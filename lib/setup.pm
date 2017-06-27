package setup;

use strict;
use warnings;
use base qw(Exporter);

use File::Spec;

our @EXPORT = ('%setup');

our %setup = (
    confdir => './etc',
    datadir => './share',
    libdir  => './lib',
    vardir  => './var',
);

# Compute directly libdir from this setup file as it should be installed
# in expected directory
$setup{libdir} = File::Spec->rel2abs('..', __FILE__)
    unless ($setup{libdir} && File::Spec->file_name_is_absolute($setup{libdir}));

1;
