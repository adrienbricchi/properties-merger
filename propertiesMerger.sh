#!/bin/bash

# properties-merger
# Copyright (C) 2016-2017
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


VERSION_NUMBER=3
VERSION_DATE="2017/01/02"

LIGHT_GREEN='\033[1;32m'
LIGHT_RED='\033[1;31m'
YELLOW='\033[1;33m'
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
        --no-color|--no-colour)
            YELLOW=''
            LIGHT_RED=''
            LIGHT_GREY=''
            STD=''
        ;;
        -v|--version)
            echo $VERSION_NUMBER
            exit 0
        ;;
        -h|--help)
            echo -e "${BOLD}NAME${STD}"
            echo -e "       properties-merger - merge a sample .properties file with already existing values"
            echo -e ""
            echo -e "${BOLD}SYNOPSIS${STD}"
            echo -e "       ./properties-merger.sh -i my.properties.old -s my.properties.sample [OPTIONS]"
            echo -e ""
            echo -e "${BOLD}DESCRIPTION${STD}"
            echo -e ""
            echo -e "       Mandatory arguments :"
            echo -e ""
            echo -e "       ${BOLD}-i${STD}, ${BOLD}--input${STD}"
            echo -e "              The input file, where existing data will be fetch."
            echo -e ""
            echo -e "       ${BOLD}-s${STD}, ${BOLD}--sample${STD}"
            echo -e "              The sample property file. The output model will be based on this one."
            echo -e ""
            echo -e "       Optional arguments :"
            echo -e ""
            echo -e "       ${BOLD}-o${STD}, ${BOLD}--output${STD}"
            echo -e "              The output file path. The file should not exists, or an error will be returned."
            echo -e "              If not set, results will be print on the standard output."
            echo -e ""
            echo -e "       ${BOLD}-t${STD}, ${BOLD}--test${STD}"
            echo -e "              The test mode, with emphasis on merged data."
            echo -e "              This mode will invalidate the -o option."
            echo -e ""
            echo -e "       ${BOLD}--no-color${STD}, ${BOLD}--no-colour${STD}"
            echo -e "              Disables colours on test mode."
            echo -e ""
            echo -e "       ${BOLD}-h${STD}, ${BOLD}--help${STD}"
            echo -e "              Displays this help."
            echo -e ""
            echo -e "       ${BOLD}-v${STD}, ${BOLD}--version${STD}"
            echo -e "              Displays the current (int) version."
            echo -e ""
            echo -e "${BOLD}AUTHOR${STD}"
            echo -e "       Written by Adrien Bricchi"
            echo -e ""
            echo -e "${BOLD}COPYRIGHT${STD}"
            echo -e "       Copyright © 2017 Libriciel.  License GPLv3+: GNU GPL version 3 or later <http://gnu.org/licenses/gpl.html>."
            echo -e "       This is free software: you are free to change and redistribute it.  There is NO WARRANTY, to the extent permitted by law."
            echo -e ""
            echo -e "${BOLD}VERSION${STD}"
            echo -e "       v.${VERSION_NUMBER} (${VERSION_DATE})"
            echo -e ""

            exit 0
        ;;
        *)
            echo -e "${LIGHT_RED}Error : Unknown argument : $1${STD}"
            echo -e "Use --help argument for the list of parameters"
            exit 1
        ;;
    esac
    shift
done


# Safety checks

if [[ ! -f $OLD_FILE ]];
then
    echo -e "${LIGHT_RED}Error : Input file (--input) does not exist.${STD}"
    exit 2
fi

if [[ ! -f $SAMPLE_FILE ]];
then
    echo -e "${LIGHT_RED}Error : Sample file (--sample) does not exist.${STD}"
    exit 3
fi

if [[ $INPUT_FILE == $SAMPLE_FILE ]];
then
    echo -e "${LIGHT_RED}Error : Input and Sample files are the same. This is probably not what you want.${STD}"
    exit 4
fi

if [[ -f $OUTPUT_FILE ]];
then
    echo -e "${LIGHT_RED}Error : Output file already exists.${STD}"
    exit 5
fi

if [[ $TEST_MODE == true ]];
then
    unset OUTPUT_FILE
fi


# Merge files

# Regex explain : ^\s*([^#]*?)=(.*?)\s*$
# 
#     ^\s*                Ignore spaces from the begining of line
#     ([^#]*?)=           Catches non-# chars until the first "=" (non greedy),
#     (.*?)\s*$           Catches everything, til the end of line, "\s*" removes every final spaces
# 
PROPERTIES_REGEX="^\s*([^#]*?)=(.*?)\s*$"

while read -r current_line
do
    if [[ "${current_line}" =~ $PROPERTIES_REGEX ]];
    then

        current_key="${BASH_REMATCH[1]}"
        current_value="${BASH_REMATCH[2]}"
        unset old_value

        # Fetching old value
        # We're using the same Regex, to prevent old comments.

        while read -r old_line
        do
            if [[ "${old_line}" =~ $PROPERTIES_REGEX ]] && [[ "${BASH_REMATCH[1]}" == $current_key ]];
            then
                old_value="${BASH_REMATCH[2]}"
            fi
        done < "${OLD_FILE}"

        # Printing result
        # Checking if old value is set, to keep existing empty values ("")
        
        if [[ $TEST_MODE == true ]]
        then
            if [[ -z ${old_value+x} ]];
            then
                echo -e "[${YELLOW}SAMPLE${STD}]  ${current_key}=${current_value}"
            else
                echo -e "[${LIGHT_GREEN}INPUT${STD}]   ${current_key}=${old_value}"
            fi
        elif [[ -z ${old_value+x} ]];
        then
            if [[ -z ${OUTPUT_FILE+x} ]];
            then
                echo "${current_key}=${current_value}"
            else
                echo "${current_key}=${current_value}" >> $OUTPUT_FILE
            fi
        else
            if [[ -z ${OUTPUT_FILE+x} ]];
            then
                echo "${current_key}=${old_value}"
            else
                echo "${current_key}=${old_value}" >> $OUTPUT_FILE
            fi
        fi

    else
        # Empty lines and comments are simply kept

        if [[ $TEST_MODE == true ]]
        then
            echo "[COMMENT] ${current_line}"
        elif [[ -z ${OUTPUT_FILE+x} ]];
        then
            echo "${current_line}"
        else
            echo "${current_line}" >> $OUTPUT_FILE
        fi
    fi

done < "${SAMPLE_FILE}"


# Printing deleted values

if [[ $TEST_MODE == true ]]
then
    while read -r old_line
    do

        if [[ "${old_line}" =~ $PROPERTIES_REGEX ]];
        then
            current_key="${BASH_REMATCH[1]}"
            current_value="${BASH_REMATCH[2]}"
            key_exists_in_sample=false

            while read -r sample_line
            do
                if [[ "${sample_line}" =~ $PROPERTIES_REGEX ]] && [[ "${BASH_REMATCH[1]}" == $current_key ]];
                then
                    key_exists_in_sample=true
                fi
            done < "${SAMPLE_FILE}"

            if [[ $key_exists_in_sample == false ]];
            then
                echo -e "[${LIGHT_RED}DELETED${STD}] ${current_key}=${current_value}"
            fi
        fi
    done < "${OLD_FILE}"
fi

