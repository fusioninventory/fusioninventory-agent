package FusionInventory::Logger;

use strict;
use warnings;

# TODO use Log::Log4perl instead.
use Carp;
use Config;
use English qw(-no_match_vars);
use UNIVERSAL::require;

BEGIN {
    # threads and threads::shared must be loaded before
    # $lock is initialized
    if ($Config{usethreads}) {
        eval {
            require threads;
            require threads::shared;
        };
        if ($EVAL_ERROR) {
            print "[error]Failed to use threads!\n"; 
        }
    }
}

my $lock :shared;

sub new {
    my ($class, $params) = @_;

    my $self = {
        config  => $params->{config},
        backend => [],
    };
    bless $self, $class;

    my @backends = $self->{config}->{logger} ?
        split /,/, $self->{config}->{logger} : 'Stderr';
    my @backends_ok;

    foreach my $backend (@backends) {
        my $package = "FusionInventory::LoggerBackend::$backend";
        $package->require();
        if ($EVAL_ERROR) {
            print STDERR
                "Failed to load Logger backend $backend: ($EVAL_ERROR)\n";
            next;
        }

        push
            @{$self->{backend}},
            $package->new({config => $self->{config}});
        push @backends_ok, $backend;
    }

    $self->debug($FusionInventory::Agent::STRING_VERSION);
    $self->debug("Log system initialised (@backends_ok)");

    return $self;
}

sub log {
    my ($self, $args) = @_;

    # levels: info, debug, warn, fault
    my $level = $args->{level} || 'info';
    my $message = $args->{message};

    return if $level eq 'debug' && !$self->{config}->{debug};

    foreach (@{$self->{backend}}) {
        $_->addMsg ({
            level => $level,
            message => $message
        });
    }
    confess if $level eq 'fault'; # Die with a backtace 
}

sub debug {
    my ($self, $msg) = @_;

    lock($lock);
    $self->log({ level => 'debug', message => $msg});
}

sub info {
    my ($self, $msg) = @_;

    lock($lock);
    $self->log({ level => 'info', message => $msg});
}

sub error {
    my ($self, $msg) = @_;

    lock($lock);
    $self->log({ level => 'error', message => $msg});
}

sub fault {
    my ($self, $msg) = @_;

    lock($lock);
    $self->log({ level => 'fault', message => $msg});
}

sub user {
    my ($self, $msg) = @_;

    lock($lock);
    $self->log({ level => 'user', message => $msg});
}

1;
