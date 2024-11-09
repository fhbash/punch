# rempointer

![Banner](./art/banner.png)
The Auto Remote Punch Clock

Have you being forced to punch the clock and constantly submit time sheets?  
**COMPLAIN NO MORE!** Remote Pointer is here to help you on keeping the schedule in the grunt work factory :wink:

# Manual Usage

- Punching the Clock using the current time

```shell
chmod +x ./scripts/rempointer.sh
./scripts/rempointer.sh -u email -p password
```

_at the moment rempointer only offers support to punch the clock using the dimep
kairos system, if you use other system please submit a PR, we are very
interested in extending rempointer to other time sheet systems_

## Install

_The simple way to install is bby copying ./scripts/rempointer.sh to wherever
you want, however we have plans to extend rempointer functionalities and for
that reason the automated installer is also available, stay tuned to understand
where the rabbit will be with the next automated installer features to come_

**Installer Dependencies:**  
* `Ansible 2.15+` - The installer is using [ansible, install it
first.](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html#pip-install)
* `GNU/Make 4.4+` - After installing ansible make sure you have GNU/Make installed.

#### Install Locally: 

* _Installs by default in $HOME/bin use `export RP_INSTALL_DIR=/my/path` to use
  a custom path_  

```shell
make install
```

* _Uninstalling rempointer_  

```shell
make uninstall
```  

##### Install Locally Examples:

_Installing locally and customizing a few settings:_  

```bash
KAIROS_USER="my_user" \
KAIROS_USER="my_pass" \
RP_INSTALL_DIR="$HOME/my/custom/path" \
RP_TG_ID="my_telegram_user_id" \
RP_TG_TOKEN="my_telegram_bot_token" \
make install
```

To avoid leaking secrets into scripts, you can use vault,
bitwarden or secret-tool, example:

```bash
KAIROS_USER="\$(secret-tool lookup kairos user)" \
KAIROS_PASS="\$(secret-tool lookup kairos pass)" \
make install
```

## Deploy:

It's also possible to deploy punch scripts into a remote machine, using ansible
inventory fashion.

1. Adding your host into the inventory:  
```bash
echo "my-host.example.com" > ./setup/ansible/inventory/myhost
```

2. Check that your host is reachable:  
```bash
ansible my-host.example.com -m ping
```

3. Deploy to your host:  
```bash
make deploy my-host.example.com
```

_Like the install method, deploy also support customizing the variables e.g.:_  

```bash
KAIROS_USER="\$(secret-tool lookup kairos user)" \
KAIROS_PASS="\$(secret-tool lookup kairos pass)" \
make deploy
```

#### The Inventory:  

* `[./setup/ansible/inventory`](./setup/ansible/inventory) - this is the main
  inventory directory. 

  [Ansible inventory
  files](https://docs.ansible.com/ansible/latest/cli/ansible-inventory.html) can
  be created on this directory in order to properly allow the `make deploy
  <my-host>` command to use those hosts as targets.  


##### Inventory Examples:

_customizing the user and connection method:_  
```ini
my-host.example.com ansible_connections=ssh ansible_user=myuser
```

_customizing the port and address:_  
```ini
home ansible_port=2222 ansible_host=192.168.1.10
```

### Additional Installer Variables 

* `RP_INSTALL_DIR` - Defines the rempointer.sh install path _(`default:
  $HOME/bin`)_   
* `RP_INSTALL_SVC` - Defined the SystemD timer and service install path,
  _(`default: $HOME/.config/systemd/user`)_  
* `RP_RANGE_WINDOW` - Defines the sleep timer before trigger rempointer
  _(`default: 1200`) aka 20min_  
* `RP_PUNCH_START` - Defines the Auto Punch Clock Start _(`default: 08:00`)_  
* `RP_PUNCH_END` - Defines the Auto Punch Clock End _(`default: 17:20`)_

to customize the installer variable preferences ensure to export the variables before
running the `make install ` command.  

## Telegram Integration

**Setup for the telegram:**  

1. Talk to `#BotFather` (in telegram) to create a telegram bot  
1. Talk to the bot you just created, so that it is able to
   communicate with you;
1. Still in `#BotFather`, take  note of its API token and export with:  
   `export TG_TOKEN=YourAPIToken`  
1. Get also your own user `ID`, and `export TG_ID=YourID`. You
   can get your id by talking to @JsonDumpBot -- you are interested in
   the "id" field from the "from" object, which is inside "message";


## Saving the Receipts

Rempointer supports saving the punched receipts, by default al receipts will be
stored in `$HOME/mylogs/comprovantes/`, if telegram is enabled the receipts will
also be sent. Receipts are `.pdf` files named as
`comprovante-current-date-time.pdf`


...To be continue...
