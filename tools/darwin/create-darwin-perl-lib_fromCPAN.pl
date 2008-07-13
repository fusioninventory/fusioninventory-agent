#!/usr/bin/perl -w
# 
# COPYRIGHT:
#
# This software is Copyright (c) 2008 claimid.com/saxjazman9
# 
# (Except where explicitly superseded by other copyright notices)
# 
# Special thanks to Jesse over a best practical for the framework
# from which this script is has been created
# 
# LICENSE:
# 
# This work is made available to you under the terms of Version 2 of
# the GNU General Public License. A copy of that license should have
# been provided with this software, but in any event can be snarfed
# from www.gnu.org.
# 
# This work is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA
# 02110-1301 or visit their web page on the internet at
# http://www.gnu.org/licenses/old-licenses/gpl-2.0.html.
# 

#
# This is just a basic script that checks to make sure that all
# the modules needed by OCSNG before you can compile it.
#

#
# WARNING: Before executing this script please modify your ~/.cpan/CPAN/MyConfig.pm file as follows:
# $> perl -MCPAN -e shell
# cpan> o conf makepl_arg 'LIB=~/darwin-perl-lib PREFIX=--perl-only'
# cpan> o conf commit
# cpan> quit
#
# This will set the CPAN shell up to install the modules in this script to ~/darwin-perl-lib
# it will also cause the man pages and other misc perl stuff to not be installed... we only need the modules anyway
#
# After this script is done, you will take the ~/darwin-perl-lib and move it to the source code directory for
# compiling your application
#
# Once the script has completed and you are confident you have everything, you can reverse the changes to your
# MyConfig.pm by:
#
# # $> perl -MCPAN -e shell
# cpan> o conf makepl_arg ''
# cpan> o conf commit
# cpan> quit
#
# A simple: vi ~/.cpan/CPAN/MyConfig.pm should show that the changes were successful

#
# THIS IS A BETA SCRIPT! USE AT YOUR OWN RISK
#

use strict;
use warnings;
use Getopt::Long;
use CPAN;

my %args;
my %deps;
GetOptions(
    \%args,
    'install',                            
	'ssl',
);

unless (keys %args) {
    help();
    exit(0);
}

# Set up defaults
my %default = (
    'ssl'		=> 0,
	'CORE'		=> 1,	
);
$args{$_} = $default{$_} foreach grep !exists $args{$_}, keys %default;

#
# Place any core modules (+ verisons) that are required in the form: MOD::MOD 0.01
#

$deps{'CORE'} = [ text_to_hash( << '.') ];
File::Temp
LWP
XML::Simple
URI
File::Listing
G/GA/GAAS/libwww-perl-5.813.tar.gz
Mac::SysProfile
Net::IP
Proc::Daemon
Proc::PID::File
XML::SAX
XML::Parser
XML::NamespaceSupport
Proc::PID::File
Compress::Zlib
Compress::Raw::Zlib
IO::Zlib
IO-Compress-Zlib-2.011
.

# for ssl, include the Crypt::SSLeay library's
# NOTE: YOU NEED OPENSSL pre-compiled on the system for this to work... You've been warned.
$deps{'SSL'} = [ text_to_hash( << '.') ];
Crypt::SSLeay
Net::SSLeay
.

# push all the dep's into a @missing array
my @missing;
my @deps = @{ $deps{'CORE'} };
while (@deps) {
	my $module = shift @deps;
	my $version = shift @deps;
	push @missing, $module, $version;
}
	
# assuming we've passed the --install, proceed with the compiling and install to our 
if ( $args{'install'} ) {
	while( @missing ) {
		resolve_dep(shift @missing, shift @missing);
	}
}

# convert the dep text list to a hash
sub text_to_hash {
    my %hash;
    for my $line ( split /\n/, $_[0] ) {
        my($key, $value) = $line =~ /(\S+)\s*(\S*)/;
        $value ||= '';
        $hash{$key} = $value;
    }
    return %hash;
}

# pull in our local .cpan/CPAN/MyConfig.pm file 
# use the cpan shell to force install the module to our local dir
# force install is used because although we may have the package already up-to-date on our system,
# we want a clean fresh copy installed to our darwin-perl-lib dir.
sub resolve_dep {
    my $module = shift;
    my $version = shift;
	
	local @INC = @INC;
	if ( $ENV{'HOME'} ) {
		unshift @INC, "$ENV{'HOME'}/.cpan";
	}

    print "\nInstall module $module\n";
	my $cfg = (eval { require CPAN::MyConfig });
	unless($cfg){ die('CPAN Not configured properly'); }
	CPAN::Shell->force('install',$module);
}

# the help....
sub help {

    print <<'.';

By default, testdeps determine whether you have 
installed all the perl modules OCSNG.app needs to run.

	--install		Install missing modules
	
The following switches will tell the tool to check for specific dependencies

	--ssl		Incorporate SSL for package deployment (requires OPENSSL lib's to be installed)
.
}

1;
