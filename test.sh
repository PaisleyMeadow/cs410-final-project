#!/bin/bash

FILENAME='FinalProject.java'
echo "copying FinalProject.class to onyx"
scp $FILENAME paisleydavis@onyx.boisestate.edu:~/cs410/FinalProject/
ssh paisleydavis@onyx.boisestate.edu "cd ~/cs410/FinalProject/;javac FinalProject.java;echo 'RUNNING PROJECT';java FinalProject $@; echo 'PROJECT EXITED'"
