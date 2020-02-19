unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, Grids, StdCtrls,
  Clipbrd, ExtDlgs, EditBtn, DateUtils;

type

  { TForm1 }

  TForm1 = class(TForm)
    Button1: TButton;
    DateEdit1: TDateEdit;
    Edit1: TEdit;
    Edit2: TEdit;
    Memo1: TMemo;
    sgRozvrh: TStringGrid;
    procedure DateEdit1Change(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure sgRozvrhDragDrop(Sender, Source: TObject; X, Y: Integer);
    procedure sgRozvrhDragOver(Sender, Source: TObject; X, Y: Integer;
      State: TDragState; var Accept: Boolean);
    procedure sgRozvrhMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure sgRozvrhPrepareCanvas(sender: TObject; aCol, aRow: Integer;
      aState: TGridDrawState);
    procedure RotateLeft(var poleZmeny : array of string; velkost_pola, posun_zmeny: smallint);
    procedure Zobraz(poleZmeny : array of string; velkost_pola: smallint);
  private

  public

  end;

type
    TZmena = record
        Majster, Blok, PG, RS : string;
        zmena_cislo : smallint;
        odrobit_Z : smallint;
        posun_zmeny : smallint;
    end;

//type
    //TCisZmeny = array[1..6] of TZmena;

var
  Form1: TForm1;
  //zmena1Marcinek, zmena2Basa : TZmena;
  velkost_pola, posun_zmeny, akt_zmena, max_zmien, i: smallint;
  SourceCol, SourceRow : integer;

  cisloZmeny : array[1..6] of TZmena;

  poleZmeny : array[1..42] of string=('O','O','O','N','N','N','N',
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
  posun_zmeny:= 0; //0,7,14,21,28,35

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

//naplnit fixne
   sgRozvrh.Cells[0,2]:='Blok';
   sgRozvrh.Cells[0,5]:='PG';
   sgRozvrh.Cells[0,7]:='RS';
   sgRozvrh.Cells[0,9]:='Blok';
   sgRozvrh.Cells[0,11]:='PG';
   sgRozvrh.Cells[0,13]:='RS';
   sgRozvrh.Cells[0,15]:='Blok';
   sgRozvrh.Cells[0,17]:='PG';
   sgRozvrh.Cells[0,19]:='RS';
   sgRozvrh.Cells[0,21]:='Z1';
   sgRozvrh.Cells[0,25]:='Z2';
end;

procedure TForm1.RotateLeft(var poleZmeny : array of string; velkost_pola, posun_zmeny: smallint);
var  i,j : smallint;
  temp, akt : string;
begin
  Memo1.Clear;
  for j:=1 to posun_zmeny do
       begin
        temp:= poleZmeny[0];
        for i:=(Low(poleZmeny)) to (High(poleZmeny)) do
            begin
              poleZmeny[i]:= poleZmeny[i+1];
              akt:= poleZmeny[i];
            end;
        poleZmeny[High(poleZmeny)]:= temp;
       end;
  for i:=(Low(poleZmeny)) to (High(poleZmeny)) do
      begin
       Memo1.Append(poleZmeny[i]);
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

procedure TForm1.DateEdit1Change(Sender: TObject);
begin
  for i:=1 to (High(poleZmeny)) do
    begin
        sgRozvrh.Cells[i,0]:= DateToStr(DateOf(DateEdit1.Date+(i-1)));//DateToStr(Date+(i-1));                //poleZmeny[1,i];
        sgRozvrh.Cells[i,1]:= LongDayNames[DayOfWeek(DateEdit1.Date+(i-1))];  //poleZmeny[2,i];
    end;
  RotateLeft(poleZmeny, velkost_pola, posun_zmeny);
  Zobraz(poleZmeny, velkost_pola);
end;

procedure TForm1.Zobraz(poleZmeny : array of string; velkost_pola: smallint);
var i,j: smallint;
begin
  //for j:=1 to 2 do begin
    for i:=(Low(poleZmeny)) to (High(poleZmeny)) do begin
    if poleZmeny[i]='R' then  begin
      sgRozvrh.Cells[i+1,2]:= cisloZmeny[1].Blok;
      sgRozvrh.Cells[i+1,5]:= cisloZmeny[1].PG;
      sgRozvrh.Cells[i+1,7]:= cisloZmeny[1].RS;
    end
    else if poleZmeny[i]='O' then  begin
      sgRozvrh.Cells[i+1,9]:= cisloZmeny[1].Blok;
      sgRozvrh.Cells[i+1,11]:= cisloZmeny[1].PG;
      sgRozvrh.Cells[i+1,13]:= cisloZmeny[1].RS;
    end
    else if poleZmeny[i]='N' then  begin
      sgRozvrh.Cells[i+1,15]:= cisloZmeny[1].Blok;
      sgRozvrh.Cells[i+1,17]:= cisloZmeny[1].PG;
      sgRozvrh.Cells[i+1,19]:= cisloZmeny[1].RS;
    end
    else if poleZmeny[i]='Z1' then  begin
      sgRozvrh.Cells[i+1,21]:= cisloZmeny[1].Blok;
      sgRozvrh.Cells[i+1,22]:= cisloZmeny[1].PG;
      sgRozvrh.Cells[i+1,23]:= cisloZmeny[1].RS;
    end
    else if poleZmeny[i]='Z2' then  begin
      //sgRozvrh.Cells[i,14]:= IntToStr(akt_zmena)+' Z2B';
      //sgRozvrh.Cells[i,15]:= IntToStr(akt_zmena)+' Z2P';
      //sgRozvrh.Cells[i,16]:= IntToStr(akt_zmena)+' Z2R';
    end
    else ;
  	end;
  //end;
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

