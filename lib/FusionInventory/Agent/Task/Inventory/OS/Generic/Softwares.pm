package FusionInventory::Agent::Task::Inventory::OS::Generic::Softwares;
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
    my (%params) = @_;

    return
        !$params{config}->{no_software} &&
        -d $params{confdir} . '/softwares';
}

sub doInventory {
    my (%params) = @_;

    my $inventory = $params{inventory};
    my $logger    = $params{logger};
    my $directory = $params{confdir} . '/softwares';

    my $handle = getDirectoryHandle(
        directory => $directory, logger => $logger
    );
    return unless $handle;

    my @dots = readdir($handle);
    foreach (@dots) {
        if (-f $directory."/".$_ ) {
            my $comm = $directory."/".$_;
            $logger->debug("Running appli detection scripts from ".$comm);
            foreach (`$comm`) {
                my $ligne = $_;
                chomp($ligne);
                my ($vendor,$soft,$version,$commentaire) = split(/\#/,$ligne);
                $inventory->addEntry({
                    section => 'SOFTWARES',
                    entry   => {
                        PUBLISHER => $vendor,
                        NAME      => $soft,
                        VERSION   => $version,
                        FILESIZE  => "",
                        COMMENTS  => $commentaire,
                        FROM      => 'ByHand'
                    }
                });
            }
        }
    }

    closedir $handle;
}

1;
