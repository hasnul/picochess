#!/bin/bash

diff -q -r -x "*cache*" -x "diffs/" .. /tmp/chess/ > differ.txt
cat differ.txt | grep books > books.txt
cat differ.txt | grep engines > engines.txt
cat differ.txt | grep tablebases > tablebases.txt
cat differ.txt | grep templates > templates.txt
cat differ.txt | grep static > static.txt
cat differ.txt | grep py > py.txt
cat differ.txt | grep talker > talker.txt
