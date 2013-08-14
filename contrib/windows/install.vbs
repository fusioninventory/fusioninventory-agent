Option Explicit
Dim versionverification, fusionarguments, uninstallocsagent, fusionsetupURL, OSType
''''' USER SETTINGS '''''
versionverification = "2.3.0" 
fusionarguments = "/S /acceptlicense /server=""https://glpi/glpi/plugins/fusioninventory/""  /runnow /no-ssl-check /add-firewall-exception /execmode=service /installtype=from-scratch" 
' Depending on your needs, you can use either HTTP or Windows share
'fusionsetupURL = "\\server1\data\fusioninventory-agent_windows-i386_" & versionverification & ".exe" 
fusionsetupURL = "http://forge.fusioninventory.org/attachments/download/1020/fusioninventory-agent_windows-"& OsType & "_" & versionverification & ".exe" 
uninstallocsagent = "yes" 
''''' DO NOT EDIT BELOW '''''
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
Function SaveWebBinary(strUrl) 'As Boolean
Const adTypeBinary = 1
Const adSaveCreateOverWrite = 2
Const ForWriting = 2
Dim web, varByteArray, strData, strBuffer, lngCounter, ado
'    On Error Resume Next
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
        ado.SaveToFile CreateObject("WScript.Shell").ExpandEnvironmentStrings("%Temp%") & "\fusioninventory.exe", adSaveCreateOverWrite
        ado.Close
    End If
    SaveWebBinary = True
End Function

Function removeOCS()
    On error resume next

    Dim OCS
    ' Uninstall agent ocs if is installed
    ' Verification on OS 32 Bits
    On error resume next
    OCS = WshShell.RegRead("HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\OCS Inventory Agent\UninstallString")
    If err.number = 0 then
        WshShell.Run "CMD.EXE /C net stop ""OCS INVENTORY SERVICE""",0,True
        WshShell.Run "CMD.EXE /C """ & OCS & """ /S /NOSPLASH",0,True
        WshShell.Run "CMD.EXE /C rmdir ""%ProgramFiles%\OCS Inventory Agent"" /S /Q",0,True
        WshShell.Run "CMD.EXE /C rmdir ""%SystemDrive%\ocs-ng"" /S /Q",0,True
        WshShell.Run "CMD.EXE /C sc delete ""OCS INVENTORY""",0,True
    End If

    ' Verification on OS 64 Bits
    On error resume next
    OCS = WshShell.RegRead("HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\OCS Inventory Agent\UninstallString")
    If err.number = 0 then
        WshShell.Run "CMD.EXE /C net stop ""OCS INVENTORY SERVICE""",0,True
        WshShell.Run "CMD.EXE /C """ & OCS & """ /S /NOSPLASH",0,True
        WshShell.Run "CMD.EXE /C rmdir ""%ProgramFiles(x86)%\OCS Inventory Agent"" /S /Q",0,True
        WshShell.Run "CMD.EXE /C rmdir ""%SystemDrive%\ocs-ng"" /S /Q",0,True
        WshShell.Run "CMD.EXE /C sc delete ""OCS INVENTORY""",0,True
    End If

    ' Verification Agent V2 on 32Bit
    On error resume next
    OCS = WshShell.RegRead("HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\OCS Inventory NG Agent\UninstallString")
    If err.number = 0 then
        WshShell.Run "CMD.EXE /C net stop ""OCS INVENTORY SERVICE""",0,True
        WshShell.Run "CMD.EXE /C taskkill /F /IM ocssystray.exe",0,True
        WshShell.Run "CMD.EXE /C """ & OCS & """ /S /NOSPLASH",0,True
        WshShell.Run "CMD.EXE /C rmdir ""%ProgramFiles%\OCS Inventory Agent"" /S /Q",0,True
        WshShell.Run "CMD.EXE /C rmdir ""%SystemDrive%\ocs-ng"" /S /Q",0,True
        WshShell.Run "CMD.EXE /C sc delete ""OCS INVENTORY""",0,True
    End If

    ' Verification Agent V2 on 64Bit
    On error resume next
    OCS = WshShell.RegRead("HKLM\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\OCS Inventory NG Agent\UninstallString")
    If err.number = 0 then
        WshShell.Run "CMD.EXE /C net stop ""OCS INVENTORY SERVICE""",0,True
        WshShell.Run "CMD.EXE /C taskkill /F /IM ocssystray.exe",0,True
        WshShell.Run "CMD.EXE /C """ & OCS & """ /S /NOSPLASH",0,True
        WshShell.Run "CMD.EXE /C rmdir ""%ProgramFiles%\OCS Inventory Agent"" /S /Q",0,True
        WshShell.Run "CMD.EXE /C rmdir ""%SystemDrive%\ocs-ng"" /S /Q",0,True
        WshShell.Run "CMD.EXE /C sc delete ""OCS INVENTORY""",0,True
    End If

End Function

Function needFusionInstall ()
    Dim Fusion
    ' install fusion if version is different or if not installed
    needFusionInstall = False 
    On error resume next
    Fusion = WshShell.RegRead("HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\FusionInventory Agent\DisplayVersion")
    If err.number = 0 Then
      ' Verification on OS 32 Bits
      If Fusion <> versionverification Then
          needFusionInstall = True
      Else
            needFusionInstall = False 
            Return
      End If
    Else
      ' Verification on OS 64 Bits
      On error resume next
      Fusion = WshShell.RegRead("HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\FusionInventory Agent\DisplayVersion")
      If err.number = 0 Then
        If Fusion <> versionverification Then
          needFusionInstall = True
        End if
      Else
          needFusionInstall = True
      End If
    End If
End Function

''' MAIN
Dim WshShell
Set WshShell = Wscript.CreateObject("Wscript.shell")

' Get OS Type, 32 or 64 bit
OsType = WshShell.RegRead("HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment\PROCESSOR_ARCHITECTURE")

If uninstallocsagent = "yes" Then
    removeOCS()
End If

If needFusionInstall() Then
    If (isHttp(fusionsetupURL)) Then
       SaveWebBinary(fusionsetupURL)
       WshShell.Run "CMD.EXE /C %TEMP%\fusioninventory.exe " & fusionarguments,0,True
    Else
        WshShell.Run "CMD.EXE /C """ & fusionsetupURL & """ " & fusionarguments,0,True
    End If
End If
