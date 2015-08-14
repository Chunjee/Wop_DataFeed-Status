<h1 align="center">
	<img src="http://i.imgur.com/cdSmWGL.png" alt="PPS2HTML">
</h1>

### Overview
This program Checks if the SGRDataFeed File is growing or not.

It shows TPAS XML data visually: Session Number, Race Results, Load, Latency, and Transaction Rate.

-TGP: Checked for SGRDataFiles status
-BOP: Checked for number of race results
-TJS: Checked for session number, TFA-Timestamp, load, latency, recent transactions, and transaction rate (still waiting for definition of what this is from Sportech)

| Information | Source / Calculation (x100 for any percentages) |
| ------------- | ----------- |
| Transactions      | (TPAS) Transactions / 1600 or Max seen in last hour |
| Load      | (TPAS) Current Load Rate / Current Load Rate |
| Latency      | (TPAS) Avg Latency / Max Latency


### Example Use
Overnight can use this to see when SGRDatafile first appears, and to gather the Session Number for the day.

Will flash if it ever reaches a 6 mins without the datafile changing size. This would be a strong indication that tote has stopped communicating


### Settings
User settings are saved in ...\Data\config.ini

datafeed_dirs.txt controls which systems are checked. The GUI will resize itself depending on how many systems are listed

TPAS_dirs.txt controls what TPAS systems are monitored

"File>Window Always Top" controls if the GUI will always cover other windows

"File>Update Now" only updates the SGRdatafile status


### Warnings & Troubleshooting
Always assumes todays date; but will fallback on yesterdays date if missing. This has no impact on how it watches TJSs or BOPs
For some reason windows is reporting the modified time of each DataCollector file as the time it was created. Restarting the service fixes this but the service should not be bothered in general.


### Dev Brief
- Check settings.ini. Quit if not found or unable to read
- Create GUI
- Show GUI if all creation was successful
- Check TPAS/TJS
- Download file and read to Variable. Note that the text file is all one line so don't try to loop read a line at a time
- Scan for each value from TPAS/TJS and assign to array for storage
- Calculate each bar and save as target progress bar percentage
- Update GUI every 100milliseconds if (Done to give smooth progress bar movement)
- Paint text red if date on BOP does not match system date
- Get Modified Time form each DataCollector text file and assign it to the Array
- Get File Size and assign it to the Array
- Flash the icon if it hasn't grown in this long


### Technical Details
Latest version is 0.12 (12.20.14)
