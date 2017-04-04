package FusionInventory::Agent::Task::Inventory::Win32::Firewall;

use strict;
use warnings;

use FusionInventory::Agent::Tools;
use FusionInventory::Agent::Tools::Win32;
use FusionInventory::Agent::Task::Inventory::Generic::Firewall;

use Data::Dumper;
use Storable 'dclone';

my @mappingFirewallProfiles = qw/public standard domain/;

sub isEnabled {
    my (%params) = @_;
    return 0 if $params{no_category}->{firewall};
    return 1;
}

sub doInventory {
    my (%params) = @_;

    my $inventory = $params{inventory};
    my $logger    = $params{logger};

    my $profiles = _getFirewallProfiles(logger => $logger);
    my @profiles = _makeProfileAndConnectionsAssociation(firewallProfiles => $profiles, logger => $logger);
    my $dd = Data::Dumper->new([\@profiles]);
    $logger->debug2('@profiles : ');
    $logger->debug2($dd->Dump);
    for my $profile (@profiles) {
        $inventory->addEntry(
            section => 'FIREWALL',
            entry   => $profile
        );
    }

}

sub _getFirewallProfiles {
    my (%params) = @_;

    my $key = getRegistryKey( path =>
        "HKEY_LOCAL_MACHINE/SYSTEM/CurrentControlSet/services/SharedAccess/Parameters/FirewallPolicy"
    );
    return unless $key;
    my $subKeys = {
        domain   => 'DomainProfile',
        public   => 'PublicProfile',
        standard => 'StandardProfile'
    };
    my $profiles = {};
    $params{logger}->debug2(join( ' - ', keys %$key)) if $params{logger};
    for my $profile (keys %$subKeys) {
        next unless $key->{$subKeys->{$profile} . '/'};
        $params{logger}->debug2(join(' - ', keys %{$key->{ $subKeys->{$profile}}})) if $params{logger};
        next unless defined $key->{$subKeys->{$profile} . '/'}->{'/EnableFirewall'};
        $params{logger}->debug2($key->{ $subKeys->{$profile} . '/'}->{'/EnableFirewall'})
          if $params{logger};
        my $enabled = hex2dec($key->{ $subKeys->{$profile} . '/'}->{'/EnableFirewall'});
        $params{logger}->debug2($enabled) if $params{logger};
        $profiles->{$profile} = {
            STATUS => $enabled
                ? FusionInventory::Agent::Constants::FIREWALL_STATUS_ON
                : FusionInventory::Agent::Constants::FIREWALL_STATUS_OFF,
            PROFILE => $subKeys->{$profile}
        };
    }

    return $profiles;
}

sub _makeProfileAndConnectionsAssociation {
    my (%params) = @_;

    return unless $params{firewallProfiles};

    my ($profilesKey, $signaturesKey) = _retrieveProfilesAndSignaturesKey();
    return unless $profilesKey && $signaturesKey;

    foreach my $interface (getInterfaces(
        additionalPropertiesNetWorkAdapterConfiguration => [qw/DNSDomain/],
        additionalPropertiesNetWorkAdapter => [qw/GUID/]
    )) {
        next if ($interface->{STATUS} ne 'Up');

        my $profile;

        my $domainSettings = _getConnectionDomainSettings(
            guid => $interface->{GUID}
        );
        # check if connection with domain
        if ($domainSettings) {
            $profile = _retrieveFirewallProfileWithdomain(
                profileName => $domainSettings->{'/PrimaryDomainName'},
                profilesKey => $profilesKey
            )
        } else {
            $profile = _retrieveFirewallProfileWithoutDomain(
                DNSDomain => $interface->{DNSDomain},
                profilesKey => $profilesKey,
                signaturesKey => $signaturesKey
            );
        }

        next unless $profile;
	
        my $category = hex2dec($profile->{'/Category'});
        if (not defined $params{firewallProfiles}->{$mappingFirewallProfiles[$category]}->{CONNECTIONS}) {
            $params{firewallProfiles}->{$mappingFirewallProfiles[$category]}->{CONNECTIONS} = [];
        }
        my $connection = {DESCRIPTION => $interface->{DESCRIPTION}};
        $connection->{IPADDRESS} = $interface->{IPADDRESS} if ($interface->{IPADDRESS});
        $connection->{IPADDRESS6} = $interface->{IPADDRESS6} if ($interface->{IPADDRESS6});
        push @{$params{firewallProfiles}->{$mappingFirewallProfiles[$category]}->{CONNECTIONS}}, $connection;
    }

    my @profiles = ();
    for my $p (values %{$params{firewallProfiles}}) {
        my @p;
        if ($p->{CONNECTIONS} && ref($p->{CONNECTIONS}) eq 'ARRAY') {
            my @conns = @{$p->{CONNECTIONS}};
            delete $p->{CONNECTIONS};
            for my $conn (@conns) {
                my $newP = dclone $p;
                while (my ($k, $v) = each %$conn) {
                    $newP->{$k} = $v;
                }
                push @p, $newP;
            }
        } else {
            push @p, $p;
        }
        push @profiles, @p;
    }

    return @profiles;
}

sub _getConnectionDomainSettings {
    my (%params) = @_;

    return unless $params{guid};

    my $registeredAdapter = getRegistryKey(
        logger => $params{logger},
        path => 'HKEY_LOCAL_MACHINE/SYSTEM/CurrentControlSet/services/Tcpip/Parameters/DNSRegisteredAdapters/' . $params{guid}
    );
    if ($registeredAdapter && $registeredAdapter->{'/PrimaryDomainName'}) {
        return $registeredAdapter;
    } else {
        return;
    }
}

sub _retrieveFirewallProfileWithoutDomain {
    my (%params) = @_;

    return unless $params{DNSDomain} && $params{profilesKey} && $params{signaturesKey};

    my $profilesKey = $params{profilesKey};
    my $signaturesKey = $params{signaturesKey};

    my $dnsDomain = $params{DNSDomain};
    $params{logger}->debug2('dnsDomain : ' . $dnsDomain) if $params{logger};
    my $profileGuid;
    for my $sig (values %{$signaturesKey->{'Managed/'}}, values %{$signaturesKey->{'Unmanaged/'}}) {
        $params{logger}->debug2('/firstNetwork : ' . $sig->{'/FirstNetwork'}) if $params{logger} && $sig->{'/FirstNetwork'};
        if ($sig->{'/FirstNetwork'} eq $dnsDomain) {
            $profileGuid = $sig->{'/ProfileGuid'};
            last;
        }
    }
    return unless $profileGuid && $profilesKey->{$profileGuid};

    return $profilesKey->{$profileGuid};
}

sub _retrieveProfilesAndSignaturesKey {
    my (%params) = @_;

    my $networkListKey = getRegistryKey(
        logger => $params{logger} || undef,
        path => 'HKEY_LOCAL_MACHINE/SOFTWARE/Microsoft/Windows NT/CurrentVersion/NetworkList'
    );
    return unless $networkListKey;

    if ($networkListKey->{'Profiles/'} && $networkListKey->{'Signatures/'}) {
        return ($networkListKey->{'Profiles/'}, $networkListKey->{'Signatures/'});
    } else {
        return;
    }
}

sub _retrieveFirewallProfileWithdomain {
    my (%params) = @_;

    return unless $params{profileName} && $params{profilesKey};

    my $profiles = $params{profilesKey};
    my $profile;
    for my $p (values %$profiles) {
        if ($p->{'/ProfileName'} && $p->{'/ProfileName'} eq $params{profileName}) {
            $profile = $p;
            last;
        }
    }

    return $profile;
}

1;
