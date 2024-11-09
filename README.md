# punch

![Banner](./art/banner.png)
The Auto Remote Punch Clock

Have you being forced to punch the clock and constantly submit time sheets?  
**COMPLAIN NO MORE!** Punch is here to help you on keeping the schedule in the grunt work factory :wink:

## Usage

- Punching the Clock using the current time

```shell
chmod +x ./scripts/punch.sh
./scripts/punch.sh -u email -p password
```

#### Settings 

The following variables can be adjusted:  

* `KAIROS_USER` - Defines the Kairos User
* `KAIROS_PASS` - Defines the Kairos Pass
* `TELEGRAM_USER_ID` - Defines Telegram User ID  
* `TELEGRAM_BOT_TOKEN` - Defines Telegram Bot Token

It also possible to specify a config file with punch like:  

```bash
./scripts/punch.sh -c myconf.conf
```

An configuration file [example is available here](./conf/punch.conf)


_at the moment punch only offers support to punch the clock using the dimep
kairos system, if you use other system please submit a PR, we are very
interested in extending punch to other time sheet systems_

## Install

_The simple way to install is bby copying ./scripts/punch.sh to wherever
you want, however we have plans to extend punch functionalities and for
that reason the automated installer is also available, stay tuned to understand
where the rabbit will be with the next automated installer features to come_

**Installer Dependencies:**  
* `Ansible 2.15+` - The installer is using [ansible, install it
first.](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html#pip-install)
* `GNU/Make 4.4+` - After installing ansible make sure you have GNU/Make installed.
* `SystemD` - The automated install timer units relies on systemd timers

#### Automated Install 

The automated install is here for those who wants to have a complete install
with all the configurations and timers. This helps to have punch configured in a
local or a remote machine.  

The automated install creates the systemd timers as additional of just installing the punch script.

* _Installs by default in $HOME/bin use `export RP_INSTALL_DIR=/my/path` to use
  a custom path_  

```shell
make install
```

* _Uninstalling punch_  

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
make deploy my-host.example.com
```

To undeploy it use the `undeploy` flag like:  

```bash
make undeploy my-host.example.com
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

* `RP_INSTALL_DIR` - Defines the punch.sh install path _(`default:
  $HOME/bin`)_   
* `RP_INSTALL_SVC` - Defined the SystemD timer and service install path,
  _(`default: $HOME/.config/systemd/user`)_  
* `RP_RANGE_WINDOW` - Defines the sleep timer before trigger punch
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

punch supports saving the punched receipts, by default al receipts will be
stored in `$HOME/mylogs/comprovantes/`, if telegram is enabled the receipts will
also be sent. Receipts are `.pdf` files named as
`comprovante-current-date-time.pdf`


## Timers  

The automated install and deploy creates timers.

It's possible to `enable` or `disable` timers as the following. 

* Enables the timer on the remote deployed host:  
```bash
make enable my-host.example.com
```

* Disable the timer on the remote deployed host:  
```bash
make disable my-host.example.com
```

* To do the same in the in the localhost when used the `make install` command use:  
```bash
make enable
```

* To disable use: 
```bash
make disable
```

_by default `enable` and `disable`  use the localhost if no host is specified_


...To be continue...
