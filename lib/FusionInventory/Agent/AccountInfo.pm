package FusionInventory::Agent::AccountInfo;

use strict;
use warnings;

use English qw(-no_match_vars);
use XML::Simple;

sub new {
    my ($class,$params) = @_;

    my $self = {
       config => $params->{config},
       logger => $params->{logger},
       target => $params->{target},
    };
    bless $self, $class;

    $self->{config} = $params->{config};
    $self->{logger} = $params->{logger};
    $self->{storage} = $params->{storage};
    $self->{target} = $params->{target};

    my $logger = $self->{logger};
    my $storage = $self->{storage};
    my $target = $self->{target};

    $self->{myData} = $storage->restore();
    
    $self;
}

sub get {
    my ($self, $keyname) = @_;

    return $self->{myData}{$keyname} if $keyname;
}

sub getAll {
    my ($self, $name) = @_;

    return $self->{myData};
}

sub set {
    my ($self, $name, $value) = @_;

    return unless defined ($name) && defined ($value);
    return unless $name && $value;

    $self->{myData}->{$name} = $value;
    $self->write();
}

sub reSetAll {
    my ($self, $ref) = @_;

    my $logger = $self->{logger};

    $self->{myData} = {};

    if (ref ($ref) eq 'ARRAY') {
        foreach (@$ref) {
            $self->set($_->{KEYNAME}, $_->{KEYVALUE});
        }
    } elsif (ref ($ref) eq 'HASH') {
        $self->set($ref->{'KEYNAME'}, $ref->{'KEYVALUE'});
    } else {
        $logger->debug ("reSetAll, invalid parameter");
    }
}

# Add accountinfo stuff to an inventory
sub setAccountInfo {
    my $self = shift;
    my $inventary = shift;

    my $ai = $self->getAll();
    $self->{h}{'CONTENT'}{ACCOUNTINFO} = [];

    return unless $ai;

    foreach (keys %$ai) {
        push @{$inventary->{h}{'CONTENT'}{ACCOUNTINFO}}, {
            KEYNAME => [$_],
            KEYVALUE => [$ai->{$_}],
        };
    }
}


sub write {
    my ($self, $args) = @_;

    my $logger = $self->{logger};
    my $target = $self->{target};
    my $storage = $self->{storage};

<<<<<<< HEAD
    $storage->save({ data => $self->{myData} });
=======
    my $tmp;
    $tmp->{ACCOUNTINFO} = [];

    foreach (keys %{$self->{accountinfo}}) {
        push @{$tmp->{ACCOUNTINFO}}, {KEYNAME => [$_], KEYVALUE =>
            [$self->{accountinfo}{$_}]}; 
    }

    my $xml = XMLout( $tmp, RootName => 'ADM' );

    if (open my $handle, ">", $target->{accountinfofile}) {
        print $handle $xml;
        close $handle;
        $logger->debug ("Account info updated successfully");
    } else {
        warn "Can't open $target->{accountinfofile} for writing: $ERRNO";
        $logger->error ("Can't save account info in `".
            $target->{accountinfofile});
    }
>>>>>>> guillomovitch/master
}

1;
