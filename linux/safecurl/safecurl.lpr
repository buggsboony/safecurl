program safecurl;

uses crt,Process, sysutils,  classes;




var
  AProcess: TProcess;
  AStringList: TStringList;

procedure RunProcessStdErr(command :Ansistring; out  S: TStringList  );
var

  M: TMemoryStream;
  P: TProcess;
  n: LongInt;
  BytesRead: LongInt;

begin
    M := TMemoryStream.Create;
   BytesRead := 0;

   P := TProcess.Create(nil);
   P.CommandLine := command;
   P.Options := [poWaitOnExit, poUsePipes];

   P.Execute;
   while P.Running do
   begin
     // make sure we have room
     M.SetSize(BytesRead + 2048);

     // try reading it
     n := P.Output.Read((M.Memory + BytesRead)^, 2048);
     if n > 0
     then begin
       Inc(BytesRead, n);
       Write('.')
     end
     else begin
       // no data, wait 100 ms
       Sleep(100);
     end;
   end;
   // read last part
   repeat
     // make sure we have room
     M.SetSize(BytesRead + 2048);
     // try reading it
     n := P.Stderr.Read((M.Memory + BytesRead)^, 2048);
     if n > 0
     then begin
       Inc(BytesRead, n);
      // Write('.');
     end;
   until n <= 0;
   if BytesRead > 0 then WriteLn;
   M.SetSize(BytesRead);
//   WriteLn('-- executed --');

   S := TStringList.Create;
   S.LoadFromStream(M);
  // WriteLn('-- linecount = ', S.Count, ' --');
   for n := 0 to S.Count - 1 do
   begin
  //  WriteLn(S[n]);
   end;


   P.Free;
   M.Free;
  end;


//Attention d'initialiser avant le Tstrings avec Tstrings.create;
procedure Split(Delimiter: Char; Str: string; ListOfStrings: TStrings);
begin
  ListOfStrings.Clear;
  ListOfStrings.Delimiter       := Delimiter;
  ListOfStrings.StrictDelimiter := True; // Requires D2006 or newer.
  ListOfStrings.DelimitedText   := Str;
end;


  var
    command,redirect, lastline, filepath, executablePath,curlAction,action, sOut, sFile,sFtpFile,sCreatedirs, sForward : ansistring;
    list, lastlist:TSTringList;


begin

   //redirect:='2>/home/boony/test2.txt'          ;
   // redirect:='2>&1'          ;
    redirect:='';
sFile:='';
sFtpFile:='';
sCreatedirs:='';

    writeln('SafeCurl V1.3');


   list := TstringList.create;


     (*  ****** Upload example
safecurl.exe -T "/home/myuser/localfile.php" "ftp://USER:PASSWORD:21/myapp\folder\remotefile.php" --ftp-create-dirs
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
       curlAction:='Upload';
       sFile:=paramstr(2);          // writeln('sFile00=',sFile);
       sFtpFile:=paramstr(3);
       sCreatedirs:=paramstr(4);    //       writeln('sFtpFile=',sFtpFile);

       curlAction:=curlAction +' file '+sFile;

       command :='curl'+' '+action+' "'+sFile+'" "'+sFtpFile+'" '+sCreatedirs;
//        sFtpFile:=stringReplace(sFtpFile,'\','/',[rfReplaceAll, rfIgnoreCase]);


//textcolor(white); writeln('command is ',command);
RunProcessStdErr(command, list);

    end else if paramcount>1 then
    begin
        //Download
          curlAction:='Download';
       sFtpFile:=paramstr(1);
        action:=paramstr(2);
       sFile:=paramstr(3);
       sCreatedirs:=paramstr(4);
       //writeln('sFtpFile=',sFtpFile);
       //sFile:=stringReplace(sFile,'\','/',[rfReplaceAll, rfIgnoreCase]);
       curlAction:=curlAction + ' -> '+sFile;
        command :='curl "'+sFtpFile+'" '+action+' "'+sFile+'" '+sCreatedirs;
        writeln('commande:',command);
        RunProcessStdErr(command, list);
    end;


     if(list.count>0)then
     begin
            // writeln('listcount:', list.count);
         textcolor(white);
          writeln('Output :'#13#10);

          textColor(blue); writeln(list.Text);
           lastline:= list[list.count-1];


           //execution time
           textcolor(white);
           Writeln ('Execution time : ', FormatDateTime('YYYY-MM-DD hh:nn:ss',now) );
           //écrire la curl Action
           textcolor(Cyan);  writeln(curlAction);  textcolor(white);
           //éclater la derniere ligne :
           if( pos('100 ',lastline )=1 )then
           begin
              //Success 100%
                 textcolor(lightgreen);
              writeln('OK Success');
           end else begin
             textcolor(lightred);
              writeln('KO Failed');
           end;




     end;
end.

