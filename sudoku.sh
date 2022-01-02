#!/bin/bash 

. ./libraries.sh

declare -A matrix
scope="sudoku"

create_log
create_empty_matrix

counter=0
for ((new_row=1;new_row<10;new_row++))
do
create_row $new_row
wrng_num=( $(find_wrong_num $new_row) )

until [[ ${#wrng_num[@]} == 0 ]]
do
	((counter++))
	swap_wrong_num "${wrng_num[@]}"
	if [[ $? == 100 ]]
	then
		echo "Rewrite row $new_row" >> log.txt
		((new_row--))
		break
	fi

	wrng_num=( $(find_wrong_num $new_row) )
done
done

echo "Total Loops:$counter"
print_matrix 0 >> sudoku.txt
