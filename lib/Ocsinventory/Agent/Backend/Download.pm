package Ocsinventory::Agent::Backend::Download;

use XML::Simple;
use File::Copy;
use LWP::Simple;
use File::Path;


use Data::Dumper;

sub check {
    my $params = shift;

    my $prologresp = $params->{prologresp};
    my $config = $params->{config};
    my $logger = $params->{logger};
    my $storage = $params->{storage};
    print "Storage".Dumper($storage);

    my $downloadBaseDir = $config->{vardir}.'/download';


    # The orders are send during the PROLOG. Since the prolog is
    # one of the arg of the check() function. We can process it.
    return unless $prologresp;
    my $conf = $prologresp->getOptionsInfoByName("DOWNLOAD");

    if (!@$conf) {
        $logger->debug("no DOWNLOAD options returned during PROLOG");
        return;
    }

    if (!$config->{vardir}) {
        $logger->error("vardir is not initialized!");
        return;
    }


    open TMP, ">$downloadBaseDir/config.$$";
    print TMP XMLout($conf, RootName => 'CONF');
    close TMP;
    move("$downloadBaseDir/config.$$", "$downloadBaseDir/config");

    print "La conf : ".Dumper($prologresp);

    print "GOGO\n";

    # The XML is ill formated and we have to run a loop to retriev
    # the different keys
    foreach my $paramHash (@$conf) {
        if ($paramHash->{TYPE} eq 'CONF') {
            # Save the config sent during the PROLOG
            open TMP, ">$downloadBaseDir/config.$$";
            print TMP XMLout($conf->[0], RootName => 'CONF');
            close TMP;
            move("$downloadBaseDir/config.$$", "$downloadBaseDir/config");
        } elsif ($paramHash->{TYPE} eq 'PACK') {
            if ($storage->{byId}{$paramHash->{ID}}) {
              $logger->debug($paramHash->{ID}." already in the queue.");
              next;
            }

            my $infoURI = 'https://'.$paramHash->{INFO_LOC}.'/'.$paramHash->{ID}.'/info';
            my $content = LWP::Simple::get($infoURI);
            if (!$content) {
              $logger->error("Failed to read info file `$infoURI'");
            }

            my $infoHash = XML::Simple::XMLin( $content );
            if (!$infoHash) {
              $logger->error("Failed to parse info file `$infoURI'");
            }

            if (!$infoHash->{ID} || $infoHash->{ID} !~ /^\d+$/ || !$infoHash->{ACT}) {
              $logger->error("Incorrect content in info file `$infoURI'");
              # TODO report the info the server
            } else {
              $storage->{byId}{$infoHash->{ID}} = $infoHash;
              foreach (keys %$paramHash) {
                $storage->{byId}{$infoHash->{ID}}{$_} = $paramHash->{$_};
              }

              $logger->debug("New download added in the queue. Info is `$infoURI'");
            }


        }
    }

    1;
}

sub longRun {

    my $params = shift;

    my $prologresp = $params->{prologresp};
    my $config = $params->{config};
    my $logger = $params->{logger};
    my $storage = $params->{storage};
    print "Storage".Dumper($storage);

    my $downloadBaseDir = $config->{vardir}.'/download';
    if (!mkpath($downloadBaseDir)) {
        $logger->error("Failed to create $downloadBaseDir");
    }

    foreach my $orderID (keys %{$storage->{byId}}) {
      my $order = $storage->{byId}->{$orderID};
      $logger->debug("processing ".$orderID);
      next unless $order->{ID} =~ /^\d+$/; # Security

      my $targetDir = $downloadBaseDir.'/'.$orderID;
      if (!-d $targetDir && !mkdir ($targetDir)) {
        $logger->error("Failed to create $targetDir");
      }

      my $baseUrl;
      if ($order->{PROTO} eq 'HTTP') {
        $baseUrl = "http://";
      }

      $baseUrl .= $order->{PACK_LOC};

      if ($order->{PACK_LOC} !~ /\/$/) {
        $baseUrl .= '/';
      }

      $baseUrl .= $orderID;

      foreach my $fragID (1..$order->{FRAGS}) {
        my $frag = $orderID.'-'.$fragID;

        my $remoteFile = $baseUrl.'/'.$frag;
        my $localFile = $targetDir.'/'.$frag;
        my $rc = LWP::Simple::getstore($remoteFile, $localFile.'.part');
        if (is_success($rc) && move($localFile.'.part', $localFile)) {
          $logger->debug($remoteFile.' -> '.$localFile.': success');
        } else {
          $logger->debug($remoteFile.' -> '.$localFile.': failed');
        }
      }

    }
}

1;

