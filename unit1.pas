unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, Grids, StdCtrls,
  Clipbrd, EditBtn, Menus, DateUtils;

type
  TZmena = record
    Majster, Blok, PG, RS : string;
    zmena_cislo : smallint;
    odrobit_Z : smallint;
    posun_zmeny : smallint;
  end;
  { TForm1 }

  TForm1 = class(TForm)
    btVyber: TButton;
    cbZmena: TComboBox;
    DateEdit1: TDateEdit;
    Edit1: TEdit;
    Label1: TLabel;
    MainMenu1: TMainMenu;
    miKoniec: TMenuItem;
    miNahladMenuItem1: TMenuItem;
    miTlacit: TMenuItem;
    miOtvorit: TMenuItem;
    miSubor: TMenuItem;
    miUlozit: TMenuItem;
    OpenDialog1: TOpenDialog;
    SaveDialog1: TSaveDialog;
    sgRozvrh: TStringGrid;
    procedure btVyberClick(Sender: TObject);
    procedure DateEdit1Exit(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure miUlozitClick(Sender: TObject);
    procedure sgRozvrhDragDrop(Sender, Source: TObject; X, Y: Integer);
    procedure sgRozvrhDragOver(Sender, Source: TObject; X, Y: Integer;
      State: TDragState; var Accept: Boolean);
    procedure sgRozvrhMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure sgRozvrhPrepareCanvas(sender: TObject; aCol, aRow: Integer;
      aState: TGridDrawState);
    procedure RotateLeft(var poleZmeny : array of string; posun : smallint);
    procedure Zobraz(poleZmeny : array of string);
  private

  public

  end;

var
  Form1: TForm1;
  velkost_pola, posun , akt_zmena, max_zmien, i: smallint;
  SourceCol, SourceRow : integer;
  //zmena1, zmena2, zmena3, zmena4, zmena5, zmena6 : TStringList

  prehodeneZmeny : array[1..6] of smallint=(1,6,2,4,5,3);

  cisloZmeny : array[1..6] of TZmena;

  poleZmeny : array[1..42] of string =('O','O','O','N','N','N','N',
                                       'V','V','V','R','R','R','R',
                                       'N','N','N','V','V','V','V',
                                       'R','R','R','O','O','O','O',
                                       'Z2','Z2','Z2','Z2','Z1','Z1','Z1',
                                       'Z1','Z1','Z1','Z1','Z2','Z2','Z2');

const
  origPoleZmeny : array[1..42] of string =('O','O','O','N','N','N','N',
                                       'V','V','V','R','R','R','R',
                                       'N','N','N','V','V','V','V',
                                       'R','R','R','O','O','O','O',
                                       'Z2','Z2','Z2','Z2','Z1','Z1','Z1',
                                       'Z1','Z1','Z1','Z1','Z2','Z2','Z2');

implementation

{$R *.lfm}

{ TForm1 }

procedure TForm1.FormCreate(Sender: TObject);
begin
  //posun_zmeny:= 0; //0,7,14,21,28,35

  with cisloZmeny[1] do
    begin
      Majster := 'Marcinek';
	    Blok := 'Hitka';
	    PG := 'Fabian';
	    RS := 'Morecz';
      zmena_cislo := 1;
      odrobit_Z := 7;
      posun_zmeny:= 0;
    end;
  with cisloZmeny[2] do
    begin
      Majster := 'Basa';
	    Blok := 'Horvath';
	    PG := 'Krajci';
	    RS := 'Svitek';
      zmena_cislo := 2;
      odrobit_Z := 7;
      posun_zmeny:= 28;
    end;
  with cisloZmeny[3] do
    begin
      Majster := 'Casar';
	    Blok := 'Paska';
	    PG := 'Dvoracek';
	    RS := 'Chudy';
      zmena_cislo := 3;
      odrobit_Z := 7;
      posun_zmeny:= 7;
    end;
  with cisloZmeny[4] do
    begin
      Majster := 'Vida';
	    Blok := 'Racz';
	    PG := 'Haluz';
	    RS := 'Porubec';
      zmena_cislo := 4;
      odrobit_Z := 7;
      posun_zmeny:= 21;
    end;
  with cisloZmeny[5] do
    begin
      Majster := 'Meszaros';
	    Blok := 'Menhart';
	    PG := 'Trnkus';
	    RS := 'Bona';
      zmena_cislo := 5;
      odrobit_Z := 7;
      posun_zmeny:= 14;
    end;
  with cisloZmeny[6] do
    begin
      Majster := 'Hlavacek';
	    Blok := 'Morvay';
	    PG := 'Dubravsky';
	    RS := 'Geleneky';
      zmena_cislo := 6;
      odrobit_Z := 7;
      posun_zmeny:= 35;
    end;

//naplnit fixne
   sgRozvrh.Cells[0,2]:='R - Blok';
   sgRozvrh.Cells[0,5]:='R - PG';
   sgRozvrh.Cells[0,7]:='R - RS';
   sgRozvrh.Cells[0,9]:='O - Blok';
   sgRozvrh.Cells[0,11]:='O - PG';
   sgRozvrh.Cells[0,13]:='O - RS';
   sgRozvrh.Cells[0,15]:='N - Blok';
   sgRozvrh.Cells[0,17]:='N - PG';
   sgRozvrh.Cells[0,19]:='N - RS';
   sgRozvrh.Cells[0,21]:='Z1';
   sgRozvrh.Cells[0,25]:='Z2';

end;

procedure TForm1.miUlozitClick(Sender: TObject);
begin
  if SaveDialog1.Execute then sgRozvrh.SaveToFile(SaveDialog1.FileName);
end;

procedure TForm1.RotateLeft(var poleZmeny : array of string; posun : smallint);
var  i,j,k : smallint;
  temp : string;
begin
  for j:=1 to posun do begin
    temp:= poleZmeny[0];   //odlozim prvu aby som ju mohol zaradit na koniec
    for i:=(Low(poleZmeny)) to (High(poleZmeny)) do begin
         if i < High(PoleZmeny) then begin   //pozor aby si neprekrocil
           poleZmeny[i]:= poleZmeny[i+1]     //lebo tu budes citat za rozsahom
           end
         else
           poleZmeny[High(poleZmeny)]:= temp;
    end;
  end;
end;

//---------farby riadkov------------------------

procedure TForm1.sgRozvrhPrepareCanvas(sender: TObject; aCol, aRow: Integer;
  aState: TGridDrawState);
begin
   if not (gdfixed in aState) then
     case aRow of
      	2,3,4,9,10,15,16: sgRozvrh.Canvas.Brush.Color := clAqua;
        5,6,11,12,17,18 : sgRozvrh.Canvas.Brush.Color := clLime;
      	7,8,13,14,19,20	: sgRozvrh.Canvas.Brush.Color := clYellow;
      	21..24					: sgRozvrh.Canvas.Brush.Color := clRed;
     end;
end;

//----------vypis datumy+mena------------------------

procedure TForm1.btVyberClick(Sender: TObject);
var i: smallint;
begin
  for i:=1 to (High(poleZmeny)) do
    begin
        sgRozvrh.Cells[i,0]:= DateToStr(DateOf(DateEdit1.Date+(i-1)));
        sgRozvrh.Cells[i,1]:= DefaultFormatSettings.LongDayNames[DayOfWeek(DateEdit1.Date+(i-1))];
    end;

  case cbZmena.ItemIndex of
     0 :  posun:= 0;    //zmena1
     1 :  posun:= 28;
     2 :  posun:= 7;    //zmena3
     3 :  posun:= 21;
     4 :  posun:= 14;    //zmena5
     5 :  posun:= 35;
  end;
  Zobraz(poleZmeny);
end;

procedure TForm1.Zobraz(poleZmeny : array of string);
var i,j, k: smallint;
begin
  //j:= 1;
  //posun:= 0;
  for j:=Low(prehodeneZmeny) to High(prehodeneZmeny) do begin
    k:=prehodeneZmeny[j];
    //cisloZmeny[k].Blok;
    RotateLeft(poleZmeny, posun);

      for i:=(Low(poleZmeny)) to (High(poleZmeny)) do begin
        if poleZmeny[i]='R' then  begin
          sgRozvrh.Cells[i+1,2]:= cisloZmeny[k].Blok;
          sgRozvrh.Cells[i+1,5]:= cisloZmeny[k].PG;
          sgRozvrh.Cells[i+1,7]:= cisloZmeny[k].RS;
        end
        else if poleZmeny[i]='O' then  begin
          sgRozvrh.Cells[i+1,9]:= cisloZmeny[k].Blok;
          sgRozvrh.Cells[i+1,11]:= cisloZmeny[k].PG;
          sgRozvrh.Cells[i+1,13]:= cisloZmeny[k].RS;
        end
        else if poleZmeny[i]='N' then  begin
          sgRozvrh.Cells[i+1,15]:= cisloZmeny[k].Blok;
          sgRozvrh.Cells[i+1,17]:= cisloZmeny[k].PG;
          sgRozvrh.Cells[i+1,19]:= cisloZmeny[k].RS;
        end
        else if poleZmeny[i]='Z1' then  begin
          sgRozvrh.Cells[i+1,21]:= cisloZmeny[k].Blok;
          sgRozvrh.Cells[i+1,22]:= cisloZmeny[k].PG;
          sgRozvrh.Cells[i+1,23]:= cisloZmeny[k].RS;
        end
        else if poleZmeny[i]='Z2' then  begin
          //sgRozvrh.Cells[i,14]:= IntToStr(akt_zmena)+' Z2B';
          //sgRozvrh.Cells[i,15]:= IntToStr(akt_zmena)+' Z2P';
          //sgRozvrh.Cells[i,16]:= IntToStr(akt_zmena)+' Z2R';
        end;
  	  end;
    posun:= 7;
  end;
end;

//---------kontrola pondelka--------------------------

procedure TForm1.DateEdit1Exit(Sender: TObject);
begin
  if DayOfWeek(DateEdit1.Date) <> 2 then ShowMessage('Musíš vybrať Pondelok');
end;

//--------Drag and Drop + Kopirovanie bunky---------

procedure TForm1.sgRozvrhDragDrop(Sender, Source: TObject; X, Y: Integer);
var
  DestCol, DestRow : integer;
begin
	sgRozvrh.MouseToCell(X,Y,DestCol,DestRow);

  sgRozvrh.Cells[DestCol,DestRow] := sgRozvrh.Cells[SourceCol,SourceRow];
  if (SourceCol <> DestCol) or (SourceRow <> DestRow) then
    sgRozvrh.Cells[SourceCol,SourceRow] := '';
end;

procedure TForm1.sgRozvrhDragOver(Sender, Source: TObject; X, Y: Integer;
  State: TDragState; var Accept: Boolean);
var
  CurrentCol, CurrentRow: integer;
begin
  sgRozvrh.MouseToCell(X,Y,CurrentCol, CurrentRow);

  Accept := (Sender = Source) and (CurrentCol > 0) and (CurrentRow > 1);
end;

procedure TForm1.sgRozvrhMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
	//takto sa preklapa z X/Y na Col/Row
	sgRozvrh.MouseToCell(X,Y,SourceCol,SourceRow);
  //netahaj fixovane bunky
  if (SourceCol > 0) and (SourceRow > 1) then
    begin
	    case Button of 	//lave tlacidlo mysi tahanie obsahu
       	mbLeft :  sgRozvrh.BeginDrag(False, 4);  //zachyt az ked mys prejde 4 pixely
      	mbRight :     //prave tlacidlo vyzva na kopirovanie
   	      case QuestionDlg ('Caption','Kopirovat do schranky alebo vlozit zo schranky?',mtCustom,[mrYes,'Kopirovat', mrNo, 'Vlozit', 'IsDefault'],'') of
              mrYes: begin
                   ClipBoard.AsText:= sgRozvrh.Cells[SourceCol, SourceRow];
                   Edit1.Text:= ClipBoard.AsText;
                   sgRozvrh.Cells[SourceCol, SourceRow]:= ''; //vyprazdni bunku po skopirovani
         	      end;
              mrNo:  begin
        		      sgRozvrh.Cells[SourceCol, SourceRow]:= Clipboard.AsText;
        		      Edit1.Text:= ClipBoard.AsText;
          	      Clipboard.Clear;
        	      end;
              mrCancel: QuestionDlg ('Caption','You canceled the dialog with ESC or close button.',mtCustom,[mrOK,'Exactly'],'');
          end;
	    end;
  end;
end;

end.

