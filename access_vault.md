# access_vault.sh Documentation

## Overview
The access_vault.sh file will automatically update user and file permissions for your organization's system. It will prompt the user with what they want to udpate, ask for the csv file, update permissions, and generate a report to reflect what has been changed.

**Required File Parameters:** None


## manageFiles() function
**Required parameter:** The absolute path to the csv file.

* Create a file report file containing a record of what file permissions were updated. Writes the user that ran the script and when the script was run to the first line of the file.


## manageUsers() function
**Required parameter:** The absolute path to the csv file.

* Create a user report file containing a record of what user permissions were updated. Writes the user that ran the script and when the script was run to the first line of the file.


## setupReports() function
**Required parameter:** The absolute path to the csv file, a string specifying if this is a file or user update, the appropriate reports file.

* Request for the location of where the reports should be stored if .reports_path.txt is not specified. Otherwise, creates the directories and move reports files into the specified location.

* Checks to see if a directory exists for the current day (day, month, year). If it does not exist, then create the directory.

* Checks to see if a directory exists for the current timestamp (hour, minute, second). If it does not exist, then create the directory.

* Creates a copy of the csv file used for the update and stores it along with the generated reports.

* Allows read and execute permission for the user and group, provides no access for others. This is to prevent the tampering of the reports files.