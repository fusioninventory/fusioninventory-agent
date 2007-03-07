package Ocsinventory::Agent::Backend::OS::BSD::Archs::I386;
# for i386 in case dmidecode is not available
use strict;

sub check{
    my $arch;
    chomp($arch=`sysctl -n hw.machine`);
    return if ($arch ne "i386");
    # dmidecode must not be present
    `which dmidecode 2>&1`;
    return if ($? >> 8)==0;
    1;
}

sub run {
  my $params = shift;
  my $inventory = $params->{inventory};

  my( $SystemSerial , $SystemModel, $SystemManufacturer, $BiosManufacturer,
    $BiosVersion, $BiosDate);
  my ( $processort , $processorn , $processors );

  # XXX number of procs with sysctl (hw.ncpu)
  chomp($processorn=`sysctl -n hw.ncpu`);
  # XXX proc type with sysctl (hw.model)
  chomp($processort=`sysctl -n hw.model`);
  # XXX quick and dirty _attempt_ to get proc speed through dmesg
  for(`dmesg`){
      my $tmp;
      if (/^cpu\S*\s.*\D[\s|\(]([\d|\.]+)[\s|-]mhz/i) { # XXX unsure
	  $tmp = $1;
	  $tmp =~ s/\..*//;
	  $processors=$tmp;
	  last
	  }
  }

  $inventory->setHardware({

      PROCESSORT => $processort,
      PROCESSORN => $processorn,
      PROCESSORS => $processors

    });


}

1;
