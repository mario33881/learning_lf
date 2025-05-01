all: run

compile:
	lfc src/hello_world.lf

run: compile
	./bin/hello_world

clean:
	rm -r bin/ include/ src-gen/

.PHONY: all compile run clean
