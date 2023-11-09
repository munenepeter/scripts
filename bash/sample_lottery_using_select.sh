#!/usr/bin/bash env bash

names='Kimbery Peter Mark Jane Joe Anne Quit'

PS3="Vote for a person:"

select name in $names
  do
  if [$name == 'Quit' ]; then

      echo "Sorry, but the lottery has ended!"
      
      break
  fi
  echo  "Hooray!!, $name has won 10,000 dollars!"
done
