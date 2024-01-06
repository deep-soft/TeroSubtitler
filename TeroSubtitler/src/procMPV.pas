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

unit procMPV;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Graphics, Dialogs, procTypes, formMain,
  UWSubtitleAPI, UWSubtitleAPI.Formats;

procedure PrepareMPV;
procedure UpdateMPVOptions;
procedure MPVPlaySelectionOnly;
procedure MPVPlay(const PlayMode: TMediaPlayMode = mpmAll);
procedure MPVSeekTo(const AForward: Boolean; const MSecsToSeek: Integer); overload;
procedure MPVSeekTo(const Value: Integer; const Play: Boolean = False); overload;
procedure MPVAlterPlayRate(const Value: Boolean);
procedure MPVLoadSubtitleTempTrack;
procedure MPVReloadSubtitleTempTrack(const ASaveBefore: Boolean = False);
procedure MPVRemoveSubtitleTempTrack;
function MPVSaveSubtitleTempTrack: Boolean;
procedure MPVDeleteSubtitleTempTrack;
function PrepareSSAStyleString: AnsiString;
procedure MPVSetVideoFilters;
procedure MPVSetAudioFilters;
procedure MPVSetFilters;

// -----------------------------------------------------------------------------

implementation

uses MPVPlayer, procConfig, UWSystem.Encoding, UWSystem.SysUtils,
  MPVPlayer.Filters;

// -----------------------------------------------------------------------------

procedure PrepareMPV;
begin
  with frmMain.MPV do
  begin
    {$IFNDEF LINUX}
    MPVFileName := libMPVFileName(False);
    {$ENDIF}
    {$IFDEF DARWIN}
    YTDLPFileName := procConfig.YTDLPFileName;
    {$ENDIF}
    LogLevel := llNo;
    AutoStartPlayback := False;
    SMPTEMode := Workspace.SMPTE;
    with MPVOptions do
    begin
      AddOption('osd-color=' + TextColor);
      AddOption('sub-color=' + TextColor);
      AddOption('osd-border-color=' + TextBorderColor);
      AddOption('sub-border-color=' + TextBorderColor);
      if UseTextShadowColor then
      begin
        AddOption('osd-shadow-color=' + TextShadowColor);
        AddOption('sub-shadow-color=' + TextShadowColor);
        AddOption('osd-shadow-offset=' + IntToStr(TextShadowOffset));
        AddOption('sub-shadow-offset=' + IntToStr(TextShadowOffset));
      end;
      if UseTextBackgroundColor then
      begin
        AddOption('osd-back-color=' + TextBackgroundColor);
        AddOption('sub-back-color=' + TextBackgroundColor);
      end;
      AddOption('osd-align-x=center');
      AddOption('osd-align-y=' + TextPosition);
      AddOption('osd-font-size=' + IntToStr(TextSize));
      AddOption('sub-font-size=' + IntToStr(TextSize));
      AddOption('osd-scale-by-window=yes');
      AddOption('osd-scale-with-window=yes');
      AddOption('sub-scale-by-window=yes');
      AddOption('sub-scale-with-window=yes');
      AddOption('volume=' + IntToStr(Volume.Percent));
      AddOption('mute=' + SysUtils.BoolToStr(Volume.Mute, 'yes', 'no'));

      //AddOption('log-file='+LogMPVFileName);
    end;
  end;
end;

// -----------------------------------------------------------------------------

procedure UpdateMPVOptions;
begin
  with frmMain, MPVOptions do
  begin
    MPV.mpv_set_option_string_('osd-font-size=' + IntToStr(TextSize));
    MPV.mpv_set_option_string_('sub-font-size=' + IntToStr(TextSize));
    MPV.mpv_set_option_string_('osd-color=' + TextColor);
    MPV.mpv_set_option_string_('sub-color=' + TextColor);
    MPV.mpv_set_option_string_('osd-border-color=' + TextBorderColor);
    MPV.mpv_set_option_string_('sub-border-color=' + TextBorderColor);

    if UseTextShadowColor then
    begin
      MPV.mpv_set_option_string_('osd-shadow-color=' + TextShadowColor);
      MPV.mpv_set_option_string_('sub-shadow-color=' + TextShadowColor);
      MPV.mpv_set_option_string_('osd-shadow-offset=' + IntToStr(TextShadowOffset));
      MPV.mpv_set_option_string_('sub-shadow-offset=' + IntToStr(TextShadowOffset));
    end;

    if UseTextBackgroundColor then
    begin
      MPV.mpv_set_option_string_('osd-back-color=' + TextBackgroundColor);
      MPV.mpv_set_option_string_('sub-back-color=' + TextBackgroundColor);
    end
    else
    begin
      MPV.mpv_set_option_string_('osd-back-color=#00000000');
      MPV.mpv_set_option_string_('sub-back-color=#00000000');
    end;
  end;

  Subtitles.FormatProperties^.SSA.DefaultStyleSettings := PrepareSSAStyleString;
end;

// -----------------------------------------------------------------------------

procedure MPVPlaySelectionOnly;
begin
  with frmMain do
    if WAVE.IsTimeLineEnabled and (not WAVE.SelectionIsEmpty) then
      MPV.Loop(WAVE.Selection.InitialTime, WAVE.Selection.FinalTime, WAVEOptions.LoopCount);
end;

// -----------------------------------------------------------------------------

procedure MPVPlayFromSelection(const Value: Integer = 0; const FromInitialTime: Boolean = True);
begin
  with frmMain do
    if WAVE.IsTimeLineEnabled and (not WAVE.SelectionIsEmpty) then
      if FromInitialTime then
        MPVSeekTo(WAVE.Selection.InitialTime + Value, True)
      else
        MPVSeekTo(WAVE.Selection.FinalTime + Value, True);
end;

// -----------------------------------------------------------------------------

procedure MPVPlay(const PlayMode: TMediaPlayMode = mpmAll);
begin
  Workspace.MediaPlayMode := PlayMode;

  with frmMain do
  begin
    case PlayMode of
      mpmSelection       : MPVPlaySelectionOnly;
      mpmFromSelection   : MPVPlayFromSelection;
      mpmBeforeSelection : MPVPlayFromSelection(-500);
      mpmAfterSelection  : MPVPlayFromSelection(+500, False);
    else
      MPV.Resume;
    end;
  end;
end;

// -----------------------------------------------------------------------------

procedure MPVSeekTo(const AForward: Boolean; const MSecsToSeek: Integer);
var
  ct, mt, tt: Integer;
begin
  with frmMain do
  begin
    ct := MPV.GetMediaPosInMs;
    tt := MPV.GetMediaLenInMs;

    if AForward then
      mt := ct + MSecsToSeek
    else
      mt := ct - MSecsToSeek;

    if mt < 0 then
      mt := 0
    else if mt > tt then
      mt := tt;

    MPVSeekTo(mt);
  end;
end;

// -----------------------------------------------------------------------------

procedure MPVSeekTo(const Value: Integer; const Play: Boolean = False);
begin
  with frmMain do
  begin
    MPV.SetMediaPosInMs(Value);
    if Play then MPV.Resume(True);
  end;
end;

// -----------------------------------------------------------------------------

procedure MPVAlterPlayRate(const Value: Boolean);
begin
  with frmMain do
    if Value then
      MPV.SetPlaybackRate(AppOptions.DefChangePlayRate)
    else
      MPV.SetPlaybackRate(100);
end;

// -----------------------------------------------------------------------------

procedure MPVLoadSubtitleTempTrack;
begin
  frmMain.MPV.LoadTrack(ttSubtitle, MPVTempSubFileName);
end;

// -----------------------------------------------------------------------------

procedure MPVReloadSubtitleTempTrack(const ASaveBefore: Boolean = False);
begin
  if ASaveBefore then MPVSaveSubtitleTempTrack;
  frmMain.MPV.ReloadTrack(ttSubtitle);
end;

// -----------------------------------------------------------------------------

procedure MPVRemoveSubtitleTempTrack;
begin
  frmMain.MPV.RemoveTrack(ttSubtitle);
end;

// -----------------------------------------------------------------------------

function MPVSaveSubtitleTempTrack: Boolean;
var
  AFPS : Single;
begin
  AFPS      := Workspace.FPS.OutputFPS;

  if Workspace.WorkMode = wmTime then
    Subtitles.TimeBase := stbMedia
  else
  begin
    if IsInteger(Subtitles.FrameRate) then
      Subtitles.TimeBase := stbMedia
    else
      Subtitles.TimeBase := stbSMPTE;
  end;

  Subtitles.Tag := 1;
  Result := Subtitles.SaveToFile(MPVTempSubFileName, AFPS, TEncoding.UTF8, sfAdvancedSubStationAlpha, smText);
  Subtitles.Tag := 0;
end;

// -----------------------------------------------------------------------------

procedure MPVDeleteSubtitleTempTrack;
begin
  if FileExists(MPVTempSubFileName) then DeleteFile(MPVTempSubFileName);
end;

// -----------------------------------------------------------------------------

function PrepareSSAStyleString: AnsiString;

  function CorrectColorFormat(const AColor: String): String;
  begin
    Result := Format('&H00%s%s%s', [Copy(AColor, 6, 2), Copy(AColor, 4, 2), Copy(AColor, 2, 2)]);
  end;

begin
  with MPVOptions do
    Result := Format('Default,Arial,%d,%s,%s,%s,%s,0,0,0,0,100,100,0,0,1,1,1,2,10,10,10,1', [TextSize, CorrectColorFormat(TextColor), CorrectColorFormat(TextColor), CorrectColorFormat(TextBorderColor), CorrectColorFormat(TextBackgroundColor)]);
end;

// -----------------------------------------------------------------------------

procedure MPVSetVideoFilters;
var
  AVideoFilters: TMPVPlayerVideoFilters;
begin
  AVideoFilters := [];

  with frmMain do
  begin
    if actVideoFilterHFlip.Checked then Include(AVideoFilters, vfHFlip);
    if actVideoFilterVFlip.Checked then Include(AVideoFilters, vfVFlip);
    if actVideoFilterSharpen.Checked then Include(AVideoFilters, vfSharpen);
    if actVideoFilterBlur.Checked then Include(AVideoFilters, vfBlur);
    if actVideoFilterEdgeEnhance.Checked then Include(AVideoFilters, vfEdgeEnhance);
    if actVideoFilterEmboss.Checked then Include(AVideoFilters, vfEmboss);
    if actVideoFilterNegative.Checked then Include(AVideoFilters, vfNegative);
    if actVideoFilterVintage.Checked then Include(AVideoFilters, vfVintage);

    MPV.SetVideoFilters(AVideoFilters);
  end;
end;

// -----------------------------------------------------------------------------

procedure MPVSetAudioFilters;
var
  AAudioFilters: TMPVPlayerAudioFilters;
begin
  AAudioFilters := [];

  with frmMain do
  begin
    if actAudioFilterDialoguEnhance.Checked then Include(AAudioFilters, afDialoguEnhance);
    if actAudioFilterSurround.Checked then Include(AAudioFilters, afSurround);
    if actAudioFilterSpeechNormalizer.Checked then Include(AAudioFilters, afSpeechNormalizer);

    MPV.SetAudioFilters(AAudioFilters);
  end;
end;

// -----------------------------------------------------------------------------

procedure MPVSetFilters;
begin
  MPVSetVideoFilters;
  MPVSetAudioFilters;
end;

// -----------------------------------------------------------------------------

end.
