#!/bin/bash

function create_log(){
	if [[ -f ./log.txt ]]
	then
		rm ./log.txt
	fi
	echo "$(date) Start" > log.txt
}

function create_empty_matrix(){
for row in {1..9}
do
	for col in {1..9}
	do
 		matrix[$row$col]=-
       done
done       
}

function print_matrix(){
	if [[ $1 == 0 ]]
	then
		for i in {1..9}
		do
		echo "${matrix[${i}1]} ${matrix[${i}2]} ${matrix[${i}3]} ${matrix[${i}4]} ${matrix[${i}5]} ${matrix[${i}6]} ${matrix[${i}7]} ${matrix[${i}8]} ${matrix[${i}9]}" 
		done
	else
		for i in {1..9}
		do
		echo "${matrix[${i}1]} ${matrix[${i}2]} ${matrix[${i}3]} ${matrix[${i}4]} ${matrix[${i}5]} ${matrix[${i}6]} ${matrix[${i}7]} ${matrix[${i}8]} ${matrix[${i}9]}" >> log.txt
		done
fi
}

function print_row(){
	frows=( $* )
	for i in ${frows[@]}
	do
	echo "${matrix[${i}1]} ${matrix[${i}2]} ${matrix[${i}3]} ${matrix[${i}4]} ${matrix[${i}5]} ${matrix[${i}6]} ${matrix[${i}7]} ${matrix[${i}8]} ${matrix[${i}9]}" >> log.txt
	done
}

function create_row(){
	row=$1
	local scope="create_row_$row"
	num_set=($(seq 1 9))
	pos_set=($(seq 1 9))

	if [[ $row == 9 ]]
	then
		for ((icol=1;icol<10;icol++))
		do
			num_set=($(seq 1 9))
			for ((irow=1;irow<$row;irow++))
			do
				num_set=( ${num_set[@]/${matrix[$irow$icol]}} )
			done
		matrix[$row$icol]=${num_set[0]}
		echo "[$scope]Chose ${num_set[0]} for position $icol" >> log.txt
		done
	else
		until [[ ${#pos_set[@]} == 0 ]]
		do
			num=${num_set[$RANDOM % ${#num_set[@]}]}
			pos=${pos_set[$RANDOM % ${#pos_set[@]}]}

			echo "[$scope]Chose $num for position $pos" >> log.txt
			matrix[$row$pos]=$num

			num_set=(${num_set[@]/$num})
			echo "[$scope]Removed $num from num_set[${num_set[@]}]" >>log.txt
			echo "[$scope]Remaining num_set : ${#num_set[@]}" >>log.txt

			pos_set=(${pos_set[@]/$pos})
			echo "[$scope]Removed $pos from pos_set[${pos_set[@]}]" >>log.txt
			echo "[$scope]Remaining pos_set : ${#pos_set[@]}" >>log.txt
		done
	fi
	print_matrix
}

function check_v(){
	local scope="check_v"
	ret=0
	num=${matrix[$row$col]}
	
	for ((irow=1;irow<$row;irow++))
	do
		if [[ ${matrix[$irow$col]} == $num ]]
		then
			#echo "[$scope]$num is already available at [$irow$col] " >> log.txt
			ret=1
		fi
	done
	return $ret
	
}

function check_h(){
	local scope="check_h"
	ret=0
	num=${matrix[$row$col]}
	
	for ((icol=1;icol<$col;icol++))
	do
		if [[ ${matrix[$row$icol]} == ${num} ]]
		then
			#echo "[$scope]$num is already available at [$row$icol] " >> log.txt
			ret=1
		fi	
	done
	return $ret
	
}

function get_square(){

	local frow=$1
	local fcol=$2
	ret_array=()

	row_f=$(( $(($frow -1)) / 3 ))
	col_f=$(( $(($fcol -1)) / 3 ))

	row_ll=$(( $(($row_f * 3)) + 1 ))
	row_ul=$(($row_ll + 2))

	col_ll=$(( $(($col_f * 3)) + 1 ))
	col_ul=$(($col_ll + 2))
	
	echo "$row_ll $row_ul $col_ll $col_ul"
}

check_sqr(){
	local scope="check_sqr"
	ret=0
	
	#echo "[check_sqr]Get sqaures for $row$col" >> log.txt
	limits=( $(get_square $row $col) )
	
	row_ll=${limits[0]}
	row_ul=${limits[1]}
	col_ll=${limits[2]}
	col_ul=${limits[3]}

	#echo "[$scope]Square limits are $row_ll|$row_ul|$col_ll|$col_ul" >> log.txt

	num=${matrix[$row$col]}
	for ((irow=$row_ll;irow<=$row_ul;irow++))
	do
		for ((icol=$col_ll;icol<=$col_ul;icol++))
		do
			if [[ $num == ${matrix[$irow$icol]} ]]
			then
				if [[ $irow == $row && $icol == $col ]]
				then
					continue
				else
					#echo "[check_sqr]$num available at [$irow$icol]" >> log.txt
					ret=1
				fi
			fi
		done
	done

	return $ret
}

function find_wrong_num(){
	local scope="find_wrong_num"
	row=$1
	wrong_num=()
	for ((col=1;col<10;col++))
	do
		echo "[$scope]Check the column for any duplicates" >> log.txt
		check_v
		if [[ $? == 1 ]]
		then
			num_pos="${matrix[$row$col]}$col"
			[[ ! ${wrong_num[@]} =~ $num_pos ]] && wrong_num+=( "$num_pos" )
		fi

		echo "[$scope]Check the row for any duplicates" >> log.txt
		check_h
		if [[ $? == 1 ]]
		then
			num_pos="${matrix[$row$col]}$col"
			[[ ! ${wrong_num[@]} =~ $num_pos ]] && wrong_num+=( "$num_pos" )
		fi

		echo "[$scope]Check the sqaure for any duplicates" >> log.txt
		check_sqr
		if [[ $? == 1 ]]
		then
			num_pos="${matrix[$row$col]}$col"
			[[ ! ${wrong_num[@]} =~ $num_pos ]] && wrong_num+=( "$num_pos" )
		fi

	done
	echo ${wrong_num[@]}
}

function get_acceptable_nums(){
	local scope="get_acceptable_nums"
	local frow=$1
	local fcol=$2
	num_set=( $(seq 1 9) )
	limits=( $(get_square $frow $fcol) )
	
	row_ll=${limits[0]}
	row_ul=${limits[1]}
	col_ll=${limits[2]}
	col_ul=${limits[3]}

	echo "[$scope]Square limits for $frow$fcol are $row_ll|$row_ul|$col_ll|$col_ul" >> log.txt

	for ((irow=$row_ll;irow<=$row_ul;irow++))
	do

	echo "[$scope]Checking the acceptance in the square" >>log.txt
	for ((icol=$col_ll;icol<=$col_ul;icol++))
	do
		if [[ ${num_set[@]} =~ ${matrix[$irow$icol]}  ]]
		then
			num_set=( ${num_set[@]/${matrix[$irow$icol]}} )
			echo "[get_acceptable_nums]Removed ${matrix[$irow$icol]} from numset since available at $irow$icol[${num_set[@]}]" >> log.txt
		fi
	done
	done

	echo "[$scope]Checking the acceptance is the column" >>log.txt
	for ((irow=1;irow<$frow;irow++))
	do
		if [[ ${num_set[@]} =~ ${matrix[$irow$fcol]}  ]]
		then
			num_set=( ${num_set[@]/${matrix[$irow$fcol]}} )
			echo "[get_acceptable_nums]Removed ${matrix[$irow$fcol]} from numset since available at $irow$fcol[${num_set[@]}]" >> log.txt
		fi
	done

	echo "[get_acceptable_nums]Acceptable nums at this cell are [${num_set[@]}]" >> log.txt
	echo "${num_set[@]}"
}

function is_num_fit(){
	local frow=$1
	local fcol=$2
	num=$3
	ret=0
	scope="is_num_fit"
	limits=( $(get_square $frow $fcol) )

	row_ll=${limits[0]}
	row_ul=${limits[1]}
	col_ll=${limits[2]}
	col_ul=${limits[3]}

	echo "[$scope]Square limits for $frow$fcol are $row_ll|$row_ul|$col_ll|$col_ul" >> log.txt

	for ((irow=$row_ll;irow<=$row_ul;irow++))
	do
	for ((icol=$col_ll;icol<=$col_ul;icol++))
	do
		if [[ ${num} == ${matrix[$irow$icol]}  ]]
		then
			echo "[$scope]$num is not a fit since aready present at $irow$icol">> log.txt
			ret=1
		fi
	done
	done

	for ((irow=1;irow<$frow;irow++))
	do
		if [[ ${num} == ${matrix[$irow$fcol]}  ]]
		then
			echo "[$scope]$num is not a fit since aready present at $irow$fcol">> log.txt
			ret=1
		fi
	done

	return $ret

}

function get_column(){
	fnum=$1
	retcol=0
	for ((icol=0;icol<10;icol++))
	do
		if [[ ${matrix[$row$icol]} == $fnum ]]
		then
			retcol=$icol
			break
		fi	
	done
	
	echo $retcol
}

function swap(){
	local scope="swap"
	col1=$1
	col2=$2
	temp=0
	ret=1
	if [[ -n $col1 && -n $col2 ]]; then
		if [[ $col1 -ne $col2 ]]
			then
			temp=${matrix[$row$col2]}
			matrix[$row$col2]=${matrix[$row$col1]}
			matrix[$row$col1]=${temp}
			echo "[$scope]Swapped positions $col1 and $col2" >> log.txt
			ret=0
		else
			echo "[$scope]Both col1[$col1] and col2[$col2] are same. Not possible to swap" >> log.txt
		fi
	else
		echo "[$scope]One column missing col1[$col1] col2[$col2]">> log.txt
	fi

	return $ret
}

function swap_wrong_num_with_random(){
		wrng_num=$1
		call_trace=$2
		if [[ -n $wrng_num ]]
		then
			local scope="swap_wrong_num_with_random_$call_trace"
			ret=1
			w_pos=${wrng_num: -1}
			w_num=${wrng_num:0:1}
			
			echo "[$scope]Swap $w_num[@$w_pos] with any random position" >>log.txt
			pos_set=( $(seq 1 9) )
			pos_set=( ${pos_set[@]/$w_pos} )

			echo "[$scope]Look for the acceptable numbers at the wrong pos[$row$w_pos]" >> log.txt
			acceptable_nums=( $(get_acceptable_nums $row $w_pos) )
			if [[ ${#acceptable_nums} == 0 ]]
			then
				echo "[$scope]Return 100 since no other num can fit at $row$w_pos">> log.txt
				ret=100
			fi

			swap_success=1
			for num in ${acceptable_nums[@]}
			do
				echo "[$scope]Get the col of $num">> log.txt
				fcol=$(get_column $num)
				if [[ -n $fcol ]]; then
					echo "[$scope]Col of acc num[$num] is $fcol" >> log.txt

					echo "[$scope]Check fitness of wrong num [$w_num] in pos of acc num[$row$fcol]" >> log.txt
					is_num_fit $row $fcol $w_num
					if [[ $? == 0 ]]
					then
						echo "[$scope]$w_num is a good fit at $row$fcol" >> log.txt
						echo "[$scope]Check fitness of random num[${matrix[$row$fcol]}] in wrong position [$row$w_pos]" >> log.txt

						is_num_fit $row $w_pos ${matrix[$row$fcol]}
						if [[ $? == 0 ]]
						then
							echo "[$scope]$num is a good fit at $row$w_pos. OK to swap" >> log.txt
							echo "[$scope]Call swap for $fcol and $w_pos" >> log.txt
							swap $fcol $w_pos
							if [[ $? == 0 ]]; then
							swap_success=0
							echo "[$scope]Swap successful between $col and $fcol" >> log.txt
							break
							fi
						else
							echo "[$scope]$matrix[$row$fcol] is not a good fit at $row$w_pos" >> log.txt
						fi
					else
						echo "[$scope]$w_num is not a good fit at $row$fcol" >> log.txt
					fi		
				else
					echo "[$scope]No columns retrieved for the chosen acceptable number[$num]" >> log.txt
				fi	
			done

			if [[ $swap_success == 1 ]]
			then
				echo "[$scope]Swap failed">> log.txt
				print_matrix
				echo "[$scope]Loop is stuck. Unable to find a possible swicth">> log.txt
				ret=100
			fi
			
			print_row $row
			
		else
			echo "[$scope]List of wrong numbers is empty. Incorrect function call">>log.txt
		fi
return $ret
}


function swap_wrong_num(){
	local scope="swap_wrong_num"
	wrng_nums=( $* )
	
	echo "Start $scope" >> log.txt
	echo "[$scope]Wrong num_pos are [${wrng_nums[@]}]" >> log.txt
	if [[ ${#wrng_num[@]} -lt 2 ]]
	then
		echo "[$scope]Only 1 wrong position. Try to swap within random position" >> log.txt
		swap_wrong_num_with_random ${wrng_num[@]} 1
			if [[ $? == 100 ]]
			then
				echo "[$scope]Return signal 100 to rewrite the row" >> log.txt
				return 100
			fi
	else
		#GET THE WRONG POSITIONS AND NUMBERS TO ARRAY
		w_pos=()
		w_num=()
		for num_pos in ${wrng_nums[@]}
		do
			w_num+=(${num_pos:0:1})
			w_pos+=(${num_pos: -1})
		done

		for inum in ${w_num[@]}
		do
			min_fitting_pos=0
			for ipos in ${w_pos[@]}
			do
				is_num_fit $row $ipos $inum
				[[ $? -eq 0 ]] && ((++min_fitting_pos))

			done
			
			if [[ $min_fitting_pos == 0 ]]
			then
				echo "[$scope]$num does not fit in any of the w_pos.Returning signal 100. Rewrite the row">> log.txt
				return 100
			fi

		done

		echo "[$scope]Positions before shuffle :[${w_pos[@]}] ">> log.txt	
		w_pos=($(shuf -e ${w_pos[@]}) )
		echo "[$scope]Positions after shuffle  :[${w_pos[@]}] ">> log.txt	
		echo "[$scope]Numbers to shuffle       :[${w_num[@]}] ">> log.txt	
		
		#SWAP
		for ind in ${!wrng_nums[@]}
		do
			new_pos=${w_pos[$ind]}
			matrix[$row${new_pos}]=${w_num[$ind]}
			echo "[$scope][Swapping][INDEX=$ind]${w_num[$ind]} added to new position [$new_pos]" >> log.txt
		done
		
		wrng_nums=( $(find_wrong_num $row) )
		
		if [[  ${#wrng_nums[@]} == 2 ]]
		then
			echo "[$scope]Two wrong numbers detected">> log.txt

			for num_pos in ${wrng_nums[@]}
			do
				w_num+=(${num_pos:0:1})
				w_pos+=(${num_pos: -1})
			done	

			w_num1=${w_num[0]}
			w_num2=${w_num[1]}
			w_num1_pos=${w_pos[0]}
			w_num2_pos=${w_pos[1]}
			
			echo "[$scope]Checking the fitness of $w_num1 at $row$w_num2_pos">>log.txt
			is_num_fit $row ${w_num2_pos} ${w_num1}
			
			if [[ $? == 0 ]]
			then
				echo "[$scope]$w_num1 is a good fit at $row$w_num2_pos" >> log.txt
				echo "[$scope]Checking the fitness of $w_num2 at $row$w_num1_pos">>log.txt
				is_num_fit $row ${w_num1_pos} ${w_num2}

				if [[ $? == 0  ]]
				then
					echo "[$scope]$w_num2 is a good fit at $row$w_num1_pos" >> log.txt
					swap $w_num1_pos $w_num2_pos
				else
					echo "[$scope]$w_num2 is a bad fit at $row$w_num1_pos. Look for another location" >> log.txt
					swap_wrong_num_with_random $w_num2 2
					if [[ $? == 100 ]]
					then
						echo "$[$scope]Return signal 100 to rewrite the row" >> log.txt
						return 100
					fi
				fi
				
			else	
				echo "[$scope]$w_num1 is a bad fit at $row$w_num2_pos" >> log.txt
				swap_wrong_num_with_random $w_num1 3
				if [[ $? == 100 ]]
				then
					echo "$[$scope]Return signal 100 to rewrite the row" >> log.txt
					return 100
				fi
			fi
		fi

		print_row $(($row -1)) $row

	fi
}
