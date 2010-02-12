###############################################################################
## OCSINVENTORY-NG 
## Copyleft Pascal DANEK 2005
## Web : http://ocsinventory.sourceforge.net
##
## This code is open source and may be copied and modified as long as the source
## code is always made freely available.
## Please refer to the General Public Licence http://www.gnu.org/ or Licence.txt
################################################################################
package FusionInventory::Agent::Common;
# - BIG FAT WARNING -
# PLEASE, DON'T USE THIS MODULE. IT ONLY USED FOR THE COMPATIBILITY
# WITH THE PREVIOUS PLUGIN MECHANISM AND WILL BE DROPPED IN THE FUTUR

use strict;

require Exporter;

our @ISA = qw /Exporter/;
our @EXPORT = qw//;
our %EXPORT_TAGS = (
	'all' => [ qw /_uncompress _debug _get_path _already_in_array/ ]
);
our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );

use Compress::Zlib;

sub _get_path{
	my $binary = shift;
	my $path;
	
	my @bin_directories 	= qw {	/usr/local/sbin/ /sbin/ /usr/sbin/ /bin/ /usr/bin/ 
				/usr/local/bin/ /etc/ocsinventory-client/};
				
	print "\n=> retrieving $binary...\n" if $::debug;
	for(@bin_directories){
		$path = $_.$binary,last if -x $_.$binary;
	}
	
	#For debbuging purposes
	if($path){
		print "=> $binary is at $path\n\n" if $::debug;
	}else{
		print "$binary not found (Maybe it is not installed ?) - Some functionnalities may lack !!\n\n";
	}
	
	return $path;
}

# A little contribution
sub _already_in_array {
	my $lookfor = shift;
	my @array   = @_;
	foreach (@array){
		if($lookfor eq $_){
			return 1 ;
		}
	}
	return 0;	 
}

#For debugging purposes
sub _debug{
	my $message = shift;
	my $context = shift;
	$message =~ s/^([^#].*)/#  $1/gm;
	my $debug = <<EOT;


[ $context ]####################################
$message
################################################





EOT



print $debug;
}

sub _uncompress{
	my($status, $data, $d);

	# Uncompress request
	($d, $status) = Compress::Zlib::inflateInit();
	($data, $status) = $d->inflate($_[0]);

	return ($data);
}
1;
