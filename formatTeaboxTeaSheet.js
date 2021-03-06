/**
 * Format Teabox Tea Spreadsheets after uploading them to Google Sheets
 * @author Monty Williams
 *
 * For information on how to use this code, see:
 *   https://developers.google.com/apps-script/guides/sheets
 *
 * Change the URL's below to those in your Google Sheets
 *
 */

/* Keep eslint from complaining about classes provided by Google App Script */
/* global SpreadsheetApp Logger */

// eslint-disable-next-line no-unused-vars
function format_Teabox_Teas() {
  var ss = SpreadsheetApp.openByUrl(
    // Dummy URL -- change to your URL on Google Sheets
    'https://docs.google.com/spreadsheets/d/abc1234567/edit'
  );
  var sheet = ss.getSheets()[0];
  var lastRowNum = sheet.getLastRow();
  var lastColumnNum = sheet.getLastColumn();

  // If you move columns around this physical mapping is all you need to change
  // Primary
  var firstColumnNum = 1;
  var teaColumnNum = 2;
  var gramsColumnNum = 3;
  var priceColumnNum = 4;
  var perCupColumnNum = 5;
  var instructionsColumnNum = 6;
  var caffeineColumnNum = 7;
  var appearanceColumnNum = 8;
  var aromaColumnNum = 9;
  var tasteColumnNum = 10;
  var descriptionColumnNum = 11;
  var complementsColumnNum = 12;
  var teaEstateColumnNum = 13;
  // Secondary
  var dryLeafAppearanceColumnNum = 14;
  var dryLeafAromaColumnNum = 15;
  var infusionAppearanceColumnNum = 16;
  var infusionAromaColumnNum = 17;
  var seasonColumnNum = 18;
  var tagsColumnNum = 19;
  var specialtyColumnNum = 20;
  var gradeColumnNum = 21;
  var drinkWithColumnNum = 22;
  var timeofDayColumnNum = 23;
  // Tertiary
  var ouncesColumnNum = 24;
  var cupsColumnNum = 25;
  var steepsColumnNum = 26;
  var bestConsumedColumnNum = 27;
  var pickingDateColumnNum = 28;
  var SKUColumnNum = 29;
  var invoiceColumnNum = 30;

  var dataColumnLength = lastRowNum - 1;
  var column;

  // If you need to change the width or formatting of any column,
  // you can simply move them between the arrays below.
  var resizeColumns = [firstColumnNum, teaColumnNum, gramsColumnNum,
    ouncesColumnNum, cupsColumnNum, priceColumnNum, perCupColumnNum,
    instructionsColumnNum, steepsColumnNum, drinkWithColumnNum,
    tagsColumnNum, pickingDateColumnNum, timeofDayColumnNum, caffeineColumnNum,
    bestConsumedColumnNum, seasonColumnNum, specialtyColumnNum, SKUColumnNum,
    gradeColumnNum, invoiceColumnNum, appearanceColumnNum];
  var centerColumns = [firstColumnNum, gramsColumnNum, ouncesColumnNum,
    cupsColumnNum, perCupColumnNum, instructionsColumnNum, steepsColumnNum,
    pickingDateColumnNum, timeofDayColumnNum, caffeineColumnNum,
    bestConsumedColumnNum, seasonColumnNum, specialtyColumnNum,
    SKUColumnNum, gradeColumnNum, invoiceColumnNum, appearanceColumnNum];
  var fixed200Columns = [aromaColumnNum, complementsColumnNum,
    dryLeafAppearanceColumnNum, dryLeafAromaColumnNum,
    infusionAppearanceColumnNum, infusionAromaColumnNum];
  var fixed300Columns = [descriptionColumnNum, tasteColumnNum];
  var fixed400Columns = [teaEstateColumnNum];

  Logger.log('Formatting spreadsheet: ' + sheet.getName());
  Logger.log('Last row number: ' + lastRowNum);
  Logger.log('Last column number: ' + lastColumnNum);
  Logger.log('Data column length: ' + dataColumnLength);

  // All columns: default to Vertical align top
  sheet.getDataRange().clearFormat().setVerticalAlignment('top');

  // Header Row: Bold, align center
  sheet.getRange(1, 1, 1, lastColumnNum).setFontWeight('bold')
    .setHorizontalAlignment('center');

  // Fixed size 200 and wrap columns
  for (column = 0; column < fixed200Columns.length; column++) {
    sheet.setColumnWidth(fixed200Columns[column], 200);
    sheet.getRange(2, fixed200Columns[column], dataColumnLength)
      .setWrap(true);
  }

  // Fixed size 300 and wrap columns
  for (column = 0; column < fixed300Columns.length; column++) {
    sheet.setColumnWidth(fixed300Columns[column], 300);
    sheet.getRange(2, fixed300Columns[column], dataColumnLength)
      .setWrap(true);
  }

  // Fixed size 400 and wrap columns
  for (column = 0; column < fixed400Columns.length; column++) {
    sheet.setColumnWidth(fixed400Columns[column], 400);
    sheet.getRange(2, fixed400Columns[column], dataColumnLength)
      .setWrap(true);
  }

  // Center columns
  for (column = 0; column < centerColumns.length; column++) {
    sheet.getRange(2, centerColumns[column], dataColumnLength)
      .setHorizontalAlignment('center');
  }

  // Auto resize columns
  for (column = 0; column < resizeColumns.length; column++) {
    sheet.autoResizeColumn(resizeColumns[column]);
  }

  // Tea Column: Wrap text
  // Note: The Tea column may appear unwrapped, even though every cell has its
  // wrap attribute set to true. Clicking on wrap in the GUI shows it correctly.
  // Create a Named Range to make that easier
  ss.setNamedRange('Teas', sheet.getRange(2, teaColumnNum, dataColumnLength)
    .setWrap(true));

  // View freeze: 1 rows, up to Tea column
  sheet.setFrozenRows(1);
  sheet.setFrozenColumns(teaColumnNum);
}
