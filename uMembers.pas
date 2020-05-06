unit uMembers;

interface

uses
  Web.HTTPApp, System.SysUtils, System.Classes, RTTI, ADODB,
  uDatabase; //located in Database-Access

type
  TMembers = class(TADOQuery)
  private
    FADOConnection: TSQLDatabase;

    FId: Integer;
    FLastName: string;
    FMiddleName: string;
    FFirstName: string;
    FAge: Integer;

    function GetId: Integer;
    function GetFirstName: string;
    function GetLastName: string;
    function GetMiddleName: string;
    function GetAge: Integer;

    function ToJSON: string;
  public
    property Id: Integer read GetId write FId;
    property FirstName: string read GetFirstName write FFirstName;
    property MiddleName: string read GetMiddleName write FMiddleName;
    property LastName: string read GetLastName write FLastName;
    property Age: Integer read GetAge write FAge;

    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    procedure Open(SQLText: string); overload;
    function GetMember(Id: Integer): string;
    procedure SavePicture(Id: Integer; Stream: TMemoryStream);
  published

  end;

implementation

uses
  JSON, Data.DB;

{ TFamily }

constructor TMembers.Create(AOwner: TComponent);
begin
  inherited;
//  FADOConnection := TSQLDatabase.Create(nil);
//  FADOConnection.ConnectDB('Family');
  Connection := TSQLDatabase.ConnectDB('Family');
end;

destructor TMembers.Destroy;
begin
  FADOConnection.Free;
  inherited;
end;

{ *** Properties ***}

function TMembers.GetAge: Integer;
var
  Field: TField;
begin
  Result := 0;
  Field := FieldByName('Age');
  if not Field.IsNull then
    Result := FieldByName('Age').AsInteger;
end;

function TMembers.GetFirstName: string;
begin
  Result := FieldByName('FirstName').AsString;
end;

function TMembers.GetId: Integer;
begin
  Result := FieldByName('Id').AsInteger;
end;

function TMembers.GetLastName: string;
begin
  Result := FieldByName('LastName').AsString;
end;

function TMembers.GetMiddleName: string;
begin
  Result := FieldByName('MiddleName').AsString;
end;

{ *** End Properties ***}

procedure TMembers.Open(SQLText: string);
begin
  SQL.Text := SQLText;
  inherited Open;
end;

procedure TMembers.SavePicture(Id: Integer; Stream: TMemoryStream);
var
  qry: TADOQuery;
  cnt: Integer;
begin
  Stream.Position := 0;
  qry := TADOQuery.Create(nil);
  try
    qry.Connection := TSQLDatabase.ConnectDB('Family');
    qry.SQL.Text :=
      'UPDATE Members '+
      'SET Picture = :Picture '+
      'WHERE Id = ' + Id.ToString;
    qry.Parameters.ParamByName('Picture').LoadFromStream(Stream, ftBlob);
    cnt := qry.ExecSQL;
  finally
    qry.Free;
  end;
end;

function TMembers.ToJSON: string;
var
  o: TJSONObject;
begin
  try
    o := TJSONObject.Create;
    o.AddPair('id', TJSONNumber.Create(Id));
    o.AddPair('FirstName', FirstName);
    o.AddPair('LastName', LastName);
    o.AddPair('Age', TJSONNumber.Create(Age));
    Result := o.Format(2);
  finally
    o.Free;
  end;
end;

function TMembers.GetMember(Id: Integer): string;
var
  sql: string;
begin
  Result := '';
  if not Assigned(self) then Exit;

   if Locate('Id', Id, []) then
  begin
    Result := ToJSON;
  end;
end;


end.
