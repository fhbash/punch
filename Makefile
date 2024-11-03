SHELL ?= /bin/bash

.PHONY: help
help: ## - print the help and usage
	@printf "Project Usage:\n"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' Makefile | sort | awk \
		'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

.PHONY: install
install: ## - install rempointer
	ansible-playbook ./setup/ansible/plays/setup.yml --tags install

.PHONY: uninstall
uninstall: ## - uninstall rempointer
	ansible-playbook ./setup/ansible/plays/setup.yml --tags uninstall
