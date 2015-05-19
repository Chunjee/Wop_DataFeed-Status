;/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\
; Description
;\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/
; Originally intended to show overnight when the SDL file had arrived. Also shows if said file stops growing.
; Displays TJS and BOP data



;~~~~~~~~~~~~~~~~~~~~~
;Compile Options
;~~~~~~~~~~~~~~~~~~~~~
StartUp()
The_ProjectName := "Tote Health Monitor"
The_VersionName = v0.13

;Dependencies
#Include %A_ScriptDir%\Functions
#Include inireadwrite
#Include class_GDI
#Include util_misc

;For Debug Only
#Include util_arrays


;Included Files
Sb_InstallFiles()


;/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\
; StartUp
;\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/
Sb_RemoteShutDown() ;Allows for remote shutdown

;;Check settings.ini. Quit if not found
		IfExist, %A_ScriptDir%\Data\config.ini
		{
		Path_SettingsFile = %A_ScriptDir%\Data\config.ini
		}
		Else
		{
		Fn_TempMessage("Could not find config file. Quitting in 10 seconds")
		ExitApp, 1
		}
		
Fn_InitializeIni(Path_SettingsFile)
Fn_LoadIni(Path_SettingsFile)
Sb_GlobalNameSpace()


GUI_x := 24
GUI_y1 := 20
GUI_y2 := 36

Loop, Read, %A_ScriptDir%\datafeed_dirs.txt
{
	If (InStr(A_LoopReadLine,";")) {
	Continue
	}
CurrentDir := A_LoopReadLine
	RegExMatch(CurrentDir, "\\\\(.+)\\", RE_Dir)
	If (RE_Dir1 != "")
	{
	The_SystemName := RE_Dir1
	StringUpper, The_SystemName, The_SystemName
	}

AllFiles_Array[A_Index,"Server"] := The_SystemName
AllFiles_Array[A_Index,"NotGrowingCounter"] := 0



;; Create GUI
GUI_y1 += 50 ;Box
GUI_y2 += 50 ;Text
GUI_y3 := GUI_y2 - 3 ;Image
Gui, Add, GroupBox, x6 y%GUI_y1% w310 h40, %The_SystemName%
Gui, Add, Text, x16 y%GUI_y2% w30 h20 vGUI_Time%A_Index%,
Gui, Add, Text, x90 y%GUI_y2% w40 h20 +Right vGUI_OldSize%A_Index%,
Gui, Add, Text, x136 y%GUI_y2% w130 h20 vGUI_Size%A_Index%,
Gui, Add, Picture, x230 y%GUI_y3% vGUI_Image%A_Index%,
}

Loop, Read, %A_ScriptDir%\TPAS_dirs.txt
{
	If (InStr(A_LoopReadLine,";")) {
	Continue
	}
GUI_y1 += 50 ;Box
GUI_y2 += 50 ;Text
GUI_y3 := GUI_y2 + 20

	StringSplit, TPASdata_short, A_LoopReadLine, #,
	The_TPASName := Fn_QuickRegEx(TPASdata_short2,"\/\/(.+):")
	StringUpper, The_TPASName, The_TPASName
	
	TPAS_Array[A_Index,"Name"] := The_TPASName
	TPAS_Array[A_Index,"XML"] := TPASdata_short1
	TPAS_Array[A_Index,"HTML"] := TPASdata_short2
	
	TPAS_Array[A_Index,"BOP"] := "http://" . TPASdata_short3 . "/RaceDayController/Status.aspx"
	
	;Create Array layer for Wagers Per Min
	TPAS_Array["WagersperMin" A_Index] := []
	TPAS_Array["GraphData" A_Index] := []
	
Gui, Font, s14, Arial
Gui, Add, Text, x20 y%GUI_y2% vGUI_TPASTime%A_Index%, 00:00
;Gui, Add, Text, x20 y%GUI_y3% vGUI_TPASSession%A_Index%, 000
Gui, Font, s10, Arial

Gui, Add, GroupBox, x6 y%GUI_y1% w310 h80 vGUI_TPASSession%A_Index%, % "TPAS   " . TPAS_Array[A_Index,"Name"]

Gui, Add, Text, x10 y%GUI_y3% w60 h20 +Right, Results:
Gui, Font, s10 w700, Arial
Gui, Add, Text, x74 y%GUI_y3% vGUI_RaceResults%A_Index%, 000
Gui, Font, s10 w100, Arial

;Load and Latency progress bars
Gui, Add, Text, x146 y%GUI_y2% w80 h20 +Right, Load
Gui, Add, Progress, x230 y%GUI_y2% w80 h14 vGUI_TPASLoad%A_Index%, 1
Gui, Add, Text, x146 y%GUI_y3% w80 h20 +Right, Latency
Gui, Add, Progress, x230 y%GUI_y3% w80 h14 vGUI_TPASLatency%A_Index%, 1
GUI_y3 := GUI_y2 + 40

;Transactions has two progress bars and a textbox
Gui, Add, Text, x120 y%GUI_y3% w80 h20 +Right, Transactions
Gui, Font, s10 w700, Arial
Gui, Add, Text, x202 y%GUI_y3% vGUI_TransactionNumber%A_Index%, 0000
Gui, Font, s10 w100, Arial

;Tote Timestamp
GUI_y3 := GUI_y2 + 40
Gui, Font, s10 w700, Arial
Gui, Add, Text, x22 y%GUI_y3% vGUI_ToteTimestamp%A_Index%, 00/00/0000
Gui, Font, s10 w100, Arial


Gui, Add, Progress, x230 y%GUI_y3% w80 h14 vGUI_TPASTransactionsPerMin%A_Index%, 1 ;Wagers Bar
GUI_y3_5 := GUI_y3 + 16
GUI_y3 += 13
Gui, Add, Progress, x230 y%GUI_y3% w80 h1 vGUI_TPASDataBaseLoads%A_Index%, 1 ;DataBase Loads


GUI_y1 += 42 ;Box
GUI_y2 += 42 ;Text
}

GUI_y1 += 42
GUI_y2 += 44

	If (Options_TrafficMonitor = 1) {
	GUI_y3 := 10
	GraphArray := []
	Gui, Add, GroupBox, x6 y%GUI_y1% w310 h60 vgui_TrafficGraphBox, Transaction Traffic:

	The_GraphMax := 300
		Loop %The_GraphMax% {
		GUI_y3 += 1
		;Random, rand, 60, 100
		Gui, Add, Progress, x%GUI_y3% y%GUI_y2% cgreen w1 h40 vertical vGUI_Graph%A_Index%, %rand%
		}

	GUI_y1 += 10 ;Box
	GUI_y2 += 50 ;Text
	}
	
	If (Options_NeulionMonitor = 9) {
	GUI_y1 += 60	
	GUI_y2 += 30
	Gui, Add, Progress, x30 y%GUI_y1% w260 h14 cgreen vGUI_Neu, 100
	}

	If (Options_ServicesMonitor = 9) {
	Services_Array := []
	;Understand Services to monitor into an array
	Settings.Monitor_Services := 1
	X := 0
		Loop, %A_ScriptDir%\Data\Services\*.txt
		{
		LabelName := 
		LabelName := Fn_QuickRegEx(A_LoopFileName,"(\w+)\.txt")
		;FileRead, File_AllContents, %A_LoopFileFullPath%
			Loop, Read, %A_LoopFileFullPath%
			{
				If (InStr(A_LoopReadLine,"Server_Type:")) {
				ServerType := Fn_QuickRegEx(A_LoopReadLine,"Server_Type:(.+)")
				Continue
				}
				If (InStr(A_LoopReadLine,"Service_Name:")) {
				ServiceName := Fn_QuickRegEx(A_LoopReadLine,"Service_Name:(.+)")
				Continue
				}
				;Insert the ServerName if not already existing
				If (!Fn_InArray(Services_Array,ServerType)) {
				;TempArray := []
				;TempArray["ServerType"] := ServerType
				Services_Array.Insert(ServerType)
				X = alf
				;Services_Array.Insert(ServerType)
				;Services_Array[X] := []
				}
				If (Fn_InArray(Services_Array,ServerType)) {
				;Msbox, % alf
				}
				;Msgbox, %A_Index% %ServerType%  %ServiceName% %A_LoopReadLine%
				Services_Array[ServerType].Insert()
				Services_Array["ServerType","ServiceName"].Insert(A_LoopReadLine)
			}
		}
	;Temp Note: 
	;	TPAS_Array["WagersperMin" para_Index].Insert(para_Transactions)
	;	The_WagersAverage += TPAS_Array["WagersperMin" para_Index][A_Index]
	;TPAS_Array["WagersperMin" A_Index] := []

;View Array
;Array_Gui(Services_Array)
		For index, obj in Services_Array {
		Msgbox, % index . "  " . obj
			For index2, obj2 in obj {
			Msgbox, % index2 . "  " . obj2
			}
		}

		ExitApp
		;GUI_y1 += 50
		Gui, Add, Progress, x10 y%GUI_y1% w305 h200 hWndhWnd ; Progress controls make ideal canvases
		GUI_y2 += 200
	}

;;Show GUI if all creation was successful
GUI_Build()
	
;UnComment to see what is in the array
;Array_Gui(AllFiles_Array)
;Array_Gui(TPAS_Array)

SetTimer, CheckFiles, -1
SetTimer, CheckTPAS, -1
SetTimer, CheckTPASSession, -1
Sleep 200

SetTimer, CheckFiles, %UserOption_CheckDataFiles%
SetTimer, CheckTPASSession, %UserOption_CheckSessionNumber%
SetTimer, CheckTPAS, %UserOption_CheckTPAS%
;SetTimer, CheckTPAS, 100
SetTimer, Beat, 100

global ALF := new CustomButton(hWnd)
ALF.Draw
Return

class CustomButton
{
    __New(hWnd)
    {
        this.GDI := new GDI(hWnd)
        this.hWnd := hWnd
        this.Draw(0x000000)
    }
	Draw(TextColor)
	{
		critical
		this.GDI.FillRectangle(0, 0, this.GDI.CliWidth, this.GDI.CliHeight, 0x008000, TextColor)
		this.GDI.BitBlt()
	}
	
}


#e::
Array_Gui(TPAS_Array)
Return

;;Check TPAS/TJS
CheckTPAS:
Combined_Transactions := 0
Loop % TPAS_Array.MaxIndex() {
DownloadXML := TPAS_Array[A_Index,"XML"]
;;Download file and read to Variable. Note that the text file is all one line so don't try to loop read a line at a time
FileDelete, % A_ScriptDir . "\Data\Temp\" . TPAS_Array[A_Index,"Name"] . "_XML.txt"
UrlDownloadToFile, %DownloadXML% , % A_ScriptDir . "\Data\Temp\" . TPAS_Array[A_Index,"Name"] . "_XML.txt"
FileRead, FileContents_TPASXML, % A_ScriptDir . "\Data\Temp\" . TPAS_Array[A_Index,"Name"] . "_XML.txt"

;;Scan for each value from TPAS/TJS and assign to array for storage
TPAS_Array[A_Index,"Date"] := Fn_QuickRegEx(FileContents_TPASXML,"Timestamp>(\d\d\/\d\d\/\d{4})")
TPAS_Array[A_Index,"TFATimestamp"] := Fn_QuickRegEx(FileContents_TPASXML,"(\d\d:\d\d):\d\d<\/TFATimestamp>")
TPAS_Array[A_Index,"TotalTransactions"] := Fn_QuickRegEx(FileContents_TPASXML,"<TotalTransactions>(.*)<\/TotalTransactions>")
TPAS_Array[A_Index,"MaxTransRate"] := Fn_QuickRegEx(FileContents_TPASXML,"<MaxTransRate>(.*)<\/MaxTransRate>")
TPAS_Array[A_Index,"CurrentTransRate"] := Fn_QuickRegEx(FileContents_TPASXML,"<CurrentTransRate>(.*)<\/CurrentTransRate>")
TPAS_Array[A_Index,"TransQueueLen"] := Fn_QuickRegEx(FileContents_TPASXML,"<TransQueueLen>(.*)<\/TransQueueLen>")
TPAS_Array[A_Index,"ToteTimestamp"] := Fn_QuickRegEx(FileContents_TPASXML,"(\d\d:\d\d):\d\d<\/ToteTimestamp>")
TPAS_Array[A_Index,"LastSeqNo"] := Fn_QuickRegEx(FileContents_TPASXML,"<LastSeqNo>(.*)<\/LastSeqNo>")
TPAS_Array[A_Index,"saveTotalTrans"] := Fn_QuickRegEx(FileContents_TPASXML,"<saveTotalTrans>(.*)<\/saveTotalTrans>")
TPAS_Array[A_Index,"maxLoadRate"] := Fn_QuickRegEx(FileContents_TPASXML,"<maxLoadRate>(.*)<\/maxLoadRate>")
TPAS_Array[A_Index,"CurrentLoadRate"] := Fn_QuickRegEx(FileContents_TPASXML,"<CurrentLoadRate>(.*)<\/CurrentLoadRate>")
TPAS_Array[A_Index,"maxLatency"] := Fn_QuickRegEx(FileContents_TPASXML,"<maxLatency>(.*)<\/maxLatency>")
TPAS_Array[A_Index,"avgLatency"] := Fn_QuickRegEx(FileContents_TPASXML,"<avgLatency>(.*)<\/avgLatency>")

;View Array
;Array_Gui(TPAS_Array)

	If (1) {
	;Color TPAS TimeStamp Red if older than 3 mins.
	FormatTime, Time_Now,,hhmm
	Time_Now := "19990101" . Time_Now . "00"

	Time_TPAS := StrReplace(TPAS_Array[A_Index,"TFATimestamp"],":")
	Time_TPAS := "19990101" . Time_TPAS . "00"

	EnvSub, Time_TPAS, Time_Now, minutes
		If (Time_TPAS > 3) {
		Gui, Font, s14 w1000 cRed, Arial
		} Else {
		Gui, Font, s14 w100 cBlack, Arial
		}

	GuiControl, Font, GUI_TPASTime%A_Index%
	Gui, Font, s10 w100 cBlack, Arial
	}
GuiControl, Text, GUI_TPASTime%A_Index%, % TPAS_Array[A_Index,"TFATimestamp"]


;;Calculate each bar and save as target progress bar percentage
;Load Bar
	The_LoadPercent := (TPAS_Array[A_Index,"CurrentLoadRate"] / TPAS_Array[A_Index,"maxLoadRate"]) * 100
	TPAS_Array[A_Index,"ProgressMax_Load"] := Fn_PercentCheck(The_LoadPercent)
	The_LoadPercent := Fn_PercentCheck(The_LoadPercent)
	
;Latency Bar
	The_LatencyPercent := (TPAS_Array[A_Index,"avgLatency"] / (TPAS_Array[A_Index,"maxLatency"] * 10)) * 100
	TPAS_Array[A_Index,"ProgressMax_Latency"] := Fn_PercentCheck(The_LatencyPercent)
	
						;Transactions Bar (SMALL INVISIBLE) - DEPRECIATED
						;	The_TransactionsPercent := Floor(TPAS_Array[A_Index,"CurrentTransRate"] / TPAS_Array[A_Index,"MaxTRateSeen"]) *100
						;	TPAS_Array[A_Index,"ProgressMax_TransactionsRAW"] := Fn_PercentCheck(The_TransactionsPercent)
						;	;Debug_Msg(TPAS_Array[A_Index,"TransQueueLen"])
	
	;Transaction Rate Raw Number
	;Insert Recent Transactions to the Array that remembers the Wagers for this min
	The_RecentTransactions := TPAS_Array[A_Index,"TotalTransactions"] - TPAS_Array[A_Index,"LastTransactionTotal"]
	TPAS_Array[A_Index,"LastTransactionTotal"] := TPAS_Array[A_Index,"TotalTransactions"]
	The_WagersPerMin := Fn_InsertWagersPerMin(A_Index, The_RecentTransactions)
	GuiControl, Text, GUI_TransactionNumber%A_Index%, % The_WagersPerMin
	
	;DataBaseLoads
	The_RecentDataBaseLoads := TPAS_Array[A_Index,"saveTotalTrans"] - TPAS_Array[A_Index,"LastDataBaseLoad"]
	TPAS_Array[A_Index,"LastDataBaseLoad"] := TPAS_Array[A_Index,"saveTotalTrans"]
	TPAS_Array[A_Index,"ProgressMax_DataBaseLoad"] := The_RecentDataBaseLoads
	
	;For Graph data
	Combined_Transactions += The_WagersPerMin
	
	
		
		;Assume 900,1600,2400 per min is the max unless that is passed; then use the max actually seen. Also only do one 1st TJS (Ignore NJ, others)
		If (A_Index = 1) {
			If (The_WagersPerMin > TPAS_Array[A_Index,"MaxTRateSeen"] || The_WagersPerMin > 3333) {
			TPAS_Array[A_Index,"MaxTRateSeen"] := The_WagersPerMin
			GuiControl, Text, gui_TrafficGraphBox, Transaction Traffic: Super High
			}
			If (The_WagersPerMin < 2400 && The_WagersPerMin > 1600) {
			TPAS_Array[A_Index,"MaxTRateSeen"] := 2400
			GuiControl, Text, gui_TrafficGraphBox, Transaction Traffic: High
			}
			If (The_WagersPerMin < 1600 && The_WagersPerMin > 900) {
			TPAS_Array[A_Index,"MaxTRateSeen"] := 1600
			GuiControl, Text, gui_TrafficGraphBox, Transaction Traffic: Medium
			}
			If (The_WagersPerMin < 900) {
			TPAS_Array[A_Index,"MaxTRateSeen"] := 900
			GuiControl, Text, gui_TrafficGraphBox, Transaction Traffic: Low
			}
		}

;TransactionsPerMin Bar
	The_TransactionsPerMinPERCENT := (The_WagersPerMin / 5000) * 100
	TPAS_Array[A_Index,"ProgressMax_WagersPerMin"] := Fn_PercentCheck(The_TransactionsPerMinPERCENT)
}

;Find the Max Rate
	If (Options_TrafficMonitor = 1) {
	Fn_InsertGraphPercent(Combined_Transactions,1)
		;;Find biggest transaction rate found in graph data
		Loop, % TPAS_Array.GraphData1.MaxIndex() {
			If (TPAS_Array["GraphData" 1][A_Index] > GraphData_MaxFound) {
			GraphData_MaxFound := TPAS_Array["GraphData" 1][A_Index]
			}
		}
		GraphData_MaxValue := GraphData_MaxFound * 2
	}

If (WatchNuelion = 1) {
	;Download Neulion Data every blah blah and check for valid
	DownloadNeu = https://www.tvg.com/ajax/video/id/live-schedule
	FileDelete, % A_ScriptDir . "\Data\Temp\Neu.txt"
	UrlDownloadToFile, %DownloadNeu% , % A_ScriptDir . "\Data\Temp\Neu.txt"
	FileRead, FileContents_Neu, % A_ScriptDir . "\Data\Temp\Neu.txt"
	If (Fn_QuickRegEx(FileContents_Neu,"(\[\])") != "null") {
	GuiControl,+cgreen, GUI_Neu, ;Change the color
	} Else {
	GuiControl,+cred, GUI_Neu, ;Change the color
	}
}
Return


GuiControl,, GUI_Graph%The_X%, %l_CurrentPercent% ;Change the progressbar percentage








Beat:
;;Update GUI every 100milliseconds if (Done to give smooth progress bar movement) 
Loop % TPAS_Array.MaxIndex()
{
;Load
The_TotalPercent := TPAS_Array[A_Index,"ProgressMax_Load"]
The_ProgressPercent := TPAS_Array[A_Index,"Progress_Load"]
TPAS_Array[A_Index,"Progress_Load"] := Fn_UpdateProgressBar("GUI_TPASLoad",The_TotalPercent,The_ProgressPercent,A_Index,95) ;Formerly 91

;Latency
The_TotalPercent := TPAS_Array[A_Index,"ProgressMax_Latency"]
The_ProgressPercent := TPAS_Array[A_Index,"Progress_Latency"]
TPAS_Array[A_Index,"Progress_Latency"] := Fn_UpdateProgressBar("GUI_TPASLatency",The_TotalPercent,The_ProgressPercent,A_Index,10) ;This is low because it never moves

;Transactions
The_TotalPercent := TPAS_Array[A_Index,"ProgressMax_WagersPerMin"]
The_ProgressPercent := TPAS_Array[A_Index,"Progress_WagersPerMin"]
TPAS_Array[A_Index,"Progress_WagersPerMin"] := Fn_UpdateProgressBar("GUI_TPASTransactionsPerMin",The_TotalPercent,The_ProgressPercent,A_Index,95) ;Formerly 81

;DataBase Load
The_TotalPercent := TPAS_Array[A_Index,"ProgressMax_WagersPerMin"]
The_ProgressPercent := TPAS_Array[A_Index,"Progress_WagersPerMin"]
TPAS_Array[A_Index,"Progress_DataBaseLoad"] := Fn_UpdateProgressBar("GUI_TPASDataBaseLoads",The_TotalPercent,The_ProgressPercent,A_Index,95) ;Formerly 81

;Very Small Transactions Bar - DEPRECIATED
;The_TotalPercent := TPAS_Array[A_Index,"ProgressMax_TransactionsRAW"]
;The_ProgressPercent := TPAS_Array[A_Index,"Progress_TransactionsRAW"]
;TPAS_Array[A_Index,"Progress_TransactionsRAW"] := Fn_UpdateProgressBar("GUI_TPASTransactions",The_TotalPercent,The_ProgressPercent,A_Index,10)
}
	If (Options_TrafficMonitor = 1) {
	Fn_UpdateGraph()
	}
Return



;Session Number STUFF. Also do Race Results
CheckTPASSession:
Loop % TPAS_Array.MaxIndex()
{
DownloadHTML := TPAS_Array[A_Index,"HTML"]

FileDelete, % A_ScriptDir . "\Data\Temp\" . TPAS_Array[A_Index,"Name"] . "_HTML.txt"
UrlDownloadToFile, %DownloadHTML% , % A_ScriptDir . "\Data\Temp\" . TPAS_Array[A_Index,"Name"] . "_HTML.txt"
FileRead, FileContents_TPASSession, % A_ScriptDir . "\Data\Temp\" . TPAS_Array[A_Index,"Name"] . "_HTML.txt"

TPAS_Array[A_Index,"SessionNumber"] := Fn_QuickRegEx(FileContents_TPASSession,"SESSION # \[ (\d*) \]")
guicontrol, Text, GUI_TPASSession%A_Index%, % TPAS_Array[A_Index,"Name"] . "      #" . TPAS_Array[A_Index,"SessionNumber"]


;Download BOP RaceDayEventCollector page and collect number of results and date
DownloadBOP := TPAS_Array[A_Index,"BOP"]

FileDelete, % A_ScriptDir . "\Data\Temp\" . TPAS_Array[A_Index,"Name"] . "_BOPHTML.txt"
UrlDownloadToFile, %DownloadBOP% , % A_ScriptDir . "\Data\Temp\" . TPAS_Array[A_Index,"Name"] . "_BOPHTML.txt"
FileRead, FileContents_RaceResults, % A_ScriptDir . "\Data\Temp\" . TPAS_Array[A_Index,"Name"] . "_BOPHTML.txt"

REG = NumberOfResultsEvents\">(\d*)<\/span> ;" ;Comment end
TPAS_Array[A_Index,"ResultsNumber"] := Fn_QuickRegEx(FileContents_RaceResults,REG)
}

;GUI Updating is handled on a 2nd loop because downloading the file causes a lag or something
Loop % TPAS_Array.MaxIndex()
{
	;Race results Red if "null"
	If (TPAS_Array[A_Index,"ResultsNumber"] = "null") {
	Gui, Font, s10 w700 cRed, Arial
	} Else {
	Gui, Font, s10 w700 cBlack, Arial
	}
GuiControl, Text, GUI_RaceResults%A_Index%, % TPAS_Array[A_Index,"ResultsNumber"]
GuiControl, Font, GUI_RaceResults%A_Index%
Gui, Font, s10 w100 cBlack, Arial

;Date Stamp
FormatTime, SystemDate, A_Now, MM/dd/yyyy
	;;Paint text red if date on BOP does not match system date
	If (SystemDate != TPAS_Array[A_Index,"Date"]) {
	Gui, Font, s10 w1000 cRed, Arial
	} Else {
	Gui, Font, s10 w100 cBlack, Arial
	}
GuiControl, Text, GUI_ToteTimestamp%A_Index%, % TPAS_Array[A_Index,"Date"]
GuiControl, Font, GUI_ToteTimestamp%A_Index%
Gui, Font, s10 w100 cBlack, Arial
}
Return



CheckFiles:
;Loop for each system in the array
AllFiles_ArraX := AllFiles_Array.MaxIndex()
Loop % AllFiles_Array.MaxIndex()
{
;Update Todays Variable to check todays datafile
Sb_UpdatePath()


The_Dir := AllFiles_Array[A_Index,"FileDir"]

;;Get Modified Time form each DataCollector text file and assign it to the Array
AllFiles_Array[A_Index,"NewCheck"] := Fn_DataFileInfoTime(The_Dir)

;;Get File Size and assign it to the Array
AllFiles_Array[A_Index,"Size"] := Fn_DataFileInfoSize(The_Dir)

	;Convert to MB for display GUI
	GUI_FileSizeMB := AllFiles_Array[A_Index,"Size"] / 1024
	StringTrimRight, GUI_FileSizeMB, GUI_FileSizeMB, 7

guicontrol, Text, GUI_Time%A_Index%, % AllFiles_Array[A_Index,"NewCheck"]
guicontrol, Text, GUI_Size%A_Index%, % AllFiles_Array[A_Index,"Size"] . "  (" . GUI_FileSizeMB . "MB)"


	;If the Filesize is the same as last time it was checked
	If (AllFiles_Array[A_Index,"LastCheck"] = AllFiles_Array[A_Index,"Size"])
	{
	;Then increment the Counter for not growing
	AllFiles_Array[A_Index,"NotGrowingCounter"] += 1
	}
	Else ;It is growing, Reset Counter to zero
	{
	AllFiles_Array[A_Index,"NotGrowingCounter"] := 0
	}


	;Set the color of the GUI picture
	If (AllFiles_Array[A_Index,"NotGrowingCounter"] = 0) ;Green
	{
	ChosenImage := 0
	}
	If (AllFiles_Array[A_Index,"NotGrowingCounter"] = 1) ;Yellow
	{
	ChosenImage := 1
		If(AllFiles_Array[A_Index,"TodaysFile"] = False) { ;Only Yesterdays file exists? Special Icon
		ChosenImage := 99
		}
	}
	If (AllFiles_Array[A_Index,"NotGrowingCounter"] = 2) ;Orange
	{
	ChosenImage := 2
	Sb_FlashGUI() ;; Flash the icon if it hasn't grown in this long
	Sb_EmailOps() ; An Empty function
	}
	If (AllFiles_Array[A_Index,"NotGrowingCounter"] >= 3) ;Red
	{
	ChosenImage := 3
	Sb_FlashGUI() ; Flash the icon if it hasn't grown in this long
	}
	

GuiControl,, GUI_Image%A_Index%, %A_ScriptDir%\Data\%ChosenImage%.png

AllFiles_Array[A_Index,"LastCheck"] := AllFiles_Array[A_Index,"Size"]
}
;UnComment to see whats in the array
;Array_Gui(AllFiles_Array)
Return



;/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\
; Functions
;\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/


Fn_UpdateProgressBar(para_ProgressBarVar,para_Max,para_Current,para_Index,para_ColorThreshold)
{
	If (para_Current = para_Max)
	{
	Return %para_Current%
	}

	If (para_Max > para_Current)
	{
	para_Current += 1
	}
	If (para_Max < para_Current)
	{
	para_Current += -1
	}

l_Color := Fn_Percent2Color(para_Current, para_ColorThreshold)
GuiControl,+c%l_Color%, %para_ProgressBarVar%%para_Index%, ;Change the color
GuiControl,, %para_ProgressBarVar%%para_Index%, %para_Current% ;Change the progressbar percentage

Return %para_Current%
}


Fn_PercentCheck(para_Input)
{
;Checks to ensure that the input var is not under 1 or over 100, essentially for percentages
para_Input := Ceil(para_Input)
	If (para_Input >= 100)
	{
	Return 100
	}
	If (para_Input <= 0)
	{
	Return 1
	}
Return %para_Input%
}


Fn_Percent2Color(para_InputNumber,para_ThresholdPercent)
{
;Returns a color code for progress bar percentages. Kinda reverse order because otherwise it will return the first encountered Return

	If (para_InputNumber <= para_ThresholdPercent) ;Green
	{
	Return "22b14c"
	}
	If (para_InputNumber > para_ThresholdPercent + 20) ;Red
	{
	Return "ed1c24"
	}
		If (para_InputNumber > para_ThresholdPercent + 18) {
		Return "ff3627"
		}
		If (para_InputNumber > para_ThresholdPercent + 18) {
		Return "ff3b27"
		}
		If (para_InputNumber > para_ThresholdPercent + 18) {
		Return "ff4027"
		}
		If (para_InputNumber > para_ThresholdPercent + 17) {
		Return "ff5027"
		}
		If (para_InputNumber > para_ThresholdPercent + 16) {
		Return "ff5f27"
		}
		If (para_InputNumber > para_ThresholdPercent + 15) {
		Return "ff6427"
		}
		If (para_InputNumber > para_ThresholdPercent + 14) {
		Return "ff6927"
		}
		If (para_InputNumber > para_ThresholdPercent + 13) {
		Return "ff6e27"
		}
		If (para_InputNumber > para_ThresholdPercent + 12) {
		Return "ff7327"
		}
		If (para_InputNumber > para_ThresholdPercent + 11) {
		Return "ff7827"
		}
	If (para_InputNumber > para_ThresholdPercent + 10) ;Orange
	{
	Return "ff7f27"
	}
		If (para_InputNumber > para_ThresholdPercent + 9) {
		Return "ff8827"
		}
		If (para_InputNumber > para_ThresholdPercent + 8) {
		Return "ff9727"
		}
		If (para_InputNumber > para_ThresholdPercent + 7) {
		Return "ffa127"
		}
		If (para_InputNumber > para_ThresholdPercent + 6) {
		Return "ffab27"
		}
		If (para_InputNumber > para_ThresholdPercent + 5) {
		Return "ffb027"
		}
		If (para_InputNumber > para_ThresholdPercent + 4) {
		Return "ffbf27"
		}
		If (para_InputNumber > para_ThresholdPercent + 3) {
		Return "ffbc04"
		}
		If (para_InputNumber > para_ThresholdPercent + 2) {
		Return "ffbe03"
		}
		If (para_InputNumber > para_ThresholdPercent + 1) {
		Return "ffc002"
		}
	If (para_InputNumber > para_ThresholdPercent) ;Yellow
	{
	Return "ffc300"
	}
		If (para_InputNumber > para_ThresholdPercent - 1) {
		Return "cabf12"
		}
		If (para_InputNumber > para_ThresholdPercent - 2) {
		Return "99bb23"
		}
		If (para_InputNumber > para_ThresholdPercent - 3) {
		Return "6db732"
		}
	
Return ERROR
}


Fn_Percent2ColorLight(para_InputNumber,para_ThresholdPercent)
{
;Same as the other function but has lighter colors

	If (para_InputNumber <= para_ThresholdPercent) ;Green
	{
	Return "a3edb9"
	}
	If (para_InputNumber > para_ThresholdPercent + 20) ;Red
	{
	Return "f7999d"
	}
	If (para_InputNumber > para_ThresholdPercent + 10) ;Orange
	{
	Return "ffbd91"
	}
	If (para_InputNumber > para_ThresholdPercent) ;Yellow
	{
	Return "fff991"
	}
	
Return ERROR
}


Fn_ConvertSecondstoMili(para_Seconds)
{
	RegExMatch(para_Seconds, "(\d+)", RE_Match)
	If (RE_Match1 != "")
	{
	Return % RE_Match1 * 1000
	}
Return
}


Fn_InsertWagersPerMin(para_Index, para_Transactions)
{
;Also returns average current wagers for this index value
global

The_MinAverage := 60 / (UserOption_CheckTPAS / 1000)
	If (TPAS_Array["WagersperMin" para_Index].MaxIndex() >= The_MinAverage)
	{
	TPAS_Array["WagersperMin" para_Index].Remove(1)
	}
TPAS_Array["WagersperMin" para_Index].Insert(para_Transactions)

The_WagersAverage := 0
	Loop, % TPAS_Array["WagersperMin" para_Index].MaxIndex()
	{
	The_WagersAverage += TPAS_Array["WagersperMin" para_Index][A_Index]
	}
	;The_WagersAverage := Floor(The_WagersAverage / The_MinAverage)
	Return %The_WagersAverage%
}


Fn_InsertGraphPercent(para_Percent,para_Index)
{
global
;TPAS_Array["GraphData" A_Index] := []
	
	If (TPAS_Array["GraphData" para_Index].MaxIndex() >= The_GraphMax)
	{
	TPAS_Array["GraphData" para_Index].Remove(1)
	}
TPAS_Array["GraphData" para_Index].Insert(para_Percent)
}

Fn_UpdateGraph()
{
global
The_X++
		
	;If The_X has gone beyond the scope of the whole graph; go back to the start
	If (The_X > The_GraphMax) {
	The_X := 1
	}
	
;The_X gone past all relevant data in the graph array; go back to the start
l_CurrentPercent := ((TPAS_Array["GraphData" 1][The_X] / GraphData_MaxValue) * 100)
l_CurrentPercent := Fn_PercentCheck(l_CurrentPercent)
	If (l_CurrentPercent = "") {
	The_X := 1
	Return
	}
	If (l_CurrentPercent = 0) {
	Return
	}

l_Color := Fn_Percent2Color(l_CurrentPercent, 70)
GuiControl,+c%l_Color%, GUI_Graph%The_X%, ;Change the color
GuiControl,, GUI_Graph%The_X%, %l_CurrentPercent% ;Change the progressbar percentage
}

;Fn_CheckDataFile(para_FileDir)
;{
;global
;
;AllFiles_Array[A_Index,"NewCheck"] := Fn_DataFileInfoTime(para_FileDir)
;}


Fn_DataFileInfoTime(para_File)
{
l_FileModified := 

	;Do normal filesize checking if the file exists
	IfExist, %para_File%
	{
	FileGetTime, l_FileModified, %para_File%, M
		If (l_FileModified != "")
		{
		FormatTime, l_FileModified, %l_FileModified%, h:mm
		Return %l_FileModified%
		}
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

Fn_TempMessage(Message, Timeout = 10)
{
MsgBox, 48,, %Message%, %Timeout%
}


;/--\--/--\--/--\--/--\--/--\
; Subroutines
;\--/--\--/--\--/--\--/--\--/

StartUp() {
SetBatchLines -1 ;Go as fast as CPU will allow
#NoTrayIcon ;No tray icon
#SingleInstance Force ;Do not allow running more then one instance at a time
}


Sb_GlobalNameSpace() {
global

AllFiles_Array := []
AllFiles_ArraX = 0

TPAS_Array := []
The_X := 0

;Convert all user settings to milliseconds
UserOption_CheckTPAS := Fn_ConvertSecondstoMili(Options_CheckTPAS)
UserOption_CheckDataFiles := Fn_ConvertSecondstoMili(Options_CheckDataFiles)
UserOption_CheckSessionNumber := Fn_ConvertSecondstoMili(Options_CheckSessionNumber)
}


Sb_InstallFiles()
{
FileCreateDir, %A_ScriptDir%\Data\Temp\
FileInstall, Data\0.png, %A_ScriptDir%\Data\0.png, 1
FileInstall, Data\1.png, %A_ScriptDir%\Data\1.png, 1
FileInstall, Data\2.png, %A_ScriptDir%\Data\2.png, 1
FileInstall, Data\3.png, %A_ScriptDir%\Data\3.png, 1
FileInstall, Data\99.png, %A_ScriptDir%\Data\99.png, 1
}

Sb_EmailOps()
{
;Currently Does nothing
}

Sb_UpdatePath()
{
global

The_Yesterday := A_Now
The_Yesterday += -1, d
FormatTime, The_Today, %A_Now%, MM-dd-yyyy
FormatTime, The_Yesterday, %A_Now%, MM-dd-yyyy

	Loop % AllFiles_Array.MaxIndex()
	{
	The_Server := AllFiles_Array[A_Index,"Server"]
	FullPath = \\%The_Server%\LogFiles\%The_Today%\SGRData%The_Today%.txt
	AllFiles_Array[A_Index,"TodaysFile"] := True
		If (!FileExist(FullPath))
		{
		FullPath = \\%The_Server%\LogFiles\%The_Yesterday%\SGRData%The_Yesterday%.txt
		AllFiles_Array[A_Index,"TodaysFile"] := False
		}
	AllFiles_Array[A_Index,"FileDir"] := FullPath
	AllFiles_Array[A_Index,"Date_Today"] := The_Today
	AllFiles_Array[A_Index,"Date_Yesterday"] := The_Yesterday
	}

}


Sb_FlashGUI()
{
SetTimer, FlashGUI, -1000
Return
FlashGUI:

	Loop, 6
	{
	Gui Flash
	Sleep 500  ;Do not change this value
	}
Return
}

GUI_Build()
{
global

;GUI Always on top variable
GUI_AOT := 1
Gui +AlwaysOnTop

;Title
Gui, Font, s14 w70, Arial
Gui, Add, Text, x2 y4 w330 h40 +Center, %The_ProjectName%
Gui, Font, s10 w70, Arial
Gui, Add, Text, x276 y0 w50 h20 +Right, %The_VersionName%

;Gui, Add, CheckBox, x30 y30 Checked1 gSwitchOnOff, Always On Top

;Gui, Add, Text, x10 y50, |-Modified-|
;Gui, Add, Text, x96 y50, |-FileSize-|
Gui, Add, Text, x230 y50, |-----Status-----|


;Menu
Menu, FileMenu, Add, &Update Now, CheckFiles
Menu, FileMenu, Add, Window &Always Top, SwitchOnOff
Menu, FileMenu, Add, R&estart`tCtrl+R, Menu_File-Restart
Menu, FileMenu, Add, E&xit`tCtrl+Q, Menu_File-Exit
Menu, MyMenuBar, Add, &File, :FileMenu  ; Attach the sub-menu that was created above
Menu, FileMenu, Check, Window &Always Top
;Menu, Default , FileMenu

Menu, HelpMenu, Add, &About, Menu_About
Menu, HelpMenu, Add, &Confluence`tCtrl+H, Menu_Confluence
Menu, MyMenuBar, Add, &Help, :HelpMenu
Gui, Menu, MyMenuBar

;Create the final size of the GUI
Gui, Show, h%GUI_y2% w330, %The_ProjectName%
Return

;Menu Shortcuts
Menu_Confluence:
Run http://confluence.tvg.com/display/wog/Ops+Tool+-+Tote+Health+Monitor
Return

Menu_About:
Msgbox, Checks that the SGRDataFeed file is growing or exists yet.
Return

SwitchOnOff:
If (GUI_AOT = 0)
{
Gui +AlwaysOnTop
GUI_AOT := 1
Menu, FileMenu, Check, Window &Always Top
}
else
{
Gui -AlwaysOnTop
GUI_AOT := 0
Menu, FileMenu, UnCheck, Window &Always Top
}
Gui, submit, NoHide
Return

Menu_File-Restart:
Reload
Menu_File-Exit:
ExitApp
GuiClose:
ExitApp, 1
}
