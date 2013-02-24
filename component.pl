#!/usr/bin/perl -w

use strict;
use warnings;

use File::Find;
use File::Basename;
my $struct;

my %vars = ( "directory" => "", "feature" => "" );

sub getUUID {
    my $string = "";
    for (1..32) {
        $string .= rand(100) % 10;
    }
       
        return $string;

}

sub scanDir {
    my ($dir) = @_;

    my @dirs;
    my @files;


    my $id = $dir;
    $id =~ s/[^a-zA-Z0-9]//g;

    opendir(my $dh, $dir) or die;
    $vars{"directory"} .= "<Directory Id=\"".$id."Folder\" Name=\"".basename($dir)."\">\n";
    while (my $entry = readdir($dh)) {
        next if $entry =~ /^\./;
        if (-d $dir.'/'.$entry) {
            push (@dirs, $entry);
        } else {
            push (@files, $entry);
        }
    }

    if (@files) {
        $vars{"directory"} .= "<Component Id=\"".$id."Component\" Guid=\"".getUUID()."\">\n";

        $vars{"feature"} .= "<ComponentRef Id=\"".$id."Component\"/>\n";
    }

    foreach my $file (@files) {

        my $id = $dir.'/'.$file;
        $id =~ s/[^a-zA-Z0-9]//g;


        $vars{"directory"} .= "<File Id=\"$id\" Source=\"$dir/$file\"  />\n";
    }


    if (@files) {
        $vars{"directory"} .= "</Component>\n";
    }

    closedir($dh);
    foreach my $subdir (@dirs) {
        scanDir($dir.'/'.$subdir);
    }
    $vars{"directory"} .= "</Directory>\n";
}

scanDir('lib');
scanDir('bin');
scanDir('share');

foreach (<DATA>) {
        s/@\@directory@@/$vars{"directory"}/;
        s/@\@feature@@/$vars{"feature"}/;

        print;
}

__DATA__
<?xml version="1.0"?>
<!-- based on WiX installer example by Mark Seuffert -->
<?define ProductVersion = "2.3.0"?>
<?define ProductUpgradeCode = "12332167-1234-1234-1234-111111111111"?>
<Wix xmlns="http://schemas.microsoft.com/wix/2006/wi">
   <Product Id="*" UpgradeCode="$(var.ProductUpgradeCode)" Name="FusionInventory Agent" Version="$(var.ProductVersion)" Manufacturer="FusionInventory contributors" Language="1033">
      <Package InstallerVersion="200" Compressed="yes" Comments="Windows Installer Package"/>
      <Media Id="1" Cabinet="product.cab" EmbedCab="yes"/>
      <Icon Id="ProductIcon" SourceFile="share/html/favicon.ico"/>
      <Property Id="ARPPRODUCTICON" Value="ProductIcon"/>
      <Property Id="ARPHELPLINK" Value="http://www.FusionInventory.org/documentation/"/>
      <Property Id="ARPURLINFOABOUT" Value="http://www.FusionInventory.org"/>
      <Property Id="ARPNOREPAIR" Value="1"/>
      <Property Id="ARPNOMODIFY" Value="1"/>
      <Upgrade Id="$(var.ProductUpgradeCode)">
         <UpgradeVersion Minimum="$(var.ProductVersion)" OnlyDetect="yes" Property="NEWERVERSIONDETECTED"/>
         <UpgradeVersion Minimum="0.0.0" Maximum="$(var.ProductVersion)" IncludeMinimum="yes" IncludeMaximum="no" Property="OLDERVERSIONBEINGUPGRADED"/>	  
      </Upgrade>
      <Condition Message="A newer version of this software is already installed.">NOT NEWERVERSIONDETECTED</Condition>

      <Directory Id="TARGETDIR" Name="SourceDir">
         <Directory Id="ProgramFilesFolder">
            <Directory Id="INSTALLDIR" Name="FusionInventory-Agent">

@@directory@@

            </Directory>
         </Directory>

         <Directory Id="ProgramMenuFolder">
            <Directory Id="ProgramMenuSubfolder" Name="Example">
               <Component Id="ApplicationShortcuts" Guid="12332167-1234-1234-1234-333333333333">
                  <Shortcut Id="ApplicationShortcut1" Name="Example Shortcut Name" Description="Example Product Name" Target="[INSTALLDIR]example.exe" WorkingDirectory="INSTALLDIR"/>
                  <RegistryValue Root="HKCU" Key="Software\FusionInventory-Agent" Name="installed" Type="integer" Value="1" KeyPath="yes"/>
                  <RemoveFolder Id="ProgramMenuSubfolder" On="uninstall"/>
               </Component>
            </Directory>
         </Directory>
      </Directory>

      <InstallExecuteSequence>
         <RemoveExistingProducts After="InstallValidate"/>
      </InstallExecuteSequence>

      <Feature Id="DefaultFeature" Level="1">
@@feature@@
         <ComponentRef Id="ApplicationShortcuts"/>		 
      </Feature>
   </Product>
</Wix>

