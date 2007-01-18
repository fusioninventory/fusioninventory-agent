package Ocsinventory::Agent::Backend::OS::Generic::Xorg;

use strict;

my @location = ("/etc/X11/xorg.conf", 
  "/etc/X11/XF86Config-4",
  "/etc/XF86Config",
  "/etc/X11/XF86Config",
  "/etc/Xconfig",
  "/usr/X11/lib/X11/XF86Config");

sub check {
  foreach(@location) {
    return 1 if -f;
  }
  0;
}

sub run {

  my $params = shift;
  my $inventory = $params->{inventory};
  my $logger = $params->{logger};

  my $caption;
  my $manufacturer;
  my $description;

# Looking for XFConfig
  my @monitor;
  my $cfgfound;
  foreach my $xconfig (@location) {
    next unless -f $xconfig;
    my ($n, $flag, @values);

    if (!open XCONFIG, $xconfig) {

      $logger->info("Failed to open $xconfig: $?");

      next;
    }

    $cfgfound++;


    my $in;
#If xfree config file found
    foreach (<XCONFIG>){
      if(/section\s+("monitor")/i) {
	$in = 1;
      } elsif($in && /endsection/i) {
	# end of the section, i write the data
	$inventory->addMonitors ({

	    CAPTION => $caption,
	    MANUFACTURER => $manufacturer,
	    DESCRIPTION => $description,

	  });
	$in = undef;
      } elsif($in) {
	$caption = $1 if /identifier\s+"(.+)"/i;
	$manufacturer = $1 if /vendorname\s+"(.+)"/i;
	$description = $1 if /modelname\s+"(.+)"/i;
      }
    }
    close XCONFIG or warn;
  }

  if ($cfgfound > 1) {
    $logger->info('Ocsinventory::Agent::Backend::Video::Xorg have found more than one X config file. Fix this by removing the unused file(s).');

  }
}
1;
