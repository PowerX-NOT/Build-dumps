#!/bin/bash

# Variables (replace these with your actual values)
REPO="PowerX-NOT/Build-dumps"             # GitHub repository (owner/repo)
RELEASE_DESCRIPTION="Description of this release"  # Description of the release

# Check if the correct number of arguments is provided
if [ $# -ne 2 ]; then
  echo "Usage: ./upload_release.sh <TAG_NAME> <drag & drop your file>"
  exit 1
fi

# Get the tag name (used for both RELEASE_NAME and TAG_NAME) and the dropped file path from arguments
TAG_NAME="$1"
ZIP_FILE="$2"

# Check if the specified file exists
if [ ! -f "$ZIP_FILE" ]; then
  echo "File $ZIP_FILE not found!"
  exit 1
fi

# Step 1: Create the Release and Upload the ZIP File
echo "Creating release $TAG_NAME and uploading $ZIP_FILE..."

gh release create "$TAG_NAME" "$ZIP_FILE" \
  --repo "$REPO" \
  --title "$TAG_NAME" \
  --notes "$RELEASE_DESCRIPTION"

# Check if the release was successful
if [ $? -eq 0 ]; then
  echo "Release created and $ZIP_FILE uploaded successfully!"
else
  echo "Failed to create release or upload file. Deleting tag $TAG_NAME..."
  
  # Delete the tag if the release failed
  git tag -d "$TAG_NAME"    # Delete the local tag
  git push origin --delete "$TAG_NAME"   # Delete the remote tag
  
  echo "Tag $TAG_NAME deleted."
  exit 1
fi

