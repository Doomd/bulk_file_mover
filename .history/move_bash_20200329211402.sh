#!/bin/zsh
# Edit these paths if you need/want to:
destPath="archive" # destination parent path/folder where we'll copy our path structure
pList="path_list.txt" # text file list of all paths we should include in our filename search
fList="file_list.txt" # text file list of all filenames to move

# DO NOT EDIT BELOW THIS LINE UNLESS YOU KNOW WHAT YOU'RE DOING

pathList=()
while IFS= read -r line || [[ "$line" ]];
    do
        pathList+=("$line")
    done < $pList

for p in "${pathList[@]}"
    do
        mkdir -p $destPath/$p
    done

while IFS= read -r file;
    do
        for p in "${pathList[@]}"
            do
                mv $p/$file $destPath/$p/$file
            done
    done < $fList