ifndef PY
PY=3.8
endif

.PHONY: build
build:
	docker login -u $${DOCKER_HUB_USERNAME} -p $${DOCKER_HUB_ACCESS_TOKEN} ;\
	FMT_TAG="$$(curl --silent https://api.github.com/repos/fmtlib/fmt/releases/latest | jq -r .tag_name)"; \
	WATCHMAN_TAG="$$(curl --silent https://api.github.com/repos/facebook/watchman/releases/latest | jq -r .tag_name)"; \
	for version in ${PY} ; do \
		echo "Building python:$$version fmt:$$FMT_TAG watchman:$$WATCHMAN_TAG" ; \
		TAG=snmishra/pywatchman:$$version ; \
		DOCKER_BUILDKIT=1 docker build --build-arg "PYTHON_VERSION=$$version" --build-arg "WATCHMAN_TAG=$$WATCHMAN_TAG" \
		  --build-arg "FMT_TAG=$$FMT_TAG" ${ARGS} . --tag $$TAG && \
		docker push $$TAG ;\
	done
