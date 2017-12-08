package FusionInventory::Agent::Task::Inventory::Win32::Firewall;

use strict;
use warnings;

use FusionInventory::Agent::Tools;
use FusionInventory::Agent::Tools::Win32;
use FusionInventory::Agent::Tools::Constants;

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

    my $profiles = _getFirewallProfiles();
    my @profiles = _makeProfileAndConnectionsAssociation(firewallProfiles => $profiles, logger => $logger);
    for my $profile (@profiles) {
        $inventory->addEntry(
            section => 'FIREWALL',
            entry   => $profile
        );
    }

}

sub _getFirewallProfiles {
    my $key = getRegistryKey( path =>
        "HKEY_LOCAL_MACHINE/SYSTEM/CurrentControlSet/services/SharedAccess/Parameters/FirewallPolicy"
    );
    return unless $key;

    return _extractFirewallProfilesFromRegistryKey(
        key => $key
    );
}

sub _extractFirewallProfilesFromRegistryKey {
    my (%params) = @_;

    return unless $params{key};
    my $key = $params{key};

    my $subKeys = {
        domain   => 'DomainProfile',
        public   => 'PublicProfile',
        standard => 'StandardProfile'
    };
    my $profiles = {};
    for my $profile (keys %$subKeys) {
        next unless $key->{$subKeys->{$profile} . '/'};
        next unless defined $key->{$subKeys->{$profile} . '/'}->{'/EnableFirewall'};
        my $enabled = hex2dec($key->{ $subKeys->{$profile} . '/'}->{'/EnableFirewall'});
        $profiles->{$profile} = {
            STATUS => $enabled
                ? STATUS_ON
                : STATUS_OFF,
            PROFILE => $subKeys->{$profile}
        };
    }

    return $profiles;
}

sub _makeProfileAndConnectionsAssociation {
    my (%params) = @_;

    return unless $params{firewallProfiles};

    my ($profilesKey, $signaturesKey) = $params{profilesKey} && $params{signaturesKey} ?
        ($params{profilesKey}, $params{signaturesKey}) :
        _retrieveProfilesAndSignaturesKey();
    return unless $profilesKey && $signaturesKey;

    my %funcParams = (
        additionalProperties => {
            NetWorkAdapterConfiguration        => [ qw/DNSDomain/ ],
            NetWorkAdapter => [ qw/GUID/ ]
        },
        list => $params{list} ? $params{list} : {}
    );

    foreach my $interface (getInterfaces(
        %funcParams
    )) {
        next if ($interface->{STATUS} ne 'Up');

        my $profile;
        my $domainSettings = _getConnectionDomainSettings(
            guid => $interface->{GUID},
            key => $params{dnsRegisteredAdaptersKey} || undef
        );
        # check if connection with domain
        if ($domainSettings) {
            $profile = _retrieveFirewallProfileWithdomain(
                profileName => $domainSettings->{'/PrimaryDomainName'},
                profilesKey => $profilesKey
            );
        } else {
            $profile = _retrieveFirewallProfileWithoutDomain(
                DNSDomain => $interface->{DNSDomain},
                profilesKey => $profilesKey,
                signaturesKey => $signaturesKey
            );
        }

        next unless $profile;

        my $category = hex2dec($profile->{'/Category'});
        unless (defined $params{firewallProfiles}->{$mappingFirewallProfiles[$category]}->{CONNECTIONS}) {
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

    my $registeredAdapter = $params{key} ?
        $params{key}->{$params{guid} . '/'} :
        getRegistryKey(
            logger => $params{logger},
            path => 'HKEY_LOCAL_MACHINE/SYSTEM/CurrentControlSet/services/Tcpip/Parameters/DNSRegisteredAdapters/' . $params{guid}
        );
    if ($registeredAdapter && $registeredAdapter->{'/PrimaryDomainName'}) {
        return $registeredAdapter;
    }
    return;
}

sub _retrieveFirewallProfileWithoutDomain {
    my (%params) = @_;

    return unless $params{DNSDomain} && $params{profilesKey} && $params{signaturesKey};

    my $profilesKey = $params{profilesKey};
    my $signaturesKey = $params{signaturesKey};

    my $dnsDomain = $params{DNSDomain};
    my $profileGuid;
    for my $sig (values %{$signaturesKey->{'Managed/'}}, values %{$signaturesKey->{'Unmanaged/'}}) {
        if ($sig->{'/FirstNetwork'} eq $dnsDomain) {
            $profileGuid = $sig->{'/ProfileGuid'};
            last;
        }
    }
    return unless $profileGuid && $profilesKey->{$profileGuid . '/'};

    return $profilesKey->{$profileGuid . '/'};
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
    }
    return;
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
