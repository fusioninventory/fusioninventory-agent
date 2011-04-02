package FusionInventory::Agent::Task::Inventory::OS::Generic::Packaging::ByHand;
#How does it work ?
#
#Create a directory called software in place where you have your
#"modules.conf" file.
#Put your scripts in this directory.
#The scripts have to write on the STDIO with the following format :
#publisher#software#version#comment
#

use strict;
use warnings;

use FusionInventory::Agent::Tools;

sub isInventoryEnabled { 
    return 1;
}

sub doInventory {
    my $params = shift;
    my $inventory = $params->{inventory};
    my $confdir = $params->{confdir};
    my $ligne;
    my $soft;
    my $comm;
    my $version;
    my $file;
    my $vendor;
    my $commentaire;
    my @dots;

    $file = $confdir . '/softwares';

    return unless -f $file;

    my $logger = $params->{logger};

    if (opendir my $handle, $file) {
        @dots = readdir($handle);
        foreach (@dots) { 
            if ( -f $file."/".$_ ) {
                $comm = $file."/".$_;
                $logger->debug("Running appli detection scripts from ".$comm);
                foreach (`$comm`) {
                    $ligne = $_;
                    chomp($ligne);
                    ($vendor,$soft,$version,$commentaire) = split(/\#/,$ligne);
                    $inventory->addSoftware ({
                        'PUBLISHER' => $vendor,
                        'NAME'          => $soft,
                        'VERSION'       => $version,
                        'FILESIZE'      => "",
                        'COMMENTS'      => $commentaire,
                        'FROM'          => 'ByHand'
                    });
                }	
            }
        }	  	

        closedir $handle;
    }
    1;
}
1;
