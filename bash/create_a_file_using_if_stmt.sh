# -----------------------------------------------------
#  Create a file whilst checking the input using 'IF'
#  Statements  
# -------------------------------------------------------

#!/bin/bash/

# Prompt the user to enter a file name

echo "Enter a file name"

# Read the inputted name
read filename 
# ----------------------
#   TODO -> Validate the input
# ----------------------

echo "Do you want to save $filename?"

echo "[Y] Yes"
echo "[N] No"

read input

if [[ $input == 'Y' || 'y' ]]; then

    touch $filename 
    
    echo "The file has been saved as"
    echo "$filename in $(pwd) "
    
 elif [[ $input == 'N' || 'n' ]]; then
    # ----------------------
    #   TODO -> Make sure that the user
    #          is sure about NOT 
    #          saving the file
    # ----------------------
     echo "No file has been saved! Bye?" 
    
fi
