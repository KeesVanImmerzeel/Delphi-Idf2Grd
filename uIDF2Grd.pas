unit uIDF2Grd;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, uSelectIDFfile,
  StdCtrls, uSpecifyBndBox, uESRI, uTSingleESRIgrid, uError, FileCtrl, inifiles, Math,
  CheckLst, OpWString, ComCtrls, Registry, AVGRIDIO;

type
  TMainForm = class(TForm)
    GroupBoxSingleFile: TGroupBox;
    ButtonTestSelectIDFfile: TButton;
    Button2: TButton;
    EditESRIgridfileName: TEdit;
    Label_IDFfile: TLabel;
    CheckBoxMultipleFileUse: TCheckBox;
    GroupBoxMultipleFileUse: TGroupBox;
    ButtonBndBox: TButton;
    Button3: TButton;
    LabelOutputDir: TLabel;
    ButtonGoMultipleFileUse: TButton;
    ButtonSelectInputFolder: TButton;
    LabelInputDir: TLabel;
    CheckListBox1: TCheckListBox;
    CheckBox1: TCheckBox;
    ButtonClear: TButton;
    ProgressBar1: TProgressBar;
    EditMinFractMtGeg: TEdit;
    Label1: TLabel;
    UseBndBox: TCheckBox;
    CheckBoxESRIgridFormat: TCheckBox;
    CheckBoxExportEsriASCformat: TCheckBox;
    procedure FormCreate(Sender: TObject);
    procedure ButtonTestSelectIDFfileClick(Sender: TObject);
    procedure ButtonBndBoxClick(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure CheckBoxMultipleFileUseClick(Sender: TObject);
    procedure ButtonSelectInputFolderClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure CheckBox1Click(Sender: TObject);
    procedure ButtonClearClick(Sender: TObject);
    procedure ButtonGoMultipleFileUseClick(Sender: TObject);
    procedure RefreshIDFfileListbox( const Dir: TFileName );
    procedure UseBndBoxClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    { Private declarations }

    // When loading the package, an instance of a form will be created.
    // To create forms SelectIDFfile and BndBoxDlg
    //FHandle_ServiceComponents: THandle;

  public
    { Public declarations }
    FIniFile: TRegIniFile;
  end;
  TMode = (Batch, Interactive);

var
  MainForm: TMainForm;

  IDFfileNames: TFileName;
  inBndBox: TBndBox;
  //aBndBoxDlg: TBndBoxDlg;
  SingleESRIgrid1 : TSingleESRIgrid;
  BaseDir: String;
  IDFfileNamesList: TStringList;

implementation

{$R *.DFM}

Function PositionInList( const aString: String ): integer;
var
  i: Integer;
begin
  Result := -1;
  for i := 0 to IDFfileNamesList.Count - 1 do begin
    if Pos( aString, IDFfileNamesList[i]) > 0 then begin
      Result := i;
      Exit;
    end;
  end;
end;

procedure TMainForm.RefreshIDFfileListbox( const Dir: TFileName );
var
  S: String;
  SearchRec: TSearchRec;
  i: Integer;
begin

    LabelInputDir.Caption := Dir;
    CheckListBox1.Clear;
    FIniFile.WriteString( 'Settings', 'InputDir', ExpandFileName( Dir ) );
    if ( FindFirst('*.idf', faAnyFile, SearchRec) = 0 ) then begin
      S := SearchRec.Name;
      WriteToLogFile(  'S=[' + S + ']' );
      if PositionInList( S )>-1 then begin
        CheckListBox1.Items.Add( S );
        {WriteToLogFile(  'Is in list' );}
      end else
        {WriteToLogFile(  'Is not in list' )};
      while( FindNext( SearchRec ) = 0 ) do begin
        S := SearchRec.Name;
        if PositionInList( S )>-1 then begin
          CheckListBox1.Items.Add( S );
          {WriteToLogFile(  'Is in list' )};
        end else
          {WriteToLogFile(  'Is not in list' )};
      end;
    end;
    FindClose( SearchRec );
    for i:=0 to CheckListBox1.items.count-1 do
      CheckListBox1.Checked[i] := true;
end;


procedure TMainForm.FormCreate(Sender: TObject);
begin
  InitialiseLogFile;
  Caption := ExtractFileName( ChangeFileExt( ParamStr( 0 ), '' ) );
  //SelectIDFfile := TSelectIDFfile.Create( self );
  // Load Package "ServiceComponents.bpl"
  //FHandle_ServiceComponents := LoadPackage('ServiceComponents.bpl');
  LabelOutputDir.Caption := BaseDir;
  IDFfileNamesList := TStringList.Create;
  FIniFile := TRegIniFile.Create('Idf2Grd');
  LabelInputDir.Caption := FIniFile.ReadString( 'Settings', 'InputDir', '___________' );
  if not SysUtils.DirectoryExists( LabelInputDir.Caption ) then
    LabelInputDir.Caption := '___________' else
  RefreshIDFfileListbox( LabelInputDir.Caption );

  LabelOutputDir.Caption := FIniFile.ReadString( 'Settings', 'OutputDir', '___________' );
  if not SysUtils.DirectoryExists( LabelOutputDir.Caption ) then begin
    LabelOutputDir.Caption := '___________';
  end else begin
    BaseDir := LabelOutputDir.Caption;
  end;
  if InitialiseGridIO <> cNoError
   then Application.Terminate;
end;

procedure TMainForm.FormDestroy(Sender: TObject);
begin
FinaliseLogFile;
end;

procedure TMainForm.ButtonTestSelectIDFfileClick(Sender: TObject);
var
  iResult: Integer;
  aFileName: TFileName;
begin
  SelectIDFfile := TSelectIDFfile.Create(self);
  if SelectIDFfile.ShowModal = mrOK then begin
    aFileName := SelectIDFfile.IDFFileName;
    SingleESRIgrid1 := TSingleESRIgrid.InitialiseFromIDFfile( aFileName, iResult, self );
    Label_IDFfile.Caption := aFileName;
    ShowMessageFmt( 'File selected: [%s]; iResult = %d', [aFileName, iResult] ) ;
    EditESRIgridfileName.text := BaseDir + '\' + SingleESRIgrid1.ID;
  end else
    ShowMessage( 'No IDF-file selected.' );
  SelectIDFfile.Free;
end;

procedure TMainForm.ButtonBndBoxClick(Sender: TObject);
begin
  BndBoxDlg := TBndBoxDlg.Create( self );
  BndBoxDlg.ShowModal( inBndBox, 25, inBndBox );
  WriteToLogFileFmt( 'cxMin: %g', [inBndBox[cxMin]] );
  WriteToLogFileFmt( 'cyMax:%g', [inBndBox[cyMax]] );
  WriteToLogFileFmt( 'cxMax:%g', [inBndBox[cxMax]] );
  WriteToLogFileFmt( 'cyMin:%g', [inBndBox[cYmin]] );
  BndBoxDlg.Free;
end;

procedure TMainForm.Button2Click(Sender: TObject);
var
  iResult: Integer;
  FileName: TFileName;
begin
  FileName := EditESRIgridfileName.Text;
  WriteToLogFileFmt(  'FileName = %s', [FileName] );
  if UseBndBox.Checked then
    iResult := SingleESRIgrid1.SaveAs( FileName, inBndBox )
  else
    iResult := SingleESRIgrid1.SaveAs( FileName );
  if ( iResult = cNoError ) then
      ShowMessage( 'ESRI grid succesfully saved.' )
    else
      ShowMessage( 'Error saving ESRI grid.' );
  SingleESRIgrid1.Free;
end;

procedure TMainForm.Button3Click(Sender: TObject);
var
  ResultDir: String;
begin
  ResultDir := BaseDir;
   if SelectDirectory( ResultDir, [sdAllowCreate, sdPerformCreate, sdPrompt], 0 ) then begin
    BaseDir := ResultDir;
    LabelOutputDir.Caption := BaseDir;
    FIniFile.WriteString( 'Settings', 'OutputDir', ExpandFileName( BaseDir ) );
  end;
end;

procedure TMainForm.Button4Click(Sender: TObject);
var
  i, j, NCols, NRows: LongInt;
begin
  NCols := SingleESRIgrid1.NCols;
  NRows := SingleESRIgrid1.NRows;
  for i:=1 to NRows do
    for j:=1 to NCols do
      SingleESRIgrid1[ i, j ] := SingleESRIgrid1[ i, j ] + 1;

  ShowMessage( 'finished.' );

end;

procedure TMainForm.CheckBoxMultipleFileUseClick(Sender: TObject);
begin
  GroupBoxSingleFile.Visible := not( GroupBoxSingleFile.Visible );
  GroupBoxMultipleFileUse.Visible := not( GroupBoxMultipleFileUse.Visible );
end;

procedure TMainForm.ButtonSelectInputFolderClick(Sender: TObject);
var
  Dir: String;
begin
  if SysUtils.DirectoryExists( LabelInputDir.Caption ) then
    Dir := LabelInputDir.Caption;
  if SelectDirectory(  Dir, [], 0 ) then
    RefreshIDFfileListbox( Dir );
end;

procedure TMainForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  IDFfileNamesList.Free;
  FIniFile.Free;

  //UnloadPackage(FHandle_ServiceComponents);

end;

procedure TMainForm.CheckBox1Click(Sender: TObject);
var
  i: Integer;
  Dir: TFileName;
begin
  CheckListBox1.Visible := not  CheckListBox1.Visible;
  ButtonClear.Visible := not ButtonClear.Visible;
  Dir := Trim( LabelInputDir.Caption ); WriteToLogFile(  'Dir = [' + Dir + ']' );
  if SysUtils.DirectoryExists( Dir ) then begin
    WriteToLogFile(  'RefreshIDFfileListbox' );
    RefreshIDFfileListbox( Dir )
  end else
    ButtonSelectInputFolder.Click;
  {if  CheckBox1.Checked then begin}
    for i:=0 to CheckListBox1.items.count-1 do
      CheckListBox1.Checked[i] := true;
  {end;}
end;
procedure TMainForm.ButtonClearClick(Sender: TObject);
var
  i: Integer;
begin
  for i:=0 to CheckListBox1.items.count-1 do
      CheckListBox1.Checked[i] := false;
end;

procedure TMainForm.ButtonGoMultipleFileUseClick(Sender: TObject);
var
  i, j, iResult, Len, nrChecked, iCount, iCountASC: Integer;
  inFileName, OutFileName: TFileName;
  Fract: Double;
const
  WordDelims = [' '];

begin
  nrChecked := 0;
  for i:=0 to CheckListBox1.items.count-1 do
    if CheckListBox1.Checked[i] then
     Inc( nrChecked );
  WriteToLogFileFmt(  'nrChecked: %d.', [nrChecked] );

  with ProgressBar1 do begin
    Visible := true;
    Min := 0;
    Max :=  nrChecked;
    Smooth := true;
  end;
  iCount := 0; iCountASC := 0;

  for i:=0 to CheckListBox1.items.count-1 do begin
    if CheckListBox1.Checked[ i ] then begin
      try
        try
          inFileName := LabelInputDir.caption + '\' +
            ExtractWord( 1,  CheckListBox1.items[ i ] , WordDelims, Len );
          WriteToLogFile(  'inFileName=[' + inFileName + ']' );
          j := PositionInList( CheckListBox1.items[ i ] );
          OutFileName :=  LabelOutputDir.Caption + '\' +
            ExtractWord( 2,  IDFfileNamesList[ j ] , WordDelims, Len );
          WriteToLogFile(  'outFileName=[' + outFileName + ']' );
          SingleESRIgrid1 := TSingleESRIgrid.InitialiseFromIDFfile( InFileName, iResult, self );
          WriteToLogFileFmt(  'Fraction of data filled: %g', [SingleESRIgrid1.FractionOfAreaWithData] );
          Fract := StrToFloat( Trim( EditMinFractMtGeg.text ) );

          if SingleESRIgrid1.FractionOfAreaWithData > Fract then begin
            if CheckBoxESRIgridFormat.Checked then begin
              if ( SingleESRIgrid1.SaveAs( OutFileName, inBndBox ) = cNoError ) then begin
                Inc( iCount );
                WriteToLogFile(  'Dataset [' + SingleESRIgrid1.FileName + '] saved to Esri grid file.' );
              end else begin
                WriteToLogFile(  'Dataset [' + SingleESRIgrid1.FileName + '] could NOT be saved to Esri grid file.' );
              end;
            end;
            if CheckBoxExportEsriASCformat.Checked then begin
              if ( SingleESRIgrid1.ExportToASC( ChangeFileExt( OutFileName, '.asc' ), inBndBox ) = cNoError ) then begin
                Inc( iCountASC );
                 WriteToLogFile(  'Dataset [' + SingleESRIgrid1.FileName + '] saved to Esri ASC file.' );
              end else begin
                WriteToLogFile(  'Dataset [' + SingleESRIgrid1.FileName + '] could NOT be saved to Esri ASC file.' );
              end;
            end;
          end else begin
            WriteToLogFile(  'Dataset [' + SingleESRIgrid1.FileName + '] is empty. Not saved.' );
          end;
          {SingleESRIgrid1.Free;}
          ProgressBar1.Position := ProgressBar1.Position + 1;
        except
        end
      finally
        {MessageDlg( 'Exiting the Object Pascal application.', mtInformation, [mbOk], 0);}
      end;
    end;
  end;
  if CheckBoxESRIgridFormat.Checked then
    ShowMessageFmt( '%d Datasets are exported in Esri grid format', [iCount] );
  if CheckBoxExportEsriASCformat.Checked then
     ShowMessageFmt( '%d Datasets are exported in Esri ASC grid format', [iCountASC] );

  ProgressBar1.Visible := false;
end;

procedure TMainForm.UseBndBoxClick(Sender: TObject);
begin
  ButtonBndBox.Visible := not  ButtonBndBox.Visible;
end;

initialization
  inBndBox[0] := 201000;
  inBndBox[1] := 545000;
  inBndBox[2] := 225000;
  inBndBox[3] := 570000;
  BaseDir := 'c:\';
finalization
end.
