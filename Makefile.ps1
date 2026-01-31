# environment variables
$IMAGE_NAME = "c-dev-env"
$CONTAINER_NAME = "c-dev-container"
$WORKDIR = (Get-Location).Path
$FILENAME = $PSCommandPath.Split("\\")[-1]

function Show-Help {
	Write-Host "C Development Environment PowerShell Script"
	Write-Host "==========================================="
	Write-Host ".\$FILENAME build       - build the Docker image"
	Write-Host ".\$FILENAME start       - start a new container"
	Write-Host ".\$FILENAME stop        - stop the running container"
	Write-Host ".\$FILENAME restart     - restart the container"
	Write-Host ".\$FILENAME shell       - connect to the container shell"
	Write-Host ".\$FILENAME nvim        - start Neovim in the container"
	Write-Host ".\$FILENAME compiledb   - generate compilation database"
	Write-Host ".\$FILENAME clean       - remove the container"
	Write-Host ".\$FILENAME clean-all   - remove container and image"
}

function Build-Image {
	Write-Host "> building the $IMAGE_NAME Docker image..."
	docker build -t $IMAGE_NAME .
}

function Start-Container {
	Write-Host "> starting $CONTAINER_NAME..."

	$containerExists = docker ps -a | Select-String -Pattern $CONTAINER_NAME

	if ($containerExists) {
		docker start $CONTAINER_NAME
		Write-Host "> container started."
	} else {
		docker run -d --name $CONTAINER_NAME `
			-v "${WORKDIR}:/workspace" `
			--cap-add=SYS_PTRACE `
			--security-opt seccomp=unconfined `
			-it $IMAGE_NAME
		Write-Host "> new container created and started."
	}
}

function Stop-Container {
	Write-Host "> stopping $CONTAINER_NAME..."
	$ErrorActionPreference = 'SilentlyContinue'
	docker stop $CONTAINER_NAME
	$ErrorActionPreference = 'Continue'
	if ($LASTEXITCODE -ne 0) {
		Write-Host "> container not running."
	}
}

function Restart-Container {
	Stop-Container
	Start-Container
}

function Enter-Shell {
	Start-Container
	Write-Host "> connecting to $CONTAINER_NAME's shell..."
	docker exec -it $CONTAINER_NAME /bin/bash
}

function Start-Nvim {
	Start-Container
	Write-Host "> starting Neovim in $CONTAINER_NAME..."
	docker exec -it $CONTAINER_NAME nvim
}

function Generate-CompileDb {
	Start-Container
	Write-Host "> generating compilation database..."
	docker exec -it $CONTAINER_NAME bash -c 'if [ -f "Makefile" ]; then compiledb make; elif [ -f "CMakeLists.txt" ]; then mkdir -p build && cd build && cmake -DCMAKE_EXPORT_COMPILE_COMMANDS=ON .. && ln -sf build/compile_commands.json ..; else bash /workspace/gen-compile-db.sh; fi'
}

function Remove-Container {
	Stop-Container
	Write-Host "> removing $CONTAINER_NAME..."
	$ErrorActionPreference = 'SilentlyContinue'
	docker rm $CONTAINER_NAME
	$ErrorActionPreference = 'Continue'
	if ($LASTEXITCODE -ne 0) {
		Write-Host "> container does not exist."
	}
}

function Remove-All {
	Remove-Container
	Write-Host "> removing $IMAGE_NAME image..."
	$ErrorActionPreference = 'SilentlyContinue'
	docker rmi $IMAGE_NAME
	$ErrorActionPreference = 'Continue'
	if ($LASTEXITCODE -ne 0) {
		Write-Host "> image does not exist."
	}
}

$command = $args[0]

switch ($command) {
	"build" { Build-Image }
	"start" { Start-Container }
	"stop" { Stop-Container }
	"restart" { Restart-Container }
	"shell" { Enter-Shell }
	"nvim" { Start-Nvim }
	"compiledb" { Generate-CompileDb }
	"clean" { Remove-Container }
	"clean-all" { Remove-All }
	default { Show-Help }
}
