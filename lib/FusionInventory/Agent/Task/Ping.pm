package FusionInventory::Agent::Task::Ping;

use strict;
no strict 'refs';
use warnings;

use FusionInventory::Agent::Config;
use FusionInventory::Logger;
use FusionInventory::Agent::Storage;
use FusionInventory::Agent::XML::Query::SimpleMessage;
use FusionInventory::Agent::XML::Response::Prolog;
use FusionInventory::Agent::Network;

use FusionInventory::Agent::AccountInfo;

sub main {
    my ( undef ) = @_;

    my $self = {};
    bless $self;

    my $storage = new FusionInventory::Agent::Storage({
            target => {
                vardir => $ARGV[0],
            }
        });

    my $data = $storage->restore({ module => "FusionInventory::Agent" });
    $self->{data} = $data;
    my $myData = $self->{myData} = $storage->restore();

    my $config = $self->{config} = $data->{config};
    my $target = $self->{target} = $data->{'target'};
    my $logger = $self->{logger} = new FusionInventory::Logger ({
            config => $self->{config}
        });

    if ($target->{'type'} ne 'server') {
        $logger->debug("No server. Exiting...");
        exit(0);
    }

    my $options = $data->{'prologresp'}->getOptionsInfoByName('PING');
    return unless $options;
    my $option = shift @$options;
    return unless $option;

    $logger->debug("Ping ID:". $option->{ID});


    my $network = $self->{network} = FusionInventory::Agent::Network->new ({

            logger => $logger,
            config => $config,
            target => $target,

        });

    my $message = FusionInventory::Agent::XML::Query::SimpleMessage->new(                                                               
        {
            config => $config,
            logger => $logger,
            target => $target,
            msg    => {
                QUERY => 'PING',
                ID    => $option->{ID},
            },
        }
    );
    $logger->debug("Pong!");
    $network->send( { message => $message } );

}

1;
