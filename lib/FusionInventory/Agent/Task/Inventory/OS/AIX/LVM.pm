package FusionInventory::Agent::Task::Inventory::OS::AIX::LVM;

use FusionInventory::Agent::Tools;

# LVM for AIX
use strict;

use warnings;

use English qw(-no_match_vars);

sub isInventoryEnabled {
    can_run("lspv");
}

sub _parseLvs {

    my @vs_elem;
    my $vg;
    my $ppsize;
    my $status;
    my $nblv;
    my $typelv;
    my $lvname;
    my $entries = [];

    foreach (`lsvg`) {
        chomp;
        foreach (`lsvg -l $_`) {
            chomp;
            if (/(\S+):.*/) {
                $vg = $1;
            }
            if ( ( !/^LV NAME.*/ )
                && /(\S+) *(\S+) *(\d+) *(\d+) *(\d+) *(\S+) *(\S+)/ )
            {
                $vs_elem[0] = $vg . "/" . $1;
                $typelv     = $2;
                $vs_elem[6] = 0;
                $vs_elem[5] = $3;
                $status     = "Type " . $2 . " ,PV: " . $5;
                $lvname     = $1;
                foreach (`lslv $1`) {
                    if (/.*PP SIZE:\s+(\d+) .*/) {
                        $ppsize = $1;
                    }
                    if (/LV IDENTIFIER:      (\S+)/) {
                        $vs_elem[7] = $1;
                    }
                }
#                print(  $lvname. " "
#                      . $vg . " "
#                      . $status . " "
#                      . $vs_elem[5] . " "
#                      . $vs_elem[7] . " "
#                      . $vs_elem[5]
#                      . "\n" );
                push @$entries,
                  {
                    LV_NAME   => $lvname,
                    VG_UUID   => $vg,
                    ATTR      => $status,
                    SIZE      => int( $vs_elem[5] * $ppsize || 0 ),
                    LV_UUID   => $vs_elem[7],
                    SEG_COUNT => $vs_elem[5],
                  };
            }
        }
    }
    return $entries;
}

sub _parsePvs {

    my @vs_elem;
    my $vg;
    my $ppsize;
    my $status;
    my $nblv;
    my $typelv;

    my $entries = [];
    my $pvname  = "";

    foreach (`lspv | cut -f1 -d' '`) {
        chomp;
        $pvname = $_;
        foreach (`lspv $_`) {
            chomp;
            if (/PHYSICAL VOLUME:    (\S+)/) {
                $vs_elem[0] = $1;
            }
            if (/FREE PPs:           (\d+) .*/) {
                $vs_elem[5] = $1;
            }
            if (/TOTAL PPs:          (\d+) .*/) {
                $vs_elem[4] = $1;
            }
            if (/VOLUME GROUP:     (\S+)/) {
                $vg = $1;
            }
            if (/PP SIZE:            (\d+) .*/) {
                $ppsize = $1;
            }
            if (/PV IDENTIFIER:      (\S+)/) {
                $vs_elem[6] = $1;
            }
        }
        push @$entries,
          {
            DEVICE      => "/dev/" . $pvname,
            PV_NAME     => $pvname,
            FORMAT      => "AIX PV " . $vs_elem[0],
            ATTR        => "VG " . $vg,
            SIZE        => $vs_elem[4] * $ppsize,
            FREE        => $vs_elem[5] * $ppsize,
            PV_UUID     => $vs_elem[6],
            PV_PE_COUNT => $vs_elem[4],
            PE_SIZE     => $ppsize,
          }

    }

    return $entries;
}

sub _parseVgs {

    my $entries = [];
    my @vs_elem;
    my $vg;
    my $ppsize;
    my $status;
    my $nblv;
    my $typelv;
    my $nbpv;

    foreach (`lsvg`) {
        chomp;
        $vg = $_;
        foreach (`lsvg $_`) {
            chomp;
            if (/VOLUME GROUP:       (\S+) .* /) {
                $vs_elem[0] = $1;
            }
            if (/TOTAL PPs:      (\d+) .*/) {
                $vs_elem[5] = $1;
            }
            if (/FREE PPs:       (\d+) .*/) {
                $vs_elem[6] = $1;
            }
            if (/VG IDENTIFIER:  (\S+)/) {
                $vs_elem[7] = $1;
            }
            if (/PP SIZE:        (\d+) .*/) {
                $ppsize = $1;
            }
            if (/LVs:                (\d+) .*/) {
                $nblv = $1;
            }
            if (/ACTIVE PVs:\s+(\d+) .*/) {
                $nbpv = $1;
            }

        }

        push @$entries,
          {
            VG_NAME        => $vg,
            PV_COUNT       => $nbpv,
            LV_COUNT       => $nblv,
            ATTR           => "",
            SIZE           => $vs_elem[5],
            FREE           => $vs_elem[6],
            VG_UUID        => $vs_elem[7],
            VG_EXTENT_SIZE => $ppsize,
          };

    }

    return $entries;
}

sub doInventory {
    my $params    = shift;
    my $inventory = $params->{inventory};
    my $pvs       = _parsePvs();
    $inventory->addPhysicalVolume($_) foreach (@$pvs);
    my $lvs = _parseLvs();
    inventory->addLogicalVolume($_) foreach (@$lvs);
    my $vgs = _parseVgs();
    $inventory->addVolumeGroup($_) foreach (@$vgs);

}

1;
