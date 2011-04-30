package FusionInventory::Agent::Logger;

use strict;
use warnings;

use English qw(-no_match_vars);
use UNIVERSAL::require;

sub new {
    my ($class, %params) = @_;

    my $self = {
        debug => $params{debug},
    };
    bless $self, $class;

    my %backends;
    foreach my $backend (
        $params{backends} ? @{$params{backends}} : 'Stderr'
    ) {
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
    my ($self, $args) = @_;

    # levels: debug, info, error, fault
    my $level = $args->{level} || 'info';
    my $message = $args->{message};

    return unless $message;
    return if $level eq 'debug' && !$self->{debug};

    foreach my $backend (@{$self->{backends}}) {
        $backend->addMsg ({
            level => $level,
            message => $message
        });
    }
}

sub debug {
    my ($self, $msg) = @_;

    $self->log({ level => 'debug', message => $msg});
}

sub info {
    my ($self, $msg) = @_;

    $self->log({ level => 'info', message => $msg});
}

sub error {
    my ($self, $msg) = @_;

    $self->log({ level => 'error', message => $msg});
}

sub fault {
    my ($self, $msg) = @_;

    $self->log({ level => 'fault', message => $msg});
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

=head2 log($params)

Add a log message, with a specific level. $params is an hashref, with the
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

=head2 debug($message)

Add a log message with debug level.

=head2 info($message)

Add a log message with info level.

=head2 error($message)

Add a log message with error level.

=head2 fault($message)

Add a log message with fault level.
