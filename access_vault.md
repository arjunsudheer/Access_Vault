# access_vault.sh Documentation

## Overview
The access_vault.sh file will automatically update user and file permissions for your organization's system. It will prompt the user with what they want to update, ask for the csv file, update permissions, and generate a report to reflect what has been changed.

**Required File Parameters:** None


## manageFiles() function
**Required parameter:** The absolute path to the csv file.

* Create a file report file containing a record of what file permissions were updated. Writes the user that ran the script and when the script was run to the first line of the file.

* Check if the owner of the file is the one specified in the csv file. If not, then update the user of the file to the one specified in the csv file. Log changes in fileUpdateReport file.

* Call the changeFilePermissions() function for the user access level, group access level, and other access level.


## changeFilePermissions() function
This function exists only to simplify the process of updating read, write, and execute permissions for files. This function is called from the manageFiles() function.

**Required parameters:** The absolute path to the file having its permissions changed, access level (r/w/x/- characters from csv file), access level name (user/group/other), the character to
    use for updates (u/w/r), position of the access rights (u=0, w=1, x=2), and the fileUpdateReport file

* Checks if the character 'r' is included.

    * If it is and the appropriate access level does not have read permissions, then add read permissions for the appropriate access level. Log changes in fileUpdateReport file.

    * If it is not and the appropriate access level has read permissions, then remove the read permissions for the appropriate access level. Log changes in fileUpdateReport file.

* Checks if the character 'w' is included.

    * If it is and the appropriate access level does not have write permissions, then add write permissions for the appropriate access level. Log changes in fileUpdateReport file.

    * If it is not and the appropriate access level has write permissions, then remove the write permissions for the appropriate access level. Log changes in fileUpdateReport file.

* Checks if the character 'x' is included.

    * If it is and the appropriate access level does not have execute permissions, then add execute permissions for the appropriate access level. Log changes in fileUpdateReport file.

    * If it is not and the appropriate access level has execute permissions, then remove the execute permissions for the appropriate access level. Log changes in fileUpdateReport file.


## manageUsers() function
**Required parameter:** The absolute path to the csv file.

* Create a user report file containing a record of what user permissions were updated. Writes the user that ran the script and when the script was run to the first line of the file.

* Checks if the user exists

    * If the user exists

        * Check if the specified primary group is different then the current primary group. If it is, then update the primary group. Log that the primary group was changed in the userUpdateReport file.

        * Check if the specified other groups is different then the current other groups. 
            
            * Store the current other groups for the user in an array

            * Loop through all the specified other groups and check if the user is already a part of that group. If they are not, then add the new other group to the user. Log that the group was added in the userUpdateReport file.

            * Update the current other groups array.

            * Remove all the other groups. Loop through all the current other groups and check if the current other group is on the specified other groups list. If they are, then add them back. If they are not, then log that the group was removed in the userUpdateReport

        * Check if the specified home directory is different then the current home directory. If it is, then update the primary group. Log that the home directory was changed in the userUpdateReport file.

    * If the user does not exist

        * Add the user with the specified home directory. Log that the user was added with the specified home directory in the userUpdateReport file.

        * Add the primary group. Log the primary group that was added to the userUpdateReport file. 
        
        * Add the other groups. Log the other groups that were added in the userUpdateReport file.

        * Lock or Unlock the account based on the specification. Log the lock status of the account in the userUpdateReport file.

***Note:*** Access Vault will not delete any users nor will it change any usernames. If this action needs to be done, please do it manually.


## setupReports() function
**Required parameter:** The absolute path to the csv file, a string specifying if this is a file or user update, the appropriate reports file.

* Request for the location of where the reports should be stored if .reports_path.txt is not specified. Otherwise, creates the directories and move reports files into the specified location.

* Checks to see if a directory exists for the current day (day, month, year). If it does not exist, then create the directory.

* Checks to see if a directory exists for the current timestamp (hour, minute, second). If it does not exist, then create the directory.

* Creates a copy of the csv file used for the update and stores it along with the generated reports.

* Allows read and execute permission for the user and group, provides no access for others. This is to prevent the tampering of the reports files.