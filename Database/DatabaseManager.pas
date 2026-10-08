unit DatabaseManager;

interface

uses
  System.SysUtils,
  Data.DB,
  System.Classes,
  FireDAC.Comp.Client,
  FireDAC.Phys.SQLite,
  FireDAC.Phys.SQLiteDef,
  FireDAC.Stan.Def,
  FireDAC.Stan.Async,
  FireDAC.DApt;

type
  TDatabaseManager = class
  private
    FConnection: TFDConnection;
    FDriverLink: TFDPhysSQLiteDriverLink;

    procedure ConfigureConnection;
    procedure CreateSchema;
    procedure SeedDatabase;

  public
    constructor Create;
    destructor Destroy; override;

    procedure Connect;
    procedure Disconnect;

    property Connection: TFDConnection read FConnection;
  end;

implementation

{ TDatabaseManager }

constructor TDatabaseManager.Create;
begin
  inherited Create;

  FDriverLink := TFDPhysSQLiteDriverLink.Create(nil);
  FConnection := TFDConnection.Create(nil);

  ConfigureConnection;
end;

destructor TDatabaseManager.Destroy;
begin
  Disconnect;

  FConnection.Free;
  FDriverLink.Free;

  inherited;
end;

procedure TDatabaseManager.ConfigureConnection;
var
  DatabasePath: string;
begin
  DatabasePath := IncludeTrailingPathDelimiter(
    ExtractFilePath(ParamStr(0))
  ) + 'patientcare.db';

  FConnection.DriverName := 'SQLite';

  FConnection.Params.Clear;
  FConnection.Params.Add('DriverID=SQLite');
  FConnection.Params.Add('Database=' + DatabasePath);
  FConnection.Params.Add('LockingMode=Normal');
  FConnection.Params.Add('Synchronous=Normal');
  FConnection.Params.Add('JournalMode=WAL');

  FConnection.LoginPrompt := False;
end;

procedure TDatabaseManager.Connect;
begin
  if FConnection.Connected then
    Exit;

  FConnection.Connected := True;

  CreateSchema;
  SeedDatabase;
end;

procedure TDatabaseManager.Disconnect;
begin
  if FConnection.Connected then
    FConnection.Connected := False;
end;

procedure TDatabaseManager.CreateSchema;
begin
  FConnection.ExecSQL(
    'CREATE TABLE IF NOT EXISTS Patients (' +
    '  Id INTEGER PRIMARY KEY AUTOINCREMENT,' +
    '  FirstName TEXT NOT NULL,' +
    '  LastName TEXT NOT NULL,' +
    '  DateOfBirth TEXT NOT NULL,' +
    '  Phone TEXT,' +
    '  Email TEXT,' +
    '  CreatedAt TEXT NOT NULL' +
    ')'
  );

  FConnection.ExecSQL(
    'CREATE INDEX IF NOT EXISTS IX_Patients_LastName ' +
    'ON Patients(LastName)'
  );

  FConnection.ExecSQL(
    'CREATE INDEX IF NOT EXISTS IX_Patients_DateOfBirth ' +
    'ON Patients(DateOfBirth)'
  );

  FConnection.ExecSQL(
    'CREATE TABLE IF NOT EXISTS Appointments (' +
    '  Id INTEGER PRIMARY KEY AUTOINCREMENT,' +
    '  PatientId INTEGER NOT NULL,' +
    '  AppointmentDate TEXT NOT NULL,' +
    '  DoctorName TEXT NOT NULL,' +
    '  Notes TEXT,' +
    '  FOREIGN KEY (PatientId) REFERENCES Patients(Id)' +
    ')'
  );

  FConnection.ExecSQL(
    'CREATE INDEX IF NOT EXISTS IX_Appointments_PatientId ' +
    'ON Appointments(PatientId)'
  );

  FConnection.ExecSQL(
    'CREATE INDEX IF NOT EXISTS IX_Appointments_Date ' +
    'ON Appointments(AppointmentDate)'
  );
end;

procedure TDatabaseManager.SeedDatabase;
var
  Query: TFDQuery;
  I: Integer;
begin
  Query := TFDQuery.Create(nil);
  try
    Query.Connection := FConnection;

    Query.SQL.Text :=
      'SELECT COUNT(*) FROM Patients';

    Query.Open;

    if Query.Fields[0].AsInteger > 0 then
      Exit;

    Query.Close;

    Query.SQL.Text :=
      'INSERT INTO Patients ' +
      '(FirstName, LastName, DateOfBirth, Phone, Email, CreatedAt) ' +
      'VALUES (:FirstName, :LastName, :DateOfBirth, :Phone, :Email, :CreatedAt)';

    // Explicit parameter types.
    Query.ParamByName('FirstName').DataType := ftString;
    Query.ParamByName('LastName').DataType := ftString;
    Query.ParamByName('DateOfBirth').DataType := ftString;
    Query.ParamByName('Phone').DataType := ftString;
    Query.ParamByName('Email').DataType := ftString;
    Query.ParamByName('CreatedAt').DataType := ftString;

    Query.Prepare;

    FConnection.StartTransaction;
    try
      for I := 0 to 99999 do
      begin
        Query.ParamByName('FirstName').AsString :=
          'Patient' + IntToStr(I + 1);

        Query.ParamByName('LastName').AsString :=
          'Lastname' + IntToStr((I mod 1000) + 1);

        Query.ParamByName('DateOfBirth').AsString :=
          FormatDateTime(
            'yyyy-mm-dd',
            EncodeDate(
              1960 + (I mod 45),
              1 + (I mod 12),
              1 + (I mod 28)
            )
          );

        Query.ParamByName('Phone').AsString :=
          '+34 600 ' +
          FormatFloat('000000', I mod 1000000);

        Query.ParamByName('Email').AsString :=
          'patient' + IntToStr(I + 1) +
          '@example.com';

        Query.ParamByName('CreatedAt').AsString :=
          FormatDateTime(
            'yyyy-mm-dd hh:nn:ss',
            Now
          );

        Query.ExecSQL;
      end;

      FConnection.Commit;
    except
      FConnection.Rollback;
      raise;
    end;

  finally
    Query.Free;
  end;
end;


end.
