object AppointmentEditForm: TAppointmentEditForm
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  Caption = 'Appointment'
  ClientHeight = 330
  ClientWidth = 520
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Segoe UI'
  Font.Style = []
  Position = poScreenCenter
  OnCreate = FormCreate
  TextHeight = 13
  object lblDate: TLabel
    Left = 32
    Top = 28
    Width = 27
    Height = 13
    Caption = 'Date:'
  end
  object lblTime: TLabel
    Left = 32
    Top = 68
    Width = 27
    Height = 13
    Caption = 'Time:'
  end
  object lblDoctor: TLabel
    Left = 32
    Top = 108
    Width = 38
    Height = 13
    Caption = 'Doctor:'
  end
  object lblNotes: TLabel
    Left = 32
    Top = 148
    Width = 33
    Height = 13
    Caption = 'Notes:'
  end
  object dtpDate: TDateTimePicker
    Left = 150
    Top = 24
    Width = 150
    Height = 24
    Date = 46303.000000000000000000
    Time = 0.693681736112921500
    TabOrder = 0
  end
  object dtpTime: TDateTimePicker
    Left = 150
    Top = 64
    Width = 100
    Height = 24
    Date = 46303.000000000000000000
    Time = 0.416666666664241300
    Kind = dtkTime
    TabOrder = 1
  end
  object edtDoctor: TEdit
    Left = 150
    Top = 104
    Width = 330
    Height = 23
    TabOrder = 2
  end
  object memNotes: TMemo
    Left = 150
    Top = 144
    Width = 330
    Height = 110
    ScrollBars = ssVertical
    TabOrder = 3
  end
  object btnCancel: TButton
    Left = 270
    Top = 278
    Width = 100
    Height = 32
    Cancel = True
    Caption = 'Cancel'
    ModalResult = 2
    TabOrder = 5
    OnClick = btnCancelClick
  end
  object btnSave: TButton
    Left = 380
    Top = 278
    Width = 100
    Height = 32
    Caption = 'Save'
    Default = True
    TabOrder = 4
    OnClick = btnSaveClick
  end
end
