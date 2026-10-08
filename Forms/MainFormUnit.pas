unit MainFormUnit;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Error, FireDAC.UI.Intf, FireDAC.Phys.Intf, FireDAC.Stan.Def,
  FireDAC.Stan.Pool, FireDAC.Stan.Async, FireDAC.Phys, FireDAC.VCLUI.Wait,
  FireDAC.Stan.Param, FireDAC.DatS, FireDAC.DApt.Intf, FireDAC.DApt,
  FireDAC.Stan.ExprFuncs, FireDAC.Phys.SQLiteWrapper.Stat,
  DatabaseManager, PatientRepository, PatientFormUnit,
  FireDAC.Phys.SQLiteDef, FireDAC.Phys.SQLite, Data.DB, FireDAC.Comp.DataSet,
  FireDAC.Comp.Client, Vcl.ComCtrls, Vcl.Grids, Vcl.DBGrids, Vcl.StdCtrls,
  Vcl.ExtCtrls;


type
  TMainForm = class(TForm)
    pnlTop: TPanel;
    lblSearch: TLabel;
    edtSearch: TEdit;
    btnSearch: TButton;
    btnClear: TButton;
    grdPatients: TDBGrid;
    StatusBar: TStatusBar;
    dsPatients: TDataSource;

    btnNewPatient: TButton;
    btnEditPatient: TButton;
    btnDeletePatient: TButton;

    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure edtSearchKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure btnSearchClick(Sender: TObject);
    procedure btnClearClick(Sender: TObject);
    procedure btnNewPatientClick(Sender: TObject);
    procedure btnEditPatientClick(Sender: TObject);
    procedure grdPatientsDblClick(Sender: TObject);
    procedure btnDeletePatientClick(Sender: TObject);
  private
    FDatabase: TDatabaseManager;
    FPatients: TPatientRepository;
    FDataSet: TDataSet;
    procedure SearchPatients;
    procedure EditSelectedPatient;

  public
    { Public declarations }
  end;

var
  MainForm: TMainForm;

implementation

{$R *.dfm}

procedure TMainForm.SearchPatients;
var
  StartTime: Cardinal;
begin
  if not Assigned(FPatients) then
    Exit;

  StartTime := GetTickCount;

  Screen.Cursor := crHourGlass;
  try
    dsPatients.DataSet := nil;

    FreeAndNil(FDataSet);

    FDataSet := FPatients.Search(
      Trim(edtSearch.Text)
    );

    dsPatients.DataSet := FDataSet;

    StatusBar.SimpleText :=
      Format(
        'Database: Connected | Records shown: %d | Query: %d ms',
        [
          FDataSet.RecordCount,
          GetTickCount - StartTime
        ]
      );
  finally
    Screen.Cursor := crDefault;
  end;
end;

procedure TMainForm.btnClearClick(Sender: TObject);
begin
  edtSearch.Clear;
  SearchPatients;
  edtSearch.SetFocus;
end;

procedure TMainForm.btnDeletePatientClick(Sender: TObject);
var
  PatientId: Integer;
  PatientName: string;
  Q: TFDQuery;
begin
  if (FDataSet = nil) or FDataSet.IsEmpty then
    Exit;

  PatientId := FDataSet.FieldByName('Id').AsInteger;

  PatientName :=
    FDataSet.FieldByName('FirstName').AsString + ' ' +
    FDataSet.FieldByName('LastName').AsString;

  if MessageDlg(
       'Delete patient "' + PatientName + '"?' +
       sLineBreak + sLineBreak +
       'This action cannot be undone.',
       mtConfirmation,
       [mbYes, mbNo],
       0
     ) <> mrYes then
    Exit;

  Q := TFDQuery.Create(nil);

  try
    Q.Connection := FDatabase.Connection;

    FDatabase.Connection.StartTransaction;

    try
      Q.SQL.Text :=
        'DELETE FROM Patients WHERE Id = :Id';

      Q.ParamByName('Id').DataType := ftInteger;
      Q.ParamByName('Id').AsInteger := PatientId;

      Q.ExecSQL;

      FDatabase.Connection.Commit;
    except
      FDatabase.Connection.Rollback;
      raise;
    end;

    SearchPatients;

  except
    on E: Exception do
      MessageDlg(
        'Unable to delete patient.' +
        sLineBreak + sLineBreak +
        E.Message,
        mtError,
        [mbOK],
        0
      );
  end;

  Q.Free;
end;


procedure TMainForm.btnEditPatientClick(Sender: TObject);
begin
  EditSelectedPatient;
end;


procedure TMainForm.btnNewPatientClick(Sender: TObject);
var
  PatientForm: TPatientEditForm;
begin
  PatientForm := TPatientEditForm.CreatePatient(
    Self,
    FDatabase.Connection,
    0
  );

  try
    if PatientForm.ShowModal = mrOk then
      SearchPatients;
  finally
    PatientForm.Free;
  end;
end;


procedure TMainForm.btnSearchClick(Sender: TObject);
begin
  SearchPatients;
end;

procedure TMainForm.edtSearchKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_RETURN then
  begin
    SearchPatients;
    Key := 0;
  end;
end;

procedure TMainForm.FormCreate(Sender: TObject);
begin
  FDatabase := TDatabaseManager.Create;

  try
    FDatabase.Connect;

    FPatients := TPatientRepository.Create(FDatabase.Connection);

    SearchPatients;

    Caption := 'PatientCare Desktop';
  except
    on E: Exception do
    begin
      ShowMessage(
        'Initialization error:'#13#10 +
        E.ClassName + #13#10 +
        E.Message
      );

      Application.Terminate;
    end;
  end;
end;

procedure TMainForm.FormDestroy(Sender: TObject);
begin
  FDatabase.Free;
end;



procedure TMainForm.grdPatientsDblClick(Sender: TObject);
begin
EditSelectedPatient;
end;

procedure TMainForm.EditSelectedPatient;
var
  PatientForm: TPatientEditForm;
  PatientId: Integer;
begin
  if (FDataSet = nil) or FDataSet.IsEmpty then
    Exit;

  PatientId := FDataSet.FieldByName('Id').AsInteger;

  PatientForm := TPatientEditForm.CreatePatient(
    Self,
    FDatabase.Connection,
    PatientId
  );

  try
    if PatientForm.ShowModal = mrOk then
      SearchPatients;
  finally
    PatientForm.Free;
  end;
end;

end.
