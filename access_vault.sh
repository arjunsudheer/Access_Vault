#!/bin/bash

manageFiles() {
    if [[ -z $1 ]]; then
        echo "Please specify the csv file that should be used to update file permissions."
        exit
    fi

    local fileUpdateReport="file_report_$(date +"%H:%M:%S").txt"
    echo "$(whoami) ran this script to update file permissions on $(date "+%m-%d-%Y at %H:%M:%S")" >> $fileUpdateReport

    IFS=","
    while read -r absoluteFilePath fileOwner userAccess groupAccess otherAccess; do
        # check file ownership (3rd field in ls -l command)
        username=$(ls -l $1 | awk '{print $3}')
        if [[ $fileOwner != $username ]]; then
            chown $fileOwner $absoluteFilePath
            echo "Changed owner of $absoluteFilePath to $fileOwner" >> $fileUpdateReport
        fi
        # check user access
        changeFilePermissions $absoluteFilePath $userAccess "user" "u" 0 $fileUpdateReport
        # check group access
        changeFilePermissions $absoluteFilePath $groupAccess "group" "g" 1 $fileUpdateReport
        # check other access
        changeFilePermissions $absoluteFilePath $otherAccess "other" "o" 2 $fileUpdateReport
    done < <(tail -n +2 $1)

    setupReports $1 "files" $fileUpdateReport
}


# Helper functions
changeFilePermissions() {
    # expects abolute file path as first parameter, access level (from csv file)
    # access level name (user/group/other) as second parameter, the character to
    # use for updates (u/w/r), position of the access rights (u=0, w=1, x=2), and
    # the fileReports file to append change messages to
    if [[ -z $1 || -z $2 || -z $3 || -z $4 || -z $5 || -z $6 ]]; then
        return
    fi

    # Check for read permissions
    if [[ "$2" == *"r"* ]]; then
        # pipe the ls -l command to the cut command to check for lack of read permissions
        if [[ $(ls -l $1 | cut -c $(( $5 * 3 + 2 ))-$(( $5 * 3 + 2 ))) == "-" ]]; then
            chmod $4+r $1
            echo "Added read access to $3 for $1" >> $6
        fi
    else
        # pipe the ls -l command to the cut command to check for read permissions
        if [[ $(ls -l $1 | cut -c $(( $5 * 3 + 2 ))-$(( $5 * 3 + 2 ))) == "r" ]]; then
            chmod $4-r $1
            echo "Removed read access from $3 for $1" >> $6
        fi
    fi

    # check for write permissions
    if [[ "$2" == *"w"* ]]; then
        # pipe the ls -l command to the cut command to check for lack of write permissions
        if [[ $(ls -l $1 | cut -c $(( $5 * 3 + 3 ))-$(( $5 * 3 + 3 ))) == "-" ]]; then
            chmod $4+r $1
            echo "Added write access to $3 for $1" >> $6
        fi
    else
        # pipe the ls -l command to the cut command to check for write permissions
        if [[ $(ls -l $1 | cut -c $(( $5 * 3 + 3 ))-$(( $5 * 3 + 3 ))) == "w" ]]; then
            chmod $4-r $1
            echo "Removed write access from $3 for $1" >> $6
        fi
    fi

    # check for execute permissions
    if [[ "$2" == *"x"* ]]; then
        # pipe the ls -l command to the cut command to check for lack of execute permissions
        if [[ $(ls -l $1 | cut -c $(( $5 * 3 + 4 ))-$(( $5 * 3 + 4 ))) == "-" ]]; then
            chmod $4+r $1
            echo "Added execute access to $3 for $1" >> $6
        fi
    else
        # pipe the ls -l command to the cut command to check for execute permissions
        if [[ $(ls -l $1 | cut -c $(( $5 * 3 + 4 ))-$(( $5 * 3 + 4 ))) == "x" ]]; then
            chmod $4-r $1
            echo "Removed execute access from $3 for $1" >> $6
        fi
    fi
}


manageUsers() {
    # verify that a csv file was given to run this script with
    if [[ -z $1 ]]; then
        echo "Please specify the csv file that should be used to update user permissions."
        exit
    fi

    userReport="user_report_$(date +"%H:%M:%S").txt"
    echo "$(whoami) ran this script to update user permissions on $(date "+%m-%d-%Y at %H:%M:%S")" >> $userReport

    setupReports $1 "users" $userReport
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
        echo $path > .reports_path.txt
        chmod u=rwx,g=rwx,o= $path
        reportPath=$path
    fi

    # store directory paths in variables for easier access
    local reportsDirectory="$reportPath/access_vault_reports"
    local dayReports="$reportsDirectory/$(date +"%m-%d-%Y")"
    local timeReports=$dayReports"/$(date +"%H:%M:%S")"

    if ! [[ -d $reportsDirectory ]]; then
        mkdir $reportsDirectory
    fi

    # temporarily allow for write access to the access_vault_reports hidden directory to create the other folders and files
    chmod u+w $reportsDirectory

    if ! [[ -d $dayReports ]]; then
        mkdir $dayReports
    else
        # temporarily allow for write access to the $dayReports directory to create the other folders and files
        chmod u+w $dayReports
    fi

    if ! [[ -d $timeReports ]]; then
        mkdir $timeReports
    fi

    # append the file report to the directory marking the time of this script being run, do not overwrite existing files
    mv -n $report $timeReports

    cp $csvFile $timeReports/$reportType.csv.bak

    # don't give write access to anyone so that the access_vault_reports directory and subdirectores/files cannot be deleted or modified
    chmod u=rx,g=rx,o= $reportsDirectory $dayReports $timeReports $timeReports/$report $timeReports/$reportType.csv.bak
}


# cd to the directory where this script is located in
cd $(dirname "$(realpath $0)")

IFS=""

declare permissionOptions
permissionOptions=("Update File Permissions" "Update User Permissions" "Update File and User Permissions" "Exit")

PS3="What do you want to update (type the name of the command or the associated number): "
select permissionType in ${permissionOptions[@]}; do
    case $permissionType in
        1|"Update File Permissions")
            read -r -p "Please enter the abolute path of the csv file you want to use for the file permissions update: " csvPathFile
            manageFiles $csvPathFile
            ;;
        2|"Update User Permissions")
            read -r -p "Please enter the abolute path of the csv file you want to use for the user permissions update: " csvPathUser
            manageUsers $csvPathUser
            ;;
        3|"Update File and User Permissions")
            read -r -p "Please enter the abolute path of the csv file you want to use for the file permissions update: " csvPathFile
            manageFiles $csvPathFile
            read -r -p "Please enter the abolute path of the csv file you want to use for the user permissions update: " csvPathUser
            manageUsers $csvPathUser
            ;;
        4|"Exit")
            exit
            ;;
        *)
            echo "Invalid selection."
            ;;
    esac
done
