#!/bin/bash 

. ./libraries.sh

declare -A matrix
scope="sudoku"

create_log
create_empty_matrix


for ((new_row=1;new_row<10;new_row++))
do
create_row $new_row
wrng_num=( $(find_wrong_num $new_row) )

until [[ ${#wrng_num[@]} == 0 ]]
do
	swap_wrong_num "${wrng_num[@]}"
	if [[ $? == 100 ]]
	then
		echo "Rewrite row $new_row" >> log.txt
		echo "Retry for Row$new_row"
		((new_row--))
		break
	fi

	wrng_num=( $(find_wrong_num $new_row) )
	[[ ${#wrng_num} == 0 ]] && echo "Row$new_row created"
done
done

print_matrix 0
