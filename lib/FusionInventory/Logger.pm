package FusionInventory::Logger;

use strict;
use warnings;

# TODO use Log::Log4perl instead.
use Carp;
use English qw(-no_match_vars);
use UNIVERSAL::require;

use Config;

BEGIN {
    # threads and threads::shared must be load before
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


    my $self = {};
    bless $self, $class;
    $self->{backend} = [];
    $self->{config} = $params->{config};

    $self->{debug} = $self->{config}->{debug}?1:0;
    my @logger;

    if (exists ($self->{config}->{logger})) {
        @logger = split /,/, $self->{config}->{logger};
    } else {
        # if no 'logger' parameter exist I use Stderr as default backend
        push @logger, 'Stderr';
    }

    my @loadedMbackends;
    foreach (@logger) {
        my $backend = "FusionInventory::LoggerBackend::".$_;
        $backend->require();
        if ($EVAL_ERROR) {
            print STDERR "Failed to load Logger backend: $backend ($EVAL_ERROR)\n";
            next;
        } else {
            push @loadedMbackends, $_;
        }

        my $obj = $backend->new({
                config => $self->{config},
            });
        push @{$self->{backend}}, $obj if $obj;
    }

    my $version = "FusionInventory unified agent for UNIX, Linux, Windows and MacOSX ";
    $version .= exists ($self->{config}->{VERSION})?$self->{config}->{VERSION}:'';
    $self->debug($version);
    $self->debug("Log system initialised (@loadedMbackends)");

    return $self;
}

sub log {
    my ($self, $args) = @_;

    # levels: info, debug, warn, fault
    my $level = $args->{level};
    my $message = $args->{message};

    return if ($level =~ /^debug$/ && !($self->{debug}));

    chomp($message);
    $level = 'info' unless $level;

    foreach (@{$self->{backend}}) {
        $_->addMsg ({
            level => $level,
            message => $message
        });
    }
    confess if $level =~ /^fault$/; # Die with a backtace 
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
