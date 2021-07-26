.PHONY: help

help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'


draft: ## create draft
	@scripts/read.sh

publish: ## publish draft
	@scripts/publish.sh

serve: ## serve
	@bundle exec jekyll serve --livereload

serve-draft: ## serve with drafts
	@bundle exec jekyll serve --drafts --livereload

clean-cache: ## Empty tmp folder
	@rm -rf _tmp/*

link: ## Get the hash of an already published post
	@scripts/get-hash.sh

tags: ## Generate tag pages
	@scripts/tags.sh

copy-from: ## Copy an article
	echo TODO

install:
	@gem install bundle && bundle install

