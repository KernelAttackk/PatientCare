unit AppointmentForm;

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
  FireDAC.Comp.Client;

type
  TAppointmentEditForm = class(TForm)
    lblDate: TLabel;
    dtpDate: TDateTimePicker;
    lblTime: TLabel;
    dtpTime: TDateTimePicker;
    lblDoctor: TLabel;
    edtDoctor: TEdit;
    lblNotes: TLabel;
    memNotes: TMemo;
    btnCancel: TButton;
    btnSave: TButton;
    procedure FormCreate(Sender: TObject);
    procedure btnCancelClick(Sender: TObject);
    procedure btnSaveClick(Sender: TObject);
  private
    FConnection: TFDConnection;
    FAppointmentId: Integer;
    FPatientId: Integer;
    FIsEdit: Boolean;

    procedure LoadAppointment;
    function ValidateInput: Boolean;
    procedure SaveAppointment;
  public
    constructor CreateAppointment(
      AOwner: TComponent;
      AConnection: TFDConnection;
      APatientId: Integer;
      AAppointmentId: Integer = 0
    ); reintroduce;
  end;

implementation

{$R *.dfm}

constructor TAppointmentEditForm.CreateAppointment(
  AOwner: TComponent;
  AConnection: TFDConnection;
  APatientId: Integer;
  AAppointmentId: Integer
);
begin
  inherited Create(AOwner);

  FConnection := AConnection;
  FPatientId := APatientId;
  FAppointmentId := AAppointmentId;
  FIsEdit := FAppointmentId > 0;
end;

procedure TAppointmentEditForm.FormCreate(Sender: TObject);
begin
  if FIsEdit then
  begin
    Caption := 'Edit Appointment';
    LoadAppointment;
  end
  else
  begin
    Caption := 'New Appointment';

    dtpDate.Date := Date;
    dtpTime.Time := EncodeTime(10, 0, 0, 0);
  end;
end;

procedure TAppointmentEditForm.LoadAppointment;
var
  Q: TFDQuery;
  AppointmentDate: TDateTime;
begin
  Q := TFDQuery.Create(nil);

  try
    Q.Connection := FConnection;

    Q.SQL.Text :=
      'SELECT AppointmentDate, DoctorName, Notes ' +
      'FROM Appointments ' +
      'WHERE Id = :Id';

    Q.ParamByName('Id').DataType := ftInteger;
    Q.ParamByName('Id').AsInteger := FAppointmentId;

    Q.Open;

    if Q.Eof then
      raise Exception.Create('Appointment not found.');

    AppointmentDate :=
      ISO8601ToDate(
        Q.FieldByName('AppointmentDate').AsString,
        False
      );

    dtpDate.Date := DateOf(AppointmentDate);
    dtpTime.Time := TimeOf(AppointmentDate);

    edtDoctor.Text :=
      Q.FieldByName('DoctorName').AsString;

    memNotes.Text :=
      Q.FieldByName('Notes').AsString;

  finally
    Q.Free;
  end;
end;

function TAppointmentEditForm.ValidateInput: Boolean;
begin
  Result := False;

  if Trim(edtDoctor.Text) = '' then
  begin
    MessageDlg(
      'Doctor name is required.',
      mtWarning,
      [mbOK],
      0
    );

    edtDoctor.SetFocus;
    Exit;
  end;

  if dtpDate.Date < Date then
  begin
    MessageDlg(
      'Appointment date cannot be in the past.',
      mtWarning,
      [mbOK],
      0
    );

    dtpDate.SetFocus;
    Exit;
  end;

  Result := True;
end;

procedure TAppointmentEditForm.SaveAppointment;
var
  Q: TFDQuery;
  AppointmentDate: TDateTime;
begin
  Q := TFDQuery.Create(nil);

  try
    Q.Connection := FConnection;

    AppointmentDate :=
      Trunc(dtpDate.Date) +
      Frac(dtpTime.Time);

    FConnection.StartTransaction;

    try
      if FIsEdit then
      begin
        Q.SQL.Text :=
          'UPDATE Appointments SET ' +
          'AppointmentDate = :AppointmentDate, ' +
          'DoctorName = :DoctorName, ' +
          'Notes = :Notes ' +
          'WHERE Id = :Id';

        Q.ParamByName('Id').DataType := ftInteger;
        Q.ParamByName('Id').AsInteger := FAppointmentId;
      end
      else
      begin
        Q.SQL.Text :=
          'INSERT INTO Appointments ' +
          '(PatientId, AppointmentDate, DoctorName, Notes) ' +
          'VALUES (:PatientId, :AppointmentDate, :DoctorName, :Notes)';

        Q.ParamByName('PatientId').DataType := ftInteger;
        Q.ParamByName('PatientId').AsInteger := FPatientId;
      end;

      Q.ParamByName('AppointmentDate').DataType := ftString;
      Q.ParamByName('AppointmentDate').AsString :=
        FormatDateTime(
          'yyyy-mm-dd hh:nn:ss',
          AppointmentDate
        );

      Q.ParamByName('DoctorName').DataType := ftString;
      Q.ParamByName('DoctorName').AsString :=
        Trim(edtDoctor.Text);

      Q.ParamByName('Notes').DataType := ftString;
      Q.ParamByName('Notes').AsString :=
        Trim(memNotes.Text);

      Q.ExecSQL;

      FConnection.Commit;

    except
      FConnection.Rollback;
      raise;
    end;

    ModalResult := mrOk;

  except
    on E: Exception do
      MessageDlg(
        'Unable to save appointment.' +
        sLineBreak +
        sLineBreak +
        E.Message,
        mtError,
        [mbOK],
        0
      );
  end;

  Q.Free;
end;

procedure TAppointmentEditForm.btnSaveClick(Sender: TObject);
begin
  if ValidateInput then
    SaveAppointment;
end;

procedure TAppointmentEditForm.btnCancelClick(Sender: TObject);
begin
  ModalResult := mrCancel;
end;

end.
