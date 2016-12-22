#!/bin/bash

# properties-merger
# Copyright (C) 2016
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program. If not, see <http://www.gnu.org/licenses/>.



# Parse input

while [[ $# -gt 1 ]]
do
    key="$1"

    case $key in
        -i|--input)
            OLD_FILE="$2"
            shift
        ;;
        -s|--sample)
            SAMPLE_FILE="$2"
            shift
        ;;
        -o|--output)
            OUTPUT_FILE="$2"
            shift
        ;;
        *)
            echo "Error : Unknown argument : $1";
            exit 1;
        ;;
    esac
    shift
done


# Default cases

if [[ ! -f $OLD_FILE ]];
then
    echo "Error : Input file does not exist.";
    exit 1;
fi

if [[ ! -f $SAMPLE_FILE ]];
then
    echo "Error : Sample file does not exist.";
    exit 1;
fi

if [[ $INPUT_FILE == $SAMPLE_FILE ]];
then
    echo "Error : Input and Sample files are the same. This is probably not what you want.";
    exit 1;
fi

if [[ -f $OUTPUT_FILE ]];
then
    echo "Error : Output file already exists.";
    exit 1;
fi


#echo "OLD = $OLD_FILE";
#echo "SAM = $SAMPLE_FILE";
#echo "OUT = $OUTPUT_FILE";


# Merge files

while read -r current_line
do

    # Regex explain : ^\s*([^#]*?)=(.*?)\s*$
    # 
    #     ^\s*                Ignore spaces from the begining of line
    #     ([^#]*?)=           Catches non-# chars until the first "=" (non greedy),
    #     (.*?)\s*$           Catches everything, til the end of line, "\s*" removes every final spaces
    # 
    if [[ "$current_line" =~ ^\s*([^#]*?)=(.*?)\s*$ ]];
    then

        current_key="${BASH_REMATCH[1]}";
        current_value="${BASH_REMATCH[2]}";
        unset old_value

        # Fetching old value
        # We're using the same Regex, to prevent old comments, and keep the last value of the file.

        while read -r old_line
        do
            if [[ "$old_line" =~ ^\s*([^#]*?)=(.*?)\s*$ ]] && [[ "${BASH_REMATCH[1]}" == $current_key ]];
            then
                old_value="${BASH_REMATCH[2]}";
            fi
        done < "$OLD_FILE"

        # Printing result
        # Checking if old value is set, to keep existing empty values ("")
        
        if [[ -z ${old_value+x} ]];
        then
            echo "$current_key=$current_value";
        else
            echo "$current_key=$old_value";
        fi

    else
        # Empty lines and comments are simply kept
        echo "$current_line";
    fi

done < "$SAMPLE_FILE"

