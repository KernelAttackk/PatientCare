object MainForm: TMainForm
  Left = 0
  Top = 0
  Caption = 'PatientCare Desktop'
  ClientHeight = 650
  ClientWidth = 1100
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Segoe UI'
  Font.Style = []
  Position = poScreenCenter
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  TextHeight = 13
  object pnlTop: TPanel
    Left = 0
    Top = 0
    Width = 1100
    Height = 58
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 1
    object lblSearch: TLabel
      Left = 18
      Top = 20
      Width = 37
      Height = 13
      Caption = 'Search:'
    end
    object edtSearch: TEdit
      Left = 72
      Top = 15
      Width = 300
      Height = 21
      TabOrder = 0
      OnKeyDown = edtSearchKeyDown
    end
    object btnSearch: TButton
      Left = 384
      Top = 14
      Width = 90
      Height = 29
      Caption = 'Search'
      TabOrder = 1
      OnClick = btnSearchClick
    end
    object btnClear: TButton
      Left = 480
      Top = 14
      Width = 75
      Height = 29
      Caption = 'Clear'
      TabOrder = 2
      OnClick = btnClearClick
    end
    object btnNewPatient: TButton
      Left = 592
      Top = 14
      Width = 110
      Height = 29
      Caption = 'New Patient'
      TabOrder = 3
      OnClick = btnNewPatientClick
    end
    object btnEditPatient: TButton
      Left = 708
      Top = 14
      Width = 100
      Height = 29
      Caption = 'Edit'
      TabOrder = 4
      OnClick = btnEditPatientClick
    end
    object btnDeletePatient: TButton
      Left = 814
      Top = 14
      Width = 100
      Height = 29
      Caption = 'Delete'
      TabOrder = 5
      OnClick = btnDeletePatientClick
    end
  end
  object grdPatients: TDBGrid
    Left = 0
    Top = 58
    Width = 1100
    Height = 542
    Align = alClient
    DataSource = dsPatients
    Options = [dgTitles, dgIndicator, dgColumnResize, dgColLines, dgRowLines, dgTabs, dgRowSelect, dgAlwaysShowSelection, dgConfirmDelete, dgCancelOnExit]
    ReadOnly = True
    TabOrder = 0
    TitleFont.Charset = DEFAULT_CHARSET
    TitleFont.Color = clWindowText
    TitleFont.Height = -11
    TitleFont.Name = 'Segoe UI'
    TitleFont.Style = []
    OnDblClick = grdPatientsDblClick
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
        FieldName = 'FirstName'
        Title.Caption = 'First Name'
        Width = 120
        Visible = True
      end
      item
        Expanded = False
        FieldName = 'LastName'
        Title.Caption = 'Last Name'
        Width = 140
        Visible = True
      end
      item
        Expanded = False
        FieldName = 'DateOfBirth'
        Title.Caption = 'Date of Birth'
        Width = 100
        Visible = True
      end
      item
        Expanded = False
        FieldName = 'Phone'
        Width = 120
        Visible = True
      end
      item
        Expanded = False
        FieldName = 'Email'
        Width = 220
        Visible = True
      end
      item
        Expanded = False
        FieldName = 'AppointmentCount'
        Title.Caption = 'Appointments'
        Width = 90
        Visible = True
      end>
  end
  object StatusBar: TStatusBar
    Left = 0
    Top = 600
    Width = 1100
    Height = 50
    Panels = <>
    SimplePanel = True
    SimpleText = 'Database: Connecting...'
  end
  object dsPatients: TDataSource
    Left = 1048
    Top = 72
  end
end
