unit uConsole;
{$mode objfpc}{$H+}

interface
   uses  SysUtils,Windows;

procedure textColor(col:integer);
function getTextColor:WORD;
procedure puts(str:string; col:integer);
procedure pause;
function replaceAccents(str:string):string;

implementation

procedure textColor(col:integer);
var hcon:Cardinal;
begin
hcon:=  GetStdHandle(STD_OUTPUT_HANDLE);
SetConsoleTextAttribute(hcon,col);
end;


function getTextColor:WORD;
var
consoleInfo  :	CONSOLE_SCREEN_BUFFER_INFO ;
begin
	GetConsoleScreenBufferInfo(GetStdHandle(STD_OUTPUT_HANDLE),&consoleInfo);
	result:= consoleInfo.wAttributes;
end;


procedure puts(str:string; col:integer);
var
col0:integer;
begin
    col0:= getTextColor;
    textColor(col);
    str:=StringReplace(str,'o',#130,[rfReplaceAll]);
    str:=StringReplace(str,'a',#133,[rfReplaceAll]);
    str:=StringReplace(str,'r',#135,[rfReplaceAll]);
    writeln(str);
    textColor(col0);
end;


//writeln( replaceAccents('É l y À Ici à des accents ét dès non àccentués') );
//Remplacer les caractères accentués pour la console windows  01/02/2020 17:47
function replaceAccents(str:string):string;
begin
  result:=str;
    result:=StringReplace(str,'à',#133,[rfReplaceAll]);
    result:=StringReplace(result,'é',#130,[rfReplaceAll]);
  // result:=StringReplace(result,'r',#135,[rfReplaceAll]);

//À, A accent grave #183
//Ç C cédille: #128
//é e accent aigu: #130
//â a accent circonflexe #131 
//ä a tréma #132
//à, a accent grave : #133
//å #134
//ç, c cédille : #135
//ê e accent circonflex: #136
//ë e tréma #137
//è e accent grave #138
//ï #139

end;


 procedure pause;
 begin
  writeln('pause...'); readln;
 end;


end.
