#!/bin/bash

for i in $(find . -name *.sw*)
do
	rm -f $i
done

