unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls;

procedure SplitSpaces(Str: string; ListOfStrings: TStrings);
type

  { TForm1 }

  TForm1 = class(TForm)
    Button1: TButton;
    Memo1: TMemo;
    procedure Button1Click(Sender: TObject);
  private

  public

  end;







var
  Form1: TForm1;


implementation

{$R *.lfm}

{ TForm1 }

procedure TForm1.Button1Click(Sender: TObject);
var lst:TstringList;
begin
      lst:=Tstringlist.create;
      SplitSpaces('100  7882  100  7882    0     0   2966      0  0:00:02  0:00:02 --:--:--  2965',lst);
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
     Form1.Memo1.lines := ListOfStrings;
end;

end.

