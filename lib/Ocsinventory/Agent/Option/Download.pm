###############################################################################
## OCSINVENTORY-NG 
## Copyleft Pascal DANEK 2005
## Web : http://ocsinventory.sourceforge.net
##
## This code is open source and may be copied and modified as long as the source
## code is always made freely available.
## Please refer to the General Public Licence http://www.gnu.org/ or Licence.txt
################################################################################
# Function by hook:
# -download_prolog_reader, download_message, download
# -download_inventory_handler
# -download_end_handler, begin, done, clean, finish, period, download, execute,
#   check_signature and build_package
package Ocsinventory::Agent::Option::Download;

use strict;

require Exporter;

our @ISA = qw /Exporter/;

our @EXPORT = qw/
	download_inventory_handler
	download_prolog_reader
	download_end_handler
/;

use Fcntl qw/:flock/;
use XML::Simple;
use LWP::UserAgent;
use Compress::Zlib;
use Ocsinventory::Agent::Common qw/_uncompress _get_path _already_in_array/;
use Digest::MD5;
use File::Path;
use Socket;
use Net::SSLeay qw(die_now die_if_ssl_error);

# Can be missing. By default, we use MD5
# You have to install it if you want to use SHA1 digest
eval{ require Digest::SHA1 };
use constant HTTPS_PORT => '443';
# Time to wait between scheduler periods, scheduling cycles and fragments downloads
use constant FRAG_LATENCY_DEFAULT 	=> 10;
use constant PERIOD_LATENCY_DEFAULT 	=> 0;
use constant CYCLE_LATENCY_DEFAULT 	=> 10;
use constant MAX_ERROR_COUNT		=> 30;
# Number of loops for one period
use constant PERIOD_LENGTH_DEFAULT 	=> 10;
# Errors
use constant CODE_SUCCESS 	=> 'SUCCESS';
use constant ERR_BAD_ID 	=> 'ERR_BAD_ID';
use constant ERR_DOWNLOAD_INFO 	=> 'ERR_DOWNLOAD_INFO';
use constant ERR_BAD_DIGEST 	=> 'ERR_BAD_DIGEST';
use constant ERR_DOWNLOAD_PACK 	=> 'ERR_DOWNLOAD_PACK';
use constant ERR_BUILD 		=> 'ERR_BUILD';
use constant ERR_EXECUTE 	=> 'ERR_EXECUTE';
use constant ERR_CLEAN 		=> 'ERR_CLEAN';
use constant ERR_TIMEOUT	=> 'ERR_TIMEOUT';
use constant ERR_ALREADY_SETUP  => 'ERR_ALREADY_SETUP';

my @packages;
my $current_context;
my $ua;
my $config;
my $error;
my $debug;

# Read prolog response
sub download_prolog_reader{
	$current_context = shift;
	my $prolog = shift;
	
	$debug = $::debug;
	
	&log($prolog);
	
	$prolog = XML::Simple::XMLin( $prolog, ForceArray => ['OPTION', 'PARAM']);
	my $option;
	# Create working directory
	my $opt_dir = $current_context->{'OCS_AGENT_INSTALL_PATH'}.'/download';
	mkdir($opt_dir) unless -d $opt_dir;
	
	# We create a file to tell to download process that we are running
	open SUSPEND, ">$opt_dir/suspend";
	close(SUSPEND);
	
	# Create history file if needed
	unless(-e "$opt_dir/history"){
		open HISTORY, ">$opt_dir/history" or die("Cannot create history file: $!");
		close(HISTORY);
	}
	
	# Create lock file if needed
	unless(-e "$opt_dir/lock"){
		open LOCK, ">$opt_dir/lock" or die("Cannot create lock file: $!");
		close(LOCK);
	}
	
	# Retrieve our options
	for $option (@{$prolog->{OPTION}}){
		if( $option->{NAME} =~/download/i){
			for ( @{ $option->{PARAM} } ) {
				# Type of param
				if($_->{'TYPE'} eq 'CONF'){
					# Writing configuration
					open FH, ">$opt_dir/config" or die("Cannot open/create
                        config file ($opt_dir/config)");
					if(flock(FH, LOCK_EX)){
						&log("Writing config file.");
						print FH XMLout($_, RootName => 'CONF');
						close(FH);
						$config = $_;
					}else{
						&log("Cannot lock config file !!");
						close(FH);
						return 0;
					}
					
					# Apply config
					# ON ?
					if($_->{'ON'} == '0'){
						&log("Download is off.");
						open LOCK, "$opt_dir/lock" or die("Cannot open lock file: $!");
						if(flock(LOCK, LOCK_EX|LOCK_NB)){
							close(LOCK);
							unlink("$opt_dir/suspend");
							return 0;
						}else{
							&log("Try to kill current download process...");
							my $pid = <LOCK>;
							close(LOCK);
							&log("Sending USR1 to $pid...");
							if(kill("USR1", $pid)){
								&log("Success.");
							}else{
								&log("Failed.");
							}
							return 0;
						}
					}
				# Maybe a new package to download
				}elsif($_->{'TYPE'} eq 'PACK'){
					push @packages, {
						'PACK_LOC' => $_->{'PACK_LOC'},
						'INFO_LOC' => $_->{'INFO_LOC'},
						'ID' => $_->{'ID'},
						'CERT_PATH' => $_->{'CERT_PATH'},
						'CERT_FILE' => $_->{'CERT_FILE'}
					};
				}
			}
		}
	}
		
	# We are now in download child
	# Connect to server
	$ua = LWP::UserAgent->new();
	$ua->agent('OCS-NG_linux_client_v'.$current_context->{'OCS_AGENT_VERSION'});
	$ua->credentials( $current_context->{'OCS_AGENT_SERVER_NAME'}, 
		$current_context->{'OCS_AGENT_AUTH_REALM'}, 
		$current_context->{'OCS_AGENT_AUTH_USER'} => $current_context->{'OCS_AGENT_AUTH_PWD'} 
	);
	
	# Check history file
	unless(open HISTORY, "$opt_dir/history") {
		flock(HISTORY, LOCK_EX);
		unlink("$opt_dir/suspend");
		&log("Cannot read history file: $!");
		return 1;
	}
	
	chomp(my @done = <HISTORY>);
	close(HISTORY);
		
	# Package is maybe already handled
	for(@packages){
		my $dir = $opt_dir."/".$_->{'ID'};
		my $fileid = $_->{'ID'};
		my $infofile = 'info';
		my $location = $_->{'INFO_LOC'};
		
		if(_already_in_array($fileid, @done)){
			&log("Will not download $fileid. (already in history file)");
			&download_message({ 'ID' => $fileid }, ERR_ALREADY_SETUP);
			next;
		}
		
		# Looking for packages status
		unless(-d $dir){
			&log("Making working directory for $fileid.");
			mkdir($dir) or die("Cannot create $fileid directory: $!");
			open FH, ">$dir/since" or die("Cannot create $fileid since file: $!");;
			print FH time();
			close(FH);
		}
		
		# Retrieve and writing info file if needed
		unless(-f "$dir/$infofile"){
			# Special value INSTALL_PATH
			$_->{CERT_PATH} =~ s/INSTALL_PATH/$current_context->{OCS_AGENT_INSTALL_PATH}/;
			$_->{CERT_FILE} =~ s/INSTALL_PATH/$current_context->{OCS_AGENT_INSTALL_PATH}/;
		
            if (!-f $_->{CERT_FILE}) {
                &log("No certificat found in ".$_->{CERT_FILE});
            }

			# Getting info file
			&log("Retrieving info file for $fileid");
			
			my ($ctx, $ssl, $ra);
			eval {
				$| = 1;
				&log('Initialize ssl layer...');
				
				# Initialize openssl
				if ( -e '/dev/urandom') {
					$Net::SSLeay::random_device = '/dev/urandom';
					$Net::SSLeay::how_random = 512;
				}
				else {
					srand (time ^ $$ ^ unpack "%L*", `ps wwaxl | gzip`);
					$ENV{RND_SEED} = rand 4294967296;
				}
				
				Net::SSLeay::randomize();
				Net::SSLeay::load_error_strings();
				Net::SSLeay::ERR_load_crypto_strings();
				Net::SSLeay::SSLeay_add_ssl_algorithms();
				
				#Create ctx object
				$ctx = Net::SSLeay::CTX_new() or die_now("Failed to create SSL_CTX $!");
				Net::SSLeay::CTX_load_verify_locations( $ctx, $_->{CERT_FILE},  $_->{CERT_PATH} )
				  or die_now("CTX load verify loc: $!");
				# Tell to SSLeay where to find AC file (or dir)
				Net::SSLeay::CTX_set_verify($ctx, &Net::SSLeay::VERIFY_PEER, \&ssl_verify_callback);
				die_if_ssl_error('callback: ctx set verify');
				
				my($server_name,$server_port,$server_dir);
				
				if($_->{INFO_LOC}=~ /^([^:]+):(\d{1,5})(.*)$/){
					$server_name = $1;
					$server_port = $2;
					$server_dir = $3;
				}elsif($_->{INFO_LOC}=~ /^([^\/]+)(.*)$/){
					$server_name = $1;
					$server_dir = $2;	
					$server_port = HTTPS_PORT;
				}
				$server_dir .= '/' unless $server_dir=~/\/$/;
				
				$server_name = gethostbyname ($server_name) or die;
				my $dest_serv_params  = pack ('S n a4 x8', &AF_INET, $server_port, $server_name );
				
				# Connect to server
				&log("Connect to server: $_->{INFO_LOC}...");
				socket  (S, &AF_INET, &SOCK_STREAM, 0) or die "socket: $!";
				connect (S, $dest_serv_params) or die "connect: $!";
				
				# Flush socket
				select  (S); $| = 1; select (STDOUT);
				$ssl = Net::SSLeay::new($ctx) or die_now("Failed to create SSL $!");
				Net::SSLeay::set_fd($ssl, fileno(S));
				
				# SSL handshake
				&log('Starting SSL connection...');
				Net::SSLeay::connect($ssl);
				die_if_ssl_error('callback: ssl connect!');
				
				# Get info file
				my $http_request = "GET /$server_dir".$fileid."/info HTTP/1.0\n\n";
				Net::SSLeay::ssl_write_all($ssl, $http_request);
				shutdown S, 1;
				
				$ra = Net::SSLeay::ssl_read_all($ssl);
				$ra = (split("\r\n\r\n", $ra))[1] or die;
				&log("Info file: $ra");
				
				my $xml = XML::Simple::XMLin( $ra ) or die;
				
				$xml->{PACK_LOC} = $_->{PACK_LOC};
				
				$ra = XML::Simple::XMLout( $xml ) or die;
				
				open FH, ">$dir/info" or die("Cannot open info file: $!");
				print FH $ra;
				close FH;
			};
			if($@){
				download_message({ 'ID' => $fileid }, ERR_DOWNLOAD_INFO);
				&log("Error: SSL hanshake has failed");
				next;	
			}
			else {
				&log("Success. :-)");
			}
			Net::SSLeay::free ($ssl);
			Net::SSLeay::CTX_free ($ctx);
			close S;
			sleep(1);
		}
	}
	unless(unlink("$opt_dir/suspend")){
		&log("Cannot delete suspend file: $!");
		return 1;
	}
	return 0;
}

sub ssl_verify_callback {
	my ($ok, $x509_store_ctx) = @_;
	return $ok; 
}

sub download_inventory_handler{
	# Adding the ocs package ids to softwares
	my $current_context = shift;
	my $inventory = shift;
	my @history;
	# Read download history file
	if( open PACKAGES, "$current_context->{OCS_AGENT_INSTALL_PATH}/download/history" ){
		flock(PACKAGES, LOCK_SH);
		while(<PACKAGES>){
			chomp( $_ );
			push @history, { ID => $_ };
		}
	}
	close(PACKAGES);
	# Add it to inventory (will be handled by Download.pm server module
	push @{ $inventory->{'CONTENT'}->{'DOWNLOAD'}->{'HISTORY'} },{
		'PACKAGE'=> \@history
	};
}

sub download_end_handler{
	# Get global structure
	$current_context = shift;
	my $dir = $current_context->{'OCS_AGENT_INSTALL_PATH'}."/download";
	my $pidfile = $dir."/lock";
	
	return 0 unless -d $dir;
	
	# We have jobs, we do it alone
	my $fork = fork();
	if($fork>0){
		return 0;
	}elsif($fork<0){
		return 1;
	}else{
		$SIG{'USR1'} = sub { 
			print "Exiting on signal...\n";
			&finish();
		};
		# Go into working directory
		chdir($dir) or die("Cannot chdir to working directory...Abort\n");
	}
	
	unless($debug){
		open STDOUT, '>/dev/null' or die("Cannot redirect STDOUT");
		open STDERR, '>/dev/null' or die("Cannot redirect STDERR");
	}
	
	# Maybe an other process is running
	exit(0) if begin($pidfile);
	# Retrieve the packages to download
	opendir DIR, $dir or die("Cannot read working directory: $!");
	
	my $end;
	
	while(1){
		# If agent is running, we wait 
		if (-e "suspend") {
			&log('Found a suspend file... Will wait 10 seconds before retry');
			sleep(10);
			next;
		}
		
		$end = 1;
		undef @packages;
		# Reading configuration
		open FH, "$dir/config" or die("Cannot read config file: $!");
		if(flock(FH, LOCK_SH)){
			$config = XMLin("$dir/config");
			close(FH);
			# If Frag latency is null, download is off
			if($config->{'ON'} eq '0'){
				&log("Option turned off. Exiting.");
				finish();
			}
		}else{
			&log("Cannot read config file :-( . Exiting.");
			close(FH);
			finish();
		}
		
		# Retrieving packages to download and their priority
		while(my $entry = readdir(DIR)){
			next if $entry !~ /^\d+$/;
						
			next unless(-d $entry);
			
			# Clean package if info file does not still exist
			unless(-e "$entry/info"){
				&log("No info file found for $entry!!");
				clean( { 'ID' => $entry } );
				next;
			}
			my $info = XML::Simple::XMLin( "$entry/info" ) or next;
			
			# Check that fileid == directory name
			if($info->{'ID'} ne $entry){	
				&log("ID in info file does not correspond!!");
				clean( { 'ID' => $entry } );
				download_message({ 'ID' => $entry }, ERR_BAD_ID);
				next;
			}
			
			# Manage package timeout
			# Clean package if since timestamp is not present
			unless(-e "$entry/since"){
				&log("No since file found!!");
				clean( { 'ID' => $entry } );
				next;
			}else{
				my $time = time();
				if(open SINCE, "$entry/since"){
					my $since = <SINCE>;
					if($since=~/\d+/){
						if( (($time-$since)/86400) > $config->{TIMEOUT}){
							&log("Timeout Reached for $entry.");
							clean( { 'ID' => $entry } );
							&download_message('ID' => $entry, ERR_TIMEOUT);
							close(SINCE);
							next;
						}else{
							&log("Checking timeout for $entry... OK");
						}
					}else{
						&log("Since data for $entry is incorrect.");
						clean( { 'ID' => $entry } );
						&download_message('ID' => $entry, ERR_TIMEOUT);
						close(SINCE);
						next;
					}
					close(SINCE);
				}else{
					&log("Cannot find since data for $entry.");
					clean( { 'ID' => $entry } );
					&download_message('ID' => $entry, ERR_TIMEOUT);
					next;
				}
			}
			
			# Building task file if needed
			unless( -f "$entry/task" and -f "$entry/task_done" ){
				open FH, ">$entry/task" or die("Cannot create task file for $entry: $!");
				
				my $i;
				my $frags = $info->{'FRAGS'};
				# There are no frags if there is only a command
				if($frags){
					for($i=1;$i<=$frags;$i++){
						print FH "$entry-$i\n";
					}
				};
				close FH;
				# To be sure that task file is fully created
				open FLAG, ">$entry/task_done" or die ("Cannot create task flag file for $entry: $!");
				close(FLAG);
			}
			# Push package XML description
			push @packages, $info;
			$end = 0;
		}
		# Rewind directory
		rewinddir(DIR);
		# Call packages scheduler
		if($end){
			last;
		}else{
			period(\@packages);	
		}
	}
	&log("No more package to download.");
	finish();
}

# Schedule the packages
sub period{
	my $packages = shift;
	my @rt;
	my $i;
	
	@rt = grep {$_->{'PRI'} eq "0"} @$packages;
	
	&log("New period. Nb of cycles: ".
	(defined($config->{'PERIOD_LENGTH'})?$config->{'PERIOD_LENGTH'}:PERIOD_LENGTH_DEFAULT));
	
	for($i=1;$i<=( defined($config->{'PERIOD_LENGTH'})?$config->{'PERIOD_LENGTH'}:PERIOD_LENGTH_DEFAULT);$i++){
		# Highest priority
		if(@rt){
			&log("Managing ".scalar(@rt)." package(s) with absolute priority.");
			for(@rt){
				# If done file found, clean package
				if(-e "$_->{'ID'}/done"){
					&log("done file found!!");
					done($_);
					next;
				}
				download($_);
					&log("Now pausing for a cycle latency => ".(
					defined($config->{'FRAG_LATENCY'})?$config->{'FRAG_LATENCY'}:FRAG_LATENCY_DEFAULT)
					." seconds");
				sleep( defined($config->{'FRAG_LATENCY'})?$config->{'FRAG_LATENCY'}:FRAG_LATENCY_DEFAULT );
			}
			next;
		}
		# Normal priority
		for(@$packages){
			# If done file found, clean package
			if(-e "$_->{'ID'}/done"){
				&log("done file found!!");
				done($_);
				next;
			}
			next if $i % $_->{'PRI'} != 0;
			download($_);
			
			&log("Now pausing for a fragment latency => ".
			(defined( $config->{'FRAG_LATENCY'} )?$config->{'FRAG_LATENCY'}:FRAG_LATENCY_DEFAULT)
			." seconds");
			
			sleep(defined($config->{'FRAG_LATENCY'})?$config->{'FRAG_LATENCY'}:FRAG_LATENCY_DEFAULT);
		}
		
		&log("Now pausing for a cycle latency => ".(
		defined($config->{'CYCLE_LATENCY'})?$config->{'CYCLE_LATENCY'}:CYCLE_LATENCY_DEFAULT)
		." seconds");
		
		sleep(defined($config->{'CYCLE_LATENCY'})?$config->{'CYCLE_LATENCY'}:CYCLE_LATENCY_DEFAULT);
	}
	sleep($config->{'PERIOD_LATENCY'}?$config->{'PERIOD_LATENCY'}:PERIOD_LATENCY_DEFAULT);
}

# Download a fragment of the specified package
sub download{
	my $p = shift;
	my $proto = $p->{'PROTO'};
	my $location = $p->{'PACK_LOC'};
	my $id = $p->{'ID'};
	my $URI = "$proto://$location/$id/";
	
	# If we find a temp file, we know that the update of the task file has failed for any reason. So we retrieve it from this file
	if(-e "$id/task.temp") {
		unlink("$id/task.temp");
		rename("$id/task.temp","$id/task") or return 1;
	}
	
	# Retrieve fragments already downloaded
	unless(open TASK, "$id/task"){
		&log("Download: Cannot open $id/task.");
		return 1;
	}
	my @task = <TASK>;
	
	# Done
	if(!@task){
		&log("Download of $p->{'ID'}... Finished.");
		close(TASK);
		execute($p);
		return 0;
	}
	
	my $fragment = shift(@task);
	my $request = HTTP::Request->new(GET => $URI.$fragment);
	
	&log("Downloading $fragment...");
	
	# Using proxy if possible
	$ua->env_proxy;
	my $res = $ua->request($request);
	
	# Checking if connected
	if($res->is_success) {
		&log("Success :-)");
		$error = 0;
		open FRAGMENT, ">$id/$fragment" or return 1;
		print FRAGMENT $res->content;
		close(FRAGMENT);
		
		# Updating task file
		rename(">$id/task", ">$id/task.temp");
		open TASK, ">$id/task" or return 1;
		print TASK @task;
		close(TASK);
		unlink(">$id/task.temp");
		
	}
	else {
		#download_message($p, ERR_DOWNLOAD_PACK);
		close(TASK);
		&log("Error :-( ".$res->code);
		$error++;
		if($error > MAX_ERROR_COUNT){
			&log("Error : Max errors count reached");
			finish();
		}
		return 1;
	}
	return 0;
}

# Assemble and handle downloaded package
sub execute{
	my $p = shift;
	my $tmp = $p->{'ID'}."/tmp";
	my $exit_code;
	
	&log("Execute orders for package $p->{'ID'}.");
	
	if(build_package($p)){
		clean($p);
		return 1;
	}else{
		# First, we get in temp directory
		unless( chdir($tmp) ){
		 	&log("Cannot chdir to working directory: $!");
			download_message($p, ERR_EXECUTE);
			clean($p);
			return 1;
		}
		
		# Executing preorders (notify user, auto launch, etc....
	# 		$p->{NOTIFY_USER}
	# 		$p->{NOTIFY_TEXT}
	# 		$p->{NOTIFY_COUNTDOWN}
	# 		$p->{NOTIFY_CAN_ABORT}
        # TODO: notification to send through DBUS to the user
		
		
		eval{
			# Execute instructions
			if($p->{'ACT'} eq 'LAUNCH'){
				my $exe_line = $p->{'NAME'};
				$p->{'NAME'} =~ s/^([^ -]+).*/$1/;
				# Exec specified file (LAUNCH => NAME)
				if(-e $p->{'NAME'}){
					&log("Launching $p->{'NAME'}...");
					chmod(0755, $p->{'NAME'}) or die("Cannot chmod: $!");
					$exit_code = system( "./".$exe_line );
				}else{
					die();
				}
				
			}elsif($p->{'ACT'} eq 'EXECUTE'){
				# Exec specified command EXECUTE => COMMAND
				&log("Execute $p->{'COMMAND'}...");
				system( $p->{'COMMAND'} ) and die();
				
			}elsif($p->{'ACT'} eq 'STORE'){
				# Store files in specified path STORE => PATH
				$p->{'PATH'} =~ s/INSTALL_PATH/$current_context->{OCS_AGENT_INSTALL_PATH}/;
				
				# Build it if needed
				my @dir = split('/', $p->{'PATH'});
				my $dir;
				
				for(@dir){
					$dir .= "$_/";
					unless(-e $dir){
						mkdir($dir);
						&log("Create $dir...");
					}	
				}
				
				&log("Storing package to $p->{'PATH'}...");
				# Stefano Brandimarte => Stevenson! <stevens@stevens.it>
				system(&_get_path('cp')." -dpr * ".$p->{'PATH'}) and die();
			}
		};
		if($@){
			# Notify success to ocs server
			download_message($p, ERR_EXECUTE);
			chdir("../..") or die("Cannot go back to download directory: $!");
			clean($p);
			return 1;
		}else{
			chdir("../..") or die("Cannot go back to download directory: $!");
			done($p, (defined($exit_code)?$exit_code:'_NONE_'));
			return 0;
		}
	}	
}

# Check package integrity
sub build_package{
	my $p = shift;
	my $id = $p->{'ID'};
	my $count = $p->{'FRAGS'};
	my $i;
	my $tmp = "./$id/tmp";
	
	unless(-d $tmp){
		mkdir("$tmp");
	}
	# No job if no files
	return 0 unless $count;
	
	# Assemble package
	&log("Building package for $p->{'ID'}.");
	
	for($i=1;$i<=$count;$i++){
		if(-f "./$id/$id-$i"){
			# We make a tmp working directory
			if($i==1){
				open PACKAGE, ">$tmp/build.tar.gz" or return 1;
			}
			# We write each fragment in the final package
			open FRAGMENT, "./$id/$id-$i" or return 1;
			my $row;
			while($row = <FRAGMENT>){
				print PACKAGE $row;
			}
			close(FRAGMENT);
		}else{
			return 1;
		}
	}
	close(PACKAGE);
	# 
	if(check_signature($p->{'DIGEST'}, "$tmp/build.tar.gz", $p->{'DIGEST_ALGO'}, $p->{'DIGEST_ENCODE'})){
		download_message($p, ERR_BAD_DIGEST);
		return 1;
	}
	
	if( system( &_get_path("tar")." -xvzf $tmp/build.tar.gz -C $tmp") ){
		&log("Cannot extract $p->{'ID'}.");
		download_message($p, ERR_BUILD);
		return 1;
	}
	&log("Building of $p->{'ID'}... Success.");
	unlink("$tmp/build.tar.gz") or die ("Cannot remove build file: $!\n");
	return 0;
}

sub check_signature{
	my ($checksum, $file, $digest, $encode) = @_;
		
	&log("Checking signature for $file.");
	
	my $base64;
		
	# Open file
	unless(open FILE, $file){
		&log("cannot open $file: $!");
		return 1;
	}
	
	binmode(FILE);
	# Retrieving encoding form
	if($encode =~ /base64/i){
		$base64 = 1;
		&log('Digest format: Base 64');
	}elsif($encode =~ /hexa/i){
		&log('Digest format: Hexadecimal');
	}else{
		&log('Digest format: Not supported');
		return 1;
	}
	
	eval{
		# Check it
		if($digest eq 'MD5'){
			&log('Digest algo: MD5');
			if($base64){
				die unless Digest::MD5->new->addfile(*FILE)->b64digest eq $checksum; 
			}
			else{
				die unless Digest::MD5->new->addfile(*FILE)->hexdigest eq $checksum;
			}
		}elsif($digest eq 'SHA1'){
			&log('Digest algo: SHA1');
			if($base64){
				die unless Digest::SHA1->new->addfile(*FILE)->b64digest eq $checksum;
			}
			else{
				die unless Digest::SHA1->new->addfile(*FILE)->hexdigest eq $checksum;
			}
		}else{
			&log('Digest algo unknown: '.$digest);
			die;
		}
	};
	if($@){
		&log("Digest checking error !!");
		close(FILE);
		return 1;
	}else{
		close(FILE);
		&log("Digest OK...");
		return 0;
	}
}

# Launch a download error to ocs server
sub download_message{
	my ($p, $code) = @_;
	
	&log("Sending message for $p->{'ID'}, code=$code.");
	
	my $xml = {
		'DEVICEID' => $current_context->{'OCS_AGENT_DEVICEID'},
		'QUERY' => 'DOWNLOAD',
		'ID' => $p->{'ID'},
		'ERR' => $code
	};
	
	# Generate xml
	$xml = XMLout($xml, RootName => 'REQUEST');
	
	# Compress data
	$xml = Compress::Zlib::compress( $xml );
	
	my $URI = $current_context->{'OCS_AGENT_SERVER_NAME'};
	
	# Send request
	my $request = HTTP::Request->new(POST => $URI);
	$request->header('Pragma' => 'no-cache', 'Content-type', 'application/x-compress');
	$request->content($xml);
	my $res = $ua->request($request);
	
	# Checking result
	if($res->is_success) {
		return 0;	
	}else{
		return 1;
	}
}

# At the beginning of end handler
sub begin{
	my $pidfile = shift;
	open LOCK_R, "$pidfile" or die("Cannot open pid file: $!"); 
	if(flock(LOCK_R,LOCK_EX|LOCK_NB)){
		open LOCK_W, ">$pidfile" or die("Cannot open pid file: $!");
		select(LOCK_W) and $|=1;
		select(STDOUT) and $|=1;
		print LOCK_W $$;
		&log("Beginning work. I am $$.");
		return 0;
	}else{
		close(LOCK_R);
		&log("$pidfile locked. Cannot begin work... :-(");
		return 1;
	}
}

sub done{	
	my $p = shift;
	my $suffix = shift;
	&log("Package $p->{'ID'}... Done. Sending message...");
	# Trace installed package
	open DONE, ">$p->{'ID'}/done";
	close(DONE);
	# Put it in history file
	open DONE, "history" or warn("Cannot open history file: $!");
	flock(DONE, LOCK_EX);
	my @historyIds = <DONE>;
	if( &_already_in_array($p->{'ID'}, @historyIds) ){
		&log("Warning: id $p->{'ID'} has been found in the history file!!");
	}
	else {
		print DONE $p->{'ID'},"\n";
	}
	close(DONE);
	
	# Notify success to ocs server
	my $code;
	if($suffix ne '_NONE_'){
		$code = CODE_SUCCESS."_$suffix";
	}
	else{
		$code = CODE_SUCCESS;
	}
	unless(download_message($p, $code)){
		# Clean package
		clean($p);
	}else{
		sleep( defined($config->{'FRAG_LATENCY'})?$config->{'FRAG_LATENCY'}:FRAG_LATENCY_DEFAULT );
	}
	return 0;
}

sub clean{
	my $p = shift;
	&log("Cleaning $p->{'ID'} package.");
	unless(File::Path::rmtree($p->{'ID'}, $debug, 0)){
		&log("Cannot clean $p->{'ID'}!! Abort...");
		download_message($p, ERR_CLEAN);
		die();
	}
	return 0;
}

# At the end
sub finish{
	open LOCK, '>'.$current_context->{'OCS_AGENT_INSTALL_PATH'}.'/download/lock';
	&log("End of work...\n");
	exit(0);
}

sub log{
	return 0 unless $debug;
	my $message = shift;
	print "DOWNLOAD: $message\n";
}

1;
