unit uMemo;

interface
uses windows, ShellApi, sysutils,classes;



function execute(command:AnsiString):integer;
function execute(command,args:AnsiString):integer;
 

 
//------------ Fonction messagebox ----------------
//messagebox function
procedure box(text:AnsiString; title:AnsiString);overload;
//messagebox function
procedure box(text:AnsiString);overload;
procedure ebox(text:AnsiString);
function askbox(question:ansistring; title:AnsiString):boolean;
//messagebox function
procedure disp( i :integer; title:AnsiString);

//---------------------------  List utils

function joinStr(c:char; strings:TstringList):ansistring;


//----------------------------------------------

function getExecutableName():string;


//----------------  Unix timestamp ---------------------
function getTimeStamp(dt:TDatetime):longint;
function getTimeStamp():longint;






function splitString(Delimiter:Char; line:AnsiString):TStringList;
 























implementation


function execute(command,args:AnsiString):integer;
begin  
 execute := shellExecute(0,nil, PChar(command), PChar(args),nil,1);
end;

function execute(command:AnsiString):integer;
begin  
    execute := execute(command,'');
end;







//--------------------------

//messagebox function
procedure box(text:AnsiString; title:AnsiString);overload;
begin
     MessageBox(0,pchar(text),pchar(title),0);
end;
//messagebox function
procedure box(text:AnsiString);overload;
begin
     MessageBox(0,pchar(text),'box',0);
end;

procedure ebox(text:AnsiString);
begin
     MessageBox(0,pchar(text),'box', MB_ICONERROR);
end;


function askbox(question:ansistring; title:AnsiString):boolean;
begin
  if( MessageBox(0,Pchar(question),pchar(title), 1) = 1) then
  begin
    askbox:=true;
  end else
  begin
    askbox:=false;
  end;
end;
//messagebox function
procedure disp( i :integer; title:AnsiString);
begin
     MessageBox(0,pchar(IntToStr(i)),pchar(title),0);
end;



//join string list

function joinStr(c:char; strings:TstringList):ansistring;
begin
                 strings.Delimiter:=c;

              joinStr:=(strings.DelimitedText);
end;     





function getExecutableName():string;
var 
AppFileName,buffer:array[0..260] of char;
begin
    //       StrPLCopy(AppFileName, ApplicationFileName, 15);
  //  GetModuleFileName(GetModuleHandle(AppFileName), Buffer, SizeOf(Buffer));
  GetModuleFileName(0,
  buffer,
  SizeOf(buffer)
  ); //r: 58

  getExecutableName:=ansistring(buffer); 
end;


function getTimeStamp(dt:TDatetime):longint;
begin
  getTimeStamp :=    Trunc( (dt - EncodeDate(1970, 1 ,1)) * 24 * 60 * 60)    
end;


function getTimeStamp():longint;
begin
  getTimeStamp :=  getTimeStamp(Now);   
end;



function splitString(Delimiter:Char; line:AnsiString):TStringList;
var ts : TStringList;
begin
  ts:= TstringList.create;
  ts.Delimiter := Delimiter;
  ts.DelimitedText := line;   
  splitString := ts;
end;



 
end.