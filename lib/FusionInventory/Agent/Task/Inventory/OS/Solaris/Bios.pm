package FusionInventory::Agent::Task::Inventory::OS::Solaris::Bios;

use strict;
use warnings;

use FusionInventory::Agent::Tools;
use FusionInventory::Agent::Tools::Solaris;

sub isEnabled {
    return
        can_run('showrev') ||
        can_run('/usr/sbin/smbios');
}

sub doInventory {
    my (%params) = @_;

    my $inventory = $params{inventory};

    my ($SystemSerial, $SystemModel, $SystemManufacturer, $BiosManufacturer,
        $BiosVersion, $BiosDate, $uuid);
    my $aarch =
        getFirstLine(command => 'arch') eq 'i86pc' ? 'i386' : 'unknown';

    my $zone = getZone();
    if ($zone) {
        if (can_run('showrev')) {
            foreach(`showrev`){
                if(/^Application architecture:\s+(\S+)/){$SystemModel = $1};
                if(/^Hardware provider:\s+(\S+)/){$SystemManufacturer = $1};
                if(/^Application architecture:\s+(\S+)/){$aarch = $1};
            }
        }
        if ($aarch eq "i386"){
            #
            # For a Intel/AMD arch, we're using smbio
            #
            foreach(`/usr/sbin/smbios`) {
                if(/^\s*Manufacturer:\s*(.+)$/){$SystemManufacturer = $1};
                if(/^\s*Serial Number:\s*(.+)$/){$SystemSerial = $1;}
                if(/^\s*Product:\s*(.+)$/){$SystemModel = $1;}
                if(/^\s*Vendor:\s*(.+)$/){$BiosManufacturer = $1};
                if(/^\s*Version String:\s*(.+)$/){$BiosVersion = $1};
                if(/^\s*Release Date:\s*(.+)$/){$BiosDate = $1};
                if(/^\s*UUID:\s*(.+)$/){$uuid = $1};
            }
        } elsif ($aarch =~ /sparc/i) {
            #
            # For a Sparc arch, we're using prtconf
            #
            my $name;
            my $OBPstring;

            foreach (`/usr/sbin/prtconf -pv`) {
                # prtconf is an awful thing to parse
                if(/^\s*banner-name:\s*'(.+)'$/){$SystemModel = $1;}
                unless ($name)
                { if(/^\s*name:\s*'(.+)'$/){$name = $1;} }
                unless ($OBPstring) {
                    if(/^\s*version:\s*'(.+)'$/){
                        $OBPstring = $1;
                        # looks like : "OBP 4.16.4 2004/12/18 05:18"
                        #    with further informations sometime
                        if( $OBPstring =~ m@OBP\s+([\d|\.]+)\s+(\d+)/(\d+)/(\d+)@ ){
                            $BiosVersion = "OBP $1";
                            $BiosDate = "$2/$3/$4";
                        } else { $BiosVersion = $OBPstring }
                    }
                }
            }
            $SystemModel .= " ($name)" if( $name );

            if( -x "/opt/SUNWsneep/bin/sneep" ) {
                $SystemSerial = getFirstLine(
                    command => '/opt/SUNWsneep/bin/sneep'
                );
            } else {
                foreach(`/bin/find /opt -name sneep`) {
                    next unless /^(\S+)/;
                    $SystemSerial = getFirstLine(command => $1);
                }
                if (!$SystemSerial){
                    $SystemSerial = "Please install package SUNWsneep";
                }
            }
        }
    } else {
        foreach(`showrev`){
            if(/^Hardware provider:\s+(\S+)/){$SystemManufacturer = $1};
        }
        $SystemModel = "Solaris Containers";
        $SystemSerial = "Solaris Containers";

    }

    $inventory->setBios({
        BVERSION      => $BiosVersion,
        BDATE         => $BiosDate,
        SMANUFACTURER => $SystemManufacturer,
        SMODEL        => $SystemModel,
        SSN           => $SystemSerial
    });

    $inventory->setHardware({
        UUID => $uuid
    });
}

1;
