#!/bin/bash
# Edit these paths if you need/want to:
destPath="archive" # destination parent path/folder where we'll copy our path structure
pList="path_list.txt" # text file list of all paths we should include in our filename search
fList="file_list.txt" # text file list of all filenames to move
subDirDepth=5
includeScriptDir="yes"
scriptDir="$(dirname "${BASH_SOURCE[0]}")"  # get the directory name
echo $scriptDir
#scriptDir="$(realpath "${DIR}")"    # resolve its full path if need be

# DO NOT EDIT BELOW THIS LINE UNLESS YOU KNOW WHAT YOU'RE DOING
ts_minute=$(date +%Y-%m-%d-%H-%M)
ts_second="  $(date +%Y-%m-%d-%H-%M-%S)"
# Log Location:
logLocation="$destPath/logs/$ts_minute"
log_all="$logLocation/all.log"
log_files_moved="$logLocation/files_moved.log"
log_files_not_moved="$logLocation/files_not_moved.log"
mkdir -p "$logLocation"
# exec > >(tee -i $logLocation/move_list.log)
# exec 2>&1
echo "Log files for this session will be created in: [ $logLocation ]"

## This is our list of directories to search
pathList=()
## This will be our new array of ALL directories to search, including subdirectories
allPaths=() 
if [ "$includeScriptDir" = "yes" ]; then
	pathList+=$scriptDir # first path should be root/current path if wanted
fi
while IFS= read -r line || [ -n "$line" ];
    do
        pathList+=("$line")
    done < $pList
## create an index for our allPaths array
i=1

## for every directory in path list...
echo "Let's create our array of paths..." >> $log_all

for p in "${pathList[@]}"
	do
		if [[ " ${allPaths[@]} " =~ " $p " ]]; then
			## if a subdirectory already matches a listed path, skip
			echo "$ts_second > A listed path [ $p ] is a duplicate of an allPaths array item. Skipping it." >> $log_all
		fi
		if [[ ! " ${allPaths[@]} " =~ " $p " ]] ; then
		    ## continue
			allPaths[$i]=$p
			echo "$ts_second > allPaths[$i] = ${allPaths[i]}" >> $log_all
			((i++))
			## ...and for each subdirectory...
			if [[ "$p" =~ "$scriptDir" ]]; then
				echo "fuck this"
			else
				for subdir in $(find $p -maxdepth $subDirDepth -type d)
					do
						if [ -d "$subdir" ]; then
							if [[ " ${allPaths[@]} " =~ " ${subdir} " ]]; then
		    					echo "$ts_second > An allPaths item [${allPaths[@]}] is duplicate of subdir [${subdir}]. Skipping it." >> $log_all
							fi
							if [[ ! " ${allPaths[@]} " =~ " ${subdir} " ]]; then
							    ## whatever you want to do when array doesn't contain value
								allPaths[$i]=$subdir
								echo "$ts_second > allPaths[$i] = ${allPaths[i]}" >> $log_all
								((i++))
							fi
						fi
					done
			fi
		fi
	done

echo -en "\n\nLet's find our listed file names inside our array of directory paths...\n" >> $log_all
echo -en "Files Moved [ $ts_minute ]\n\n" >> $log_files_moved
echo -en "Files NOT Found (and NOT Moved) [ $ts_minute ]\n\n" >> $log_files_not_moved

while IFS= read -r file || [ -n "$file" ];
    do
        for path in "${allPaths[@]}"
			do
				if [ "$path" = "." ]; then
					 path="<script_root>"
				fi	
				if  test -f "$path/$file" ; then
					echo "$ts_second > $file was found in $path directory." >> $log_all
						if [ -d " $destPath/$path " ]; then
							echo "$ts_second > $destPath/$path directory already exists." >> $log_all
						else
							mkdir -p "$destPath/$path"
							echo "$ts_second > $destPath/$path directory created." >> $log_all
						fi
					if [ "$path" = "." ]; then
						mv "$file" "$destPath/$file"
					else
						mv "$path/$file" "$destPath/$path/$file"
					fi	
					echo "$ts_second > $file moved from $path to $destPath/$path" >> $log_all
					echo "$destPath/$path/$file" >> $log_files_moved
				else
					echo "$ts_second > $file was not found in $path directory" >> $log_all
					echo "$destPath/$path/$file" >> $log_files_not_moved
				fi
			done
   done < $fList
