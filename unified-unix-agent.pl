#!/usr/bin/perl
# TODO Create ETIME (execution time) correcly
use strict;
use warnings;
#use diagnostics;
use Data::Dumper; #XXX DEBUG

use Getopt::Long;

use Ocsinventory::XML::Inventory;
use Ocsinventory::XML::Prolog;

use Ocsinventory::Agent::Network;
use Ocsinventory::Agent::Backend;
use Ocsinventory::Agent::Config;
use Ocsinventory::Agent::AccountInfo;
my $h = {};
my $inventory;
my $config;
my $accountinfo;
# default settings;
my $params = { 
  'debug'     =>  1,
  'force'     =>  0,
  'help'      =>  0,
  'info'      =>  1,
  'local'     =>  '',
  'password'  =>  '',
  'realm'     =>  '',
  'tag'       =>  'DEBUG',
  'server'    =>  'ocsinventory-ng',
  'user'      =>  '',
#  'xml'       =>  0,

  # Other values that can't be changed with the
  # CLI parameters (yet?)
  'version'   => '0.0.1',
  'deviceid'  => '',
  'etcdir'    =>  '/etc/ocsinventory-client/',
};

$ENV{LANG} = 'C'; # Turn off localised output for command

my %options = (
  "d|debug"         =>   \$params->{debug},
  "f|force"         =>   \$params->{force},
  "h|help"          =>   \$params->{help},
  "i|info"          =>   \$params->{info},
  "l|local=s"         =>   \$params->{local},
  "p|password=s"    =>   \$params->{password},
  "r|realm=s"       =>   \$params->{realm},
  "t|tag=s"         =>   \$params->{tag},
  "s|server=s"      =>   \$params->{server},
  "u|user"          =>   \$params->{user},
#  "x|xml"           =>   \$params{xml},
#"nosoft"
);

##########################################
##########################################
##########################################
##########################################
sub help {
  my $error = shift;
  if ($error) {
    chomp $error;
    print "ERROR: $error\n\n";
  }

  print STDERR "Usage:\n";
  print STDERR "\t-d --debug          debug mode ($params->{debug})\n";
  print STDERR "\t-f --force          always send data to server (Don't ask
  before) ($params->{force})\n";
  print STDERR "\t-i --info           verbose mode ($params->{info})\n";
  print STDERR "\t-l --local=DIR      do not contact server but write
  inventory in DIR directory in XML ($params->{local})\n";
  print STDERR "\t-p --password=PWD   password for server auth\n";
  print STDERR "\t-r --realm=REALM    realm for server auth\n";
  print STDERR "\t-s --server=SERVER  use the specific server SERVER
  ($params->{server})\n";
  print STDERR "\t-t --tag=TAG        use TAG as tag ($params->{tag})\n";
  print STDERR "\t-u --user=USER      user for server auth\n";
#  print STDERR "\t-x --xml            write output in a xml file ($params->{xml})\n";
#  print STDERR "\t--nosoft           do not return installed software list\n";

  exit 1;
}



#####################################
################ MAIN ###############
#####################################
# load CFG files
$config = new Ocsinventory::Agent::Config({
    params => $params,
  });
$accountinfo = new Ocsinventory::Agent::AccountInfo({
    params => $params,
  });

my $srv = $config->get('OCSFSERVER');
$params->{server} = $srv if $srv;
$params->{deviceid}   = $config->get('DEVICEID');

my $deviceID = $config->get("DEVICEID");

# Should I create a new deviceID?
chomp(my $tmp = `uname -n| cut -d . -f 1`);
if ($deviceID !~ /$tmp-(?:\d{4})(?:-\d{2}){5}/) {
  my ($YEAR, $MONTH , $DAY, $HOUR, $MIN, $SEC) = (localtime
    (time))[5,4,3,2,1,0];
  $params->{old_deviceid} = $deviceID;
  $params->{deviceid} =sprintf "%s-%02d-%02d-%02d-%02d-%02d-%02d",
  $tmp, ($YEAR+1900), ($MONTH+1), $DAY, $HOUR, $MIN, $SEC;
}

############################
#### CLI parameters ########
############################
GetOptions(%options);
&help if $params->{help}; 

my $inventory = new Ocsinventory::XML::Inventory({
    params => $params,
  });

my $backend = new Ocsinventory::Agent::Backend ({
    accountinfo => $accountinfo,
    config => $config,
    params => $params,
  });

# Feed the inventory with its modules
$backend->feedInventory ({inventory => $inventory});

if ($params->{local}) {
  $inventory->writeXML();
  # TODO write XML inventory 
} else { # I've to contact the server
  my $net = new Ocsinventory::Agent::Network({params => $params});
  my $prolog = new Ocsinventory::XML::Prolog({params => $params});

#  $cnx->send($prolog);
#  if ($cnx->response() !~ /STOP/) {}

  if ($net->send({message => $prolog})) {
    $inventory = createInventory();
    $net->send({message => $inventory});    
  }
}

#$accountinfo->write();
$inventory->dump();
