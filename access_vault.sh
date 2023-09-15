#!/bin/bash

manageFiles() {
    if [[ -z $1 ]]; then
        echo "Please specify the csv file that should be used to update file permissions."
        exit
    fi

    fileReport="file_report_$(date +"%H:%M:%S").txt"
    echo "$(whoami) ran this script to update file permissions on $(date "+%m-%d-%Y at %H:%M:%S")" >> $fileReport

    setupReports $1 "files" $fileReport
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
    local fileReport=$3

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
    mv -n $fileReport $timeReports

    cp $csvFile $timeReports/$reportType.csv.bak

    # don't give write access to anyone so that the access_vault_reports directory and subdirectores/files cannot be deleted or modified
    chmod u=rx,g=rx,o= $reportsDirectory $dayReports $timeReports $timeReports/$fileReport $timeReports/$reportType.csv.bak
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
