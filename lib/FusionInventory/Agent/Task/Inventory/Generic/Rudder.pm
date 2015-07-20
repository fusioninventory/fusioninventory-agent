package FusionInventory::Agent::Task::Inventory::Generic::Rudder;

use strict;
use warnings;

use English qw(-no_match_vars);

use FusionInventory::Agent::Tools;

sub isEnabled {
    return -r '/opt/rudder/etc/uuid.hive';
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
    my $command = $OSNAME eq 'linux' ? 'hostname --fqd' : 'hostname';
    my $hostname = getFirstLine(
        logger => $logger, command => $command
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

        my $server_hostname_file = "/var/rudder/$name/policy_server.dat";
        my $uuid_file            = "/var/rudder/$name/rudder-server-uuid.txt";
        my $cfengine_key_file    = "/var/rudder/$name/ppkeys/localhost.pub";

        # get policy server hostname
        my $serverHostname = getFirstLine (
            logger => $logger,
            file => $server_hostname_file
        );
        chomp $serverHostname;

        # get policy server uuid
        #
        # the default file is no longer /var/rudder/tmp/uuid.txt since the
        # change in http://www.rudder-project.org/redmine/issues/2443.
        # we gracefully fallback to the old default if we can not find the
        # new file.
        my $serverUuid = getFirstLine (
            logger => $logger,
            file => ( -e "$uuid_file" ) ? $uuid_file : "/var/rudder/tmp/uuid.txt"
        );
        chomp $serverUuid;

        # get CFengine public key
        my $cfengineKey = getAllLines(
            file => $cfengine_key_file
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
