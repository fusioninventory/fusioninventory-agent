'
'  ------------------------------------------------------------------------
'  fusioninventory-agent-deployment.vbs
'  Copyright (C) 2010-2013 by the FusionInventory Development Team.
'
'  http://www.fusioninventory.org/ http://forge.fusioninventory.org/
'  ------------------------------------------------------------------------
'
'  LICENSE
'
'  This file is part of FusionInventory project.
'
'  This file is free software; you can redistribute it and/or modify it
'  under the terms of the GNU General Public License as published by the
'  Free Software Foundation; either version 2 of the License, or (at your
'  option) any later version.
'
'
'  This file is distributed in the hope that it will be useful, but WITHOUT
'  ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
'  FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for
'  more details.
'
'  You should have received a copy of the GNU General Public License
'  along with this program; if not, write to the Free Software Foundation,
'  Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA,
'  or see <http://www.gnu.org/licenses/>.
'
'  ------------------------------------------------------------------------
'
'  @package   FusionInventory Agent
'  @file      .\contrib\windows\fusioninventory-agent-deployment.vbs
'  @author(s) mips
'             meldrone
'             ZenAdm
'             Tomas Abad <tabadgp@gmail.com>
'  @copyright Copyright (c) 2010-2013 FusionInventory Team
'  @license   GNU GPL version 2 or (at your option) any later version
'             http://www.gnu.org/licenses/old-licenses/gpl-2.0-standalone.html
'  @link      http://www.fusioninventory.org/
'  @link      http://forge.fusioninventory.org/projects/fusioninventory-agent
'  @since     2012
'
'  ------------------------------------------------------------------------
'

'
'
' Purpose:
'     FusionInventory Agent Unatended Deployment.
'
'

Option Explicit
Dim Setup, SetupArchitecture, SetupLocation, SetupOptions, SetupVersion, SetupVerbose

'
'
' USER SETTINGS
'
'

' SetupLocation
'    Depending on your needs or your environment, you can use either a HTTP or CIFS/SMB.
'    If you use HTTP, please, set to SetupLocation a URL:
'
'       SetupLocation = "http://host[:port]/[absolut_path]" or
'       SetupLocation = "https://host[:port]/[absolut_path]"
'
'    If you use CIFS, please, set to SetupLocation a UNC path name:
'
'       SetupLocation = "\\host\share\[path]"
'
SetupLocation = "http://forge.fusioninventory.org/attachments/download/1034"

' SetupVersion
'    Setup version with the pattern <major>.<minor>.<release>[-<package>]
'
SetupVersion = "2.3.0-1"

' SetupArchitecture
'    The setup architecture can be 'i386', 'x86' or 'x64'.
'
'    If SetupVersion is 2.2.x (or previous) you must use 'i386' exclusively.
'    If SetupVersion is 2.3.x (or later) you can use 'x86' or 'x64', but not 'i386'.
'
SetupArchitecture = "x64"

' SetupOptions
'    Consult the installer documentation to know its list of options.
'
SetupOptions = "/acceptlicense /runnow /server='http://<server>/glpi/plugins/fusioninventory/' /S"

' Setup
'    The installer file name. You should not have to modify this variable ever.
'
Setup = "fusioninventory-agent_windows-" & SetupArchitecture & "_" & SetupVersion & ".exe"

' SetupVerbose
'    Enable or disable the information messages.
'
'    It's advisable to use SetupVerbose = "Yes" with 'cscript'.
'
SetupVerbose = "No"

'
'
' DO NOT EDIT BELOW
'
'

Function baseName (strng)
   Dim regEx, ret
   Set regEx = New RegExp
   regEx.Global = true
   regEx.IgnoreCase = True
   regEx.Pattern = ".*[/\\]([^/\\]+)$"
   baseName = regEx.Replace(strng,"$1")
End Function

Function isHttp (strng)
   Dim regEx, matches
   Set regEx = New RegExp
   regEx.Global = true
   regEx.IgnoreCase = True
   regEx.Pattern = "^(http(s?)).*"
   If regEx.Execute(strng).count > 0 Then
      isHttp = True
   Else
      isHttp = False
   End If
   Exit Function
End Function

' http://www.ericphelps.com/scripting/samples/wget/index.html
Function SaveWebBinary (strSetupLocation, strSetup) 'As Boolean
Const adTypeBinary = 1
Const adSaveCreateOverWrite = 2
Const ForWriting = 2
Dim web, varByteArray, strData, strBuffer, lngCounter, ado, strUrl
   strUrl = strSetupLocation & "/" & strSetup
   'On Error Resume Next
   'Download the file with any available object
   Err.Clear
   Set web = Nothing
   Set web = CreateObject("WinHttp.WinHttpRequest.5.1")
   If web Is Nothing Then Set web = CreateObject("WinHttp.WinHttpRequest")
   If web Is Nothing Then Set web = CreateObject("MSXML2.ServerXMLHTTP")
   If web Is Nothing Then Set web = CreateObject("Microsoft.XMLHTTP")
   web.Open "GET", strURL, False
   web.Send
   If Err.Number <> 0 Then
      SaveWebBinary = False
      Set web = Nothing
      Exit Function
   End If
   If web.Status <> "200" Then
      SaveWebBinary = False
      Set web = Nothing
      Exit Function
   End If
   varByteArray = web.ResponseBody
   Set web = Nothing
   'Now save the file with any available method
   On Error Resume Next
   Set ado = Nothing
   Set ado = CreateObject("ADODB.Stream")
   If ado Is Nothing Then
      Set fs = CreateObject("Scripting.FileSystemObject")
      Set ts = fs.OpenTextFile(baseName(strUrl), ForWriting, True)
      strData = ""
      strBuffer = ""
      For lngCounter = 0 to UBound(varByteArray)
         ts.Write Chr(255 And Ascb(Midb(varByteArray,lngCounter + 1, 1)))
      Next
      ts.Close
   Else
      ado.Type = adTypeBinary
      ado.Open
      ado.Write varByteArray
      ado.SaveToFile CreateObject("WScript.Shell").ExpandEnvironmentStrings("%Temp%") & "\" & strSetup, adSaveCreateOverWrite
      ado.Close
   End If
   SaveWebBinary = True
End Function

Function IsInstallationNeeded (strSetupVersion, strSetupArchitecture)
   Dim strSystemArchitecture, strCurrentSetupVersion
   ' Set the default value
   IsInstallationNeeded = False
   ' Get operative system architecture
   '    It can be 'x86', 'AMD64' or 'x64'
   strSystemArchitecture = WshShell.RegRead("HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment\PROCESSOR_ARCHITECTURE")
   ' Check the operative system architecture
   If strSystemArchitecture = "x86" Then
      ' The system architecture is 32-bit
   ElseIf strSystemArchitecture = "x64" Then
      ' The system architecture is 64-bit, but is IA64
      Exit Function
   ElseIf strSystemArchitecture = "AMD64" Then
      ' The system architecture is 64-bit
      strSystemArchitecture = "x64"
   Else
      ' The system architecture is unknow
      Exit Function
   End If
   If SetupVerbose <> "No" Then
      Wscript.Echo "System Architecture Detected... '" & strSystemArchitecture & "'"
   End If
   ' Check the relation between strSystemArchitecture and strSetupArchitecture
   If (strSystemArchitecture = "x86") And (strSetupArchitecture = "x64") Then
      ' It isn't possible to install a 64-bit setup on a 32-bit operative system
      If SetupVerbose <> "No" Then
         Wscript.Echo "It isn't possible to install a 64-bit setup on a 32-bit operative system."
      End If
      Exit Function
   End If
   ' Compare the current version, whether it exists, with strSetupVersion
   If strSystemArchitecture = "x86" Then
      ' The system architecture is 32-bit
      ' Check if the subkey 'SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\FusionInventory Agent' exists
      '    This subkey is now deprecated
      On error resume next
      strCurrentSetupVersion = WshShell.RegRead("HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\FusionInventory Agent\DisplayVersion")
      If Err.Number = 0 Then
      ' The subkey 'SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\FusionInventory Agent' exists
         If strCurrentSetupVersion <> strSetupVersion Then
            If SetupVerbose <> "No" Then
	       Wscript.Echo "Installation needed: '" & strCurrentSetupVersion & "' -> '" & strSetupVersion & "'"
            End If
            IsInstallationNeeded = True
         End If
         Exit Function
      Else
         ' The subkey 'SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\FusionInventory Agent' doesn't exist
         Err.Clear
         ' Check if the subkey 'SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\FusionInventory-Agent' exists
         On error resume next
         strCurrentSetupVersion = WshShell.RegRead("HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\FusionInventory-Agent\DisplayVersion")
         If Err.Number = 0 Then
         ' The subkey 'SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\FusionInventory-Agent' exists
            If strCurrentSetupVersion <> strSetupVersion Then
               If SetupVerbose <> "No" Then
	          Wscript.Echo "Installation needed: '" & strCurrentSetupVersion & "' -> '" & strSetupVersion & "'"
               End If
               IsInstallationNeeded = True
            End If
            Exit Function
	 Else
            ' The subkey 'SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\FusionInventory-Agent' doesn't exist
            Err.Clear
            If SetupVerbose <> "No" Then
	       Wscript.Echo "Installation needed: '" & strSetupVersion & "'"
            End If
            IsInstallationNeeded = True
         End If
      End If
   Else
      ' The system architecture is 64-bit
      ' Check if the subkey 'SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\FusionInventory Agent' exists
      '    This subkey is now deprecated
      On error resume next
      strCurrentSetupVersion = WshShell.RegRead("HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\FusionInventory Agent\DisplayVersion")
      If Err.Number = 0 Then
      ' The subkey 'SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\FusionInventory Agent' exists
         If strCurrentSetupVersion <> strSetupVersion Then
            If SetupVerbose <> "No" Then
               Wscript.Echo "Installation needed: '" & strCurrentSetupVersion & "' -> '" & strSetupVersion & "'"
            End If
            IsInstallationNeeded = True
         End If
         Exit Function
      Else
         ' The subkey 'SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\FusionInventory Agent' doesn't exist
         Err.Clear
         ' Check if the subkey 'SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\FusionInventory-Agent' exists
         On error resume next
         strCurrentSetupVersion = WshShell.RegRead("HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\FusionInventory-Agent\DisplayVersion")
         If Err.Number = 0 Then
         ' The subkey 'SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\FusionInventory-Agent' exists
            If strCurrentSetupVersion <> strSetupVersion Then
               If SetupVerbose <> "No" Then
                  Wscript.Echo "Installation needed: '" & strCurrentSetupVersion & "' -> '" & strSetupVersion & "'"
               End If
               IsInstallationNeeded = True
            End If
            Exit Function
         Else
            ' The subkey 'SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\FusionInventory-Agent' doesn't exist
            Err.Clear
            ' Check if the subkey 'SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\FusionInventory-Agent' exists
            On error resume next
            strCurrentSetupVersion = WshShell.RegRead("HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\FusionInventory-Agent\DisplayVersion")
            If Err.Number = 0 Then
            ' The subkey 'SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\FusionInventory-Agent' exists
               If strCurrentSetupVersion <> strSetupVersion Then
                  If SetupVerbose <> "No" Then
                     Wscript.Echo "Installation needed: '" & strCurrentSetupVersion & "' -> '" & strSetupVersion & "'"
                  End If
                  IsInstallationNeeded = True
               End If
               Exit Function
            Else
               ' The subkey 'SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\FusionInventory-Agent' doesn't exist
               Err.Clear
               If SetupVerbose <> "No" Then
                  Wscript.Echo "Installation needed: '" & strSetupVersion & "'"
               End If
               IsInstallationNeeded = True
            End If
         End If
      End If
   End If
End Function

'
'
' MAIN
'
'

Dim WshShell
Set WshShell = Wscript.CreateObject("Wscript.shell")

If IsInstallationNeeded(SetupVersion, SetupArchitecture) Then
   If isHttp(SetupLocation) Then
      If SetupVerbose <> "No" Then
         Wscript.Echo "Downloading '" & SetupLocation & "/" & Setup & "'..."
      End If
      If SaveWebBinary(SetupLocation, Setup) Then
         If SetupVerbose <> "No" Then
            Wscript.Echo "Running:  ""%TEMP%\" & Setup & """ " & SetupOptions
         End If
         WshShell.Run "CMD.EXE /C ""%TEMP%\" & Setup & """ " & SetupOptions, 0, True
      Else
         If SetupVerbose <> "No" Then
            Wscript.Echo "Error downloading '" & SetupLocation & "\" & Setup & "'!"
         End If
      End If
   Else
      If SetupVerbose <> "No" Then
         Wscript.Echo "Running:  """ & SetupLocation & "\" & Setup & """ " & SetupOptions
      End If
      WshShell.Run "CMD.EXE /C """ & SetupLocation & "\" & Setup & """ " & SetupOptions, 0, True
   End If
Else
   If SetupVerbose <> "No" Then
      Wscript.Echo "It isn't needed (or possible) the installation of '" & Setup & "'."
   End If
End If
