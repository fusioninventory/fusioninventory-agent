/*
	File:		GetPID.h
	
	Description:	This file defines a simple API to do process PID lookup based on process name.
	
	Author:		Chad Jones 

	Copyright: 	© Copyright 2003 Apple Computer, Inc. All rights reserved.
	
	Disclaimer:	IMPORTANT:  This Apple software is supplied to you by Apple Computer, Inc.
				("Apple") in consideration of your agreement to the following terms, and your
				use, installation, modification or redistribution of this Apple software
				constitutes acceptance of these terms.  If you do not agree with these terms,
				please do not use, install, modify or redistribute this Apple software.

				In consideration of your agreement to abide by the following terms, and subject
				to these terms, Apple grants you a personal, non-exclusive license, under Apple’s
				copyrights in this original Apple software (the "Apple Software"), to use,
				reproduce, modify and redistribute the Apple Software, with or without
				modifications, in source and/or binary forms; provided that if you redistribute
				the Apple Software in its entirety and without modifications, you must retain
				this notice and the following text and disclaimers in all such redistributions of
				the Apple Software.  Neither the name, trademarks, service marks or logos of
				Apple Computer, Inc. may be used to endorse or promote products derived from the
				Apple Software without specific prior written permission from Apple.  Except as
				expressly stated in this notice, no other rights or licenses, express or implied,
				are granted by Apple herein, including but not limited to any patent rights that
				may be infringed by your derivative works or by other works in which the Apple
				Software may be incorporated.

				The Apple Software is provided by Apple on an "AS IS" basis.  APPLE MAKES NO
				WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION THE IMPLIED
				WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS FOR A PARTICULAR
				PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND OPERATION ALONE OR IN
				COMBINATION WITH YOUR PRODUCTS.

				IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL OR
				CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE
				GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
				ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION, MODIFICATION AND/OR DISTRIBUTION
				OF THE APPLE SOFTWARE, HOWEVER CAUSED AND WHETHER UNDER THEORY OF CONTRACT, TORT
				(INCLUDING NEGLIGENCE), STRICT LIABILITY OR OTHERWISE, EVEN IF APPLE HAS BEEN
				ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
				
	Change History (most recent first): 
*/
#if !defined(__DTSSampleCode_GetPID__)
#define __DTSSampleCode_GetPID__ 1

#include <stdlib.h>
#include <stdio.h>

#if defined(__cplusplus)
extern "C" {
#endif
    
// --- Defining constants for use with sample code --- //
enum	{kSuccess = 0,
        kCouldNotFindRequestedProcess = -1, 
        kInvalidArgumentsError = -2,
        kErrorGettingSizeOfBufferRequired = -3,
        kUnableToAllocateMemoryForBuffer = -4,
        kPIDBufferOverrunError = -5};

/*****************************************************
 * GetAllPIDsForProcessName
 *****************************************************
 * Purpose:  This functions purpose is to lookup a BSD
 * process PID given the BSD process name.  This function may
 * potentially return multiple PIDs for a given BSD process name
 * since several processes can have the same BSD process name.
 *
 * Parameters:
 * 	ProcessName		A constant C-string.  On calling
 * GetAllPIDsForProcessName this variable holds the BSD process name
 * used to do the process lookup.  Note that the process name you need
 * to pass is the name of the BSD executable process.  If trying
 * to find the PID of an regular OSX application you will need to pass the 
 * name of the actual BSD executable inside an application bundle (rather
 * than the bundle name itself).  In any case as a user you can find the 
 * BSD process name of any process (including OSX applications) by 
 * typing the command "ps -axcocommand,pid" in terminal.
 *
 * 	ArrayOfReturnedPIDs	A pointer to a pre-allocated array of pid_t.
 * On calling GetAllPIDsForProcessName this variable must be a pointer to a
 * pre-allocated array of pid_t whos length (in number of pid_t entries) is defined
 * in ArrayOfPIDsLength.  On successful return from GetAllPIDsForProcessName
 * this array will hold the PIDs of all processes which have a matching process
 * name to that specified in the ProcessName input variable.  The number of actual
 * PIDs entered in the array starting at index zero will be the value returned
 * in NumberOfMatchesFound.  On failed return if the error is a buffer overflow
 * error then the buffer will be filled to the  max with PIDs which matched.
 * Otherwise on failed return the state of the array will be undefined.
 *
 * 	NumberOfPossiblePIDsInArray	A unsigned integer.  On calling
 * GetAllPIDsForProcessName this variable will hold the number of
 * pre-allocated PID entries which are in the ArrayOfReturnedPIDs for this functions
 * use.  Note this value must have a value greater than zero.
 *
 * 	NumberOfMatchesFound	An unsigned integer.  On calling GetAllPIDsForProcessName
 * this variable will point to a pre-allocated unsigned integer.  On return from
 * GetAllPIDsForProcessName this variable will contain the number of PIDs contained in the
 * ArrayOfReturnedPIDs.  On failed return the value of the variable will be undefined.
 *
 * 	SysctlError	A pointer to a pre-allocated integer.  On failed return, this
 * variable represents the error returned from the sysctl command.  On function
 * success this variable will have a value specified by the sysctl based on the
 * error that occurred.  On success the variable will have the value zero.
 * Note this variable can also be NULL in which case the variable is ignored.
 *
 * 	*Function Result* 	A integer return value.
 * 				See result codes listed below.
 * 		Result Codes:
 *	 	  0  		Success.  A set of process PIDs were found and are located in
 *				ArrayOfReturnedPIDs array.
 *		 -1	 	Could not find a process with a matching process name
 *                              (i.e. process not found).
 *		 -2		Invalid arguments passed.
 * 	 	 -3 		Unable to get the size of sysctl buffer required
 *				(consult SysctlError return value for more information)
 * 		 -4 		Unable to allocate memory to store BSD process information
 *				(consult SysctlError return value for more information)
 *		 -5 		The array passed to hold the returned PIDs is not large enough
 *				to hold all PIDs of process with matching names.
 *
 *****************************************************/
int GetAllPIDsForProcessName(const char* ProcessName,
                             pid_t ArrayOfReturnedPIDs[],
                             const unsigned int NumberOfPossiblePIDsInArray,
                             unsigned int* NumberOfMatchesFound,
                             int* SysctlError); //Can be NULL

/*****************************************************
 * GetPIDForProcessName
 *****************************************************
 * Purpose:  A convience call for GetAllPIDsForProcessName().
 * This function looks up a process PID given a BSD process 
 * name.  
 *
 * Parameters:
 * 	ProcessName		A constant C-string.  On calling
 * GetPIDForProcessName this variable holds the BSD process name
 * used to do the process lookup.  Note that the process name you need
 * to pass is the name of the BSD executable process.  If trying
 * to find the PID of an regular OSX application you will need to pass the
 * name of the actual BSD executable inside an application bundle (rather
 * than the bundle name itself).  In any case as a user you can find the
 * BSD process name of any process (including OSX applications) by
 * typing the command "ps -axcocommand,pid" in terminal.
 *
 * 	*Function Result* 	A integer return value.
 * 				See result codes listed below.
 * 		Result Codes:
 *	 	  >=0  		Success.  The value returned is the PID of the 
 *				requested process.
 *		 -1	 	Error getting PID for requested process.  This error can
 *				be caused by several things.  One is if no such process exists.
 *				Another is if more than one process has the given name.  The
 *				Answer is to call GetAllPIDsForProcessName()
 *				for complete error code or to get PIDs if there are multiple
 *				processes with that name.
 *****************************************************/
int GetPIDForProcessName(const char* ProcessName);

#if defined(__cplusplus)
}
#endif

#endif