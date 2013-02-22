package FusionInventory::Agent::Task::Inventory::Input::Linux::Rudder;

use strict;
use warnings;

use FusionInventory::Agent::Tools;
use FusionInventory::Agent::Tools::Unix;

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
    my $Uuid = getFirstLine(
        logger => $logger, file => '/opt/rudder/etc/uuid.hive'
    );
    # get all agents running on that machine
    my @agents = _manageAgent(
        logger => $logger, command => 'ls /var/rudder'
    );
    # get machine hostname
    my $hostname = getFirstLine(
        logger => $logger, command => 'hostname --fqd'
    );
    my $rudder = {
        HOSTNAME => $hostname,
        UUID => $Uuid,
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

    # each line could be a new agent
    while(my $name = <$handle>){

        chomp $name;
        # verify agent name
        next unless $name =~ /cfengine/;

        # get policy server hostname
        my $serverHostname = getFirstLine (
            logger => $logger,
            file => "/var/rudder/$name/policy_server.dat"
        );
        chomp $serverHostname;

        # get policy server uuid
        my $serverUuid = getFirstLine (
            logger => $logger,
            file => '/var/rudder/tmp/uuid.txt'
        );
        chomp $serverUuid;

        # get CFengine public key
        my $cfengineKey = getAllLines(
            file => "/var/rudder/$name/ppkeys/localhost.pub"
        );

        # get owner name
        my $owner = getFirstLine (
            logger => $logger,
            command => 'whoami'
        );

        # build agent from datas
        my $agent = {
            AGENT_NAME             => $name,
            POLICY_SERVER_HOSTNAME => $serverHostname,
            CFENGINE_KEY           => $cfengineKey,
            OWNER                  => $owner,
            POLICY_SERVER_UUID     => $serverUuid,
        };

        push @agents, $agent;

    }

    close $handle;
    return @agents;
}

1;
