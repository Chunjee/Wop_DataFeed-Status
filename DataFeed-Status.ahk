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

;Included Files
Sb_InstallFiles()

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

AllFiles_Array[A_Index,"NotGrowingCounter"] := 0






;GUI Stuffs
GUI_y1 += 50 ;Box
GUI_y2 += 50 ;Text
GUI_y3 := GUI_y2 - 3 ;Image
Gui, Add, GroupBox, x6 y%GUI_y1% w310 h40 , %The_SystemName%
Gui, Add, Text, x16 y%GUI_y2% w40 h20 vGUI_Time%A_Index%,
Gui, Add, Text, x100 y%GUI_y2% w60 h20 vGUI_Size%A_Index%,
Gui, Add, Picture, x230 y%GUI_y3% vGUI_Image%A_Index%, %A_ScriptDir%\Data\alf.png
}

GUI_Build()


;UnComment to see whats in the array
;Array_Gui(AllFiles_Array)

SetTimer, CheckFiles, -1
Sleep 400

SetTimer, CheckFiles, 90000
Return





CheckFiles:
AllFiles_ArraX := AllFiles_Array.MaxIndex()
Loop, %AllFiles_ArraX%
{

The_Dir := AllFiles_Array[A_Index,"FileDir"]
AllFiles_Array[A_Index,"NewCheck"] := Fn_DataFileInfoTime(The_Dir)
AllFiles_Array[A_Index,"Size"] := Fn_DataFileInfoSize(The_Dir)

guicontrol, Text, GUI_Time%A_Index%, % AllFiles_Array[A_Index,"NewCheck"]
guicontrol, Text, GUI_Size%A_Index%, % AllFiles_Array[A_Index,"Size"]


	If (AllFiles_Array[A_Index,"LastCheck"] = AllFiles_Array[A_Index,"Size"])
	{
	AllFiles_Array[A_Index,"NotGrowingCounter"] += 1
	}
	Else
	{
	AllFiles_Array[A_Index,"NotGrowingCounter"] := 0
	}
	;MSgbox % AllFiles_Array[A_Index,"NotGrowingCounter"]
	
	If (AllFiles_Array[A_Index,"NotGrowingCounter"] = 0) ;Green
	{
	ChosenImage := 0
	}
	If (AllFiles_Array[A_Index,"NotGrowingCounter"] = 1) ;Yellow
	{
	ChosenImage := 1
	}
	If (AllFiles_Array[A_Index,"NotGrowingCounter"] = 2) ;Orange
	{
	ChosenImage := 2
	}
	If (AllFiles_Array[A_Index,"NotGrowingCounter"] >= 3) ;Red
	{
	;Msgbox % A_Index . "  ------    " . AllFiles_Array[A_Index,"NotGrowingCounter"]
	ChosenImage := 3
	}


GuiControl,, GUI_Image%A_Index%, %A_ScriptDir%\Data\%ChosenImage%.png

AllFiles_Array[A_Index,"LastCheck"] := AllFiles_Array[A_Index,"Size"]
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
l_FileSize := ;MakeThis Variable Empty

;Check the size of the file specified in the Function argument/option
FileGetSize, l_FileSize, %para_File%, k

	;If the filesize is NOT blank
	If (l_FileSize != "")
	{
	;Exit the Function with the value of the filesize
	Return %l_FileSize%
	}
;filesize was blank or not understood. Return the word "ERROR"
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

AllFiles_Array := {Server:"", FileDir:"", Size:"", NewCheck:"", LastCheck:"", NotGrowingCounter: "", Result:""}
AllFiles_ArraX = 0
}


Sb_InstallFiles()
{
FileInstall, Data\0.png, %A_ScriptDir%\Data\0.png, 1
FileInstall, Data\1.png, %A_ScriptDir%\Data\1.png, 1
FileInstall, Data\2.png, %A_ScriptDir%\Data\2.png, 1
FileInstall, Data\3.png, %A_ScriptDir%\Data\3.png, 1
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