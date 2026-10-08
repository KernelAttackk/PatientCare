unit PatientRepository;

interface

uses
  System.SysUtils,
  System.Classes,
  Data.DB,
  FireDAC.Comp.Client;

type
  TPatientRepository = class
  private
    FConnection: TFDConnection;
  public
    constructor Create(AConnection: TFDConnection);

    function Search(const ASearch: string): TDataSet;
    function Count: Integer;

    function GetById(AId: Integer): TDataSet;

    function CreatePatient(
      const AFirstName: string;
      const ALastName: string;
      const ADateOfBirth: string;
      const APhone: string;
      const AEmail: string
    ): Integer;

    procedure UpdatePatient(
      AId: Integer;
      const AFirstName: string;
      const ALastName: string;
      const ADateOfBirth: string;
      const APhone: string;
      const AEmail: string
    );

    procedure Delete(AId: Integer);
  end;

implementation

constructor TPatientRepository.Create(AConnection: TFDConnection);
begin
  inherited Create;

  if not Assigned(AConnection) then
    raise EArgumentNilException.Create(
      'Database connection is required'
    );

  FConnection := AConnection;
end;

function TPatientRepository.Search(const ASearch: string): TDataSet;
var
  Q: TFDQuery;
begin
  Q := TFDQuery.Create(nil);
  Q.Connection := FConnection;

  Q.SQL.Text :=
    'SELECT ' +
    '  p.Id, ' +
    '  CAST(p.FirstName AS VARCHAR(100)) AS FirstName, ' +
    '  CAST(p.LastName AS VARCHAR(100)) AS LastName, ' +
    '  CAST(p.DateOfBirth AS VARCHAR(10)) AS DateOfBirth, ' +
    '  CAST(p.Phone AS VARCHAR(50)) AS Phone, ' +
    '  CAST(p.Email AS VARCHAR(150)) AS Email, ' +
    '  p.CreatedAt, ' +
    '  (SELECT COUNT(*) FROM Appointments a WHERE a.PatientId = p.Id) AS AppointmentCount ' +
    'FROM Patients p ' +
    'WHERE (:Search = '''' ' +
    '   OR p.FirstName LIKE :SearchLike ' +
    '   OR p.LastName LIKE :SearchLike ' +
    '   OR p.Phone LIKE :SearchLike) ' +
    'ORDER BY p.LastName, p.FirstName ' +
    'LIMIT 500';

  Q.ParamByName('Search').DataType := ftString;
  Q.ParamByName('Search').AsString := ASearch;

  Q.ParamByName('SearchLike').DataType := ftString;
  Q.ParamByName('SearchLike').AsString := '%' + ASearch + '%';

  Q.Open;

  Result := Q;
end;

function TPatientRepository.Count: Integer;
var
  Query: TFDQuery;
begin
  Query := TFDQuery.Create(nil);

  try
    Query.Connection := FConnection;

    Query.SQL.Text :=
      'SELECT COUNT(*) FROM Patients';

    Query.Open;

    Result := Query.Fields[0].AsInteger;
  finally
    Query.Free;
  end;
end;

function TPatientRepository.GetById(AId: Integer): TDataSet;
var
  Query: TFDQuery;
begin
  Query := TFDQuery.Create(nil);

  try
    Query.Connection := FConnection;

    Query.SQL.Text :=
      'SELECT ' +
      '  p.Id, ' +
      '  p.FirstName, ' +
      '  p.LastName, ' +
      '  p.DateOfBirth, ' +
      '  p.Phone, ' +
      '  p.Email, ' +
      '  p.CreatedAt, ' +
      '  (SELECT COUNT(*) ' +
      '     FROM Appointments a ' +
      '    WHERE a.PatientId = p.Id) AS AppointmentCount ' +
      'FROM Patients p ' +
      'WHERE p.Id = :Id';

    Query.ParamByName('Id').DataType := ftInteger;
    Query.ParamByName('Id').AsInteger := AId;

    Query.Open;

    Result := Query;
  except
    Query.Free;
    raise;
  end;
end;

function TPatientRepository.CreatePatient(
  const AFirstName: string;
  const ALastName: string;
  const ADateOfBirth: string;
  const APhone: string;
  const AEmail: string
): Integer;
var
  Query: TFDQuery;
begin
  Query := TFDQuery.Create(nil);

  try
    Query.Connection := FConnection;

    FConnection.StartTransaction;

    try
      Query.SQL.Text :=
        'INSERT INTO Patients ' +
        '(FirstName, LastName, DateOfBirth, Phone, Email, CreatedAt) ' +
        'VALUES ' +
        '(:FirstName, :LastName, :DateOfBirth, :Phone, :Email, :CreatedAt)';

      Query.ParamByName('FirstName').DataType := ftString;
      Query.ParamByName('LastName').DataType := ftString;
      Query.ParamByName('DateOfBirth').DataType := ftString;
      Query.ParamByName('Phone').DataType := ftString;
      Query.ParamByName('Email').DataType := ftString;
      Query.ParamByName('CreatedAt').DataType := ftString;

      Query.ParamByName('FirstName').AsString := AFirstName;
      Query.ParamByName('LastName').AsString := ALastName;
      Query.ParamByName('DateOfBirth').AsString := ADateOfBirth;
      Query.ParamByName('Phone').AsString := APhone;
      Query.ParamByName('Email').AsString := AEmail;
      Query.ParamByName('CreatedAt').AsString :=
        FormatDateTime(
          'yyyy-mm-dd hh:nn:ss',
          Now
        );

      Query.ExecSQL;

      Query.SQL.Text :=
        'SELECT last_insert_rowid()';

      Query.Open;

      Result := Query.Fields[0].AsInteger;

      FConnection.Commit;
    except
      FConnection.Rollback;
      raise;
    end;

  finally
    Query.Free;
  end;
end;

procedure TPatientRepository.UpdatePatient(
  AId: Integer;
  const AFirstName: string;
  const ALastName: string;
  const ADateOfBirth: string;
  const APhone: string;
  const AEmail: string
);
var
  Query: TFDQuery;
begin
  Query := TFDQuery.Create(nil);

  try
    Query.Connection := FConnection;

    FConnection.StartTransaction;

    try
      Query.SQL.Text :=
        'UPDATE Patients SET ' +
        'FirstName = :FirstName, ' +
        'LastName = :LastName, ' +
        'DateOfBirth = :DateOfBirth, ' +
        'Phone = :Phone, ' +
        'Email = :Email ' +
        'WHERE Id = :Id';

      Query.ParamByName('FirstName').DataType := ftString;
      Query.ParamByName('LastName').DataType := ftString;
      Query.ParamByName('DateOfBirth').DataType := ftString;
      Query.ParamByName('Phone').DataType := ftString;
      Query.ParamByName('Email').DataType := ftString;
      Query.ParamByName('Id').DataType := ftInteger;

      Query.ParamByName('FirstName').AsString := AFirstName;
      Query.ParamByName('LastName').AsString := ALastName;
      Query.ParamByName('DateOfBirth').AsString := ADateOfBirth;
      Query.ParamByName('Phone').AsString := APhone;
      Query.ParamByName('Email').AsString := AEmail;
      Query.ParamByName('Id').AsInteger := AId;

      Query.ExecSQL;

      FConnection.Commit;
    except
      FConnection.Rollback;
      raise;
    end;

  finally
    Query.Free;
  end;
end;

procedure TPatientRepository.Delete(AId: Integer);
var
  Query: TFDQuery;
begin
  Query := TFDQuery.Create(nil);

  try
    Query.Connection := FConnection;

    FConnection.StartTransaction;

    try
      Query.SQL.Text :=
        'DELETE FROM Patients WHERE Id = :Id';

      Query.ParamByName('Id').DataType := ftInteger;
      Query.ParamByName('Id').AsInteger := AId;

      Query.ExecSQL;

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
