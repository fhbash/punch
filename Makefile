SHELL ?= /bin/bash

HOST := $(word 2, $(MAKECMDGOALS))

.PHONY: help
help: ## - print the help and usage
	@printf "Project Usage:\n"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' Makefile | sort | awk \
		'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

.PHONY: install
install: ## - install punch into the localhost
	@ansible-playbook ./setup/ansible/plays/setup.yml \
		--tags install --limit localhost

.PHONY: uninstall
uninstall: ## - uninstall punch from the localhost
	@ansible-playbook ./setup/ansible/plays/setup.yml \
		--tags uninstall --limit localhost

.PHONY: deploy
deploy: ## - deploy punch into a remote host via ansible
		@[ -n "$(HOST)" ] || \
			{ echo "##Error: Host is missing use, make deploy <hostname>"; exit 1; }
		@ansible-playbook ./setup/ansible/plays/setup.yml \
			--limit "$(HOST)" --tags install

.PHONY: undeploy
undeploy: ## - undeploy punch from a remote host via ansible
		@[ -n "$(HOST)" ] || \
			{ echo "##Error: Host is missing use, make deploy <hostname>"; exit 1; }
		@ansible-playbook ./setup/ansible/plays/setup.yml \
			--limit "$(HOST)" --tags uninstall

.PHONY: enable
enable: ## - enable punch timers
		@(HOST="$(HOST)"; [ -n "$(HOST)" ] || HOST="localhost" ;\
			ansible-playbook ./setup/ansible/plays/setup.yml \
				--limit "$$HOST" --tags enable-timers)

.PHONY: disable
disable: ## - disable punch timers
		@(HOST=$(HOST); [ -n "${HOST}" ] || HOST="localhost" ;\
			ansible-playbook ./setup/ansible/plays/setup.yml \
				--limit "$$HOST" --tags disable-timers)

%:
	@true
