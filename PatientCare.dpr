program PatientCare;

uses
  Vcl.Forms,
  MainFormUnit in 'Forms\MainFormUnit.pas' {MainForm},
  DatabaseManager in 'Database\DatabaseManager.pas',
  PatientRepository in 'Services\PatientRepository.pas',
  PatientFormUnit in 'Forms\PatientFormUnit.pas' {PatientEditForm},
  AppointmentRepository in 'Services\AppointmentRepository.pas',
  AppointmentForm in 'Forms\AppointmentForm.pas' {Form1},
  AppointmentsForm in 'Forms\AppointmentsForm.pas' {Form2};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.
