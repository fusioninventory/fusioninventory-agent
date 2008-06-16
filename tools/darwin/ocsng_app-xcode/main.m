//
//  main.m
//  OCSNG
//
//  Created by Wes Young - claimid.com/saxjazman9 on 5/28/08.
//  CopyLeft Barely3am.com 2008. All rights reserved.
//
//  This code is opensource and may be copied and modified as long as the source
//  code is always made freely available.
//  Please refer to the General Public Licence http://www.gnu.org/
//

#import <Cocoa/Cocoa.h>

int main(int argc, char *argv[]) {
	// Too be on the safe side, I chose the array length to be 10.
	const int kPIDArrayLength = 10;
	pid_t myArray[kPIDArrayLength];
	unsigned int numberMatches;

	// simple way of geting our PID, see if we're already running....
	int error = GetAllPIDsForProcessName("OCSNG",myArray,kPIDArrayLength,&numberMatches,NULL);
	if (error == 0) { // Success
		if (numberMatches > 1) {
			// There's already a copy of this app running
			return -1;
		}
	}
	// we're good, continue on
	// create autorelease pool since we're not using NSApplication, which would do it for us
	NSAutoreleasePool *autoreleasepool = [[NSAutoreleasePool alloc] init];
	
	// set the default status and the create the task ref
	int status = -1;
	
   	NSTask *task = [[NSTask alloc] init];
	
	// set the path of main.pl and create the arguments (our path)
	NSString *path = [[NSBundle mainBundle] pathForResource:@"main"ofType:@"pl"];
	NSArray *args = [NSArray arrayWithObjects:[NSString stringWithString:path],nil ]; // make sure you end with ,nil for 10.3.9-10.4.x compatibility
	[task setArguments: args];
	
	// set the launch path of the task
	[task setLaunchPath:[NSString stringWithString:path]];
	[task launch];
	[task waitUntilExit];
	status = [task terminationStatus];
	
	// relase the pool of ... 
	[autoreleasepool release];
	return status;
}
