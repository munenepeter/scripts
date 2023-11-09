@REM -------------------------------------------------------------------
@REM This is my EOD script
@REM This will move all my downloaded files to a specific dir
@REM and also close commonly used apps like chrome & Teams by default
@REM but one can add other apps by adding the name of the app
@REM -------------------------------------------------------------------

@echo off

echo Hope you had a wonderful day, Time to rest...

@REM Sleep for 5 secs
timeout /t 5 /nobreak > NUL

for /F %%i in ('dir /b "C:\Users\%username%\Downloads\*.*"') do (
  echo Seems like you have some files in Downloads
  goto :MoveFiles
    )

echo  Downloads is empty!
 goto checkParameters
:MoveFiles

    
echo  First things first lets move your downloads to delete...
  
@REM Sleep for 5 secs
timeout /t 5 /nobreak > NUL

@REM From: C:\Users\%username%\Downloads
    
move "C:\Users\%username%\Downloads\*" "C:\Users\%username%\Desktop\JWG Tracking\Delete"
    
rmdir "C:\Users\%username%\Downloads\*"

echo Done moving all your files!
@REM Sleep for 5 secs
timeout /t 5 /nobreak > NUL

goto checkParameters
@REM To: C:\Users\%username%\Desktop\JWG Tracking\Delete
    
:checkParameters
        if %1==" " (
           goto NoAppsToClose
        ) else (
          goto closeApps
        )
    
:closeApps
echo Now let's start closing the listed apps....
@REM Sleep for 5 secs
timeout /t 5 /nobreak > NUL
@REM Intiliaze an array containg all the provided apps
        
set list=%1 %2 %3 %4 %5
        
@REM echo out the contents of the array
        
(for %%a in (%list%) do ( 
   echo %%a
))
        
@REM Confirm if the user really needs to close the apps
        
:prompt
            
set /p prompt=Are you sure you want to close the listed apps? [Y/N] 
            
            
@REM check what the user has typed
            if "%prompt:~,1%"=="Y" (
             echo Alright Starting .....
            
                @REM Kill all apps specifed
                 (for %%a in (%list%) do ( 
                    taskkill -im %%a.exe /f
                 ))
                 goto shutdown
                @REM Ask if they want to shutdown or restart
                :shutdown
                   set /p shutdownprompt=Done closing the apps, Wanna Shutdown or Restart? [S/R] 
                  
                   @REM Check the input
                   if "%shutdownprompt:~,1%"=="S" (
                  
                      echo Shutting down in a minute...
                      @REM Actually shutdown
                       shutdown /p
                   )
                   if "%shutdownprompt:~,1%"=="R" (
                  
                      echo Restarting in a minute...
                      @REM Restart the machine
                       shutdown /r                        
                   ) 
                   if "%shutdownprompt:~,1%"==" " (
                      
                     echo Please enter S to shutdown or R to restart
                     @REM Sleep for 2 secs
                     timeout /t 2 /nobreak > NUL
                     goto shutdown
                   ) 
            )
            
            if "%prompt:~,1%"=="N" (
            
                echo Bye, See you when you are ready to leave
                
                exit /b 0
            )
            
            if "%prompt:~,1%"==" " (
            
                echo Please type Y for Yes or N for No
                goto prompt
            ) 
    :NoAppsToClose
    
    echo Since no apps were provided we are done, Bye  
