TARGETS=darwin linux windows

default: build

build:
	go build -v

.PHONY: build changelog targets $(TARGETS)