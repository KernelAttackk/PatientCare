unit AppointmentsForm;

interface

uses
  Winapi.Windows,
  Winapi.Messages,
  System.SysUtils,
  System.Classes,
  Vcl.Forms,
  Vcl.Controls,
  Vcl.StdCtrls,
  Vcl.ExtCtrls,
  Vcl.Grids,
  Vcl.DBGrids,
  Vcl.Dialogs,
  Data.DB,
  FireDAC.Comp.Client,
  AppointmentRepository,
  AppointmentForm;

type
  TAppointmentsForm = class(TForm)
    pnlTop: TPanel;
    lblPatient: TLabel;
    btnNew: TButton;
    btnEdit: TButton;
    btnDelete: TButton;
    grdAppointments: TDBGrid;
    dsAppointments: TDataSource;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure btnNewClick(Sender: TObject);
    procedure btnEditClick(Sender: TObject);
    procedure btnDeleteClick(Sender: TObject);
    procedure grdAppointmentsDblClick(Sender: TObject);
  private
    FConnection: TFDConnection;
    FPatientId: Integer;
    FPatientName: string;
    FRepository: TAppointmentRepository;
    FDataSet: TDataSet;

    procedure LoadAppointments;
    procedure EditSelectedAppointment;
    procedure DeleteSelectedAppointment;
  public
    constructor CreateForPatient(
      AOwner: TComponent;
      AConnection: TFDConnection;
      APatientId: Integer;
      const APatientName: string
    ); reintroduce;
  end;

implementation

{$R *.dfm}

constructor TAppointmentsForm.CreateForPatient(
  AOwner: TComponent;
  AConnection: TFDConnection;
  APatientId: Integer;
  const APatientName: string
);
begin
  inherited Create(AOwner);

  FConnection := AConnection;
  FPatientId := APatientId;
  FPatientName := APatientName;
end;

procedure TAppointmentsForm.FormCreate(Sender: TObject);
begin
  Caption := 'Appointments - ' + FPatientName;
  lblPatient.Caption := 'Patient: ' + FPatientName;

  FRepository := TAppointmentRepository.Create(FConnection);

  LoadAppointments;
end;

procedure TAppointmentsForm.FormDestroy(Sender: TObject);
begin
  dsAppointments.DataSet := nil;

  if Assigned(FDataSet) then
    FDataSet.Free;

  FRepository.Free;
end;

procedure TAppointmentsForm.LoadAppointments;
begin
  if Assigned(FDataSet) then
  begin
    dsAppointments.DataSet := nil;
    FDataSet.Free;
    FDataSet := nil;
  end;

  FDataSet := FRepository.GetByPatient(FPatientId);

  dsAppointments.DataSet := FDataSet;
end;

procedure TAppointmentsForm.btnNewClick(Sender: TObject);
var
  Form: TAppointmentEditForm;
begin
  Form := TAppointmentEditForm.CreateAppointment(
    Self,
    FConnection,
    FPatientId
  );

  try
    if Form.ShowModal = mrOk then
      LoadAppointments;
  finally
    Form.Free;
  end;
end;

procedure TAppointmentsForm.btnEditClick(Sender: TObject);
begin
  EditSelectedAppointment;
end;

procedure TAppointmentsForm.grdAppointmentsDblClick(Sender: TObject);
begin
  EditSelectedAppointment;
end;

procedure TAppointmentsForm.EditSelectedAppointment;
var
  Form: TAppointmentEditForm;
  AppointmentId: Integer;
begin
  if (FDataSet = nil) or FDataSet.IsEmpty then
    Exit;

  AppointmentId :=
    FDataSet.FieldByName('Id').AsInteger;

  Form := TAppointmentEditForm.CreateAppointment(
    Self,
    FConnection,
    FPatientId,
    AppointmentId
  );

  try
    if Form.ShowModal = mrOk then
      LoadAppointments;
  finally
    Form.Free;
  end;
end;

procedure TAppointmentsForm.btnDeleteClick(Sender: TObject);
begin
  DeleteSelectedAppointment;
end;

procedure TAppointmentsForm.DeleteSelectedAppointment;
var
  AppointmentId: Integer;
  DoctorName: string;
begin
  if (FDataSet = nil) or FDataSet.IsEmpty then
    Exit;

  AppointmentId :=
    FDataSet.FieldByName('Id').AsInteger;

  DoctorName :=
    FDataSet.FieldByName('DoctorName').AsString;

  if MessageDlg(
       'Delete appointment with ' + DoctorName + '?' +
       sLineBreak + sLineBreak +
       'This action cannot be undone.',
       mtConfirmation,
       [mbYes, mbNo],
       0
     ) <> mrYes then
    Exit;

  try
    FRepository.DeleteAppointment(AppointmentId);
    LoadAppointments;
  except
    on E: Exception do
      MessageDlg(
        'Unable to delete appointment.' +
        sLineBreak + sLineBreak +
        E.Message,
        mtError,
        [mbOK],
        0
      );
  end;
end;

end.
