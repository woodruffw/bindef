.PHONY: all
all: doc

.PHONY: doc
doc:
	bundle exec yard

.PHONY: test
test:
	bundle exec rspec
