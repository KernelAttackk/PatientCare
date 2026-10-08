object PatientEditForm: TPatientEditForm
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  Caption = 'Patient'
  ClientHeight = 290
  ClientWidth = 522
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Segoe UI'
  Font.Style = []
  Position = poScreenCenter
  OnCreate = FormCreate
  TextHeight = 13
  object lblFirstName: TLabel
    Left = 32
    Top = 28
    Width = 56
    Height = 13
    Caption = 'First name:'
  end
  object lblLastName: TLabel
    Left = 32
    Top = 68
    Width = 54
    Height = 13
    Caption = 'Last name:'
  end
  object lblDateOfBirth: TLabel
    Left = 32
    Top = 108
    Width = 69
    Height = 13
    Caption = 'Date of birth:'
  end
  object lblPhone: TLabel
    Left = 32
    Top = 148
    Width = 36
    Height = 13
    Caption = 'Phone:'
  end
  object lblEmail: TLabel
    Left = 32
    Top = 188
    Width = 30
    Height = 13
    Caption = 'Email:'
  end
  object edtFirstName: TEdit
    Left = 150
    Top = 24
    Width = 310
    Height = 21
    TabOrder = 0
  end
  object edtLastName: TEdit
    Left = 150
    Top = 64
    Width = 310
    Height = 21
    TabOrder = 1
  end
  object dtpDateOfBirth: TDateTimePicker
    Left = 150
    Top = 104
    Width = 150
    Height = 24
    Date = 32874.000000000000000000
    Time = 32874.000000000000000000
    TabOrder = 2
  end
  object edtPhone: TEdit
    Left = 150
    Top = 144
    Width = 310
    Height = 21
    TabOrder = 3
  end
  object edtEmail: TEdit
    Left = 150
    Top = 184
    Width = 310
    Height = 21
    TabOrder = 4
  end
  object btnCancel: TButton
    Left = 300
    Top = 232
    Width = 100
    Height = 32
    Cancel = True
    Caption = 'Cancel'
    ModalResult = 2
    TabOrder = 6
    OnClick = btnCancelClick
  end
  object btnSave: TButton
    Left = 410
    Top = 232
    Width = 100
    Height = 32
    Caption = 'Save'
    Default = True
    TabOrder = 7
    OnClick = btnSaveClick
  end
  object btnAppointments: TButton
    Left = 180
    Top = 232
    Width = 110
    Height = 32
    Caption = 'Appointments'
    TabOrder = 5
    OnClick = btnAppointmentsClick
  end
end
