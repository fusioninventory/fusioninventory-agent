package FusionInventory::Agent::Task::Deploy;

use strict;
use warnings;

use XML::Simple;
use File::Copy;
use File::Glob;
use LWP::Simple qw ($ua getstore is_success);
use File::Path;
use File::stat;
use Digest::MD5 qw(md5);

use Data::Dumper;

use Archive::Extract;
use File::Copy::Recursive qw(dirmove);
use Time::HiRes;

use Cwd;

sub new {
    my ( undef, $params ) = @_;

    my $self = {};

    $self->{inventory}     = $params->{inventory};
    my $logger = $self->{logger} = $params->{logger};
    $self->{network}    = $params->{network};

    if ( !exists( $self->{config}->{vardir} ) ) {
        $logger->fault('No vardir in $config');
    }

    bless $self;

}

sub doInventory {

    my $self      = shift;
    my $inventory = $self->{inventory};
    my $storage   = $self->{storage};

    # Just in case the stack is not empty
    $self->pushErrorStack();

    use Data::Dumper;
    print Dumper($storage);

    # Record in the Inventory the commands already recieved by the agent
    foreach ( keys %{ $storage->{byId} } ) {
        $inventory->addSoftwareDeploymentPackage($_);
    }

}

1;

