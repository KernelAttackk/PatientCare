unit PatientFormUnit;

interface

uses
  Winapi.Windows,
  Winapi.Messages,
  System.SysUtils,
  System.Classes,
  System.DateUtils,
  Vcl.Forms,
  Vcl.Controls,
  Vcl.StdCtrls,
  Vcl.ComCtrls,
  Vcl.Dialogs,
  Data.DB,
  AppointmentsForm,
  FireDAC.Comp.Client,
  AppointmentForm;

type
  TPatientEditForm = class(TForm)
    lblFirstName: TLabel;
    edtFirstName: TEdit;
    lblLastName: TLabel;
    edtLastName: TEdit;
    lblDateOfBirth: TLabel;
    dtpDateOfBirth: TDateTimePicker;
    lblPhone: TLabel;
    edtPhone: TEdit;
    lblEmail: TLabel;
    edtEmail: TEdit;
    btnCancel: TButton;
    btnSave: TButton;
    btnAppointments: TButton;
    procedure FormCreate(Sender: TObject);
    procedure btnCancelClick(Sender: TObject);
    procedure btnSaveClick(Sender: TObject);
    procedure btnAppointmentsClick(Sender: TObject);
  private
    FConnection: TFDConnection;
    FPatientId: Integer;
    FIsEdit: Boolean;

    procedure LoadPatient;
    function ValidateInput: Boolean;
    procedure SavePatient;
  public
    constructor CreatePatient(
      AOwner: TComponent;
      AConnection: TFDConnection;
      APatientId: Integer = 0
    ); reintroduce;
  end;

implementation

{$R *.dfm}

constructor TPatientEditForm.CreatePatient(
  AOwner: TComponent;
  AConnection: TFDConnection;
  APatientId: Integer
);
begin
  inherited Create(AOwner);

  FConnection := AConnection;
  FPatientId := APatientId;
  FIsEdit := FPatientId > 0;
end;

procedure TPatientEditForm.FormCreate(Sender: TObject);
begin
  if FIsEdit then
  begin
    Caption := 'Edit Patient';
    LoadPatient;
  end
  else
  begin
    Caption := 'New Patient';
    dtpDateOfBirth.Date := EncodeDate(1990, 1, 1);
  end;
end;

procedure TPatientEditForm.LoadPatient;
var
  Q: TFDQuery;
begin
  Q := TFDQuery.Create(nil);

  try
    Q.Connection := FConnection;

    Q.SQL.Text :=
      'SELECT FirstName, LastName, DateOfBirth, Phone, Email ' +
      'FROM Patients ' +
      'WHERE Id = :Id';

    Q.ParamByName('Id').DataType := ftInteger;
    Q.ParamByName('Id').AsInteger := FPatientId;

    Q.Open;

    if Q.Eof then
      raise Exception.Create('Patient not found.');

    edtFirstName.Text :=
      Q.FieldByName('FirstName').AsString;

    edtLastName.Text :=
      Q.FieldByName('LastName').AsString;

    edtPhone.Text :=
      Q.FieldByName('Phone').AsString;

    edtEmail.Text :=
      Q.FieldByName('Email').AsString;

    if not Q.FieldByName('DateOfBirth').IsNull then
      dtpDateOfBirth.Date :=
        ISO8601ToDate(
          Q.FieldByName('DateOfBirth').AsString,
          False
        );

  finally
    Q.Free;
  end;
end;

function TPatientEditForm.ValidateInput: Boolean;
begin
  Result := False;

  if Trim(edtFirstName.Text) = '' then
  begin
    MessageDlg(
      'First name is required.',
      mtWarning,
      [mbOK],
      0
    );

    edtFirstName.SetFocus;
    Exit;
  end;

  if Trim(edtLastName.Text) = '' then
  begin
    MessageDlg(
      'Last name is required.',
      mtWarning,
      [mbOK],
      0
    );

    edtLastName.SetFocus;
    Exit;
  end;

  if dtpDateOfBirth.Date > Date then
  begin
    MessageDlg(
      'Date of birth cannot be in the future.',
      mtWarning,
      [mbOK],
      0
    );

    dtpDateOfBirth.SetFocus;
    Exit;
  end;

  Result := True;
end;

procedure TPatientEditForm.SavePatient;
var
  Q: TFDQuery;
  TransactionStarted: Boolean;
begin
  Q := TFDQuery.Create(nil);
  TransactionStarted := False;

  try
    Q.Connection := FConnection;

    FConnection.StartTransaction;
    TransactionStarted := True;

    if FIsEdit then
    begin
      Q.SQL.Text :=
        'UPDATE Patients SET ' +
        'FirstName = :FirstName, ' +
        'LastName = :LastName, ' +
        'DateOfBirth = :DateOfBirth, ' +
        'Phone = :Phone, ' +
        'Email = :Email ' +
        'WHERE Id = :Id';

      Q.ParamByName('Id').DataType := ftInteger;
      Q.ParamByName('Id').AsInteger := FPatientId;
    end
    else
    begin
      Q.SQL.Text :=
        'INSERT INTO Patients ' +
        '(FirstName, LastName, DateOfBirth, Phone, Email, CreatedAt) ' +
        'VALUES ' +
        '(:FirstName, :LastName, :DateOfBirth, :Phone, :Email, :CreatedAt)';
    end;

    Q.ParamByName('FirstName').DataType := ftString;
    Q.ParamByName('FirstName').AsString :=
      Trim(edtFirstName.Text);

    Q.ParamByName('LastName').DataType := ftString;
    Q.ParamByName('LastName').AsString :=
      Trim(edtLastName.Text);

    Q.ParamByName('DateOfBirth').DataType := ftString;
    Q.ParamByName('DateOfBirth').AsString :=
      FormatDateTime(
        'yyyy-mm-dd',
        dtpDateOfBirth.Date
      );

    Q.ParamByName('Phone').DataType := ftString;
    Q.ParamByName('Phone').AsString :=
      Trim(edtPhone.Text);

    Q.ParamByName('Email').DataType := ftString;
    Q.ParamByName('Email').AsString :=
      Trim(edtEmail.Text);

    if not FIsEdit then
    begin
      Q.ParamByName('CreatedAt').DataType := ftString;
      Q.ParamByName('CreatedAt').AsString :=
        FormatDateTime(
          'yyyy-mm-dd hh:nn:ss',
          Now
        );
    end;

    Q.ExecSQL;

    FConnection.Commit;
    TransactionStarted := False;

    ModalResult := mrOk;

  except
    on E: Exception do
    begin
      if TransactionStarted then
        FConnection.Rollback;

      MessageDlg(
        'Unable to save patient.' +
        sLineBreak +
        sLineBreak +
        E.Message,
        mtError,
        [mbOK],
        0
      );
    end;
  end;

  Q.Free;
end;

procedure TPatientEditForm.btnSaveClick(Sender: TObject);
begin
  if ValidateInput then
    SavePatient;
end;

procedure TPatientEditForm.btnAppointmentsClick(Sender: TObject);
var
  Form: TAppointmentsForm;
begin
  if FPatientId = 0 then
  begin
    MessageDlg(
      'Save the patient before managing appointments.',
      mtInformation,
      [mbOK],
      0
    );
    Exit;
  end;

  Form := TAppointmentsForm.CreateForPatient(
    Self,
    FConnection,
    FPatientId,
    Trim(edtFirstName.Text) + ' ' +
    Trim(edtLastName.Text)
  );

  try
    Form.ShowModal;
  finally
    Form.Free;
  end;
end;

procedure TPatientEditForm.btnCancelClick(Sender: TObject);
begin
  ModalResult := mrCancel;
end;

end.