#!/bin/bash
# Author: @certainly1182
# Description: Checks for updates to Velocity and downloads them if available

# Define the API URL
apiURL="https://papermc.io/api/v2/projects/velocity"
# Name of the tmux session where Geyser is running
tmuxSession='velocity'

getLocalBuild() {
    localBuild=$(unzip -p "velocity-3.2.0-SNAPSHOT-220.jar" META-INF/MANIFEST.MF | grep "Implementation-Version" | grep -o 'b[0-9]\{3\}' | awk -F'b' '{print $2}')
}

checkForUpdates() {
    # Check the lastest version and build
    latestVersion=$(curl -s "$apiURL" | jq '.versions[-1]')
    latestBuild=$(curl -s "$apiURL/versions/$latestVersion" | jq '.builds[-1]')
    # Check if the current version is up to date
    localChecksum=$(sha256sum velocity-*.jar | awk '{print $1}')
    latestChecksum=$(curl -s "$apiURL/versions/$latestVersion/builds/$latestBuild" | jq '.downloads.application.sha256' -r)
    
    if [ "$localChecksum" == "$latestChecksum" ]; then
        echo "No update available, you have the latest build ($latestBuild)"
        exit 0
    else
        echo "Update available, from $localBuild to $latestBuild"
    fi
}

confirmUpdate() {
    # Ask if the user wants to update
    while true; do
        read -r -p "Do you wish to update? [y/n] " yn
        case $yn in
            [Yy]* ) break;;
            [Nn]* ) exit;;
            * ) echo "Please answer yes or no.";;
        esac
    done
}

archiveOld() {
    # Remove the old old version
    for file in velocity-*.jar.old; do
        rm "$file"
    done

    # Rename the old version
    for file in velocity-*.jar; do
        mv "$file" "$file.old"
    done
}

downloadVelocity() {
    # Get the latest download URL
    latestDownload=$(curl -s "$apiURL/versions/$latestVersion/builds/$latestBuild" | jq '.downloads.application.name' -r)
    velocityDownloadURL="$apiURL/versions/$latestVersion/builds/$latestBuild/downloads/$latestDownload"

    # Download the latest version
    echo "Downloading Velocity $velocityDownloadURL -> $latestDownload..."
    echo "> curl --progress $velocityDownloadURL -o $latestDownload "
    curl --progress "$velocityDownloadURL" -o "$latestDownload"
    if [ $? -ne 0 ]; then
        echo "Failed to download Velocity"
        exit 1
    fi
}

stopVelocity() {
    echo "Stopping Velocity tmux session: $tmuxSession..."
    tmux kill-session -t $tmuxSession
}

startVelocity() {
    echo "Starting Velocity in a tmux session: $tmuxSession..."
    tmux new-session -d -s $tmuxSession 'sh start.sh'
}

getLocalBuild
checkForUpdates
confirmUpdate
stopVelocity
archiveOld
downloadVelocity
startVelocity