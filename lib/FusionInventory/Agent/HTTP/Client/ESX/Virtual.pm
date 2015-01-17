package FusionInventory::Agent::HTTP::Client::ESX::Virtual;

use strict;
use warnings;
use base 'FusionInventory::Agent::HTTP::Client::ESX';

use English qw(-no_match_vars);
use XML::TreePP;

sub new {
    my ($class, %params) = @_;

    die "non-existing directory '$params{directory}'\n"
        unless -d $params{directory};
    die "unreadable directory '$params{directory}'\n"
        unless -r $params{directory};

    my $self = {
        directory => $params{directory},
        tpp       => XML::TreePP->new(force_array => [qw(returnval propSet)])
    };
    bless $self, $class;

    return $self;
}

sub _send {
    my ($self, $action, $xmlToSend) = @_;

    my $tree = $self->{tpp}->parse($xmlToSend);
    my $body =
        $tree->{'soapenv:Envelope'}->{'soapenv:Body'};
    my $obj  =
        $body->{RetrieveProperties}->{specSet}->{objectSet}->{obj};
    if ($obj->{'-type'} && $obj->{'-type'} eq 'VirtualMachine') {
        $action .= "-VM-$obj->{'#text'}";
    }
    my $file = $self->{directory} . "/" . $action . ".soap";

    local $INPUT_RECORD_SEPARATOR; # Set input to "slurp" mode.
    open(my $handle, '<', $file) or die "failed to open $file";
    my $content = <$handle>;
    close $handle;

    return $content;
}

1;

__END__

=head1 NAME

FusionInventory::Agent::HTTP::Client::ESX::Virtual - Virtual HTTP client for ESX hypervisor

=head1 DESCRIPTION

This module allow access to VMware hypervisor using VMware SOAP API.

=head1 METHODS

=head2 new(%params)

Returns a VMware object.

=head2 connect($user, $password)

Connect the VMware object with the given credentials.

=head2 getHostFullInfo($id)

Returns a large hash structure with the host information.

=head2 getHostIds()

Returns the list of the virtual machine ID in an array reference.
