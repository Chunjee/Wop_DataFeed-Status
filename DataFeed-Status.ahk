;/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\
; Description
;\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/
; Renames FreePPs pdf files; then generates html for use with the normal FreePPs process.



;~~~~~~~~~~~~~~~~~~~~~
;Compile Options
;~~~~~~~~~~~~~~~~~~~~~
StartUp()
Version = v0.1

;Dependencies
#Include %A_ScriptDir%\Functions
#Include inireadwrite

;For Debug Only
#Include util_arrays

;/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\
; StartUp
;\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/
Sb_GlobalNameSpace()


The_Settings = %A_ScriptDir%\settings.ini
Fn_InitializeIni(The_Settings)
Fn_LoadIni(The_Settings)






GUI_x := 24
GUI_y1 := 20
GUI_y2 := 36

Loop, Read, %A_ScriptDir%\datafeed_dirs.txt
{
CurrentDir := A_LoopReadLine
	RegExMatch(CurrentDir, "\\\\(.+)\\", RE_Dir)
	If (RE_Dir1 != "")
	{
	The_SystemName := RE_Dir1
	StringUpper, The_SystemName, The_SystemName
	}
	
FormatTime, The_Today, %A_Now%, MM-dd-yyyy

FullPath = %CurrentDir%\%The_Today%\SGRData%The_Today%.txt
AllFiles_Array[A_Index,"Server"] := The_SystemName
AllFiles_Array[A_Index,"FileDir"] := FullPath






;GUI Stuffs
GUI_y1 += 50
GUI_y2 += 50
Gui, Add, GroupBox, x6 y%GUI_y1% w310 h40 , %The_SystemName%
Gui, Add, Text, x16 y%GUI_y2% w40 h20 vGUI_Time%A_Index%,
Gui, Add, Text, x100 y%GUI_y2% w60 h20 vGUI_Size%A_Index%,
}

GUI_Build()


;UnComment to see whats in the array
;Array_Gui(AllFiles_Array)

SetTimer, CheckFiles, -1
Sleep 400

SetTimer, CheckFiles, 30000







CheckFiles:
AllFiles_ArraX := AllFiles_Array.MaxIndex()
Loop, %AllFiles_ArraX%
{

The_Dir := AllFiles_Array[A_Index,"FileDir"]
AllFiles_Array[A_Index,"NewCheck"] := Fn_DataFileInfoTime(The_Dir)
AllFiles_Array[A_Index,"Size"] := Fn_DataFileInfoSize(The_Dir)

guicontrol, Text, GUI_Time%A_Index%, % AllFiles_Array[A_Index,"NewCheck"]
guicontrol, Text, GUI_Size%A_Index%, % AllFiles_Array[A_Index,"Size"]

}
Return





GuiClose:
ExitApp, 1


;/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\
; Functions
;\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/


Fn_CheckDataFile(para_FileDir)
{
global

AllFiles_Array[A_Index,"NewCheck"] := Fn_DataFileInfoTime(para_File)


}


Fn_DataFileInfoTime(para_File)
{
l_FileModified := 
FileGetTime, l_FileModified, %para_File%, M
	If (l_FileModified != "")
	{
	FormatTime, l_FileModified, %l_FileModified%, h:mm
	Return %l_FileModified%
	}
Return "ERROR"
}


Fn_DataFileInfoSize(para_File)
{
l_FileSize :=
FileGetSize, l_FileSize, %para_File%, k
	If (l_FileSize != "")
	{
	Return %l_FileSize%
	}
Return "ERROR"
}


;/--\--/--\--/--\--/--\--/--\
; Subroutines
;\--/--\--/--\--/--\--/--\--/

;No Tray icon because it takes 2 seconds; Do not allow running more then one instance at a time
StartUp() {
#NoTrayIcon
#SingleInstance force
}


Sb_GlobalNameSpace() {
global

AllFiles_Array := {Server:"", FileDir:"", Size:"", NewCheck:"", LastCheck:"", Result:""}
AllFiles_ArraX = 0
}


GUI_Build()
{
global
Gui +AlwaysOnTop
;Title
Gui, Font, s14 w70, Arial
Gui, Add, Text, x2 y4 w330 h40 +Center, Datafeed File Status
Gui, Font, s10 w70, Arial
Gui, Add, Text, x280 y0 w50 h20 +Right, %Version%

Gui, Add, Text, x16 y50 w200 h20, |Modified|------
Gui, Add, Text, x96 y50 w60 h20, |FileSize|

GUI_y2 += 40
Gui, Show, h%GUI_y2% w330, Datafeed File Status
}