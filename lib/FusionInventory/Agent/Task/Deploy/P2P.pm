package FusionInventory::Agent::Task::Deploy::P2P;

use strict;
use warnings;

use English qw(-no_match_vars);
use Net::IP;
use POE qw(Component::Client::TCP Component::Client::Ping);

use UNIVERSAL::require;

# POE Debug
#sub POE::Kernel::TRACE_REFCNT () { 1 }

my $last_run;
my @peers;

sub findPeers {
    my ( $port, $logger ) = @_;

#    $logger->debug("cachedate: ".$cache{date});
    $logger->info("looking for a peer in the network");
    return @peers if $last_run + 600 > time;

    my @interfaces;

    if ($OSNAME eq 'linux') {
        FusionInventory::Agent::Tools::Linux->require();
        @interfaces = FusionInventory::Agent::Tools::Linux::getInterfacesFromIfconfig();

    } elsif ($OSNAME eq 'MSWin32') {
        FusionInventory::Agent::Tools::Win32->require();
        @interfaces = FusionInventory::Agent::Tools::Win32::getInterfaces();
    }

    if (!@interfaces) {
        $logger->info("No network interfaces found");
        return;
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
        $logger->info("No local address found");
        return;
    }

    my @potential_peers;
    
    foreach my $address (@addresses) {
        push @potential_peers, _getPotentialPeers($logger, $address);
    }

    if (!@potential_peers) {
        $logger->info("No neighbour address found");
        return;
    }

    $last_run = time;
    @peers    = _scanPeers($logger, $port, @potential_peers);

    return @peers;
}

sub _getPotentialPeers {
    my ($logger, $address, $ipLimit) = @_;

    # Max number of IP to pick from a network range
    $ipLimit = 255 unless $ipLimit;

    my @ipToTest;

    my @ip_bytes   = split(/\./, $address->{ip});
    my @mask_bytes = split(/\./, $address->{mask});
    return if $ip_bytes[0] == 127; # Ignore 127.x.x.x addresses
    return if $ip_bytes[0] == 169; # Ignore 169.x.x.x range too

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

    return if $ipStart eq $ipEnd;

    if ($ipInterval->size() > 5000) {
        $logger->debug("Range to large: ".$ipInterval->size()." (max 5000)");
        return;
    }

    my $after = 0;
    my @peers;
    do {
        push @peers, $ipInterval->ip();
        if ($after || $address->{ip} eq $ipInterval->ip()) {
            $after++;
        } elsif (@peers > ($ipLimit / 2)) {
            shift @peers;
        }
    } while (++$ipInterval && ($after < ($ipLimit / 2)));

    return @peers;
}

sub _scanPeers {
    my ($logger, $port, @addresses) = @_;

    $logger->debug("Scanning from $addresses[0] to $addresses[-1]") if $logger;

    _fisher_yates_shuffle(\@addresses);

    POE::Component::Client::Ping->spawn(
        Timeout => 5,           # defaults to 1 second
    );

    my $ipCpt = int(@addresses);
    my @ipFound;
    POE::Session->create(
        inline_states => {
            _start => sub {
                $_[HEAP]->{shutdown_on_error}=1;
                $_[KERNEL]->yield( "add", 0 );
            },
            add => sub {
            my $ipToTest = shift @addresses;

            return unless $ipToTest;

            print ".";

            $_[KERNEL]->post(
                "pinger", # Post the request to the "pingthing" component.
                "ping",      # Ask it to "ping" an address.
                "pong",      # Have it post an answer as a "pong" event.
                $ipToTest,    # This is the address we want to ping.
                );

            if (@addresses && @ipFound < 30) {
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

sub _fisher_yates_shuffle {
    my $deck = shift;  # $deck is a reference to an array

    return unless @$deck; # must not be empty!

    my $i = @$deck;
    while (--$i) {
        my $j = int rand ($i+1);
        @$deck[$i,$j] = @$deck[$j,$i];
    }
}


1;
