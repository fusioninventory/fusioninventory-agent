/*
	File:		GetPID.c
	
	Description:	This file provides a simple API to do process PID lookup based on process name.
	
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

#include "GetPID.h"

#include <errno.h>
#include <string.h>
#include <sys/sysctl.h>

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
 * Otherwise on failed return the state of the array will be undefined.  Note
 * the returned PID array is not sorted and is listed in order of process encountered.  
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
                             int* SysctlError)
{
    // --- Defining local variables for this function and initializing all to zero --- //
    int mib[6] = {0,0,0,0,0,0}; //used for sysctl call.
    int SuccessfullyGotProcessInformation;
    size_t sizeOfBufferRequired = 0; //set to zero to start with.
    int error = 0;
    long NumberOfRunningProcesses = 0;
    unsigned int Counter = 0;
    struct kinfo_proc* BSDProcessInformationStructure = NULL;
    pid_t CurrentExaminedProcessPID = 0;
    char* CurrentExaminedProcessName = NULL;

    // --- Checking input arguments for validity --- //
    if (ProcessName == NULL) //need valid process name
    {
        return(kInvalidArgumentsError);
    }

    if (ArrayOfReturnedPIDs == NULL) //need an actual array
    {
        return(kInvalidArgumentsError);
    }

    if (NumberOfPossiblePIDsInArray <= 0)
    {
        //length of the array must be larger than zero.
        return(kInvalidArgumentsError);
    }

    if (NumberOfMatchesFound == NULL) //need an integer for return.
    {
        return(kInvalidArgumentsError);
    }
    

    //--- Setting return values to known values --- //

    //initalizing PID array so all values are zero
    memset(ArrayOfReturnedPIDs, 0, NumberOfPossiblePIDsInArray * sizeof(pid_t));
        
    *NumberOfMatchesFound = 0; //no matches found yet

    if (SysctlError != NULL) //only set sysctlError if it is present
    {
        *SysctlError = 0;
    }

    //--- Getting list of process information for all processes --- //
    
    /* Setting up the mib (Management Information Base) which is an array of integers where each
    * integer specifies how the data will be gathered.  Here we are setting the MIB
    * block to lookup the information on all the BSD processes on the system.  Also note that
    * every regular application has a recognized BSD process accociated with it.  We pass
    * CTL_KERN, KERN_PROC, KERN_PROC_ALL to sysctl as the MIB to get back a BSD structure with
    * all BSD process information for all processes in it (including BSD process names)
    */
    mib[0] = CTL_KERN;
    mib[1] = KERN_PROC;
    mib[2] = KERN_PROC_ALL;

    /* Here we have a loop set up where we keep calling sysctl until we finally get an unrecoverable error
    * (and we return) or we finally get a succesful result.  Note with how dynamic the process list can
    * be you can expect to have a failure here and there since the process list can change between
    * getting the size of buffer required and the actually filling that buffer.
    */
    SuccessfullyGotProcessInformation = FALSE;
    
    while (SuccessfullyGotProcessInformation == FALSE)
    {
        /* Now that we have the MIB for looking up process information we will pass it to sysctl to get the 
        * information we want on BSD processes.  However, before we do this we must know the size of the buffer to 
        * allocate to accomidate the return value.  We can get the size of the data to allocate also using the 
        * sysctl command.  In this case we call sysctl with the proper arguments but specify no return buffer 
        * specified (null buffer).  This is a special case which causes sysctl to return the size of buffer required.
        *
        * First Argument: The MIB which is really just an array of integers.  Each integer is a constant
        *     representing what information to gather from the system.  Check out the man page to know what
        *     constants sysctl will work with.  Here of course we pass our MIB block which was passed to us.
        * Second Argument: The number of constants in the MIB (array of integers).  In this case there are three.
        * Third Argument: The output buffer where the return value from sysctl will be stored.  In this case
        *     we don't want anything return yet since we don't yet know the size of buffer needed.  Thus we will
        *     pass null for the buffer to begin with.
        * Forth Argument: The size of the output buffer required.  Since the buffer itself is null we can just
        *     get the buffer size needed back from this call.
        * Fifth Argument: The new value we want the system data to have.  Here we don't want to set any system
        *     information we only want to gather it.  Thus, we pass null as the buffer so sysctl knows that 
        *     we have no desire to set the value.
        * Sixth Argument: The length of the buffer containing new information (argument five).  In this case
        *     argument five was null since we didn't want to set the system value.  Thus, the size of the buffer
        *     is zero or NULL.
        * Return Value: a return value indicating success or failure.  Actually, sysctl will either return
        *     zero on no error and -1 on error.  The errno UNIX variable will be set on error.
        */ 
        error = sysctl(mib, 3, NULL, &sizeOfBufferRequired, NULL, 0);

        /* If an error occurred then return the accociated error.  The error itself actually is stored in the UNIX 
        * errno variable.  We can access the errno value using the errno global variable.  We will return the 
        * errno value as the sysctlError return value from this function.
        */
        if (error != 0) 
        {
            if (SysctlError != NULL)
            {
                *SysctlError = errno;  //we only set this variable if the pre-allocated variable is given
            } 

            return(kErrorGettingSizeOfBufferRequired);
        }
    
        /* Now we successful obtained the size of the buffer required for the sysctl call.  This is stored in the 
        * SizeOfBufferRequired variable.  We will malloc a buffer of that size to hold the sysctl result.
        */
        BSDProcessInformationStructure = (struct kinfo_proc*) malloc(sizeOfBufferRequired);

        if (BSDProcessInformationStructure == NULL)
        {
            if (SysctlError != NULL)
            {
                *SysctlError = ENOMEM;  //we only set this variable if the pre-allocated variable is given
            } 

            return(kUnableToAllocateMemoryForBuffer); //unrecoverable error (no memory available) so give up
        }
    
        /* Now we have the buffer of the correct size to hold the result we can now call sysctl
        * and get the process information.  
        *
        * First Argument: The MIB for gathering information on running BSD processes.  The MIB is really 
        *     just an array of integers.  Each integer is a constant representing what information to 
        *     gather from the system.  Check out the man page to know what constants sysctl will work with.  
        * Second Argument: The number of constants in the MIB (array of integers).  In this case there are three.
        * Third Argument: The output buffer where the return value from sysctl will be stored.  This is the buffer
        *     which we allocated specifically for this purpose.  
        * Forth Argument: The size of the output buffer (argument three).  In this case its the size of the 
        *     buffer we already allocated.  
        * Fifth Argument: The buffer containing the value to set the system value to.  In this case we don't
        *     want to set any system information we only want to gather it.  Thus, we pass null as the buffer
        *     so sysctl knows that we have no desire to set the value.
        * Sixth Argument: The length of the buffer containing new information (argument five).  In this case
        *     argument five was null since we didn't want to set the system value.  Thus, the size of the buffer
        *     is zero or NULL.
        * Return Value: a return value indicating success or failure.  Actually, sysctl will either return 
        *     zero on no error and -1 on error.  The errno UNIX variable will be set on error.
        */ 
        error = sysctl(mib, 3, BSDProcessInformationStructure, &sizeOfBufferRequired, NULL, 0);
    
        //Here we successfully got the process information.  Thus set the variable to end this sysctl calling loop
        if (error == 0)
        {
            SuccessfullyGotProcessInformation = TRUE;
        }
        else 
        {
            /* failed getting process information we will try again next time around the loop.  Note this is caused
            * by the fact the process list changed between getting the size of the buffer and actually filling
            * the buffer (something which will happen from time to time since the process list is dynamic).
            * Anyways, the attempted sysctl call failed.  We will now begin again by freeing up the allocated 
            * buffer and starting again at the beginning of the loop.
            */
            free(BSDProcessInformationStructure); 
        }
    }//end while loop

    // --- Going through process list looking for processes with matching names --- //

    /* Now that we have the BSD structure describing the running processes we will parse it for the desired
     * process name.  First we will the number of running processes.  We can determine
     * the number of processes running because there is a kinfo_proc structure for each process.
     */
    NumberOfRunningProcesses = sizeOfBufferRequired / sizeof(struct kinfo_proc);  
    
    /* Now we will go through each process description checking to see if the process name matches that
     * passed to us.  The BSDProcessInformationStructure has an array of kinfo_procs.  Each kinfo_proc has
     * an extern_proc accociated with it in the kp_proc attribute.  Each extern_proc (kp_proc) has the process name
     * of the process accociated with it in the p_comm attribute and the PID of that process in the p_pid attibute.
     * We test the process name by compairing the process name passed to us with the value in the p_comm value.
     * Note we limit the compairison to MAXCOMLEN which is the maximum length of a BSD process name which is used
     * by the system. 
     */
    for (Counter = 0 ; Counter < NumberOfRunningProcesses ; Counter++)
    {
        //Getting PID of process we are examining
        CurrentExaminedProcessPID = BSDProcessInformationStructure[Counter].kp_proc.p_pid; 
    
        //Getting name of process we are examining
        CurrentExaminedProcessName = BSDProcessInformationStructure[Counter].kp_proc.p_comm; 
        
        if ((CurrentExaminedProcessPID > 0) //Valid PID
           && ((strncmp(CurrentExaminedProcessName, ProcessName, MAXCOMLEN) == 0))) //name matches
        {	
            // --- Got a match add it to the array if possible --- //
            if ((*NumberOfMatchesFound + 1) > NumberOfPossiblePIDsInArray)
            {
                //if we overran the array buffer passed we release the allocated buffer give an error.
                free(BSDProcessInformationStructure);
                return(kPIDBufferOverrunError);
            }
        
            //adding the value to the array.
            ArrayOfReturnedPIDs[*NumberOfMatchesFound] = CurrentExaminedProcessPID;
            
            //incrementing our number of matches found.
            *NumberOfMatchesFound = *NumberOfMatchesFound + 1;
        }
    }//end looking through process list

    free(BSDProcessInformationStructure); //done with allocated buffer so release.

    if (*NumberOfMatchesFound == 0)
    {
        //didn't find any matches return error.
        return(kCouldNotFindRequestedProcess);
    }
    else
    {
        //found matches return success.
        return(kSuccess);
    }
}

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
 *	 	  >0  		Success.  The value returned is the PID of the 
 *				matching process.
 *		 -1	 	Error getting PID for requested process.  This error can
 *				be caused by several things.  One is if no such process exists.
 *				Another is if more than one process has the given name.  The
 *				thing to do here is to call GetAllPIDsForProcessName()
 *				for complete error code or to get PIDs if there are multiple
 *				processes with that name.
 *****************************************************/
int GetPIDForProcessName(const char* ProcessName)
{
    pid_t PIDArray[1] = {0};
    int Error = 0;
    unsigned int NumberOfMatches = 0;  

   /* Here we are calling the function GetAllPIDsForProcessName which wil give us the PIDs
    * of the process name we pass.  Of course here we are hoping for a single PID return.
    * First Argument: The BSD process name of the process we want to lookup.  In this case the
    *	the process name passed to us.
    * Second Argument: A preallocated array of pid_t.  This is where the PIDs of matching processes
    *	will be placed on return.  We pass the array we just allocated which is length one.
    * Third Argument: The number of pid_t entries located in the array of pid_t (argument 2).  In this
    *   case our array has one pid_t entry so pass one.
    * Forth Argument: On return this will hold the number of PIDs placed into the 
    *	pid_t array (array passed in argument 2).
    * Fifth Argument: Passing NULL to ignore this argument.
    * Return Value: An error indicating success (zero result) or failure (non-zero).
    *   
    */
    Error = GetAllPIDsForProcessName(ProcessName, PIDArray, 1, &NumberOfMatches, NULL);
    
    if ((Error == 0) && (NumberOfMatches == 1))//success!  
    {
        return((int) PIDArray[0]); //return the one PID we found.
    }
    else 
    {
        return(-1);
    }
}
