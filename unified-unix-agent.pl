#!/usr/bin/perl

use strict;
use warnings;

use Data::Dumper; #XXX DEBUG

use Getopt::Long;

use Ocsinventory::Logger;
use Ocsinventory::XML::Inventory;
use Ocsinventory::XML::Prolog;

use Ocsinventory::Agent::Network;
use Ocsinventory::Agent::Backend;
use Ocsinventory::Agent::Config;
use Ocsinventory::Agent::AccountInfo;

# default settings;
my $params = { 
  'debug'     =>  1,
  'force'     =>  0,
  'help'      =>  0,
  'info'      =>  1,
  'local'     =>  '',
  'logger'    =>  'File,Stderr',
  'logger-file-path' => '/tmp/ocsuc.log',
  'password'  =>  '',
  'realm'     =>  '',
  'tag'       =>  '',
  'server'    =>  'ocsinventory-ng',
  'user'      =>  '',
#  'xml'       =>  0,

  # Other values that can't be changed with the
  # CLI parameters
  'version'   => '0.0.1',
  'deviceid'  => '',
  'etcdir'    =>  '/etc/ocsinventory-client',
  'vardir'    =>  '/var/lib/ocsinventory-client',
};

$ENV{LANG} = 'C'; # Turn off localised output for commands

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
  print STDERR "\t-t --tag=TAG        use TAG as tag ($params->{tag}). Will
  be ignored by server if a value already exists.\n";
  print STDERR "\t-u --user=USER      user for server auth\n";
#  print STDERR "\t-x --xml            write output in a xml file ($params->{xml})\n";
#  print STDERR "\t--nosoft           do not return installed software list\n";

  exit 1;
}

#####################################
################ MAIN ###############
#####################################


############################
#### CLI parameters ########
############################
help() if (!GetOptions(%options) || $params->{help});


############################
#### Objects initilisation 
############################

  # The agent can contact different servers. Every server config are
  # stored in a specific file:
  if ((!defined($params->{local}) && $params->{local})) {

    $params->{conffile} = $params->{vardir}."/ocsinv.conf";
    $params->{accountinfofile} = $params->{vardir}."/ocsinv.adm";
    $params->{laste_statefile} = $params->{vardir}."/laste_state";

  } else {

    $params->{conffile} = $params->{vardir}."/$params->{server}_ocsinv.conf";
    $params->{accountinfofile} = $params->{vardir}."/$params->{server}_ocsinv.adm";
    $params->{laste_statefile} = $params->{vardir}."/$params->{server}_laste_state";

  }


my $logger = new Ocsinventory::Logger ({

    params => $params

  });

# load CFG files
my $config = new Ocsinventory::Agent::Config({
    logger => $logger,
    params => $params,
  });

my $srv = $config->get('OCSFSERVER');
$params->{server} = $srv if $srv;
$params->{deviceid}   = $config->get('DEVICEID');

# Should I create a new deviceID?
chomp(my $tmp = `uname -n| cut -d . -f 1`);
if ((!$params->{deviceid}) || $params->{deviceid} !~ /$tmp-(?:\d{4})(?:-\d{2}){5}/) {
  my ($YEAR, $MONTH , $DAY, $HOUR, $MIN, $SEC) = (localtime
    (time))[5,4,3,2,1,0];
  $params->{old_deviceid} = $params->{deviceid};
  $params->{deviceid} =sprintf "%s-%02d-%02d-%02d-%02d-%02d-%02d",
  $tmp, ($YEAR+1900), ($MONTH+1), $DAY, $HOUR, $MIN, $SEC;
}

my $accountinfo = new Ocsinventory::Agent::AccountInfo({

    logger => $logger,
    params => $params,

  });

if ($params->{tag}) {
  if ($accountinfo->get("TAG")) {
    $logger->log({
	level => 'debug',
	message => "A TAG seems to already exist in the server for this
	machine. If so, the -t paramter is usless. Please change the TAG
	directly on the
	server."
      });
  }
}

my $inventory = new Ocsinventory::XML::Inventory ({

    accountinfo => $accountinfo,
    logger => $logger,
    params => $params,

  });

my $backend = new Ocsinventory::Agent::Backend ({

    accountinfo => $accountinfo,
    config => $config,
    logger => $logger,
    params => $params,

  });

# Feed the inventory with its modules
$backend->feedInventory ({inventory => $inventory});

if ($params->{local}) {
  $inventory->writeXML();
  # TODO write XML inventory 
} else { # I've to contact the server
  my $net = new Ocsinventory::Agent::Network ({

      logger => $logger,
      params => $params,
      respHandlers => {
	OPTION => sub {print "TODO: OPTION data retruned must be used\n"},
	PROLOG_FREQ => sub {$config->set("PROLOG_FREQ", $_[0])},
	ACCOUNTINFO => sub {$accountinfo->reSetAll($_[0])},
      }

    });

  my $dontSendIventory;
  if (!$params->{force}) {
    my $prolog = new Ocsinventory::XML::Prolog({

	logger => $logger,
	params => $params,

      });

    my $ret = $net->send({message => $prolog});
    $dontSendIventory = 1 if ( $ret !~ /SEND/ );
  }

  if (!$dontSendIventory) {

    my $ret = $net->send({message => $inventory});

    $logger->log({

	level => 'debug',
	message => "Server returned: $ret"

      }); 


  } else {

    $logger->log({

	level => 'info',
	message => 'No need to send the inventory'

      }); 
  }
}

