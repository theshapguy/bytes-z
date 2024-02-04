#!/bin/bash

# Define the source and destination directories
source_dir="content/til"
destination_dir="content/posts"

cp -r "$source_dir"/til_* "$destination_dir"

echo "Contents of '$source_dir' copied to '$destination_dir' successfully."

echo "Building Site Now"
if [ "$CF_PAGES_BRANCH" == "main" ]; then
  # Run the "production" build
  zola build --force
else
  # Run the build  with drafts
  zola build --drafts --force --base-url $CF_PAGES_URL
fi