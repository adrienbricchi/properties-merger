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
BOLD='\033[1m'
STD='\033[0m'

# Parse input

TEST_MODE=false
HELP=false

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
            TEST_MODE=true
        ;;
        --no-color)
            YELLOW=''
            LIGHT_RED=''
            LIGHT_GREY=''
            STD=''
        ;;
        --help)
            HELP=true
        ;;
        *)
            echo -e "${LIGHT_RED}Error : Unknown argument : $1$STD"
            exit 1
        ;;
    esac
    shift
done


# Safety checks

if [[ ! -f $OLD_FILE ]];
then
    echo -e "${LIGHT_RED}Error : Input file does not exist.$STD"
    exit 2
fi

if [[ ! -f $SAMPLE_FILE ]];
then
    echo -e "${LIGHT_RED}Error : Sample file does not exist.$STD"
    exit 3
fi

if [[ $INPUT_FILE == $SAMPLE_FILE ]];
then
    echo -e "${LIGHT_RED}Error : Input and Sample files are the same. This is probably not what you want.$STD"
    exit 4
fi

if [[ -f $OUTPUT_FILE ]];
then
    echo -e "${LIGHT_RED}Error : Output file already exists.$STD"
    exit 5
fi

if [[ $HELP == true ]];
then
   echo -e "${BOLD}NAME$STD"
   echo -e "       properties-merger - merge a sample .properties file with already existing values"
   echo -e ""
   echo -e "${BOLD}SYNOPSIS$STD"
   echo -e "       ./properties-merger.sh -i my.properties.old -s my.properties.sample [OPTIONS]"
   echo -e ""
   echo -e "${BOLD}DESCRIPTION$STD"
   echo -e ""
   echo -e "       Mandatory arguments :"
   echo -e ""
   echo -e "       ${BOLD}-i$STD, ${BOLD}--input$STD"
   echo -e "              The input file, where existing data will be fetch."
   echo -e ""
   echo -e "       ${BOLD}-s$STD, ${BOLD}--sample$STD"
   echo -e "              The sample property file. The output model will be based on this one."
   echo -e ""
   echo -e "       Optional arguments :"
   echo -e ""
   echo -e "       ${BOLD}-o$STD, ${BOLD}--output$STD"
   echo -e "              The output file path. The file should not exists, or an error will be returned."
   echo -e "              If not set, results will be print on the standard output."
   echo -e ""
   echo -e "       ${BOLD}-t$STD, ${BOLD}--test$STD"
   echo -e "              The test mode, with color emphasis on merged data."
   echo -e "              This mode will invalidate the -o option."
   echo -e ""
   echo -e "       ${BOLD}--no-color$STD"
   echo -e "              Disables colors on test mode."
   echo -e ""
   echo -e "       ${BOLD}--help$STD"
   echo -e "              Ignore every other input, and displays this help."
   echo -e ""
   echo -e "${BOLD}AUTHOR$STD"
   echo -e "       Written by Adrien Bricchi"
   echo -e ""
   echo -e "${BOLD}COPYRIGHT$STD"
   echo -e "       Copyright © 2017 Libriciel.  License GPLv3+: GNU GPL version 3 or later <http://gnu.org/licenses/gpl.html>."
   echo -e "       This is free software: you are free to change and redistribute it.  There is NO WARRANTY, to the extent permitted by law."
   echo -e ""

   exit 0
fi

if [[ $TEST_MODE == true ]];
then
    echo -e "${LIGHT_GREY}################################################################################$STD"
    echo -e "${LIGHT_GREY}#                             TEST MODE                                        #$STD"
    echo -e "${LIGHT_GREY}#                                                                              #$STD"
    echo -e "${LIGHT_GREY}# This output contains a bunch of coloured chars,                              #$STD"
    echo -e "${LIGHT_GREY}# Avoid redirecting the output in a real property file..                       #$STD"
    echo -e "${LIGHT_GREY}#                                                                              #$STD"
    echo -e "${LIGHT_GREY}# ${YELLOW}Yellow lines$LIGHT_GREY are parameters from the old file                                #$STD"
    echo -e "${LIGHT_GREY}# ${STD}Regular lines$LIGHT_GREY are parameters from the sample file                            #$STD"
    echo -e "${LIGHT_GREY}################################################################################$STD"
    unset OUTPUT_FILE
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
        elif [[ $TEST_MODE == true ]]
        then
            echo -e "$YELLOW$current_key=$old_value$STD"
        else
            echo "$current_key=$old_value"
        fi

    else
        # Empty lines and comments are simply kept
        echo "$current_line"
    fi

done < "$SAMPLE_FILE"

