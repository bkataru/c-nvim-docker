#!/bin/bash 

# create a compilation database for C files in the current directory
first=true

find . -type f -name "*.c" | while read -r file; do
  abs_file=$(realpath "$file")

  if [ "$first" = true ]; then
    first=false
  else
    echo "," >> compile_commands.json
  fi

  echo "  {" >> compile_commands.json
  echo "    \"directory\": \"$(pwd)\"," >> compile_commands.json
  echo "    \"command\": \"clang -Wall -Werror -std=c11 -g $file -o ${file%.c}.o\"," >> compile_commands.json
  echo "    \"file\": \"$abs_file\"" >> compile_commands.json
  echo "  }" >> compile_commands.json
done

echo "]" >> compile_commands.json
chmod 644 compile_commands.json
echo "compilation database generated: compile_commands.json"
