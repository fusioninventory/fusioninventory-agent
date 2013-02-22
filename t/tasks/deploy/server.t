#!/usr/bin/perl -w

my $tmpDirClient = $FindBin::Bin . "/../tmp/deploy-test/client";
my $tmpDirServer = $FindBin::Bin . "/../tmp/deploy-test/server";

package My::WebServer;
use base qw/Test::HTTP::Server::Simple HTTP::Server::Simple::CGI/;
use strict;
use warnings;

use JSON;
use Data::Dumper;
use Digest::SHA;
use File::Basename;
use FindBin;
use File::Path qw(make_path remove_tree);
use Archive::Tar;
use Compress::Zlib;
use English '-no_match_vars';

remove_tree($tmpDirServer) if -d $tmpDirServer;
make_path($tmpDirServer);

my $last;
my %files;
my %filePathByFilename;

# Generate a tarball
my $tar = Archive::Tar->new;
$tar->add_files(
    $FindBin::Bin . "/../Makefile.PL",
    $FindBin::Bin . "/../META.yml",
    $FindBin::Bin . "/../lib/FusionInventory/Agent/Task/Deploy.pm"
);
$tar->add_data( 'toto',   'bababa' );
$tar->add_data( 'titit',  'bibibi' );
$tar->add_data( 'tututu', 'bububu' );
open TMP, ">" . $tmpDirServer . "/tmp" or die;
foreach ( 1 .. 1024 ) {
    print TMP "aefsfcoijsfiorjfdrfoijdrfrf";
}
close TMP;
$tar->add_files( $tmpDirServer . "/tmp" );

# Add the tarball in the files list
my $sha = Digest::SHA->new('512');
$tar->write( $tmpDirServer . '/files.tar' );
$sha->addfile( $tmpDirServer . '/files.tar', 'b' );
my $sha512 = $sha->hexdigest();
$files{ $sha512 } = [
    {
        path    => $tmpDirServer . '/files.tar',
        extract => 0,
        sha512  => $sha512
    }
];
$filePathByFilename{'files.tar'} = $tmpDirServer . '/files.tar';

# Generate a multi-part distribution from the tarball
my @parts;
open FILE, "<" . $tmpDirServer . '/files.tar' or die;
binmode(FILE);
my $b;
my $cpt = 0;
while ( read( FILE, $b, 768 ) ) {
    my $file = $tmpDirServer . '/files.tar.part-' . $cpt++ . '.gz';
    my $gz = gzopen( $file, 'wb' );
    $gz->gzwrite($b);
    $gz->gzclose();
    my $sha = Digest::SHA->new('512');
    $sha->addfile( $file, 'b' );
    my $sha512 = $sha->hexdigest;
    push @parts, { path => $file, extract => 1, sha512 => $sha512 };
    $filePathByFilename{ basename($file) } = $file;
}
close FILE;
$sha->reset('512');
$sha->addfile( $tmpDirServer . '/files.tar', 'b' );
$files{ $sha->hexdigest } = \@parts;

open EMPTY, '>'.$tmpDirServer . '/empty.txt' or die;
print EMPTY "EMPTY\n";
close EMPTY;

my %actions = (
    getConfig => sub {

        my $ret = {
            'requireSSLClientCert' => 0,
            'httpd'                => {
                'ip'    => '0.0.0.0',
                'trust' => ['127.0.0.1'],
                'port'  => 62354
            },
            'configValidityPeriod' => 600,
            'schedule'             => [
                {
                    'periodicity'  => 3600,
                    'delayStartup' => 600,
                    'task'         => 'Inventory',
                    'remote' => 'https://server1/plugins/fusioninventory/b'
                },
                {
                    'periodicity' => 600,
                    'task'        => 'Deploy1',
                    'remote'      => 'http://localhost:8080/deploy1'
                },
                {
                    'periodicity' => 600,
                    'task'        => 'Deploy2',
                    'remote'      => 'http://localhost:8080/deploy2'
                },
                {
                    'periodicity' => 600,
                    'task'        => 'Deploy3',
                    'remote'      => 'http://localhost:8080/deploy3'
                },
                {
                    'periodicity' => 600,
                    'task'        => 'Deploy4',
                    'remote'      => 'http://localhost:8080/deploy4'
                },
                {
                    'periodicity' => 600,
                    'task'        => 'Deploy5',
                    'remote'      => 'http://localhost:8080/deploy5'
                },

                {
                    'periodicity' => 700,
                    'task'        => 'ESX',
                    'remote'      => 'https://server1/plugins/fusioninventory/b'
                },
                {
                    'periodicity' => 5600,
                    'task'        => 'Inventory',
                    'remote'      => 'https://server1/plugins/fusinvinventory/b'
                },
                {
                    'periodicity' => 5600,
                    'task'        => 'FooBarAMQPService',
                    'remote'      => 'amqp://server1/plugins/fusinvinventory/b'
                }
            ]
        };
        return ( encode_json($ret), 200 );

    },
    getJobs => sub {
        my ($cgi, $testname) = @_;

        my $ret = {
            'jobs' => [
                {
                    'checks' => [
                        {
                            type => "fileExists",
                            path => $tmpDirServer . '/files.tar'
                        },

                    ],
                    'actions'         => [],
                    'maxValidityDate' => 12334546,
                    'associatedFiles' => [],
                    'uuid' => '0fae2958-24d5-0651-c49c-d1fec1766af650',
                    'associatedFiles' => []
                }
            ],
            associatedFiles => {}
        };


        if ($testname eq 'deploy1') {
            $ret->{jobs}[0]{checks}[1] = {
                type => "fileSHA512",
                            path => $tmpDirServer . '/empty.txt',
                            value => '9f8e4a78eecc0391a5a86a669507d79d9756f589ffb679ff2209656022c9e3539064fec29d16251a1139c512bafcfc2051c4fa5f2a157dc8040b6b42f275712b'
            };
            $ret->{jobs}[0]{checks}[2] = {
                type => "fileSHA512",
                            path => $tmpDirServer . '/empty.txt',
                            value => 'badSHA512'
            };

        } elsif ($testname eq 'deploy2') {
            return ("", 500); # Invalid answer

    }
    elsif ( $testname eq 'deploy3' ) {
          $ret->{jobs}[0]{actions}[0] = {
              cmd => {
                  "retChecks" => [
                      {
                          "type"   => "okCode",
                          "values" => [0]
                      }
                  ],
                  exec => "$EXECUTABLE_NAME -V"
              }
          };
        }
    elsif ( $testname eq 'deploy4' ) {
          $ret->{jobs}[0]{actions}[0] = {
              cmd => {
                  "retChecks" => [
                      {
                          "type"   => "errorCode",
                          "values" => [0]
                      }
                  ],
                  exec => "$EXECUTABLE_NAME -V"
              }
          };
        }
    elsif ( $testname eq 'deploy4.1' ) {
          $ret->{jobs}[0]{actions}[0] = {
               cmd => {
          "retChecks" => [
                  {
                  "type"   => "errorCode",
                  "values" => [0]
                  }
              ],

                  exec => "$EXECUTABLE_NAME -pe \"\" " . $FindBin::Bin . "/../META.yml",
                  logLineLimit => 10
              }
          };
        }
    elsif ( $testname eq 'deploy5' ) {
          $ret->{jobs}[0]{actions}[0] = {
              cmd => {
                  "retChecks" => [
                      {
                          "type"   => "okPattern",
                          "values" => [ "foobar", "perl" ]
                      }
                  ],
                  exec => "$EXECUTABLE_NAME -V"
              }
          };
        }
    elsif ( $testname eq 'deploy6' ) {
          $ret->{jobs}[0]{actions}[0] = {
              cmd => {
                  "retChecks" => [
                      {
                          "type"   => "errorPattern",
                          "values" => [ "foobar", "perl" ]
                      }
                  ],
                  exec => "$EXECUTABLE_NAME -V"
              }
          };
        }
    elsif ( $testname eq 'deploy7' ) {
          $ret->{jobs}[0]{actions}[0] = {
              cmd => {
                  checks => [
                  {
                      path => $FindBin::Bin . "/../lib/FusionInventory/Agent/Task/Deploy.pm",
                      type => "fileExists",
                      return => "ignore"
                  }
                  ],
                  "retChecks" => [
                      {
                          "type"   => "okPattern",
                          "values" => [ "perl" ]
                      }
                  ],
                  exec => "$EXECUTABLE_NAME -V"
              }
          };
        }
    elsif ( $testname eq 'deploy8' ) {
          $ret->{jobs}[0]{actions}[0] = {
              cmd => {
                  checks => [
                  {
                      path => $FindBin::Bin . "/../lib/FusionInventory/Agent/Task/Deploy.pm-missing",
                      type => "fileExists",
                      return => "ignore"
                  }
                  ],
                  copy => [
                      $FindBin::Bin . "/../lib/FusionInventory/Agent/Task/Deploy.pm",
                      $FindBin::Bin . "/../lib/FusionInventory/Agent/Task/Deploy.pm-shouldnotbethere"
                      ]
              }
          };
        }
    elsif ( $testname eq 'deploy8' ) {
          $ret->{jobs}[0]{actions}[0] = {
              cmd => {
                  checks => [
                  {
                      path => $FindBin::Bin . "/../lib/FusionInventory/Agent/Task/Deploy.pm-missing",
                      type => "fileExists",
                      return => "ignore"
                  }
                  ],
                  "retChecks" => [
                      {
                          "type"   => "okPattern",
                          "values" => [ "perl" ]
                      }
                  ],
                  exec => "$EXECUTABLE_NAME -V"
              }
          };
        }
    elsif ( $testname eq 'deploy9' ) {
          $ret->{jobs}[0]{actions}[0] = {
              copy => {
                  from =>  $FindBin::Bin . "/../lib/FusionInventory/Agent/Task/Deploy.pm",
                  to =>  $tmpDirServer
              }
          };
        }
    elsif ( $testname eq 'deploy10' ) {
          $ret->{jobs}[0]{actions}[0] = {
              copy => {
                  from => $FindBin::Bin . "/../lib/FusionInventory/Agent/Task/*",
                  to => $tmpDirServer
              }
          };
        }
    elsif ( $testname eq 'deploy11' ) {
          $ret->{jobs}[0]{actions}[0] = {
              move => {
                  from => $tmpDirServer.'/Deploy.pm',
                  to => $tmpDirServer.'/Deploy.toto'
              }
          };
        }
    elsif ( $testname eq 'deploy12' ) {
          $ret->{jobs}[0]{actions}[0] = {
              move => {
                  from => $tmpDirServer.'/Deploy.tot*',
                  to => $tmpDirServer.'/Deploy.titi'
              }
          };
        }
    elsif ( $testname eq 'deploy13' ) {
          $ret->{jobs}[0]{actions}[0] = {
              copy => {
                  from => $tmpDirServer.'/Deploy.titi',
                  to => $tmpDirServer.'/Deploy.totor'
              }
          };
          $ret->{jobs}[0]{actions}[1] = {
              copy => {
                  from => $tmpDirServer.'/Deploy.totorMissing',
                  to => $tmpDirServer.'/Deploy.titi'
              }
          };
        }
    elsif ( $testname eq 'deploy14' ) {
          $ret->{jobs}[0]{actions}[0] = {
              mkdir => {
                list => [
                $tmpDirServer.'/test-dir1',
                $tmpDirServer.'/test-dir2',
                $tmpDirServer.'/test-dir3',
                ]
             }
          };
        }
    elsif ( $testname eq 'deploy15' ) {
          $ret->{jobs}[0]{actions}[0] = {
              delete => {
                list => [
                $tmpDirServer.'/dir-to-delete',
                $tmpDirServer.'/file-to-delete',
                ]
             }
          };
        }
        return ( encode_json($ret), 200 );
    },
    setStatus => sub {
        return ( encode_json( {} ), 200 );
    },
    setLog => sub {
        return ( encode_json( {} ), 200 );
    },
    getFiles => sub {
        my ($cgi) = @_;
        my $name = $cgi->param("name");

        #        print STDERR Dumper(\%filePathByFilename);
        if ( !$filePathByFilename{$name} || !-f $filePathByFilename{$name} ) {

            #            print STDERR "$sha512 → 404\n";
            return ( encode_json( {} ), 404 );
        }
        else {
            my $content;
            open TMP, "<" . $filePathByFilename{$name} or die;
            binmode(TMP);
            $content .= $_ foreach (<TMP>);
            close TMP;
            return ( $content, 200 );
        }
    },

);

sub handle_request {
    my $self = shift;
    my $cgi  = shift;

    my $testname = $cgi->path_info();
    $testname =~ s#\/##;

    if (   !$actions{ $cgi->param("action") }
        || !defined( $actions{ $cgi->param("action") } ) )
    {
        print "Invalid action\n";
        return;
    }
    my ( $content, $code ) = &{ $actions{ $cgi->param("action") } }($cgi, $testname);
    print "HTTP/1.0 $code OK\r\n";
    print "Content-Type: application/json\r\nContent-Length: ";
    print length($content), "\r\n\r\n", $content;
}

package main;

use strict;
use warnings;

use FusionInventory::Agent::HTTP::Client::OCS;
use FusionInventory::Agent::Target::Server;
use FusionInventory::Agent::Task::Deploy;
use FindBin;
use File::Path qw(make_path remove_tree);
use Test::More;
use Data::Dumper;

plan tests => 26;

remove_tree($tmpDirClient) if -d $tmpDirClient;
make_path($tmpDirClient);

my $port = 8080;
my $s    = My::WebServer->new();
$s->setup( port => $port );

my $url_root = $s->started_ok("start up my web server");

my $target = FusionInventory::Agent::Target::Server->new(
    url        => "http://localhost:$port/",
    basevardir => $tmpDirClient,
);
ok( $target, "loading Target object" );

my $deploy = FusionInventory::Agent::Task::Deploy->new(
    deviceid => "fakeid",
    target   => $target,
    debug    => 1
);
ok( $deploy, "loading Task object" );

$deploy->{client} = FusionInventory::Agent::HTTP::Client::Fusion->new(
    debug    => 1
);
ok( $deploy->{client}, "loading Client object" );



my $ret;
#ok( $deploy->processRemote('http://localhost:8080/deploy1'), "processRemote()" );

# $ret =
#[
#          {
#            'action' => 'getJobs',
#            'machineid' => 'fakeid'
#          },
#          {
#            'currentStep' => 'checking',
#            'action' => 'setStatus',
#            'part' => 'job',
#            'machineid' => 'fakeid',
#            'uuid' => '0fae2958-24d5-0651-c49c-d1fec1766af650'
#          },
#          {
#            'currentStep' => 'downloading',
#            'action' => 'setStatus',
#            'part' => 'job',
#            'machineid' => 'fakeid',
#            'uuid' => '0fae2958-24d5-0651-c49c-d1fec1766af650'
#          },
#          {
#            'sha512' => '2a3f70d6e9c8720ab854190838fb8739f5a23d34023d28255f3e4b673e7c987421c5bc93160b5446111b7fdf5c2ca1bbd455d8d24e1683eedee7050d151e2526',
#            'currentStep' => 'downloading',
#            'action' => 'setStatus',
#            'part' => 'file',
#            'machineid' => 'fakeid',
#            'uuid' => '0fae2958-24d5-0651-c49c-d1fec1766af650'
#          },
#          {
#            'sha512' => '2a3f70d6e9c8720ab854190838fb8739f5a23d34023d28255f3e4b673e7c987421c5bc93160b5446111b7fdf5c2ca1bbd455d8d24e1683eedee7050d151e2526',
#            'currentStep' => 'downloading',
#            'status' => 'ok',
#            'action' => 'setStatus',
#            'part' => 'file',
#            'machineid' => 'fakeid',
#            'uuid' => '0fae2958-24d5-0651-c49c-d1fec1766af650'
#          },
#          {
#            'currentStep' => 'downloading',
#            'status' => 'ok',
#            'action' => 'setStatus',
#            'part' => 'job',
#            'machineid' => 'fakeid',
#            'uuid' => '0fae2958-24d5-0651-c49c-d1fec1766af650'
#          },
#          {
#            'status' => 'ok',
#            'action' => 'setStatus',
#            'part' => 'job',
#            'machineid' => 'fakeid',
#            'uuid' => '0fae2958-24d5-0651-c49c-d1fec1766af650'
#          }
#        ];
#use Data::Dumper;
#print Dumper($ret);
#foreach(0..@$ret) {
## We ignore uuid since we don't know it.
#    $ret->[$_]{sha512} = $deploy->{client}{msgStack}[$_]{sha512} = 'ignore';
#    is_deeply($ret->[$_], $deploy->{client}{msgStack}[$_]);
#}

$deploy->{client}{msgStack} = [];


#ok( $deploy->processRemote('http://localhost:8080/deploy1.1'), "processRemote()" );

#$ret = [
#          {
#            'action' => 'getJobs',
#            'machineid' => 'fakeid'
#          },
#          {
#            'currentStep' => 'checking',
#            'part' => 'job',
#            'action' => 'setStatus',
#            'machineid' => 'fakeid',
#            'uuid' => '0fae2958-24d5-0651-c49c-d1fec1766af650'
#          },
#          {
#            'currentStep' => 'downloading',
#            'part' => 'job',
#            'action' => 'setStatus',
#            'machineid' => 'fakeid',
#            'uuid' => '0fae2958-24d5-0651-c49c-d1fec1766af650'
#          },
#          {
#            'sha512' => 'dee62337e981d7c859e6bb7d65ddd30530721b29687d3a85dafb9bb1850a7c2a4e13193bf8bf9e2d2dc4b8fbb679c74a0262479e8acf907f64bfea96ebaf20a1',
#            'currentStep' => 'downloading',
#            'part' => 'file',
#            'action' => 'setStatus',
#            'machineid' => 'fakeid',
#            'uuid' => '0fae2958-24d5-0651-c49c-d1fec1766af650'
#          },
#          {
#            'msg' => 'download failed',
#            'sha512' => 'dee62337e981d7c859e6bb7d65ddd30530721b29687d3a85dafb9bb1850a7c2a4e13193bf8bf9e2d2dc4b8fbb679c74a0262479e8acf907f64bfea96ebaf20a1',
#            'status' => 'ko',
#            'currentStep' => 'downloading',
#            'part' => 'file',
#            'action' => 'setStatus',
#            'machineid' => 'fakeid',
#            'uuid' => '0fae2958-24d5-0651-c49c-d1fec1766af650'
#          }
#        ];
#
#foreach(0..@$ret) {
## We ignore uuid since we don't know it.
#    $ret->[$_]{sha512} = $deploy->{client}{msgStack}[$_]{sha512} = 'ignore';
#    is_deeply($ret->[$_], $deploy->{client}{msgStack}[$_]);
#}

$deploy->{client}{msgStack} = [];

# Invalid getJobs answer
ok($deploy->processRemote('http://localhost:8080/deploy1'), "valid order with no action" );
$ret =
{
    'cheknum' => 2,
    'msg' => 'failure of check #3 (ko)',
    'status' => 'ko',
    'currentStep' => 'checking',
    'part' => 'job',
    'machineid' => 'fakeid',
    'uuid' => '0fae2958-24d5-0651-c49c-d1fec1766af650',
    'action' => 'setStatus'
}
;
$last = pop @{$deploy->{client}{msgStack}};
is_deeply($last, $ret);
$deploy->{client}{msgStack} = [];


# Invalid getJobs answer
ok(!$deploy->processRemote('http://localhost:8080/deploy2'), "invalid order, should generate an err 500" );
$ret = [
          {
            'action' => 'getJobs',
            'machineid' => 'fakeid'
          }
];
is_deeply($deploy->{client}{msgStack}, $ret);
$deploy->{client}{msgStack} = [];

# Run perl and see 0 as success code and so
# should flag the deployment as OK
$deploy->processRemote('http://localhost:8080/deploy3');
$last = pop @{$deploy->{client}{msgStack}};
ok(
        ($last->{status} eq "ok")
        &&
        ($last->{part} eq "job"), "Cmd okCode");
$deploy->{client}{msgStack} = [];

# Run perl and see 0 as an error code and so
# should flag the deployment as KO
$deploy->processRemote('http://localhost:8080/deploy4');
$last = pop @{$deploy->{client}{msgStack}};
ok(($last->{status} eq "ko") && ($last->{actionnum} == 0), "Cmd errorCode");
$deploy->{client}{msgStack} = [];

# ensure we got only 10 lines of log
$deploy->processRemote('http://localhost:8080/deploy4.1');
pop @{$deploy->{client}{msgStack}};
$last = pop @{$deploy->{client}{msgStack}};
ok (int(@{$last->{msg}}) == 10 + 3, "Log: Number of line based on logLineLimit");
$deploy->{client}{msgStack} = [];

# Run perl and see 0 as an error code and so
# should flag the deployment as KO
$deploy->processRemote('http://localhost:8080/deploy5');
$last = pop @{$deploy->{client}{msgStack}};
ok($last->{status} eq "ok", "Cmd okPattern");
$deploy->{client}{msgStack} = [];

# Run perl and see 0 as an error code and so
# should flag the deployment as KO
$deploy->processRemote('http://localhost:8080/deploy6');
$last = pop @{$deploy->{client}{msgStack}};
ok(($last->{status} eq "ko") && ($last->{actionnum} == 0), "Cmd errorPatern");
$deploy->{client}{msgStack} = [];

# Action with check that must return ignore and so get
# the action to be ignored
$deploy->processRemote('http://localhost:8080/deploy7');
$last = pop @{$deploy->{client}{msgStack}};
ok($last->{status} eq "ok", "false ignore + action");
$deploy->{client}{msgStack} = [];

#SKIP: {
#   skip "not implemnted yet", 2;
# Action with check that must return 'ignore' status.
# With such status, the action will be be ignored
$deploy->processRemote('http://localhost:8080/deploy8');
$last = pop @{$deploy->{client}{msgStack}};
ok($last->{status} eq "ok", "true ignore + action, unimplemented");
$last = pop @{$deploy->{client}{msgStack}};
ok($last->{status} eq "ignore", "action has been ignored");
ok(!-f $FindBin::Bin . "/../lib/FusionInventory/Agent/Task/Deploy.pm-shouldnotbethere", "action really ignored");
$deploy->{client}{msgStack} = [];
#}

# Try to copy a file
unlink ($tmpDirServer.'/Deploy.pm');
$deploy->processRemote('http://localhost:8080/deploy9');
$deploy->{client}{msgStack} = [];
ok (-f $tmpDirServer.'/Deploy.pm', "copy a file");
unlink ($tmpDirServer.'/Deploy.pm');
$deploy->{client}{msgStack} = [];

# Try to copy a file using a wildcare (*)
$deploy->processRemote('http://localhost:8080/deploy10');
ok (-d $tmpDirServer.'/Deploy/', "copy using a glob()");
$deploy->{client}{msgStack} = [];

# Move a file
$deploy->processRemote('http://localhost:8080/deploy11');
ok ((!-f $tmpDirServer.'/Deploy.pm') && (-f $tmpDirServer.'/Deploy.toto'), "move");
$deploy->{client}{msgStack} = [];

# move a file using a wildcare (*)
unlink($tmpDirServer.'/Deploy.titi');
$deploy->processRemote('http://localhost:8080/deploy12');
ok ((!-f $tmpDirServer.'/Deploy.toto') && (-f $tmpDirServer.'/Deploy.titi'), "move with glob()");
$deploy->{client}{msgStack} = [];

# try to copy valide file then a missing file
unlink($tmpDirServer.'/Deploy.totor');
$deploy->processRemote('http://localhost:8080/deploy13');
ok ((!-f $tmpDirServer.'/Deploy.toto') && (-f $tmpDirServer.'/Deploy.titi'), "fails the second action");
$last = pop @{$deploy->{client}{msgStack}};
ok(($last->{status} eq "ko") && ($last->{actionnum} == 1), "section action should failed");
$deploy->{client}{msgStack} = [];

# create a list of directory
$deploy->processRemote('http://localhost:8080/deploy14');
ok (
  -d $tmpDirServer.'/test-dir1'
    &&
  -d $tmpDirServer.'/test-dir2'
    &&
  -d $tmpDirServer.'/test-dir3',
, "create directory");
$deploy->{client}{msgStack} = [];

mkdir $tmpDirServer.'/dir-to-delete';
open FILE, ">".$tmpDirServer.'/file-to-delete';
print FILE "titi\n";
close FILE;
# delete a list of file and directory
$deploy->processRemote('http://localhost:8080/deploy15');
ok (
  !-e $tmpDirServer.'/dir-to-delete'
    &&
  !-e $tmpDirServer.'/file-to-delete'
, "delete file and directory");
$deploy->{client}{msgStack} = [];


#ok( $deploy->processRemote('http://localhost:8080/deploy3'), "processRemote()" );
#ok( $deploy->processRemote('http://localhost:8080/deploy4'), "processRemote()" );
#ok( $deploy->processRemote('http://localhost:8080/deploy5'), "processRemote()" );

ok ($deploy->run(), "running the task");
