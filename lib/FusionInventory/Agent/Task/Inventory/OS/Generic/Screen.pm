package FusionInventory::Agent::Task::Inventory::OS::Generic::Screen;
#     Copyright (C) 2005 Mandriva
#     Copyright (C) 2007 Gonéri Le Bouder <goneri@rulezlan.org> 
#     This program is free software; you can redistribute it and/or modify
#     it under the terms of the GNU General Public License as published by
#     the Free Software Foundation; either version 2 of the License, or
#     (at your option) any later version.

#     This program is distributed in the hope that it will be useful,
#     but WITHOUT ANY WARRANTY; without even the implied warranty of
#     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#     GNU General Public License for more details.

#     You should have received a copy of the GNU General Public License
#     along with this program; if not, write to the Free Software
#     Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
#
# Some part come from Mandriva's (great) monitor-edid
# http://svn.mandriva.com/cgi-bin/viewvc.cgi/soft/monitor-edid/trunk/
#
use strict;
use warnings;

use English qw(-no_match_vars);

sub isInventoryEnabled {

    return
        $OSNAME eq 'MSWin32'                  ||
        can_run("monitor-get-edid-using-vbe") ||
        can_run("monitor-get-edid")           ||
        can_run("get-edid");
}

sub getScreens {
    my @raw_edid;


    if ($OSNAME eq 'MSWin32') {
        eval {
            require FusionInventory::Agent::Task::Inventory::OS::Win32;
            require Win32::TieRegistry;
            Win32::TieRegistry->import(
                Access      => "KEY_READ",
                Delimiter   => "/",
                ArrayValues => 0
            );
        };
        if ($EVAL_ERROR) {
            print "Failed to load Win32::OLE and Win32::TieRegistry\n";
            return;
        }

        use constant wbemFlagReturnImmediately => 0x10;
        use constant wbemFlagForwardOnly => 0x20;

        my $objWMIService = Win32::OLE->GetObject("winmgmts:\\\\.\\root\\CIMV2") or die "WMI connection failed.\n";
        my $colItems = $objWMIService->ExecQuery("SELECT * FROM Win32_DesktopMonitor", "WQL",
                wbemFlagReturnImmediately | wbemFlagForwardOnly);

        foreach my $objItem (getWmiProperties('Win32_DesktopMonitor',
                    qw/
                    Caption
                    PNPDeviceID
                    /)) {

            next unless $objItem->{"PNPDeviceID"};
            my $name = $objItem->{"Caption"};

            my $a= $Win32::TieRegistry::Registry->Open( "LMachine", {Access=>"KEY_READ",Delimiter=>"/"} )
                or  die "Can't open HKEY_LOCAL_MACHINE key: EXTENDED_OS_ERROR\n";

            my $edid = $a->{'SYSTEM/CurrentControlSet/Enum/'.$objItem->{"PNPDeviceID"}.'/Device Parameters/EDID'}."\n";
            $edid =~ s/^\s+$//;

            push @raw_edid, { name => $name, edid => $edid };
        }

    } else {

# Mandriva
        my $raw_edid = `monitor-get-edid-using-vbe 2>/dev/null`;

# Since monitor-edid 1.15, it's possible to retrieve EDID information
# through DVI link but we need to use monitor-get-edid
        if (!$raw_edid) {
            $raw_edid = `monitor-get-edid 2>/dev/null`;
        }

        if (!$raw_edid) {
            foreach (1..5) { # Sometime get-edid return an empty string...
                $raw_edid = `get-edid 2>/dev/null`;
                last if (length($raw_edid) == 128 || length($raw_edid) == 256);
            }
        }
        return unless (length($raw_edid) == 128 || length($raw_edid) == 256);

        push @raw_edid, { edid => $raw_edid };
    }

    return @raw_edid;
}

my @CVT_ratios = qw(5/4 4/3 3/2 16/10 15/9 16/9);
my @known_ratios = @CVT_ratios;

my @edid_info = group_by2(
    a8 => '_header',
    a2  => 'manufacturer_name',

    v => 'product_code',
    V => 'serial_number',
    C => 'week',
    C => 'year',
    C => 'edid_version',
    C => 'edid_revision',
    a => 'video_input_definition',

    C => 'max_size_horizontal', # in cm, 0 on projectors
    C => 'max_size_vertical', # in cm, 0 on projectors
    C => 'gamma',
    a => 'feature_support',
    a10 => '_color_characteristics',
    a3  => 'established_timings',
    a16 => 'standard_timings',
    a72 => 'monitor_details',

    C => 'extension_flag',
    C => 'checksum',
);

my %subfields = (
    manufacturer_name => [ group_by2(
        1 => '',
        5 => '1',
        5 => '2',
        5 => '3',
    ) ],

    video_input_definition => [ group_by2(
        1 => 'digital',
        1 => 'separate_sync',
        1 => 'composite_sync',
        1 => 'sync_on_green',
        2 => '',
        2 => 'voltage_level',
    ) ],

    feature_support => [ group_by2(
        1 => 'DPMS_standby',
        1 => 'DPMS_suspend',
        1 => 'DPMS_active_off',        
        1 => 'rgb',

        1 => '',
        1 => 'sRGB_compliance',
        1 => 'has_preferred_timing',
        1 => 'GTF_compliance',
    ) ],

    established_timings => [ group_by2(
        1 => '720x400_70',
        1 => '720x400_88',
        1 => '640x480_60',
        1 => '640x480_67',
        1 => '640x480_72',
        1 => '640x480_75',
        1 => '800x600_56',
        1 => '800x600_60',
        1 => '800x600_72',
        1 => '800x600_75',
        1 => '832x624_75',
        1 => '1024x768_87i',
        1 => '1024x768_60',
        1 => '1024x768_70',
        1 => '1024x768_75',
        1 => '1280x1024_75',
    ) ],

    detailed_timing => [ group_by2(
        8 => 'horizontal_active',
        8 => 'horizontal_blanking',
        4 => 'horizontal_active_hi',
        4 => 'horizontal_blanking_hi',
        8 => 'vertical_active',
        8 => 'vertical_blanking',
        4 => 'vertical_active_hi',
        4 => 'vertical_blanking_hi',
        8 => 'horizontal_sync_offset',
        8 => 'horizontal_sync_pulse_width',
        4 => 'vertical_sync_offset',
        4 => 'vertical_sync_pulse_width',
        2 => 'horizontal_sync_offset_hi',
        2 => 'horizontal_sync_pulse_width_hi',
        2 => 'vertical_sync_offset_hi',
        2 => 'vertical_sync_pulse_width_hi',
        8 => 'horizontal_image_size', # in mm
        8 => 'vertical_image_size', # in mm
        4 => 'horizontal_image_size_hi',
        4 => 'vertical_image_size_hi',
        8 => 'horizontal_border',
        8 => 'vertical_border',

        1 => 'interlaced',
        2 => 'stereo',      
        2 => 'digital_composite',
        1 => 'horizontal_sync_positive',
        1 => 'vertical_sync_positive',
        1 => '',
    ) ],

    standard_timing => [ group_by2(
        8 => 'X',
        2 => 'aspect',
        6 => 'vfreq',
    ) ],

    monitor_range => [ group_by2(
        8 => 'vertical_min',
        8 => 'vertical_max',
        8 => 'horizontal_min',
        8 => 'horizontal_max',
        8 => 'pixel_clock_max',
    ) ],

    # http://www.spwg.org/salisbury_march_19_2002.pdf
    # for the glossary: http://www.vesa.org/Public/PSWG/PSWG15v1.pdf
    manufacturer_specified_range_timing => [ group_by2(
        8 => 'horizontal_sync_pulse_width_min', # HSPW (Horizontal Sync Pulse Width)
        8 => 'horizontal_sync_pulse_width_max',
        8 => 'horizontal_back_porch_min', # t_hbp
        8 => 'horizontal_back_porch_max',
        8 => 'vertical_sync_pulse_width_min', # VSPW (Vertical Sync Pulse Width)
        8 => 'vertical_sync_pulse_width_max',
        8 => 'vertical_back_porch_min', # t_vbp (Vertical Back Porch)
        8 => 'vertical_back_porch_max',
        8 => 'horizontal_blanking_min', # t_hp (Horizontal Period)
        8 => 'horizontal_blanking_max',
        8 => 'vertical_blanking_min', # t_vp
        8 => 'vertical_blanking_max',
        8 => 'module_revision',
    ) ],
);

sub get_many_bits {
    my ($s, $field_name) = @_;
    my @bits = split('', unpack('B*', $s));
    my %h;
    foreach (@{$subfields{$field_name}}) {
        my ($size, $field) = @$_;
        my @l = ('0' x (8 - $size), splice(@bits, 0, $size));
        $h{$field} = unpack("C", pack('B*', join('', @l))) if $field && $field !~ /^_/;
    }
    \%h;
}

sub check_parsed_edid {
    my ($edid) = @_;

    $edid->{manufacturer_name} ne '@@@' or return 'bad manufacturer_name';
    $edid->{edid_version} != 0xff && $edid->{edid_revision} != 0xff or return 'bad edid_version';

    if ($edid->{monitor_range}) {
        $edid->{monitor_range}{horizontal_min} && 
            $edid->{monitor_range}{horizontal_min} <= $edid->{monitor_range}{horizontal_max} 
        or return 'bad HorizSync';
        $edid->{monitor_range}{vertical_min} &&
            $edid->{monitor_range}{vertical_min} <= $edid->{monitor_range}{vertical_max} 
        or return 'bad VertRefresh';
    }

    '';
}

sub parse_edid {
    my ($raw_edid) = @_;

    my %edid;
    my @vals = unpack(join('', map { $_->[0] } @edid_info), $raw_edid);
    my $i;
    foreach (@edid_info) {
        my ($field, $v) = ($_->[1], $vals[$i++]);

        if ($field eq 'year') {
            $v += 1990;
        } elsif ($field eq 'manufacturer_name') {
            my $h = get_many_bits($v, 'manufacturer_name');
            $v = join('', map { chr(ord('A') + $h->{$_} - 1) } 1 .. 3);
        } elsif ($field eq 'video_input_definition') {
            $v = get_many_bits($v, 'video_input_definition');
        } elsif ($field eq 'feature_support') {
            $v = get_many_bits($v, 'feature_support');
        } elsif ($field eq 'established_timings') {
            my $h = get_many_bits($v, 'established_timings');
            $v = [
                sort { $a->{X} <=> $b->{X} || $a->{vfreq} <=> $b->{vfreq} }
            map { /(\d+)x(\d+)_(\d+)(i?)/ ? { X => $1, Y => $2, vfreq => $3, $4 ? (interlace => 1) : () } : () }
            grep { $h->{$_} } keys %$h ];
        } elsif ($field eq 'standard_timings') {
            my @aspect2ratio = (
                    $edid{edid_version} > 1 || $edid{edid_revision} > 2 ? '16/10' : '1/1',
                    '4/3', '5/4', '16/9',
                    );
            $v = [ map {
                my $h = get_many_bits($_, 'standard_timing');
                $h->{X} = ($h->{X} + 31) * 8;
                if ($_ ne "\x20\x20" && $h->{X} > 256) { # cf VALID_TIMING in Xorg edid.h
                    $h->{vfreq} += 60;
                    if ($h->{ratio} = $aspect2ratio[$h->{aspect}]) {
                        delete $h->{aspect};
                        $h->{Y} = $h->{X} / eval($h->{ratio}); ## no critic
                    }
                    $h;
                } else { () }
            } unpack('a2' x 8, $v) ];
        } elsif ($field eq 'monitor_details') {
            while ($v) {
                (my $pixel_clock, my $vv, $v) = unpack("v a16 a*", $v);

                if ($pixel_clock) {
# detailed timing
                    my $h = get_many_bits($vv, 'detailed_timing');
                    $h->{pixel_clock} = $pixel_clock / 100; # to have it in MHz

                        my %detailed_timing_field_size = map { $_->[1], $_->[0] } @{$subfields{detailed_timing}};
                    foreach my $field (keys %detailed_timing_field_size) {
                        $field =~ s/_hi$// or next;
                        my $hi = delete($h->{$field . '_hi'});
                        $h->{$field} += $hi << $detailed_timing_field_size{$field};
                    }
                    push @{$edid{detailed_timings}}, $h
                        if $h->{horizontal_active} > 0 && $h->{vertical_active} > 0;
                } else {
                    (my $flag, $vv) = unpack("n x a*", $vv);

                    if ($flag == 0xfd) {
# range
                        $edid{monitor_range} = get_many_bits($vv, 'monitor_range');
                        if ($edid{monitor_range}{pixel_clock_max} == 0xff) {
                            delete $edid{monitor_range}{pixel_clock_max};
                        } else {
                            $edid{monitor_range}{pixel_clock_max} *= 10; #- to have it in MHz
                        }
                    } elsif ($flag == 0xf) {
                        my $range = get_many_bits($vv, 'manufacturer_specified_range_timing');

                        my $e = $edid{detailed_timings}[0];
                        my $valid = 1;
                        foreach my $m ('min', 'max') {
                            my %total;
                            foreach my $dir ('horizontal', 'vertical') {
                                $range->{$dir . '_sync_pulse_width_' . $m} *= 2;
                                $range->{$dir . '_back_porch_' . $m} *= 2;
                                $range->{$dir . '_blanking_' . $m} *= 2;
                                if ($e && $e->{$dir . '_active'}) {
                                    $total{$dir} = $e->{$dir . '_active'} + $range->{$dir . '_blanking_' . $m};
                                }
                            }
                            if ($total{horizontal} && $total{vertical}) {
                                my $hfreq = $e->{pixel_clock} * 1000 / $total{horizontal};
                                my $vfreq = $hfreq * 1000 / $total{vertical};
                                $range->{'horizontal_' . ($m eq 'min' ? 'max' : 'min')} = round($hfreq);
                                $range->{'vertical_' . ($m eq 'min' ? 'max' : 'min')} = round($vfreq);
                            } else {
                                $valid = 0;
                            }
                        }
                        $edid{$valid ? 'monitor_range' : 'manufacturer_specified_range_timing'} = $range;

                    } elsif ($flag == 0xfc) {
                        my $prev = $edid{monitor_name};
                        $edid{monitor_name} = ($prev ? "$prev " : '') . unpack('A13', $vv);
                    } elsif ($flag == 0xfe) {
                        push @{$edid{monitor_text}}, unpack('A13', $vv);
                    } elsif ($flag == 0xff) {
                        push @{$edid{serial_number2}}, unpack('A13', $vv);
                    } else {
#warn "parse_edid: unknown flag $flag\n";
                    }
                }
            }
        }

        $edid{$field} = $v if $field && $field !~ /^_/;
    }

    $edid{max_size_precision} = 'cm';
    $edid{EISA_ID} = $edid{manufacturer_name} . sprintf('%04x', $edid{product_code}) if $edid{product_code};

    if ($edid{monitor_range}) {
        $edid{HorizSync} = $edid{monitor_range}{horizontal_min} . '-' . $edid{monitor_range}{horizontal_max};
        $edid{VertRefresh} = $edid{monitor_range}{vertical_min} . '-' . $edid{monitor_range}{vertical_max};
    }

    if ($edid{max_size_vertical}) {
        $edid{ratio} = $edid{max_size_horizontal} / $edid{max_size_vertical};
        $edid{ratio_name} = ratio_name($edid{max_size_horizontal}, $edid{max_size_vertical}, 'cm');
        $edid{ratio_precision} = 'cm';
    }

    foreach my $h (@{$edid{detailed_timings}}) {
        my $horizontal_total = $h->{horizontal_active} + $h->{horizontal_blanking};
        my $vertical_total = $h->{vertical_active} + $h->{vertical_blanking};

        $h->{ModeLine_comment} = sprintf qq(# Monitor preferred modeline (%.1f Hz vsync, %.1f kHz hsync, ratio %s)),
            $h->{pixel_clock} / $horizontal_total / $vertical_total * 1000 * 1000,
            $h->{pixel_clock} / $horizontal_total * 1000,
            nearest_ratio($h->{horizontal_active} / $h->{vertical_active}, 0.01) || sprintf("%.2f", $h->{horizontal_active} / $h->{vertical_active});

        $h->{ModeLine} = sprintf qq("%dx%d" $h->{pixel_clock} %d %d %d %d %d %d %d %d %shsync %svsync),
            $h->{horizontal_active}, $h->{vertical_active},

            $h->{horizontal_active},
            $h->{horizontal_active} + $h->{horizontal_sync_offset}, 
            $h->{horizontal_active} + $h->{horizontal_sync_offset} + $h->{horizontal_sync_pulse_width},
            $horizontal_total,

            $h->{vertical_active},
            $h->{vertical_active} + $h->{vertical_sync_offset}, 
            $h->{vertical_active} + $h->{vertical_sync_offset} + $h->{vertical_sync_pulse_width},
            $vertical_total,

            $h->{horizontal_sync_positive} ? '+' : '-',
            $h->{vertical_sync_positive} ? '+' : '-';

# if the mm size given in the detailed_timing is not far from the cm size
# put it as a more precise cm size
        my %in_cm = map { $_ => $h->{$_ . '_image_size'} / 10 } ('horizontal', 'vertical');
        my ($error) = sort { $b <=> $a } map { abs($edid{'max_size_' . $_} - $in_cm{$_}) } keys %in_cm;
        if ($error <= 0.5) {
            $edid{'max_size_' . $_} = $in_cm{$_} foreach keys %in_cm;
            $edid{max_size_precision} = 'mm';
        }
        if ($error < 1 && $in_cm{vertical}) {
# using it for the ratio
            $edid{ratio} = $in_cm{horizontal} / $in_cm{vertical};
            $edid{ratio_name} = ratio_name($in_cm{horizontal}, $in_cm{vertical}, 'mm');
            $edid{ratio_precision} = 'mm';
        }

        $h->{bad_ratio} = 1 if abs($edid{ratio} - $h->{horizontal_active} / $h->{vertical_active}) > ($edid{ratio_precision} eq 'mm' ? 0.02 : 0.2);
    }

    $edid{diagonal_size} = sqrt(sqr($edid{max_size_horizontal}) + 
            sqr($edid{max_size_vertical})) / 2.54;

    \%edid;
}

sub nearest_ratio {
    my ($ratio, $max_error) = @_;
    my @sorted = 
        sort { $a->[1] <=> $b->[1] }
    map { 
        my $error = abs($ratio - eval($_)); ## no critic
        $error > $max_error ? () : [ $_, $error ];
    } @known_ratios;
    $sorted[0][0];
}

sub ratio_name {
    my ($horizontal, $vertical, $precision) = @_;

    if ($precision eq 'mm') {
        nearest_ratio($horizontal / $vertical, 0.1);
    } else {
        my $error = 0.5;
        my $ratio1 = nearest_ratio(($horizontal + $error) / ($vertical - $error), 0.2);
        my $ratio2 = nearest_ratio(($horizontal - $error) / ($vertical + $error), 0.2);
        $ratio1 && $ratio2 or return;
        if ($ratio1 eq $ratio2) {
            $ratio1;
        } else {
            my $ratio = nearest_ratio($horizontal / $vertical, 0.2);
            join(' or ', $ratio, $ratio eq $ratio1 ? $ratio2 : $ratio1);
        }
    }
}

sub to_MonitorsDB {
    my ($edid) = @_;

    $edid->{monitor_range} && $edid->{EISA_ID} or return;

    my $detailed_timings = $edid->{detailed_timings} || [];
    my @preferred_resolutions = map { 
        join('x', $_->{horizontal_active}, $_->{vertical_active});
    } grep { !$_->{bad_ratio} } @$detailed_timings;

    (my $monitor_name = $edid->{monitor_name}) =~ s/;/,/g;
    my ($raw_vendor, $raw_model) = $edid->{EISA_ID} =~ /(...)(.*)/;
    my ($VendorName, $only_Model) =
        $monitor_name =~ /(\S+)\s(.*)/ ? 
        ($1, $2) :
        ($raw_vendor, $monitor_name || $raw_model);

    join('; ', 
            $VendorName, "$VendorName $only_Model", $edid->{EISA_ID},
            sprintf("%u-%u", $edid->{monitor_range}{horizontal_min}, $edid->{monitor_range}{horizontal_max}),
            sprintf("%u-%u", $edid->{monitor_range}{vertical_min}, $edid->{monitor_range}{vertical_max}),
            @$detailed_timings == 1 ? @preferred_resolutions : (),
        );
}

sub print_edid {
    my ($edid, $verbose) = @_;

    print "Name: $edid->{monitor_name}\n" if $edid->{monitor_name};
    print "EISA ID: $edid->{EISA_ID}\n" if $edid->{EISA_ID};
    printf "Screen size: %.1f cm x %.1f cm (%3.2f inches%s)\n",
           $edid->{max_size_horizontal},
           $edid->{max_size_vertical},
           $edid->{diagonal_size},
           $edid->{ratio_name} ? sprintf(", aspect ratio %s = %.2f", $edid->{ratio_name}, $edid->{ratio}) :
               $edid->{ratio} ? sprintf(", aspect ratio %.2f", $edid->{ratio}) : '';

    print "Gamma: ", $edid->{gamma} / 100 + 1, "\n";
    printf "%s signal\n", $edid->{video_input_definition}{digital} ? 'Digital' : 'Analog';

    if ($verbose) {
        foreach (@{$edid->{established_timings} || []}) {
            print "Standard resolution: $_->{X}x$_->{Y} @ $_->{vfreq} Hz (established timing)\n" if !$_->{interlace};
        }
        foreach (@{$edid->{standard_timings} || []}) {
            print "Standard resolution: $_->{X}x$_->{Y} @ $_->{vfreq} Hz, ratio $_->{ratio}",
                  $edid->{ratio_name} && index($edid->{ratio_name}, $_->{ratio}) == -1 ? ' (!)' : '',
                  "\n";
        }
    }

    if ($edid->{monitor_range}) {
        printf "Max video bandwidth: %u MHz\n", $edid->{monitor_range}{pixel_clock_max} if $edid->{monitor_range}{pixel_clock_max};
        print "\n";
        printf "\tHorizSync %u-%u\n", $edid->{monitor_range}{horizontal_min}, $edid->{monitor_range}{horizontal_max};
        printf "\tVertRefresh %u-%u\n", $edid->{monitor_range}{vertical_min}, $edid->{monitor_range}{vertical_max};
    }

    foreach my $h (@{$edid->{detailed_timings}}) {
        print "\n";
        print "\t", $h->{ModeLine_comment}, $h->{bad_ratio} ? ' (bad ratio)' : '', "\n";
        print "\tModeLine ", $h->{ModeLine}, "\n";	
    }
}

sub _getManifacturerFromCode {
    my $code = shift;
    my $h = {
        "ACT" => "Targa",
        "ADI" => "ADI Corporation http://www.adi.com.tw",
        "AOC" => "AOC International (USA) Ltd.",
        "API" => "Acer America Corp.",
        "APP" => "Apple Computer, Inc.",
        "ART" => "ArtMedia",
        "AST" => "AST Research",
        "AUO" => "AU Optronics",
        "CPL" => "Compal Electronics, Inc. / ALFA",
        "CPQ" => "COMPAQ Computer Corp.",
        "CTX" => "CTX - Chuntex Electronic Co.",
        "DEC" => "Digital Equipment Corporation",
        "DEL" => "Dell Computer Corp.",
        "DPC" => "Delta Electronics, Inc.",
        "DWE" => "Daewoo Telecom Ltd",
        "ECS" => "ELITEGROUP Computer Systems",
        "EIZ" => "EIZO",
        "FCM" => "Funai Electric Company of Taiwan",
        "FUS" => "Fujitsu Siemens",
        "GSM" => "LG Electronics Inc. (GoldStar Technology, Inc.)",
        "GWY" => "Gateway 2000",
        "HEI" => "Hyundai Electronics Industries Co., Ltd.",
        "HIT" => "Hitachi",
        "HSL" => "Hansol Electronics",
        "HTC" => "Hitachi Ltd. / Nissei Sangyo America Ltd.",
        "HWP" => "Hewlett Packard",
        "IBM" => "IBM PC Company",
        "ICL" => "Fujitsu ICL",
        "IVM" => "Idek Iiyama North America, Inc.",
        "KDS" => "KDS USA",
        "KFC" => "KFC Computek",
        "LGD" => "LG Display",
        "LKM" => "ADLAS / AZALEA",
        "LNK" => "LINK Technologies, Inc.",
        "LTN" => "Lite-On",
        "MAG" => "MAG InnoVision",
        "MAX" => "Maxdata Computer GmbH",
        "MEI" => "Panasonic Comm. & Systems Co.",
        "MEL" => "Mitsubishi Electronics",
        "MIR" => "miro Computer Products AG",
        "MTC" => "MITAC",
        "NAN" => "NANAO",
        "NEC" => "NEC Technologies, Inc.",
        "NOK" => "Nokia",
        "OQI" => "OPTIQUEST",
        "PBN" => "Packard Bell",
        "PGS" => "Princeton Graphic Systems",
        "PHL" => "Philips Consumer Electronics Co.",
        "REL" => "Relisys",
        "SAM" => "Samsung",
        "SEC" => "Seiko Epson Corporation",
        "SMI" => "Smile",
        "SMC" => "Samtron",
        "SNI" => "Siemens Nixdorf",
        "SNY" => "Sony Corporation",
        "SPT" => "Sceptre",
        "SRC" => "Shamrock Technology",
        "STN" => "Samtron",
        "STP" => "Sceptre",
        "TAT" => "Tatung Co. of America, Inc.",
        "TRL" => "Royal Information Company",
        "TSB" => "Toshiba, Inc.",
        "UNM" => "Unisys Corporation",
        "VSC" => "ViewSonic Corporation",
        "WTC" => "Wen Technology",
        "ZCM" => "Zenith Data Systems",
        "___" => "Targa"
    };

    return $h->{$code} if (exists ($h->{$code}) && $h->{$code});
    return "Unknown manufacturer code ".$code;
}

sub sqr { $_[0] * $_[0] }
sub round { int($_[0] + 0.5) }
sub group_by2 {
    my @l;
    for (my $i = 0; $i < @_; $i += 2) {
        push @l, [ $_[$i], $_[$i+1] ];
    }
    @l;
}


sub doInventory {
    my $params = shift;
    my $inventory = $params->{inventory};
    my $logger = $params->{logger};

    my $raw_perl = 1;
    my $verbose;
    my $MonitorsDB;

    my @screens = getScreens();

    return unless @screens;

    foreach my $screen (@screens) {
        my $name = $screen->{name};

        my $caption = $name;
        my $description;
        my $manufacturer;
        my $serial;
        my $base64;
        my $uuencode;

        if ($screen->{edid}) {
            my $edid = parse_edid($screen->{edid});
            if (my $err = check_parsed_edid($edid)) {
                $logger->debug("check failed: bad edid: $err");
            } else {

                $caption = $edid->{monitor_name};
                $description = $edid->{week}."/".$edid->{year};
                $manufacturer = _getManifacturerFromCode($edid->{manufacturer_name});
                $serial = $edid->{serial_number2}[0];
            }

            if (can_load("MIME::Base64")) {
                $base64 = MIME::Base64::encode_base64($screen->{edid});
            }
            if (can_run("uuencode")) {
                $uuencode = `echo $screen->{edid}|uuencode -`;
                if (!$base64) {
                    $base64 = `echo $screen->{edid}|uuencode -m -`;
                }
            }

        }

        $inventory->addMonitor ({
            BASE64 => $base64,
            CAPTION => $caption,
            DESCRIPTION => $description,
            MANUFACTURER => $manufacturer,
            SERIAL => $serial,
            UUENCODE => $uuencode,
        });
    }
}
1;

