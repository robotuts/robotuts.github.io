# A Self-Documenting Makefile: http://marmelab.com/blog/2016/02/29/auto-documented-makefile.html

.PHONY: help
.DEFAULT_GOAL := help

install: ## Install all required dependencies
	@echo "Installing dependencies"
	@pip install -q -r requirements.txt

build: ## Build MkDocs site
	@echo "Building docs"
	@mkdocs build

help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'
