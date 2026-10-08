unit AppointmentRepository;

interface

uses
  System.SysUtils,
  System.Classes,
  Data.DB,
  FireDAC.Comp.Client;

type
  TAppointmentRepository = class
  private
    FConnection: TFDConnection;
  public
    constructor Create(AConnection: TFDConnection);

    function GetByPatient(APatientId: Integer): TDataSet;
    procedure CreateAppointment(
      APatientId: Integer;
      AAppointmentDate: TDateTime;
      const ADoctorName, ANotes: string
    );
    procedure UpdateAppointment(
      AAppointmentId: Integer;
      AAppointmentDate: TDateTime;
      const ADoctorName, ANotes: string
    );
    procedure DeleteAppointment(AAppointmentId: Integer);
  end;

implementation

constructor TAppointmentRepository.Create(AConnection: TFDConnection);
begin
  inherited Create;
  FConnection := AConnection;
end;

function TAppointmentRepository.GetByPatient(
  APatientId: Integer
): TDataSet;
var
  Q: TFDQuery;
begin
  Q := TFDQuery.Create(nil);
  Q.Connection := FConnection;

  Q.SQL.Text :=
    'SELECT ' +
    '  Id, ' +
    '  PatientId, ' +
    '  CAST(AppointmentDate AS VARCHAR(19)) AS AppointmentDate, ' +
    '  CAST(DoctorName AS VARCHAR(100)) AS DoctorName, ' +
    '  CAST(Notes AS VARCHAR(500)) AS Notes ' +
    'FROM Appointments ' +
    'WHERE PatientId = :PatientId ' +
    'ORDER BY AppointmentDate DESC';

  Q.ParamByName('PatientId').DataType := ftInteger;
  Q.ParamByName('PatientId').AsInteger := APatientId;

  Q.Open;

  Result := Q;
end;

procedure TAppointmentRepository.CreateAppointment(
  APatientId: Integer;
  AAppointmentDate: TDateTime;
  const ADoctorName, ANotes: string
);
var
  Q: TFDQuery;
begin
  Q := TFDQuery.Create(nil);

  try
    Q.Connection := FConnection;

    FConnection.StartTransaction;

    try
      Q.SQL.Text :=
        'INSERT INTO Appointments ' +
        '(PatientId, AppointmentDate, DoctorName, Notes) ' +
        'VALUES (:PatientId, :AppointmentDate, :DoctorName, :Notes)';

      Q.ParamByName('PatientId').DataType := ftInteger;
      Q.ParamByName('PatientId').AsInteger := APatientId;

      Q.ParamByName('AppointmentDate').DataType := ftString;
      Q.ParamByName('AppointmentDate').AsString :=
        FormatDateTime('yyyy-mm-dd hh:nn:ss', AAppointmentDate);

      Q.ParamByName('DoctorName').DataType := ftString;
      Q.ParamByName('DoctorName').AsString := ADoctorName;

      Q.ParamByName('Notes').DataType := ftString;
      Q.ParamByName('Notes').AsString := ANotes;

      Q.ExecSQL;

      FConnection.Commit;
    except
      FConnection.Rollback;
      raise;
    end;

  finally
    Q.Free;
  end;
end;

procedure TAppointmentRepository.UpdateAppointment(
  AAppointmentId: Integer;
  AAppointmentDate: TDateTime;
  const ADoctorName, ANotes: string
);
var
  Q: TFDQuery;
begin
  Q := TFDQuery.Create(nil);

  try
    Q.Connection := FConnection;

    FConnection.StartTransaction;

    try
      Q.SQL.Text :=
        'UPDATE Appointments SET ' +
        'AppointmentDate = :AppointmentDate, ' +
        'DoctorName = :DoctorName, ' +
        'Notes = :Notes ' +
        'WHERE Id = :Id';

      Q.ParamByName('Id').DataType := ftInteger;
      Q.ParamByName('Id').AsInteger := AAppointmentId;

      Q.ParamByName('AppointmentDate').DataType := ftString;
      Q.ParamByName('AppointmentDate').AsString :=
        FormatDateTime('yyyy-mm-dd hh:nn:ss', AAppointmentDate);

      Q.ParamByName('DoctorName').DataType := ftString;
      Q.ParamByName('DoctorName').AsString := ADoctorName;

      Q.ParamByName('Notes').DataType := ftString;
      Q.ParamByName('Notes').AsString := ANotes;

      Q.ExecSQL;

      FConnection.Commit;
    except
      FConnection.Rollback;
      raise;
    end;

  finally
    Q.Free;
  end;
end;

procedure TAppointmentRepository.DeleteAppointment(
  AAppointmentId: Integer
);
var
  Q: TFDQuery;
begin
  Q := TFDQuery.Create(nil);

  try
    Q.Connection := FConnection;

    FConnection.StartTransaction;

    try
      Q.SQL.Text :=
        'DELETE FROM Appointments WHERE Id = :Id';

      Q.ParamByName('Id').DataType := ftInteger;
      Q.ParamByName('Id').AsInteger := AAppointmentId;

      Q.ExecSQL;

      FConnection.Commit;
    except
      FConnection.Rollback;
      raise;
    end;

  finally
    Q.Free;
  end;
end;

end.
