package FusionInventory::Agent::Tools::Screen;

# Contains code from monitor-edid:
# URL: http://svn.mandriva.com/cgi-bin/viewvc.cgi/soft/monitor-edid
# Copyright: 2005 Mandriva
# License: GPLv2+

use strict;
use warnings;
use base 'Exporter';

use English qw(-no_match_vars);

our @EXPORT = qw(
     parseEdid
     checkParsedEdid
     getManufacturerFromCode
);

my @CVT_ratios = qw(5/4 4/3 3/2 16/10 15/9 16/9);
my @known_ratios = @CVT_ratios;

my @edid_info = _group_by2(
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
    manufacturer_name => [ _group_by2(
        1 => '',
        5 => '1',
        5 => '2',
        5 => '3',
    ) ],

    video_input_definition => [ _group_by2(
        1 => 'digital',
        1 => 'separate_sync',
        1 => 'composite_sync',
        1 => 'sync_on_green',
        2 => '',
        2 => 'voltage_level',
    ) ],

    feature_support => [ _group_by2(
        1 => 'DPMS_standby',
        1 => 'DPMS_suspend',
        1 => 'DPMS_active_off',        
        1 => 'rgb',

        1 => '',
        1 => 'sRGB_compliance',
        1 => 'has_preferred_timing',
        1 => 'GTF_compliance',
    ) ],

    established_timings => [ _group_by2(
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

    detailed_timing => [ _group_by2(
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

    standard_timing => [ _group_by2(
        8 => 'X',
        2 => 'aspect',
        6 => 'vfreq',
    ) ],

    monitor_range => [ _group_by2(
        8 => 'vertical_min',
        8 => 'vertical_max',
        8 => 'horizontal_min',
        8 => 'horizontal_max',
        8 => 'pixel_clock_max',
    ) ],

    # http://www.spwg.org/salisbury_march_19_2002.pdf
    # for the glossary: http://www.vesa.org/Public/PSWG/PSWG15v1.pdf
    manufacturer_specified_range_timing => [ _group_by2(
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

sub _get_many_bits {
    my ($s, $field_name) = @_;
    my @bits = split('', unpack('B*', $s));
    my %h;
    foreach (@{$subfields{$field_name}}) {
        my ($size, $field) = @$_;
        my @l = ('0' x (8 - $size), splice(@bits, 0, $size));
        $h{$field} = unpack("C", pack('B*', join('', @l))) if $field && $field !~ /^_/;
    }

    return \%h;
}

sub checkParsedEdid {
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

    return '';
}

sub parseEdid {
    my ($raw_edid) = @_;

    no warnings 'uninitialized'; ## no critic (ProhibitNoWarnings)

    my %edid;
    my @vals = unpack(join('', map { $_->[0] } @edid_info), $raw_edid);
    my $i;
    foreach (@edid_info) {
        my ($field, $v) = ($_->[1], $vals[$i++]);

        if ($field eq 'year') {
            $v += 1990;
        } elsif ($field eq 'manufacturer_name') {
            my $h = _get_many_bits($v, 'manufacturer_name');
            $v = join('', map { chr(ord('A') + $h->{$_} - 1) } 1 .. 3);
        } elsif ($field eq 'video_input_definition') {
            $v = _get_many_bits($v, 'video_input_definition');
        } elsif ($field eq 'feature_support') {
            $v = _get_many_bits($v, 'feature_support');
        } elsif ($field eq 'established_timings') {
            my $h = _get_many_bits($v, 'established_timings');
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
                my $h = _get_many_bits($_, 'standard_timing');
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
                    my $h = _get_many_bits($vv, 'detailed_timing');
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
                        $edid{monitor_range} = _get_many_bits($vv, 'monitor_range');
                        if ($edid{monitor_range}{pixel_clock_max} == 0xff) {
                            delete $edid{monitor_range}{pixel_clock_max};
                        } else {
                            $edid{monitor_range}{pixel_clock_max} *= 10; #- to have it in MHz
                        }
                    } elsif ($flag == 0xf) {
                        my $range = _get_many_bits($vv, 'manufacturer_specified_range_timing');

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
                                $range->{'horizontal_' . ($m eq 'min' ? 'max' : 'min')} = _round($hfreq);
                                $range->{'vertical_' . ($m eq 'min' ? 'max' : 'min')} = _round($vfreq);
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
        $edid{ratio_name} = _ratio_name($edid{max_size_horizontal}, $edid{max_size_vertical}, 'cm');
        $edid{ratio_precision} = 'cm';
    }

    foreach my $h (@{$edid{detailed_timings}}) {
        my $horizontal_total = $h->{horizontal_active} + $h->{horizontal_blanking};
        my $vertical_total = $h->{vertical_active} + $h->{vertical_blanking};

        $h->{ModeLine_comment} = sprintf qq(# Monitor preferred modeline (%.1f Hz vsync, %.1f kHz hsync, ratio %s)),
            $h->{pixel_clock} / $horizontal_total / $vertical_total * 1000 * 1000,
            $h->{pixel_clock} / $horizontal_total * 1000,
            _nearest_ratio($h->{horizontal_active} / $h->{vertical_active}, 0.01) || sprintf("%.2f", $h->{horizontal_active} / $h->{vertical_active});

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
            $edid{ratio_name} = _ratio_name($in_cm{horizontal}, $in_cm{vertical}, 'mm');
            $edid{ratio_precision} = 'mm';
        }

        if ($edid{ratio_precision}) {
            my $ratio = abs(
                $edid{ratio} -
                $h->{horizontal_active} / $h->{vertical_active}
            );
            my $factor = $edid{ratio_precision} eq 'mm' ? 0.02 : 0.2;
            $h->{bad_ratio} = 1 if $ratio > $factor;
        }
    }

    $edid{diagonal_size} = sqrt(_sqr($edid{max_size_horizontal}) + 
            _sqr($edid{max_size_vertical})) / 2.54;

    return \%edid;
}

sub _nearest_ratio {
    my ($ratio, $max_error) = @_;
    my @sorted = 
        sort { $a->[1] <=> $b->[1] }
    map { 
        my $error = abs($ratio - eval($_)); ## no critic
        $error > $max_error ? () : [ $_, $error ];
    } @known_ratios;

    return $sorted[0][0];
}

sub _ratio_name {
    my ($horizontal, $vertical, $precision) = @_;

    if ($precision eq 'mm') {
        _nearest_ratio($horizontal / $vertical, 0.1);
    } else {
        my $error = 0.5;
        my $ratio1 = _nearest_ratio(($horizontal + $error) / ($vertical - $error), 0.2);
        my $ratio2 = _nearest_ratio(($horizontal - $error) / ($vertical + $error), 0.2);
        $ratio1 && $ratio2 or return;
        if ($ratio1 eq $ratio2) {
            return $ratio1;
        } else {
            my $ratio = _nearest_ratio($horizontal / $vertical, 0.2);
            return join(' or ', $ratio, $ratio eq $ratio1 ? $ratio2 : $ratio1);
        }
    }
}

sub getManufacturerFromCode {
    my ($code) = @_;
    my $h = {
        "ACR" => "Acer America Corp.",
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
        "EPI" => "Envision Peripherals, Inc.",
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
        "LEN" => "Lenovo",
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
        "___" => "Targa",
        "BNQ" => "BenQ Corporation",
        "LPL" => "LG Philips",
        "PCK" => "Daewoo",
        "NVD" => "Nvidia", #Nvidia
        "HIQ" => "Hyundai ImageQuest",
        "BMM" => "BMM",
        "AMW" => "AMW",
        "IFS" => "InFocus",
        "BOE" => "BOE Display Technology",
        "IQT" => "Hyundai",
        "HSD" => "Hannspree Inc"


    };

    return $h->{$code} if (exists ($h->{$code}) && $h->{$code});
    return $code;
}

sub _sqr { $_[0] * $_[0] }
sub _round { int($_[0] + 0.5) }
sub _group_by2 {
    my @l;
    foreach (my $i = 0; $i < @_; $i += 2) {
        push @l, [ $_[$i], $_[$i+1] ];
    }
    return @l;
}

1;
__END__

=head1 NAME

FusionInventory::Agent::Tools::Screen - OS-independant screen functions

=head1 DESCRIPTION

This module provides some OS-independant screen functions.

=head1 FUNCTIONS

=head2 parseEdid($edid)

=head2 checkParsedEdid($edid)

=head2 getManufacturerFromCode($code)
