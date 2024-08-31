#!/bin/bash

# Navigate to the workspace folder
cd /workspaces/$(basename $PWD)

# Install Bundler if not already installed
if ! gem spec bundler > /dev/null 2>&1; then
  gem install bundler
fi

# Create a Gemfile if it doesn't exist
if [ ! -f "Gemfile" ]; then
  echo 'source "https://rubygems.org"' > Gemfile
  echo 'gem "jekyll"' >> Gemfile
  echo 'gem "just-the-docs"' >> Gemfile
fi

# Install the gems specified in the Gemfile
bundle install

# Optional: Build the Jekyll site to verify the setup
# bundle exec jekyll build
