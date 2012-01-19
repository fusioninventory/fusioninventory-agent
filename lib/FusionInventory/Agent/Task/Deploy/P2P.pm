package FusionInventory::Agent::Task::Deploy::P2P;

use strict;
use warnings;

use English qw(-no_match_vars);
use HTTP::Request::Common qw(GET);
use Net::IP;
use POE qw(Component::Client::TCP Component::Client::Ping);

# POE Debug
#sub POE::Kernel::TRACE_REFCNT () { 1 }

my %cache = (
    date => 0,
    data => undef
);

sub _computeIPToTest {
    my ($addresses, $ipLimit) = @_;

    # Max number of IP to pick from a network range
    $ipLimit = 255 unless $ipLimit;

    my @ipToTest;
    foreach my $address (@$addresses) {
        my @ip_bytes   = split(/\./, $address->{ip});
        my @mask_bytes = split(/\./, $address->{mask});
        next if $ip_bytes[0] == 127; # Ignore 127.x.x.x addresses
        next if $ip_bytes[0] == 169; # Ignore 169.x.x.x range too

        # compute range
        my @start;
        my @end;

        foreach my $idx (0..3) {
            push @start, $ip_bytes[$idx] & (255 & $mask_bytes[$idx]);
            push @end,   $ip_bytes[$idx] | (255 - $mask_bytes[$idx]);
        }

        my $ipStart = join('.', @start);
        my $ipEnd   = join('.', @end);

        my $ipInterval = Net::IP->new($ipStart.' - '.$ipEnd) || die Net::IP::Error();

        next if $ipStart eq $ipEnd;

        if ($ipInterval->size() > 5000) {
            print("Range to large: ".$ipInterval->size()." (max 5000)\n");
            next;
        }

        my $after = 0;
        my @newIPs;
        do {
            push @newIPs, $ipInterval->ip();
            if ($after || $address->{ip} eq $ipInterval->ip()) {
                $after++;
            } elsif (@newIPs > ($ipLimit / 2)) {
                shift @newIPs;
            }
        } while (++$ipInterval && ($after < ($ipLimit / 2)));


        print("Scanning from ".$newIPs[0]." to ".$newIPs[@newIPs-1]."\n");

        push @ipToTest, @newIPs;

    }
    return @ipToTest;

}

sub fisher_yates_shuffle {
    my $deck = shift;  # $deck is a reference to an array

    return unless @$deck; # must not be empty!

    my $i = @$deck;
    while (--$i) {
        my $j = int rand ($i+1);
        @$deck[$i,$j] = @$deck[$j,$i];
    }
}

sub findPeer {
    my ( $port ) = @_;

print "cachedate: ".$cache{date}."\n";
    print("looking for a peer in the network\n");
    return $cache{data} if $cache{date} + 600 > time;

    my @addresses;

    print $OSNAME."\n";
    if ($OSNAME eq 'linux') {
        FusionInventory::Agent::Tools::Linux->require();
        @addresses =
            map {
                { 
                    ip   => $_->{IPADDRESS},
                    mask => $_->{IPMASK},
                }
            } 
            grep { $_->{IPMASK} =~ /^255\.255\.255/ }
            grep { $_->{STATUS} eq 'Up' }
            FusionInventory::Agent::Tools::Linux::getInterfacesFromIfconfig();

    } elsif ($OSNAME eq 'MSWin32') {
        foreach (`route print`) {
            if (/^\s+(\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})\s+(255\.255\.\d{1,3}\.\d{1,3})/x) {
                push @addresses, { 
                    ip   => $1,
                    mask => $2
                };
            }
        }
    }

    if (!@addresses) {
        print "No network to scan...\n";
        return;
    }

    $cache{date}=time;
    $cache{data}=scan({port => $port}, _computeIPToTest(\@addresses));
    return $cache{data};
}


sub scan {
    my ($params, @ipToTestList) = @_;
    my $port = $params->{port};
    my $sha512 = $params->{sha512};


    fisher_yates_shuffle(\@ipToTestList);

    POE::Component::Client::Ping->spawn(
        Timeout => 5,           # defaults to 1 second
    );

    my $found;
    my $running = 0;

    my @needCheck2 = 0;
    my $ipCpt = int(@ipToTestList);
    my @ipFound;
    POE::Session->create(
        inline_states => {
            _start => sub {
                $_[HEAP]->{shutdown_on_error}=1;
                $_[KERNEL]->yield( "add", 0 );
            },
            add => sub {
            my $ipToTest = shift @ipToTestList;

            return unless $ipToTest;

            print ".";

            $_[KERNEL]->post(
                "pinger", # Post the request to the "pingthing" component.
                "ping",      # Ask it to "ping" an address.
                "pong",      # Have it post an answer as a "pong" event.
                $ipToTest,    # This is the address we want to ping.
                );
            $_[KERNEL]->delay(add => 0.1) if @ipToTestList;

            },
            pong => sub {
                my ($request, $response) = @_[ARG0, ARG1];

                my ($addr) = @$response;

                if (!$addr) {
                    $ipCpt--;
                    print "cpt:".$ipCpt."\n";

                    return;
                }
                print($addr." is up\n");

                POE::Component::Client::TCP->new(
                    RemoteAddress  => $addr,
                    RemotePort     => $port,
                    ConnectTimeout => 10,
                    Connected      => sub {
                        push @ipFound, "http://$addr:$port/deploy/getFile/";
                        $_[KERNEL]->yield("shutdown");
                    },
                    ServerInput    => sub {
                        $_[KERNEL]->yield("shutdown");
                    },
                );
            },
        },
    );
# Run everything, and exit when it's all done.
    $poe_kernel->run();
    print "byebye\n";
    return \@ipFound;
}

1;
