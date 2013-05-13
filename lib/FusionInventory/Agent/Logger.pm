package FusionInventory::Agent::Logger;

use strict;
use warnings;

use English qw(-no_match_vars);
use UNIVERSAL::require;

sub new {
    my ($class, %params) = @_;

    my $self = {
        debug => $params{debug} || 0,
    };
    bless $self, $class;

    my %backends;
    foreach (
        $params{backends} ? @{$params{backends}} : 'Stderr'
    ) {
        my $backend = ucfirst($_);
        next if $backends{$backend};
        my $package = "FusionInventory::Agent::Logger::$backend";
        $package->require();
        if ($EVAL_ERROR) {
            print STDERR
                "Failed to load Logger backend $backend: ($EVAL_ERROR)\n";
            next;
        }
        $backends{$backend} = 1;

        $self->debug("Logger backend $backend initialised");
        push
            @{$self->{backends}},
            $package->new(%params);
    }

    $self->debug($FusionInventory::Agent::VERSION_STRING);

    return $self;
}

sub log {
    my ($self, %params) = @_;

    # levels: debug2, debug, info, error, fault
    my $level = $params{level} || 'info';
    my $message = $params{message};

    return unless $message;
    return if $level eq 'debug2' && $self->{debug} < 2;
    return if $level eq 'debug'  && $self->{debug} < 1;

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

    $self->log(level => 'debug2', message => $message);
}

sub debug {
    my ($self, $message) = @_;

    $self->log(level => 'debug', message => $message);
}

sub info {
    my ($self, $message) = @_;

    $self->log(level => 'info', message => $message);
}

sub error {
    my ($self, $message) = @_;

    $self->log(level => 'error', message => $message);
}

sub fault {
    my ($self, $message) = @_;

    $self->log(level => 'fault', message => $message);
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

=item I<debug>

a flag allowing debug messages (default: false)

=back

=head2 log(%params)

Add a log message, with a specific level. %params is an hash, with the
following keys:

=over

=item I<level>

Can be one of:

=over

=item debug

=item info

=item error

=item fault

=back

=item I<message>

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
