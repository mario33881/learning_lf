all: run

compile:
	lfc src/actions.lf

run: compile
	./bin/actions

clean:
	rm -r bin/ include/ src-gen/

.PHONY: all compile run clean
