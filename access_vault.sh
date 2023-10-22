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
        local username=$(ls -l $1 | awk '{print $3}')
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

    echo "Finished updating file permissions."

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
            chmod $4+w $1
            echo "Added write access to $3 for $1" >> $6
        fi
    else
        # pipe the ls -l command to the cut command to check for write permissions
        if [[ $(ls -l $1 | cut -c $(( $5 * 3 + 3 ))-$(( $5 * 3 + 3 ))) == "w" ]]; then
            chmod $4-w $1
            echo "Removed write access from $3 for $1" >> $6
        fi
    fi

    # check for execute permissions
    if [[ "$2" == *"x"* ]]; then
        # pipe the ls -l command to the cut command to check for lack of execute permissions
        if [[ $(ls -l $1 | cut -c $(( $5 * 3 + 4 ))-$(( $5 * 3 + 4 ))) == "-" ]]; then
            chmod $4+x $1
            echo "Added execute access to $3 for $1" >> $6
        fi
    else
        # pipe the ls -l command to the cut command to check for execute permissions
        if [[ $(ls -l $1 | cut -c $(( $5 * 3 + 4 ))-$(( $5 * 3 + 4 ))) == "x" ]]; then
            chmod $4-x $1
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

    local userUpdateReport="user_report_$(date +"%H:%M:%S").txt"
    echo "$(whoami) ran this script to update user permissions on $(date "+%m-%d-%Y at %H:%M:%S")" >> $userUpdateReport

    IFS=","
    while read -r username primaryGroup otherGroups homeDirectory lockAccount; do
        # check if the user exists
        if [[ $(id -u $username) ]]; then
            # check if the user's primary group has changed
            if [[ $(id -gn $username) != $primaryGroup ]]; then
                $(usermod -g $primaryGroup $username)
                echo "Changed $username primary group to: $primaryGroup" >> $userUpdateReport
            fi

            # check if the user's other groups have changed
            declare -a currentOtherGroups
            currentOtherGroups=$(id -Gn $username)
            addNewGroup=true
            # check if there are any new other groups that need to be added
            for otherGroupAdd in $otherGroupsAdd; do
                for currentOtherGroupAdd in $currentOtherGroupsAdd; do
                    if [[ $currentOtherGroupAdd == $otherGroupAdd ]]; then
                        addNewGroup=false
                        break
                    fi
                done
                if [[ $addNewGroup ]]; then
                    usermod -a -G $otherGroupAdd $username
                    echo "Added $username to other group: $otherGroupAdd" >> $userUpdateReport
                fi
                addNewGroup=true
            done

            currentOtherGroups=$(id -Gn $username)
            removeNewGroup=true
            # check if there are any existing other groups that need to be removed
            # remove the user from all other groups so the desired ones can be manually added back
            usermod -G "" $username
            for currentOtherGroup in $currentOtherGroups; do
                for otherGroup in $otherGroups; do
                    if [[ $currentOtherGroup == $otherGroup ]]; then
                        removeNewGroup=false
                        break;
                    fi
                done
                if [[ $removeNewGroup ]]; then
                    echo "Removed $username from other group: $otherGroupAdd" >> $userUpdateReport
                else
                    usermod -a -G $otherGroup $username
                fi
                removeNewGroup=true
            done

            # check if the user's home directory has changed
            if [[ $(~$username) != $homeDirectory]]; then
                $(usermod -d $homeDirectory $username)
                echo "Changed $username home directory to: $homeDirectory" >> $userUpdateReport
            fi
        else
            # add the user with the specified home directory
            useradd -d $homeDirectory $username
            echo "Added user: $username with home directory: $homeDirectory" >> $userUpdateReport
            # add the primary group to the user
            usermod -g $primaryGroup $username
            echo "Added $username to primary group: $primaryGroup" >> $userUpdateReport
            for group in $otherGroups; do
                # add all specified other groups to the user
                usermod -a -G $group $username
                echo "Added $username to other group: $group" >> $userUpdateReport
            done
            if [[ $lockAccount == "N" ]]; then
                usermod -U $username
                echo "Unlocked $username account" >> $userUpdateReport
            else
                usermod -L $username
                echo "Locked $username account" >> $userUpdateReport
            fi
        fi
    done < <(tail -n +2 $1)

    echo "Finished updating user permissions."

    setupReports $1 "users" $userUpdateReport
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

    echo "Finished generating $reportType reports."
}


filePermissionsSetup() {
    read -r -p "Please enter the abolute path of the csv file you want to use for the file permissions update: " csvPathFile
    manageFiles $csvPathFile
}

userPermissionsSetup() {
    read -r -p "Please enter the abolute path of the csv file you want to use for the user permissions update: " csvPathUser
    manageUsers $csvPathUser
}

# cd to the directory where this script is located in
# cd $(dirname "$(realpath $0)")

IFS=""

declare permissionOptions
permissionOptions=("Update File Permissions" "Update User Permissions" "Update File and User Permissions" "Exit")

PS3="What do you want to update (type the name of the command or the associated number): "
select permissionType in ${permissionOptions[@]}; do
    case $permissionType in
        1|"Update File Permissions")
            filePermissionsSetup
            ;;
        2|"Update User Permissions")
            userPermissionsSetup
            ;;
        3|"Update File and User Permissions")
            filePermissionsSetup
            userPermissionsSetup
            ;;
        4|"Exit")
            exit
            ;;
        *)
            echo "Invalid selection."
            ;;
    esac
done
