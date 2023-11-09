function main(workbook: ExcelScript.Workbook) {

  let tempSheet = workbook.getWorksheet("test");    //temporary sheet to hold all our data
  let analystSheets: Array<string> = getAnalystSheets(workbook);

  analystSheets.forEach(sheet => {
    copyDocsToTempSheet(workbook.getWorksheet(sheet), tempSheet);
  });

}

/**
 * Copy the docs 
 * 
 */
function copyDocsToTempSheet(source: ExcelScript.Worksheet, tempSheet: ExcelScript.Worksheet) {
  let startRow = 2;                              // assume the 1st row as it is the header which we don't need
  let sourceLastRow = getLastRow(source, "AH");    //get the last non blank row, for the source to change
  let tempLastRow = getLastRow(tempSheet, "A");    //get the last non blank row, for the temp sheet

  //Copy the range from A2 to H<lastRow> & paste to the last empty row
  tempSheet.getRange("A" + tempLastRow).copyFrom(source.getRange("A2:AH" + sourceLastRow), ExcelScript.RangeCopyType.all, false, false);
}

/**
 * Get all analyst spreadsheets
 */
function getAnalystSheets(workbook: ExcelScript.Workbook) {
  let analysts: Array<string> = [];
  let config_sheet = workbook.getWorksheet("Configuration");

  let range = config_sheet.getRange("B2:B8");

  range.getValues().forEach(value => {
    analysts.push(String(value));
  });

  return analysts.filter(analyst => doesWorksheetExist(workbook, analyst));
}


/**
 * Check if the spreadsheet exists on the workbook
 * 
 */
function doesWorksheetExist(workbook: ExcelScript.Workbook, worksheetName: string): boolean {
  const worksheets = workbook.getWorksheets();

  for (const worksheet of worksheets) {
    if (worksheet.getName() === worksheetName) {
      return true;
    }
  }
  return false;
}

/**
 * get the last non empty row
 * - see https://www.reddit.com/r/excel/comments/vnqa6h/office_scripts_last_row_multiple_sheets/
 */
function getLastRow(sheet: ExcelScript.Worksheet, column: string): number {
  let lastRange = sheet.getUsedRange()?.getIntersection(`${column}:${column}`)?.
    getLastCell() ?? sheet.getRange(`${column}1`);

  if (lastRange.getRowIndex() > 0 && lastRange.getValue() === "") {
    lastRange = lastRange.getRangeEdge(ExcelScript.KeyboardDirection.up);
  }

  return lastRange.getRowIndex() + 1;
}
