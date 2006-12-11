package Ocsinventory::Agent::Backend::OS::POSIX::Xorg;

my @location = ("/etc/X11/xorg.conf", 
  "/etc/X11/XF86Config-4",
  "/etc/XF86Config",
  "/etc/X11/XF86Config",
  "/etc/Xconfig",
  "/usr/X11/lib/X11/XF86Config");

sub check {
  foreach(@location) {
    return if -f;
  }
  0
}

sub run {
  my $h = shift;

# Looking for XFConfig
  my @monitor;
  my $cfgfound;
  foreach my $xconfig (@location) {
    next unless -f $xconfig;
    my ($n, $flag, @values);

    if (!open XCONFIG, $xconfig) {
      warn;
      next;
    }
    $cfgfound++;
    my $in;
#If xfree config file found
    foreach (<XCONFIG>){
      if(/section\s+("monitor")/i){
	$in = 1;
	push @monitor, {
	  CAPTION => '',
	  MANUFACTURER => '',
	  DESCRIPTION => '',
	};
      }
      $in = undef if($in && /endsection/i);

      if($in) {
	$monitor[@monitor]->{CAPTION} = $1 if /identifier\s+"(.+)"/i;
	$monitor[@monitor]->{MANUFACTURER} = $1 if /vendorname\s+"(.+)"/i;
	$monitor[@monitor]->{DESCRIPTION} = $1 if /modelname\s+"(.+)"/i;
      }
    }
  }

  foreach (@monitor) {
    $inventory->addMonitors ({
	CAPTION => $_->{CAPTION},
	MANUFACTURER => $_->{MANUFACTURER},
	DESCRIPTION => $_->{DESCRIPTION},
      });

  }
  if ($cfgfound > 1) {
    print "Ocsinventory::Agent::Backend::Video::Xorg have found more than one X config file:\n";
    print "->".$_."\n" foreach(@done);
    print "Fix this by removing the unused file(s).";
  }
}
1;
