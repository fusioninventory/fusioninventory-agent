package FusionInventory::Agent::Task::Inventory::Input::Generic::Rudder;

use strict;
use warnings;

use FusionInventory::Agent::Tools;

sub isEnabled {
    return
	canRead("/opt/rudder/etc/uuid.hive");
}

sub doInventory {
    my (%params) = @_;

    my $inventory = $params{inventory};
    my $logger    = $params{logger};

    my $UUID = getFileHandle(
	logger => $logger, file => '/opt/rudder/etc/uuid.hive'
	);

    my @agents = _manageAgent(
	logger => $logger, command => 'ls /var/rudder | grep cfengine'
	);
 
   my $hostname =getFileHandle(
	logger => $logger, command => 'hostname --fqd'
	);
    my $rudder = {
	HOSTNAME => <$hostname>,
	UUID => <$UUID>,
	AGENT => \@agents,
    };

    $inventory->addEntry(
	section => 'RUDDER', entry => $rudder
	);
}

sub _manageAgent {

    my $handle = getFileHandle(@_);
    my %params = @_;
    my $logger = $params{logger};

    my @agents;


    while(my $line = <$handle>){
        chomp $line;

        my $name = $line;

        my $servHostname = getFileHandle
            (logger => $logger,
             file => "/var/rudder/$line/policy_server.dat"
            );

        my $cfengineKey = getFileHandle
             (logger => $logger,
              file => "/var/rudder/$line/ppkeys/localhost.pub"
             );

        my $host =  <$servHostname>;
        chomp $host;

        my $policy_file = getFileHandle(
            logger => $logger, file => '/var/rudder/tmp/uuid.txt'
        );
        my $policy = <$policy_file>;
        chomp $policy;

        my $key;
        while (my $tmpkey = <$cfengineKey>){
            $key = $key.$tmpkey;
        }
        chomp $key;


        my $ownerfile =  getFileHandle(
         logger => $logger, command => "ps aux | grep $name"
        );

        my $owner = (split " ", <$ownerfile>)[0];

        my $agent = {
            AGENT_NAME             => $name,
            POLICY_SERVER_HOSTNAME => $host,
            CFENGINE_KEY           => $key,
            OWNER                  => $owner,
            POLICY_SERVER_UUID     => $policy,
        };

        push @agents, $agent;

    }
    close $handle;
    return @agents;
}

1;
