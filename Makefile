# Environment variables
IMAGE_NAME = c-dev-env
CONTAINER_NAME = c-dev-container
WORKDIR = $(shell pwd)

# Default target
.PHONY: help
help:
	@echo "C Development Environment Makefile"
	@echo "==================================="
	@echo "make build	     - Build the Docker image"
	@echo "make start	     - Start a new container"
	@echo "make stop	     - Stop the running container"
	@echo "make restart	   - Restart the container"
	@echo "make shell	     - Connect to the container shell"
	@echo "make nvim	     - Start Neovim in the container"
	@echo "make compiledb  - Generate compilation database for C files"
	@echo "make clean	     - Remove the container"
	@echo "make clean-all  - Remove container and image"

# Build the Docker image
.PHONY: build
build:
	@echo "Building the $(IMAGE_NAME) Docker image..."
	docker build -t $(IMAGE_NAME) .

# Start a new container or restart an existing one
.PHONY: start
start:
	@echo "Starting $(CONTAINER_NAME)..."
	@docker ps -a | grep -q $(CONTAINER_NAME) && \
	(docker start $(CONTAINER_NAME) && echo "Container started.") || \
	(docker run -d --name $(CONTAINER_NAME) \
		-v $(WORKDIR):/workspace \
		--cap-add=SYS_PTRACE \
		--security-opt seccomp=unconfined \
		-it $(IMAGE_NAME) tail -f /dev/null && \
	echo "New container created and started.")

# Stop the running container
.PHONY: stop
stop:
	@echo "Stopping $(CONTAINER_NAME)..."
	@docker stop $(CONTAINER_NAME) || echo "Container not running."

# Restart the container
.PHONY: restart
restart: stop start

# Connect to the container shell
.PHONY: shell
shell: start
	@echo "Connecting to $(CONTAINER_NAME) shell..."
	docker exec -it $(CONTAINER_NAME) /bin/bash

# Start Neovim in the container
.PHONY: nvim
nvim: start
	@echo "Starting Neovim in $(CONTAINER_NAME)..."
	docker exec -it $(CONTAINER_NAME) nvim

# Generate compilation database
.PHONY: compiledb
compiledb: start
	@echo "generating compilation database..."
	docker exec -it $(CONTAINER_NAME) bash -c 'if [ -f "Makefile" ]; then compiledb make; elif [ -f "CMakeLists.txt" ]; then mkdir -p build && cd build && cmake -DCMAKE_EXPORT_COMPILE_COMMANDS=ON .. && ln -sf build/compile_commands.json ..; else bash /workspace/gen-compile-db.sh; fi'

# Remove the container
.PHONY: clean
clean: stop
	@echo "Removing $(CONTAINER_NAME)..."
	@docker rm $(CONTAINER_NAME) || echo "Container does not exist."

# Remove container and image
.PHONY: clean-all
clean-all: clean
	@echo "Removing $(IMAGE_NAME) image..."
	@docker rmi $(IMAGE_NAME) || echo "Image does not exist."
