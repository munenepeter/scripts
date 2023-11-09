@REM Create a file whilst checking the input using 'IF' Statements

@echo off

echo Do you want to create a file by the name %1?

echo [Y] Yes
echo [N] NO

choice /c YN /m "Yes or NO"

@REM don't know how to read input in batch!