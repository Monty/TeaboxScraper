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

/**
 * Structure of a Teabox Pack Spreadsheet
 * # Tea  Price  Description  Discount  Sale_Price  In_Stock
 * 1  2     3         4          5          6          7
 */

// eslint-disable-next-line no-unused-vars
function format_Teabox_Packs() {
  var ss = SpreadsheetApp.openByUrl(
    'https://docs.google.com/spreadsheets/d/abc1234567/edit'
  );
  var sheet = ss.getSheets()[0];
  var lastRowNum = sheet.getLastRow();
  var lastColumnNum = sheet.getLastColumn();
  var teaColumnNum = 2;
  var priceColumnNum = 3;
  var descriptionColumnNum = 4;
  // Make column length adjustments for 'Totals' rows if they exist
  // i.e the bottom Title Row cell contains 'Total ' rather than a link
  var dataColumnLength = lastRowNum - 1;
  var columnNum;
  Logger.log('Formatting spreadsheet: ' + sheet.getName());
  Logger.log('Last row number: ' + lastRowNum);
  Logger.log('Last column number: ' + lastColumnNum);
  Logger.log('Data column length: ' + dataColumnLength);

  // All columns: default to Vertical align top, Horizontal align center
  sheet.getDataRange().clearFormat()
    .setVerticalAlignment('top').setHorizontalAlignment('center');

  // All columns except description column: Resize, Fit to data
  for (columnNum = 1; columnNum < lastColumnNum; columnNum++) {
    if (columnNum != descriptionColumnNum) {
      sheet.autoResizeColumn(columnNum);
    }
  }

  // Tea Column: Horizontal align left, wrap text
  // Note: The Tea column may appear unwrapped, even though every cell has its
  // wrap attribute set to true. Clicking on wrap in the GUI shows it correctly.
  // Create a Named Range to make that easier
  ss.setNamedRange('Teas', sheet.getRange(2, teaColumnNum, dataColumnLength)
    .setHorizontalAlignment('left').setWrap(true));

  // Price Column: Horizontal align right
  sheet.getRange(2, priceColumnNum, dataColumnLength)
    .setHorizontalAlignment('right');

  // Description Column: Resize to 300 pixels, Horizontal align left, wrap text
  sheet.setColumnWidth(descriptionColumnNum, 300);
  sheet.getRange(2, descriptionColumnNum, dataColumnLength)
    .setHorizontalAlignment('left').setWrap(true);

  // Header Row: Bold
  sheet.getRange(1, 1, 1, lastColumnNum).setFontWeight('bold');

  // Pack Row: Vertical align center
  sheet.getRange(2, 1, 1, lastColumnNum).setVerticalAlignment('middle');

  // Pack Link: Bold,Horizontal align center
  sheet.getRange(2, 2, 1, 1).setFontWeight('bold')
    .setHorizontalAlignment('center');

  // View freeze: 2 rows, up to Tea column
  sheet.setFrozenRows(2);
  sheet.setFrozenColumns(teaColumnNum);
}
