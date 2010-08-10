package FusionInventory::Agent::Task::Inventory::OS::Solaris::Storages;
use strict;
#use warning;

#sd0      Soft Errors: 0 Hard Errors: 0 Transport Errors: 0
#Vendor: HITACHI  Product: DK32EJ72NSUN72G  Revision: PQ08 Serial No: 43W14Z080040A34E
#Size: 73.40GB <73400057856 bytes>
#Media Error: 0 Device Not Ready: 0 No Device: 0 Recoverable: 0
#Illegal Request: 0 Predictive Failure Analysis: 0

# With -En :
#c8t60060E80141A420000011A420000300Bd0 Soft Errors: 1 Hard Errors: 0 Transport Errors: 0
#Vendor: HITACHI  Product: OPEN-V      -SUN Revision: 5009 Serial No:
#Size: 64.42GB <64424509440 bytes>
#Media Error: 0 Device Not Ready: 0 No Device: 0 Recoverable: 0
#Illegal Request: 1 Predictive Failure Analysis: 0


sub isInventoryEnabled { can_run ("iostat") }

sub doInventory {
    my $params = shift;
    my $inventory = $params->{inventory};

    my $manufacturer;
    my $model;
    my $description;
    my $capacity;
    my $name;
    my $rev;
    my $sn;
    my $type;
    my $flag_first_line;
    my $rdisk_path;

    foreach(`iostat -En`){
#print;
        $flag_first_line = 0;
        if(/^(\S+)\s+Soft/){
            $name = $1;
        }
        if(/^.*Product:\s*(\S+)/){
            $model = $1;
        }
        if(/^.*Serial No:\s*(\S+)/){
            $sn = $1;
            ## To be removed when SERIALNUMBER will be supported
            $description = "S/N:$sn";
            ##
        }
        if(/^.*Revision:\s*(\S+)/){
            $rev = $1;
        }
        if(/^Vendor:\s*(\S+)/){
            $manufacturer = $1;
        }


        if(/^.*<(\d+)\s*bytes/){
            $capacity = int($1/(1000*1000));
        }
        ## To be removed when FIRMWARE will be supported
        if ($rev) {
            $description .= ' ' if $description;
            $description .= "FW:$rev";
        }

        if (-l "/dev/rdsk/${name}s2") {
            $rdisk_path=`ls -l /dev/rdsk/${name}s2`;
            if( $rdisk_path =~ /.*->.*scsi_vhci.*/ ) {
                $type="MPxIO";
            }
            elsif( $rdisk_path =~ /.*->.*fp@.*/ ) {
                $type="FC";
            }
            elsif( $rdisk_path =~ /.*->.*scsi@.*/ ) {
                $type="SCSI";
            }
        }
        use Data::Dumper;

        if(/^Illegal/) { # Last ligne
            $inventory->addStorage({
                    NAME => $name,
                    MANUFACTURER => $manufacturer,
                    MODEL => $model,
                    DESCRIPTION => $description,
                    TYPE => $type,
                    FIRMWARE => $rev,
                    SERIALNUMBER => $sn,
                    DISKSIZE => $capacity
                });

            $manufacturer='';
            $model='';
            $description='';
            $name='';
            $rev='';
            $sn='';
            $type='';
        }


    }
}

1;
