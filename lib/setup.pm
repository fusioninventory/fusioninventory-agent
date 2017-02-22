package setup;

use strict;
use warnings;
use base qw(Exporter);

our @EXPORT = ('%setup');

our %setup = (
    confdir => './etc',
    datadir => './share',
    libdir  => './lib',
    vardir  => './var',
);

1;
