' Call this from a scheduled task to get around having the batch script be displayed in a command prompt window
Set oShell = CreateObject ("Wscript.Shell") 
Dim strArgs
strArgs = "cmd /c ""[PATH]\javaUpdate.cmd"""
oShell.Run strArgs, 0, false
