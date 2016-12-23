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


YELLOW='\033[1;33m'
LIGHT_RED='\033[1;31m'
LIGHT_GREY='\033[1;30m'
NO_COLOR='\033[0m'

# Parse input

TEST_MODE=$false

while [[ $# -gt 0 ]]
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
        -t|--test)
            TEST_MODE=$true
        ;;
        *)
            echo -e "${LIGHT_RED}Error : Unknown argument : $1$NO_COLOR"
            exit 1
        ;;
    esac
    shift
done


# Safety checks

if [[ $TEST_MODE == $true ]];
then
    echo -e "${LIGHT_GREY}################################################################################$NO_COLOR"
    echo -e "${LIGHT_GREY}#                             TEST MODE                                        #$NO_COLOR"
    echo -e "${LIGHT_GREY}#                                                                              #$NO_COLOR"
    echo -e "${LIGHT_GREY}# This output contains a bunch of coloured chars,                              #$NO_COLOR"
    echo -e "${LIGHT_GREY}# Avoid redirecting the output in a real property file..                       #$NO_COLOR"
    echo -e "${LIGHT_GREY}#                                                                              #$NO_COLOR"
    echo -e "${LIGHT_GREY}# ${YELLOW}Yellow lines are parameters from the old file                                $LIGHT_GREY#$NO_COLOR"
    echo -e "${LIGHT_GREY}# ${NO_COLOR}Regular lines are parameters from the sample file                            $LIGHT_GREY#$NO_COLOR"
    echo -e "${LIGHT_GREY}################################################################################$NO_COLOR"
    unset OUTPUT_FILE
fi

if [[ ! -f $OLD_FILE ]];
then
    echo -e "${LIGHT_RED}Error : Input file does not exist.$NO_COLOR"
    exit 1
fi

if [[ ! -f $SAMPLE_FILE ]];
then
    echo -e "${LIGHT_RED}Error : Sample file does not exist.$NO_COLOR"
    exit 1
fi

if [[ $INPUT_FILE == $SAMPLE_FILE ]];
then
    echo -e "${LIGHT_RED}Error : Input and Sample files are the same. This is probably not what you want.$NO_COLOR"
    exit 1
fi

if [[ -f $OUTPUT_FILE ]];
then
    echo -e "${LIGHT_RED}Error : Output file already exists.$NO_COLOR"
    exit 1
fi


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

        current_key="${BASH_REMATCH[1]}"
        current_value="${BASH_REMATCH[2]}"
        unset old_value

        # Fetching old value
        # We're using the same Regex, to prevent old comments, and keep the last value of the file.

        while read -r old_line
        do
            if [[ "$old_line" =~ ^\s*([^#]*?)=(.*?)\s*$ ]] && [[ "${BASH_REMATCH[1]}" == $current_key ]];
            then
                old_value="${BASH_REMATCH[2]}"
            fi
        done < "$OLD_FILE"

        # Printing result
        # Checking if old value is set, to keep existing empty values ("")
        
        if [[ -z ${old_value+x} ]];
        then
            echo "$current_key=$current_value"
        elif [[ $TEST_MODE == $true ]];
        then
            echo -e "$YELLOW$current_key=$old_value$NO_COLOR"
        else
            echo "$current_key=$old_value"
        fi

    else
        # Empty lines and comments are simply kept
        echo "$current_line"
    fi

done < "$SAMPLE_FILE"

