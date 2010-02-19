package FusionInventory::Agent::Task::Inventory::OS::Win32::Software;


# http://techtasks.com/code/viewbookcode/1417

use strict;

# No check here. If Win32::OLE and Win32::OLE::Variant not available, the module
# will fail to load.
use Win32::OLE;
use Win32::OLE::Variant;

my $Registry;
use Win32::TieRegistry ( Delimiter=>"/", ArrayValues=>0 );

sub check {1}

sub run {
    my $params = shift;
    my $inventory = $params->{inventory};



    my $softwares=
        $Registry->{"HKEY_LOCAL_MACHINE/SOFTWARE/Microsoft/Windows/CurrentVersion/Uninstall"};

    foreach my $name ( keys %$softwares ) {
        my $data = $softwares->{$name};

        my $name = $name;
        my $comments = $data->{'/Comments'};
        my $version = $data->{'/DisplayVersion'};
        my $publisher = $data->{'/Publisher'};
        my $urlInfoAbout = $data->{'/URLInfoAbout'};
        my $helpLink = $data->{'/HelpLink'};
        my $uninstallString = $data->{'/UninstallString'};
        my $noRemove = ($data->{'/NoRemove'} =~ /1/)?1:0;
        my $releaseType = $data->{'/ReleaseType'};
        my $installDate = $data->{'/InstallDate'};

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
            VERSION => $version
        });
    }


}
1;
