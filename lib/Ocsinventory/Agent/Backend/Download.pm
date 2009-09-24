package Ocsinventory::Agent::Backend::Download;

use strict;
use warnings;

use XML::Simple;
use File::Copy;
use LWP::Simple;
use File::Path;


use Data::Dumper;


sub download {
    my $params = shift;

    use Data::Dumper;
    print Dumper($params);
    my $config = $params->{config};
    my $logger = $params->{logger};
    my $orderId = $params->{orderId};
    my $storage = $params->{storage};

    my $downloadBaseDir = $config->{vardir}.'/download';


    my $order = $storage->{byId}->{$orderId};
    $logger->fault("order not correctly initialised") unless $order;
    $logger->fault("config not correctly initialised") unless $config;
    
    $logger->debug("processing ".$orderId);

    my $targetDir = $downloadBaseDir.'/'.$orderId;
    if (!-d $targetDir && !mkdir ($targetDir)) {
        $logger->error("Failed to create $targetDir");
    }

    my $baseUrl = ($order->{PROTO} =~ /^HTTP$/i)?"http://":"";
    $baseUrl .= $order->{PACK_LOC};
    $baseUrl .= '/' if $order->{PACK_LOC} !~ /\/$/;
    $baseUrl .= $orderId;

    $order->{CURRENT_FRAG} = 1 unless $order->{CURRENT_FRAG};
    # TODO randomise the order
    foreach my $fragID ($order->{CURRENT_FRAG}..$order->{FRAGS}) {
        my $frag = $orderId.'-'.$fragID;

        my $remoteFile = $baseUrl.'/'.$frag;
        my $localFile = $targetDir.'/'.$frag;
        my $rc = LWP::Simple::getstore($remoteFile, $localFile.'.part');
        if (is_success($rc) && move($localFile.'.part', $localFile)) {
            # TODO to a md5sum/sha256 check here
            $logger->debug($remoteFile.' -> '.$localFile.': success');

        } else {
            $logger->debug($remoteFile.' -> '.$localFile.': failed');
            unlink ($localFile.'.part');
            unlink ($localFile);
            return;
        }
    }

}


sub unpackAndUncompress {



}


sub check {
    my $params = shift;

    my $prologresp = $params->{prologresp};
    my $config = $params->{config};
    my $logger = $params->{logger};
    my $storage = $params->{storage};
    print "Storage".Dumper($storage);

    if (!$storage) {
        $storage->{config} = {};
        $storage->{byId} = {};
        $storage->{byPriority} = [
        0  => {},
        1  => {},
        2  => {},
        4  => {},
        5  => {},
        5  => {},
        6  => {},
        7  => {},
        8  => {},
        9  => {},
        10 => {},
        ];
    }

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



    print "GOGO\n";

    # The XML is ill formated and we have to run a loop to retriev
    # the different keys
    foreach my $paramHash (@$conf) {
        if ($paramHash->{TYPE} eq 'CONF') {
            # Save the config sent during the PROLOG
            $storage->{config} = $conf->[0];
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

            if (
                !$infoHash->{ID}
                ||
                $infoHash->{ID} !~ /^\d+$/
                ||
                !$infoHash->{ACT}
                ||
                $infoHash->{PRI} !~ /^\d+$/
            ) {
                $logger->error("Incorrect content in info file `$infoURI'");
                # TODO report the info the server
            } else {
                $storage->{byId}{$infoHash->{ID}} = $infoHash;
                foreach (keys %$paramHash) {
                    $storage->{byId}{$infoHash->{ID}}{$_} = $paramHash->{$_};
                }

                $storage->{byPriority}->[$infoHash->{PRI}]->{$infoHash->{ID}} = $storage->{byId}{$infoHash->{ID}};
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
    if (!-f $downloadBaseDir && !mkpath($downloadBaseDir)) {
        $logger->error("Failed to create $downloadBaseDir");
    }

    foreach my $priority (0..10) {
        foreach my $orderId (keys %{$storage->{byPriority}->[$priority]}) {
            print $orderId."\n";
            download({
                    config => $config,
                    logger => $logger,
                    orderId => $orderId,
                    storage => $storage,
                });
        }
    }
}

1;

