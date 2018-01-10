project_name = $(shell basename $$PWD)

.PHONY: build build_from_scratch build_debug clean clean_containers
	run run_prod stop

clean:
	@./scripts/clean.sh all

clean_containers:
	@./scripts/clean.sh containers

build:
	@./scripts/clean.sh containers
	ansible-container build

build_from_scratch: clean
	ansible-container build

build_debug:
	@./scripts/clean.sh containers
	ansible-container --debug build

run:
	ansible-container run

run_debug:
	ansible-container --debug run

run_prod:
	ansible-container run --production

stop:
	ansible-container stop

%:
	@:
