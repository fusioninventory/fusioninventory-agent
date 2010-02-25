package FusionInventory::Agent::Task::Inventory::OS::Win32::Software;

use strict;
use warnings;
# http://techtasks.com/code/viewbookcode/1417


use Win32::TieRegistry ( Delimiter=>"/", ArrayValues=>0 );

sub isInventoryEnabled {1}

sub hexToDec {
    my $val = shift;

    return unless $val;

    return $val unless $val =~ /^0x/; 

    my $tmp = $val;

    $tmp =~ s/^0x0*//i;
    return hex($tmp); 
}

sub processSoftwares {
    my $params = shift;

    my $softwares = $params->{softwares};

    my $inventory = $params->{inventory};
    my $is64bit = $params->{is64bit};

    foreach my $name ( keys %$softwares ) {
        my $data = $softwares->{$name};
        next unless keys %$data;

    # odd, found on Win2003
        next unless keys %$data > 2;

    
        my $name = $data->{'/DisplayName'};
        my $comments = $data->{'/Comments'};
        my $version = $data->{'/DisplayVersion'};
        my $publisher = $data->{'/Publisher'};
        my $urlInfoAbout = $data->{'/URLInfoAbout'};
        my $helpLink = $data->{'/HelpLink'};
        my $uninstallString = $data->{'/UninstallString'};
        my $noRemove;
        my $releaseType = $data->{'/ReleaseType'};
        my $installDate = $data->{'/InstallDate'};
        my $versionMinor = hexToDec($data->{'/VersionMinor'});
        my $versionMajor = hexToDec($data->{'/VersionMajor'});


        if ($data->{'/NoRemove'}) {
           $noRemove = ($data->{'/NoRemove'} =~ /1/)?1:0;
       }

        $inventory->addSoftware ({
            COMMENTS => $comments,
#            FILESIZE => $filesize,
#            FOLDER => $folder,
            FROM => "registry",
            HELPLINK => $helpLink,
            INSTALLDATE => $installDate,
            NAME => $name,
            NOREMOVE => $noRemove,
            RELEASETYPE => $releaseType,
            PUBLISHER => $publisher,
            UNINSTALL_STRING => $uninstallString,
            URL_INFO_ABOUT => $urlInfoAbout,
            VERSION => $version,
            VERSION_MINOR => $versionMinor,
            VERSION_MAJOR => $versionMajor,
            IS64BIT => $is64bit,
        });
}

sub doInventory {
    my $params = shift;

    my $inventory = $params->{inventory};

    my $KEY_WOW64_64KEY = 0x100; 
    my $KEY_WOW64_32KEY = 0x200; 
    my $machKey32bit= $Registry->Open( "LMachine", {Access=>Win32::TieRegistry::KEY_READ()|$KEY_WOW64_32KEY,Delimiter=>"/"} );
    my $machKey64bit= $Registry->Open( "LMachine", {Access=>Win32::TieRegistry::KEY_READ()|$KEY_WOW64_64KEY,Delimiter=>"/"} );

    my $softwares=
        $machKey32bit->{"SOFTWARE/Microsoft/Windows/CurrentVersion/Uninstall"};

    processSoftwares({ inventory => $inventory, softwares => $softwares, is64bit => 0});


    $softwares=
        $machKey64bit->{"SOFTWARE/Microsoft/Windows/CurrentVersion/Uninstall"};
    processSoftwares({ inventory => $inventory, softwares => $softwares, is64bit => 1});
    }


}
1;
