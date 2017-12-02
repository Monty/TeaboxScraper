#### To create a .csv spreadsheet of teas in a teabox.com sample pack:

Run **makeTeaboxSpreadsheet.sh [-du]** or **makeSingleTeaSpreadsheet.sh [-d]**  
&nbsp;&nbsp;&nbsp;&nbsp; 
**-d**
&nbsp;&nbsp;&nbsp;&nbsp;
_Debug_ - Create a diffs file that details what changed in each column.  
&nbsp;&nbsp;&nbsp;&nbsp;
**-u**
&nbsp;&nbsp;&nbsp;&nbsp;
_Unsorted_ - Leave teas in the order they are found on the web.

Each script creates a number of .csv and .txt files.  Running the
script again will overwrite any files from earlier that day but not
from any previous day.  Any secondary files are tucked away in the
directory **Teabox-columns**.

The primary spreadsheet files are called **Teabox_Teas-[TEA]-[DATE].csv**
and **Teabox_Pack-[TEA]-[DATE].csv**.  **[DATE]** is today’s date
in the format yymmdd, e.g. 170810. **[TEA]** is the name of the
sample pack or individual tea, e.g. **sample-of-all-muscatel-teas**
or **goomtee-summer-darjeeling-black-tea** These spreadsheets can
be loaded into Open Office or Google Sheets for further formatting.

The prinary text files are **Pack_Note-[TEA]-[DATE].txt** which
only contains Tea | Per Cup price , and **Tea_Note-[TEA]-[DATE].txt**
which contains Tea | Per Cup | Caffeine | Appearance | Aroma | Taste
| Description.

You don't need to keep any .csv files around after loading the
spreadsheet into an application for formatting. Formatted spreadsheets
should get saved as .xls or .ods files. Spreadsheets uploaded to
Google Sheets won't depend on the local file being around.

Teas in the spreadsheet are sorted by name. You can sort them in
the order they are found on the web by using the **-u** switch or
by sorting on the first column.

#### To format the spreadsheets:

Manual formatting is tedious, but you can automate it. Upload your
spreadheets to [Google Sheets](https://docs.google.com/spreadsheets/u/0/),
modify **formatTeaboxTeaSheet.js** or **formatTeaboxPackSheet.js**
to include the URL for your spreadsheet, paste it into a [Google
Apps Script](https://script.google.com) and run it.  *You'll have
to authorize it the first time it's run*. If you ever create new
spreadsheets, you can copy and paste the .csv files into your
existing [Google Sheets](https://docs.google.com/spreadsheets/u/0/)
so the URLs don't change. Then rerun the formatting script.

#### To help debug any problems:

Run one of the primary scripts with the **-d** [_debug]_ option.
This provides diffs of each column individually, which is more
useful for debugging than diffs of the whole spreadsheet. Files
diffed against are in **Teabox-baseline**. Obviously, you have to
run the script at least twice before diffs are generated.

Then examine the diff file called **Teabox_diffs-[TEA]-[LONGDATE].txt**,
where **[LONGDATE]** is the date/time the script was run in the
format yymmdd.HHMMSS, e.g. 170609.161113.
