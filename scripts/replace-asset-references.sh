#!/bin/bash

# Verbosity level: set to true for more detailed output
VERBOSE=true

# Directory where assets are stored
ASSETS_DIR="assets"

# Function to log messages if verbosity is enabled
log() {
  if [ "$VERBOSE" = true ]; then
    echo "$1"
  fi
}

# Function to update image URLs in markdown files
update_image_urls() {
  local file="$1"
  log "Processing file: $file"
  
  # Iterate over all image URLs in the markdown file
  grep -oP '!\[.*?\]\(\K[^)]+' "$file" | while read -r url; do
    log "Found image URL: $url"
    
    # Extract the filename from the URL
    filename=$(basename "$url")
    
    # Check if the image exists in the assets directory
    if [ -f "_pages/$ASSETS_DIR/$filename" ]; then
      log "Found local asset: $ASSETS_DIR/$filename"
      
      # Create the local path reference for the markdown
      local_path="/$ASSETS_DIR/$filename"
      
      # Replace the original URL with the local path in the markdown file
      sed -i "s|$url|$local_path|g" "$file"
      log "Updated $url to $local_path in $file"
    else
      log "No local asset found for $filename, skipping."
    fi
  done
}

# Iterate over all markdown files in _pages directory
find _pages -name "*.md" | while read -r file; do
  update_image_urls "$file"
done
