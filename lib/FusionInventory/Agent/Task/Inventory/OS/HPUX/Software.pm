package FusionInventory::Agent::Task::Inventory::OS::HPUX::Software;

use strict;
use warnings;

sub isInventoryEnabled  {
    my $params = shift;

    # Do not run an package inventory if there is the --nosoft parameter
    return if ($params->{params}->{nosoft});

    can_run('swlist') and can_run('grep')
}

sub doInventory {
    my $params = shift;
    my $inventory = $params->{inventory};

    my @softList;
    my $software;



    @softList = `swlist | grep -v '^  PH' | grep -v '^#' |tr -s "\t" " "|tr -s " "` ;
    foreach my $software (@softList) {
        chomp( $software );
        if ( $software =~ /^ (\S+)\s(\S+)\s(.+)/ ) {
            $inventory->addSoftware({
                    'NAME'          => $1  ,
                    'VERSION'       => $2 ,
                    'COMMENTS'      => $3 ,
                    'PUBLISHER'     => "HP" ,
                });
        }
    }

}

1;
