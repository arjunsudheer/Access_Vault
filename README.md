# Access Vault

Access Vault is a tool meant to help organizations easily manage file and user permissions. This helps organizations follow the principle of least privilege. The principle of least privilege states that authorization and access to documents and assets should only be given to those that need permission.

## Installation Guide 

This section will talk about how to install the necessary components and get the access vault up and running on your system.

### Bash Installation Guide

Access vault use the Bash shell.

#### Mac Users

If you are on Mac, then your default shell is set to zsh. To switch your shell to bash, run the following command in your terminal:

```
chsh -s bin/bash
```

#### Windows Users

If you are on Windows, it is recommended that you install Windows Subsystem for Linux 2 (WSL2). This will allow you to use a Linux environment directly in Windows without needing to dual boot.

For more information and guidance, you can refer to [Microsoft's documentation on how to install WSL2 for your Windows machine](https://learn.microsoft.com/en-us/windows/wsl/install). 

To summarize the article above, you can run the following command in powershell:

```
wsl --install
```

This will install the default Linux distribution which is Ubuntu. If you prefer to install a different distribution, then please refer to Microsoft's documentation as they explain how to do so.

Once WSL2 is installed, you should run the access vault inside of WSL2 instead of the Windows command prompt or powershell. 

The default shell in WSL2 should be bash. Refer to the next section for Linux Users to confirm if your default shell is bash.

#### Linux Users

You can verify if your shell is Bash by running the following command in your terminal:

```
echo $SHELL
```

If the path printed points towards bash, then you are good to go. If not, then please change your default shell to bash by following the appropriate steps for your Linux distribution.


## How to Use Access Vault

You can clone this repository by running the following command in your terminal:

```
git clone https://github.com/arjunsudheer/access-vault.git
```

### Setting up files for access vault to run effectively

Once you have cloned the access value repository, you can run access value by typing the following command in your terminal:

```
bash <path to access_vault.sh>
```

## Access_Tracker.xlsx

Access_Tracker.xlsx is a spreadsheet with some values for managing user and file permissions. You can use this template to keep track of user and file permissions. Access Vault expects input in the form of a csv with the columns seen in Access_Tracker.xlsx. The first row has been filled out for example purposes.