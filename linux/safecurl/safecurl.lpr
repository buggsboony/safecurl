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
procedure SplitSpaces(Str: string; ListOfStrings: TStrings);
var i:integer;
pstr:pstring;
ch:Char;
word:AnsiString;
store, storeq :boolean;
begin
      store:=false;
ListOfStrings.Clear;
      pstr:=@str;
      word:='';
      for i:=1 to length(pstr[0]) do   {length is 89}
      begin
           ch := pstr[0][i];  {http://eqcode.com/wiki/CharAt}
           storeq:=store;
           if( (ch<>' ') ) then
           begin
                store:=true;
           end else begin
            store:=false;
           end;

           if(store)then begin
                   word:=word+ch;
           end;

           if( (not store) and (storeq<>store) ) then begin
              //save word (append list);
            ListOfStrings.append(word);
            //reset word
            word:='';
           end;
      end;

      if( Length(word) >0 ) then begin  ListOfStrings.append(word); //the last one
       end;

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
    list, lastlist ,snapshotLines, tempStrings, lastLineParts:TSTringList;
     bRes, canPush,res:boolean;
    iRes, iloop:integer;

    action_percent: AnsiString;//0
   action_size :AnsiString;//1
   download_percent  :AnsiString;//2
   download_size  :AnsiString;//3
   upload_percent  :AnsiString;//4
   upload_size  :AnsiString;//5
                      action_succeed:boolean;
             search_size:AnsiString;


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

   var version : ansistring='V1.53 linux';

begin

   //redirect:='2>/home/boony/test2.txt'          ;
   // redirect:='2>&1'          ;
    redirect:='';
sFile:='';
sFtpFile:='';
sCreatedirs:='';

    writeln('SafeCurl '+version);


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
       sCreatedirs:=paramstr(4);         //writeln('sFtpFile=',sFtpFile);
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


           if( not bRes )then
           begin //repeat command and get error message
               list:= TStringList.create; // just in case
               RunProcessStdErr(process_cmd, list);
               lastline := list[list.Count-1];
                   if(  ( Pos('curl: (19)',lastline) = 1) or (Pos('curl: (78)',lastline) = 1) )//curl: (19) Given file does not exist  OR curl: (78) Given file does not exist
                   then begin //File does not exists, allow upload
                    textcolor(LightMagenta);
                    writeln('Remote file does not exists');
                    textcolor(lightgray);
                   canPush := true;
                   end;

                   if(  ( Pos('curl: (9)',lastline) = 1)  )//curl: (9) Server denied you to change to the given directory
                   then begin //path does not exists, allow upload
                    textcolor(LightMagenta);
                    writeln('Remote path will be created');
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

           lastLineParts:= TStringList.create;
           SplitSpaces(lastline, lastLineParts);


//             writeln('lastlineparts.Count=' ,lastLineParts.Count);

           if(lastLineParts.Count>=1) then             action_percent:=lastLineParts[0]; //0
           if(lastLineParts.Count>=2) then             action_size :=lastLineParts[1];//1
           if(lastLineParts.Count>=3) then             download_percent :=lastLineParts[2];//2
           if(lastLineParts.Count>=4) then             download_size:=lastLineParts[3];
           if(lastLineParts.Count>=5) then             upload_percent :=lastLineParts[4];
          if(lastLineParts.Count>=6)  then  upload_size :=lastLineParts[5];

               action_succeed  :=false;


                 if(curlAct ='Download')then
                 begin
                     search_size :=   download_size;
                 end else
                 if(curlAct ='Upload') then
                    begin
                       search_size := upload_size;
                   end;

//writeln('search size',search_size);          writeln('search perce', action_percent);
  if( pos('100 ', lastline )=1 )then
  begin
      action_succeed :=true;
  end;

  if( (search_size='0') and (action_percent='0')  ) then
  begin
      action_succeed :=true;
  end;

// writeln('lastline='+lastline+':', Pos('curl: (',lastline) );
          //Vérification supplémentaire de cas d'erreur
          if(  ( Pos('curl: (',lastline) >=1)  ) then
          begin
                 action_succeed:=false;
          end;


           if( action_succeed )then
           begin
              //Success 100%
                 textcolor(lightgreen);
              writeln('OK Success !');
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

