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
    foreach my $data (@$addresses) {
        next if $data->{ip}[0] == 127; # Ignore 127.x.x.x addresses
        next if $data->{ip}[0] == 169; # Ignore 169.x.x.x range too

        my @begin;
        my @end;

        foreach my $idx (0..3) {
            push @begin, $data->{ip}[$idx] & (255 & $data->{mask}[$idx]);
            push @end, $data->{ip}[$idx] | (255 - $data->{mask}[$idx]);
        }

        my $ip = sprintf("%d.%d.%d.%d", @{$data->{ip}});
        my $ipStart = sprintf("%d.%d.%d.%d", @begin);
        my $ipEnd = sprintf("%d.%d.%d.%d", @end);

        my $ipInterval = Net::IP->new ($ipStart.' - '.$ipEnd) || die  (Net::IP::Error());

        next if $ipStart eq $ipEnd;

        if ($ipInterval->size() > 5000) {
            print("Range to large: ".$ipInterval->size()." (max 5000)\n");
            next;
        }

        my $after = 0;
        my @newIPs;
        do {
            push @newIPs, $ipInterval->ip();
            if ($after || $ip eq $ipInterval->ip()) {
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
        my $stack;
        foreach (`LC_ALL=C ifconfig`) {
#        inet addr:192.168.69.106  Bcast:192.168.69.255  Mask:255.255.255.0
            if (/^\s*$/) {
                $stack = undef; 
            } elsif($stack && /Interrupt:\d+\s+/) {
# This is a real physical network card
                push @addresses, $stack; 
                $stack = undef; 
            } elsif
            (/inet\saddr:(\d{1,3})\.(\d{1,3})\.(\d{1,3})\.(\d{1,3}).*Mask:(255)\.(255).(\d+)\.(\d+)/x) {
                print "→".$_."\n";
                $stack = { 
                    ip => [ $1, $2, $3, $4 ],
                    mask => [ 255, 255, 255, $8 ]
                };
            }

        }
    } elsif ($OSNAME eq 'MSWin32') {
        foreach (`route print`) {
            if (/^\s+(\d{1,3})\.(\d{1,3})\.(\d{1,3})\.(\d{1,3})\s+(255)\.(255)\.(\d+)\.(\d+)/x) {
                push @addresses, { 
                    ip => [ $1, $2, $3, $4 ],
                       mask => [ 255, 255, 255, $8 ]
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
            Timeout             => 5,           # defaults to 1 second
            );


    my $found;
    my $running = 0;

    my $thisIsWindows = ($OSNAME eq 'MSWin32');

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
                        RemoteAddress => $addr,
                        RemotePort    => $port,
                        ConnectTimeout=> 10,
                        Connected     => sub {
                            push @ipFound, 'http://'.$addr.':'.$port.'/deploy/getFile/';
                            $_[KERNEL]->yield("shutdown");
                            },
                        ServerInput   => sub {
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
