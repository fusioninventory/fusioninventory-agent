package FusionInventory::Compress;

use strict;
use warnings;

use English qw(-no_match_vars);
use File::Temp qw/ tempdir tempfile /;

sub new {
    my ($class, $params) = @_;

    my $self = {
        logger => $params->{logger}
    };

    my $logger = $self->{logger};

    eval {
        require Compress::Zlib;
        $self->{mode} = 'native';
        $logger->debug('Compress::Zlib is available.');
    };

    if ($EVAL_ERROR) {
        if (system('which gzip >/dev/null 2>&1') == 0) {
            $self->{mode} = 'gzip';
            $self->{tmpdir} = tempdir( CLEANUP => 1 );
            $logger->debug(
                "Compress::Zlib is not available! The data will be " .
                "compressed with gzip instead but won't be accepted by " .
                "server prior 1.02"
            );
        } else {
            $self->{mode} = 'deflated';
            $logger->debug(
                "I need the Compress::Zlib library or the gzip command to " .
                "compress the data. The data will be sent uncompressed but " .
                "won't be accepted by server prior 1.02"
            );
        }
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
        my ($handle, $file) = tempfile(DIR => $self->{tmpdir});
        print $handle $data;
        close $handle;

        system ("gzip --best $file > /dev/null");

        my $out_file = $file . '.gz';
        my $out_handle;

        if (! open $out_handle, '<', $out_file) {
            $self->{logger}->debug("Can't open $out_file: $ERRNO");
            return;
        }

        local $/;   # Set input to "slurp" mode.
        my $out_data = <$out_handle>;
        close $out_handle;

        if (! unlink $out_file) {
            $self->{logger}->debug("Can't remove $out_file: $ERRNO");
        }

        return $out_data;
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
        my ($handle, $file) = tempfile(DIR => $self->{tmpdir}, SUFFIX => '.gz');
        print $handle $data;
        close $handle;

        system ("gzip -d $file > /dev/null");

        my $out_file = $file;
        $out_file =~ s/\.gz$//;
        my $out_handle;

        if (! open $out_handle, '<', $out_file) {
            $self->{logger}->debug("Can't open $out_file: $ERRNO");
            return;
        }

        local $/;   # Set input to "slurp" mode.
        my $out_data = <$out_handle>;
        close $out_handle;

        if (! unlink $out_file) {
            $self->{logger}->debug("Can't remove $out_file: $ERRNO");
        }

        return $out_data;
    }

    if ($self->{mode} eq 'deflated') {
        return $data;
    }
}

1;
