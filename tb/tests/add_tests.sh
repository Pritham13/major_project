#!/bin/bash

# Define the maximum number to print
max=10

# Initialize odd and even counters
odd=3
even=4

echo "Printing odd and even numbers alternatively up to $max:"

while [ $odd -le $max ] || [ $even -le $max ]; do
    if [ $odd -le $max ]; then
        cp test1.sv test$odd.sv
        sed -i "s/test1/test$odd/gI" test$odd.sv
        odd=$((odd + 2))
    fi  

    if [ $even -le $max ]; then
        cp test2.sv test$even.sv
        sed -i "s/test2/test$even/gI" test$even.sv
        even=$((even + 2))
    fi  
done

