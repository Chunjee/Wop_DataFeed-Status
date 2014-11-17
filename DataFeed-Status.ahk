;/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\
; Description
;\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/
; Renames FreePPs pdf files; then generates html for use with the normal FreePPs process.



;~~~~~~~~~~~~~~~~~~~~~
;Compile Options
;~~~~~~~~~~~~~~~~~~~~~
StartUp()
Version = v0.11

;Dependencies
#Include %A_ScriptDir%\Functions
#Include inireadwrite
#Include internet_fileread

;For Debug Only
#Include util_arrays
#Include util_misc

;Included Files
Sb_InstallFiles()

;/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\
; StartUp
;\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/

;Check settings.ini. Quit if not found
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
CurrentDir := A_LoopReadLine
	RegExMatch(CurrentDir, "\\\\(.+)\\", RE_Dir)
	If (RE_Dir1 != "")
	{
	The_SystemName := RE_Dir1
	StringUpper, The_SystemName, The_SystemName
	}

AllFiles_Array[A_Index,"Server"] := The_SystemName
AllFiles_Array[A_Index,"NotGrowingCounter"] := 0



;GUI Stuffs
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
Gui, Add, Text, x74 y%GUI_y3% vGUI_RaceResults%A_Index%, 000

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

Gui, Add, Progress, x230 y%GUI_y3% w80 h14 vGUI_TPASTransactionsPerMin%A_Index%, 1 ;Wagers Bar
GUI_y3_5 := GUI_y3 + 16
Gui, Add, Progress, x116 y%GUI_y3% w10 h14 vertical vGUI_TPASTransactions%A_Index%, 1 ;Other very small trasactions bar




GUI_y1 += 42 ;Box
GUI_y2 += 42 ;Text
}

GUI_y1 += 42
GUI_y2 += 40

GUI_y3 := 300
GraphArray := []
Gui, Add, GroupBox, x6 y%GUI_y1% w310 h60 vgui_TrafficGraphBox, Transaction Traffic:

The_GraphMax := 280
Loop %The_GraphMax% {
GUI_y3 += -1
;Random, rand, 40, 100
Gui, Add, Progress, x%GUI_y3% y%GUI_y2% w1 h40 vertical vGUI_Graph%A_Index%, 0
}

GUI_y1 += 10 ;Box
GUI_y2 += 10 ;Text

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


Return



#e::
Array_Gui(TPAS_Array)
Return


CheckTPAS:
Combined_Transactions := 0
Loop % TPAS_Array.MaxIndex()
{
DownloadXML := TPAS_Array[A_Index,"XML"]
;Download file and read to Variable. Note that the text file is all one line so don't try to loop read a line at a time
FileDelete, % A_ScriptDir . "\Data\Temp\" . TPAS_Array[A_Index,"Name"] . "_XML.txt"
UrlDownloadToFile, %DownloadXML% , % A_ScriptDir . "\Data\Temp\" . TPAS_Array[A_Index,"Name"] . "_XML.txt"
FileRead, FileContents_TPASXML, % A_ScriptDir . "\Data\Temp\" . TPAS_Array[A_Index,"Name"] . "_XML.txt"

;Scan for each arrays value and assign
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
guicontrol, Text, GUI_TPASTime%A_Index%, % TPAS_Array[A_Index,"TFATimestamp"]

;Load Bar
	The_LoadPercent := (TPAS_Array[A_Index,"CurrentLoadRate"] / TPAS_Array[A_Index,"maxLoadRate"]) * 100
	TPAS_Array[A_Index,"ProgressMax_Load"] := Fn_PercentCheck(The_LoadPercent)
	The_LoadPercent := Fn_PercentCheck(The_LoadPercent)
	
;Latency Bar
	The_LatencyPercent := (TPAS_Array[A_Index,"avgLatency"] / (TPAS_Array[A_Index,"maxLatency"] * 10)) * 100
	TPAS_Array[A_Index,"ProgressMax_Latency"] := Fn_PercentCheck(The_LatencyPercent)
	
;Transactions Bar (SMALL INVISIBLE)
	The_TransactionsPercent := Floor(TPAS_Array[A_Index,"CurrentTransRate"] / TPAS_Array[A_Index,"MaxTRateSeen"]) *100 ;This thing is still tricky
	TPAS_Array[A_Index,"ProgressMax_TransactionsRAW"] := Fn_PercentCheck(The_TransactionsPercent)
	;Debug_Msg(TPAS_Array[A_Index,"TransQueueLen"])
	
	;Transaction Rate Raw Number
	;Insert Recent Transactions to the Array that remembers the Wagers for this min
	The_RecentTransactions := TPAS_Array[A_Index,"saveTotalTrans"] - TPAS_Array[A_Index,"LastTransactionTotal"]
	TPAS_Array[A_Index,"LastTransactionTotal"] := TPAS_Array[A_Index,"saveTotalTrans"]
	The_WagersPerMin := Fn_InsertWagersPerMin(A_Index, The_RecentTransactions)
	GuiControl, Text, GUI_TransactionNumber%A_Index%, % The_WagersPerMin
	
	;Scale of big transaction bar is determined here
	
		;Assume 400,700,1600 per min is the max unless that is broken; then use the max actually seen
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
	;TPAS_Array[A_Index,"MaxTRateSeen"] := 600

;TransactionsPerMin Bar
	The_TransactionsPerMinPERCENT := (The_WagersPerMin / TPAS_Array[A_Index,"MaxTRateSeen"]) * 100
	TPAS_Array[A_Index,"ProgressMax_WagersPerMin"] := Fn_PercentCheck(The_TransactionsPerMinPERCENT)
	Combined_Transactions += The_TransactionsPerMinPERCENT
}
Combined_Transactions := Fn_PercentCheck(Combined_Transactions)
Fn_InsertGraphPercent(Combined_Transactions,1)
Return



Beat:
Loop % TPAS_Array.MaxIndex()
{
;Load
The_TotalPercent := TPAS_Array[A_Index,"ProgressMax_Load"]
The_ProgressPercent := TPAS_Array[A_Index,"Progress_Load"]
TPAS_Array[A_Index,"Progress_Load"] := Fn_UpdateProgressBar("GUI_TPASLoad",The_TotalPercent,The_ProgressPercent,A_Index,91)

;Latency
The_TotalPercent := TPAS_Array[A_Index,"ProgressMax_Latency"]
The_ProgressPercent := TPAS_Array[A_Index,"Progress_Latency"]
TPAS_Array[A_Index,"Progress_Latency"] := Fn_UpdateProgressBar("GUI_TPASLatency",The_TotalPercent,The_ProgressPercent,A_Index,10)

;Transactions
The_TotalPercent := TPAS_Array[A_Index,"ProgressMax_WagersPerMin"]
The_ProgressPercent := TPAS_Array[A_Index,"Progress_WagersPerMin"]
TPAS_Array[A_Index,"Progress_WagersPerMin"] := Fn_UpdateProgressBar("GUI_TPASTransactionsPerMin",The_TotalPercent,The_ProgressPercent,A_Index,81)

;Very Small Transactions Bar
The_TotalPercent := TPAS_Array[A_Index,"ProgressMax_TransactionsRAW"]
The_ProgressPercent := TPAS_Array[A_Index,"Progress_TransactionsRAW"]
TPAS_Array[A_Index,"Progress_TransactionsRAW"] := Fn_UpdateProgressBar("GUI_TPASTransactions",The_TotalPercent,The_ProgressPercent,A_Index,10)
}
Fn_UpdateGraph()
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


;Now do Race Results
DownloadBOP := TPAS_Array[A_Index,"BOP"]
FileDelete, % A_ScriptDir . "\Data\Temp\" . TPAS_Array[A_Index,"Name"] . "_BOPHTML.txt"
UrlDownloadToFile, %DownloadBOP% , % A_ScriptDir . "\Data\Temp\" . TPAS_Array[A_Index,"Name"] . "_BOPHTML.txt"

REG = NumberOfResultsEvents\">(\d*)<\/span> ;" ;Comment end
FileRead, FileContents_RaceResults, % A_ScriptDir . "\Data\Temp\" . TPAS_Array[A_Index,"Name"] . "_BOPHTML.txt"
TPAS_Array[A_Index,"ResultsNumber"] := Fn_QuickRegEx(FileContents_RaceResults,REG)


guicontrol, Text, GUI_RaceResults%A_Index%, % TPAS_Array[A_Index,"ResultsNumber"]
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

;Get Modified Time and assign it to the Array
AllFiles_Array[A_Index,"NewCheck"] := Fn_DataFileInfoTime(The_Dir)

;Get File Size and assign it to the Array
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
	Sb_FlashGUI() ; Flash the icon if it hasn't grown in this long
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





GuiClose:
ExitApp, 1





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
	If (para_Input <= 1)
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
	If (The_X > The_GraphMax) {
	The_X := 1
	}
	;Loop, % TPAS_Array["GraphData" para_Index].MaxIndex()
CurrentPercent := TPAS_Array["GraphData" 1][The_X]
	;If (CurrentPercent < 10) {
	;CurrentPercent = 10
	;}
;Msgbox, %CurrentPercent%
l_Color := Fn_Percent2Color(CurrentPercent, 70)
GuiControl,+c%l_Color%, GUI_Graph%The_X%, ;Change the color
GuiControl,, GUI_Graph%The_X%, %CurrentPercent% ;Change the progressbar percentage
}
	
;UNUSED
Fn_TPASArrayInsert(para_TPASIndex,para_Readline)
{
global TPAS_Array
;Example Input: <TFATimestamp>08/24/2014 09:17:50</TFATimestamp>
	;Grab what the Tag is
	RegExMatch(para_Readline, "<(\w*)>", RE_Tag)
	If (RE_Tag1 != "")
	{
	l_XMLElement := RE_Tag1
		;Grab Everything within the tag
		RegExMatch(para_Readline, ">(.*)<", RE_Value)
		If (RE_Value1 != "")
		{
		;Put it into the Array. Note that para_TPASIndex is the Index value assigned to each TPAS
		TPAS_Array[para_TPASIndex,l_XMLElement] := RE_Value1
		}
	}
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

;No Tray icon because it takes 2 seconds; Do not allow running more then one instance at a time
StartUp() {
#NoTrayIcon
#SingleInstance force
}


Sb_GlobalNameSpace() {
global

The_FancyName := "Tote Health Monitor"

AllFiles_Array := []
AllFiles_ArraX = 0

TPAS_Array := []
The_X := 0

;Old pointless array format ;TPAS_Array := {Name:"", XML:"", HTML:"", BOP:"", ResultsNumber:"", SessionNumber:"", TFATimestamp:"", LastTFA:"", TotalTransactions:"", MaxTransRate:"", CurrentTransRate:"", TransQueueLen:"", ToteTimestamp:"", LastSeqNo:"", saveTotalTrans:"", maxLoadRate:"", CurrentLoadRate:"", maxLatency:"", avgLatency:"", LastTransactionTotal:"", TransactionsThisMin:""}

;Convert all user settings to miliseconds
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

GUI_AOT := 1
Gui +AlwaysOnTop

;Title
Gui, Font, s14 w70, Arial
Gui, Add, Text, x2 y4 w330 h40 +Center, %The_FancyName%
Gui, Font, s10 w70, Arial
Gui, Add, Text, x276 y0 w50 h20 +Right, %Version%

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
GUI_y2 += 40
Gui, Show, h%GUI_y2% w330, %The_FancyName%
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
gui, submit, NoHide
Return

Menu_File-Restart:
Reload
Menu_File-Exit:
ExitApp
}