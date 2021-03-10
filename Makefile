ifndef PY
PY=3.8
endif

.PHONY: build
build:
	@WATCHMAN_TAG="$$(curl --silent https://api.github.com/repos/facebook/watchman/releases/latest | jq -r .tag_name)"; \
	docker login -u ${DOCKER_HUB_USERNAME} -p ${DOCKER_HUB_ACCESS_TOKEN} ;\
	for version in ${PY} ; do \
		echo "Building $$version" ; \
		TAG=snmishra/pywatchman:$$version ; \
		DOCKER_BUILDKIT=1 docker build --build-arg PYTHON_VERSION=$$version WATCHMAN_TAG="$$WATCHMAN_TAG" ${ARGS} . --tag $$TAG ;\
		docker push $$TAG ;\
	done
