program proc;

{$mode objfpc}

uses windows, Process, sysutils,  classes, uMemo;

var
filepath, executablePath,action, s, sFile,sFtpFile,sCreatedirs, sForward : ansistring;


 

procedure RunDosInMemo(DosApp : ansistring ; out sOutput:ansistring);
const
    READ_BUFFER_SIZE = 2400;
var
    Security: TSecurityAttributes;
    readableEndOfPipe, writeableEndOfPipe: THandle;
    start: TStartUpInfo;
    ProcessInfo: TProcessInformation;
    Buffer: PAnsiChar;
    BytesRead: DWORD;
    AppRunning: DWORD;
begin
    Security.nLength := SizeOf(TSecurityAttributes);
    Security.bInheritHandle := True;
    Security.lpSecurityDescriptor := nil;

    if CreatePipe({var}readableEndOfPipe, {var}writeableEndOfPipe, @Security, 0) then
    begin
        Buffer := AllocMem(READ_BUFFER_SIZE+1);
        FillChar(Start, Sizeof(Start), #0);
        start.cb := SizeOf(start);

        // Set up members of the STARTUPINFO structure.
        // This structure specifies the STDIN and STDOUT handles for redirection.
        // - Redirect the output and error to the writeable end of our pipe.
        // - We must still supply a valid StdInput handle (because we used STARTF_USESTDHANDLES to swear that all three handles will be valid)
        start.dwFlags := start.dwFlags or STARTF_USESTDHANDLES;
        start.hStdInput := GetStdHandle(STD_INPUT_HANDLE); //we're not redirecting stdInput; but we still have to give it a valid handle
        start.hStdOutput := writeableEndOfPipe; //we give the writeable end of the pipe to the child process; we read from the readable end
        start.hStdError := writeableEndOfPipe;

        //We can also choose to say that the wShowWindow member contains a value.
        //In our case we want to force the console window to be hidden.
        start.dwFlags := start.dwFlags + STARTF_USESHOWWINDOW;
        start.wShowWindow := SW_HIDE;

        // Don't forget to set up members of the PROCESS_INFORMATION structure.
        ProcessInfo := Default(TProcessInformation);

        //WARNING: The unicode version of CreateProcess (CreateProcessW) can modify the command-line "DosApp" string. 
        //Therefore "DosApp" cannot be a pointer to read-only memory, or an ACCESS_VIOLATION will occur.
        //We can ensure it's not read-only with the RTL function: UniqueString

        if CreateProcess(nil, PChar(DosApp), nil, nil, True, NORMAL_PRIORITY_CLASS, nil, nil, start, {var}ProcessInfo) then
        begin
            //Wait for the application to terminate, as it writes it's output to the pipe.
            //WARNING: If the console app outputs more than 2400 bytes (ReadBuffer),
            //it will block on writing to the pipe and *never* close.
            repeat
                Apprunning := WaitForSingleObject(ProcessInfo.hProcess, 100);            
            until (Apprunning <> WAIT_TIMEOUT);

            //Read the contents of the pipe out of the readable end
            //WARNING: if the console app never writes anything to the StdOutput, then ReadFile will block and never return
            repeat
                BytesRead := 0;
                ReadFile(readableEndOfPipe, Buffer[0], READ_BUFFER_SIZE, {var}BytesRead, nil);
                Buffer[BytesRead]:= #0;
                //OemToAnsi(Buffer,Buffer);     
                sOutput := sOutput+ (   (Buffer) );
                //writeln('soutput=',sOutput);
            until (BytesRead < READ_BUFFER_SIZE);
        end;
        FreeMem(Buffer);
        CloseHandle(ProcessInfo.hProcess);
        CloseHandle(ProcessInfo.hThread);
        CloseHandle(readableEndOfPipe);
        CloseHandle(writeableEndOfPipe);
    end;
end;




begin {button 1 code}

//Writeln(WAIT_TIMEOUT); exit;
   RunDosInMemo('curl.exe -T "c:\Users\W596554\Documents\dev\PROJETS\CLOUDCATS\digiborne_LOCAL\kalysta\tests\query file.php" "ftp://envol972:innovations%40972@10.70.138.16:21/apps/kalysta/tests/query proc.php" --ftp-create-dirs', s);

 writeln(s);
end.