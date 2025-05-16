#!/bin/bash

find -type f > change_name.txt

xargs -a change_name.txt -I {} sed 's/apb/ni/g' -i {}

l_num=1

for line in $(find . -type f -print)
do
	mv "$line"  "$(head -$l_num change_name.txt | tail -1)"
	((l_num++))
done

