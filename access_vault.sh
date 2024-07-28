#!/bin/bash


manageFiles() {
    if [[ -z $1 ]]; then
        echo "Please specify the csv file that should be used to update file permissions."
        exit
    fi

    local "fileUpdateReport"="file_report_$(date +"%H:%M:%S").txt"
    echo "$(whoami) ran this script to update file permissions on $(date "+%m-%d-%Y at %H:%M:%S")" >> $"fileUpdateReport"

    IFS=","
    while read -r absoluteFilePath fileOwner userAccess groupAccess otherAccess; do
        # Check file ownership (3rd field in ls -l command)
        local username=$(ls -l $1 | awk '{print $3}')
        if [[ $fileOwner != $username ]]; then
            chown $fileOwner $absoluteFilePath
            echo "Changed owner of $absoluteFilePath to $fileOwner" >> $"fileUpdateReport"
        fi

        # Assign user, group, and other permissions to the file
        chmod u=$userAccess $absoluteFilePath
        echo "Assigned user permissions of $absoluteFilePath to $userAccess" >> $"fileUpdateReport"
        chmod g=$groupAccess $absoluteFilePath
        echo "Assigned user permissions of $absoluteFilePath to $groupAccess" >> $"fileUpdateReport"
        chmod o=$otherAccess $absoluteFilePath
        echo "Assigned user permissions of $absoluteFilePath to $otherAccess" >> $"fileUpdateReport"
    done < <(tail -n +2 $1)

    echo "Finished updating file permissions."

    setupReports $1 "files" $"fileUpdateReport"
}


manageUsers() {
    # Verify that a csv file was given to run this script with
    if [[ -z $1 ]]; then
        echo "Please specify the csv file that should be used to update user permissions."
        exit
    fi

    local userUpdateReport="user_report_$(date +"%H:%M:%S").txt"
    echo "$(whoami) ran this script to update user permissions on $(date "+%m-%d-%Y at %H:%M:%S")" >> "$userUpdateReport"

    IFS=","
    while read -r username primaryGroup otherGroups homeDirectory lockAccount; do
        # Create the user if the user does not exist
        if [[ ! $(id -u "$username") ]]; then
            # Add the user with the specified home directory
            useradd -d "$homeDirectory" "$username"
            echo "Added user: "$username" with home directory: "$homeDirectory"" >> "$userUpdateReport"
        else
            # Assign the appropriate home directory to the user
            usermod -d "$homeDirectory" "$username"
            echo "Assigned "$username" home directory to: "$homeDirectory"" >> "$userUpdateReport"
        fi

        # Assign the appropriate primary group to the user
        usermod -g "$primaryGroup" "$username"
        echo "Assigned "$username" primary group to: "$primaryGroup"" >> "$userUpdateReport"

        # Create a comma-separated string containing the elements from the other groups list
        otherGroupList="${otherGroups// /,}"
        # Assign the appropriate other group(s) to the user
        usermod -G "$otherGroupList" "$username"
        echo "Assigned "$username" other groups to: "$otherGroupList"" >> "$userUpdateReport"

        # Lock or unlock the user's account depending on the provied selection
        if [[ "$lockAccount" == "N" ]]; then
            usermod -U "$username"
            echo "Unlocked "$username" account" >> "$userUpdateReport"
        else
            usermod -L "$username"
            echo "Locked "$username" account" >> "$userUpdateReport"
        fi
    done < <(tail -n +2 $1)

    echo "Finished updating user permissions."

    setupReports $1 "users" "$userUpdateReport"
}

setupReports() {
    if [[ -z $1 && -z $2 && -z $3 ]]; then
        echo "csv file must be passed as an argument to setup_reports.sh, and files or users should be specified, and filename should be specified"
        exit
    fi

    local csvFile=$1
    local reportType=$2
    local report=$3

    if [[ -f ".reports_path.txt" ]]; then
        reportPath=$(< .reports_path.txt)
    else
        read -p "Please enter the absolute path of the location for where you want to store the access vault auto-generated reports: " path
        echo "$path" > .reports_path.txt
        chmod u=rwx,g=rwx,o= "$path"
        reportPath="$path"
    fi

    # Store directory paths in variables for easier access
    local reportsDirectory="$reportPath/access_vault_reports"
    local dayReports="$reportsDirectory/$(date +"%m-%d-%Y")"
    local timeReports=$dayReports"/$(date +"%H:%M:%S")"

    if ! [[ -d "$reportsDirectory" ]]; then
        mkdir "$reportsDirectory"
    fi

    if ! [[ -d "$dayReports" ]]; then
        mkdir "$dayReports"
    fi

    if ! [[ -d "$timeReports" ]]; then
        mkdir "$timeReports"
    fi

    # Append the file report to the directory marking the time of this script being run, do not overwrite existing files
    mv -n "$report" "$timeReports"

    # Store a copy of the csv file used to update file or user permissions
    cp "$csvFile" "$timeReports/$reportType.csv.bak"

    echo "Finished generating $reportType reports."
}


filePermissionsSetup() {
    read -r -p "Please enter the abolute path of the csv file you want to use for the file permissions update: " csvPathFile
    manageFiles "$csvPathFile"
}

userPermissionsSetup() {
    read -r -p "Please enter the abolute path of the csv file you want to use for the user permissions update: " csvPathUser
    manageUsers "$csvPathUser"
}

# cd to the directory where this script is located in
cd $(dirname "$(realpath $0)")

IFS=""

declare permissionOptions
permissionOptions=("Update File Permissions" "Update User Permissions" "Exit")

PS3="What do you want to update: "
select permissionType in ${permissionOptions[@]}; do
    case $permissionType in
        "Update File Permissions")
            filePermissionsSetup
            ;;
        "Update User Permissions")
            userPermissionsSetup
            ;;
        "Exit")
            exit
            ;;
        *)
            echo "Invalid selection."
            ;;
    esac
done
