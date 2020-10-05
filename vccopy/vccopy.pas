program safecurl;

{$mode objfpc}
uses windows, Process, sysutils,  classes, uMemo, uConsole, base64;




var
command, lastline, verbose, destdir,relativFile, localFile, context, filepath, executablePath,action, sOut,curlAction, sFile,sFtpFile,sCreatedirs, sForward : ansistring;
list,  snapshotLines: TStringList;
destFullDir,destFullname,curlAct,errMess, event_com, process_arg1 , basename, remoteFilename, snapshotFilename, dtString :string;
iRes, errCode:integer;
bRes,copResult, canPush: Boolean;
dtRemote : TDateTime;
fa : Longint;

//Lire la taille d'un fichier le plus rapidement possible
function ReadFileSize(filename:string):longint;
var
f:File of Byte;
l:longint;
begin
    Assign(f,filename);
    Reset(f);
        l:= FileSize(f);
    Close(f);
    result := l;
end;



procedure snapShotFile(remoteFile, save_update:AnsiString);
var
  dt:TDateTime;
    fa : Longint;
    dtstr, destfile: AnsiString;
Begin
  fa:=FileAge(remoteFile);
  If fa<>-1 then
   begin
      dt:=FileDateTodateTime(fa);
      dtstr:=DateTimeToStr(dt);
      //créer le fichier :
         process_arg1:=paramstr(7);
         bRes := ForceDirectories( extractFilePath(process_arg1) );
         snapshotLines:= TStringList.create;
         snapshotLines.Text:=dtstr;                          
         basename:=ExtractFileName(process_arg1);
         destfile:=extractFilePath(process_arg1)+EncodeStringBase64(basename);
         snapshotLines.saveToFile(destfile);
         putsNoLn('Remote file infos '+save_update+' : ' ,3);
         Write(destfile+ '    size('+inttostr(ReadFileSize(destfile)) +')');
   end;   
end; //snapShotFile

begin

writeln('VcCopy V1.2');


filepath := getExecutableName;
executablePath := extractFilePath(filepath); 


sFile:='';
sFtpFile:='';
sCreatedirs:='';
 
 
        action:=paramstr(1);    
    
    if(action='upload')then  
    begin        
       //Upload
       curlAct:='Upload';
              curlAction:='Upload';

      sFtpFile:=paramstr(3);       
       sFile:=paramstr(2);  
       relativFile:=paramstr(4);
       context:=paramstr(5);  
           event_com:=paramstr(6);          
       sFtpFile:=sfTpFile + Copy(relativFile, Length(context) +1);

        verbose:=paramstr(8);
   if(verbose='verbose') then begin             
       writeln( 'relativFile=',relativFile);
       writeln( 'context=',context);
       writeln( 'remote file =', sFtpFile);
       writeln('sFile=',sFile);
   end;
       sCreatedirs:=paramstr(4);   


      canPush:=false;

      if(event_com='--check')then
      begin
        //get remote file modification time
         writeln('Check remote file modification date');
         fa := FileAge(sFtpFile);
         If fa<>-1 then
         begin
            dtRemote:=FileDateTodateTime(fa);
            dtString:=Trim( DateTimeToStr(dtRemote) );
            //read snap file
            snapshotFilename:=paramstr(7);
            basename:=ExtractFileName(snapshotFilename);
            destFullname:=extractFilePath(snapshotFilename)+EncodeStringBase64(basename);            
            if(fileExists(destFullname)) then
            begin               
               snapshotLines:= TStringList.create;
               snapshotLines.loadFromFile(destFullname);
              //writeln('snaplines:['+snapshotLines.Text, ']dtstrs:['+dtString+']');
               if( Trim(snapshotLines.Text) = dtString) then
                 begin
                     canPush := true;
                 end else
                 begin
                   puts('Remote file has been modified !', 4);                   
                   writeln('Local  : ', Trim(snapshotLines.Text) );
                   puts   ('Remote : '+dtString, 4);
                 end;
            end 
            else
            begin
              writeln('No Snap found : '+ destFullname);
            end;//endif exists
         end;

        

      end else 
      begin
         canPush:=true;
      end;


      curlAction:=curlAction +' file '+sFile; 

      if(canPush)then
      begin
            copResult := CopyFile(Pchar(sFile), Pchar(sFtpFile), false);             
      end else
      begin      
           puts('Check failed, action cancelled',5);
      end; //end canPush
      
    end else
    begin
        //Download
      curlAct:='Download'; 
      curlAction:='Download';
       sFtpFile:=paramstr(2);    
          destdir:=paramstr(2);  
        relativFile:=paramstr(3);       
         sFile:=paramstr(4);  
       context:=paramstr(5);   
        event_com:=paramstr(6);       
       sFtpFile:=sfTpFile + Copy(relativFile, Length(context) +1);

        verbose:=paramstr(8);
    if(verbose='verbose') then begin      
       writeln('destDir=',destdir);    
       writeln('relativFile=',relativFile);       
       writeln( 'context=',context);
       writeln( 'remote file =',sFtpFile);
       writeln('sFile=',sFile);
    end;
       sCreatedirs:=paramstr(4);
        curlAction:=curlAction + ' -> '+sFile;

       copResult := CopyFile(Pchar(sFtpFile),  Pchar(sFile) ,false //true: fail if exists
                              );      
    end;


    // puts(command, 3); //color 4 = rouge, 2 = vert

    // writeln('Output :'#13#10,sOut);
    writeln('');
   Writeln ('Time : ', DateTimeToStr(Now) );  
    //écrire la curl Action
   puts(curlAction, 9 );


//des erreurs !?
     if( copResult )then
    begin
        //Success
        puts('OK Success', 2); //color 4 = rouge, 2 = vert     
        
        if(event_com='--check')then
        begin
            if(curlAct='Download')then
               begin
                  snapShotFile(sFtpFile, 'saved');
               end;

            if(curlAct='Upload')then
               begin
                snapShotFile(sFtpFile, 'updated');
               end;
        end;

    end else
      begin
         puts('KO Failed',4);
         if( canPush )then begin
          errCode:= GetLastError();
          errMess:=SysErrorMessage(errCode);
            //if( errCode = 80 ) then   begin errMess:=('le fichier existe'+#10);   end;
            writeln('Copy failed : '+ intToStr(errCode) +' '+ errMess);         
        end;
      end;   
 




end.