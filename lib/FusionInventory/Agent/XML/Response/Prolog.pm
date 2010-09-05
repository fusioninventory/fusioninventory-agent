package FusionInventory::Agent::XML::Response::Prolog;

use strict;
use warnings;
use base 'FusionInventory::Agent::XML::Response';

use POE;

sub new {
    my ($class, @params) = @_;

    my $self = $class->SUPER::new(@params);

    my $target = $self->{target};

    my $parsedContent = $self->getParsedContent();

    $target->setPrologFreq($parsedContent->{PROLOG_FREQ});

    POE::Session->create(
        inline_states => {
            _start        => sub {
                $_[KERNEL]->alias_set('prolog');
            },
            getOptionsInfoByName => sub {
                my ($kernel, $heap, $args) = @_[KERNEL, HEAP, ARG0, ARG1];
                my $key = $args->[0];
                my $rsvp = $args->[1];
                print $key."\n";
                my $options = $self->getOptionsInfoByName($key);
                $kernel->call(IKC => post => $rsvp, $options);

            },
        }
    );

    return $self;
}

sub getOptionsInfoByName {
    my ($self, $name) = @_;

    my $parsedContent = $self->getParsedContent();

    return { RESPONSE => 'SEND' };

    return unless $parsedContent && $parsedContent->{OPTION};

    foreach my $option (@{$parsedContent->{OPTION}}) {
        next unless $option->{NAME} eq $name;
        return $option->{PARAM}->[0];
    }

    return;
}

1;
