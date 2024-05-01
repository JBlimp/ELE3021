#!/bin/bash

make clean

if [ $? -eq 0 ]; then  
    make

    if [ $? -eq 0 ]; then  
        make fs.img

        if [ $? -eq 0 ]; then  
        ./bootxv6.sh
        fi
    fi
fi