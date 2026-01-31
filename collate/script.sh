#!/bin/bash

# Default configuration

OUTPUT_FILE="context.txt"
SCRIPT_NAME=$(basename "$0")
DEFAULT_EXCLUDE_DIRS=(".git" "node_modules" "venv" ".venv")
DEFAULT_EXCLUDE_FILES=("$SCRIPT_NAME" "$OUTPUT_FILE")
EXCLUDE_DIRS=()
EXCLUDE_FILES=()
SOURCE_DIR="."

VERBOSE=false
INCLUDE_HIDDEN=true
MAX_FILE_SIZE=1048576  # 1MB in bytes

# Function for logging
log() {
    local level="$1"

    local message="$2"
    local timestamp=$(date "+%Y-%m-%d %H:%M:%S")
    

    if [[ "$VERBOSE" == true || "$level" == "ERROR" ]]; then
        echo "[$timestamp] [$level] $message" >&2

    fi
}

# Function to display help

show_help() {
    cat << EOF
Usage: $SCRIPT_NAME [OPTIONS]

Generate a context file by compiling the contents of files in a directory.


Options:

  -o, --output FILE        Specify output file (default: $OUTPUT_FILE)
  -s, --source DIR         Source directory to scan (default: current directory)
  -e, --exclude-dir DIR    Directory to exclude (can be used multiple times)
  -f, --exclude-file FILE  File to exclude (can be used multiple times)
  -n, --no-hidden          Exclude hidden files and directories

  -m, --max-size SIZE      Maximum file size in bytes (default: 1MB)
  -v, --verbose            Enable verbose output
  -h, --help               Display this help message


Example:
  $SCRIPT_NAME --source ./project --exclude-dir build --exclude-file README.md

EOF
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case "$1" in
        -o|--output)
            OUTPUT_FILE="$2"
            shift 2
            ;;
        -s|--source)
            SOURCE_DIR="$2"
            shift 2
            ;;
        -e|--exclude-dir)
            EXCLUDE_DIRS+=("$2")
            shift 2

            ;;
        -f|--exclude-file)

            EXCLUDE_FILES+=("$2")
            shift 2
            ;;
        -n|--no-hidden)
            INCLUDE_HIDDEN=false
            shift
            ;;

        -m|--max-size)
            MAX_FILE_SIZE="$2"
            shift 2
            ;;
        -v|--verbose)
            VERBOSE=true
            shift
            ;;
        -h|--help)
            show_help
            exit 0
            ;;
        *)
            log "ERROR" "Unknown option: $1"
            show_help
            exit 1
            ;;
    esac
done


# Combine default and user-specified exclusions
EXCLUDE_DIRS+=("${DEFAULT_EXCLUDE_DIRS[@]}")
EXCLUDE_FILES+=("${DEFAULT_EXCLUDE_FILES[@]}")


# Check if source directory exists
if [[ ! -d "$SOURCE_DIR" ]]; then
    log "ERROR" "Source directory '$SOURCE_DIR' does not exist"
    exit 1

fi


# Build find command exclusion arguments
FIND_ARGS=()

# Add directory exclusions
for dir in "${EXCLUDE_DIRS[@]}"; do
    FIND_ARGS+=("-path" "$SOURCE_DIR/$dir" "-prune" "-o")
done

# Add file type condition
FIND_ARGS+=("-type" "f")


# Add file exclusions
for file in "${EXCLUDE_FILES[@]}"; do

    FIND_ARGS+=("-not" "-name" "$file")
done

# Handle hidden files exclusion
if [[ "$INCLUDE_HIDDEN" == false ]]; then
    FIND_ARGS+=("-not" "-path" "*/\.*")
fi

# Prepare output file

log "INFO" "Starting context generation from directory: $SOURCE_DIR"
log "INFO" "Output will be written to: $OUTPUT_FILE"

# Initialize the context string

CONTEXT=""
FILE_COUNT=0
SKIPPED_COUNT=0
TOTAL_SIZE=0

# Create a temporary file for the context

TEMP_FILE=$(mktemp)
trap 'rm -f "$TEMP_FILE"' EXIT

while IFS= read -r -d '' file; do
    # Get file size
    FILE_SIZE=$(stat -c%s "$file" 2>/dev/null || stat -f%z "$file" 2>/dev/null)
    
    # Skip files exceeding max size
    if (( FILE_SIZE > MAX_FILE_SIZE )); then
        log "WARN" "Skipping file (too large): $file ($FILE_SIZE bytes)"
        ((SKIPPED_COUNT++))
        continue

    fi
    

    # Get relative path
    REL_PATH="${file#$SOURCE_DIR/}"
    if [[ "$REL_PATH" == "$file" ]]; then
        REL_PATH="${file#./}"
    fi
    
    # Try to read file content
    if FILE_CONTENT=$(cat "$file" 2>/dev/null); then
        # Append file metadata and content to context
        {
            echo "==== FILE: $REL_PATH ===="
            echo "$FILE_CONTENT"
            echo ""

        } >> "$TEMP_FILE"
        
        ((FILE_COUNT++))
        ((TOTAL_SIZE+=FILE_SIZE))
        log "INFO" "Added file: $REL_PATH ($FILE_SIZE bytes)"
    else
        log "ERROR" "Failed to read file: $file"
        ((SKIPPED_COUNT++))
    fi
    
done < <(find "$SOURCE_DIR" "${FIND_ARGS[@]}" -print0)


# Move temporary file to output file
if mv "$TEMP_FILE" "$OUTPUT_FILE" 2>/dev/null; then
    log "INFO" "Context generation complete"
    log "INFO" "Files processed: $FILE_COUNT"
    log "INFO" "Files skipped: $SKIPPED_COUNT"
    log "INFO" "Total size: $TOTAL_SIZE bytes"
else
    log "ERROR" "Failed to write output file: $OUTPUT_FILE"
    exit 1
fi

exit 0
