package FusionInventory::Agent::Task::Inventory::Input::Generic::Rudder;

use strict;
use warnings;

use FusionInventory::Agent::Tools;

sub isEnabled {

    #If you can read /opt/rudder/etc/uuid.hive then you can do that inventory
    return
	canRead("/opt/rudder/etc/uuid.hive");
}

sub doInventory {
    my (%params) = @_;

    my $inventory = $params{inventory};
    my $logger    = $params{logger};

    # get Rudder UUID
    my $UUID = getFileHandle(
        logger => $logger, file => '/opt/rudder/etc/uuid.hive'
        );
    # get all agents running on that machine
    my @agents = _manageAgent(
        logger => $logger, command => 'ls /var/rudder | grep cfengine'
        );
    # get machine hostname
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

    # each line is a new agent
    while(my $line = <$handle>){
        chomp $line;

        # get agent name
        my $name = $line;
        next unless $name;

        # get policy server hostname
        my $servHostname = getFileHandle (
             logger => $logger,
             file => "/var/rudder/$line/policy_server.dat"
            );
        my $host =  <$servHostname>;
        chomp $host;

        # get policy server uuid
        my $policy_file = getFileHandle (
            logger => $logger,
            file => '/var/rudder/tmp/uuid.txt'
            );
        my $policy = <$policy_file>;
        chomp $policy;

        # get CFengine public key
        my $cfengineKey = getFileHandle (
            logger => $logger,
            file => "/var/rudder/$line/ppkeys/localhost.pub"
            );
        my $key;
        while (my $tmpkey = <$cfengineKey>){
            $key = $key.$tmpkey;
        }
        chomp $key;

        # get owner name
        my $owner_info =  getFileHandle(
         logger => $logger, command => "ps aux | grep $name"
        );
        my $owner = (split " ", <$ownerfile>)[0];

        # build agent from datas
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
