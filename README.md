# rempointer

![Banner](./art/banner.png)
The Auto Remote Punch Clock

Have you being forced to punch the clock and constantly submit time sheets?  
**COMPLAIN NO MORE!** Remote Pointer is here to help you on keeping the schedule in the grunt work factory :wink:

# Usage

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
* `GNU/Makei 4.4+` - After installing ansible make sure you have GNU/Make installed.

**Installer Instrcutions:**  

* _Installs by default in $HOME/bin use `export RP_INSTALL_DIR=/my/path` to use
  a custom path_  

```shell
make install
```

* _Uninstalling rempointer_  

```shell
make uninstall
```  


...To be continue...
