package FusionInventory::Agent::Task::Inventory::Input::Solaris::Storages;

use strict;
use warnings;

use FusionInventory::Agent::Tools;

sub isEnabled {
    return canRun('iostat');
}

sub doInventory {
    my (%params) = @_;

    my $inventory = $params{inventory};
    my $logger    = $params{logger};

    foreach my $storage (_getStorages(
            logger => $logger, command => 'iostat -En'
        )) {
        $inventory->addEntry(section => 'STORAGES', entry => $storage);
    }
}

sub _getStorages {

    my $handle = getFileHandle(@_);

    return unless $handle;

    my @storages;
    my $storage;

    while (<$handle>) {
        if (/^(\S+)\s+Soft/) {
            $storage->{NAME} = $1;
        }
        if (/^
            Vendor:       \s (\S+)          \s+
            Product:      \s (\S[\w\s-]*\S) \s+
            Revision:     \s (\S+)          \s+
            Serial \s No: \s (\S*)
        /x) {
            $storage->{MANUFACTURER} = $1;
            $storage->{MODEL} = $2;
            $storage->{FIRMWARE} = $3;
            $storage->{SERIALNUMBER} = $4 if $4;
        }
        if (/<(\d+) bytes/) {
            $storage->{DISKSIZE} = int($1/(1000*1000));
        }
        if(/^Illegal/) { # Last ligne

            ## To be removed when SERIALNUMBER will be supported
            if ($storage->{SERIALNUMBER}) {
                $storage->{DESCRIPTION} = $storage->{DESCRIPTION} ? 
                $storage->{DESCRIPTION} . " S/N:" . $storage->{SERIALNUMBER} :
                                           "S/N:" . $storage->{SERIALNUMBER} ;

            }

            ## To be removed when FIRMWARE will be supported
            if ($storage->{FIRMWARE}) {
                $storage->{DESCRIPTION} = $storage->{DESCRIPTION} ?
                $storage->{DESCRIPTION} . " FW:" . $storage->{FIRMWARE} :
                                           "FW:" . $storage->{FIRMWARE} ;
            }

            if ($storage->{MANUFACTURER}) {
                ## Workaround for MANUFACTURER == ATA case
                if (($storage->{MANUFACTURER} eq 'ATA') && $storage->{MODEL} =~ s/^(Hitachi|Seagate|INTEL)\s(\S.*)/$2/i) {
                        $storage->{MANUFACTURER} = $1;
                }

                ## Drop the (R) from the manufacturer string
                $storage->{MANUFACTURER} =~ s/\(R\)$//i;
            }


            if (-l "/dev/rdsk/$storage->{NAME}s2") {
                my $rdisk_path = getFirstLine(
                    command => "ls -l /dev/rdsk/$storage->{NAME}s2"
                );
                $storage->{TYPE} =
                    $rdisk_path =~ /->.*scsi_vhci/ ? 'MPxIO' :
                    $rdisk_path =~ /->.*fp@/       ? 'FC'    :
                    $rdisk_path =~ /->.*scsi@/     ? 'SCSI'  :
                                                     undef   ;
            }
            push @storages, $storage;
            undef $storage;
        }
    }
    close $handle;

    return @storages;
}

1;
