program safecurl;

uses crt,Process, sysutils,  classes, base64;




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
  realSnapFile,snapFilePath, basename, curlExe,curlAct,process_cmd, process_arg1,process_arg2,process_name, event_com:AnsiString;
    list, lastlist ,snapshotLines, tempStrings:TSTringList;
     bRes, canPush,res:boolean;
    iRes, iloop:integer;




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
                           textcolor(cyan);
                           write(get_refresh+' infos ... ');
                            RunCommand(process_cmd, sOut);
                           //if verboz writeln('process_result',sOut);
                           snapshotLines:= TStringList.create;
//                           snapshotLines.append(sOut);
                             snapshotLines.Text:=sOut;
                           process_arg2:=process_arg1;
                           basename:=ExtractFileName(process_arg2);
                           process_arg2:=extractFilePath(process_arg1)+EncodeStringBase64(basename);
                           snapshotLines.saveToFile(process_arg2);
                           writeln(' '+save_updated+', "'+process_arg2+'", size : '+ inttostr( Length(snapshotLines.Text) ) ,3);
end;


begin

   //redirect:='2>/home/boony/test2.txt'          ;
   // redirect:='2>&1'          ;
    redirect:='';
sFile:='';
sFtpFile:='';
sCreatedirs:='';

    writeln('SafeCurl V1.34');


         curlExe := 'curl';

   list := TstringList.create;


    if( paramcount() > 1)then
    begin
        action:=paramstr(1);
    end;

    if(action='-T')then
    begin
       //Upload      //////////////////////////////////////////////////////////////////////  UPLOAD  -------------------------------

          curlAct:='Upload';
       curlAction:='Upload';
       sFile:=paramstr(2);          // writeln('sFile00=',sFile);
       sFtpFile:=paramstr(3);
       sCreatedirs:=paramstr(4);    //       writeln('sFtpFile=',sFtpFile);
             event_com:=paramstr(5); //--check
       curlAction:=curlAction +' file '+sFile;

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
               list:= TStringList.create; // just in case
               RunProcessStdErr(process_cmd, list);
               lastline := list[list.Count-1];
                   if( Pos('curl: (19)',lastline) = 1) //curl: (19) Given file does not exist
                   then begin //File does not exists, allow upload
                    textcolor(LightMagenta);
                    writeln('Remote file does not exists');
                    textcolor(lightgray);
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

                   realSnapFile:=snapFilePath+realSnapFile;
                   if( not FileExists(realSnapFile) ) then
                   begin
                     canPush := false;
                     textcolor(red); writeln('Comparison file does not exists !');  
                       writeln(' Stopped !');
                       textcolor(LightGray);
                       halt;
                   end else
                   begin
                    snapshotLines.LoadFromFile(realSnapFile);
                   end;
                   
                   if( snapshotLines.Text = tempStrings.Text) then
                   begin
                       canPush := true;
                   end else
                   begin
                     canPush := false;
                        textcolor(red); writeln('Destination file has been modified !');
                        textcolor(LightGray);
                       writeln('SnapShot : ', snapshotLines[0] +' - '+ snapshotLines[1]);
                       textcolor(red);
                       writeln('Remote   : ', tempStrings[0] +' - '+ tempStrings[1] );
                       writeln(curlAct+' aborted !');
                       textcolor(LightGray);
                       halt;
                   end;

           end;

       end;  //endcheck



          if( canPush ) then
          begin
               command :=curlExe+' '+action+' "'+sFile+'" "'+sFtpFile+'" '+sCreatedirs;
        //        sFtpFile:=stringReplace(sFtpFile,'\','/',[rfReplaceAll, rfIgnoreCase]);

              //textcolor(LightGray); writeln('command is ',command);
              RunProcessStdErr(command, list);
          end;









    end else if paramcount>1 then                      ////////////////////////////////////  Download  ----------------------
    begin
        //Download
          curlAct:='Download';
          curlAction:='Download';
       sFtpFile:=paramstr(1);
        action:=paramstr(2);
       sFile:=paramstr(3);
       sCreatedirs:=paramstr(4);
       //writeln('sFtpFile=',sFtpFile);
       //sFile:=stringReplace(sFile,'\','/',[rfReplaceAll, rfIgnoreCase]);
       curlAction:=curlAction + ' -> '+sFile;
               event_com:=paramstr(5);

        command :=curlExe+' "'+sFtpFile+'" '+action+' "'+sFile+'" '+sCreatedirs;
        writeln('commande:',command);
        RunProcessStdErr(command, list);
    end;










     if(list.count>0)then
     begin
            // writeln('listcount:', list.count);
         textcolor(LightGray);
          writeln('Output :'#13#10);

          textColor(blue); writeln(list.Text);
           lastline:= list[list.count-1];

           //execution time
           textcolor(lightGray);
           Writeln ('Execution time : ', FormatDateTime('YYYY-MM-DD hh:nn:ss',now) );
           //écrire la curl Action
           textcolor(Cyan);  writeln(curlAction);  textcolor(LightGray);
           //éclater la derniere ligne :
           if( pos('100 ',lastline )=1 )then
           begin
              //Success 100%
                 textcolor(lightgreen);
              writeln('OK Success');
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
             textcolor(lightred);
              writeln('KO Failed');
           end;


           textcolor(LightGray);

     end;
end.

