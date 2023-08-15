; Script generated by the Inno Setup Script Wizard.
; SEE THE DOCUMENTATION FOR DETAILS ON CREATING INNO SETUP SCRIPT FILES!

#define MyAppName "Tero Subtitler"
#define MyAppVersion "1.0.0.8"
#define ShortAppVersion "1008"
#define MyAppPublisher "URUWorks"
#define MyAppURL "https://github.com/URUWorks/TeroSubtitler/releases"
#define MyAppExeName "tero.exe"
#define MyAppAssocName MyAppName + " File"

[Setup]
; NOTE: The value of AppId uniquely identifies this application. Do not use the same AppId value in installers for other applications.
; (To generate a new GUID, click Tools | Generate GUID inside the IDE.)
AppId={{216B2DAF-093C-4C88-9C82-E34CE46580E5}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
;AppVerName={#MyAppName} {#MyAppVersion}
AppPublisher={#MyAppPublisher}
AppPublisherURL={#MyAppURL}
AppSupportURL={#MyAppURL}
AppUpdatesURL={#MyAppURL}
DefaultDirName={autopf}\{#MyAppName}
ChangesAssociations=yes
DefaultGroupName={#MyAppName}
AllowNoIcons=yes
; Uncomment the following line to run in non administrative install mode (install for current user only.)
;PrivilegesRequired=lowest
PrivilegesRequiredOverridesAllowed=dialog
OutputDir={#SourcePath}
ArchitecturesInstallIn64BitMode=x64
OutputBaseFilename=ts{#ShortAppVersion}_win64
SetupIconFile={#SourcePath}\bin\Icons\890.ico
Compression=lzma
SolidCompression=yes
WizardStyle=modern

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"
Name: "bulgarian"; MessagesFile: "compiler:Languages\Bulgarian.isl"
Name: "spanish"; MessagesFile: "compiler:Languages\Spanish.isl"

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked

[Dirs]
Name: "{app}"; Permissions: everyone-full

[Files]
Source: "{#SourcePath}\bin\{#MyAppExeName}"; DestDir: "{app}"; Flags: ignoreversion
Source: "{#SourcePath}\bin\libcrypto-1_1-x64.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "{#SourcePath}\bin\libhunspellx64.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "{#SourcePath}\bin\libmpv-2.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "{#SourcePath}\bin\libssl-1_1-x64.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "{#SourcePath}\bin\tero.cfs"; DestDir: "{app}"; Flags: ignoreversion
Source: "{#SourcePath}\bin\OCR\Default.ocr"; DestDir: "{app}\OCR"; Flags: ignoreversion
Source: "{#SourcePath}\bin\OCR\English.ocr"; DestDir: "{app}\OCR"; Flags: ignoreversion
Source: "{#SourcePath}\bin\OCR\Spanish.ocr"; DestDir: "{app}\OCR"; Flags: ignoreversion
Source: "{#SourcePath}\bin\Languages\en-US.xml"; DestDir: "{app}\Languages"; Flags: ignoreversion
Source: "{#SourcePath}\bin\Languages\es-UY.xml"; DestDir: "{app}\Languages"; Flags: ignoreversion
Source: "{#SourcePath}\bin\Languages\it-IT.xml"; DestDir: "{app}\Languages"; Flags: ignoreversion
Source: "{#SourcePath}\bin\Languages\ru-RU.xml"; DestDir: "{app}\Languages"; Flags: ignoreversion
Source: "{#SourcePath}\bin\Icons\890.ico"; DestDir: "{app}\Icons"; Flags: ignoreversion
Source: "{#SourcePath}\bin\Icons\aqt.ico"; DestDir: "{app}\Icons"; Flags: ignoreversion
Source: "{#SourcePath}\bin\Icons\asc.ico"; DestDir: "{app}\Icons"; Flags: ignoreversion
Source: "{#SourcePath}\bin\Icons\ass.ico"; DestDir: "{app}\Icons"; Flags: ignoreversion
Source: "{#SourcePath}\bin\Icons\dfxp.ico"; DestDir: "{app}\Icons"; Flags: ignoreversion
Source: "{#SourcePath}\bin\Icons\itt.ico"; DestDir: "{app}\Icons"; Flags: ignoreversion
Source: "{#SourcePath}\bin\Icons\sbv.ico"; DestDir: "{app}\Icons"; Flags: ignoreversion
Source: "{#SourcePath}\bin\Icons\srt.ico"; DestDir: "{app}\Icons"; Flags: ignoreversion
Source: "{#SourcePath}\bin\Icons\ssa.ico"; DestDir: "{app}\Icons"; Flags: ignoreversion
Source: "{#SourcePath}\bin\Icons\stl.ico"; DestDir: "{app}\Icons"; Flags: ignoreversion
Source: "{#SourcePath}\bin\Icons\sub.ico"; DestDir: "{app}\Icons"; Flags: ignoreversion
Source: "{#SourcePath}\bin\Icons\vtt.ico"; DestDir: "{app}\Icons"; Flags: ignoreversion
Source: "{#SourcePath}\bin\Icons\xas.ico"; DestDir: "{app}\Icons"; Flags: ignoreversion
Source: "{#SourcePath}\bin\Dictionaries\en_US.aff"; DestDir: "{app}\Dictionaries"; Flags: ignoreversion
Source: "{#SourcePath}\bin\Dictionaries\en_US.dic"; DestDir: "{app}\Dictionaries"; Flags: ignoreversion
Source: "{#SourcePath}\bin\Dictionaries\es_UY.aff"; DestDir: "{app}\Dictionaries"; Flags: ignoreversion
Source: "{#SourcePath}\bin\Dictionaries\es_UY.dic"; DestDir: "{app}\Dictionaries"; Flags: ignoreversion
Source: "{#SourcePath}\bin\Dictionaries\it_IT.aff"; DestDir: "{app}\Dictionaries"; Flags: ignoreversion
Source: "{#SourcePath}\bin\Dictionaries\it_IT.dic"; DestDir: "{app}\Dictionaries"; Flags: ignoreversion
Source: "{#SourcePath}\bin\Dictionaries\ko_KR.aff"; DestDir: "{app}\Dictionaries"; Flags: ignoreversion
Source: "{#SourcePath}\bin\Dictionaries\ko_KR.dic"; DestDir: "{app}\Dictionaries"; Flags: ignoreversion
Source: "{#SourcePath}\bin\Dictionaries\pt_BR.aff"; DestDir: "{app}\Dictionaries"; Flags: ignoreversion
Source: "{#SourcePath}\bin\Dictionaries\pt_BR.dic"; DestDir: "{app}\Dictionaries"; Flags: ignoreversion
Source: "{#SourcePath}\bin\Dictionaries\pt_BR_README.txt"; DestDir: "{app}\Dictionaries"; Flags: ignoreversion
Source: "{#SourcePath}\bin\Dictionaries\pt_PT (pos-AO 1990).aff"; DestDir: "{app}\Dictionaries"; Flags: ignoreversion
Source: "{#SourcePath}\bin\Dictionaries\pt_PT (pos-AO 1990).dic"; DestDir: "{app}\Dictionaries"; Flags: ignoreversion
Source: "{#SourcePath}\bin\Dictionaries\pt_PT (pre-AO 1990).aff"; DestDir: "{app}\Dictionaries"; Flags: ignoreversion
Source: "{#SourcePath}\bin\Dictionaries\pt_PT (pre-AO 1990).dic"; DestDir: "{app}\Dictionaries"; Flags: ignoreversion
Source: "{#SourcePath}\bin\Dictionaries\ru_RU.aff"; DestDir: "{app}\Dictionaries"; Flags: ignoreversion
Source: "{#SourcePath}\bin\Dictionaries\ru_RU.dic"; DestDir: "{app}\Dictionaries"; Flags: ignoreversion
Source: "{#SourcePath}\bin\CustomFormat\DoStudio.cfi"; DestDir: "{app}\CustomFormat"; Flags: ignoreversion
Source: "{#SourcePath}\bin\CustomFormat\HTML Example.cft"; DestDir: "{app}\CustomFormat"; Flags: ignoreversion
Source: "{#SourcePath}\bin\CustomFormat\Sonic Scenarist HDMV Authoring.cfi"; DestDir: "{app}\CustomFormat"; Flags: ignoreversion
; NOTE: Don't use "Flags: ignoreversion" on any shared system files

[Registry]
Root: HKCR; Subkey: ".ass"; ValueData: "{#MyAppName}";  Flags: uninsdeletevalue; ValueType: string;  ValueName: ""
Root: HKCR; Subkey: ".xas"; ValueData: "{#MyAppName}";  Flags: uninsdeletevalue; ValueType: string;  ValueName: ""
Root: HKCR; Subkey: ".aqt"; ValueData: "{#MyAppName}";  Flags: uninsdeletevalue; ValueType: string;  ValueName: ""
Root: HKCR; Subkey: ".890"; ValueData: "{#MyAppName}";  Flags: uninsdeletevalue; ValueType: string;  ValueName: ""
Root: HKCR; Subkey: ".asc"; ValueData: "{#MyAppName}";  Flags: uninsdeletevalue; ValueType: string;  ValueName: ""
Root: HKCR; Subkey: ".cap"; ValueData: "{#MyAppName}";  Flags: uninsdeletevalue; ValueType: string;  ValueName: ""
Root: HKCR; Subkey: ".dks"; ValueData: "{#MyAppName}";  Flags: uninsdeletevalue; ValueType: string;  ValueName: ""
Root: HKCR; Subkey: ".dtc"; ValueData: "{#MyAppName}";  Flags: uninsdeletevalue; ValueType: string;  ValueName: ""
Root: HKCR; Subkey: ".sub"; ValueData: "{#MyAppName}";  Flags: uninsdeletevalue; ValueType: string;  ValueName: ""
Root: HKCR; Subkey: ".stl"; ValueData: "{#MyAppName}";  Flags: uninsdeletevalue; ValueType: string;  ValueName: ""
Root: HKCR; Subkey: ".ttxt"; ValueData: "{#MyAppName}";  Flags: uninsdeletevalue; ValueType: string;  ValueName: ""
Root: HKCR; Subkey: ".itt"; ValueData: "{#MyAppName}";  Flags: uninsdeletevalue; ValueType: string;  ValueName: ""
Root: HKCR; Subkey: ".lrc"; ValueData: "{#MyAppName}";  Flags: uninsdeletevalue; ValueType: string;  ValueName: ""
Root: HKCR; Subkey: ".vkt"; ValueData: "{#MyAppName}";  Flags: uninsdeletevalue; ValueType: string;  ValueName: ""
Root: HKCR; Subkey: ".scr"; ValueData: "{#MyAppName}";  Flags: uninsdeletevalue; ValueType: string;  ValueName: ""
Root: HKCR; Subkey: ".mpl"; ValueData: "{#MyAppName}";  Flags: uninsdeletevalue; ValueType: string;  ValueName: ""
Root: HKCR; Subkey: ".dfxp"; ValueData: "{#MyAppName}";  Flags: uninsdeletevalue; ValueType: string;  ValueName: ""
Root: HKCR; Subkey: ".srt"; ValueData: "{#MyAppName}";  Flags: uninsdeletevalue; ValueType: string;  ValueName: ""
Root: HKCR; Subkey: ".sbv"; ValueData: "{#MyAppName}";  Flags: uninsdeletevalue; ValueType: string;  ValueName: ""
Root: HKCR; Subkey: ".tero"; ValueData: "{#MyAppName}";  Flags: uninsdeletevalue; ValueType: string;  ValueName: ""
Root: HKCR; Subkey: ".vtt"; ValueData: "{#MyAppName}";  Flags: uninsdeletevalue; ValueType: string;  ValueName: ""
Root: HKCR; Subkey: ".webvtt"; ValueData: "{#MyAppName}";  Flags: uninsdeletevalue; ValueType: string;  ValueName: ""

Root: HKCR; Subkey: "{#MyAppName}";                     ValueData: "Program {#MyAppName}";  Flags: uninsdeletekey;   ValueType: string;  ValueName: ""
Root: HKCR; Subkey: "{#MyAppName}\DefaultIcon";             ValueData: "{app}\{#MyAppExeName},0";               ValueType: string;  ValueName: ""
Root: HKCR; Subkey: "{#MyAppName}\shell\open\command";  ValueData: """{app}\{#MyAppExeName}"" ""%1""";  ValueType: string;  ValueName: ""

[Icons]
Name: "{group}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"
Name: "{group}\{cm:ProgramOnTheWeb,{#MyAppName}}"; Filename: "{#MyAppURL}"
Name: "{group}\{cm:UninstallProgram,{#MyAppName}}"; Filename: "{uninstallexe}"
Name: "{autodesktop}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"; Tasks: desktopicon

[Run]
Filename: "{app}\{#MyAppExeName}"; Description: "{cm:LaunchProgram,{#StringChange(MyAppName, '&', '&&')}}"; Flags: nowait postinstall skipifsilent

[UninstallDelete]
Type: files; Name: "{app}\Tero.cfg"
Type: files; Name: "{app}\Tero.mru"
Type: files; Name: "{app}\yt-dlp.exe"
Type: filesandordirs; Name: "{app}\Backup"
Type: filesandordirs; Name: "{app}\ffmpeg"
Type: filesandordirs; Name: "{app}\ShotChanges"
Type: filesandordirs; Name: "{app}\Terminology"
Type: filesandordirs; Name: "{app}\TM"
Type: filesandordirs; Name: "{app}\Waveforms"
Type: filesandordirs; Name: "{app}\Whisper"
Type: filesandordirs; Name: "{app}\Projects"
Type: filesandordirs; Name: "{app}\Tero.act"
Type: filesandordirs; Name: "{app}"