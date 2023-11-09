#-------------------------------------------------------------------------------
# Write a Bash script which will take a single command line argument 
# (a directory) and will print each entry in that directory. 
# If the entry is a file it will print it's size. 
# If the entry is a directory it will print how many items are in that directory.
#---------------------------------------------------------------------------------

#!/usr/bin/bash/env bash

echo "Enter a directory"

read dir

# This shitty if check can be avoided by specifying
# the type of in find command 
# But for the magic or error handling it will stay

# check if the input is a valid folder | Directory
if [ -d "$dir" ]; then

  #insert the inputted folder into a variable

  # the find cmd returns "./path/to/folder/" & since 
  # we can't cd into "./path/to/folder/ " we try to trim
  # the "./" using sed in order to get "path/to/folder/

  inputDir=$(find -name $dir | sed 's/\.\///g' )

  # Some black magic is going on here..... 
  # It does not work when we try to cd into the dir
  
  #**********************************************8***********
  # Research about using source 
  # https://linuxcommand.org/lc3_man_pages/sourceh.html
  #***********************************************************
  
  # cd $inputDir
  
  #----------------------------
  # TODO //
  #----------------------------

  #for debugging
  echo $inputDir
  
else

  # handle if the input is a file
  if [ -f "$dir" ]; then
  
    echo "$dir is a file!"
    
    # handle if the input is not a file nor  a dir
  else
  
    echo "$dir is not valid!!"
    
    exit 1
  fi
fi
