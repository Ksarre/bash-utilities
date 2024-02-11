#!/bin/bash

#checks for file diffs between HEAD and current in this git repository,
#if found, find lines in these diffs that start with a comment delimiter
#loop through each line for the file and use sed to remove the comment line
#useful to clean up single line comments that I forgot to remove

declare -A delimiter_map

delimiter_map["py"]="#"
delimiter_map["java"]="\/\/"
delimiter_map["js"]="\/\/"

git diff --name-only | while read -r file; do
    #change the regex pattern depending on the filetype (.py, .js, .class)
    file_type="${file##*.}"
    
    delimiter="${delimiter_map[$file_type]}"

    if [ -z "$delimiter" ]; then
        echo "$file is of an unsupported filetype. Skipping."
        continue
    fi

    
    git diff HEAD $file | grep '+' | grep "${delimiter}" | sed 's/+\s*//' > /tmp/tempfile

    echo "Cleaning file: $file"
    while read -r comment; do
        line=$(grep -n "${comment}" "$file")
        # could be dangerous if comment is empty
        sed -i "/$comment/d" "$file"
        echo "Deleted: $line"
    done < /tmp/tempfile
    echo "Finished cleaning $file."

    rm /tmp/tempfile
done
