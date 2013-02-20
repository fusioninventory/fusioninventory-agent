package FusionInventory::Agent::Task::Deploy::P2P;

use strict;
use warnings;

use English qw(-no_match_vars);
use HTTP::Request::Common qw(GET);
use Net::IP;
use POE qw(Component::Client::TCP Component::Client::Ping);

use UNIVERSAL::require;

# POE Debug
#sub POE::Kernel::TRACE_REFCNT () { 1 }

my %cache = (
    date => 0,
    data => undef
);

sub _computeIPToTest {
    my ($logger, $addresses, $ipLimit) = @_;

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
            ## no critic (ProhibitBitwise)
            push @start, $ip_bytes[$idx] & (255 & $mask_bytes[$idx]);
            push @end,   $ip_bytes[$idx] | (255 - $mask_bytes[$idx]);
        }

        my $ipStart = join('.', @start);
        my $ipEnd   = join('.', @end);

        my $ipInterval = Net::IP->new($ipStart.' - '.$ipEnd) || die Net::IP::Error();

        next if $ipStart eq $ipEnd;

        if ($ipInterval->size() > 5000) {
            $logger->debug("Range to large: ".$ipInterval->size()." (max 5000)");
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


        $logger->debug("Scanning from ".$newIPs[0]." to ".$newIPs[@newIPs-1]) if $logger;

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
    my ( $port, $logger ) = @_;

#    $logger->debug("cachedate: ".$cache{date});
    $logger->info("looking for a peer in the network");
    return $cache{data} if $cache{date} + 600 > time;

    my @interfaces;


    if ($OSNAME eq 'linux') {
        FusionInventory::Agent::Tools::Linux->require();
        @interfaces = FusionInventory::Agent::Tools::Linux::getInterfacesFromIfconfig();

    } elsif ($OSNAME eq 'MSWin32') {
        FusionInventory::Agent::Tools::Win32->require();
        @interfaces = FusionInventory::Agent::Tools::Win32::getInterfaces();
    }


    my @addresses;

    foreach my $interface (@interfaces) {
#if interface has both ip and netmask setup then push the address
        next unless $interface->{IPADDRESS};
        next unless $interface->{IPMASK};
        next unless lc($interface->{STATUS}) eq 'up';
        next if $interface->{IPADDRESS} =~ /^127\./;


        push @addresses, {
            ip   => $interface->{IPADDRESS},
            mask => $interface->{IPMASK}
        };
    }


    if (!@addresses) {
        $logger->info("No network to scan...");
        return;
    }

    $cache{date}=time;
    $cache{data}=scan({logger => $logger, port => $port}, _computeIPToTest($logger, \@addresses));
    return $cache{data};
}


sub scan {
    my ($params, @ipToTestList) = @_;
    my $port = $params->{port};
    my $logger = $params->{logger};


    fisher_yates_shuffle(\@ipToTestList);

    POE::Component::Client::Ping->spawn(
        Timeout => 5,           # defaults to 1 second
    );

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
			
            if (@ipToTestList && @ipFound < 30) {
                $_[KERNEL]->delay(add => 0.1)
            } else {
                $_[KERNEL]->yield("shutdown");
            }


            },
            pong => sub {
                my ($response) = $_[ARG1];

                my ($addr) = @$response;

                if (!$addr) {
                    $ipCpt--;
                    $logger->debug("cpt:".$ipCpt);

                    return;
                }
                $logger->debug($addr." is up");

                POE::Component::Client::TCP->new(
                    RemoteAddress  => $addr,
                    RemotePort     => $port,
                    ConnectTimeout => 10,
                    Connected      => sub {
                        push @ipFound, "http://$addr:$port/deploy/getFile/";
                    },
		    ServerInput   => sub { }
                );
            },
        },
    );
# Run everything, and exit when it's all done.
    $poe_kernel->run();
    $logger->debug("end of POE loop");
    return \@ipFound;
}

1;
