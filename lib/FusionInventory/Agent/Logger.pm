package FusionInventory::Agent::Logger;

use strict;
use warnings;
use base qw/Exporter/;

use constant {
    LOG_DEBUG2 => 5,
    LOG_DEBUG  => 4,
    LOG_INFO   => 3,
    LOG_ERROR  => 2,
    LOG_FAULT  => 1,
    LOG_NONE   => 0,
};

use English qw(-no_match_vars);

use FusionInventory::Agent::Tools;

our @EXPORT = qw/LOG_DEBUG2 LOG_DEBUG LOG_INFO LOG_ERROR LOG_FAULT LOG_NONE/;

sub new {
    my ($class, %params) = @_;

    my $self = {
        verbosity => defined $params{verbosity} ? $params{verbosity} : LOG_INFO,
    };
    bless $self, $class;

    my %backends;
    foreach my $type (
        $params{backends} ? @{$params{backends}} : 'Stderr'
    ) {
        next if $backends{$type};

        my $backend;
        eval {
            $backend = getInstance(
                class => 'FusionInventory::Agent::Logger::' . ucfirst($type),
                params => \%params
            );
        };
        if ($EVAL_ERROR) {
            warn "Unable to load logger backend $type: $EVAL_ERROR\n";
            next;
        }
        $backends{$type} = 1;

        $self->debug("Logger backend $type initialised");
        push @{$self->{backends}}, $backend;
    }

    $self->debug($FusionInventory::Agent::VERSION_STRING);

    return $self;
}

sub _log {
    my ($self, %params) = @_;

    # levels: debug2, debug, info, error, fault
    my $level = $params{level} || 'info';
    my $message = $params{message};

    return unless $message;

    chomp($message);

    foreach my $backend (@{$self->{backends}}) {
        $backend->addMessage (
            level => $level,
            message => $message
        );
    }
}

sub debug2 {
    my ($self, $message) = @_;

    return unless $self->{verbosity} >= LOG_DEBUG2;
    $self->_log(level => 'debug2', message => $message);
}

sub debug {
    my ($self, $message) = @_;

    return unless $self->{verbosity} >= LOG_DEBUG;
    $self->_log(level => 'debug', message => $message);
}

sub debug_result {
    my ($self, $message, $result) = @_;

    return unless $self->{verbosity} >= LOG_DEBUG;
    $self->_log(
        level   => 'debug',
        message => sprintf(
            '%s: %s', $message, $result ? 'success' : 'no result'
        )
    );
}

sub debug_absence {
    my ($self, $message) = @_;

    return unless $self->{verbosity} >= LOG_DEBUG;
    $self->_log(
        level   => 'debug',
        message => sprintf(
            '%s not available', $message
        )
    );
}

sub info {
    my ($self, $message) = @_;

    return unless $self->{verbosity} >= LOG_INFO;
    $self->_log(level => 'info', message => $message);
}

sub error {
    my ($self, $message) = @_;

    return unless $self->{verbosity} >= LOG_ERROR;
    $self->_log(level => 'error', message => $message);
}

sub fault {
    my ($self, $message) = @_;

    return unless $self->{verbosity} >= LOG_FAULT;
    $self->_log(level => 'fault', message => $message);
}

1;
__END__

=head1 NAME

FusionInventory::Agent::Logger - Fusion Inventory logger

=head1 DESCRIPTION

This is the logger object.

=head1 METHODS

=head2 new(%params)

The constructor. The following parameters are allowed, as keys of the %params
hash:

=over

=item I<config>

the agent configuration object, to be passed to backends

=item I<backends>

a list of backends to use (default: Stderr)

=item I<verbosity>

the verbosity level (default: LOG_INFO)

=back

=head2 debug2($message)

Add a log message with debug2 level.

=head2 debug($message)

Add a log message with debug level.

=head2 info($message)

Add a log message with info level.

=head2 error($message)

Add a log message with error level.

=head2 fault($message)

Add a log message with fault level.
