package Ocsinventory::Agent::Backend::OS::MacOS::CPU;
use strict;

sub check {
    return(undef) unless -r '/usr/sbin/system_profiler';
    return(undef) unless can_load("Mac::SysProfile");
    return 1;
}

sub run {
    my $params = shift;
    my $inventory = $params->{inventory};

    # create sysprofile obj. Return undef unless we get a return value
    my $pro = Mac::SysProfile->new();
    my $h = $pro->gettype('SPHardwareDataType');
    return(undef) unless(ref($h) eq 'HASH');

    $h = $h->{'Hardware Overview'};

    ######### CPU
    my $processort  = $h->{'Processor Name'} | $h->{'CPU Type'}; # 10.5 || 10.4
    my $processorn  = $h->{'Number Of Processors'} || $h->{'Number Of CPUs'};
    my $processors  = $h->{'Processor Speed'} || $h->{'CPU Speed'};

    # lamp spits out an sql error if there is something other than an int (MHZ) here....
    if($processors =~ /GHz$/){
            $processors =~ s/ GHz//;
            $processors = ($processors * 1000);
    }
    if($processors =~ /MHz$/){
            $processors =~ s/ MHz//;
    }

    ### mem convert it to meg's if it comes back in gig's
    my $mem = $h->{'Memory'};
    if($mem =~ /GB$/){
        $mem =~ s/\sGB$//;
        $mem = ($mem * 1024);
    }
    if($mem =~ /MB$/){
	$mem =~ s/\sMB$//;
    }


    $inventory->setHardware({
        PROCESSORT  => $processort,
        PROCESSORN  => $processorn,
        PROCESSORS  => $processors,
        MEMORY      => $mem,
    });
}

1;
