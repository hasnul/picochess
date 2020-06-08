#!/bin/bash
while inotifywait -e modify .;
    do rsync -avz *.py picochess:/opt/picochess/;
done
