## Move Bulk Files from a List (Shell Script)

### Introduction & Use Case
This is a very basic MacOS/UNIX/LINUX shell script that will copy or move a long list of files that could be inside multiple folders, all while maintining the existing folder/tree structure of your files and LEAVING behind files that aren't included in your move list. If you have a long list of files to move, that could be inside many different folders, but you don't want to move EVERYTHING from inside your folders, then this script is for you.

More specifically, this script does the following:
1.  Reads a file which contains a list of all the filenames you want to move and creates an array of all the unique filetype extensions in your list of filenames
2.  Starting with the top level folders you list in the paths_list.txt file, it will check all subdirectories recursively for the existence of any files with the same unique filetypes from your file list and create an array of relevant paths (directories) to search in.
3. Then, the script goes to work: It will move (or copy) all files on your list that are in ANY of the relevant directories into a folder (backups/files), copying the exact file structure beginning with the parent directory (so you can easy reverse the move if you need to)
4. All actions are meticulously logged into 4 different log files which are placed in (backups/logs) so you'll know which files found, where they were found, and where they were moved, and which files weren't found (or moved).

**OPTIONAL BACKSTORY:** *I made this script because I had to move over 100K potentially copyright infringing image files from out of a public webserver directory based on a list that was generated via an SQL query for all files uploaded before 2017. Each filename could be duplicated dozens of times over in many different folders (ie, `images/somespookyimage.jpg, images/thumbnail/somespookyimage.jpg, images/large/somespookyimage.jpg` etc) and the only way of knowing each file's creation date was by inferring it from corresponding drupal node/articles that dated before some day in 2017 when this website publisher began using official stock images. The file system's dates were not accurate because all the files were at some point moved from one server to another, and all create dates were set to the date the files were copied over. We could determine file dates via the Drupal MySQL database, thankfully. We went through all this trouble because my client was tired of copyright trolls suing him for images uploaded over 5 years ago that his staff thought were "creative commons" (but apparently were not), and he basically decided to move/delete all potentially copyright infringing images from his server until he could ensure each image was indeed copyright free.*

**If you're interested:** I generated my list of files with an SQL Query on a Drupal database and cleaned it up in a Google Spreadsheet. [Here's a gist of those MySQL queries](https://gist.github.com/Doomd/ce238a10661b17965357c600c3e0c765)

**WHAT THIS SCRIPT ISN'T:** If your filesystem data is sound, (in particular, your file creation/modified dates), then there are easier ways to move files based on creation date. There are hundreds of scripts out there, I'm sure, that will help you use bash and/or regex to bulk move selected files based on filesystem metadata.

### Requirements
You'll need to be able to run Linux/Unix/Mac shell scripts, obviously. And this script assumes you are able to generate a line separated list of filenames that you want to move (like we were able to), and assumes you also have a list of folders these files might reside in.

### Files & Folders Explaination
1. The relevant script itself is in the `move_files_script` folder. **Copy this entire folder** to the source/parent directory that contains the files (and relevant child folders) that you want to move.
   - `move.sh` : The actual script file.
   - `path_list.txt` : A line seperated list of filenames
   - `file_list.txt` : A line seprated list of paths to include
2. The repository also contains documenation, and a sample, sibiling folder (with files) if you want to test the script first. These files/folders are optional and non-essential.
   - `source_sample` : This is an example "child" directory of the parent directory (and a sibling to the `move_files_script` folder). I've included some public domain images in this folder, with sample sudirectories, to demonstrate the script's reach.
   - `README.md` : This file
   - `LICENSE.md` : A file explaining where the public domain sample image files came from.

### Sample Folder Structure
This folder tree illustrates where to place the script folder in relation to the files you want to move:

parent
 ┣ move_files_script
 ┃ ┣ file_list.txt
 ┃ ┣ move.sh
 ┃ ┗ path_list.txt
 ┣ source_sample
 ┃ ┣ large
 ┃ ┃ ┣ file_to_leave_alone.jpg
 ┃ ┃ ┗ large_file.jpg
 ┃ ┣ sub1
 ┃ ┃ ┣ sub2
 ┃ ┃ ┃ ┣ sub3
 ┃ ┃ ┃ ┃ ┣ file.jpg
 ┃ ┃ ┃ ┃ ┗ file_to_leave_alone.jpg
 ┃ ┣ thumbnails
 ┃ ┃ ┣ file_to_leave_alone.jpg
 ┃ ┃ ┗ thumbnail.jpg
 ┃ ┣ file with spaces.jpg
 ┃ ┣ file(with parentheses).jpg
 ┃ ┣ file-with-dashes.jpg
 ┃ ┣ file_diff_format.png
 ┃ ┗ file_to_leave_alone.jpg
 ┣ file with spaces.jpg
 ┣ file(with parentheses).jpg
 ┣ file-with-dashes.jpg
 ┗ file_to_leave_alone.jpg

### Instructions
1. Download or Clone this repository. You only need the folder `move_files_script`, but I've included the `source_sample` folder if you want to perform testing on fake files before touching your own. Inside a terminal window, navigate to the `move_files_script` folder.
2. Ensure you have the correct permissions to run the shell script:
```
$ chmod +x move.sh
```
1. Edit the top lines of the `move.sh` script if you want to edit some of the basic settings (name of the file where your files and path names are listed, whether you want the action to be "cp" or "mv", etc).
      >*I highly recommend that you do a small test run using the `"cp -p"` action instead of `"mv"`...to make sure you're targetting the files that you want before you do an actual move.*
2. The script will search through all the directories (and their subdirectories to the depth you specify) that are listed in `path_list.txt` and move all matching filenames that are listed in `file_list.txt` into a new folder inside the script directory (`backups/files`). If you'd like to run a test to see it work before you start editing the text files to include your own list of files and paths, go ahead:
```
$ bash move.sh
```
3. Open and edit the move.sh script in an editor and adjust the options as needed.
4. The script will by default, start searching for files in the parent folder the script folder is placed in. It will NOT automatically search inside every folder that's inside this parent directory. You need to specify which child folders you want to search in by listing them in the `path_list.txt` file. But you don't need to specify `child/child` or `child/child/child` folders. It will recursively search through all listed top-level child folders for as many subfolder levels as you specify (default depth is 5). Don't include trailing backslashes in any of your folder path names (ie, `thumbnails` is good.
`thumbnails/` IS BAD. Put a new path on each line.
5. Insert a list of all the filenames you'd like to move into `file_list.txt` ensuring that there is only one filename on each line. The script should work if the filenames include spaces or most special characters, but I didn't do thorough testing, so probably don't include weird things in your file names to be safe.

That's basically it. Run the script again once you've edited `path_list.txt` and `file_list.txt` with your own files and paths. All the files you WANT to move will be moved to `backups/files` (inside the script folder) with the existing structure maintained, and all the files NOT included in your `file_list.txt` will be safely left in place. Logs are placed inside the script folder at `backups/logs`

Cheers!