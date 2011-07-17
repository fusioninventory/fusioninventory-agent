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
        my $cpt = 0;
        foreach my $sha512 ( keys %files ) {
            push @{ $ret->{jobs}[0]{associatedFiles} }, $sha512;

            my $associatedFile = {
                'uncompress' => 0,
                'mirrors' => ['http://localhost:8080/?action=getFiles&name='],
                'multiparts'             => [],
                'p2p'                    => 0,
                'p2p-retention-duration' => 0,
                'name'                   => 'file-' . $cpt++ . '.test'
            };
            foreach ( @{ $files{$sha512} } ) {
                push @{ $associatedFile->{multiparts} },
                  { basename( $_->{path} ) => $_->{sha512} };
            }
            $ret->{associatedFiles}{$sha512} = $associatedFile;
        }
        }
        elsif ($testname eq 'deploy1.1') {
        my $cpt = 0;
        foreach my $sha512 ( keys %files ) {
            push @{ $ret->{jobs}[0]{associatedFiles} }, $sha512;

            my $associatedFile = {
                'uncompress' => 0,
                'mirrors' => ['http://localhost:8080/?action=getFiles&name='],
                'multiparts'             => [],
                'p2p'                    => 0,
                'p2p-retention-duration' => 0,
                'name'                   => 'file-' . $cpt++ . '.test'
            };
            foreach ( @{ $files{$sha512} } ) {
                push @{ $associatedFile->{multiparts} },
                  { "bad" => "bad" };
            }
            $ret->{associatedFiles}{$sha512} = $associatedFile;
        }
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

use FusionInventory::Agent::Target::Server;
use FusionInventory::Agent::Task::Deploy;
use FindBin;
use File::Path qw(make_path remove_tree);
use Test::More tests => 16;
use Data::Dumper;

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
    debug      => 1
);
ok( $deploy, "loading Task object" );

ok( $deploy->processRemote('http://localhost:8080/deploy1'), "processRemote()" );

my $ret = [
          {
            'action' => 'getJobs',
            'machineid' => 'fakeid'
          },
          {
            'currentStep' => 'checking',
            'part' => 'job',
            'action' => 'setStatus',
            'machineid' => 'DEVICEID',
            'uuid' => '0fae2958-24d5-0651-c49c-d1fec1766af650'
          },
          {
            'currentStep' => 'downloading',
            'part' => 'job',
            'action' => 'setStatus',
            'machineid' => 'DEVICEID',
            'uuid' => '0fae2958-24d5-0651-c49c-d1fec1766af650'
          },
          {
            'sha512' => '2a3f70d6e9c8720ab854190838fb8739f5a23d34023d28255f3e4b673e7c987421c5bc93160b5446111b7fdf5c2ca1bbd455d8d24e1683eedee7050d151e2526',
            'currentStep' => 'downloading',
            'part' => 'file',
            'action' => 'setStatus',
            'machineid' => 'DEVICEID',
            'uuid' => '0fae2958-24d5-0651-c49c-d1fec1766af650'
          },
          {
            'sha512' => '2a3f70d6e9c8720ab854190838fb8739f5a23d34023d28255f3e4b673e7c987421c5bc93160b5446111b7fdf5c2ca1bbd455d8d24e1683eedee7050d151e2526',
            'status' => 'ok',
            'currentStep' => 'downloading',
            'part' => 'file',
            'action' => 'setStatus',
            'machineid' => 'DEVICEID',
            'uuid' => '0fae2958-24d5-0651-c49c-d1fec1766af650'
          },
          {
            'status' => 'ok',
            'currentStep' => 'downloading',
            'part' => 'job',
            'action' => 'setStatus',
            'machineid' => 'DEVICEID',
            'uuid' => '0fae2958-24d5-0651-c49c-d1fec1766af650'
          },
          {
            'status' => 'ok',
            'part' => 'job',
            'action' => 'setStatus',
            'machineid' => 'DEVICEID',
            'uuid' => '0fae2958-24d5-0651-c49c-d1fec1766af650'
          }
        ];

foreach(0..@$ret) {
# We ignore uuid since we don't know it.
    $ret->[$_]{sha512} = $deploy->{fusionClient}{msgStack}[$_]{sha512} = 'ignore';
    is_deeply($ret->[$_], $deploy->{fusionClient}{msgStack}[$_]);
}

$deploy->{fusionClient}{msgStack} = [];


ok( $deploy->processRemote('http://localhost:8080/deploy1.1'), "processRemote()" );

$ret = [
          {
            'action' => 'getJobs',
            'machineid' => 'fakeid'
          },
          {
            'currentStep' => 'checking',
            'part' => 'job',
            'action' => 'setStatus',
            'machineid' => 'DEVICEID',
            'uuid' => '0fae2958-24d5-0651-c49c-d1fec1766af650'
          },
          {
            'currentStep' => 'downloading',
            'part' => 'job',
            'action' => 'setStatus',
            'machineid' => 'DEVICEID',
            'uuid' => '0fae2958-24d5-0651-c49c-d1fec1766af650'
          },
          {
            'sha512' => 'dee62337e981d7c859e6bb7d65ddd30530721b29687d3a85dafb9bb1850a7c2a4e13193bf8bf9e2d2dc4b8fbb679c74a0262479e8acf907f64bfea96ebaf20a1',
            'currentStep' => 'downloading',
            'part' => 'file',
            'action' => 'setStatus',
            'machineid' => 'DEVICEID',
            'uuid' => '0fae2958-24d5-0651-c49c-d1fec1766af650'
          },
          {
            'msg' => 'download failed',
            'sha512' => 'dee62337e981d7c859e6bb7d65ddd30530721b29687d3a85dafb9bb1850a7c2a4e13193bf8bf9e2d2dc4b8fbb679c74a0262479e8acf907f64bfea96ebaf20a1',
            'status' => 'ko',
            'currentStep' => 'downloading',
            'part' => 'file',
            'action' => 'setStatus',
            'machineid' => 'DEVICEID',
            'uuid' => '0fae2958-24d5-0651-c49c-d1fec1766af650'
          }
        ]; 

foreach(0..@$ret) {
# We ignore uuid since we don't know it.
    $ret->[$_]{sha512} = $deploy->{fusionClient}{msgStack}[$_]{sha512} = 'ignore';
    is_deeply($ret->[$_], $deploy->{fusionClient}{msgStack}[$_]);
}

$deploy->{fusionClient}{msgStack} = [];

# Invalid getJobs answer
ok(!$deploy->processRemote('http://localhost:8080/deploy2'), "processRemote()" );
$ret = [
          {
            'action' => 'getJobs',
            'machineid' => 'fakeid'
          }
];
is_deeply($ret, $deploy->{fusionClient}{msgStack});
$deploy->{fusionClient}{msgStack} = [];

my $last;
# Run perl and see 0 as success code and so
# should flag the deployment as OK 
$deploy->processRemote('http://localhost:8080/deploy3');
$last = pop @{$deploy->{fusionClient}{msgStack}};
ok(
        ($last->{status} eq "ok")
        &&
        ($last->{part} eq "job"), "Cmd okCode");
$deploy->{fusionClient}{msgStack} = [];

# Run perl and see 0 as an error code and so
# should flag the deployment as KO
$deploy->processRemote('http://localhost:8080/deploy4');
$last = pop @{$deploy->{fusionClient}{msgStack}};
ok(($last->{status} eq "ko") && ($last->{actionnum} == 0), "Cmd errorCode");
$deploy->{fusionClient}{msgStack} = [];

# Run perl and see 0 as an error code and so
# should flag the deployment as KO
$deploy->processRemote('http://localhost:8080/deploy5');
$last = pop @{$deploy->{fusionClient}{msgStack}};
ok($last->{status} eq "ok", "Cmd okPattern");
$deploy->{fusionClient}{msgStack} = [];

# Run perl and see 0 as an error code and so
# should flag the deployment as KO
$deploy->processRemote('http://localhost:8080/deploy6');
$last = pop @{$deploy->{fusionClient}{msgStack}};
ok(($last->{status} eq "ko") && ($last->{actionnum} == 0), "Cmd errorPatern");
$deploy->{fusionClient}{msgStack} = [];

# Action with check that must return ignore and so get
# the action to be ignored
$deploy->processRemote('http://localhost:8080/deploy7');
$last = pop @{$deploy->{fusionClient}{msgStack}};
ok($last->{status} eq "ok", "false ignore + action");
$deploy->{fusionClient}{msgStack} = [];

# Action with check that must return ignore and so get
# the action to be ignored
$deploy->processRemote('http://localhost:8080/deploy8');
$last = pop @{$deploy->{fusionClient}{msgStack}};
ok($last->{status} eq "ok", "true ignore + action");
$last = pop @{$deploy->{fusionClient}{msgStack}};
ok($last->{status} eq "ignore", "action has been ignored");
ok(!-f $FindBin::Bin . "/../lib/FusionInventory/Agent/Task/Deploy.pm-shouldnotbethere", "action really ignored");
$deploy->{fusionClient}{msgStack} = [];

unlink ($tmpDirServer.'/Deploy.pm');
$deploy->processRemote('http://localhost:8080/deploy9');
$deploy->{fusionClient}{msgStack} = [];
ok (-f $tmpDirServer.'/Deploy.pm', "copy a file");
unlink ($tmpDirServer.'/Deploy.pm');
$deploy->{fusionClient}{msgStack} = [];

$deploy->processRemote('http://localhost:8080/deploy10');
ok (-d $tmpDirServer.'/Deploy/', "copy using a glob()");
$deploy->{fusionClient}{msgStack} = [];

$deploy->processRemote('http://localhost:8080/deploy11');
ok ((!-f $tmpDirServer.'/Deploy.pm') && (-f $tmpDirServer.'/Deploy.toto'), "move");
$deploy->{fusionClient}{msgStack} = [];

unlink($tmpDirServer.'/Deploy.titi');
$deploy->processRemote('http://localhost:8080/deploy12');
ok ((!-f $tmpDirServer.'/Deploy.toto') && (-f $tmpDirServer.'/Deploy.titi'), "move with glob()");
$deploy->{fusionClient}{msgStack} = [];


#ok( $deploy->processRemote('http://localhost:8080/deploy3'), "processRemote()" );
#ok( $deploy->processRemote('http://localhost:8080/deploy4'), "processRemote()" );
#ok( $deploy->processRemote('http://localhost:8080/deploy5'), "processRemote()" );

ok ($deploy->run(), "running the task");
