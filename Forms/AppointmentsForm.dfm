object AppointmentsForm: TAppointmentsForm
  Left = 0
  Top = 0
  BorderStyle = bsSizeable
  Caption = 'Appointments'
  ClientHeight = 420
  ClientWidth = 760
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Segoe UI'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  TextHeight = 13
  object pnlTop: TPanel
    Left = 0
    Top = 0
    Width = 760
    Height = 58
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 0
    object lblPatient: TLabel
      Left = 16
      Top = 21
      Width = 180
      Height = 17
      Caption = 'Patient:'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = 'Segoe UI'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object btnNew: TButton
      Left = 400
      Top = 13
      Width = 100
      Height = 30
      Caption = 'New'
      TabOrder = 0
      OnClick = btnNewClick
    end
    object btnEdit: TButton
      Left = 510
      Top = 13
      Width = 100
      Height = 30
      Caption = 'Edit'
      TabOrder = 1
      OnClick = btnEditClick
    end
    object btnDelete: TButton
      Left = 620
      Top = 13
      Width = 100
      Height = 30
      Caption = 'Delete'
      TabOrder = 2
      OnClick = btnDeleteClick
    end
  end
  object grdAppointments: TDBGrid
    Left = 0
    Top = 58
    Width = 760
    Height = 362
    Align = alClient
    DataSource = dsAppointments
    Options = [
      dgTitles,
      dgIndicator,
      dgColumnResize,
      dgColLines,
      dgRowLines,
      dgTabs,
      dgRowSelect,
      dgAlwaysShowSelection,
      dgConfirmDelete,
      dgCancelOnExit
    ]
    ReadOnly = True
    TabOrder = 1
    OnDblClick = grdAppointmentsDblClick
    Columns = <
      item
        Expanded = False
        FieldName = 'Id'
        Title.Caption = 'ID'
        Width = 50
        Visible = True
      end
      item
        Expanded = False
        FieldName = 'AppointmentDate'
        Title.Caption = 'Date'
        Width = 150
        Visible = True
      end
      item
        Expanded = False
        FieldName = 'DoctorName'
        Title.Caption = 'Doctor'
        Width = 180
        Visible = True
      end
      item
        Expanded = False
        FieldName = 'Notes'
        Title.Caption = 'Notes'
        Width = 300
        Visible = True
      end>
  end
  object dsAppointments: TDataSource
    Left = 24
    Top = 80
  end
end