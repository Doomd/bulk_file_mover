#!/bin/bash

#### Edit these paths if you need/want to:
pathListFile="path_list.txt" # text file list of all top level directory paths we should include in our filename search
fileListFile="file_list.txt" # text file list of all filenames to move
subDirDepth=5 # how many potential subdirectories should we include/search?
includeParentDir="yes" # "yes/no" include files IN the root/parent directory?

#### COPY, MOVE, or DELETE! ####
action="cp -p"
# choose "cp -p" (for copy with optional timestamp preservation)
# or "mv" for move
# or "rm" for delete

#### DO NOT EDIT BELOW THIS LINE UNLESS YOU KNOW WHAT YOU'RE DOING

# relevantFiles=(imagefolder/*.jpg); echo $#relevantFiles
parentDir=".." # Root/Parent Directory to begin file search
parentPath="$parentDir/"
if [[ $action == *"mv"* ]]; then
	actionWord="moved"
fi
if [[ $action == *"cp"* ]]; then
	actionWord="copied"
fi
if [[ $action == *"rm"* ]]; then
	actionWord="removeD"
fi
ts_title="$(date +%Y-%m-%d-%H-%M-%S)"
ts_indented="  $(date +%Y-%m-%d-%H-%M-%S)"
destPath="backups"
destFilePath="$destPath/files"

# Log Location:
logLocation="$destPath/logs/$ts_title"
log_all="$logLocation/all.log"
log_files_touched="$logLocation/files_touched.log"
log_files_not_touched="$logLocation/files_not_touched.log"
mkdir -p "$logLocation"

title="Doomd's Bulk File Mover"
author="https://github.com/Doomd"
echo -en "$title ~ $author" >> $log_all
echo -en "\033[43m\033[30m$title\033[m\033[m \033[33m~ $author\033[m"

echo -en "\n\nCopied/Moved files will be placed in:\n  '\033[32m$destFilePath\033[m'"
echo -en "\nLog files for this session will be created in:\n  '\033[32m$logLocation\033[m'"

pathList=() ## Array for our list of directories to search
allPaths=() ## Array for ALL directories to search, including subdirectories we find
if [ "$includeParentDir" = "yes" ]; then
	pathList+=$parentDir # first path should be root/current path if wanted
fi
while IFS= read -r line || [ -n "$line" ];
    do
        pathList+=("$line")
    done < $pathListFile

## Let's get an array of different file extensions from our file list so we can exclude subdirectories that don't have these filetypes
uniqueExt="Unique File Extensions:"
echo -en "\n\n$uniqueExt\n" >> $log_all
echo -en "\n\n\033[42m\033[30m$uniqueExt\033[m\n"
fileExtensions=()
while IFS= read -r file || [ -n "$file" ];
    do
        base=${file%.*}
		extension=${file#$base.}
		if [[ "$extension"  =~ "${fileExtensions[@]}" ]]; then
			echo "  DUPLICATE file extention, '$extension' (from '$file'). Skipped."
		else
			if [[ ! "$extension"  =~ "${fileExtensions[@]}" ]]; then
				fileExtensions+=("$extension")
				echo "  UNIQUE file extention, '$extension' (from '$file') added to fileExtensions array."
			fi
		fi
   	done < $fileListFile

trim() {
    local var="$*"
    # remove leading whitespace characters
    var="${var#"${var%%[![:space:]]*}"}"
    # remove trailing whitespace characters
    var="${var%"${var##*[![:space:]]}"}"
    printf '%s' "$var"
}

i=1 ## create an index for our allPaths array (compatible w bash & zsh)

## for every directory in path list...
pathsToSearch="PATHS to Search:"
echo -en "\n$pathsToSearch\n" >> $log_all
echo -en "\n\033[42m\033[30m$pathsToSearch\033[m\n"
for p in "${pathList[@]}"
	do
		if [[ " ${allPaths[@]} " =~ " $p " ]]; then
			## if a subdirectory already matches a listed path, skip
			echo "$ts_indented > A listed path [$p] is a duplicate of an allPaths array item. Skipping it." | tee -a $log_all
		fi
		if [[ ! " ${allPaths[@]} " =~ " $p " ]] ; then
			## if the path is the parent directory...
			if [[ "$p" =~ "$parentDir" ]]; then
				allPaths[$i]=$p
				echo "$ts_indented > allPaths[$i] = '${allPaths[i]}' (Parent Directory)" | tee -a $log_all
				((i++))
			fi
			## if the path is not the parent directory, add the parent directory to path
			if [[ ! "$p" =~ "$parentDir" ]]; then
				allPaths[$i]="$parentDir/$p"
				echo "$ts_indented > allPaths[$i] = '${allPaths[i]}' (Listed Subdirectory)" | tee -a $log_all
				((i++))
				## ...and for each subdirectory of all paths...
				for subdir in $(find $parentDir/$p -maxdepth $subDirDepth -type d)
					do
						if [ -d "$subdir" ]; then
							if [[ " ${allPaths[@]} " =~ " ${subdir} " ]]; then
								echo "$ts_indented > A found subdirectory [${subdir}] is a duplicate of a allPaths path. Skipping it." | tee -a $log_all
							else
								for fileType in "${fileExtensions[@]}"
									do
										numFiles=$((`ls ${subdir} | grep $fileType | wc -l`))
										if [ $numFiles -gt 0 ]; then
											echo "  There are [$numFiles] files with '$fileType' ext in '$parentDir/${subdir}'" | tee -a $log_all
											if [[ ! " ${allPaths[@]} " =~ " $parentDir/${subdir} " ]]; then
												allPaths[$i]="$subdir"
												echo "$ts_indented > allPaths[$i] = '${allPaths[i]}' (Found Subdirectory)" | tee -a $log_all
												((i++))
												break
											fi
										else
											echo "  There are 0 files with '$fileType' ext in '$parentDir/${subdir}'. Skipping it." | tee -a $log_all
										fi

									done
							fi
						fi
					done
			fi
		fi
	done

filesAction="FILES Action:"
echo -en "\n$filesAction\n" >> $log_all
echo -en "\n\033[42m\033[30m$filesAction\033[m\n"

files_touched_header="Files $actionWord [ $ts_title ]\n\n"
echo -en $files_touched_header >> $log_files_touched
files_not_touched_header="Files NOT Found (and NOT $actionWord) [ $ts_title ]\n\n"
echo -en $files_not_touched_header >> $log_files_not_touched

while IFS= read -r file || [ -n "$file" ];
    do
        for path in "${allPaths[@]}"
			do
				if test -f "$path/$file"; then
					echo "$ts_indented > '$file' was found in '$path' directory." | tee -a $log_all
					if [ "$path" = "$parentDir" ]; then
						if [ -d " $destFilePath " ]; then
							echo "$ts_indented > '$destFilePath' directory already exists." | tee -a $log_all
						else
							mkdir -p "$destFilePath"
							echo "$ts_indented > '$destFilePath' directory created." | tee -a $log_all
						fi
					else
						noParentPath="${path#$parentPath}"
						if [ -d " $destFilePath/$path " ]; then
							echo "$ts_indented > '$destFilePath/$path' directory already exists." | tee -a $log_all
						else
							mkdir -p "$destFilePath/$noParentPath"
							echo "$ts_indented > '$destFilePath/$noParentPath' directory created." | tee -a $log_all
						fi
					fi
					## if the file is IN the root/parent directory...
					if [ "$path" = "$parentDir" ]; then
						$action "$path/$file" "$destFilePath/$file"
						echo "$ts_indented > '$file' $actionWord from '$path' to '$destFilePath'" | tee -a $log_all
						echo "$destFilePath/$file" >> $log_files_touched
					## else if it's in a subfolder(s) of the parent directory
					else
						$action "$path/$file" "$destFilePath/$noParentPath/$file"
						echo "$ts_indented > '$file' $actionWord from '$path' to '$destFilePath/$noParentPath'" | tee -a $log_all
						echo "$destFilePath/$noParentPath/$file" >> $log_files_touched
					fi
				else
					echo "$ts_indented > '$file' was not found in '$path' directory" | tee -a $log_all
					if [ "$path" = "$parentDir" ]; then
						echo "$destFilePath/$file" >> $log_files_not_touched
					else
						echo "$destFilePath/$noParentPath/$file" >> $log_files_not_touched
					fi
				fi
			done
   done < $fileListFile
