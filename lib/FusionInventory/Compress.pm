package FusionInventory::Compress;

use strict;
use warnings;

use English qw(-no_match_vars);
use File::Temp;
use UNIVERSAL::require;

sub new {
    my ($class, $params) = @_;

    my $self = {
        logger => $params->{logger}
    };

    my $logger = $self->{logger};


    if (Compress::Zlib->require()) {
        $self->{mode} = 'native';
        $logger->debug('Compress::Zlib is available.');
    } elsif (system('which gzip >/dev/null 2>&1') == 0) {
        $self->{mode} = 'gzip';
        $logger->debug(
            "Compress::Zlib is not available! The data will be compressed " .
            "with gzip instead but won't be accepted by server prior 1.02"
        );
    } else {
        $self->{mode} = 'deflated';
        $logger->debug(
            "I need the Compress::Zlib library or the gzip command to " .
            "compress the data. The data will be sent uncompressed but " .
            "won't be accepted by server prior 1.02"
        );
    }

    bless $self, $class;
    return $self;
}

sub compress {
    my ($self, $data) = @_;

    if ($self->{mode} eq 'native') {
        return Compress::Zlib::compress($data);
    }

    if ($self->{mode} eq 'gzip') {
        return $self->_compressGzip($data);
    }

    if ($self->{mode} eq 'deflated') {
        return $data;
    }
}



sub uncompress {
    my ($self, $data) = @_;

    if ($self->{mode} eq 'native') {
        return Compress::Zlib::uncompress($data);
    }

    if ($self->{mode} eq 'gzip') {
        return $self->_uncompressGzip($data);
    }

    if ($self->{mode} eq 'deflated') {
        return $data;
    }
}

sub _compressGzip {
    my ($self, $data) = @_;

    my $in = File::Temp->new();
    print $in $data;
    close $in;

    my $command = 'gzip -c ' . $in->filename();
    my $out;
    if (! open $out, '-|', $command) {
        $self->{logger}->debug("Can't run $command: $ERRNO");
        return;
    }

    local $INPUT_RECORD_SEPARATOR; # Set input to "slurp" mode.
    my $result = <$out>;
    close $out;

    return $result;
}

sub _uncompressGzip {
    my ($self, $data) = @_;

    my $in = File::Temp->new();
    print $in $data;
    close $in;

    my $command = 'gzip -dc ' . $in->filename();
    my $out;
    if (! open $out, '-|', $command) {
        $self->{logger}->debug("Can't run $command: $ERRNO");
        return;
    }

    local $INPUT_RECORD_SEPARATOR; # Set input to "slurp" mode.
    my $result = <$out>;
    close $out;

    return $result;
}

1;
