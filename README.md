# punch

![Banner](./art/banner.png)
The Auto Remote Punch Clock

Have you being forced to punch the clock and constantly submit time sheets?  
**COMPLAIN NO MORE!** Punch is here to help you on keeping the schedule in the grunt work factory :wink:

* [Start Here - Usage](#usage)  
    * [General Settings](#settings)
* [Installing](#install)
    * [The Automated Install](#automated-install) 
    * [Installing Locally Examples](#install-locally-examples)
    * [Deploy - Auto install into a remote machine](#deploy)
        * [Creating a deploy inventory](#the-inventory)  
        * [Custom Inventory Examples](#inventory-examples)
    * [Additional Installer Variables](#additional-installer-variables)
* [Telegram Integration](#telegram-integration)
* [Paperless Integration](#paperless-integration)  
* [Saving the Receipts](#saving-the-receipts)
* [Managing Timers](#timers)  
* [Holiday Mode](#holiday-mode)
    * [Creating Holidays](#creating-holidays)  
    * [Commenting Holidays](#commenting-holidays)

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
* `PAPERLESS_URL` - Defines Paperless URL, e.g: `http://localhost` 
* `PAPERLESS_TOKEN` - Defines Paperless API Token  
* `HOLIDAY_FILE` - The full path to a holiday file. [read more](#holiday-mode)

It's also possible to specify a config file with punch like:  

```bash
./scripts/punch.sh -c myconf.conf
```

A configuration file [example is available here](./conf/punch.conf)


_at the moment punch only offers support to punch the clock using the dimep
kairos system, if you use other system please submit a PR, we are very
interested in extending punch to other time sheet systems_

## Install

_The simple way to install is by copying ./scripts/punch.sh to wherever
you want, however we have plans to extend punch functionalities and for
that reason the automated installer is also available, jump to the [Automated
Install](#automated-install) section to see where the rabbit can go with the 
automated installer features_


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

##### Install Locally Examples

_Installing locally and customizing a few settings:_  

```bash
KAIROS_USER="my_user" \
KAIROS_USER="my_pass" \
RP_INSTALL_DIR="$HOME/my/custom/path" \
TELEGRAM_USER_ID="my_telegram_user_id" \
TELEGRAM_BOT_TOKEN="my_telegram_bot_token" \
HOLIDAY_FILE="./my-holidays.yml" \
make install
```

To avoid leaking secrets into scripts, you can use vault,
bitwarden or secret-tool, example:

```bash
KAIROS_USER="\$(secret-tool lookup kairos user)" \
KAIROS_PASS="\$(secret-tool lookup kairos pass)" \
make install
```

## Deploy

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

#### The Inventory  

* [`./setup/ansible/inventory`](./setup/ansible/inventory) - this is the main
  inventory directory. 

  [Ansible inventory
  files](https://docs.ansible.com/ansible/latest/cli/ansible-inventory.html) can
  be created on this directory in order to properly allow the `make deploy
  <my-host>` command to use those hosts as targets.  


##### Inventory Examples

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

to customize the installer variable preferences you can export or declare the variables before
running the `make install ` command, example:  

* Install timers to punch without a random range window:  
```bash
RP_PUNCH_START='09:00' RP_PUNCH_END='18:00' RP_RANGE_WINDOW=0 make install
```

* Install punch with paperless and telegram:  
```bash
PAPERLESS_URL='https://my-paperless.lan' \
PAPERLESS_TOKEN='MyPaperlessAPIToken \
TELEGRAM_BOT_TOKEN='MyTelegramBotToken \
TELEGRAM_USER_ID='MyTelegramUserID' \
make install
```

To deploy punch into a remote machine change the `make install` to `make deploy
my-server`, this will do the same however in a remote host.  

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


## Paperless Integration  

Punch supports sending the receipts to a paperless-ngx server.  
The following variables customize Paperless integration:  

* `PAPERLESS_URL` - The Paperless Server URL e.g.: "http://my-server". _It's not
  necessary the entire API endpoint, just the http url server_  
* `PAPERLESS_TOKEN` - Paperless API Token  
* `PAPERLESS_CORRESPONDENT` - The correspondent name (`default: kairos`)  
* `PAPERLESS_TAGS` - Single or list of tags. (`default: ponto`)

The variables can be either exported or set in the config file. Some alias
variables can also be used during the runtime or installer. Check the
[Installer variables](#additional-installer-variables).

## Saving the Receipts

punch supports saving the punched receipts, by default al receipts will be
stored in `$HOME/mylogs/comprovantes/`, if telegram or paperless is enabled the receipts will
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

## Holiday Mode

Punch supports a holiday file to make sure it will not punch the clock on
holidays. A holiday file is a `YAML` file where you can register a list of your
holidays. Punch will look this file, if todays date matches a date in the
file it will not punch the clock.

A [holiday file example is available here](./conf/holidays.yml).  

You can create a custom holiday file and install it, those are the supported
variables of a holiday file:

* `HOLIDAY_FILE` - The path to the holiday file

Examples:  

* Using punch with a holiday file:  
```bash
HOLIDAY_FILE="path/to/my-holiday.yml" ./scripts/punch.sh -u user -p pass
```
_The same variable can be used in a punch configuration file_  

* Installing a custom holiday file:  
```bash
HOLIDAY_FILE="./my-custom-holiday.yml" make install
```
_By default this will copu the `my-custom-holiday.yml` into
`$HOME/bin/my-custom-holiday.yml` it will also configure `$HOME/bin/punch.conf`
to use this file._

* Uninstalling a custom holiday file:  
```bash
HOLIDAY_FILE="./my-custom-holiday.yml" make uninstall
```

It's also possible to deploy the holiday file using the `make deploy` command.

**NOTE**  
_By default the holiday file will be installed in the `RP_INSTALL_DIR` with as
defaults points to "$HOME/bin"._    
**If you update the holiday file make sure to
deploy or install it again, using the `make deploy` or `make install` commands,
this will update your holiday changes into the punch configuration**

### Creating Holidays  

The holiday file is a `YAML` that has the following structure:  

```yaml
- date: "2024-12-25"
  name: "Christmas"

- date: "2024-12-31,2025-01-01"
  name: "New Year"

# - date "2025-02-02"
#   name: "This will punch since date is commented
```

When a single `date` is informed punch considers that date as a holiday, and will
not punch the clock. Multiple dates can be specified as a range by comma
separated.  
  
In the previous example the `New Year` starts at `31` of December and lasts till
January the First of the next Year. In this example punch will only start 
again in January the Second aka `2025-01-02`.
  
A holiday [file example is available here](./conf/holidays.yml). This file is
used by default in the punch installation, you can update it and `deploy` or
`install` as you need.  

##### Commenting Holidays

It's also possible to comment out holidays.
Dates starting with `#` in front of it, will make punch not threat the date as
a holiday, Example:    

```yaml
# - date: 2024-02-02
#   name: Punch the clock normally
```


**NOTE**  
_Punch is not using `yq` or any external dependencies to parse the YAML file,
that means punch looks for YAML format but does not support full YAML parsing.
In fact any text file with the `date` in the format bellow will be properly parsed by
punch_   
  
_The `date` will properly work using the following syntax:_  
  
```yaml
- date: "YYYY-mm-dd"
- date: 'YYYY-mm-dd'
- date: YYYY-mm-dd
```
  
_Other fields are currently optional and are currently not used by punch_



...To be continue...
