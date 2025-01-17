{*
 *  URUWorks EditAction
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

unit UWEditAction;

//------------------------------------------------------------------------------

{$mode ObjFPC}{$H+}

interface

uses
  Classes, Controls, StdCtrls, Forms, LCLType, SysUtils, Math, ActnList,
  ImgList, LCLProc, LCLIntf, LazarusPackageIntf;

type

  TUWEditAction = class;

  { TUWEditActionFormList }

  TOnClickActionEvent = procedure(Sender: TObject; const AAction: TAction) of object;
  TLocalizeFunc = function(const AText: String): String;

  TUWEditActionFormList = class(TCustomForm)
  private
    FEditAction: TUWEditAction;
    FListBox: TListBox;
    procedure ListBoxMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure ListBoxMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure DoActionEvent;
    procedure UpdateText;
  protected
    procedure DoClose(var CloseAction: TCloseAction); override;
  public
    constructor CreateNew(AOwner: TComponent; Num: Integer = 0); override;
    destructor Destroy; override;
    procedure CloseAndReturnAction;
    procedure MoveSelection(const APrevious: Boolean);
  end;

  { TUWEditAction }

  TUWEditAction = class(TCustomEdit)
  private
    FActionList : TActionList;
    FImages : TCustomImageList;
    FUpdating : Boolean;
    FOnClickAction: TOnClickActionEvent;
    FOnPopupList: TNotifyEvent;
    FDoLocalize: TLocalizeFunc;
    procedure FillListWithFilter(const AText: String);
    procedure CloseFormPopupList;
  protected
    procedure KeyDown(var Key: Word; Shift: TShiftState); override;
    procedure Change; override;
    procedure DoExit; override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure BeginUpdate;
    procedure EndUpdate;
    property LocalizeFunc : TLocalizeFunc read FDoLocalize write FDoLocalize;
  published
    property ActionList : TActionList read FActionList write FActionList;
    property Images : TCustomImageList read FImages write FImages;
    property OnClickAction : TOnClickActionEvent read FOnClickAction write FOnClickAction;
    property OnPopupList : TNotifyEvent read FOnPopupList write FOnPopupList;

    property Align;
    property Alignment;
    property AutoSize;
    property Anchors;
    property AutoSelect;
    property BorderSpacing;
    property BorderStyle;
    property CharCase;
    property Color;
    property Constraints;
    property DragCursor;
    property DragKind;
    property DragMode;
    property EchoMode;
    property Enabled;
    property Font;
    property HideSelection;
    property Hint;
    property ParentBidiMode;
    property OnChange;
    property OnChangeBounds;
    property OnClick;
    property OnContextPopup;
    property OnDblClick;
    property OnDragDrop;
    property OnDragOver;
    property OnEditingDone;
    property OnEndDrag;
    property OnEnter;
    property OnExit;
    property OnKeyDown;
    property OnKeyPress;
    property OnKeyUp;
    property OnMouseDown;
    property OnMouseEnter;
    property OnMouseLeave;
    property OnMouseMove;
    property OnMouseUp;
    property OnMouseWheel;
    property OnMouseWheelDown;
    property OnMouseWheelUp;
    property OnResize;
    property OnStartDrag;
    property ParentColor;
    property ParentFont;
    property ParentShowHint;
    property ShowHint;
    property TabStop;
    property TabOrder;
    property TextHint;
    property Visible;
  end;

procedure Register;

//------------------------------------------------------------------------------

implementation

var
  FormPopupList: TUWEditActionFormList = NIL;

// -----------------------------------------------------------------------------

{ TUWEditActionFormList }

// -----------------------------------------------------------------------------

constructor TUWEditActionFormList.CreateNew(AOwner: TComponent; Num: Integer = 0);
begin
  inherited CreateNew(AOwner, Num);

  BorderStyle := bsNone;
  FormStyle := fsStayOnTop;
  ShowInTaskBar := stNever;
  FEditAction := NIL;
  FListBox := TListBox.Create(Self);
  with FListBox do
  begin
    Parent := Self;
    Align := alClient;
    ClickOnSelChange := False;
    OnMouseDown := @ListBoxMouseDown;
    OnMouseMove := @ListBoxMouseMove
  end;
end;

// -----------------------------------------------------------------------------

destructor TUWEditActionFormList.Destroy;
begin
  FEditAction := NIL;
  FListBox.Free;
  FormPopupList := NIL;

  inherited Destroy;
end;

// -----------------------------------------------------------------------------

procedure TUWEditActionFormList.DoClose(var CloseAction: TCloseAction);
begin
  CloseAction := caFree;

  inherited DoClose(CloseAction);
end;

// -----------------------------------------------------------------------------

procedure TUWEditActionFormList.ListBoxMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
 if FListBox.GetIndexAtXY(X, Y) <> -1 then
   CloseAndReturnAction
 else
   FEditAction.Text := '';
end;

// -----------------------------------------------------------------------------

procedure TUWEditActionFormList.ListBoxMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
var
  i: Integer;
begin
 i := FListBox.GetIndexAtXY(X, Y);
 if i <> -1 then
   FListBox.ItemIndex := i;
end;

// -----------------------------------------------------------------------------

procedure TUWEditActionFormList.DoActionEvent;
begin
  with FEditAction do
  begin
    FEditAction.BeginUpdate;
    FEditAction.Text := '';
    FEditAction.EndUpdate;
    if Assigned(FOnClickAction) and Assigned(FActionList) and (FListBox.ItemIndex >= 0) then
      FOnClickAction(Self, TAction(FActionList.Actions[PtrUInt(FListBox.Items.Objects[FListBox.ItemIndex])]));
  end;
end;

// -----------------------------------------------------------------------------

procedure TUWEditActionFormList.CloseAndReturnAction;
begin
  Hide;
  DoActionEvent;
  Close;
end;

// -----------------------------------------------------------------------------

procedure TUWEditActionFormList.UpdateText;
begin
  with FEditAction do
  begin
    BeginUpdate;
    Text := FListBox.Items[FListBox.ItemIndex];
    EndUpdate;
  end;
end;

// -----------------------------------------------------------------------------

procedure TUWEditActionFormList.MoveSelection(const APrevious: Boolean);
var
  i: Integer;
begin
  if FListBox.Items.Count > 0 then
  begin
    i := FListBox.ItemIndex;
    if APrevious then
      Dec(i)
    else
      Inc(i);

    i := EnsureRange(i, 0, FListBox.Items.Count-1);

    if i <> FListBox.ItemIndex then
    begin
      FListBox.ItemIndex := i;
      UpdateText;
    end;
  end;
end;

// -----------------------------------------------------------------------------

{ TUWEditAction }

// -----------------------------------------------------------------------------

constructor TUWEditAction.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);

  AutoSize := False;
  FActionList := NIL;
  FUpdating := False;
  FOnClickAction := NIL;
  FOnPopupList := NIL;
  FDoLocalize := NIL;
end;

// -----------------------------------------------------------------------------

destructor TUWEditAction.Destroy;
begin
  CloseFormPopupList;
  FActionList := NIL;
  FOnClickAction := NIL;
  FOnPopupList := NIL;
  FDoLocalize := NIL;

  inherited Destroy;
end;

// -----------------------------------------------------------------------------

procedure TUWEditAction.BeginUpdate;
begin
  FUpdating := True;
end;

// -----------------------------------------------------------------------------

procedure TUWEditAction.EndUpdate;
begin
  FUpdating := False;
end;

// -----------------------------------------------------------------------------

procedure TUWEditAction.KeyDown(var Key: Word; Shift: TShiftState);

  procedure MoveUpOrDown(const AUp: Boolean);
  begin
    if Assigned(FormPopupList) then
    begin
      FormPopupList.MoveSelection(AUp);
      SelectAll;
      Key := 0;
    end;
  end;

begin
  case Key of
    VK_UP     : MoveUpOrDown(True);
    VK_DOWN   : MoveUpOrDown(False);
    VK_RETURN : if Assigned(FormPopupList) then FormPopupList.CloseAndReturnAction;
    VK_ESCAPE : CloseFormPopupList;
  else
    inherited KeyDown(Key, Shift);
  end;
end;

// -----------------------------------------------------------------------------

procedure TUWEditAction.Change;
begin
  if not FUpdating then
    FillListWithFilter(Text)
  else
    inherited Change;
end;

// -----------------------------------------------------------------------------

procedure TUWEditAction.DoExit;
begin
  CloseFormPopupList;
  inherited DoExit;
end;

// -----------------------------------------------------------------------------

procedure TUWEditAction.FillListWithFilter(const AText: String);
var
  i : Integer;
  xy : TPoint;
  frm : TForm;
  s : String;
begin
  if not Assigned(FormPopupList) then
  begin
    xy := ControlToScreen(Point(0, ClientHeight));
    FormPopupList := TUWEditActionFormList.CreateNew(Application);
    FormPopupList.FEditAction := Self;
    FormPopupList.SetBounds(xy.x, xy.y + BorderWidth, Width * 2, Height * 10);

    if (FormPopupList.Left + FormPopupList.Width) > Screen.Width then
      FormPopupList.Width := Screen.Width - FormPopupList.Left;

    frm := Screen.ActiveForm;
  end;

  with FormPopupList do
  begin
    FListBox.Items.Clear;
    if AText.IsEmpty then
    begin
      FormPopupList.Close;
      Exit;
    end;

    FListBox.Items.BeginUpdate;
    try
      if Assigned(FActionList) then
        for i := 0 to FActionList.ActionCount-1 do
          with TAction(FActionList.Actions[i]) do
          begin
            if LowerCase(Caption).Contains(AText.ToLower) then
            begin
              s := Caption;

              if not Category.IsEmpty then
              begin
                if Assigned(FDoLocalize) then
                  s := Format('[%s] %s', [FDoLocalize(Category), s])
                else
                  s := Format('[%s] %s', [Category, s]);
              end;

              if ShortCut <> 0 then
                s := Format('%s (%s)', [s, ShortCutToText(ShortCut)]);

              FListBox.Items.AddObject(s, TObject(PtrInt(i)));
            end;
          end;
    finally
      if FListBox.Items.Count > 0 then
        FListBox.ItemIndex := 0;

      FListBox.Items.EndUpdate;
    end;

    if (FListBox.Items.Count = 0) then
      FormPopupList.Close
    else if not FormPopupList.Visible then
    begin
      if FListBox.Items.Count < 10 then
        {$IFDEF WINDOWS}
        FormPopupList.Height := Self.Height * FListBox.Items.Count;
        {$ELSE}
        FormPopupList.Height := (Self.Height*2) * FListBox.Items.Count;
        {$ENDIF}

      if Assigned(FOnPopupList) then FOnPopupList(FormPopupList);
      FormPopupList.Visible := True; //ShowWindow(FormPopupList.Handle, SW_SHOWNOACTIVATE);
      if frm <> NIL then
      begin
        frm.SetFocus;
        {$IFDEF DARWIN}
        SelStart := SelLength; //without this it does not work correctly on macOS
        {$ENDIF}
      end;
    end;
  end;
end;

// -----------------------------------------------------------------------------

procedure TUWEditAction.CloseFormPopupList;
begin
  Text := '';
  if Assigned(FormPopupList) then FormPopupList.Close;
end;

// -----------------------------------------------------------------------------

procedure RegisterTeroControlsUnit;
begin
  RegisterComponents('URUWorks Tero', [TUWEditAction]);
end;

// -----------------------------------------------------------------------------

procedure Register;
begin
  RegisterUnit('UWEditAction', @RegisterTeroControlsUnit);
end;

// -----------------------------------------------------------------------------

end.

