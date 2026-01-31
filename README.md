# c-nvim-docker

Dockerized C development environment with Neovim, clang, and LSP support.

## Features

- **Clang toolchain** - Based on `silkeh/clang:latest` with full C/C++ support
- **Neovim 0.10.4** - With AstroNvim configuration for a modern editing experience
- **LSP support** - clangd with `compile_commands.json` generation
- **Debugging** - gdb, lldb, valgrind, and codelldb for DAP integration
- **Cross-platform** - Makefile for Unix/Linux, PowerShell script for Windows

## Quick Start

### Prerequisites

- Docker installed and running
- Make (Unix/Linux/macOS) or PowerShell (Windows)

### Build and Run

**Unix/Linux/macOS:**
```bash
make build    # Build the Docker image
make nvim     # Start Neovim in the container
```

**Windows (PowerShell):**
```powershell
.\Makefile.ps1 build    # Build the Docker image
.\Makefile.ps1 nvim     # Start Neovim in the container
```

## Commands

| Command | Description |
|---------|-------------|
| `build` | Build the Docker image |
| `start` | Start/create the container |
| `stop` | Stop the running container |
| `restart` | Restart the container |
| `shell` | Open a bash shell in the container |
| `nvim` | Launch Neovim in the container |
| `compiledb` | Generate `compile_commands.json` for LSP |
| `clean` | Remove the container |
| `clean-all` | Remove container and image |

## LSP Setup

For clangd to provide accurate completions and diagnostics, you need a `compile_commands.json` file:

```bash
make compiledb
```

This command auto-detects your build system:
1. **Makefile** - Uses `compiledb make`
2. **CMakeLists.txt** - Uses CMake's `CMAKE_EXPORT_COMPILE_COMMANDS`
3. **No build system** - Falls back to `gen-compile-db.sh`

## Project Structure

```
.
├── Dockerfile          # Container image definition
├── Makefile            # Unix/Linux commands
├── Makefile.ps1        # PowerShell commands for Windows
├── gen-compile-db.sh   # Fallback compile_commands.json generator
├── .config/nvim/       # AstroNvim configuration
└── collate/            # Utility to aggregate source files
    └── script.sh       # Collate script for LLM context
```

## Collate Utility

The `collate/script.sh` utility aggregates all source files into a single text file, useful for sharing code context with AI assistants:

```bash
./collate/script.sh --source ./src --output context.txt
```

Options:
- `-s, --source DIR` - Source directory to scan
- `-o, --output FILE` - Output file (default: context.txt)
- `-e, --exclude-dir DIR` - Directory to exclude
- `-v, --verbose` - Enable verbose output

## Container Details

- **Working directory:** `/workspace` (mounted from host)
- **User:** `tron` (non-root with sudo access)
- **Debugging:** `SYS_PTRACE` capability enabled for gdb/lldb

## License

MIT
