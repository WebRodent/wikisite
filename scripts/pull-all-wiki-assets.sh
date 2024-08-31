#!/bin/bash

# Verbosity level: set to true for more detailed output
VERBOSE=true

# Directory to store downloaded assets
ASSETS_DIR="_pages/assets"
mkdir -p "$ASSETS_DIR"

# Function to log messages if verbosity is enabled
log() {
  if [ "$VERBOSE" = true ]; then
    echo "$1"
  fi
}

# Validate if the GitHub CLI token is set
if [ -z "$gh_cli_token" ]; then
  echo "GitHub CLI token is not set. Trying to read from 'gh auth token'..."
  # Try to read the token from gh auth token
  gh_cli_token=$(gh auth token)
  if [ -z "$gh_cli_token" ]; then
    echo "Error: GitHub CLI token is not set. Set the 'gh_cli_token' environment variable."
    exit 1
  else
    echo "GitHub CLI token read successfully."
    # print the first 5 characters of the token
    echo "
    GitHub CLI token: ${gh_cli_token:0:5}...
    "
  fi
fi

# Function to check if a downloaded file is a valid image
is_valid_image() {
  file_type=$(file --mime-type "$1" | awk '{print $2}')
  case $file_type in
    image/*)
      return 0 ;;
    *)
      return 1 ;;
  esac
}

# Function to convert GitHub URL to raw content URL
convert_to_raw_url() {
  local url="$1"
  echo "$url" | sed -e 's#https://github.com/#https://raw.githubusercontent.com/#' -e 's#/blob/#/#'
}

# Function to download a file using curl
download_file() {
  local url="$1"
  local filepath="$2"
  curl -H "Authorization: token $gh_cli_token" -H "Accept: application/vnd.github.v4.raw" -L "$url" -o "$filepath"
}

# Function to handle user-attachments URLs with cookie handling
handle_user_attachments() {
  local url="$1"
  local filepath="$2"
  local cookies_file=$(mktemp)

  # Step 1: Get the cookie
  curl -c "$cookies_file" -H "Authorization: token $gh_cli_token" -L "$url" -o /dev/null

  # Step 2: Use the cookie to download the file
  curl -b "$cookies_file" -H "Authorization: token $gh_cli_token" -L -o "$filepath" "$url"

  # Validate if the file is a correct image
  if is_valid_image "$filepath"; then
    log "Downloaded and validated image: $filepath"
  else
    log "Failed to download or invalid image at: $url"
    rm -f "$filepath"
  fi

  # Clean up the cookie file
  rm -f "$cookies_file"
}

# Iterate over all markdown files in _pages directory
find _pages -name "*.md" | while read -r file; do
  log "Processing markdown file: $file"
  
  # Extract image URLs from markdown file using grep and sed
  grep -oP '!\[.*?\]\(\K[^)]+' "$file" | while read -r url; do
    log "Found image URL: $url"
    
    # Prepare target filename based on the URL
    filename=$(basename "$url")  # Correctly capture the entire filename
    filepath="$ASSETS_DIR/$filename"

    # Check if URL is a user-attachments link
    if [[ "$url" == *"user-attachments"* ]]; then
      log "Handling user-attachments URL with cookie"
      handle_user_attachments "$url" "$filepath"
    else
      # Convert GitHub web URL to raw URL and download
      raw_url=$(convert_to_raw_url "$url")
      log "Converted URL to raw URL: $raw_url"
      
      log "Downloading $raw_url to $filepath"
      download_file "$raw_url" "$filepath"
      
      # Check if the download was successful and the file is a valid image
      if [ -f "$filepath" ] && is_valid_image "$filepath"; then
        log "Downloaded and validated image: $filepath"
      else
        log "Failed to download or invalid image at: $raw_url"
        rm -f "$filepath"  # Remove invalid file
      fi
    fi
  done
done
