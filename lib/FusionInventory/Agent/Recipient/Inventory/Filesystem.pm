package FusionInventory::Agent::Recipient::Inventory::Filesystem;

use strict;
use warnings;
use base 'FusionInventory::Agent::Recipient::Filesystem';

use FusionInventory::Agent::XML::Query::Inventory;

sub new {
    my ($class, %params) = @_;

    my $self = $class->SUPER::new(%params);

    $self->{format}  = $params{format};
    $self->{datadir} = $params{datadir};
    return $self;
}

sub send {
    my ($self, %params) = @_;

    my $file = sprintf(
        "%s/%s.%s",
        $self->{path},
        $self->{deviceid},
        $self->{format} eq 'xml' ? 'ocs' : 'html'
    );

    my $handle;
    if (Win32::Unicode::File->require()) {
        $handle = Win32::Unicode::File->new('w', $file);
    } else {
        open($handle, '>', $file);
    }

    if ($self->{format} eq 'xml') {

        my $message = FusionInventory::Agent::XML::Query::Inventory->new(
            deviceid => $self->{deviceid},
            content  => $params{inventory}->getContent()
        );

        print $handle $message->getContent();
    }

    if ($self->{format} eq 'html') {
        Text::Template->require();
        my $template = Text::Template->new(
            TYPE => 'FILE', SOURCE => "$self->{datadir}/html/inventory.tpl"
        );

         my $hash = {
            version  => $FusionInventory::Agent::VERSION,
            deviceid => $self->{deviceid},
            data     => $params{inventory}->{content},
            fields   => $params{inventory}->{fields},
        };

        print $handle $template->fill_in(HASH => $hash);
    }

    close($handle);
}

1;
