#!/bin/bash

# Directory to store the wikis
WIKI_DIR="wikis"
ORG_NAME=$ENV_ORG_NAME
VERBOSE=false

# Parse arguments
while getopts "vn:" flag; do
  case "${flag}" in
    v) VERBOSE=true ;;
    n) ORG_NAME=${OPTARG} ;;
    *) 
      echo "Usage: $0 [-v] [-n ORG_NAME]"
      exit 1
      ;;
  esac
done

# Ensure the wiki directory exists
mkdir -p $WIKI_DIR

# Function to update existing repository
update_repo() {
  local dir=$1
  $VERBOSE && echo "Updating existing repository in $dir"
  cd $dir
  DEFAULT_BRANCH=$(git remote show origin | grep "HEAD branch" | cut -d' ' -f5)
  git fetch origin
  git reset --hard origin/$DEFAULT_BRANCH
  cd - > /dev/null 2>&1
}

# Fetch the list of repositories in the organization
REPOS=$(gh api "orgs/$ORG_NAME/repos" --paginate --jq '.[] | .full_name')

# Loop over each repository to check for the shared-wiki custom property
for REPO in $REPOS; do
  $VERBOSE && echo "Processing repo: $REPO"

  # Fetch the custom properties for the repository
  SHARED_WIKI=$(gh api "repos/$REPO/properties/values" --jq '.[] | select(.property_name == "shared-wiki") | .value')

  # Check if the shared-wiki property is true
  if [ "$SHARED_WIKI" = "true" ]; then
    WIKI_REPO="$REPO.wiki"
    DEST_DIR="$WIKI_DIR/$(basename $REPO)"

    if [ -d "$DEST_DIR" ]; then
      update_repo "$DEST_DIR"
    else
      $VERBOSE && echo "Cloning wiki for $REPO into $DEST_DIR"
      if gh repo clone "$WIKI_REPO" "$DEST_DIR" > /dev/null 2>&1; then
        $VERBOSE && echo "Successfully cloned $WIKI_REPO"
      else
        $VERBOSE && echo "No wiki found for $REPO or failed to clone."
      fi
    fi
  else
    $VERBOSE && echo "Repo $REPO does not have shared-wiki enabled."
  fi
done

$VERBOSE || echo "Wiki cloning and updating process completed."
