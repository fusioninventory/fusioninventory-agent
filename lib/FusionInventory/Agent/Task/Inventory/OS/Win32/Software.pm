package FusionInventory::Agent::Task::Inventory::OS::Win32::Software;


# http://techtasks.com/code/viewbookcode/1417


use Win32::TieRegistry ( Delimiter=>"/", ArrayValues=>0 );

sub isInventoryEnabled {1}

sub hexToDec {
    my $val = shift;

    return $val unless /^0x/; 

    my $tmp = $val;

    $tmp =~ s/^0x0*//i;
    return hex($tmp); 
}

sub doInventory {
    my $params = shift;
    my $inventory = $params->{inventory};

    my $softwares=
        $Registry->{"HKEY_LOCAL_MACHINE/SOFTWARE/Microsoft/Windows/CurrentVersion/Uninstall"};

    foreach my $name ( keys %$softwares ) {
        my $data = $softwares->{$name};
        next unless keys %$data;


        my $name = $data->{'/DisplayName'};
        my $comments = $data->{'/Comments'};
        my $version = $data->{'/DisplayVersion'};
        my $publisher = $data->{'/Publisher'};
        my $urlInfoAbout = $data->{'/URLInfoAbout'};
        my $helpLink = $data->{'/HelpLink'};
        my $uninstallString = $data->{'/UninstallString'};
        my $noRemove = ($data->{'/NoRemove'} =~ /1/)?1:0;
        my $releaseType = $data->{'/ReleaseType'};
        my $installDate = $data->{'/InstallDate'};
        my $versionMinor = hexToDec($data->{'/VersionMinor'});
        my $versionMajor = hexToDec($data->{'/VersionMajor'});

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
        });
    }


}
1;
