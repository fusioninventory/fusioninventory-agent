package FusionInventory::Agent::AccountInfo;

use strict;
use warnings;

use English qw(-no_match_vars);

sub new {
    my ($class,$params) = @_;

    my $self = {};
    bless $self, $class;

    $self->{config} = $params->{config};
    $self->{logger} = $params->{logger};
    $self->{target} = $params->{target};

    my $logger = $self->{logger};
    my $target = $self->{target};


    if ($self->{config}->{accountinfofile}) {

        $logger->debug ('Accountinfo file: '. $self->{config}->{accountinfofile});
        if (! -f $self->{config}->{accountinfofile}) {
            $logger->info ("Accountinfo file doesn't exist. I create an empty one.");
            $self->write();
        } else {

            my $xmladm;

            eval {
                $xmladm = XML::Simple::XMLin(
                    $self->{config}->{accountinfofile},
                    ForceArray => [ 'ACCOUNTINFO' ]
                );
            };

            if ($xmladm && exists($xmladm->{ACCOUNTINFO})) {
                # Store the XML content in a local HASH
                for(@{$xmladm->{ACCOUNTINFO}}){
                    if (!$_->{KEYNAME}) {
                        $logger->debug ("Incorrect KEYNAME in ACCOUNTINFO");
                    }
                    $self->{accountinfo}{ $_->{KEYNAME} } = $_->{KEYVALUE};
                }
            }
        }
    } else { $logger->debug("No accountinfo file defined") }

    return $self;
}

sub get {
    my ($self, $keyname) = @_;

    return $self->{accountinfo}{$keyname} if $keyname;
}

sub getAll {
    my ($self, $name) = @_;

    return $self->{accountinfo};
}

sub set {
    my ($self, $name, $value) = @_;

    return unless defined ($name) && defined ($value);
    return unless $name && $value;

    $self->{accountinfo}->{$name} = $value;
    $self->write();
}

sub reSetAll {
    my ($self, $ref) = @_;

    my $logger = $self->{logger};

    undef $self->{accountinfo};

    if (ref ($ref) =~ /^ARRAY$/) {
        foreach (@$ref) {
            $self->set($_->{KEYNAME}, $_->{KEYVALUE});
        }
    } elsif (ref ($ref) =~ /^HASH$/) {
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

    my $tmp;
    $tmp->{ACCOUNTINFO} = [];

    foreach (keys %{$self->{accountinfo}}) {
        push @{$tmp->{ACCOUNTINFO}}, {KEYNAME => [$_], KEYVALUE =>
            [$self->{accountinfo}{$_}]}; 
    }

    my $xml=XML::Simple::XMLout( $tmp, RootName => 'ADM' );

    if (open my $handle, ">", $target->{accountinfofile}) {
        print $handle $xml;
        close $handle;
        $logger->debug ("Account info updated successfully");
    } else {
        warn "Can't open $target->{accountinfofile} for writing: $ERRNO";
        $logger->error ("Can't save account info in `".
            $target->{accountinfofile});
    }
}

1;
