dim objShell

set objShell = CreateObject("WScript.Shell")

 

strPath = Wscript.ScriptFullName

Set objFSO = CreateObject("Scripting.FileSystemObject")

Set objFile = objFSO.GetFile(strPath)

strFolder = objFSO.GetParentFolderName(objFile)

'msgbox strFolder

objShell.run "code """&strFolder&"""",0