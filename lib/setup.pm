package
        setup;

use strict;
use warnings;
use parent qw(Exporter);

our @EXPORT = ('%setup');

our %setup = (
    datadir => './share',
    libdir  => './lib',
    vardir  => './var',
);

# Compute directly libdir from this setup file as it should be installed
# in expected directory
eval {
    $setup{libdir} = abs_path(File::Spec->rel2abs('..', __FILE__))
        unless ($setup{libdir} && File::Spec->file_name_is_absolute($setup{libdir}));

    # If run from sources, we can try to rebase setup keys to absolute folders related to libdir
    if (File::Spec->file_name_is_absolute($setup{libdir})) {
        foreach my $key (qw(datadir vardir)) {
            # Anyway don't update if target still absolute
            next if ($setup{$key} && File::Spec->file_name_is_absolute($setup{$key}));

            my $folder = abs_path(File::Spec->rel2abs('../'.$setup{$key}, $setup{libdir}));
            $setup{$key} = $folder if -d $folder;
        }
    }
};

1;
