.PHONY: all
all: doc

.PHONY: doc
doc:
	bundle exec yard

.PHONY: lint
lint:
	bundle exec rubocop -D lib/ bin/

.PHONY: test
test:
	bundle exec rspec
