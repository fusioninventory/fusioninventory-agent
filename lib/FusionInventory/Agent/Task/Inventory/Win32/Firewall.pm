package FusionInventory::Agent::Task::Inventory::Win32::Firewall;

use strict;
use warnings;

use Storable 'dclone';

use FusionInventory::Agent::Tools;
use FusionInventory::Agent::Tools::Win32;
use FusionInventory::Agent::Tools::Constants;

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
    my $wmiParams = {};
    $wmiParams->{WMIService} = dclone ($params{inventory}->{WMIService}) if $params{inventory}->{WMIService};

    my $profiles = _getFirewallProfiles(
        %$wmiParams,
        logger => $logger
    );
    my @profiles = _makeProfileAndConnectionsAssociation(
        %$wmiParams,
        firewallProfiles => $profiles,
        logger => $logger
    );
    for my $profile (@profiles) {
        $inventory->addEntry(
            section => 'FIREWALL',
            entry   => $profile
        );
    }

}

sub _getFirewallProfiles {
    my (%params) = @_;
$DB::single = 1;
    my $key = getRegistryKey(
        %params,
        retrieveValuesForAllKeys => 1,
        path => "HKEY_LOCAL_MACHINE/SYSTEM/CurrentControlSet/services/SharedAccess/Parameters/FirewallPolicy",
        keysToKeep => {
            DomainProfile   => 1,
            PublicProfile   => 1,
            StandardProfile => 1
        }
    );
    unless ($key && ref $key eq 'HASH') {
        if ($params{logger}) {
            $params{logger}->debug2('no firewall profiles detected with params:' . "\n");
            $params{logger}->debug2(join(' - ', %params));
        }
        return;
    }

    my $profiles = _extractFirewallProfilesFromRegistryKey(
        WMIService => $params{WMIService} ? 1 : 0,
        key => $key
    );

    unless (scalar keys %$profiles) {
        $params{logger}->debug2('no firewall profiles extracted' . "\n") if $params{logger} ;
    }

    return $profiles;
}

sub _extractFirewallProfilesFromRegistryKey {
    my (%params) = @_;

    my $key = $params{key};

    my $subKeys = {
        domain   => 'DomainProfile',
        public   => 'PublicProfile',
        standard => 'StandardProfile'
    };

    my $enableFirewall = 'EnableFirewall';
    $enableFirewall = '/' . $enableFirewall unless $params{WMIService};
    my $profiles = {};
    for my $profile (keys %$subKeys) {
        my $profileSubKey = $subKeys->{$profile};
        $profileSubKey .= '/' unless $params{WMIService};
        next unless $key->{$profileSubKey};
        next unless defined $key->{$profileSubKey}->{$enableFirewall};
        my $enabled = hex2dec($key->{$profileSubKey}->{$enableFirewall});
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
        _retrieveProfilesAndSignaturesKey(%params);
    return values %{$params{firewallProfiles}} unless $profilesKey && $signaturesKey;

    my %funcParams = (
        additionalProperties => {
            NetWorkAdapterConfiguration        => [ qw/DNSDomain/ ],
            NetWorkAdapter => [ qw/GUID/ ]
        },
        list => $params{list} ? $params{list} : {}
    );

    foreach my $interface (getInterfaces(
        %params,
        %funcParams
    )) {
        next if ($interface->{STATUS} ne 'Up');

        my $profile;
        my $domainSettings = _getConnectionDomainSettings(
            %params,
            guid => $interface->{GUID},
            key => $params{dnsRegisteredAdaptersKey} || undef
        );
        # check if connection with domain
        if ($domainSettings) {
            $profile = _retrieveFirewallProfileWithdomain(
                %params,
                profileName => $domainSettings->{'/PrimaryDomainName'},
                profilesKey => $profilesKey
            );
        } else {
            $profile = _retrieveFirewallProfileWithoutDomain(
                %params,
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
            %params,
            retrieveValuesForAllKeys => 1,
            path => 'HKEY_LOCAL_MACHINE/SYSTEM/CurrentControlSet/services/Tcpip/Parameters/DNSRegisteredAdapters/' . $params{guid}
        );
    my $key1 = 'PrimaryDomainName';
    $key1 = '/' . $key1 if $params{WMIService};
    if ($registeredAdapter && $registeredAdapter->{$key1}) {
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
    my @keys = qw/ Managed Unmanaged FirstNetwork ProfileGuid /;
    unless ($params{WMIService}) {
        $keys[0] .= '/';
        $keys[1] .= '/';
        $keys[2] = '/' . $keys[2];
        $keys[3] = '/' . $keys[3];
    }
    for my $sig (values %{$signaturesKey->{$keys[0]}}, values %{$signaturesKey->{$keys[1]}}) {
        if ($sig->{$keys[2]} eq $dnsDomain) {
            $profileGuid = $sig->{$keys[3]};
            last;
        }
    }
    $profileGuid .= '/' unless $params{WMIService};
    return unless $profileGuid && $profilesKey->{$profileGuid};

    return $profilesKey->{$profileGuid};
}

sub _retrieveProfilesAndSignaturesKey {
    my (%params) = @_;
$DB::single = 1;
    my $networkListKey = getRegistryKey(
        %params,
        retrieveValuesForAllKeys => 1,
        path => 'HKEY_LOCAL_MACHINE/SOFTWARE/Microsoft/Windows NT/CurrentVersion/NetworkList'
    );
    return unless $networkListKey;

    my $key1 = 'Profiles';
    my $key2 = 'Signatures';
    unless ($params{WMIService}) {
        $key1 .= '/';
        $key2 .= '/';
    }
$DB::single = 1;
    if ($networkListKey->{$key1} && $networkListKey->{$key2}) {
        return ($networkListKey->{$key1}, $networkListKey->{$key2});
    }
    return;
}

sub _retrieveFirewallProfileWithdomain {
    my (%params) = @_;

    return unless $params{profileName} && $params{profilesKey};

    my $profiles = $params{profilesKey};
    my $profile;
    my $key1 = 'ProfileName';
    $key1 = '/' . $key1;
    for my $p (values %$profiles) {
        if ($p->{$key1} && $p->{$key1} eq $params{profileName}) {
            $profile = $p;
            last;
        }
    }

    return $profile;
}

1;
