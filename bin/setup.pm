package setup;

use strict;
use warnings;
use base qw(Exporter);

our @EXPORT = ('%setup');

our %setup;

# From here we can setup @INC so any needed perl module can be found. We add
# as many 'use lib' directive as needed
# We could also define '%setup' hash while useful

# Here is a sample working from sources directory or its bin subfolder
if (-d 'lib') {
    use lib './lib' ;

    %setup = (
        confdir => './etc',
        datadir => './share',
        libdir  => './lib',
        vardir  => './var',
    );

} elsif (-d '../lib') {
    use lib '../lib';

    %setup = (
        confdir => '../etc',
        datadir => '../share',
        libdir  => '../lib',
        vardir  => '../var',
    );
}
