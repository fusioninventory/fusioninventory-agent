package FusionInventory::Agent::Task::NetDiscovery::Engine;

use strict;
use warnings;

use English qw(-no_match_vars);
use XML::TreePP;

use FusionInventory::Agent::Tools;
use FusionInventory::Agent::Tools::Hardware;

sub new {
    my ($class, %params) = @_;

    my $self = {
        nmap_parameters  => $params{nmap_parameters},
        snmp_credentials => $params{snmp_credentials},
        snmp_dictionary  => $params{snmp_dictionary},
        logger           => $params{logger},
        timeout          => $params{timeout},
        datadir          => $params{datadir},
    };

    bless $self, $class;

    return $self;
}

sub _scanAddress {
    my ($self, $address) = @_;

    my $logger = $self->{logger};
    $logger->debug("scanning $address");

    my %device = (
        $self->{nmap_parameters} ? $self->_scanAddressByNmap($address)    : (),
        $INC{'Net/NBName.pm'}    ? $self->_scanAddressByNetbios($address) : (),
        $INC{'Net/SNMP.pm'}      ? $self->_scanAddressBySNMP($address)    : ()
    );

    if ($device{MAC}) {
        $device{MAC} =~ tr/A-F/a-f/;
    }

    if ($device{MAC} || $device{DNSHOSTNAME} || $device{NETBIOSNAME}) {
        $device{IP}     = $address;
        $logger->debug("device found for $address");
        return \%device;
    } else {
        $logger->debug("nothing found for $address");
        return;
    }
}

sub _scanAddressByNmap {
    my ($self, $address) = @_;

    my $device = _parseNmap(
        command => "nmap $self->{nmap_parameters} $address -oX -"
    );

    return $device ? %$device : ();
}

sub _scanAddressByNetbios {
    my ($self, $address) = @_;

    my $nb = Net::NBName->new();

    my $ns = $nb->node_status($address);

    $self->{logger}->debug2(
        sprintf "scanning %s with netbios: %s",
        $address,
        $ns ? 'success' : 'failure'
    );
    return unless $ns;

    my %device;
    foreach my $rr ($ns->names()) {
        my $suffix = $rr->suffix();
        my $G      = $rr->G();
        my $name   = $rr->name();
        if ($suffix == 0 && $G eq 'GROUP') {
            $device{WORKGROUP} = getSanitizedString($name);
        }
        if ($suffix == 3 && $G eq 'UNIQUE') {
            $device{USERSESSION} = getSanitizedString($name);
        }
        if ($suffix == 0 && $G eq 'UNIQUE') {
            $device{NETBIOSNAME} = getSanitizedString($name)
                unless $name =~ /^IS~/;
        }
    }

    $device{MAC} = $ns->mac_address();
    $device{MAC} =~ tr/-/:/;

    return %device;
}

sub _scanAddressBySNMP {
    my ($self, $address) = @_;

    my %device;
    foreach my $credential (@{$self->{snmp_credentials}}) {

        my $snmp;
        eval {
            $snmp = FusionInventory::Agent::SNMP::Live->new(
                hostname     => $address,
                timeout      => $self->{timeout},
                version      => $credential->{VERSION},
                community    => $credential->{COMMUNITY},
                username     => $credential->{USERNAME},
                authpassword => $credential->{AUTHPASSWORD},
                authprotocol => $credential->{AUTHPROTOCOL},
                privpassword => $credential->{PRIVPASSWORD},
                privprotocol => $credential->{PRIVPROTOCOL},
            );
        };
        if ($EVAL_ERROR) {
            $self->{logger}->error(
                "Unable to create SNMP session for $address: $EVAL_ERROR"
            );
            next;
        }

        %device = getDeviceInfo(
            snmp       => $snmp,
            dictionary => $self->{snmp_dictionary},
            datadir    => $self->{datadir},
        );

        # no device just means invalid credentials
        $self->{logger}->debug2(
            sprintf "scanning %s with snmp credentials %d: %s",
            $address,
            $credential->{ID},
            %device ? 'success' : 'failure'
        );

        next unless %device;

        $device{AUTHSNMP} = $credential->{ID};

        last;
    }

    return %device;
}

sub _parseNmap {
    my (%params) = @_;

    my $handle = getFileHandle(%params);
    return unless $handle;

    local $INPUT_RECORD_SEPARATOR; # Set input to "slurp" mode
    my $tpp  = XML::TreePP->new(force_array => '*');
    my $tree = $tpp->parse(<$handle>);
    close $handle;
    return unless $tree;

    my $result;

    foreach my $host (@{$tree->{nmaprun}[0]{host}}) {
        foreach my $address (@{$host->{address}}) {
            next unless $address->{'-addrtype'} eq 'mac';
            $result->{MAC}           = $address->{'-addr'};
            $result->{NETPORTVENDOR} = $address->{'-vendor'};
            last;
        }
        foreach my $hostname (@{$host->{hostnames}}) {
            my $name = eval {$hostname->{hostname}[0]{'-name'}};
            next unless $name;
            $result->{DNSHOSTNAME} = $name;
        }
    }

    return $result;
}

1;

__END__

=head1 NAME

FusionInventory::Agent::Task::NetDiscovery::Engine - Network discovery engine
