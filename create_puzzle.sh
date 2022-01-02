#!/bin/bash

. ./libraries.sh

loc=$(dirname $0)
mat="${loc}/sudoku.txt"
pzl="${loc}/puzzle.txt"

cp $mat $pzl

for ((count=0;count<15;))
do
	clue_pos=$(($RANDOM % 9 + 1))$(($RANDOM % 9 + 1))
	if [[ ! ${clue[@]} =~ $clue_pos ]]
	then
		clue+=( $clue_pos )
		((count++))
	fi
done

count=0
while read line
do
	((++count))
	matrix[${count}1]=$(echo $line | awk '{print $1}')	
	matrix[${count}2]=$(echo $line | awk '{print $2}')	
	matrix[${count}3]=$(echo $line | awk '{print $3}')	
	matrix[${count}4]=$(echo $line | awk '{print $4}')	
	matrix[${count}5]=$(echo $line | awk '{print $5}')	
	matrix[${count}6]=$(echo $line | awk '{print $6}')	
	matrix[${count}7]=$(echo $line | awk '{print $7}')	
	matrix[${count}8]=$(echo $line | awk '{print $8}')	
	matrix[${count}9]=$(echo $line | awk '{print $9}')	
done < $pzl

echo ${clue[@]}
echo ""

for ((irow=1;irow<10;irow++))
do
	for ((icol=1;icol<10;icol++))
	do
		if [[ ${clue[@]} =~ $irow$icol ]]
		then
			continue
		else
			matrix[$irow$icol]=-
		fi
	done
done
(print_matrix 0) > $pzl
