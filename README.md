## Move Bulk Files from a List (Shell Script)

### Introduction & Use Case
This is a very basic MacOS/UNIX/LINUX shell script that will move a long list of files that could be inside multiple folders, all while maintining the existing folder/tree structure of your files and LEAVING behind files that aren't included in your move list. If you have a long list of files to move, but don't want to move EVERYTHING from inside your folders, then this script is for you.

**OPTIONAL BACKSTORY:** *I made this script because I had to move over 100K potentially copyright infringing image files from out of a public webserver directory based on a list that was generated via an SQL query for all files uploaded before 2017. Each filename could be duplicated dozens of times over in many different folders (ie, `images/somespookyimage.jpg, images/thumbnail/somespookyimage.jpg, images/large/somespookyimage.jpg` etc) and the only way of knowing each file's creation date was by inferring it from corresponding drupal node/articles that dated before some day in 2016 when this website publisher began using official stock images. The file system's dates were not accurate because all the files were at some point moved from one server to another, and all create dates were set to the date the files were copied over. We could determine file dates via the Drupal MySQL database, thankfully. We went through all this trouble because my client was tired of copyright trolls suing him for images uploaded over 5 years ago that his staff thought were "creative commons" (but apparently were not), and he basically decided to move/delete all potentially copyright infringing images from his server until he could ensure each image was indeed copyright free.*

**If you're interested:** I generated my list of files with an SQL Query on a Drupal database and cleaned it up in a Google Spreadsheet. [Here's a gist of those MySQL queries](https://gist.github.com/Doomd/ce238a10661b17965357c600c3e0c765)

**WHAT THIS SCRIPT ISN'T:** If your filesystem data is sound, (in particular, your file creation/modified dates), then there are easier ways to move files based on creation date. There are hundreds of scripts out there, I'm sure, that will help you use bash and/or regex to bulk move selected files based on filesystem metadata.

### Requirements
You'll need to be able to run *nix shell scripts, obviously. And this script assumes you are able to generate a line separated list of filenames that you want to move (like we were able to), and assumes you also have a list of folders these files might reside in.

### Files & Folders Explaination
1. There are 3 files you need to be concerned with:
   - `move.sh` : The main very simple script file.
   - `path_list.txt` : A line seperated list of filenames
   - `file_list.txt` : A line seprated list of paths to include
1. The two default folders are:
   - `source_files` : Where your original files are. I've included some public domain images in this folder as an example.
   - `archive` : Where you'd like to move your folder structure and files to.

### Instructions
1. Download or Clone this repository and navigate to it with a new terminal window
2. Ensure you have the correct permissions to run the shell script:
```
$ chmod +x move.sh
```
3. Edit the move.sh script if you want to change your destination folder. It defaults to `destPath="archive"`
4. The script will search through all the directories that are listed in `path_list.txt` and move all matching filenames that are listed in `file_list.txt` into a new folder (in the default case, it's called `archive`). If you'd like to run a test to see it work before you start editing the text files to include your own list of files and paths, go ahead:
```
$ bash move.sh
    or...
$ zsh move.sh
```
5. To have the script search through your own folder tree for your own files, edit the `path_list.txt` file with a list of directory paths you want to move files from. Don't include a trailing backslash:
(ie, `source_files/thumbnails` is good.
`source_files/thumbnails/` IS BAD.
Put a new path on each line. Leave an empty line on the last line.
6. Insert a list of all the filenames you'd like to move into `file_list.txt` ensuring that there is only one filename on each line. The script should work if the filenames include spaces or most special characters, but I didn't do thorough testing, so probably don't include weird things in your file names to be safe. Leave an empty line on the last line.

That's basically it. Run the script again, and all the files you WANT to move will be moved to your destination directory with the existing structure maintained, and all the files NOT included in your file_list.txt will be safely left in place.

Cheers!