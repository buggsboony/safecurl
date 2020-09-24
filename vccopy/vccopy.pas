program safecurl;

{$mode objfpc}
uses windows, Process, sysutils,  classes, uMemo, uConsole;




var
command, lastline, verbose, destdir,relativFile, localFile, context, filepath, executablePath,action, sOut,curlAction, sFile,sFtpFile,sCreatedirs, sForward : ansistring;
list:TSTringList;
destFullDir,destFullname,errMess:string;
errCode:integer;
copResult: Boolean;
begin

writeln('VcCopy V1.0');


filepath := getExecutableName;
executablePath := extractFilePath(filepath); 


sFile:='';
sFtpFile:='';
sCreatedirs:='';
 
 
        action:=paramstr(1);    
    
    if(action='upload')then  
    begin        
       //Upload
              curlAction:='Upload';

      sFtpFile:=paramstr(3);       
       sFile:=paramstr(2);  
       relativFile:=paramstr(4);
       context:=paramstr(5);       
       sFtpFile:=sfTpFile + Copy(relativFile, Length(context) +1);

        verbose:=paramstr(6);
    if(verbose='verbose') then begin             
       writeln( 'relativFile=',relativFile);
       writeln( 'context=',context);
       writeln( 'remote file =',sFtpFile);
       writeln('sFile=',sFile);
    end;
       sCreatedirs:=paramstr(4);   

       copResult := CopyFile(Pchar(sFile), Pchar(sFtpFile)  ,false);      

        curlAction:=curlAction +' file '+sFile;        
    
    end else
    begin
        //Download
        curlAction:='Download'; 
       sFtpFile:=paramstr(2);    
          destdir:=paramstr(2);  
        relativFile:=paramstr(3);       
         sFile:=paramstr(4);  
       context:=paramstr(5);       
       sFtpFile:=sfTpFile + Copy(relativFile, Length(context) +1);

        verbose:=paramstr(6);
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
    end else
      begin
         puts('KO Failed',4);
          errCode:= GetLastError();
          errMess:=SysErrorMessage(errCode);
            //if( errCode = 80 ) then   begin errMess:=('le fichier existe'+#10);   end;
        writeln('Copy failed : '+ intToStr(errCode) +' '+ errMess);         
      end;   
 




end.