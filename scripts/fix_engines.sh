#!/bin/bash

# Find all the executable files in this folder and set the +x flag
find . -type f -print0 | xargs -0 file -i | grep executable | cut -d":" -f1 | xargs chmod +x
