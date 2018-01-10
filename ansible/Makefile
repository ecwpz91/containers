project_name = $(shell basename $$PWD)

.PHONY: build build_from_scratch build_debug clean clean_containers
	run run_prod stop

clean:
	@./hack/clean.sh all

clean_containers:
	@./hack/clean.sh containers

build:
	@./hack/clean.sh containers
	ansible-container build

build_from_scratch: clean
	ansible-container build

build_debug:
	@./hack/clean.sh containers
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
