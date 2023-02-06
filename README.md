# Velocity Update Script
This script checks for updates to the [Velocity](https://velocitypowered.com) server proxy jar and downloads them if available.

## Prerequisites
- jq
- curl
- unzip
- tmux

Please make sure these dependencies are installed before running the script.

## Usage
- Clone this repository and navigate to the directory where the script is located.
- Make it executable using `chmod +x update.sh`.
- Run the script using `./update.sh`.
## What it does
1. Checks if all required dependencies are installed.
2. Retrieves the version and build number of the local Velocity installation.
3. Checks for updates to Velocity using the papermc API.
4. Prompts the user to confirm the update.
5. Stops the Velocity server if it is running.
6. Archives the old version of Velocity.
7. Downloads the latest version of Velocity.
8. Starts the Velocity server in a tmux session.
## Notes
The name of the tmux session where Velocity is running is defined as `tmuxSession='velocity'` in the script. Change this if your tmux session has a different name.

The script assumes that you have Velocity installed and that it is started using a script named `start.sh`.
