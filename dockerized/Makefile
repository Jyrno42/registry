.PHONY: release tag_latest build help
.DEFAULT_GOAL := help

NAME = thorgate/eis-registry
VERSION = 2016.09.9

help:
	@echo "Goals"
	@echo "===================================================================================================="
	@echo "make release            Run build->tag_latest->push"
	@echo "make build              Build $(NAME):$(VERSION)"
	@echo "make tag_latest         Tag $(NAME):$(VERSION) as :latest"
	@echo "make push               Push $(NAME):$(VERSION) to docker registry"

build:
ifdef REBUILD
	@echo "REBUILDING $(NAME):$(VERSION)"
	docker build -t $(NAME):$(VERSION) ../
else
	@if docker images $(NAME) | awk '{ print $2 }' | grep -q -F $(VERSION); then echo "$(NAME) version $(VERSION) is already built. Use 'REBUILD=1 make build' to rebuild"; false; fi
	docker build -t $(NAME):$(VERSION) ../
endif

tag_latest:
	docker tag $(NAME):$(VERSION) $(NAME):latest

push:
	@if ! docker images $(NAME) | awk '{ print $2 }' | grep -q -F $(VERSION); then echo "$(NAME) version $(VERSION) is not yet built. Please run 'make build'"; false; fi
	docker push $(NAME)

release:
	@if ! docker images $(NAME) | awk '{ print $2 }' | grep -q -F $(VERSION); then $(MAKE) build; fi
	$(MAKE) tag_latest
	$(MAKE) push

