' Enable error handling
On Error Resume Next

' Get the file path and log file path from the batch script arguments
xlsFilePath = WScript.Arguments(0)
logFilePath = WScript.Arguments(1)

' Open the log file for appending
Set objFSO = CreateObject("Scripting.FileSystemObject")
Set logFile = objFSO.OpenTextFile(logFilePath, 8, True)

' Check if the file exists
If Not objFSO.FileExists(xlsFilePath) Then
    logFile.WriteLine "Error: File not found - " & xlsFilePath
    logFile.Close
    WScript.Quit 1
End If

Set objExcel = CreateObject("Excel.Application")
If Err.Number <> 0 Then
    WScript.Echo "Error: Unable to create Excel.Application object. Please ensure Excel is installed."
    logFile.WriteLine "Error: Unable to create Excel.Application object. Please ensure Excel is installed."
    logFile.Close
    WScript.Quit 1
End If

objExcel.Visible = False

' Try to open the xls file
Set objWorkbook = objExcel.Workbooks.Open(xlsFilePath)
If Err.Number <> 0 Then
    WScript.Echo "Error: Unable to open file - " & xlsFilePath & ". The file may be corrupted or incompatible."
    logFile.WriteLine "Error: Unable to open file - " & xlsFilePath & ". The file may be corrupted or incompatible."
    objExcel.Quit
    logFile.Close
    WScript.Quit 1
End If

' Replace the file extension to create the new xlsx path
xlsxFilePath = Replace(xlsFilePath, ".xls", ".xlsx")

' Try to save it as xlsx (code 51)
objWorkbook.SaveAs xlsxFilePath, 51
If Err.Number <> 0 Then
    WScript.Echo "Error: Unable to save file as .xlsx - " & xlsxFilePath
    logFile.WriteLine "Error: Unable to save file as .xlsx - " & xlsxFilePath
    objWorkbook.Close False
    objExcel.Quit
    logFile.Close
    WScript.Quit 1
End If

' Close the workbook and quit Excel
objWorkbook.Close False
objExcel.Quit

logFile.WriteLine "Successfully converted " & xlsFilePath & " to " & xlsxFilePath

' Clean up
logFile.Close
Set objWorkbook = Nothing
Set objExcel = Nothing
Set objFSO = Nothing
