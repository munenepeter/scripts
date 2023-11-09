#!/usr/bin/env bash

# Run a while loop for 165 times running git pull

i=1; while [ $i -le 165 ]; do sleep 5 && git pull && echo $i; ((i++)); done