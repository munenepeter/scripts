# Intro into bash functions


function helloWorld(){
    echo "Passing parameters $1";
    echo "Second $2"
}

helloWorld "1st parameter" "2nd Parameter"
