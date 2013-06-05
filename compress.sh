#!/bin/sh
declare -a FIRST_NAME_CHAR=(a b c d e f g h i j k l m n o p q r s t u v w x y z A B C D E F G H I J K L M N O P Q R S T U V W X Y Z)
declare -a ALL_NAME_CHAR=(a b c d e f g h i j k l m n o p q r s t u v w x y z A B C D E F G H I J K L M N O P Q R S T U V W X Y Z - _)

HTML_FILE=$1
FILE_LENGTH=`wc $HTML_FILE | awk '{ print $3 }'`
CLASS_MAP_TABLE=$1.class_map_table
ID_MAP_TABLE=$1.id_map_table

rm $CLASS_MAP_TABLE 1>/dev/null 2>&1
rm $ID_MAP_TABLE 1>/dev/null 2>&1

function create_map_table() 
{
    cat=$1;
    declare -i i=0;
    egrep -o " $cat *= *\"[^\"]+\"" $HTML_FILE | sed "s/$cat *= *//g" | sed "s/\"//g" | sed "s/ /`echo \\\n`/g" | sed "/^$/d" | sort | uniq -c | sort -nr | sed "s/^ *//" | while read name
    do
        if [ $i -lt ${#FIRST_NAME_CHAR[@]} ]; then
            compressName=${FIRST_NAME_CHAR[$i]}
        else 
            index_1=$((($i-${#FIRST_NAME_CHAR[@]})/${#ALL_NAME_CHAR[@]}))
            index_2=$((($i-${#FIRST_NAME_CHAR[@]})%${#ALL_NAME_CHAR[@]}))
            compressName=${FIRST_NAME_CHAR[$index_1]}${ALL_NAME_CHAR[$index_2]}
        fi
        echo "$name $compressName" >> $HTML_FILE.$cat"_map_table"
        i=$i+1;
    done
}

function clac_compress_rate() 
{
    eval $(awk -v cat="$1" '{ old_length+=$1*length($2); new_length+=$1*length($3) } END { print cat"Name_count=" NR "&&sum_old_"cat"Name_length=" old_length "&&sum_new_"cat"Name_length=" new_length "&&"cat"Name_decrease_rate=" (old_length-new_length)/old_length*100}' $HTML_FILE.$1"_map_table")
}

create_map_table id
create_map_table class
clac_compress_rate id
clac_compress_rate class

echo "idName count: $idName_count"
echo "Sum old idName length: $sum_old_idName_length"
echo "Sum new idName length: $sum_new_idName_length"
echo "Decrease idName length rate : $idName_decrease_rate%"
echo "\r"
echo "className count: $className_count"
echo "Sum old className length: $sum_old_className_length"
echo "Sum new className length: $sum_new_className_length"
echo "Decrease className length rate : $className_decrease_rate%"
echo "\r"
new_file_length=$(($FILE_LENGTH-($sum_old_className_length-$sum_new_className_length)-($sum_old_idName_length-$sum_new_idName_length)))
html_file_decrease_rate=$(echo "scale=3;($FILE_LENGTH-$new_file_length)/$FILE_LENGTH*100" | bc)
echo "Old html file length: $FILE_LENGTH"
echo "New html file length: $new_file_length"
echo "Decrease html file length rate: $html_file_decrease_rate%"

