.PHONY: all
all: doc

.PHONY: doc
doc:
	bundle exec yard

.PHONY: test
test:
	@echo "how about contributing some tests?"
