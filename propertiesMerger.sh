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


#SAMPLE_FILE="$1"
SAMPLE_FILE="./sample.properties"
#OLD_FILE="$2"
OLD_FILE="./old.properties"


while read -r current_line
do

    # Regex explain : ^(.*?)=(.*?)\s*$
    # 
    #     ^(.*?)=             Catches everything from the begining until the first "=" (non greedy)
    #     (.*?)\s*$           Catches everything, til the end of line, "\s*" removes every final spaces

    if [[ "$current_line" =~ ^(.*?)=(.*?)\s*$ ]];
    then
        
        current_key="${BASH_REMATCH[1]}";
        current_value="${BASH_REMATCH[2]}";
        old_value=$(sed -n "/$current_key=/{s///; p;}" $OLD_FILE);

        if [ "$old_value" != "" ];
        then
            echo "$current_key=$old_value";
        else
            echo "$current_key=$current_value";
        fi
    
    else
        # Empty lines and comments
        echo "$current_line";
    fi

done < "$SAMPLE_FILE"

