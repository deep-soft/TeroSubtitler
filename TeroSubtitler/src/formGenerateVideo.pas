{*
 *  URUWorks
 *
 *  The contents of this file are used with permission, subject to
 *  the Mozilla Public License Version 2.0 (the "License"); you may
 *  not use this file except in compliance with the License.
 *  You may obtain a copy of the License at
 *  http://www.mozilla.org/MPL/2.0.html
 *
 *  Software distributed under the License is distributed on an
 *  "AS IS" basis, WITHOUT WARRANTY OF ANY KIND, either express or
 *  implied. See the License for the specific language governing
 *  rights and limitations under the License.
 *
 *  Copyright (C) 2023 URUWorks, uruworks@gmail.com.
 *}

unit formGenerateVideo;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, StdCtrls,
  laz.VirtualTrees, LCLIntf, LCLType, Spin, Menus, ComCtrls, UWCheckBox;

type

  { TfrmGenerateVideo }

  TfrmGenerateVideo = class(TForm)
    btnClose: TButton;
    btnGenerate: TButton;
    btnRes: TButton;
    cbnSub: TColorButton;
    cbnBox: TColorButton;
    cboFont: TComboBox;
    cboAudioEncoding: TComboBox;
    cboSampleRate: TComboBox;
    cboBitRate: TComboBox;
    cboAudioChannels: TComboBox;
    cboVideoEncoding: TComboBox;
    cboVideoPreset: TComboBox;
    lblFont: TLabel;
    lblAudioEncoding: TLabel;
    lblSampleRate: TLabel;
    lblBitrate: TLabel;
    lblAudioChannels: TLabel;
    lblTimeElapsed: TLabel;
    lblVideoEncoding: TLabel;
    lblFontSize: TLabel;
    lblFontColor: TLabel;
    lblVideoPreset: TLabel;
    lblVideoRes: TLabel;
    lblX: TLabel;
    popRes: TPopupMenu;
    prbProgress: TProgressBar;
    spnFontSize: TSpinEdit;
    spnHeight: TSpinEdit;
    spnWidth: TSpinEdit;
    chkBox: TUWCheckBox;
    chkReEncodeAudio: TUWCheckBox;
    VST: TLazVirtualStringTree;
    procedure btnGenerateClick(Sender: TObject);
    procedure btnCloseClick(Sender: TObject);
    procedure btnResClick(Sender: TObject);
    procedure cboVideoEncodingSelect(Sender: TObject);
    procedure chkReEncodeAudioClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure VSTAdvancedHeaderDraw(Sender: TVTHeader;
      var PaintInfo: THeaderPaintInfo; const Elements: THeaderPaintElements);
    procedure VSTDrawText(Sender: TBaseVirtualTree; TargetCanvas: TCanvas;
      Node: PVirtualNode; Column: TColumnIndex; const CellText: String;
      const CellRect: TRect; var DefaultDraw: Boolean);
    procedure VSTGetText(Sender: TBaseVirtualTree; Node: PVirtualNode;
      Column: TColumnIndex; TextType: TVSTTextType; var CellText: String);
    procedure VSTHeaderDrawQueryElements(Sender: TVTHeader;
      var PaintInfo: THeaderPaintInfo; var Elements: THeaderPaintElements);
    procedure VSTResize(Sender: TObject);
  private
    FOutputFileName: String;
    procedure ResItemClick(Sender: TObject);
    procedure SetControlsEnabled(const AValue: Boolean);
    procedure OpenFolderClick(Sender: TObject);
    function SuggestNewVideoFileName: String;
  public

  end;

var
  frmGenerateVideo: TfrmGenerateVideo;
  CancelGeneration: Boolean;

// -----------------------------------------------------------------------------

implementation

uses
  procTypes, procWorkspace, procColorTheme, procConfig, UWSystem.XMLLang,
  procCustomFormat, procGenerateVideo, formMain, UWSubtitleAPI,
  UWSubtitleAPI.Formats, UWSystem.Encoding, UWSystem.TimeUtils,
  UWSystem.SysUtils, procDialogs;

{$R *.lfm}

// -----------------------------------------------------------------------------

{ TfrmGenerateVideo }

// -----------------------------------------------------------------------------

procedure TfrmGenerateVideo.FormCreate(Sender: TObject);
var
  i: Integer;
  m: TMenuItem;
  //  FAppStringList: TAppStringList = NIL;
begin
  LoadLanguage(Self);

  //LanguageManager.GetAppStringList('GenerateVideoStrings', FAppStringList);
  //VSTAddColumn(VST, GetString(FAppStringList, 'Subtitle'), 150);
  //FAppStringList.Free;

  cboFont.Items.Assign(Screen.Fonts);
  i := cboFont.Items.IndexOf('Verdana');
  if i >= 0 then
    cboFont.ItemIndex := i
  else
    cboFont.ItemIndex := 0;

  popRes.Items.Clear;
  for i := 0 to High(TResolutionList) do
  begin
    m := TMenuItem.Create(popRes);
    m.Caption := TResolutionList[i].Name;
    m.Tag := i;
    m.OnClick := @ResItemClick;
    popRes.Items.Add(m);
  end;

  spnWidth.Value  := frmMain.MPV.GetVideoWidth;
  spnHeight.Value := frmMain.MPV.GetVideoHeight;

  FillComboWithVideoEncoders(cboVideoEncoding);
  FillComboWithAudioEncoders(cboAudioEncoding);
  FillComboWithAudioChannels(cboAudioChannels);
  FillComboWithAudioSampleRate(cboSampleRate);
  FillComboWithAudioBitRate(cboBitRate);

  CancelGeneration := False;
end;

// -----------------------------------------------------------------------------

procedure TfrmGenerateVideo.FormClose(Sender: TObject;
  var CloseAction: TCloseAction);
begin
  SaveFormSettings(Self, Format('%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d',
    [cboFont.ItemIndex, spnFontSize.Value, cbnSub.ButtonColor, cbnBox.ButtonColor,
    chkBox.Checked.ToInteger, cboVideoEncoding.ItemIndex, chkReEncodeAudio.Checked.ToInteger,
    cboAudioEncoding.ItemIndex, cboAudioChannels.ItemIndex, cboSampleRate.ItemIndex, cboBitRate.ItemIndex]));
  CloseAction := caFree;
  frmGenerateVideo := NIL;
end;

// -----------------------------------------------------------------------------

procedure TfrmGenerateVideo.FormShow(Sender: TObject);
var
  s: String;
  AParamArray: TStringArray;
begin
  CheckColorTheme(Self);
  s := LoadFormSettings(Self);
  if not s.IsEmpty then
  begin
    AParamArray := s.Split(',');
    if Length(AParamArray) = 11 then
    begin
      cboFont.ItemIndex := AParamArray[0].ToInteger;
      spnFontSize.Value := AParamArray[1].ToInteger;
      cbnSub.ButtonColor := AParamArray[2].ToInteger;
      cbnBox.ButtonColor := AParamArray[3].ToInteger;
      chkBox.Checked := AParamArray[4].ToBoolean;
      cboVideoEncoding.ItemIndex := AParamArray[5].ToInteger;
      chkReEncodeAudio.Checked := AParamArray[6].ToBoolean;
      cboAudioEncoding.ItemIndex := AParamArray[7].ToInteger;
      cboAudioChannels.ItemIndex := AParamArray[8].ToInteger;
      cboSampleRate.ItemIndex := AParamArray[9].ToInteger;
      cboBitRate.ItemIndex := AParamArray[10].ToInteger;
    end;
  end;
  chkReEncodeAudioClick(NIL);
  cboVideoEncodingSelect(NIL);
end;

// -----------------------------------------------------------------------------

procedure TfrmGenerateVideo.btnCloseClick(Sender: TObject);
begin
  if btnGenerate.Enabled then
    Close
  else
    CancelGeneration := True;
end;

// -----------------------------------------------------------------------------

procedure TfrmGenerateVideo.btnResClick(Sender: TObject);
begin
  popRes.PopUp;
end;

// -----------------------------------------------------------------------------

procedure TfrmGenerateVideo.chkReEncodeAudioClick(Sender: TObject);
begin
  cboAudioEncoding.Enabled := chkReEncodeAudio.Checked;
  cboAudioChannels.Enabled := chkReEncodeAudio.Checked;
  cboSampleRate.Enabled    := chkReEncodeAudio.Checked;
  cboBitRate.Enabled       := chkReEncodeAudio.Checked;
  lblAudioEncoding.Enabled := chkReEncodeAudio.Checked;
  lblAudioChannels.Enabled := chkReEncodeAudio.Checked;
  lblSampleRate.Enabled    := chkReEncodeAudio.Checked;
  lblBitrate.Enabled       := chkReEncodeAudio.Checked;
end;

// -----------------------------------------------------------------------------

procedure TfrmGenerateVideo.VSTAdvancedHeaderDraw(Sender: TVTHeader;
  var PaintInfo: THeaderPaintInfo; const Elements: THeaderPaintElements);
begin
  if (hpeBackground in Elements) then
  begin
    PaintInfo.TargetCanvas.Brush.Color := ColorThemeInstance.Colors.Window;

    if Assigned(PaintInfo.Column) then
      DrawFrameControl(PaintInfo.TargetCanvas.Handle, PaintInfo.PaintRectangle, DFC_BUTTON, DFCS_FLAT or DFCS_ADJUSTRECT);

    PaintInfo.TargetCanvas.FillRect(PaintInfo.PaintRectangle);
  end;
end;

// -----------------------------------------------------------------------------

procedure TfrmGenerateVideo.VSTHeaderDrawQueryElements(Sender: TVTHeader;
  var PaintInfo: THeaderPaintInfo; var Elements: THeaderPaintElements);
begin
  if ColorThemeInstance.GetRealColorMode = cmDark then
    Elements := [hpeBackground];
end;

// -----------------------------------------------------------------------------

procedure TfrmGenerateVideo.VSTDrawText(Sender: TBaseVirtualTree;
  TargetCanvas: TCanvas; Node: PVirtualNode; Column: TColumnIndex;
  const CellText: String; const CellRect: TRect; var DefaultDraw: Boolean);
begin
  DefaultDraw := True;
end;

// -----------------------------------------------------------------------------

procedure TfrmGenerateVideo.VSTGetText(Sender: TBaseVirtualTree;
  Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType;
  var CellText: String);
begin
//  case Column of
//  end;
end;

// -----------------------------------------------------------------------------

procedure TfrmGenerateVideo.VSTResize(Sender: TObject);
var
  c, wCols: Integer;
begin
  wCols := (VST.Width - (GetSystemMetrics(SM_CXVSCROLL)+VST.Header.Columns.Count)) div VST.Header.Columns.Count;
  for c := 0 to VST.Header.Columns.Count-1 do
    VST.Header.Columns[c].Width := wCols;
end;

// -----------------------------------------------------------------------------

procedure TfrmGenerateVideo.ResItemClick(Sender: TObject);
begin
  with TResolutionList[TMenuItem(Sender).Tag] do
  begin
    spnWidth.Value  := Width;
    spnHeight.Value := Height;
  end;
end;

// -----------------------------------------------------------------------------

procedure TfrmGenerateVideo.cboVideoEncodingSelect(Sender: TObject);
begin
  cboVideoPreset.Enabled := cboVideoEncoding.ItemIndex = High(TFFVideoEncoders);
  if cboVideoPreset.Enabled then
    FillComboWithVideoProfileProRes(cboVideoPreset)
  else
    cboVideoPreset.Clear;
end;

// -----------------------------------------------------------------------------

procedure TfrmGenerateVideo.SetControlsEnabled(const AValue: Boolean);
begin
  lblTimeElapsed.Caption := '';
  lblTimeElapsed.Visible := not AValue;
  prbProgress.Visible := not AValue;
  btnGenerate.Enabled := AValue;

  cboFont.Enabled := AValue;
  spnFontSize.Enabled := AValue;
  chkBox.Enabled := AValue;
  cbnSub.Enabled := AValue;
  cbnBox.Enabled := AValue;
  spnWidth.Enabled := AValue;
  spnHeight.Enabled := AValue;
  btnRes.Enabled := AValue;
  cboVideoEncoding.Enabled := AValue;
  cboVideoPreset.Enabled := False;
  chkReEncodeAudio.Enabled := AValue;
  cboAudioEncoding.Enabled := False;
  cboAudioChannels.Enabled := False;
  cboSampleRate.Enabled := False;
  cboBitRate.Enabled := False;
  if AValue then
  begin
    chkReEncodeAudioClick(NIL);
    cboVideoEncodingSelect(NIL);
  end;

  if AValue then
    btnClose.Caption := GetCommonString('btnClose', 'CommonControls')
  else
    btnClose.Caption := GetCommonString('btnCancel', 'CommonControls');
end;

procedure ProcessCB(const TimeElapsed: Double; var Cancel: Boolean);
begin
  frmGenerateVideo.lblTimeElapsed.Caption := TimeToString(Trunc(TimeElapsed)*1000, 'mm:ss');
  Cancel := CancelGeneration;
end;

// -----------------------------------------------------------------------------

procedure TfrmGenerateVideo.OpenFolderClick(Sender: TObject);
begin
  OpenDocument(ExtractFileDir(FOutputFileName));
end;

// -----------------------------------------------------------------------------

function TfrmGenerateVideo.SuggestNewVideoFileName: String;
begin
  Result := ChangeFileExt(ExtractFileName(frmMain.MPV.FileName), '');

  case cboVideoEncoding.ItemIndex of
    3..5 : Result += '_x265';
    6    : Result += '_vp9';
    7    : Result += '_ProRes';
  else
    Result += '_x264';
  end;
end;

// -----------------------------------------------------------------------------

procedure TfrmGenerateVideo.btnGenerateClick(Sender: TObject);
var
  sub, aEnc, style, ext: String;
begin
  FOutputFileName := '';

  if not FileExists(Tools.FFmpeg) then
  begin
    ShowErrorMessageDialog(Format(GetCommonString('ExtractAppError'), [ExtractFileName(Tools.FFmpeg)]));
    Exit;
  end;

  CancelGeneration := False;

  with TSaveDialog.Create(NIL) do
  try
    Title := GetCommonString('SaveFile');

    if cboVideoEncoding.ItemIndex <> 7 then
    begin
      Filter := 'MP4 (*.mp4)|*.mp4';
      ext := '.mp4';
    end
    else
    begin
      Filter := 'MOV (*.mov)|*.mov';
      ext := '.mov';
    end;

    Options  := [ofOverwritePrompt, ofEnableSizing];
    FileName := SuggestNewVideoFileName;

    if Execute then
    begin
      if ExtractFileExt(FOutputFileName) = '' then
        FOutputFileName := ChangeFileExt(FileName, ext)
      else
        FOutputFileName := FileName;
    end
    else
      Exit;
  finally
    Free;
  end;

  SetControlsEnabled(False);

  sub := ChangeFileExt(GetTempFileName, '.ass');
  if Subtitles.SaveToFile(sub, Workspace.FPS.OutputFPS, TEncoding.GetEncoding(Encodings[Workspace.DefEncoding].CPID), sfAdvancedSubStationAlpha, smText) then
  begin
    if chkReEncodeAudio.Checked then
      aEnc := TFFAudioEncoders[cboAudioEncoding.ItemIndex].Codec
    else
      aEnc := '';

    style := Format('Fontname=%s,Fontsize=%d,Alignment=2,PrimaryColour=%s,Outline=0,Shadow=0,MarginV=20',
      [StringReplace(cboFont.Text, ' ', '%%', [rfReplaceAll]), spnFontSize.Value, IntToHexStr(cbnSub.ButtonColor, True, '&H00')]);

    if chkBox.Checked then
      style += ',BorderStyle=4,BackColour=' + IntToHexStr(cbnBox.ButtonColor, True, '&H00');

    if GenerateVideoWithSubtitle(frmMain.MPV.FileName, sub, FOutputFileName,
      spnWidth.Value, spnHeight.Value,
      TFFVideoEncoders[cboVideoEncoding.ItemIndex].Codec, cboVideoPreset.ItemIndex, style,
      aEnc, TFFAudioChannels[cboAudioChannels.ItemIndex].Value,
      TFFAudioSampleRate[cboSampleRate.ItemIndex].Value,
      TFFAudioBitRate[cboBitRate.ItemIndex].Value,
      @ProcessCB) then
        ShowMessageDialog(GetCommonString('FileSavedSuccessfully'), '', GetCommonString('OpenContainingFolder'), @OpenFolderClick)
      else
        ShowErrorMessageDialog(GetCommonString('VideoGenerationFailed'));

    SetControlsEnabled(True);
    //Close;
  end;
end;

// -----------------------------------------------------------------------------

end.

