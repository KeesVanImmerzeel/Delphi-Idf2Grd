program Idf2Grd;

{$R '..\..\ServiceComponents\ESRI\TSingleESRIgrid\SelectIDFfile\uSelectIDFfile.dfm' :TForm(uSelectIDFfile)}

uses
  Forms,
  Sysutils,
  AVGRIDIO,
  uError,
  uIDF2Grd in 'uIDF2Grd.pas' {MainForm};

{$R *.RES}

begin
  Application.Initialize;

  InitialiseGridIO;

  Application.CreateForm(TMainForm, MainForm);
  {Application.CreateForm(TRegIniForm, RegIniForm); }
  Try
    Try
      IDFfileNames := ExpandFileName( ChangeFileExt( LogFileName, '.txt' ) );
      WriteToLogFile(  'IDFfileNames: [' + IDFfileNames + '].' );
      if not FileExists( IDFfileNames ) then begin
        HandleError( 'File: [' + IDFfileNames + '] does not exist.', true );
        Exit;
      end;
      IDFfileNamesList.LoadFromFile( IDFfileNames );
      IDFfileNamesList.SaveToFile( ChangeFileExt( LogFileName , '.tmp' ) );
      if ( ParamCount >= 2 ) then begin
      end;
      Application.Run;
    Except
      WriteToLogFile(  Format( 'Error in application: [%s].', [ApplicationFileName] ) );
    end;
  Finally
  end;
end.
