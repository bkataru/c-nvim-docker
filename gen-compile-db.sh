#!/bin/bash

# Create a compilation database for C files in the current directory
# This is a fallback when no Makefile or CMakeLists.txt exists

set -e

OUTPUT_FILE="compile_commands.json"
COMPILER_FLAGS="-Wall -Wextra -std=c11 -g"

# Start JSON array
echo "[" > "$OUTPUT_FILE"

first=true

# Use process substitution instead of pipe to preserve variable state
while IFS= read -r -d '' file; do
    abs_file=$(realpath "$file")
    
    if [ "$first" = true ]; then
        first=false
    else
        echo "," >> "$OUTPUT_FILE"
    fi
    
    cat >> "$OUTPUT_FILE" << EOF
  {
    "directory": "$(pwd)",
    "command": "clang $COMPILER_FLAGS -c $file -o ${file%.c}.o",
    "file": "$abs_file"
  }
EOF
done < <(find . -type f -name "*.c" -print0)

# Close JSON array
echo "]" >> "$OUTPUT_FILE"

chmod 644 "$OUTPUT_FILE"
echo "Compilation database generated: $OUTPUT_FILE"
