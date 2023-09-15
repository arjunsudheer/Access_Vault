# Access Vault

Access Vault is a tool meant to help organizations easily manage file and user permissions. This helps organizations follow the principle of least priviledge. The principle of least priviledge states that authorization and access to documents and assets should only be given to those that need permission.

## Installation Guide 

This section will talk about how to install the neccessary componenets and get the access vault up and running on your system.

### Bash Installation Guide

These access vault use the Bash shell. The curent supported Bash version is Bash 3. 

#### Mac Users

If you are on Mac, then your default shell is set to zsh. Although many features across bash and zsh are similar, you will get the best results if you [switch your default shell to bash](https://www.cyberciti.biz/faq/change-default-shell-to-bash-on-macos-catalina/).

To summarize the article above, you can run the following command in your terminal:

```chsh -s bin/bash```

After you run this command, then relaunch your terminal and your default shell should now be bash. 

#### Windows Users

If you are on Windows, we recommend that you install Windows Subsystem for Linux 2 (WSL2). This will allow you to use a Linux environment directly in Windows without needing to dual boot. 

We recommend you follow [Microsoft's documentation on how to install WSL2 for your Windows machine](https://learn.microsoft.com/en-us/windows/wsl/install). 

To summarize the article above, you can run the following command in powershell:

```wsl --install```

This will install the default Linux distribution which is Ubuntu. If you prefer to install a different distribution, then please refer to Microsoft's documentation as they explain how to do so. 

Once WSL2 is installed, you should run the access vault inside of WSL2 instead of Windows command prompt or powershell. 

The default shell in WSL2 should be bash. Refer to the next section for Linux Users to confirm if your default shell is bash.

#### Linux Users

Your default shell should already be bash. You can verify this by running the following command:

```echo $SHELL```

If the path printed points towards bash, then you are good to go. If not, then please change your default shell to bash by following the appropriate steps for your Linux distribution.

### Dowloading access vault to your device

In order to download the access vault, we recommend that you download the zip file of the access vault bash script onto your computer.

***Note:** Please make sure to change which OS you are running at the top of the file to get the most accurate instructions.*

## How to Use Access Vault

### Setting up files for access vault to run effectively

Once you have the access vault downloaded, you can begin using it.

In the terminal, run the following command to use access vault.

```bash <path to main.sh>```


## Access_Tracker.xlsx

Access_Tracker.xlsx is a spreadsheet with some values for managing user and file permissions. You can use this template to keep track of user and file permissions. Access Vault expects input in the form of a csv with the columns seen in Access_Tracker.xlsx. The first row has been filled out for example purposes.