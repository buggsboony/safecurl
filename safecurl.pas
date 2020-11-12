program safecurl;

{$mode objfpc}
uses windows, Process, sysutils,  classes, base64, uMemo, uConsole;



procedure RunDosCommand(DosApp : ansistring ; out sOutput:ansistring);
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

//         RunCommand('C:\windows\system32\curl.exe',[action
//  , sFile
//  ,sFtpFile 
//  ,sCreatedirs 
//  , '2>&1'
//  //,'--output', executablePath+'safecurl.txt'
//  ],sOutput) ;   //le output ne fonctionne pas avec curl et runCommand


var
command,curlExe,curlAct,process_cmd, process_arg1,process_arg2,process_name, event_com, lastline, filepath, executablePath,action, sOut,curlAction, sFile,sFtpFile,sCreatedirs, sForward : ansistring;
realSnapFile,snapFilePath, basename:AnsiString;
 bRes, canPush,res:boolean;
list,snapshotLines, tempStrings :TSTringList; 
 iRes, iloop:integer;





 //puts('cyan?', 9 ); puts('blue ?', 3 );
procedure saveSnapShotFile(curlAct:AnsiString);
var save_updated, get_refresh:AnsiString;
begin
   if(curlAct ='Upload') then
   begin
       get_refresh:= 'Updating';
      save_updated:= 'Updated';

   end else
   begin
      get_refresh:= 'Receiving';
      save_updated:= 'Saved';
     end;

  //Check ftp Infos :
                            process_arg1:=paramstr(6);
                            res := ForceDirectories( extractFilePath(process_arg1) );

                            //verboz writeln('ForceDirs = ', res);
                            process_cmd :=curlExe+' -I "'+sFtpFile+'"';
                            //Write in snapshot file
                           //if verboz writeln('info commande:'); writeln(process_cmd);                           
                           puts(get_refresh+' infos ... ', 9);
                            RunCommand(process_cmd, sOut);
                           //if verboz writeln('process_result',sOut);
                           snapshotLines:= TStringList.create;
//                           snapshotLines.append(sOut);
                             snapshotLines.Text:=sOut;
                           process_arg2:=process_arg1;
                           basename:=ExtractFileName(process_arg2);
                           process_arg2:=extractFilePath(process_arg1)+EncodeStringBase64(basename);
                           snapshotLines.saveToFile(process_arg2);
                           writeln(save_updated+', "'+process_arg2+'", size : '+ inttostr( Length(snapshotLines.Text) ) ,3);
end;




var version:AnsiString='V1.48b';
begin

writeln('SafeCurl '+version);

filepath := getExecutableName;
executablePath := extractFilePath(filepath); 

curlExe := 'C:\windows\system32\curl.exe';

sFile:='';
sFtpFile:='';
sCreatedirs:='';
  (*  ****** Upload
safecurl.exe -T "c:\Users\W596554\Documents\dev\PROJETS\CLOUDCATS\digiborne_LOCAL\kalysta\tests\query file.php" "ftp://envol972:innovations%40972@10.70.138.16:21/apps/kalysta\tests\query file.php" --ftp-create-dirs
  ********
   "-T",
        "${file}",
        "ftp://${config:tasks.credentials}/${config:tasks.context}/${relativeFile}",      
        "--ftp-create-dirs"
    *)
    (* ***  Download
  "ftp://${config:tasks.credentials}/${config:tasks.context}/${relativeFile}",
        "-o",
        "${file}",
        "--create-dirs"
    *)

    if( paramcount() > 1)then
    begin
        action:=paramstr(1);    
    end;




    
    if(action='-T')then  
    begin        
       //Upload
       curlAct:='Upload';
       curlAction:='Upload';
       sFile:=paramstr(2);
       //writeln('sFile=',sFile);
       sFtpFile:=paramstr(3);
       sCreatedirs:=paramstr(4);
              event_com:=paramstr(5);
       //writeln('sFtpFile=',sFtpFile);
        sFtpFile:=stringReplace(sFtpFile,'\','/',[rfReplaceAll, rfIgnoreCase]);

        curlAction:=curlAction +' file '+sFile;

        command :=curlExe+' '+action+' "'+sFile+'" "'+sFtpFile+'" '+sCreatedirs;
        //writeln('commande:',command);


       if( event_com ='--check') then
       begin
              //Check ftp Infos before upload :
            process_arg1:=paramstr(6);
            process_cmd :=curlExe+' -I "'+sFtpFile+'"';
            //Write in snapshot file
           //if verboz             writeln('info commande:'); writeln(process_cmd);              halt;
           writeln('Check remote before upload...');
           bRes := RunCommand(process_cmd,sOut );
           //if verboz writeln('process_result',sOut);

//

           if( not bRes )then
           begin //repeat command and get error message
               RunDosCommand(process_cmd, sOut);
               list:= TstringList.create;
               list.text:=sOut;
               lastline := list[list.Count-1];
                   if(  ( Pos('curl: (19)',lastline) = 1) or (Pos('curl: (78)',lastline) = 1) )//curl: (19) Given file does not exist  OR curl: (78) Given file does not exist                  
                   then begin //File does not exists, allow upload                     
                    puts('Remote file does not exists.', 3); //c'étant censé être du Magenta             
                   canPush := true;
                   end;
                   
                   if(  ( Pos('curl: (9)',lastline) = 1)  )//curl: (9) Server denied you to change to the given directory
                   then begin //path does not exists, allow upload                                  
                    puts('Remote path will be created.', 3); //c'étant censé être du Magenta             
                    canPush := true;
                   end;                   
           end else
           begin
                 //check version in last snap
                   snapFilePath:= ExtractFilePath(process_arg1);
                   basename:=ExtractFileName(process_arg1);
                   //writeln('snapfilepath ======= ', snapFilePath);
                   //writeln('basname ======= ', basename);
                   realSnapFile:=EncodeStringBase64(basename);
                   //writeln('realSnapFile ----- ', realSnapFile);

                   snapshotLines:= TStringList.create; tempStrings:= TStringList.create;
                   tempStrings.Text:=sOut;
                   snapshotLines.LoadFromFile(snapFilePath+realSnapFile);

                   if( snapshotLines.Text = tempStrings.Text) then
                   begin
                       canPush := true;
                   end else
                   begin
                     canPush := false;
                       puts('Destination file has been modified !',4); //Red, error                        
                       writeln('SnapShot : ', snapshotLines[0] +' - '+ snapshotLines[1]);            
                       puts('Remote   : '+ tempStrings[0] +' - '+ tempStrings[1] , 4);
                       puts(curlAct+' aborted !', 4); //Red,Error
                       halt;
                   end;

           end;

       end;  //endcheck

    if( canPush ) then
    begin

        RunDosCommand(command, sOut);
    end;

    end else
    begin
        //Download
      //Download
          curlAct:='Download';
          curlAction:='Download';
       sFtpFile:=paramstr(1);
        action:=paramstr(2);  
       sFile:=paramstr(3);
       //writeln('sFile=',sFile);
       sCreatedirs:=paramstr(4);
        event_com:=paramstr(5);
       //writeln('sFtpFile=',sFtpFile);
        sFtpFile:=stringReplace(sFtpFile,'\','/',[rfReplaceAll, rfIgnoreCase]);
      curlAction:=curlAction + ' -> '+sFile;
        command :=curlExe+' "'+sFtpFile+'" '+action+' "'+sFile+'" "'+sCreatedirs;
        
        //writeln('commande:',command);  
        RunDosCommand(command, sOut);
        
    end;

list:= TstringList.create;
list.text:=sOut;

    puts(command, 3); //color 4 = rouge, 2 = vert

    writeln('Output :'#13#10,sOut);
    //writeln('listcount:', list.count);
//puts(sOut, 3); //color 4 = rouge, 3 = bleu,  6 = Jaune
 lastline:= list[list.count-1];

//writeln( 'pos=', pos(lastline,'100   ')  );
// writeln('lastline ['+lastline+'] pos=', pos('curl:', lastline)  );
// writeln('lastline ['+lastline+'] pos de 100 =', pos('100 ',lastline ));

   
   Writeln ('Execution time : ', DateTimeToStr(Now) );  
    //écrire la curl Action
   puts(curlAction, 9 );
 if( pos('100 ',lastline )=1 )then
 begin
    //Success 100%
    puts('OK Success', 2); //color 4 = rouge, 2 = vert    
   
    if(event_com='--check') then
    begin
        //verboz writeln('CurlAction',curlAction);
                if(curlAct ='Download')then
                begin
                saveSnapShotFile(curlAct);
                end else
                if(curlAct ='Upload') then
                begin

                saveSnapShotFile(curlAct);

                end;

    end;

 end else begin
    puts('KO Failed',4);
 end;




end.