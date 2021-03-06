unit LamwDesigner;

{$mode objfpc}{$h+}

interface

uses
  Classes, SysUtils, Graphics, Controls, FormEditingIntf, PropEdits,
  ComponentEditors, ProjectIntf, Laz2_DOM, AndroidWidget, LCLVersion, fileutil, Dialogs;

type
  TDraftWidget = class;

  jVisualControlClass = class of jVisualControl;
  TDraftWidgetClass = class of TDraftWidget;

  { TDraftControlHash }

  TDraftControlHash = class
  private
    FFreeLeft: Integer;
    FItems: array of record
      VisualControl: jVisualControlClass;
      Draft: TDraftWidgetClass;
    end;
    function Hash1(c: TClass): PtrUInt; inline;
    function Hash2(i: PtrUInt): PtrUInt; inline;
  public
    constructor Create(MaxCapacity: Integer);
    procedure Add(VisualControlClass: jVisualControlClass; DraftWidgetClass: TDraftWidgetClass);
    function Find(VisualControlClass: TClass): TDraftWidgetClass;
  end;

  { TAndroidWidgetMediator :: thanks to x2nie !}

  TAndroidWidgetMediator = class(TDesignerMediator,IAndroidWidgetDesigner)
  private
    FDefaultBrushColor: TColor;
    FDefaultPenColor: TColor;
    FDefaultFontColor: TColor;
    FSizing: Boolean;
    FStarted, FDone: TFPList;
    FLastSelectedContainer: jVisualControl;
    FSelection: TFPList;

    // smart designer helpers
    FSelectedJControlClassName: String;
    FPathToJavaTemplates: string;
    FPathToAndroidProject: string;
    FPackageName: string;
    FPathToJavaSource: string;
    FStartModuleVarName: string;
    FStartModuleTypeName: string;
    FNDKIndex: string;
    FPathToAndroidNDK: string;
    FPathToAndroidSDK: string;

    function GetAndroidForm: jForm;

    //Smart Designer helpers
    procedure InitSmartDesignerHelpers;
    function IsStartModule(uName: string): boolean;
    function GetStartModuleMode(): string;
    procedure SetStartModuleTypeNameAndVarName();
    function TryRemoveJControl(jclassname: string; out nativeRemoved: boolean): boolean;
    function TryAddJControl(jclassname: string; out nativeAdded: boolean): boolean;
    procedure GetAllJControlsFromForms(const jcontrolsList: TStrings);
    procedure CleanupAllJControlsSource();

    procedure TryChangeDemoProjecPaths;
    function IsDemoProject(): boolean;
    procedure TryFindDemoPathsFromReadme(out pathToDemoNDK: string; out pathToDemoSDK: string);
    procedure UpdateProjectLPR;
    function GetEventSignature(nativeMethod: string): string;

  protected
    procedure OnDesignerModified(Sender: TObject{$If lcl_fullversion>1060004}; {%H-}PropName: ShortString{$ENDIF});
    procedure OnPersistentAdded(APersistent: TPersistent; {%H-}Select: boolean);
    procedure OnSetSelection(const ASelection: TPersistentSelectionList);

    //smart designer helper
    procedure OnComponentRenamed(AComponent: TComponent);

  public

    //needed by the lazarus form editor
    class function CreateMediator(TheOwner, TheForm: TComponent): TDesignerMediator; override;
    class function FormClass: TComponentClass; override;

    procedure GetBounds(AComponent: TComponent; out CurBounds: TRect); override;
    procedure SetBounds(AComponent: TComponent; NewBounds: TRect); override;
    procedure GetClientArea(AComponent: TComponent; out CurClientArea: TRect; out ScrollOffset: TPoint); override;
    procedure InitComponent(AComponent, NewParent: TComponent; NewBounds: TRect); override;
    procedure Paint; override;
    procedure KeyUp(Sender: TControl; var {%H-}Key: word; {%H-}Shift: TShiftState); override;
    function ComponentIsIcon(AComponent: TComponent): boolean; override;
    function ParentAcceptsChild(Parent: TComponent; Child: TComponentClass): boolean; override;
    procedure UpdateTheme;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; p: TPoint; var Handled: boolean); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; p: TPoint; var Handled: boolean); override;

  public
    // needed by TAndroidWidget
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure InvalidateRect(Sender: TObject; ARect: TRect; Erase: boolean);
    property AndroidForm: jForm read GetAndroidForm;

  public
    procedure GetObjInspNodeImageIndex(APersistent: TPersistent; var AIndex: integer); override;
  end;


  { TDraftWidget }

  TDraftWidget = class
  private
    FColor: TARGBColorBridge;
    FFontColor: TARGBColorBridge;
    procedure SetColor(color: TARGBColorBridge);
    procedure SetFontColor(AColor: TARGBColorBridge);
    function Designer: TAndroidWidgetMediator;
  protected
    FAndroidWidget: TAndroidWidget;      // original
    FCanvas: TCanvas;                    // canvas to draw onto
    FnewW, FnewH, FnewL, FnewT: Integer; // layout
    FminW, FminH: Integer;
    function GetParentBackgroundColor: TARGBColorBridge;
    function GetBackGroundColor: TColor;
  public
    BackGroundColor: TColor;
    TextColor: TColor;
    MarginBottom: integer;
    MarginLeft: integer;
    MarginRight: integer;
    MarginTop: integer;
    Height: integer;
    Width: integer;
    constructor Create(AWidget: TAndroidWidget; Canvas: TCanvas); virtual;
    procedure Draw; virtual;
    procedure UpdateLayout; virtual;
    property Color: TARGBColorBridge read FColor write SetColor;
    property FontColor: TARGBColorBridge read FFontColor write SetFontColor;
  end;

  { TDraftTextView }

  TDraftTextView = class(TDraftWidget)
  public
    constructor Create(AWidget: TAndroidWidget; Canvas: TCanvas); override;
    procedure Draw; override;
    procedure UpdateLayout; override;
  end;

  { TDraftEditText }

  TDraftEditText = class(TDraftWidget)
  public
    constructor Create(AWidget: TAndroidWidget; Canvas: TCanvas); override;
    procedure Draw; override;
    procedure UpdateLayout; override;
  end;

  { TDraftAutoTextView }

  TDraftAutoTextView = class(TDraftWidget)
  public
    constructor Create(AWidget: TAndroidWidget; Canvas: TCanvas); override;
    procedure Draw; override;
    procedure UpdateLayout; override;
  end;

  { TDraftButton }

  TDraftButton = class(TDraftWidget)
  public
    constructor Create(AWidget: TAndroidWidget; Canvas: TCanvas); override;
    procedure Draw; override;
    procedure UpdateLayout; override;
  end;

  { TDraftCheckBox }

  TDraftCheckBox = class(TDraftWidget)
  public
    constructor Create(AWidget: TAndroidWidget; Canvas: TCanvas); override;
    procedure Draw; override;
    procedure UpdateLayout; override;
  end;

  { TDraftRadioButton }

  TDraftRadioButton = class(TDraftWidget)
  public
    constructor Create(AWidget: TAndroidWidget; Canvas: TCanvas); override;
    procedure Draw; override;
    procedure UpdateLayout; override;
  end;

  TDraftRadioGroup = class(TDraftWidget)
  public
    constructor Create(AWidget: TAndroidWidget; Canvas: TCanvas); override;
    procedure Draw; override;
  end;

  { TDraftRatingBar }

  TDraftRatingBar = class(TDraftWidget)
  public
    constructor Create(AWidget: TAndroidWidget; Canvas: TCanvas); override;
    procedure Draw; override;
    procedure UpdateLayout; override;
  end;

  TDraftDigitalClock = class(TDraftWidget)
  public
    constructor Create(AWidget: TAndroidWidget; Canvas: TCanvas); override;
  end;

  TDraftAnalogClock = class(TDraftWidget)
  public
    constructor Create(AWidget: TAndroidWidget; Canvas: TCanvas); override;
  end;

  { TDraftProgressBar }

  TDraftProgressBar = class(TDraftWidget)
  public
    constructor Create(AWidget: TAndroidWidget; Canvas: TCanvas); override;
    procedure Draw; override;
    procedure UpdateLayout; override;
  end;

  TDraftSeekBar = class(TDraftWidget)
  public
    constructor Create(AWidget: TAndroidWidget; Canvas: TCanvas); override;
    procedure Draw; override;
    procedure UpdateLayout; override;
  end;

  { TDraftListView }

  TDraftListView = class(TDraftWidget)
  public
    constructor Create(AWidget: TAndroidWidget; Canvas: TCanvas); override;
    procedure Draw; override;
  end;

  { TDraftImageBtn }

  TDraftImageBtn = class(TDraftWidget)
  public
    constructor Create(AWidget: TAndroidWidget; Canvas: TCanvas); override;
    procedure Draw; override;
  end;

  { TDraftImageView }

  TDraftImageView = class(TDraftWidget)
   public
     constructor Create(AWidget: TAndroidWidget; Canvas: TCanvas); override;
   end;

  {TDraftDrawingView}

  TDraftDrawingView = class(TDraftWidget)
   public
     constructor Create(AWidget: TAndroidWidget; Canvas: TCanvas); override;
   end;

  {TDraftSurfaceView}

  TDraftSurfaceView = class(TDraftWidget)
   public
     constructor Create(AWidget: TAndroidWidget; Canvas: TCanvas); override;
   end;

  { TDraftSpinner }

  TDraftSpinner = class(TDraftWidget)
  private
    FDropListTextColor: TARGBColorBridge;
    DropListFontColor: TColor;

    FDropListBackgroundColor: TARGBColorBridge;
    DropListColor: TColor;

    FSelectedFontColor: TARGBColorBridge;
    SelectedTextColor: TColor;

    procedure SetDropListTextColor(Acolor: TARGBColorBridge);
    procedure SetDropListBackgroundColor(Acolor: TARGBColorBridge);
    procedure SetSelectedFontColor(Acolor: TARGBColorBridge);

  public
     constructor Create(AWidget: TAndroidWidget; Canvas: TCanvas); override;
     procedure Draw; override;

     property DropListTextColor: TARGBColorBridge read FDropListTextColor write SetDropListTextColor;
     property DropListBackgroundColor: TARGBColorBridge  read FDropListBackgroundColor write SetDropListBackgroundColor;
     property SelectedFontColor: TARGBColorBridge  read FSelectedFontColor write SetSelectedFontColor;
  end;

  { TDraftWebView }

  TDraftWebView = class(TDraftWidget)
  public
     constructor Create(AWidget: TAndroidWidget; Canvas: TCanvas); override;
     procedure Draw; override;
  end;

  { TDraftScrollView }

  TDraftScrollView = class(TDraftWidget)
  public
     constructor Create(AWidget: TAndroidWidget; Canvas: TCanvas); override;
     procedure Draw; override;
  end;

  TDraftHorizontalScrollView = class(TDraftWidget)
  public
     constructor Create(AWidget: TAndroidWidget; Canvas: TCanvas); override;
     procedure Draw; override;
  end;

  { TDraftToggleButton }

  TDraftToggleButton = class(TDraftWidget)
  private
     FOnOff: boolean;
  public
     constructor Create(AWidget: TAndroidWidget; Canvas: TCanvas); override;
     procedure Draw; override;
  end;

  { TDraftSwitchButton }

  TDraftSwitchButton = class(TDraftWidget)
  public
    procedure Draw; override;
    procedure UpdateLayout; override;
  end;

  { TDraftGridView }

  TDraftGridView = class(TDraftWidget)
  public
     constructor Create(AWidget: TAndroidWidget; Canvas: TCanvas); override;
     procedure Draw; override;
  end;

  { TDraftView }

  TDraftView = class(TDraftWidget)
  public
     constructor Create(AWidget: TAndroidWidget; Canvas: TCanvas); override;
  end;

  { TDraftPanel }

  TDraftPanel = class(TDraftWidget)
  public
    procedure Draw; override;
    procedure UpdateLayout; override;
  end;

  { TARGBColorBridgePropertyEditor }

  TARGBColorBridgePropertyEditor = class(TEnumPropertyEditor)
  public
    function GetAttributes: TPropertyAttributes; override;
    procedure ListDrawValue(const CurValue: ansistring; Index: integer;
      ACanvas: TCanvas; const ARect:TRect; AState: TPropEditDrawState); override;
    procedure PropDrawValue(ACanvas: TCanvas; const ARect: TRect;
      {%H-}AState: TPropEditDrawState); override;
  end;

  { TAnchorPropertyEditor }

  TAnchorPropertyEditor = class(TComponentOneFormPropertyEditor)
  public
    procedure GetValues(Proc: TGetStrProc); override;
  end;

  { TAndroidFormComponentEditor }

  TAndroidFormComponentEditor = class(TDefaultComponentEditor)
  private
    procedure ChangeSize(AWidth, AHeight: Integer);
    procedure ShowSelectSizeDialog;
  public
    procedure ExecuteVerb(Index: Integer); override;
    function GetVerb(Index: Integer): string; override;
    function GetVerbCount: Integer; override;
  end;

  { TAndroidFormSizeEditor }

   TAndroidFormSizeEditor = class(TIntegerPropertyEditor)
   public
     procedure Edit; override;
     function GetAttributes: TPropertyAttributes; override;
   end;

implementation

uses
  LCLIntf, LCLType, strutils, ObjInspStrConsts, IDEMsgIntf, LazIDEIntf,
  IDEExternToolIntf, laz2_XMLRead, LazFileUtils, FPimage, IniFiles, typinfo,uJavaParser,
  Laz_And_Controls, customdialog, togglebutton, switchbutton,
  Laz_And_GLESv1_Canvas, Laz_And_GLESv2_Canvas, gridview, Spinner, seekbar,
  uFormSizeSelect, radiogroup, ratingbar, digitalclock, analogclock,
  surfaceview, autocompletetextview, drawingview, chronometer;

const
  MaxRGB2Inverse = 64;

var
  DraftClassesMap: TDraftControlHash;


function GetPackageNameFromAndroidManifest(pathToAndroidManifest: string): string;
var
  str: string;
  xml: TXMLDocument;
begin
  str := pathToAndroidManifest+DirectorySeparator + 'AndroidManifest.xml';
  if not FileExists(str) then Exit('');
  ReadXMLFile(xml, str);
  try
    Result := xml.DocumentElement.AttribStrings['package'];
  finally
    xml.Free
  end;
end;

function ReplaceChar(const query: string; oldchar, newchar: char): string;
var
  i: Integer;
begin
  Result := query;
  for i := 1 to Length(Result) do
    if Result[i] = oldchar then Result[i] := newchar;
end;

function FindNodeAtrib(root: TDOMElement; const ATag, AAttr, AVal: string): TDOMElement;
var
  n: TDOMNode;
begin
  if not root.HasChildNodes then Exit(nil);
  n := root.FirstChild;
  while n <> nil do
  begin
    if n is TDOMElement then
      with TDOMElement(n) do
        if (TagName = ATag) and (AttribStrings[AAttr] = AVal) then
        begin
          Result := TDOMElement(n);
          Exit;
        end;
    n := n.NextSibling;
  end;
  Result := nil;
end;

function TryGetBackgroudColorByTheme(Theme, SdkValuesPath: string; out Color: TColor): Boolean;
var
  xml_themes, xml_themes_device: TXMLDocument;

  function FindTheme(AThemeName: string): TDOMElement;
  begin
    Result := nil;
    if (Copy(AThemeName, 1, 19) = 'Theme.DeviceDefault') then
    begin
      if Assigned(xml_themes_device) then
        Result := FindNodeAtrib(xml_themes_device.DocumentElement, 'style', 'name', AThemeName);
    end else
    if Assigned(xml_themes) then
      Result := FindNodeAtrib(xml_themes.DocumentElement, 'style', 'name', AThemeName);
  end;

var
  xml: TXMLDocument;
  n, nn: TDOMElement;
  colr: string;
  i: Integer;
begin
  Result := False;
  xml_themes := nil; xml_themes_device := nil;
  try
    if FileExists(SdkValuesPath + 'themes.xml') then
      ReadXMLFile(xml_themes, SdkValuesPath + 'themes.xml');
    if FileExists(SdkValuesPath + 'themes_device_defaults.xml') then
      ReadXMLFile(xml_themes_device, SdkValuesPath + 'themes_device_defaults.xml');

    colr := '';
    repeat
      n := FindTheme(Theme);
      if n = nil then Exit;
      nn := FindNodeAtrib(n, 'item', 'name', 'colorBackground');
      while (nn = nil) and (n.AttribStrings['parent'] <> '') do
      begin
        Theme := n.AttribStrings['parent'];
        n := FindTheme(Theme);
        nn := FindNodeAtrib(n, 'item', 'name', 'colorBackground');
      end;
      if nn <> nil then
        colr := nn.TextContent
      else begin
        i := RPos('.', Theme);
        if i = 0 then Exit;
        Theme := Copy(Theme, 1, i - 1)
      end;
    until colr <> ''
  finally
    xml_themes.Free;
    xml_themes_device.Free;
  end;
  if Pos('@android:color/', colr) = 1 then
  begin
    ReadXMLFile(xml, SdkValuesPath + 'colors.xml');
    try
      Delete(colr, 1, 15);
      n := FindNodeAtrib(xml.DocumentElement, 'color', 'name', colr);
      if n = nil then Exit;
      colr := n.TextContent;
    finally
      xml.Free
    end;
  end;
  if (colr = '') or (colr[1] <> '#') then Exit;
  colr := RightStr(colr, 6);
  Color := RGBToColor(StrToInt('$' + Copy(colr, 1, 2)),
                      StrToInt('$' + Copy(colr, 3, 2)),
                      StrToInt('$' + Copy(colr, 5, 2)));
  Result := True;
end;

function GetColorBackgroundByTheme(Root: TComponent): TColor;
var
  proj: TLazProjectFile;
  xml: TXMLDocument;
  fn, TargetSDK, Theme, SdkPath: string;
  n: TDOMNode;
  SDK: Longint;
  Found: Boolean;
begin
  Result := clWhite; // fallback
  proj := LazarusIDE.GetProjectFileWithRootComponent(Root);

  if proj <> nil then
  begin
    fn := proj.GetFullFilename;
    if (Pos(PathDelim + 'jni' + PathDelim, fn) = 0)
    and (proj.GetFileOwner is TLazProject) then
    begin
      proj := TLazProject(proj.GetFileOwner).Files[1];
      fn := proj.GetFullFilename;
    end;
    fn := Copy(fn, 1, Pos(PathDelim + 'jni' + PathDelim, fn));
    fn := fn + 'AndroidManifest.xml';
    if FileExists(fn) then
    begin
      ReadXMLFile(xml, fn);
      try
        n := xml.DocumentElement.FindNode('uses-sdk');
        if n is TDOMElement then
        begin
          TargetSDK := TDOMElement(n).AttribStrings['android:targetSdkVersion'];
          if TryStrToInt(TargetSDK, SDK) then
          begin
            fn := ExtractFilePath(fn) + 'res' + PathDelim + 'values-v';
            Found := False;
            while (SDK > 0) and not Found do
              if FileExists(fn + IntToStr(SDK) + PathDelim + 'styles.xml') then
                Found := True
              else
                Dec(SDK);
            if Found then
            begin
              xml.Free;
              ReadXMLFile(xml, fn + IntToStr(SDK) + PathDelim + 'styles.xml');
              n := FindNodeAtrib(xml.DocumentElement, 'style', 'name', 'AppBaseTheme');
              if n <> nil then
              begin
                Theme := TDOMElement(n).AttribStrings['parent'];
                Delete(Theme, 1, Pos(':', Theme));
                with TIniFile.Create(AppendPathDelim(LazarusIDE.GetPrimaryConfigPath) + 'JNIAndroidProject.ini') do
                try
                  SdkPath := ReadString('NewProject', 'PathToAndroidSDK', '');
                finally
                  Free
                end;
                SdkPath := AppendPathDelim(SdkPath) + 'platforms' + PathDelim
                  + 'android-' + TargetSDK + PathDelim + 'data' + PathDelim
                  + 'res' + PathDelim + 'values' + PathDelim;
                TryGetBackgroudColorByTheme(Theme, SdkPath, Result);
              end;
            end;
          end;
        end;
      finally
        xml.Free;
      end;
    end;
  end;
end;

procedure GetRedGreenBlue(rgb: longInt; out Red, Green, Blue: word); inline;
begin
  Red   := ( (rgb and $ff0000)  shr 16);
  Red   := Red shl 8 or Red;
  Green := ( (rgb and $ff00  )  shr  8);
  Green := Green shl 8 or Green;
  Blue  := ( (rgb and $ff    )        );
  Blue  := Blue shl 8 or Blue;
end;

function ToTFPColor(colbrColor: TARGBColorBridge): TFPColor;
var
  index: integer;
  red, green, blue: word;
begin
  index := Ord(colbrColor);
  GetRedGreenBlue(TFPColorBridgeArray[index], red, green, blue);
  Result.Red   := red;
  Result.Green := green;
  Result.Blue  := blue;
  Result.Alpha := AlphaOpaque;
end;

function AndroidToLCLFontSize(asize: DWord; Default: Integer): Integer; inline;
begin
  case asize of
  0: Result := Default;
  1: Result := 1;
  else Result := asize * 3 div 4;
  end;
end;

function MaxRGB(c: TColor): Byte;
var
  r, g, b: Byte;
begin
  RedGreenBlue(ColorToRGB(c), r, g, b);
  if g > r then r := g;
  if b > r then r := b;
  Result := r;
end;

function BlendColors(c: TColor; alpha: Double; r, g, b: Byte): TColor; inline;
var
  r1, g1, b1: Byte;
begin
  RedGreenBlue(ColorToRGB(c), r1, g1, b1);
  Result := RGBToColor(Byte(Trunc(r1 * alpha + r * (1 - alpha))),
                       Byte(Trunc(g1 * alpha + g * (1 - alpha))),
                       Byte(Trunc(b1 * alpha + b * (1 - alpha))));
end;

procedure RegisterAndroidWidgetDraftClass(AWidgetClass: jVisualControlClass;
  ADraftClass: TDraftWidgetClass);
begin
  DraftClassesMap.Add(AWidgetClass, ADraftClass);
end;

{ TAndroidFormSizeEditor }

procedure TAndroidFormSizeEditor.Edit;
begin
  with TAndroidFormComponentEditor.Create(GetComponent(0) as TComponent, nil) do
  try
    ShowSelectSizeDialog
  finally
    Free
  end;
end;

function TAndroidFormSizeEditor.GetAttributes: TPropertyAttributes;
begin
  Result := inherited GetAttributes + [paDialog];
end;

{ TAndroidFormComponentEditor }

procedure TAndroidFormComponentEditor.ChangeSize(AWidth, AHeight: Integer);
begin
  with jForm(Component) do
  begin
    if Assigned(Designer) then
      with Designer as TAndroidWidgetMediator, LCLForm do
        SetBounds(Left, Top, AWidth, AHeight);
    SetBounds(Left, Top, AWidth, AHeight);
  end;
end;

procedure TAndroidFormComponentEditor.ShowSelectSizeDialog;
begin
  with TfrmFormSizeSelect.Create(nil) do
  try
    with jForm(Component) do
      SetInitSize(Width, Height);
    if ShowModal = mrOk then
      ChangeSize(seWidth.Value, seHeight.Value);
  finally
    Free
  end;
end;

procedure TAndroidFormComponentEditor.ExecuteVerb(Index: Integer);
begin
  case Index of
  0: // Rotate
    with jForm(Component) do
      ChangeSize(Height, Width);
  1: ShowSelectSizeDialog; // Select size
  else
    inherited ExecuteVerb(Index);
  end;
end;

function TAndroidFormComponentEditor.GetVerb(Index: Integer): string;
begin
  case Index of
  0: Result := 'Rotate';
  1: Result := 'Select size...';
  else
    Result := inherited;
  end
end;

function TAndroidFormComponentEditor.GetVerbCount: Integer;
begin
  Result := 2;
end;

{ TAnchorPropertyEditor }

procedure TAnchorPropertyEditor.GetValues(Proc: TGetStrProc);
var
  i, j: Integer;
  p: TAndroidWidget;
  sl: TStringList;
begin
  Proc(oisNone);
  p := jVisualControl(GetComponent(0)).Parent;
  for i := 1 to PropCount - 1 do
    if jVisualControl(GetComponent(i)).Parent <> p then
      Exit;
  sl := TStringList.Create;
  try
    for i := 0 to p.ChildCount - 1 do
      sl.Add(p.Children[i].Name);
    sl.Sorted := True;
    for i := 0 to PropCount - 1 do
    begin
      j := sl.IndexOf(TComponent(GetComponent(i)).Name);
      if j >= 0 then sl.Delete(j);
    end;
    for i := 0 to sl.Count - 1 do
      Proc(sl[i]);
  finally
    sl.Free;
  end;
end;

{ TDraftPanel }

procedure TDraftPanel.Draw;
begin
  with Fcanvas do
  begin
    if jPanel(FAndroidWidget).BackgroundColor <> colbrDefault then
      Brush.Color := FPColorToTColor(ToTFPColor(jPanel(FAndroidWidget).BackgroundColor))
    else begin
      Brush.Color:= clNone;
      Brush.Style:= bsClear;
    end;
    Rectangle(0, 0, FAndroidWidget.Width, FAndroidWidget.Height);    // outer frame
  end;
end;

procedure TDraftPanel.UpdateLayout;
var
  maxH, i, t: Integer;
begin
   with jPanel(FAndroidWidget) do
    if (LayoutParamHeight = lpWrapContent) and (ChildCount > 0) then
    begin
      with Children[0] do
        maxH := Top + Height + MarginBottom;
      for i := 1 to ChildCount - 1 do
        with Children[i] do
        begin
          t := Top + Height + MarginBottom;
          if t > maxH then maxH := t;
        end;
      FnewH := maxH;
    end;
  inherited;
end;

{ TDraftControlHash }

function TDraftControlHash.Hash1(c: TClass): PtrUInt;
begin
  Result := ({%H-}PtrUInt(c) + {%H-}PtrUInt(c) shr 7) mod PtrUInt(Length(FItems));
end;

function TDraftControlHash.Hash2(i: PtrUInt): PtrUInt;
begin
  Result := (i + 7) mod PtrUInt(Length(FItems));
end;

constructor TDraftControlHash.Create(MaxCapacity: Integer);
begin
  SetLength(FItems, MaxCapacity);
  FFreeLeft := MaxCapacity;
end;

procedure TDraftControlHash.Add(VisualControlClass: jVisualControlClass;
  DraftWidgetClass: TDraftWidgetClass);
var
  i: PtrUInt;
begin
  if FFreeLeft = 0 then
    raise Exception.Create('[DraftControlHash] Overfull!');
  i := Hash1(VisualControlClass);
  while FItems[i].VisualControl <> nil do
    i := Hash2(i);
  with FItems[i] do
  begin
    VisualControl := VisualControlClass;
    Draft := DraftWidgetClass;
  end;
  Dec(FFreeLeft);
end;

function TDraftControlHash.Find(VisualControlClass: TClass): TDraftWidgetClass;
var i: PtrUInt;
begin
  Result := nil;
  i := Hash1(VisualControlClass);
  if FItems[i].VisualControl = nil then Exit;
  while FItems[i].VisualControl <> VisualControlClass do
  begin
    i := Hash2(i);
    if FItems[i].VisualControl = nil then Exit;
  end;
  Result := FItems[i].Draft;
end;

{ TARGBColorBridgePropertyEditor }

function TARGBColorBridgePropertyEditor.GetAttributes: TPropertyAttributes;
begin
  Result := [paMultiSelect,paValueList,paCustomDrawn];
end;

procedure TARGBColorBridgePropertyEditor.ListDrawValue(const CurValue: ansistring;
  Index: integer; ACanvas: TCanvas; const ARect: TRect;
  AState: TPropEditDrawState);
var
  h: Integer;
  r: TRect;
  bc: TColor;
begin
  h := ARect.Bottom - ARect.Top;
  with ACanvas do
  begin
    FillRect(ARect);
    bc := Pen.Color;
    Pen.Color := clBlack;
    r := ARect;
    r.Right := r.Left + h;
    InflateRect(r, -2, -2);
    Rectangle(r);
    if (TARGBColorBridge(Index) in [colbrDefault, colbrCustom]) then
    begin
      InflateRect(r, -1, -1);
      MoveTo(r.Left, r.Top); LineTo(r.Right, r.Bottom);
      MoveTo(r.Right - 1, r.Top); LineTo(r.Left - 1, r.Bottom);
      Pen.Color := bc;
    end else begin
      Pen.Color := bc;
      bc := Brush.Color;
      Brush.Color := FPColorToTColor(ToTFPColor(TARGBColorBridge(Index)));
      InflateRect(r, -1, -1);
      FillRect(r);
      Brush.Color := bc;
    end;
  end;
  r := ARect;
  r.Left := r.Left + h + 2;
  inherited ListDrawValue(CurValue, Index, ACanvas, r, AState);
end;

procedure TARGBColorBridgePropertyEditor.PropDrawValue(ACanvas: TCanvas;
  const ARect: TRect; AState: TPropEditDrawState);
var
  s: string;
  i: Integer;
begin
  s := GetVisualValue;
  for i := 0 to Ord(High(TARGBColorBridge)) do
    if GetEnumName(TypeInfo(TARGBColorBridge), i) = s then
    begin
      ListDrawValue(s, i, ACanvas, ARect, [pedsInEdit]);
      Exit;
    end;
end;

{ TAndroidWidgetMediator }

constructor TAndroidWidgetMediator.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FDefaultBrushColor:= clForm;
  FDefaultPenColor:= clMedGray;
  FDefaultFontColor:= clMedGray;
  GlobalDesignHook.AddHandlerModified(@OnDesignerModified);
  GlobalDesignHook.AddHandlerPersistentAdded(@OnPersistentAdded);
  GlobalDesignHook.AddHandlerSetSelection(@OnSetSelection);
  GlobalDesignHook.AddHandlerComponentRenamed(@OnComponentRenamed);

  FStarted := TFPList.Create;
  FDone := TFPList.Create;
  FSelection := TFPList.Create;

  //smart designer helper
  InitSmartDesignerHelpers;

end;

destructor TAndroidWidgetMediator.Destroy;
begin

  if Assigned(AndroidForm) then
    AndroidForm.Designer := nil;

  FSelection.Free;
  FStarted.Free;
  FDone.Free;

  if GlobalDesignHook <> nil then
    GlobalDesignHook.RemoveAllHandlersForObject(Self);

  inherited Destroy;
end;

procedure TAndroidWidgetMediator.OnDesignerModified(Sender: TObject{$If lcl_fullversion>1060004}; {%H-}PropName: ShortString{$ENDIF});
var
  Instance: TPersistent;
  InvalidateNeeded: Boolean;
  i: Integer;
begin
  if not (Sender is TPropertyEditor) or (LCLForm = nil) then Exit;
  InvalidateNeeded := False;
  for i := 0 to TPropertyEditor(Sender).PropCount - 1 do
  begin
    Instance := TPropertyEditor(Sender).GetComponent(i);
    if (Instance = AndroidForm) or (Instance is jVisualControl)
    and (jVisualControl(Instance).Owner = AndroidForm) then
    begin
      InvalidateNeeded := True;
      Break;
    end;
  end;
  if InvalidateNeeded then
    LCLForm.Invalidate;

end;

//smart designer helper
function TAndroidWidgetMediator.IsStartModule(uName: string): boolean;
var
  list: TStringList;
begin

  Result:= False;

  list:= TStringList.Create;
  if FileExists(FPathToAndroidProject+DirectorySeparator+'jni'+DirectorySeparator+uName+'.lfm') then
  begin

    list.LoadFromFile(FPathToAndroidProject+DirectorySeparator+'jni'+DirectorySeparator+uName+'.lfm');
    if Pos(GetStartModuleMode(), list.Text) > 0 then
    begin
      Result:= True;
    end;

  end;

  list.Free;
end;

procedure TAndroidWidgetMediator.OnComponentRenamed(AComponent: TComponent);
begin
   if AComponent is jForm then
   begin
      if IsStartModule( (AComponent as jForm).UnitName ) then
      begin
         FStartModuleVarName:= (AComponent as jForm).Name;
         FStartModuleTypeName:= (AComponent as jForm).ClassName;
         UpdateProjectLPR;   //force update .lpr
      end;
   end;
end;

procedure TAndroidWidgetMediator.OnPersistentAdded(APersistent: TPersistent; {%H-}Select: boolean);
var
  auxClassName: string;
  added, nativeExists: boolean;

begin
  if (APersistent is jVisualControl)
  and (jVisualControl(APersistent).Parent = nil)
  and (jVisualControl(APersistent).Owner = AndroidForm)
  then
    if Assigned(FLastSelectedContainer) then
      jVisualControl(APersistent).Parent := FLastSelectedContainer
    else
      jVisualControl(APersistent).Parent := AndroidForm;

  //smart designer helpers
  added:= False;
  nativeExists:= False;

  auxClassName:= APersistent.ClassName;
  if FileExists(FPathToJavaTemplates+DirectorySeparator+'lamwdesigner'+DirectorySeparator+auxClassName+'.java') then
  begin
     if not FileExists(FPathToJavaSource+DirectorySeparator+auxClassName+'.java') then
        added:= TryAddJControl(auxClassName, nativeExists);

     if added then
        if nativeExists then UpdateProjectLPR;
  end;

end;

procedure TAndroidWidgetMediator.OnSetSelection(const ASelection: TPersistentSelectionList);
var
  i: Integer;
begin

  FLastSelectedContainer := nil;
  if (ASelection.Count = 1) and (ASelection[0] is jVisualControl) then
    with jVisualControl(ASelection[0]) do
      if (Owner = AndroidForm) and AcceptChildrenAtDesignTime then
        FLastSelectedContainer := jVisualControl(ASelection[0]);

  FSelection.Clear;
  for i := 0 to ASelection.Count - 1 do
    FSelection.Add(ASelection[i]);

  //smart deginer helper
  if ASelection <> nil then
  begin
    if ASelection.Count > 0 then
    begin
      FSelectedJControlClassName:= '';
      if (ASelection[0] is jControl) then
      begin
        FSelectedJControlClassName:= (ASelection[0] as jControl).ClassName;
      end;
    end;
  end;

end;

function TAndroidWidgetMediator.GetAndroidForm: jForm;
begin
  Result := jForm(Root);
end;

procedure TAndroidWidgetMediator.InitSmartDesignerHelpers;
var
  list, auxList, jcontrolsList: TStringList;
  j, p1: integer;
  aux, dlgMessage: string;
  doUpdateLPR, nativeExists: boolean;
begin

  //it is not necessary repeat "InitSmartDesignerHelpers" tasks for each form...
  if LazarusIDE.ActiveProject.Tag <> 0  then Exit;

  LazarusIDE.ActiveProject.Tag:= 1010;  //break "InitSmartDesignerHelpers" repetition...

  doUpdateLPR:= False;

  p1:= Pos(DirectorySeparator+'jni'+DirectorySeparator, LazarusIDE.ActiveProject.ProjectInfoFile);
  if p1 > 0 then
    FPathToAndroidProject:= Trim(Copy(LazarusIDE.ActiveProject.ProjectInfoFile, 1, p1-1))
  else
  begin
    FPathToAndroidProject:= ExtractFilePath(LazarusIDE.ActiveProject.ProjectInfoFile);
    FPathToAndroidProject:= Copy(FPathToAndroidProject,1, Length(FPathToAndroidProject)-1);
  end;

  FPackageName:= LazarusIDE.ActiveProject.CustomData.Values['Package'];
  if FPackageName = '' then
  begin
    FPackageName:= GetPackageNameFromAndroidManifest(FPathToAndroidProject);
    if FPackageName = '' then
    begin
       ShowMessage('Warning: "AndroidManifest.xml" not Found!');
       Exit;
    end;

     //try add custom
     LazarusIDE.ActiveProject.CustomData.Values['Package']:= FPackageName;
  end;

  aux:= FPackageName;
  FPathToJavaSource:= FPathToAndroidProject + DirectorySeparator+ 'src' + DirectorySeparator + ReplaceChar(aux, '.', DirectorySeparator);
  ForceDirectory(FPathToJavaSource);

  auxList:=  TStringList.Create;
  list:= TStringList.Create;

  if FileExists(LazarusIDE.GetPrimaryConfigPath+DirectorySeparator+'JNIAndroidProject.ini') then
  begin
    list.LoadFromFile(LazarusIDE.GetPrimaryConfigPath+DirectorySeparator+'JNIAndroidProject.ini');
    FPathToJavaTemplates:= Trim(list.Values['PathToJavaTemplates']);

    //will be used to try update/change project NDK/SDK paths [demos,  etc...]
    FNDKIndex:=  Trim(list.Values['NDK']);
    FPathToAndroidNDK:= Trim(list.Values['PathToAndroidNDK']);
    FPathToAndroidSDK:= Trim(list.Values['PathToAndroidSDK']);
  end;

  ForceDirectory(FPathToJavaSource+DirectorySeparator+'bak');
  if not DirectoryExists(FPathToAndroidProject+DirectorySeparator+'lamwdesigner') then
  begin

    dlgMessage:= 'Hello!'+sLineBreak+sLineBreak+'We need to do an important change/update in your project.'+sLineBreak+sLineBreak+
                 'Don''t worry.'+sLineBreak+sLineBreak+'The project''s backup files will be saved as *.bak.OLD'+sLineBreak+sLineBreak+
                 'Please, whenever a dialog prompt select "Reload from disk" ';

    case QuestionDlg ('\o/ \o/ \o/    Welcome to LAMW version 0.7!',dlgMessage,mtCustom,[mrYes,'OK'],'') of
        mrYes:
        begin
          CopyFile(FPathToJavaSource+DirectorySeparator+'Controls.java',
                   FPathToJavaSource+DirectorySeparator+'bak'+DirectorySeparator+'Controls.java.bak.OLD');

          CopyFile(FPathToJavaSource+DirectorySeparator+'App.java',
                   FPathToJavaSource+DirectorySeparator+'bak'+DirectorySeparator+'App.java.bak.OLD');

          CopyFile(FPathToAndroidProject+DirectorySeparator+'jni'+DirectorySeparator+'controls.lpr',
                   FPathToAndroidProject+DirectorySeparator+'jni'+DirectorySeparator+'controls.lpr.bak.OLD');
        end;
    end;
    ForceDirectory(FPathToAndroidProject+DirectorySeparator+'lamwdesigner');
    doUpdateLPR:= True;  //force cleanup old [fat]  *.lpr !!
  end;

  CleanupAllJControlsSource();  //force cleanup all java code

  SetStartModuleTypeNameAndVarName(); //need to update/change .lpr

  //update all java code ...
  if FileExists(FPathToJavaTemplates+DirectorySeparator+'App.java') then
  begin
    auxList.LoadFromFile(FPathToJavaTemplates+DirectorySeparator+'App.java');
    auxList.Strings[0]:= 'package '+FPackageName+';';
    auxList.SaveToFile(FPathToJavaSource+DirectorySeparator+'App.java');
  end;

  if FileExists(FPathToJavaTemplates+DirectorySeparator+'Controls.java') then
  begin
    auxList.LoadFromFile(FPathToJavaTemplates+DirectorySeparator+'Controls.java');
    auxList.Strings[0]:= 'package '+FPackageName+';';
    auxList.SaveToFile(FPathToJavaSource+DirectorySeparator+'Controls.java');
  end;

  if FileExists(FPathToJavaTemplates + DirectorySeparator + 'Controls.native') then
  begin
     CopyFile(FPathToJavaTemplates + DirectorySeparator + 'Controls.native',
              FPathToAndroidProject+ DirectorySeparator+'lamwdesigner'+DirectorySeparator+ 'Controls.native');

     doUpdateLPR:= True;  //force .lpr update  !!
  end;

  jcontrolsList:= TStringList.Create;
  GetAllJControlsFromForms(jcontrolsList);

  //re-add all [updated] java code ...
  for j:= 0 to jcontrolsList.Count - 1 do
  begin
    if FileExists(FPathToJavaTemplates+DirectorySeparator+'lamwdesigner'+DirectorySeparator+jcontrolsList.Strings[j]+'.java') then
    begin
       if not FileExists(FPathToJavaSource+DirectorySeparator+jcontrolsList.Strings[j]+'.java') then
       begin
          TryAddJControl(jcontrolsList.Strings[j], nativeExists);
       end;
    end;
  end;

  if Pos('TFPNoGUIGraphicsBridge', jcontrolsList.Text) > 0 then   //handle lib freetype need by TFPNoGUIGraphicsBridge
  begin
    auxList.LoadFromFile(FPathToJavaSource+DirectorySeparator+'Controls.java');
    aux:=  StringReplace(auxList.Text, '/*--nogui--' , '/*--nogui--*/' , [rfReplaceAll,rfIgnoreCase]);
    aux:=  StringReplace(aux, '--graphics--*/' , '/*--graphics--*/' , [rfReplaceAll,rfIgnoreCase]);
    auxList.Text:= aux;
    auxList.SaveToFile(FPathToJavaSource+DirectorySeparator+'Controls.java');
  end;

  list.Free;
  jcontrolsList.Free;
  auxList.Free;

  // try fix/repair project paths [demos, etc..]
  if IsDemoProject() then
  begin
    TryChangeDemoProjecPaths();
  end
  else
  begin  // add/update custom
    LazarusIDE.ActiveProject.CustomData.Values['NdkPath']:= FPathToAndroidNDK;
    LazarusIDE.ActiveProject.CustomData.Values['SdkPath']:= FPathToAndroidSDK
  end;

  if doUpdateLPR then UpdateProjectLPR;

end;

function GetPathToSDKFromBuildXML(fullPathToBuildXML: string): string;
var
  i, pk: integer;
  strAux: string;
  packList: TStringList;
begin
  Result:= '';
  if FileExists(fullPathToBuildXML) then
  begin
    packList:= TStringList.Create;
    packList.LoadFromFile(fullPathToBuildXML);
    pk:= Pos('location="',packList.Text);  //ex. location="C:\adt32\sdk"
    strAux:= Copy(packList.Text, pk+Length('location="'), 300 {dummy});
    i:= 2; //scape first "
    while strAux[i]<>'"' do
    begin
      i:= i+1;
    end;
    Result:= Trim(Copy(strAux, 1, i-1));
    packList.Free;
  end;
end;

procedure TAndroidWidgetMediator.TryChangeDemoProjecPaths();
var
  strList: TStringList;
  strResult: string;
  lpiFileName: string;
  strLibraries: string;
  strCustom: string;
  pathToDemoNDK: string;
  pathToDemoSDK: string;
begin

  strList:= TStringList.Create;

  if FPathToAndroidSDK <> '' then
  begin
    if FileExists(FPathToAndroidProject + DirectorySeparator+'build.xml') then
    begin

      pathToDemoSDK:= GetPathToSDKFromBuildXML(FPathToAndroidProject + DirectorySeparator+'build.xml');
      if pathToDemoSDK <> '' then
      begin
        strList.LoadFromFile(FPathToAndroidProject + DirectorySeparator+'build.xml');
        strList.SaveToFile(FPathToAndroidProject+ DirectorySeparator+'build.xml.bak2');
        strResult:=  StringReplace(strList.Text, pathToDemoSDK, FPathToAndroidSDK , [rfReplaceAll,rfIgnoreCase]);
        strList.Text:= strResult;
        strList.SaveToFile(FPathToAndroidProject + DirectorySeparator+'build.xml');
      end;

    end;
  end else
    ShowMessage('Sorry.. Project "build.xml" Path  to SDK not fixed... [Please, change it by hand!]');

  lpiFileName:= LazarusIDE.ActiveProject.ProjectInfoFile; //full path to 'controls.lpi';
  strList.LoadFromFile(lpiFileName);
  strList.SaveToFile(lpiFileName+'.bak2');

  strList:= TStringList.Create;

  pathToDemoNDK:= LazarusIDE.ActiveProject.CustomData.Values['NdkPath'];
  if (pathToDemoNDK <> '') and (FPathToAndroidNDK <> '') then
  begin
      strLibraries:= LazarusIDE.ActiveProject.LazCompilerOptions.Libraries;
      strResult:= StringReplace(strLibraries, pathToDemoNDK, FPathToAndroidNDK, [rfReplaceAll,rfIgnoreCase]);
      if (FNDKIndex = '3') or  (FNDKIndex = '4') then
      begin
        strResult:= StringReplace(strResult, '4.6', '4.9', [rfReplaceAll,rfIgnoreCase]);
      end;
      LazarusIDE.ActiveProject.LazCompilerOptions.Libraries:= strResult;

      strCustom:= LazarusIDE.ActiveProject.LazCompilerOptions.CustomOptions;
      strResult:= StringReplace(strCustom, pathToDemoNDK, FPathToAndroidNDK, [rfReplaceAll,rfIgnoreCase]);
      if (FNDKIndex = '3') or  (FNDKIndex = '4') then
      begin
        strResult:= StringReplace(strResult, '4.6', '4.9', [rfReplaceAll,rfIgnoreCase]);
      end;
      LazarusIDE.ActiveProject.LazCompilerOptions.CustomOptions:= strResult;

      //  add/update  custom ...
      LazarusIDE.ActiveProject.CustomData.Values['NdkPath']:= FPathToAndroidNDK;
      LazarusIDE.ActiveProject.CustomData.Values['SdkPath']:= FPathToAndroidSDK;

  end else
    ShowMessage('Sorry.. path to NDK not fixed ... [Please, change it by hand!]');

  strList.Free;
end;

procedure TAndroidWidgetMediator.TryFindDemoPathsFromReadme(out pathToDemoNDK: string;
                                              out pathToDemoSDK: string);
var
  strList: TStringList;
  aux: string;
  p: integer;
  p2: integer;
begin

  strList:= TStringList.Create;
  if FileExists(FPathToAndroidProject + DirectorySeparator+'readme.txt') then
  begin
    strList.LoadFromFile(FPathToAndroidProject + DirectorySeparator+'readme.txt');

    p := Pos('System Path to Android SDK=', strList.Text);
    p := p+length('System Path to Android SDK=');

    p2 := Pos('System Path to Android NDK=', strList.Text);
    pathToDemoSDK := Trim(copy(strList.Text,p,p2-p));

    p := Pos('System Path to Android NDK=', strList.Text);
    p := p+length('System Path to Android NDK=');

    pathToDemoNDK := Trim(copy(strList.Text,p,strList.Count));
  end;

  strList.Free;
end;

function TAndroidWidgetMediator.IsDemoProject(): boolean;
var
  pathToDemoNDK: string;
  pathToDemoSDK: string;
begin

  Result := False;

  pathToDemoNDK:= LazarusIDE.ActiveProject.CustomData.Values['NdkPath'];
  pathToDemoSDK:= LazarusIDE.ActiveProject.CustomData.Values['SdkPath'];

  if (pathToDemoNDK = '') and (pathToDemoSDK = '') then
  begin

    TryFindDemoPathsFromReadme(pathToDemoNDK, pathToDemoSDK);  // try "readme.txt"

    if (pathToDemoNDK = '') and (pathToDemoSDK = '') then Exit;

    //create custom data
    LazarusIDE.ActiveProject.CustomData.Values['NdkPath']:= pathToDemoNDK;
    LazarusIDE.ActiveProject.CustomData.Values['SdkPath']:= pathToDemoSDK

  end;

  if (pathToDemoNDK = FPathToAndroidNDK) and (pathToDemoSDK = FPathToAndroidSDK) then Exit;

  Result:= True;
end;

procedure TAndroidWidgetMediator.SetStartModuleTypeNameAndVarName();
var
  list, contentList: TStringList;
  i: integer;
  aux: string;
begin
  contentList := FindAllFiles(FPathToAndroidProject+DirectorySeparator+'jni', '*.lfm', False);
  if contentList.Count = 0 then
  begin
    //new project created ... no file yet;
    FStartModuleVarName:= 'AndroidModule1';    //default
    FStartModuleTypeName:= 'TAndroidModule1';  //default
    contentList.Free;
    Exit;
  end;

  list:= TStringList.Create;

  FStartModuleVarName:= ''; //reset...
  FStartModuleTypeName:= ''; //reset...
  for i:= 0 to contentList.Count-1 do
  begin
    list.LoadFromFile(contentList.Strings[i]);

    if Pos('= actSplash', list.Text) > 0  then  //there is a SplashActivity
    begin
      aux:= list.Strings[0]; //format:  "object AndroidModule1: TAndroidModule1"
      FStartModuleVarName:= SplitStr(aux, ':');  //object AndroidModule1
      FStartModuleTypeName:= Trim(aux);   //TAndroidModule1
      SplitStr(FStartModuleVarName, ' ');  //AndroidModule1
    end;

    if (FStartModuleVarName='') and (FStartModuleTypeName='') then
    begin
      if Pos('= actMain', list.Text) > 0  then  //isMainActvity
      begin
         aux:= list.Strings[0]; //format:  "object AndroidModule1: TAndroidModule1"
         FStartModuleVarName:= SplitStr(aux, ':');  //object AndroidModule1
         FStartModuleTypeName:= Trim(aux);   //TAndroidModule1
         SplitStr(FStartModuleVarName, ' ');  //AndroidModule1
      end
    end;
  end;

  list.Free;
  contentList.Free;
end;

function TAndroidWidgetMediator.GetStartModuleMode(): string;
var
  list, contentList: TStringList;
  i: integer;
begin
  Result:= 'actMain';  //default

  contentList := FindAllFiles(FPathToAndroidProject+DirectorySeparator+'jni', '*.lfm', False);
  if contentList.Count = 0 then
  begin
    contentList.Free;
    Exit;
  end;

  list:= TStringList.Create;
  for i:= 0 to contentList.Count-1 do
  begin
    list.LoadFromFile(contentList.Strings[i]);

    if Pos('= actSplash', list.Text) > 0  then  //start module is a "Splash" Activity
    begin
      Result:= '= actSplash';
      Break;
    end;

    if Pos('= actMain', list.Text) > 0  then  //start module is a "Main" Actvity
       Result:= '= actMain';

  end;
  list.Free;
  contentList.Free;
end;

procedure TAndroidWidgetMediator.GetAllJControlsFromForms(const jcontrolsList: TStrings);
var
  list, contentList: TStringList;
  i, j, p1: integer;
  aux: string;
begin
  //No need to create the stringlist...
  if jcontrolsList <> nil then
  begin
    list:= TStringList.Create;
    contentList := FindAllFiles(FPathToAndroidProject+DirectorySeparator+'jni', '*.lfm', False);
    for i:= 0 to contentList.Count-1 do
    begin
      list.LoadFromFile(contentList.Strings[i]);
      for j:= 1 to list.Count - 1 do  // "1" --> skip form
      begin
        aux:= list.Strings[j];
        if Pos('object ', aux) > 0 then  //object jTextView1: jTextView
        begin
           p1:= Pos(':', aux);
           aux:=  Copy(aux, p1+1, Length(aux));
           jcontrolsList.Add(Trim(aux));
        end;
      end;
    end;
    list.Free;
    contentList.Free;
  end;

end;

procedure TAndroidWidgetMediator.CleanupAllJControlsSource();
var
   contentList: TStringList;
   i: integer;
begin

   //No need to create the stringlist...
   contentList := FindAllFiles(FPathToJavaSource, '*.java', False);
   for i:= 0 to contentList.Count-1 do
   begin         //do backup
      CopyFile(contentList.Strings[i],
            FPathToJavaSource+DirectorySeparator+'bak'+DirectorySeparator+ExtractFileName(contentList.Strings[i])+'.bak');

      DeleteFile(contentList.Strings[i]);
   end;
   contentList.Free;

   ForceDirectory(FPathToAndroidProject+DirectorySeparator+'lamwdesigner'+DirectorySeparator+'bak');
   contentList := FindAllFiles(FPathToAndroidProject+ DirectorySeparator+'lamwdesigner', '*.native', False);
   for i:= 0 to contentList.Count-1 do
   begin     //do backup
     CopyFile(contentList.Strings[i],
           FPathToAndroidProject+ DirectorySeparator+'lamwdesigner'+DirectorySeparator+'bak'+DirectorySeparator+ExtractFileName(contentList.Strings[i])+'.bak');

     DeleteFile(contentList.Strings[i]);
   end;
   contentList.Free;

end;

function TAndroidWidgetMediator.GetEventSignature(nativeMethod: string): string;
var
  method: string;
  signature: string;
  params, paramName: string;
  i, d, p, p1, p2: integer;
  listParam: TStringList;
begin

  listParam:= TStringList.Create;
  method:= nativeMethod;

  p:= Pos('native', method);
  method:= Copy(method, p+Length('native'), Length(method));
  p1:= Pos('(', method);
  p2:= Pos(')', method);
  d:=(p2-p1);

  params:= Copy(method, p1+1, d-1); //long pasobj, long elapsedTimeMillis
  method:= Copy(method, 1, p1-1);
  method:= Trim(method); //void pOnChronometerTick
  SplitStr(method,' ');
  method:=  Trim(method); //pOnChronometerTick

  signature:= '(PEnv,this';  //no param...

  if  Length(params) > 3 then
  begin
    listParam.Delimiter:= ',';
    listParam.StrictDelimiter:= True;
    listParam.DelimitedText:= params;

    for i:= 0 to listParam.Count-1 do
    begin
       paramName:= Trim(listParam.Strings[i]); //long pasobj
       SplitStr(paramName,' ');
       listParam.Strings[i]:= Trim(paramName);
    end;

    for i:= 0 to listParam.Count-1 do
    begin
      if Pos('pasobj', listParam.Strings[i]) > 0 then
         signature:= signature + ',TObject(' + listParam.Strings[i]+')'
      else
        signature:= signature + ',' + listParam.Strings[i];
    end;
  end;

  Result:= method+'=Java_Event_'+method+signature+');';

  if Pos('pAppOnCreate=', Result) > 0 then
  begin
    if FStartModuleVarName <> '' then
      Result:= Result+Trim(FStartModuleVarName)+'.Init(gApp);'
    else
      Result:= Result+'AndroidModule1.Init(gApp);'
  end;

  listParam.Free;
end;

procedure TAndroidWidgetMediator.UpdateProjectLPR;
var
   tempList, importList, javaClassList, nativeMethodList,  SynMemo1, SynMemo2: TStringList;
   i, k: integer;
begin

  if FPackageName = '' then Exit;

  nativeMethodList:= TStringList.Create;
  tempList:= TStringList.Create;
  SynMemo1:= TStringList.Create;
  SynMemo2:= TStringList.Create;
  importList:= TStringList.Create;

  javaClassList := FindAllFiles(FPathToAndroidProject+DirectorySeparator+'lamwdesigner', '*.native', False);

  for k:= 0 to javaClassList.Count - 1 do
  begin
    tempList.LoadFromFile(javaClassList.Strings[k]);
    for i:= 0 to  tempList.Count - 1 do
    begin
      nativeMethodList.Add(Trim(tempList.Strings[i]));
    end;
  end;
  javaClassList.Free;

  javaClassList := FindAllFiles(FPathToJavaSource, '*.java', False);
  for k:= 0 to javaClassList.Count - 1 do
  begin
    tempList.LoadFromFile(javaClassList.Strings[k]);
    for i:= 0 to tempList.Count - 1 do
    begin
       if Pos('import ', tempList.Strings[i]) > 0 then
       begin
         importList.Add(Trim(tempList.Strings[i]));
       end;
    end;
  end;

  tempList.Clear;
  for i:= 0 to nativeMethodList.Count-1 do
  begin
    tempList.Add(GetEventSignature(nativeMethodList.Strings[i]));
  end;

  tempList.SaveToFile(FPathToAndroidProject+DirectorySeparator+'lamwdesigner'+DirectorySeparator+'ControlsEvents.txt');

  tempList.Clear;
  tempList.Add('package '+ FPackageName+';');
  tempList.Add(' ');
  tempList.Add(importList.Text);
  tempList.Add('public class Controls {');
  tempList.Add(' ');
  tempList.Add(nativeMethodList.Text);
  tempList.Add('}');
  tempList.SaveToFile(FPathToAndroidProject+DirectorySeparator+'lamwdesigner'+DirectorySeparator+'Controls.dummy');

  //upgrade [library] controls.lpr
  SynMemo1.Clear;
  SynMemo2.Clear;
  if FileExists(FPathToAndroidProject+PathDelim+'jni'+PathDelim+'controls.lpr') then
  begin
    // from old "controls.lpr"
    SynMemo1.LoadFromFile(FPathToAndroidProject+PathDelim+'jni'+PathDelim+'controls.lpr');
    i := 0;
    while i < SynMemo1.Count do
    begin
      if Copy(Trim(SynMemo1[i]) + ' ', 1, 5) = 'uses ' then
      begin
        repeat
          SynMemo2.Add(SynMemo1[i]);
          Inc(i);
        until (i >= SynMemo1.Count) or (Pos(';', SynMemo1[i - 1]) > 0);
        SynMemo2.Add('');
        Break;
      end else
        SynMemo2.Add(SynMemo1[i]);
      Inc(i);
    end;
  end else begin
    SynMemo2.Add('{hint: save all files to location: '+FPathToAndroidProject+DirectorySeparator+'jni}');
    SynMemo2.Add('library controls;  //by Lamw: Lazarus Android Module Wizard: '+DateTimeToStr(Now)+']');
    SynMemo2.Add(' ');
    SynMemo2.Add('{$mode delphi}');
    SynMemo2.Add(' ');
    SynMemo2.Add('uses');
    SynMemo2.Add('  Classes, SysUtils, And_jni, And_jni_Bridge, AndroidWidget, Laz_And_Controls,');
    SynMemo2.Add('  Laz_And_Controls_Events, unit1;');
    SynMemo2.Add(' ');
  end;

  if nativeMethodList.Count > 0 then
  begin
    with TJavaParser.Create(FPathToAndroidProject+DirectorySeparator+'lamwdesigner'+DirectorySeparator+'Controls.dummy') do
    try
      SynMemo2.Add(GetPascalJNIInterfaceCode(FPathToAndroidProject+DirectorySeparator+'lamwdesigner'+DirectorySeparator+'ControlsEvents.txt'));
    finally
      Free
    end;
  end;

  // TODO: should be taken from old "controls.lpr" (SynMemo1)
  SynMemo2.Add('begin');
  SynMemo2.Add('  gApp:= jApp.Create(nil);{AndroidWidget.pas}');
  SynMemo2.Add('  gApp.Title:= ''My Android Bridges Library'';');
  SynMemo2.Add('  gjAppName:= '''+FPackageName+''';{AndroidWidget.pas}');
  SynMemo2.Add('  gjClassName:= '''+ReplaceChar(FPackageName, '.','/')+'/Controls'';{AndroidWidget.pas}');
  SynMemo2.Add('  gApp.AppName:=gjAppName;');
  SynMemo2.Add('  gApp.ClassName:=gjClassName;');
  SynMemo2.Add('  gApp.Initialize;');
  SynMemo2.Add('  gApp.CreateForm('+FStartModuleTypeName+', '+FStartModuleVarName+');');
  SynMemo2.Add('end.');

  if FileExists(FPathToAndroidProject+DirectorySeparator+'jni'+DirectorySeparator+'controls.lpr') then
  begin
    CopyFile(FPathToAndroidProject+DirectorySeparator+'jni'+DirectorySeparator+'controls.lpr',
       FPathToAndroidProject+DirectorySeparator+'jni'+DirectorySeparator+'controls.lpr.bak');
  end;

  SynMemo2.SaveToFile(FPathToAndroidProject+DirectorySeparator+'jni'+DirectorySeparator+'controls.lpr');

  importList.Free;
  nativeMethodList.Free;
  tempList.Free;
  SynMemo1.Free;
  SynMemo2.Free;
  javaClassList.Free;

  //[clenup ?????]
  //DeleteFile(FPathToAndroidProject+DirectorySeparator+'lamwdesigner'+DirectorySeparator+'Controls.dummy');
  //DeleteFile(FPathToAndroidProject+DirectorySeparator+'lamwdesigner'+DirectorySeparator+'ControlsEvents.txt');


end;

//smart designer helper
function TAndroidWidgetMediator.TryRemoveJControl(jclassname: string; out nativeRemoved: boolean): boolean;
var
  list, auxList, listRequirements, manifestList, allFormsControlsList: TStringList;
  i, j, count: integer;
  aux: string;
  flagFoundRequirement: boolean;
begin

  Result:= False;
  nativeRemoved:= False;

  allFormsControlsList:= TStringList.Create;
  GetAllJControlsFromForms(allFormsControlsList);

  i:= allFormsControlsList.IndexOf(jclassname);

  if i >= 0 then
  begin
    allFormsControlsList.Delete(i); //delete one ocorrence of the java class ...
  end;

  if allFormsControlsList.IndexOf(jclassname) >= 0 then
  begin
    allFormsControlsList.Free;
    Exit;  //stop removing java stuff... still exists others component of the same java class..
  end;

  list:= TStringList.Create;
  manifestList:= TStringList.Create;
  listRequirements:= TStringList.Create;
  auxList:= TStringList.Create;

  if FileExists(FPathToJavaSource+DirectorySeparator+jclassname+'.java') then
  begin
    DeleteFile(FPathToJavaSource+DirectorySeparator+jclassname+'.java');
    if FileExists(FPathToJavaTemplates+DirectorySeparator+'lamwdesigner'+DirectorySeparator +jclassname+'.create') then
    begin
      auxlist.LoadFromFile(FPathToJavaTemplates+DirectorySeparator+'lamwdesigner'+DirectorySeparator +jclassname+'.create');

      if FileExists(FPathToAndroidProject+DirectorySeparator+'lamwdesigner'+DirectorySeparator+jclassname+'.native') then
      begin
        list.LoadFromFile(FPathToAndroidProject+DirectorySeparator+'lamwdesigner'+DirectorySeparator+jclassname+'.native');
        for i:= 0 to list.Count-1 do
             auxlist.Add(list.Strings[i]);
        //warning: do not delete ".native" here!
      end;
      count:= auxlist.Count; //count inserted lines
      aux:= auxList.Strings[0]; //insert reference
      list.LoadFromFile(FPathToJavaSource+DirectorySeparator+'Controls.java');
      for i:= list.Count-1 downto 0 do
      begin
        if list.Strings[i] = aux then //insert reference
        begin
          for j:= 0 to count do list.Delete(i);  //delete count+1 lines
          list.SaveToFile(FPathToJavaSource+DirectorySeparator+'Controls.java');
          Break;
        end;
      end;
    end;
  end;

  //try delete all reference added by the component in AndroidManifest ...
  if FileExists(FPathToAndroidProject+DirectorySeparator+'lamwdesigner'+DirectorySeparator+jclassname+'.required') then
  begin
    listRequirements.LoadFromFile(FPathToAndroidProject+DirectorySeparator+'lamwdesigner'+DirectorySeparator+jclassname+'.required');
    manifestList.LoadFromFile(FPathToAndroidProject+DirectorySeparator+'AndroidManifest.xml');
    aux:= manifestList.Text;

    for i:=0 to listRequirements.Count-1 do
    begin
      if Pos(Trim(listRequirements.Strings[i]), aux) > 0 then
      begin
        flagFoundRequirement:= False;
        for j:= 0 to allFormsControlsList.Count-1 do
        begin
           if allFormsControlsList.Strings[j] <> jclassname then
           begin
              if FileExists(FPathToAndroidProject+DirectorySeparator+'lamwdesigner'+DirectorySeparator+allFormsControlsList.Strings[j]+'.required') then
              begin
                auxlist.LoadFromFile(FPathToAndroidProject+DirectorySeparator+'lamwdesigner'+DirectorySeparator+allFormsControlsList.Strings[j]+'.required');
                if auxlist.Count > 0 then
                begin
                  if Pos(Trim(listRequirements.Strings[i]), auxlist.Text) > 0 then
                  begin
                    flagFoundRequirement:= True; //Requirement can NOT be deleted...
                    Break;
                  end;
                end;
              end;
           end;
        end;
        if not flagFoundRequirement then //Requirement can be deleted ..
           aux:= StringReplace(aux,sLineBreak+Trim(listRequirements.Strings[i]),'',[rfIgnoreCase]);
      end;
    end;
    manifestList.Text:= aux;
    manifestList.SaveToFile(FPathToAndroidProject+DirectorySeparator+'AndroidManifest.xml');
    DeleteFile(FPathToAndroidProject+DirectorySeparator+'lamwdesigner'+DirectorySeparator+jclassname+'.required');
  end;

  if FileExists(FPathToAndroidProject+DirectorySeparator+'lamwdesigner'+DirectorySeparator+jclassname+'.native') then
  begin
    DeleteFile(FPathToAndroidProject+DirectorySeparator+'lamwdesigner'+DirectorySeparator+jclassname+'.native');
    nativeRemoved:= True;
  end;

  manifestList.Free;
  listRequirements.Free;
  list.Free;
  auxList.Free;
  allFormsControlsList.Free;

  Result:= True;

end;

//experimental....
function TAndroidWidgetMediator.TryAddJControl(jclassname: string;  out nativeAdded: boolean): boolean;
var
   list, listRequirements, auxList, manifestList: TStringList;
   p1, p2, i: integer;
   aux: string;
   insertRef: string;
   c: char;
begin
   nativeAdded:= False;
   Result:= False;

   if FPackageName = '' then Exit;

   if FileExists(FPathToJavaSource+DirectorySeparator+jclassname+'.java') then
     Exit; //do not duplicated!

   list:= TStringList.Create;
   manifestList:= TStringList.Create;
   listRequirements:= TStringList.Create;  //android maninfest Requirements
   auxList:= TStringList.Create;

   //try insert "jControl.java" in java project source
   if FileExists(FPathToJavaTemplates+DirectorySeparator+'lamwdesigner'+DirectorySeparator +jclassname+'.java') then
   begin
     list.LoadFromFile(FPathToJavaTemplates+DirectorySeparator+'lamwdesigner'+DirectorySeparator +jclassname+'.java');
     list.Strings[0]:= 'package '+FPackageName+';';
     list.SaveToFile(FPathToJavaSource+DirectorySeparator+jclassname+'.java');
     Result:= True;
   end;

   if FileExists(FPathToJavaTemplates+DirectorySeparator+'lamwdesigner'+DirectorySeparator+jclassname+'.native') then
   begin
       CopyFile(FPathToJavaTemplates+DirectorySeparator+'lamwdesigner'+DirectorySeparator+jclassname+'.native',
                FPathToAndroidProject+DirectorySeparator+'lamwdesigner'+DirectorySeparator+jclassname+'.native');
        nativeAdded:= True;
   end;

   //try insert "jControl.create" constructor in "Controls.java"
   if FileExists(FPathToJavaTemplates+DirectorySeparator+'lamwdesigner'+DirectorySeparator +jclassname+'.create') then
   begin
     list.LoadFromFile(FPathToJavaTemplates+DirectorySeparator+'lamwdesigner'+DirectorySeparator +jclassname+'.create');
     if FileExists(FPathToAndroidProject+DirectorySeparator+'lamwdesigner'+DirectorySeparator+jclassname+'.native') then
     begin
       auxList.LoadFromFile(FPathToJavaTemplates+DirectorySeparator+'lamwdesigner'+DirectorySeparator +jclassname+'.native');
       for i:= 0 to auxList.Count-1 do
           list.Add(auxList.Strings[i]);
     end;
     aux:= list.Text;
     list.LoadFromFile(FPathToJavaSource+DirectorySeparator+'Controls.java');
     list.Insert(list.Count-1, aux);
     list.SaveToFile(FPathToJavaSource+DirectorySeparator+'Controls.java');
   end;

   //try insert reference required by the jControl in AndroidManifest ..
   if FileExists(FPathToJavaTemplates+DirectorySeparator+'lamwdesigner'+DirectorySeparator +jclassname+'.permission') then
   begin
     auxList.LoadFromFile(FPathToJavaTemplates+DirectorySeparator+'lamwdesigner'+DirectorySeparator +jclassname+'.permission');
     if auxList.Count > 0 then
     begin
       insertRef:= '<uses-sdk android:minSdkVersion'; //insert reference point
       manifestList.LoadFromFile(FPathToAndroidProject+DirectorySeparator+'AndroidManifest.xml');
       aux:= manifestList.Text;

       listRequirements.Add(Trim(auxList.Text));  //Add permissions
       list.Clear;
       for i:= 0 to auxList.Count-1 do
       begin
         if Pos(Trim(auxList.Strings[i]), aux) <= 0 then list.Add(Trim(auxList.Strings[i])); //not duplicate..
       end;

       if list.Count > 0 then
       begin
         p1:= Pos(insertRef, aux);
         p2:= p1 + Length(insertRef);
         c:= aux[p2];
         while c <> '>' do
         begin
            Inc(p2);
            c:= aux[p2];
         end;
         Inc(p2);
         insertRef:= Trim(Copy(aux, p1, p2-p1));
         p1:= Pos(insertRef, aux);
         if Length(list.Text) >  10 then  //dummy
         begin
           Insert(sLineBreak + Trim(list.Text), aux, p1+Length(insertRef) );
           manifestList.Text:= aux;
           manifestList.SaveToFile(FPathToAndroidProject+DirectorySeparator+'AndroidManifest.xml');
         end;
       end;
     end;
   end;

   if FileExists(FPathToJavaTemplates+DirectorySeparator+'lamwdesigner'+DirectorySeparator +jclassname+'.feature') then
   begin
     auxList.LoadFromFile(FPathToJavaTemplates+DirectorySeparator+'lamwdesigner'+DirectorySeparator +jclassname+'.feature');
     if auxList.Count > 0 then
     begin
       insertRef:= '<uses-sdk android:minSdkVersion'; //insert reference point

       manifestList.LoadFromFile(FPathToAndroidProject+DirectorySeparator+'AndroidManifest.xml');
       aux:= manifestList.Text;

       listRequirements.Add(Trim(auxList.Text));  //Add feature
       list.Clear;
       for i:= 0 to auxList.Count-1 do
       begin
         if Pos(Trim(auxList.Strings[i]), aux) <= 0 then
           list.Add(Trim(auxList.Strings[i])); //do not insert duplicate..
       end;

       if list.Count > 0 then
       begin
         p1:= Pos(insertRef, aux);
         p2:= p1 + Length(insertRef);
         c:= aux[p2];
         while c <> '>' do
         begin
            Inc(p2);
            c:= aux[p2];
         end;
         Inc(p2);
         insertRef:= Trim(Copy(aux, p1, p2-p1));
         p1:= Pos(insertRef, aux);
         if Length(list.Text) > 10 then  //dummy
         begin
           Insert(sLineBreak + Trim(list.Text), aux, p1+Length(insertRef) );
           manifestList.Text:= aux;
           manifestList.SaveToFile(FPathToAndroidProject+DirectorySeparator+'AndroidManifest.xml');
         end;
       end;
     end;
   end;

   if FileExists(FPathToJavaTemplates+DirectorySeparator+'lamwdesigner'+DirectorySeparator +jclassname+'.intentfilter') then
   begin
     auxList.LoadFromFile(FPathToJavaTemplates+DirectorySeparator+'lamwdesigner'+DirectorySeparator +jclassname+'.intentfilter');
     if auxList.Count > 0 then
     begin
       insertRef:= '<intent-filter>'; //insert reference point

       manifestList.LoadFromFile(FPathToAndroidProject+DirectorySeparator+'AndroidManifest.xml');
       aux:= manifestList.Text;

       listRequirements.Add(Trim(auxList.Text));  //Add intentfilters

       list.Clear;
       for i:= 0 to auxList.Count-1 do
       begin
         if Pos(Trim(auxList.Strings[i]), aux) <= 0 then list.Add(Trim(auxList.Strings[i])); //not duplicate..
       end;

       if list.Count > 0 then
       begin
         p1:= Pos(insertRef, aux);
         if Length(list.Text) > 10 then  //dummy
         begin
           Insert(sLineBreak + Trim(list.Text), aux, p1+Length(insertRef) );
           manifestList.Text:= aux;
           manifestList.SaveToFile(FPathToAndroidProject+DirectorySeparator+'AndroidManifest.xml');
         end;
       end;
     end;
   end;

   if FileExists(FPathToJavaTemplates+DirectorySeparator+'lamwdesigner'+DirectorySeparator +jclassname+'.service') then
   begin
     auxList.LoadFromFile(FPathToJavaTemplates+DirectorySeparator+'lamwdesigner'+DirectorySeparator +jclassname+'.service');
     if auxList.Count > 0 then
     begin
       insertRef:= '</activity>'; //insert reference point

       manifestList.LoadFromFile(FPathToAndroidProject+DirectorySeparator+'AndroidManifest.xml');
       aux:= manifestList.Text;

       listRequirements.Add(Trim(auxList.Text));  //Add services

       list.Clear;
       for i:= 0 to auxList.Count-1 do
       begin
         if Pos(Trim(auxList.Strings[i]), aux) <= 0 then list.Add(Trim(auxList.Strings[i])); //not duplicate..
       end;

       if list.Count > 0 then
       begin
         p1:= Pos(insertRef, aux);
         if Length(list.Text) > 10 then //dummy
         begin
           Insert(sLineBreak+Trim(list.Text), aux, p1+Length(insertRef) );
           manifestList.Text:= aux;
           manifestList.SaveToFile(FPathToAndroidProject+DirectorySeparator+'AndroidManifest.xml');
         end;
       end;
     end;
   end;

   if listRequirements.Count > 0 then
     listRequirements.SaveToFile(FPathToAndroidProject+DirectorySeparator+'lamwdesigner'+DirectorySeparator+jclassname+'.required');

   manifestList.Free;
   listRequirements.Free;
   list.Free;
   auxList.Free;

   //if doUpdateLPR then UpdateLPRProject;

end;

class function TAndroidWidgetMediator.CreateMediator(TheOwner, TheForm: TComponent): TDesignerMediator;
var
  Mediator: TAndroidWidgetMediator;
begin
  Result:=inherited CreateMediator(TheOwner,nil);

  Mediator:= TAndroidWidgetMediator(Result);
  Mediator.Root := TheForm;

  Mediator.FDefaultBrushColor := clWhite;
  Mediator.FDefaultPenColor:= clMedGray;
  Mediator.FDefaultFontColor:= clMedGray;
  Mediator.UpdateTheme;

  Mediator.AndroidForm.Designer:= Mediator;
end;

class function TAndroidWidgetMediator.FormClass: TComponentClass;
begin
  Result:=TAndroidForm;
end;

procedure TAndroidWidgetMediator.GetBounds(AComponent: TComponent; out CurBounds: TRect);
var
  w: TAndroidWidget;
begin
  if AComponent is TAndroidWidget then
  begin
    w:=TAndroidWidget(AComponent);
    CurBounds:=Bounds(w.Left,w.Top,w.Width,w.Height);
  end else inherited GetBounds(AComponent,CurBounds);
end;

procedure TAndroidWidgetMediator.InvalidateRect(Sender: TObject; ARect: TRect; Erase: boolean);
begin
  if (LCLForm=nil) or (not LCLForm.HandleAllocated) then exit;
  LCLIntf.InvalidateRect(LCLForm.Handle,@ARect,Erase);
end;

procedure TAndroidWidgetMediator.GetObjInspNodeImageIndex(APersistent: TPersistent; var AIndex: integer);
begin
  if (APersistent is TAndroidWidget) and (TAndroidWidget(APersistent).AcceptChildrenAtDesignTime) then
    AIndex:= FormEditingHook.GetCurrentObjectInspector.ComponentTree.ImgIndexBox
  else if (APersistent is TAndroidWidget) then
    AIndex:= FormEditingHook.GetCurrentObjectInspector.ComponentTree.ImgIndexControl
  else
    inherited GetObjInspNodeImageIndex(APersistent, AIndex);
end;

procedure TAndroidWidgetMediator.SetBounds(AComponent: TComponent; NewBounds: TRect);
begin
  if AComponent is TAndroidWidget then
  begin
    TAndroidWidget(AComponent).SetBounds(NewBounds.Left,NewBounds.Top,
      NewBounds.Right-NewBounds.Left,NewBounds.Bottom-NewBounds.Top);
  end else inherited SetBounds(AComponent,NewBounds);
end;

procedure TAndroidWidgetMediator.GetClientArea(AComponent: TComponent; out
  CurClientArea: TRect; out ScrollOffset: TPoint);
var
  Widget: TAndroidWidget;
begin
  if AComponent is TAndroidWidget then
  begin
    Widget:=TAndroidWidget(AComponent);
    CurClientArea:=Rect(0, 0, Widget.Width, Widget.Height);
    ScrollOffset:=Point(0, 0);
  end
  else inherited GetClientArea(AComponent, CurClientArea, ScrollOffset);
end;


procedure TAndroidWidgetMediator.KeyUp(Sender: TControl; var {%H-}Key: word; {%H-}Shift: TShiftState);
var
  hadNative: boolean;
  removed: boolean;
begin
  //smart desgner helper
  if Key = VK_DELETE then //called before "OnPersistentDeleting"
  begin
    if FSelectedJControlClassName <> '' then
    begin
       removed:= TryRemoveJControl(FSelectedJControlClassName, hadNative);
       if removed then
         if hadNative then UpdateProjectLPR;
    end;
  end;
end;

procedure TAndroidWidgetMediator.InitComponent(AComponent, NewParent: TComponent; NewBounds: TRect);
begin
   if AComponent <> AndroidForm then // to preserve jForm size
   begin
     if AComponent is TAndroidWidget then
       with NewBounds do
         if (Right - Left = 50) and (Bottom - Top = 50) then // ugly check, but IDE makes 50x50 default size for non TControl
         begin
           // restore default size
           Right := Left + TAndroidWidget(AComponent).Width;
           Bottom := Top + TAndroidWidget(AComponent).Height
         end;
     inherited InitComponent(AComponent, NewParent, NewBounds);
     if (AComponent is jVisualControl)
     and Assigned(jVisualControl(AComponent).Parent) then
       with jVisualControl(AComponent) do
       begin
         if not (LayoutParamWidth in [lpWrapContent]) then
           LayoutParamWidth := GetDesignerLayoutByWH(Width, Parent.Width);
         if not (LayoutParamHeight in [lpWrapContent]) then
           LayoutParamHeight := GetDesignerLayoutByWH(Height, Parent.Height);
       end;
   end;
end;

procedure TAndroidWidgetMediator.Paint;

  procedure PaintWidget(AWidget: TAndroidWidget);
  var
    i: Integer;
    Child: TAndroidWidget;
    fpcolor: TFPColor;
    fWidget: TDraftWidget;
    fWidgetClass: TDraftWidgetClass;
  begin

    if FDone.IndexOf(AWidget) >= 0 then Exit;
    if FStarted.IndexOf(AWidget) >= 0 then
    begin
      jVisualControl(AWidget).Anchor := nil;
      MessageBox(0, 'Circular dependency detected!', '[Lamw] Designer', MB_ICONERROR);
      Abort;
    end;
    FStarted.Add(AWidget);

    with LCLForm.Canvas do begin
      //fill background

      Brush.Style:= bsSolid;
      Brush.Color:= Self.FDefaultBrushColor;
      Pen.Color:= Self.FDefaultPenColor;      //MedGray...
      Font.Color:= Self.FDefaultFontColor;

      if AWidget is jVisualControl then
        with jVisualControl(AWidget) do
          if Assigned(Anchor) then
          begin
            RestoreHandleState;
            SaveHandleState;
            MoveWindowOrgEx(Handle, Anchor.Left, Anchor.Top);
            IntersectClipRect(Handle, 0, 0, Anchor.Width, Anchor.Height);
            PaintWidget(Anchor); // needed for update its layout
            RestoreHandleState;
            SaveHandleState;
            MoveWindowOrgEx(Handle, AWidget.Left, AWidget.Top);
          end;

      if (AWidget is jForm) then
      begin
        if jForm(AWidget).BackgroundColor <> colbrDefault then
        begin
          fpcolor:= ToTFPColor(jForm(AWidget).BackgroundColor);
          Brush.Color:= FPColorToTColor(fpcolor);
          Rectangle(0,0,AWidget.Width,AWidget.Height); // outer frame
        end
        else
        begin
          Brush.Color := FDefaultBrushColor;
          GradientFill(Rect(0,0,AWidget.Width,AWidget.Height),
            BlendColors(FDefaultBrushColor, 0.92, 0, 0, 0),
            BlendColors(FDefaultBrushColor, 0.81, 255, 255, 255),
            gdVertical);
        end;
      end else
      if (AWidget is jCustomDialog) then
      begin
        if jCustomDialog(AWidget).BackgroundColor <> colbrDefault then
        begin
          fpcolor:= ToTFPColor(jCustomDialog(AWidget).BackgroundColor);
          Brush.Color:= FPColorToTColor(fpcolor);
        end;
        {
        else
        begin
          Brush.Color:= clNone;
          Brush.Style:= bsClear;
        end;
        }
        Rectangle(0,0,AWidget.Width,AWidget.Height);    // outer frame
        Font.Color:= clMedGray;
        TextOut(6,4,(AWidget as jVisualControl).Text);

      end
      else // generic
      begin
        fWidgetClass := DraftClassesMap.Find(AWidget.ClassType);
        if Assigned(fWidgetClass) then
        begin
          fWidget := fWidgetClass.Create(AWidget, LCLForm.Canvas);
          if not FSizing or (FSelection.IndexOf(AWidget) < 0) then
            fWidget.UpdateLayout;
          fWidget.Draw;
          fWidget.Free;
        end
        //// default drawing: rect with Text
        else if (AWidget is jVisualControl) then
        begin
          Brush.Color:= Self.FDefaultBrushColor;
          FillRect(0,0,AWidget.Width,AWidget.Height);
          Rectangle(0,0,AWidget.Width,AWidget.Height);    // outer frame
          //generic
          Font.Color:= clMedGray;
          TextOut(5,4,AWidget.Text);
        end;
      end;

      if AWidget.AcceptChildrenAtDesignTime then
      begin       //inner rect...
        if (AWidget is jCustomDialog) then
        begin
          Pen.Color:= clSilver; //clWhite;
          Frame(4,4,AWidget.Width-4,AWidget.Height-4); // inner frame
        end
        else
        if not (AWidget is jForm) then
        begin
          Pen.Color:= clSilver;
          Frame(2, 2, AWidget.Width - 2, AWidget.Height - 2); // inner frame
        end;
      end;

      // children
      if AWidget.ChildCount>0 then
      begin
        SaveHandleState;
        // clip client area
        if IntersectClipRect(Handle, 0, 0, AWidget.Width, AWidget.Height)<>NullRegion then
        begin
          for i:=0 to AWidget.ChildCount-1 do
          begin
            SaveHandleState;
            Child:=AWidget.Children[i];
            // clip child area
            MoveWindowOrgEx(Handle,Child.Left,Child.Top);
            if IntersectClipRect(Handle,0,0,Child.Width,Child.Height)<>NullRegion then
               PaintWidget(Child);
            RestoreHandleState;
          end;
        end;
        RestoreHandleState;
      end;
    end;
    FStarted.Remove(AWidget);
    FDone.Add(AWidget);
  end;

begin
  FStarted.Clear;
  FDone.Clear;
  PaintWidget(AndroidForm);
  inherited Paint;
end;

function TAndroidWidgetMediator.ComponentIsIcon(AComponent: TComponent): boolean;
begin
  Result := not (AComponent is TAndroidWidget);
end;

function TAndroidWidgetMediator.ParentAcceptsChild(Parent: TComponent; Child: TComponentClass): boolean;
begin
  Result:=(Parent is TAndroidWidget) and
          (Child.InheritsFrom(TAndroidWidget)) and
          (TAndroidWidget(Parent).AcceptChildrenAtDesignTime);
end;

procedure TAndroidWidgetMediator.UpdateTheme;
begin
  try
    FDefaultBrushColor := GetColorBackgroundByTheme(Root);
  except
    on e: Exception do
      IDEMessagesWindow.AddCustomMessage(mluError, e.Message);
  end;
end;

procedure TAndroidWidgetMediator.MouseDown(Button: TMouseButton;
  Shift: TShiftState; p: TPoint; var Handled: boolean);
begin
  FSizing := True;
  inherited MouseDown(Button, Shift, p, Handled);
end;

procedure TAndroidWidgetMediator.MouseUp(Button: TMouseButton;
  Shift: TShiftState; p: TPoint; var Handled: boolean);
begin
  inherited MouseUp(Button, Shift, p, Handled);
  FSizing := False;
  LCLForm.Invalidate;
end;

{ TDraftWidget }

constructor TDraftWidget.Create(AWidget: TAndroidWidget; Canvas: TCanvas);
var
  x: TLayoutParams;
  y, z: DWORD;
begin
  TextColor:= clNone;
  BackGroundColor:= clNone;
  FAndroidWidget := AWidget;
  FCanvas := Canvas;
  FColor := colbrDefault;

  with jVisualControl(FAndroidWidget) do
  begin
    FnewW := Width;
    FnewH := Height;
    FnewL := Left;
    FnewT := Top;
    with Designer do
      if FSizing and (FSelection.IndexOf(AWidget) >= 0)
      and (Parent <> nil) then
      begin
        if not (LayoutParamWidth in [lpWrapContent]) then
        begin
          x := GetDesignerLayoutByWH(FnewW, Parent.Width);
          y := GetLayoutParamsByParent2(Parent, x, sdW);
          if LayoutParamWidth = lpMatchParent then
            z := Parent.Width - MarginLeft - FnewL - MarginRight
          else
            z := GetLayoutParamsByParent2(Parent, LayoutParamWidth, sdW);
          if (z <> FnewW) and (Abs(y - FnewW) < Abs(z - FnewW)) then
            LayoutParamWidth := x;
        end;
        if not (LayoutParamHeight in [lpWrapContent]) then
        begin
          x := GetDesignerLayoutByWH(FnewH, Parent.Height);
          y := GetLayoutParamsByParent2(Parent, x, sdH);
          if LayoutParamHeight = lpMatchParent then
            z := Parent.Height - MarginTop - FnewT - MarginBottom
          else
            z := GetLayoutParamsByParent2(Parent, LayoutParamHeight, sdH);
          if (z <> FnewH) and (Abs(y - FnewH) < Abs(z - FnewH)) then
            LayoutParamHeight := x;
        end;
      end;
  end;

  Height := AWidget.Height;
  Width := AWidget.Width;
  MarginLeft := AWidget.MarginLeft;
  MarginTop := AWidget.MarginTop;
  MarginRight := AWidget.MarginRight;
  MarginBottom := AWidget.MarginBottom;
end;


procedure TDraftWidget.Draw;
begin
  with FCanvas do
  begin
    if Color <> colbrDefault then
      Brush.Color := FPColorToTColor(ToTFPColor(Color))
    else begin
      Brush.Color:= clNone;
      Brush.Style:= bsClear;
    end;
    Rectangle(0, 0, FAndroidWidget.Width, FAndroidWidget.Height);    // outer frame
    TextOut(12, 9, FAndroidWidget.Text);
  end;
end;

procedure TDraftWidget.UpdateLayout;
begin
  with jVisualControl(FAndroidWidget) do
  begin
    if Assigned(Parent) then
    begin
      if not (LayoutParamWidth in [lpWrapContent, lpMatchParent]) then
        FnewW := GetLayoutParamsByParent2(Parent, LayoutParamWidth, sdW);
      if not (LayoutParamHeight in [lpWrapContent, lpMatchParent]) then
        FnewH := GetLayoutParamsByParent2(Parent, LayoutParamHeight, sdH);
      if FnewW < FminW then FnewW := FminW;
      if FnewH < FminH then FnewH := FminH;
      if (PosRelativeToParent <> []) or (PosRelativeToAnchor <> []) then
      begin
        FnewL := MarginLeft;
        FnewT := MarginTop;
      end;
      if rpCenterHorizontal in PosRelativeToParent then
        FnewL := (Parent.Width - FnewW) div 2;
      if rpCenterVertical in PosRelativeToParent then
        FnewT := (Parent.Height - FnewH) div 2;
      if rpCenterInParent in PosRelativeToParent then
      begin
        FnewL := (Parent.Width - FnewW) div 2;
        FnewT := (Parent.Height - FnewH) div 2;
      end;
      if rpRight in PosRelativeToParent then
        if not (rpLeft in PosRelativeToParent) then
          FnewL := Parent.Width - Width - MarginRight
        else begin
          FnewL := MarginRight;
          FnewW := Parent.Width - MarginRight - MarginLeft;
        end
      else
      if rpLeft in PosRelativeToParent then
        FnewL := MarginLeft;
      if rpTop in PosRelativeToParent then
        if not (rpBottom in PosRelativeToParent) then
          FnewT := MarginTop
        else begin
          FnewT := MarginTop;
          FnewH := Parent.Height - MarginTop - MarginBottom;
        end
      else
      if rpBottom in PosRelativeToParent then
        FnewT := Parent.Height - MarginBottom - Height;
      { TODO: rpStart, rpEnd }
    end;
    if Anchor <> nil then
    begin
      if raBelow in PosRelativeToAnchor then
        FnewT := Anchor.Top + Anchor.Height + Anchor.MarginBottom + MarginTop;
      if raAbove in PosRelativeToAnchor then
        FnewT := Anchor.Top - Height - MarginBottom - Anchor.MarginTop;
      if raToRightOf in PosRelativeToAnchor then
        FnewL := Anchor.Left + Anchor.Width + Anchor.MarginRight + MarginLeft;
      if raAlignBaseline in PosRelativeToAnchor then
        FnewT := Anchor.Top + (Anchor.Height - Height) div 2;
      if raAlignLeft in PosRelativeToAnchor then
        FnewL := Anchor.Left + MarginLeft;
      if raToEndOf in PosRelativeToAnchor then
        FnewL := Anchor.Left + Anchor.Width + Anchor.MarginRight + MarginLeft;
      { TODO: other combinations }
    end;
    if Assigned(Parent) then
    begin
      if LayoutParamWidth = lpMatchParent then
        FnewW := Parent.Width - MarginLeft - FnewL - MarginRight;
      if LayoutParamHeight = lpMatchParent then
        FnewH := Parent.Height - MarginTop - FnewT - MarginBottom;
    end;
    SetBounds(FnewL, FnewT, FnewW, FnewH);
  end;
end;

procedure TDraftWidget.SetColor(color: TARGBColorBridge);
begin
  FColor:= color;
  if color <> colbrDefault then
    BackGroundColor:= FPColorToTColor(ToTFPColor(color))
  else
    BackGroundColor:= clNone;
end;

procedure TDraftWidget.SetFontColor(AColor: TARGBColorBridge);
begin
  FFontColor := AColor;
  if AColor <> colbrDefault then
    TextColor := FPColorToTColor(ToTFPColor(AColor))
  else
    TextColor := clNone;
end;

function TDraftWidget.Designer: TAndroidWidgetMediator;
var
  t: TAndroidWidget;
begin
  Result := nil;
  if FAndroidWidget = nil then Exit;
  t := FAndroidWidget;
  while Assigned(t.Parent) do t := t.Parent;
  if t is TAndroidForm then
    Result := TAndroidForm(t).Designer as TAndroidWidgetMediator;
end;

function TDraftWidget.GetParentBackgroundColor: TARGBColorBridge;
begin
  // TODO: Parent.AcceptChildrenAtDesignTime
  if FAndroidWidget.Parent is jPanel then
  begin
    Result := jPanel(FAndroidWidget.Parent).BackgroundColor;
  end else
  if FAndroidWidget.Parent is jCustomDialog then
  begin
    Result := jCustomDialog(FAndroidWidget.Parent).BackgroundColor;
  end else
    Result := Color;
end;

function TDraftWidget.GetBackGroundColor: TColor;
var
  w: TAndroidWidget;
  d: TDraftWidgetClass;
begin
  Result := BackGroundColor;
  if Result = clNone then
  begin
    w := FAndroidWidget.Parent;
    while (Result = clNone) and (w is jVisualControl) do
    begin
      d := DraftClassesMap.Find(w.ClassType);
      if d = nil then Break;
      with d.Create(w, FCanvas) do
      begin
        Result := BackGroundColor;
        w := w.Parent;
        Free;
      end;
    end;
    if (Result = clNone) and (w is jForm)
    and (jForm(w).BackgroundColor <> colbrDefault) then
      Result := FPColorToTColor(ToTFPColor(jForm(w).BackgroundColor))
    else
      Result := Designer.FDefaultBrushColor;
  end;
end;

{ TDraftButton }

constructor TDraftButton.Create(AWidget: TAndroidWidget; Canvas: TCanvas);
begin
  inherited;

  Color := jButton(AWidget).BackgroundColor;
  FontColor := jButton(AWidget).FontColor;

  if jButton(AWidget).BackgroundColor = colbrDefault then
    Color := GetParentBackgroundColor;
end;

procedure TDraftButton.Draw;
var
  r: TRect;
  ts: TTextStyle;
  lastFontSize: Integer;
begin
  with Fcanvas do
  begin
    Brush.Color := BackGroundColor;
    Pen.Color := clForm;
    Font.Color := TextColor;

    if BackGroundColor = clNone then
      Brush.Color := RGBToColor($cc, $cc, $cc);

    if TextColor = clNone then
      Font.Color:= clBlack;
    lastFontSize := Font.Size;
    Font.Size := AndroidToLCLFontSize(jButton(FAndroidWidget).FontSize, 13);

    r := Rect(0, 0, Self.Width, Self.Height);
    FillRect(r);
    //outer frame
    Rectangle(r);

    Pen.Color := clMedGray;
    Brush.Style := bsClear;
    InflateRect(r, -1, -1);
    Rectangle(r);

    ts := TextStyle;
    ts.Layout := tlCenter;
    ts.Alignment := Classes.taCenter;
    TextRect(r, r.Left, r.Top, FAndroidWidget.Text, ts);
    Font.Size := lastFontSize;
  end;
end;

procedure TDraftButton.UpdateLayout;
begin
  with jButton(FAndroidWidget) do
    if LayoutParamHeight = lpWrapContent then
    begin
      FnewH := 14 + AndroidToLCLFontSize(jButton(FAndroidWidget).FontSize, 13) + 13;
      if FnewH < 40 then FnewH := 40;
    end;
  inherited UpdateLayout;
end;

{ TDraftTextView }

constructor TDraftTextView.Create(AWidget: TAndroidWidget; Canvas: TCanvas);
begin
  inherited;
  Color := jTextView(AWidget).BackgroundColor;
  if Color = colbrDefault then
    Color := GetParentBackgroundColor;
  FontColor := jTextView(AWidget).FontColor;
end;

procedure TDraftTextView.Draw;
var
  lastSize, ps: Integer;
begin
  with Fcanvas do
  begin
    ps := AndroidToLCLFontSize(jTextView(FAndroidWidget).FontSize, 10);
    lastSize := Font.Size;
    Font.Size := ps;

    Brush.Color := BackGroundColor;
    Pen.Color := TextColor;
    if BackGroundColor <> clNone then
      FillRect(0, 0, Self.Width, Self.Height)
    else
      Brush.Style := bsClear;

    if TextColor = clNone then
    begin
      Font.Color := RGBToColor($3A,$3A,$3A);
      if MaxRGB(GetBackGroundColor) < MaxRGB2Inverse then
        Font.Color := InvertColor(Font.Color);
    end else
      Font.Color := TextColor;

    TextOut(0, (ps + 5) div 10, FAndroidWidget.Text);
    Font.Size := lastSize;
  end;
end;

procedure TDraftTextView.UpdateLayout;
var
  ps, lastSize: Integer;
begin
  with jTextView(FAndroidWidget), FCanvas do
    if (LayoutParamWidth = lpWrapContent)
    or (LayoutParamHeight = lpWrapContent) then
    begin
      lastSize := Font.Size;
      ps := AndroidToLCLFontSize(FontSize, 10);
      Font.Size := ps;
      with TextExtent(Text) do
      begin
        if LayoutParamWidth = lpWrapContent then
          FnewW := cx;
        if LayoutParamHeight = lpWrapContent then
          FnewH := cy + 2 + (ps + 5) div 10;
      end;
      Font.Size := lastSize;
    end;
  inherited UpdateLayout;
end;

{ TDraftEditText }

constructor TDraftEditText.Create(AWidget: TAndroidWidget; Canvas: TCanvas);
begin
  inherited;
  Color := jEditText(AWidget).BackgroundColor;
  if Color = colbrDefault then
    Color := GetParentBackgroundColor;
  FontColor := jEditText(AWidget).FontColor;
end;

procedure TDraftEditText.Draw;
var
  ls: Integer;
begin
  with FCanvas do
  begin
    if BackgroundColor <> clNone then
    begin
      Brush.Color := BackGroundColor;
      FillRect(0, 0, FAndroidWidget.Width, FAndroidWidget.Height);
    end else
      Brush.Style := bsClear;
    if TextColor = clNone then
    begin
      Font.Color := clBlack;
      if MaxRGB(GetBackGroundColor) < MaxRGB2Inverse then
        Font.Color := InvertColor(Font.Color);
    end else
      Font.Color := TextColor;
    ls := Font.Size;
    Font.Size := AndroidToLCLFontSize(jEditText(FAndroidWidget).FontSize, 13);
    TextOut(12, 9, jEditText(FAndroidWidget).Text);
    Font.Size := ls;
    if BackgroundColor = clNone then
    begin
      Pen.Color := RGBToColor(175,175,175);
      with FAndroidWidget do
      begin
        MoveTo(4, Height - 8);
        Lineto(4, Height - 5);
        Lineto(Width - 4, Height - 5);
        Lineto(Width - 4, Height - 8);
      end;
    end;
  end;
end;

procedure TDraftEditText.UpdateLayout;
var
  fs: Integer;
begin
  with jEditText(FAndroidWidget) do
    if LayoutParamHeight = lpWrapContent then
    begin
      fs := FontSize;
      if fs = 0 then fs := 18;
      FnewH := 29 + (fs - 10) * 4 div 3; // todo: multiline
    end;
  inherited;
end;

{TDraftAutoTextView}

constructor TDraftAutoTextView.Create(AWidget: TAndroidWidget; Canvas: TCanvas);
begin
  inherited;
  Color := jAutoTextView(AWidget).BackgroundColor;
  FontColor := jAutoTextView(AWidget).FontColor;
end;

procedure TDraftAutoTextView.Draw;
var
  ls: Integer;
begin
  with FCanvas do
  begin
    if BackgroundColor <> clNone then
    begin
      Brush.Color := BackGroundColor;
      FillRect(0, 0, FAndroidWidget.Width, FAndroidWidget.Height);
    end else
      Brush.Style := bsClear;
    if TextColor = clNone then
    begin
      Font.Color := clBlack;
      if MaxRGB(GetBackGroundColor) < MaxRGB2Inverse then
        Font.Color := InvertColor(Font.Color);
    end else
      Font.Color := TextColor;

    ls := Font.Size;
    Font.Size := AndroidToLCLFontSize(jAutoTextView(FAndroidWidget).FontSize, 13);
    TextOut(4, 12, jAutoTextView(FAndroidWidget).Text);
    Font.Size := ls;

    if BackgroundColor = clNone then
    begin
      Pen.Color := RGBToColor(175,175,175);
      with FAndroidWidget do
      begin
        MoveTo(4, Height - 8);
        Lineto(4, Height - 5);
        Lineto(Width - 4, Height - 5);
        Lineto(Width - 4, Height - 8);
      end;
    end;
  end;
end;

procedure TDraftAutoTextView.UpdateLayout;
var
  fs: Integer;
begin
  with jAutoTextView(FAndroidWidget) do
    if LayoutParamHeight = lpWrapContent then
    begin
      fs := FontSize;
      if fs = 0 then fs := 18;
      FnewH := 29 + (fs - 10) * 4 div 3; // todo: multiline
    end;
  inherited UpdateLayout;
end;

{ TDraftCheckBox }

constructor TDraftCheckBox.Create(AWidget: TAndroidWidget; Canvas: TCanvas);
begin
  inherited;
  Color := jCheckBox(AWidget).BackgroundColor;
  FontColor := jCheckBox(AWidget).FontColor;
end;

procedure TDraftCheckBox.Draw;
var
  lastSize, ps: Integer;
begin
  with Fcanvas do
  begin
    Brush.Color := Self.BackGroundColor;
    if BackGroundColor <> clNone then
      FillRect(0, 0, Self.Width, Self.Height)
    else
      Brush.Style := bsClear;

    if TextColor = clNone then
    begin
      Font.Color := clBlack;
      if MaxRGB(GetBackGroundColor) < MaxRGB2Inverse then
        Font.Color := InvertColor(Font.Color);
    end else
      Font.Color := TextColor;

    lastSize := Font.Size;
    ps := AndroidToLCLFontSize(jCheckBox(FAndroidWidget).FontSize, 12);
    Font.Size := ps;
    TextOut(32, 14 - Abs(Font.Height) div 2, FAndroidWidget.Text);
    Font.Size := lastSize;

    Brush.Color := clWhite;
    Brush.Style := bsClear;
    Pen.Color := RGBToColor($A1,$A1,$A1);
    Rectangle(8, 8, 24, 24);
    if jCheckBox(FAndroidWidget).Checked then
    begin
      lastSize := Pen.Width;
      Pen.Width := 4;
      Pen.Color := RGBToColor($44,$B3,$DD);
      MoveTo(12, 13);
      LineTo(16, 18);
      LineTo(26, 7);
      Pen.Width := lastSize;
    end;
  end;
end;

procedure TDraftCheckBox.UpdateLayout;
var
  ls, ps: Integer;
begin
  with jCheckBox(FAndroidWidget) do
  begin
    if LayoutParamHeight = lpWrapContent then
      FnewH := 32;
    if LayoutParamWidth = lpWrapContent then
    begin
      ps := AndroidToLCLFontSize(FontSize, 12);
      ls := FCanvas.Font.Size;
      FCanvas.Font.Size := ps;
      FnewW := 33 + FCanvas.TextWidth(Text);
      FCanvas.Font.Size := ls;
    end;
  end;
  inherited UpdateLayout;
end;

{ TDraftRadioButton }

constructor TDraftRadioButton.Create(AWidget: TAndroidWidget; Canvas: TCanvas);
begin
  inherited;
  Color := jRadioButton(AWidget).BackgroundColor;
  FontColor := jRadioButton(AWidget).FontColor;
end;

procedure TDraftRadioButton.Draw;
var
  lastSize: Integer;
begin
  with Fcanvas do
  begin
    Brush.Color := BackGroundColor;
    if BackGroundColor <> clNone then
      FillRect(0, 0, Self.Width, Self.Height)
    else
      Brush.Style := bsClear;

    if TextColor = clNone then
    begin
      Font.Color := clBlack;
      if MaxRGB(GetBackGroundColor) < MaxRGB2Inverse then
        Font.Color := InvertColor(Font.Color);
    end else
      Font.Color := Self.TextColor;

    lastSize := Font.Size;
    Font.Size := AndroidToLCLFontSize(jCheckBox(FAndroidWidget).FontSize, 12);
    TextOut(32, 14 - Abs(Font.Height) div 2, FAndroidWidget.Text);
    Font.Size := lastSize;

    Brush.Style := bsClear;
    Pen.Color := RGBToColor(155,155,155);
    Ellipse(7, 6, 25, 24);

    if jRadioButton(FAndroidWidget).Checked then
    begin
      Brush.Color := RGBToColor(0,$99,$CC);
      Ellipse(7+3, 6+3, 25-3, 24-3);
    end;
  end;
end;

procedure TDraftRadioButton.UpdateLayout;
var
  ps, ls: Integer;
begin
  with jRadioButton(FAndroidWidget) do
  begin
    if LayoutParamHeight = lpWrapContent then
      FnewH := 32;
    if LayoutParamWidth = lpWrapContent then
    begin
      ps := AndroidToLCLFontSize(FontSize, 12);
      ls := FCanvas.Font.Size;
      FCanvas.Font.Size := ps;
      FnewW := 33 + FCanvas.TextWidth(Text);
      FCanvas.Font.Size := ls;
    end;
  end;
  inherited UpdateLayout;
end;

{ TDraftProgressBar }

constructor TDraftProgressBar.Create(AWidget: TAndroidWidget; Canvas: TCanvas);
begin
  inherited;

  Color := jProgressBar(AWidget).BackgroundColor;
  FontColor := colbrBlack;

  if jProgressBar(AWidget).BackgroundColor = colbrDefault then
    Color := GetParentBackgroundColor;
end;

procedure TDraftProgressBar.Draw;
var
  x: integer;
  r: TRect;
begin
  with Fcanvas do
  begin
    Brush.Color := RGBToColor($ad,$ad,$ad);
    r := Rect(0, 10, Self.Width, 13);
    FillRect(r);
    Brush.Color := RGBToColor($44,$B3,$DD);
    r.Top := 9;
    r.Bottom := 12;
    if jProgressBar(FAndroidWidget).Max <= 0 then
      jProgressBar(FAndroidWidget).Max := 100;
    x := Self.Width * jProgressBar(FAndroidWidget).Progress
         div jProgressBar(FAndroidWidget).Max;
    { "inverse" does not work... yet?
    if not (jProgressBar(FAndroidWidget).Style
            in [cjProgressBarStyleInverse, cjProgressBarStyleLargeInverse])
    then}
      r.Right := x
    {else begin
      r.Right := Self.Width;
      r.Left := Self.Width - x;
    end};
    FillRect(r);
  end;
end;

procedure TDraftProgressBar.UpdateLayout;
begin
  with jProgressBar(FAndroidWidget) do
    if LayoutParamHeight = lpWrapContent then
      FnewH := 23;
  inherited UpdateLayout;
end;


{ TDraftSeekBar }

constructor TDraftSeekBar.Create(AWidget: TAndroidWidget; Canvas: TCanvas);
begin
  inherited;

  Color := jSeekBar(AWidget).BackgroundColor;
  FontColor := colbrBlack;

  if jSeekBar(AWidget).BackgroundColor = colbrDefault then
    Color := GetParentBackgroundColor;
end;

procedure TDraftSeekBar.Draw;
var
  x: integer;
  r: TRect;
begin
  with Fcanvas do
  begin
    Brush.Color := RGBToColor($ad,$ad,$ad);
    r := Rect(0, 10, Self.Width, 13);
    FillRect(r);
    Brush.Color := RGBToColor($44,$B3,$DD);
    r.Top := 9;
    r.Bottom := 12;
    if jSeekBar(FAndroidWidget).Max <= 0 then
      jSeekBar(FAndroidWidget).Max := 100;
    x := Self.Width * jSeekBar(FAndroidWidget).Progress div jSeekBar(FAndroidWidget).Max;
    { "inverse" does not work... yet?
    if not (jProgressBar(FAndroidWidget).Style
            in [cjProgressBarStyleInverse, cjProgressBarStyleLargeInverse])
    then}
      r.Right := x;
    {else begin
      r.Right := Self.Width;
      r.Left := Self.Width - x;
    end};
    FillRect(r);
    Brush.Color := RGBToColor($ff,$ff,$00);
    Ellipse(Rect(x, 6, x+12 , 18));
  end;
end;

procedure TDraftSeekBar.UpdateLayout;
begin
  with jSeekBar(FAndroidWidget) do
    if LayoutParamHeight = lpWrapContent then
      FnewH := 23;
  inherited UpdateLayout;
end;

{ TDraftListView }

constructor TDraftListView.Create(AWidget: TAndroidWidget; Canvas: TCanvas);
begin
  inherited;

  Color := jListView(AWidget).BackgroundColor;
  FontColor := jListView(AWidget).FontColor; //colbrBlack;

  if jListView(AWidget).BackgroundColor = colbrDefault then
    Color := GetParentBackgroundColor;
end;

procedure TDraftListView.Draw;
var
  i, k: integer;
begin
  Fcanvas.Brush.Color:= Self.BackGroundColor;
  Fcanvas.Pen.Color:= clActiveCaption;

  if  Self.BackGroundColor = clNone then Fcanvas.Brush.Style:= bsClear;

  Fcanvas.FillRect(0,0,Self.Width,Self.Height);
      // outer frame
  Fcanvas.Rectangle(0,0,Self.Width,Self.Height);

  Fcanvas.Brush.Style:= bsSolid;

  Fcanvas.Pen.Color:= clSilver;
  k:= Trunc(Self.Height/20);
  for i:= 1 to k-1 do
  begin
    Fcanvas.MoveTo(Self.Width{-Self.MarginRight+10}, {x2} Self.MarginTop+i*20); {y1}
    Fcanvas.LineTo(0,Self.MarginTop+i*20);  {x1, y1}
  end;

  //canvas.Brush.Style:= bsClear;
  //canvas.Font.Color:= Self.TextColor;
  //canvas.TextOut(5,4, txt);

end;

{ TDraftImageBtn }

constructor TDraftImageBtn.Create(AWidget: TAndroidWidget; Canvas: TCanvas);
begin
  inherited;

  Color := jImageBtn(AWidget).BackgroundColor;
  FontColor:= colbrGray;
  BackGroundColor:= clActiveCaption; //clMenuHighlight;

  if jImageBtn(AWidget).BackgroundColor = colbrDefault then
    Color := GetParentBackgroundColor;
end;

procedure TDraftImageBtn.Draw;
begin
  Fcanvas.Brush.Color:= Self.BackGroundColor;
  Fcanvas.Pen.Color:= clWhite;
  if Self.BackGroundColor = clNone then
     Fcanvas.Brush.Color:= clSilver; //clMedGray;
  Fcanvas.FillRect(0,0,Self.Width,Self.Height);
      // outer frame
  Fcanvas.Rectangle(0,0,Self.Width,Self.Height);
  Fcanvas.Pen.Color:= clWindowFrame;
  Fcanvas.Line(Self.Width-Self.MarginRight+3, {x2}
             Self.MarginTop-3,  {y1}
             Self.Width-Self.MarginRight+3,  {x2}
             Self.Height-Self.MarginBottom+3); {y2}

  Fcanvas.Line(Self.Width-Self.MarginRight+3, {x2}
             Self.Height-Self.MarginBottom+3,{y2}
             Self.MarginLeft-4,                {x1}
             Self.Height-Self.MarginBottom+3);  {y2}
end;

{ TDraftImageView }

constructor TDraftImageView.Create(AWidget: TAndroidWidget; Canvas: TCanvas);
begin
  inherited;

  Color := jImageView(AWidget).BackgroundColor;
  FontColor:= colbrGray;
  BackGroundColor:= clActiveCaption; //clMenuHighlight;

  if jImageView(AWidget).BackgroundColor = colbrDefault then
    Color := GetParentBackgroundColor;
end;

{ TDrafDrawingView }

constructor TDraftDrawingView.Create(AWidget: TAndroidWidget; Canvas: TCanvas);
begin
  inherited;

  Color := jDrawingView(AWidget).BackgroundColor;
  FontColor := colbrGray;
  BackGroundColor := clActiveCaption; //clMenuHighlight;

  if jDrawingView(AWidget).BackgroundColor = colbrDefault then
    Color := GetParentBackgroundColor;
end;

{ TDraftSurfaceView }

constructor TDraftSurfaceView.Create(AWidget: TAndroidWidget; Canvas: TCanvas);
begin
  inherited;

  Color := jSurfaceView(AWidget).BackgroundColor;
  FontColor := colbrGray;
  BackGroundColor := clActiveCaption; //clMenuHighlight;

  if jSurfaceView(AWidget).BackgroundColor = colbrDefault then
    Color := GetParentBackgroundColor;
end;

{ TDraftSpinner }

constructor TDraftSpinner.Create(AWidget: TAndroidWidget; Canvas: TCanvas);
begin
  inherited;

  Color := jSpinner(AWidget).BackgroundColor;
  FontColor := jSpinner(AWidget).DropListBackgroundColor;
  DropListTextColor := jSpinner(AWidget).DropListTextColor;
  DropListBackgroundColor := jSpinner(AWidget).DropListBackgroundColor;
  SelectedFontColor := jSpinner(AWidget).SelectedFontColor;

  if jSpinner(AWidget).BackgroundColor = colbrDefault then
    Color := GetParentBackgroundColor;
end;

procedure TDraftSpinner.SetDropListBackgroundColor(Acolor: TARGBColorBridge);
begin
  FDropListBackgroundColor:= Acolor;
  if Acolor <> colbrDefault then
    DropListColor:= FPColorToTColor(ToTFPColor(Acolor))
  else
    DropListColor:= clNone;
end;

procedure TDraftSpinner.SetDropListTextColor(Acolor: TARGBColorBridge);
var
  fpColor: TFPColor;
begin
  FDropListTextColor:= Acolor;
  if Acolor <> colbrDefault then
  begin
    fpColor:= ToTFPColor(Acolor);
    DropListFontColor:= FPColorToTColor(fpColor);
  end
  else DropListFontColor:= clNone;
end;

procedure TDraftSpinner.SetSelectedFontColor(Acolor: TARGBColorBridge);
var
  fpColor: TFPColor;
begin
  FSelectedFontColor:= Acolor;
  if Acolor <> colbrDefault then
  begin
    fpColor:= ToTFPColor(Acolor);
    SelectedTextColor:= FPColorToTColor(fpColor);
  end
  else SelectedTextColor:= clNone;
end;

procedure TDraftSpinner.Draw;
var
  saveColor: TColor;
begin
  Fcanvas.Brush.Color:= Self.BackGroundColor;
  Fcanvas.Pen.Color:= Self.DropListColor;

  if DropListColor = clNone then
     Fcanvas.Pen.Color:= clMedGray;

  if BackGroundColor = clNone then
     Fcanvas.Brush.Color:= clWhite;

  Fcanvas.FillRect(0,0,Self.Width,Self.Height);
      // outer frame
  Fcanvas.Rectangle(0,0,Self.Width,Self.Height);

  Fcanvas.Brush.Color:= Self.DropListColor; //clActiveCaption;

  if DropListColor = clNone then
     Fcanvas.Brush.Color:= clSilver;

  Fcanvas.Rectangle(Self.Width-47,0+7,Self.Width-7,Self.Height-7);
  saveColor:= Fcanvas.Brush.Color;

  Fcanvas.Brush.Style:= bsClear;
  Fcanvas.Pen.Color:= clWhite;
  Fcanvas.Rectangle(Self.Width-48,0+6,Self.Width-6,Self.Height-6);

  Fcanvas.Pen.Color:= Self.DropListFontColor;

  if saveColor <> clBlack then
     Fcanvas.Pen.Color:= clBlack
  else
     Fcanvas.Pen.Color:= clSilver;

  Fcanvas.Line(Self.Width-42, 12,Self.Width-11, 12);
  Fcanvas.Line(Self.Width-42-1, 12,Self.Width-42+31 div 2, Self.Height-12);
  Fcanvas.Line(Self.Width-42+31 div 2,Self.Height-12,Self.Width-11,12);

  Fcanvas.Font.Color:= Self.SelectedTextColor;
  if SelectedTextColor = clNone then
     Fcanvas.Font.Color:= clMedGray;

  //Fcanvas.TextOut(5,4,txt);
end;

{ TDraftWebView }

constructor TDraftWebView.Create(AWidget: TAndroidWidget; Canvas: TCanvas);
begin
  inherited;

  Color := jWebView(AWidget).BackgroundColor;
  BackGroundColor := clWhite;

  if jWebView(AWidget).BackgroundColor = colbrDefault then
    Color := GetParentBackgroundColor;
end;

procedure TDraftWebView.Draw;
begin
  Fcanvas.Brush.Color:= Self.BackGroundColor;
  Fcanvas.Pen.Color:= clTeal; //clGreen;//clActiveCaption;
  Fcanvas.FillRect(0,0,Self.Width,Self.Height);
  Fcanvas.Rectangle(0,0,Self.Width,Self.Height);  // outer frame

  Fcanvas.Brush.Color:= clWhite;
  Fcanvas.Pen.Color:= clMoneyGreen;//clActiveCaption;

  Fcanvas.FillRect(5,5,Self.Width-5,25);
  Fcanvas.Rectangle(5,5,Self.Width-5,25);

  Fcanvas.FillRect (5,30,Trunc(Self.Width/2)-5,Self.Height-5);
  Fcanvas.Rectangle(5,30,Trunc(Self.Width/2)-5,Self.Height-5);

  Fcanvas.FillRect (Trunc(Self.Width/2),30,Self.Width-5,Trunc(0.5*Self.Height));
  Fcanvas.Rectangle(Trunc(Self.Width/2),30,Self.Width-5,Trunc(0.5*Self.Height));

  Fcanvas.FillRect (Trunc(Self.Width/2),Trunc(0.5*Self.Height)+5,Self.Width-5,Self.Height-5);
  Fcanvas.Rectangle(Trunc(Self.Width/2),Trunc(0.5*Self.Height)+5,Self.Width-5,Self.Height-5);
end;

{ TDraftScrollView }

constructor TDraftScrollView.Create(AWidget: TAndroidWidget; Canvas: TCanvas);
begin
  inherited;

  Color := jScrollView(AWidget).BackgroundColor;

  if jScrollView(AWidget).BackgroundColor = colbrDefault then
    Color := GetParentBackgroundColor;
end;

procedure TDraftScrollView.Draw;
begin
  Fcanvas.Brush.Color:= Self.BackGroundColor;
  Fcanvas.Pen.Color:= clMedGray; //clGreen;//clActiveCaption;

  if Self.BackGroundColor = clNone then Fcanvas.Brush.Style:= bsClear;

  Fcanvas.FillRect(0,0,Self.Width,Self.Height);
  Fcanvas.Rectangle(0,0,Self.Width,Self.Height);  // outer frame

  Fcanvas.Brush.Style:= bsSolid;
  Fcanvas.Brush.Color:= clWhite;
  Fcanvas.FillRect(Self.Width-20,5,Self.Width-5,Self.Height-5);

  Fcanvas.Brush.Color:= clMedGray; //Self.BackGroundColor;
  Fcanvas.FillRect(Self.Width-20+5,5+25,Self.Width-5-5,Self.Height-5-25);

  Fcanvas.Pen.Color:= clMedGray; //clGreen;//clActiveCaption;
  Fcanvas.Frame(Self.Width-20,5,Self.Width-5,Self.Height-5);

  Fcanvas.Pen.Color:= clBlack; //clGreen;//clActiveCaption;
  Fcanvas.MoveTo(Self.Width-5-1,5+1);
  Fcanvas.LineTo(Self.Width-20+1,5+1);
  Fcanvas.LineTo(Self.Width-20+1,Self.Height-5-1);

  Fcanvas.Pen.Color:= clWindowFrame; //clGreen;//clActiveCaption;
  Fcanvas.MoveTo(Self.Width-5-5,5+25+1);
  Fcanvas.LineTo(Self.Width-5-5,Self.Height-5-25);
  Fcanvas.LineTo(Self.Width-20+5,Self.Height-5-25);
end;

{ TDraftHorizontalScrollView }

constructor TDraftHorizontalScrollView.Create(AWidget: TAndroidWidget; Canvas: TCanvas);
begin
  inherited;

  Color := jHorizontalScrollView(AWidget).BackgroundColor;

  if jHorizontalScrollView(AWidget).BackgroundColor = colbrDefault then
    Color := GetParentBackgroundColor;
end;

procedure TDraftHorizontalScrollView.Draw;
begin
  Fcanvas.Brush.Color:= Self.BackGroundColor;
  Fcanvas.Pen.Color:= clMedGray;

  if Self.BackGroundColor = clNone then Fcanvas.Brush.Style:= bsClear;

  Fcanvas.Rectangle(0,0,Self.Width,Self.Height);  // outer frame
  Fcanvas.TextOut(12, 9, jHorizontalScrollView(FAndroidWidget).Text);

(*  TODO :: Horizontal!
  Fcanvas.Brush.Style:= bsSolid;
  Fcanvas.Brush.Color:= clWhite;
  Fcanvas.FillRect(Self.Width-20,5,Self.Width-5,Self.Height-5);

  Fcanvas.Brush.Color:= clMedGray; //Self.BackGroundColor;
  Fcanvas.FillRect(Self.Width-20+5,5+25,Self.Width-5-5,Self.Height-5-25);

  Fcanvas.Pen.Color:= clMedGray; //clGreen;//clActiveCaption;
  Fcanvas.Frame(Self.Width-20,5,Self.Width-5,Self.Height-5);

  Fcanvas.Pen.Color:= clBlack; //clGreen;//clActiveCaption;
  Fcanvas.MoveTo(Self.Width-5-1,5+1);
  Fcanvas.LineTo(Self.Width-20+1,5+1);
  Fcanvas.LineTo(Self.Width-20+1,Self.Height-5-1);

  Fcanvas.Pen.Color:= clWindowFrame; //clGreen;//clActiveCaption;
  Fcanvas.MoveTo(Self.Width-5-5,5+25+1);
  Fcanvas.LineTo(Self.Width-5-5,Self.Height-5-25);
  Fcanvas.LineTo(Self.Width-20+5,Self.Height-5-25);
  *)

end;

{ TDraftRadioGroup}

constructor TDraftRadioGroup.Create(AWidget: TAndroidWidget; Canvas: TCanvas);
begin
  inherited;

  Color := jRadioGroup(AWidget).BackgroundColor;

  if jRadioGroup(AWidget).BackgroundColor = colbrDefault then
    Color := GetParentBackgroundColor;
end;

procedure TDraftRadioGroup.Draw;
begin
  Fcanvas.Brush.Color:= Self.BackGroundColor;
  Fcanvas.Pen.Color:= clMedGray; //clGreen;//clActiveCaption;

  if Self.BackGroundColor = clNone then Fcanvas.Brush.Style:= bsClear;

  Fcanvas.Rectangle(0,0,Self.Width,Self.Height);  // outer frame

  Fcanvas.TextOut(12, 9, jRadioGroup(FAndroidWidget).Text);
end;

{ TDraftRatingBar}

constructor TDraftRatingBar.Create(AWidget: TAndroidWidget; Canvas: TCanvas);
begin
  inherited;

  Color := jRatingBar(AWidget).BackgroundColor;

  if jRatingBar(AWidget).BackgroundColor = colbrDefault then
    Color := GetParentBackgroundColor;
end;

procedure TDraftRatingBar.Draw;

  procedure DrawStar(cx, cy: Integer);
  const
    R1 = 18.8;
    R2 = 8.4;
  var
    i: Integer;
    p: array of TPoint;
  begin
    SetLength(p, 5*2);
    for i := 0 to 4 do
    begin
      with p[i * 2] do
      begin
        x := cx + Round(R1 * Sin(i * 72 * pi / 180));
        y := cy - Round(R1 * Cos(i * 72 * pi / 180));
      end;
      with p[i * 2 + 1] do
      begin
        x := cx + Round(R2 * Sin((i + 0.5) * 72 * pi / 180));
        y := cy - Round(R2 * Cos((i + 0.5) * 72 * pi / 180));
      end;
    end;
    with FCanvas.Brush do
    begin
      Style := bsSolid;
      Color := RGBToColor(183, 183, 183);
    end;
    with FCanvas.Pen do
    begin
      Style := psSolid;
      Width := 1;
      Color := BlendColors(BackGroundColor, 62/114, 2, 2, 2);
    end;
    FCanvas.Polygon(p);
  end;

var
  i: Integer;
begin
  with Fcanvas do
  begin
    Brush.Color := BackGroundColor;
    if BackGroundColor <> clNone then
      FillRect(0, 0, Self.Width, Self.Height)
  end;
  for i := 0 to jRatingBar(FAndroidWidget).NumStars - 1 do
    DrawStar(24 + 48 * i, 6 + 19)
end;

procedure TDraftRatingBar.UpdateLayout;
begin
  with jRatingBar(FAndroidWidget) do
  begin
    if LayoutParamHeight = lpWrapContent then
      FnewH := 57;
    if LayoutParamWidth = lpWrapContent then
      FnewW := 48 * NumStars;
  end;
  inherited UpdateLayout;
end;

{ TDraftDigitalClock}

constructor TDraftDigitalClock.Create(AWidget: TAndroidWidget; Canvas: TCanvas);
begin
  inherited;

  Color := jDigitalClock(AWidget).BackgroundColor;

  if jDigitalClock(AWidget).BackgroundColor = colbrDefault then
    Color := GetParentBackgroundColor;
end;

{ TDraftAnalogClock }

constructor TDraftAnalogClock.Create(AWidget: TAndroidWidget; Canvas: TCanvas);
begin
  inherited;

  Color := jAnalogClock(AWidget).BackgroundColor;

  if jAnalogClock(AWidget).BackgroundColor = colbrDefault then
    Color := GetParentBackgroundColor;
end;

{ TDraftToggleButton }

constructor TDraftToggleButton.Create(AWidget: TAndroidWidget; Canvas: TCanvas);
begin
  inherited;
  BackGroundColor := clActiveCaption;; //clMenuHighlight;
  Color := jToggleButton(AWidget).BackgroundColor;
  FontColor := colbrGray;

  FOnOff := jToggleButton(AWidget).State <> tsOff
  {
  if jToggleButton(AWidget).BackgroundColor = colbrDefault then
    if AWidget.Parent is jPanel then
    begin
      Color := jPanel(AWidget.Parent).BackgroundColor;
    end else
    if AWidget.Parent is jCustomDialog then
    begin
      Color := jCustomDialog(AWidget.Parent).BackgroundColor;
    end;
  }
end;

procedure TDraftToggleButton.Draw;
begin
  Fcanvas.Brush.Color:= Self.BackGroundColor;
  Fcanvas.Pen.Color:= clWhite;
  Fcanvas.Font.Color:= Self.TextColor;

  if Self.BackGroundColor = clNone then
     Fcanvas.Brush.Color:= clSilver; //clMedGray;

  if Self.TextColor = clNone then
      Fcanvas.Font.Color:= clBlack;

  Fcanvas.FillRect(0,0,Self.Width,Self.Height);
      // outer frame
  Fcanvas.Rectangle(0,0,Self.Width,Self.Height);

  Fcanvas.Pen.Color:= clWindowFrame;
  if Self.FOnOff = True then  //on
  begin

    Fcanvas.Brush.Style:= bsSolid;
    Fcanvas.Brush.Color:= clSkyBlue;
    Fcanvas.FillRect(Self.MarginRight-4,
                    Self.MarginTop-3,
                    Self.Width-Self.MarginLeft+2,
                    Self.Height-Self.MarginBottom+3);

    Fcanvas.Brush.Style:= bsClear;
    Fcanvas.Pen.Color:= clWindowFrame;

     Fcanvas.Line(Self.Width-Self.MarginRight+3, {x2}
             Self.MarginTop-3,  {y1}
             Self.Width-Self.MarginRight+3,  {x2}
             Self.Height-Self.MarginBottom+3); {y2}

     Fcanvas.Line(Self.Width-Self.MarginRight+3, {x2}
             Self.Height-Self.MarginBottom+3,{y2}
             Self.MarginLeft-4,                {x1}
             Self.Height-Self.MarginBottom+3);  {y2}


     Fcanvas.Pen.Color:= clWhite;
     Fcanvas.Line(Self.MarginLeft-4, {x1}
                   Self.MarginTop-3,  {y1}
                   Self.MarginLeft-4, {x1}
                   Self.Height-Self.MarginBottom+3); {y2}

     Fcanvas.Line(Self.Width-Self.MarginRight+3, {x2}
                Self.MarginTop-3,  {y1}
                Self.MarginLeft-4, {x1}
                Self.MarginTop-3);{y1}
  end
  else  //off
  begin
    (*
    Fcanvas.Brush.Style:= bsSolid;
    Fcanvas.Brush.Color:= clSkyBlue;
    Fcanvas.FillRect(Self.MarginRight-4,
                    Self.MarginTop-3,
                    Self.Width-Self.MarginLeft+2,
                    Self.Height-Self.MarginBottom+3);

    *)
    Fcanvas.Brush.Style:= bsClear;
    Fcanvas.Pen.Color:= clWindowFrame;

    //V
    Fcanvas.Line(Self.MarginLeft-4, {x1}
               Self.MarginTop-3,  {y1}
               Self.MarginLeft-4, {x1}
               Self.Height-Self.MarginBottom+3); {y2}

     //H
    Fcanvas.Line(Self.Width-Self.MarginRight+3, {x2}
            Self.MarginTop-3,  {y1}
            Self.MarginLeft-4, {x1}
            Self.MarginTop-3);{y1}

    Fcanvas.Pen.Color:= clWhite;
    Fcanvas.Line(Self.Width-Self.MarginRight+3, {x2}
            Self.MarginTop-3,  {y1}
            Self.Width-Self.MarginRight+3,  {x2}
            Self.Height-Self.MarginBottom+3); {y2}

    Fcanvas.Line(Self.Width-Self.MarginRight+3, {x2}
            Self.Height-Self.MarginBottom+3,{y2}
            Self.MarginLeft-4,                {x1}
            Self.Height-Self.MarginBottom+3);  {y2}


  end;
end;

{ TDraftSwitchButton }

procedure TDraftSwitchButton.Draw;
var
  x, y, z, i, ps: Integer;
  r, rb: TRect;
  ts: TTextStyle;
  s: string;
begin
  with FCanvas do
  begin
    if BackGroundColor = clNone then
      BackGroundColor := GetBackGroundColor
    else begin
      Brush.Color := BackGroundColor;
      FillRect(0, 0, Self.Width, Self.Height);
    end;
    x := Self.Height div 2 - 12;
    Brush.Color := BlendColors(BackGroundColor, 0.7, 153,153,153);
    ps := Font.Size;
    Font.Size := 10;
    with jSwitchButton(FAndroidWidget) do
    begin
      y := TextWidth(TextOn);
      z := TextWidth(TextOff);
      if y < z then y := z;
      y := y + 22; // button width

      i := 2 * (y + 2);
      if i < 92 then i := 92;
      z := Self.Width - 2 - i;
      rb := Rect(z, x, z + i, x + 24);

      FillRect(rb);
      if State = tsOff then
      begin
        z := rb.Left + 1;
        Brush.Color := BlendColors(Self.BackgroundColor, 0.414, 153,153,153);
        Font.Color := RGBToColor(234,234,234);
        s := TextOff;
      end else begin
        z := rb.Right - 1 - y;
        Brush.Color := BlendColors(Self.BackgroundColor, 0.14, 11,153,200);
        Font.Color := clWhite;
        s := TextOn;
      end;
    end;
    r := Rect(z, x + 1, z + y, x + 23);
    FillRect(r);
    ts := TextStyle;
    ts.Layout := tlCenter;
    ts.Alignment := Classes.taCenter;
    TextRect(r, 0, 0, s, ts);
    Font.Size := ps;
  end;
end;

procedure TDraftSwitchButton.UpdateLayout;
var
  ps, x, y: Integer;
begin
  FminH := 28;
  with jSwitchButton(FAndroidWidget) do
  begin
    if LayoutParamWidth = lpWrapContent then
      with FCanvas do
      begin
        ps := Font.Size;
        Font.Size := 10;
        x := TextWidth(TextOn);
        y := TextWidth(TextOff);
        if y > x then x := y;
        x := 2 * (x + 22 + 2);
        if x < 92 then x := 92;
        x := x + 4;
        FnewW := x;
        Font.Size := ps;
      end;
    if LayoutParamHeight = lpWrapContent then
      FnewH := 28
  end;
  inherited;
end;

{TDraftGridView}

constructor TDraftGridView.Create(AWidget: TAndroidWidget; Canvas: TCanvas);
begin
  inherited;
  Color := jGridView(AWidget).BackgroundColor;
  if jGridView(AWidget).BackgroundColor = colbrDefault then
    Color := GetParentBackgroundColor;
end;

procedure TDraftGridView.Draw;
var
  i, k: integer;
begin
  Fcanvas.Brush.Color:= Self.BackGroundColor;
  Fcanvas.Pen.Color:= clActiveCaption;

  if  Self.BackGroundColor = clNone then Fcanvas.Brush.Style:= bsClear;

  Fcanvas.FillRect(0,0,Self.Width,Self.Height);
  // outer frame
  Fcanvas.Rectangle(0,0,Self.Width,Self.Height);
  Fcanvas.Brush.Style:= bsSolid;
  Fcanvas.Pen.Color:= clSilver;

  //H lines
  k:= Trunc((Self.Height-Self.MarginTop-Self.MarginBottom)/70);
  for i:= 1 to k do
  begin
    Fcanvas.MoveTo(Self.Width-Self.MarginRight+10, {x2} Self.MarginTop+i*70); {y1}
    Fcanvas.LineTo(Self.MarginLeft-10,Self.MarginTop+i*70);  {x1, y1}
  end;

  //V  lines
  k:= Trunc((Self.Width-Self.MarginLeft-Self.MarginRight)/70);
  for i:= 1 to k do
  begin
    Fcanvas.MoveTo((Self.MarginLeft-10)+i*70, Self.MarginTop-10);  {x1, y1}
    Fcanvas.LineTo((Self.MarginLeft-10)+i*70, Self.Height); {y1}
  end;
end;

{ TDraftView }

constructor TDraftView.Create(AWidget: TAndroidWidget; Canvas: TCanvas);
begin
  inherited;
  Color := jView(AWidget).BackgroundColor;

  FontColor:= colbrGray;
  BackGroundColor:= clActiveCaption; //clMenuHighlight;

  if jView(AWidget).BackgroundColor = colbrDefault then
    Color := GetParentBackgroundColor;
end;

initialization

  DraftClassesMap := TDraftControlHash.Create(64); // should be power of 2 for efficiency
  RegisterPropertyEditor(TypeInfo(TARGBColorBridge), nil, '', TARGBColorBridgePropertyEditor);
  RegisterPropertyEditor(TypeInfo(jVisualControl), jVisualControl, 'Anchor', TAnchorPropertyEditor);
  RegisterComponentEditor(jForm, TAndroidFormComponentEditor);
  RegisterPropertyEditor(TypeInfo(Integer), jForm, 'Width', TAndroidFormSizeEditor);
  RegisterPropertyEditor(TypeInfo(Integer), jForm, 'Height', TAndroidFormSizeEditor);

  // DraftClasses registeration:
  //  * default drawing and anchoring => use TDraftWidget
  //    (it is not needed to create draft class without custom drawing)
  //  * do not register custom draft class for default drawing w/o anchoring
  //    (default drawing implemented in Mediator.Paint)
  RegisterAndroidWidgetDraftClass(jProgressBar, TDraftProgressBar);
  RegisterAndroidWidgetDraftClass(jSeekBar, TDraftSeekBar);
  RegisterAndroidWidgetDraftClass(jButton, TDraftButton);
  RegisterAndroidWidgetDraftClass(jCheckBox, TDraftCheckBox);
  RegisterAndroidWidgetDraftClass(jRadioButton, TDraftRadioButton);
  RegisterAndroidWidgetDraftClass(jTextView, TDraftTextView);
  RegisterAndroidWidgetDraftClass(jPanel, TDraftPanel);
  RegisterAndroidWidgetDraftClass(jEditText, TDraftEditText);
  RegisterAndroidWidgetDraftClass(jToggleButton, TDraftToggleButton);
  RegisterAndroidWidgetDraftClass(jSwitchButton, TDraftSwitchButton);
  RegisterAndroidWidgetDraftClass(jListView, TDraftListView);
  RegisterAndroidWidgetDraftClass(jGridView, TDraftGridView);
  RegisterAndroidWidgetDraftClass(jImageBtn, TDraftImageBtn);
  RegisterAndroidWidgetDraftClass(jImageView, TDraftImageView);
  RegisterAndroidWidgetDraftClass(jSurfaceView, TDraftSurfaceView);
  RegisterAndroidWidgetDraftClass(jWebView, TDraftWebView);
  RegisterAndroidWidgetDraftClass(jScrollView, TDraftScrollView);
  RegisterAndroidWidgetDraftClass(jHorizontalScrollView, TDraftHorizontalScrollView);
  RegisterAndroidWidgetDraftClass(jRadioGroup, TDraftRadioGroup);
  RegisterAndroidWidgetDraftClass(jRatingBar, TDraftRatingBar);
  RegisterAndroidWidgetDraftClass(jAnalogClock, TDraftAnalogClock);
  RegisterAndroidWidgetDraftClass(jDigitalClock, TDraftDigitalClock);
  RegisterAndroidWidgetDraftClass(jSpinner, TDraftSpinner);
  RegisterAndroidWidgetDraftClass(jView, TDraftView);
  RegisterAndroidWidgetDraftClass(jAutoTextView, TDraftAutoTextView);
  RegisterAndroidWidgetDraftClass(jDrawingView, TDraftDrawingView);

  // TODO :: (default drawing and layout)
  RegisterAndroidWidgetDraftClass(jCanvasES1, TDraftWidget);
  RegisterAndroidWidgetDraftClass(jCanvasES2, TDraftWidget);
  RegisterAndroidWidgetDraftClass(jChronometer, TDraftWidget);

finalization
  DraftClassesMap.Free;
end.

