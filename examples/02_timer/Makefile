all: run

compile:
	lfc src/timer_lag.lf

run: compile
	./bin/timer_lag

clean:
	rm -r bin/ include/ src-gen/

.PHONY: all compile run clean
