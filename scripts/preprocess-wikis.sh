#!/bin/bash

# Directory containing the raw wiki markdown files
WIKI_DIR="wikis"
MAIN_WIKI=$ENV_MAIN_WIKI
# Directory for processed files ready for Jekyll
PAGES_DIR="_pages"

# Ensure the target directory exists
mkdir -p "$PAGES_DIR"

# Initialize counters for top-level and sub-level pages
declare -A nav_order_counters
top_level_counter=2  # Start from 2 to reserve 1 for the main index

# Function to create front matter based on hierarchy
create_front_matter() {
  local file="$1"
  local filename="$2"
  local repo_name="$3"
  local relative_path="$4"
  
  local parent_title=""
  local title="$filename"
  local nav_order=""
  local has_children="false"
  
  if [[ "$filename" == "index" ]]; then
    title="$repo_name"
    nav_order=$top_level_counter
    top_level_counter=$((top_level_counter + 1))  # Increment top-level counter for next index.md
    
    # Check if there are other files in the same directory (children)
    if [ $(find "$(dirname "$file")" -maxdepth 1 -name "*.md" | wc -l) -gt 1 ]; then
      has_children="true"
    fi
  else
    parent_title="$repo_name"
    if [[ -z "${nav_order_counters[$relative_path]}" ]]; then
      nav_order_counters[$relative_path]=1
    else
      nav_order_counters[$relative_path]=$((nav_order_counters[$relative_path]+1))
    fi
    nav_order="${nav_order_counters[$relative_path]}"
  fi
  
  # Generate front matter
  echo "---" > temp.md
  echo "title: \"$title\"" >> temp.md
  echo "layout: \"default\"" >> temp.md
  echo "nav_order: $nav_order" >> temp.md
  if [[ -n "$parent_title" ]]; then
    echo "parent: \"$parent_title\"" >> temp.md
  fi
  if [[ "$has_children" == "true" ]]; then
    echo "has_children: true" >> temp.md
  fi
  echo "---" >> temp.md
  cat "$file" >> temp.md
}

# Iterate over each markdown file in the wikis directory
find "$WIKI_DIR" -name "*.md" | while read -r file; do
  # Extract the filename without the extension
  FILENAME=$(basename "$file" .md)
  
  # Extract the relative path from WIKI_DIR to the file
  RELATIVE_PATH=$(dirname "$file" | sed "s|^$WIKI_DIR/||")
  REPO_NAME=$(basename "$(dirname "$file")")

  # Always convert Home.md to index.md
  if [[ "$FILENAME" == "Home" ]]; then
    FILENAME="index"
  fi

  # Create the corresponding directory in _pages
  mkdir -p "$PAGES_DIR/$RELATIVE_PATH"

  # Determine the target file path
  TARGET_FILE="$PAGES_DIR/$RELATIVE_PATH/$FILENAME.md"

  # Check if the file already contains front matter
  if ! (head -n 1 "$file" | grep -q "^---" && awk 'NR==1,/^---/{if(NR>1 && /^---/) exit 0} END{exit 1}' "$file"); then
    # Create front matter and move the file to the _pages directory
    create_front_matter "$file" "$FILENAME" "$REPO_NAME" "$RELATIVE_PATH"
  else
    cp "$file" temp.md
  fi

  # Adjust the code block wrapping
  awk '
  BEGIN {in_code_block=0}
  /```/ {
    if (in_code_block == 0) {
      print $0
      print "{% raw %}"
      in_code_block=1
    } else {
      print "{% endraw %}"
      print $0
      in_code_block=0
    }
    next
  }
  {print}' temp.md > "$TARGET_FILE"

  # If this is the main index page, copy it to the top level
  if [[ "$RELATIVE_PATH/$FILENAME.md" == "$MAIN_WIKI/index.md" ]]; then
    # Adjust nav_order to 1 when copying to root index.md
    sed 's/nav_order: [0-9]*/nav_order: 1/' "$TARGET_FILE" > "$PAGES_DIR/index.md"
    # remove the target file
    rm -f "$TARGET_FILE"
  fi

  # Remove the temporary file
  rm -f temp.md

  echo "Processed $file into $TARGET_FILE"
done
