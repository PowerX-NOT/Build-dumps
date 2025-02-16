#!/bin/bash

# Variables (replace these with your actual values)
REPO="PowerX-NOT/Build-dumps"  # GitHub repository (owner/repo)
RELEASE_DESCRIPTION="Description of this release"  # Description of the release

# Check if the correct number of arguments is provided
if [ $# -lt 2 ] || [ $# -gt 3 ]; then
  echo "Usage: ./upload.sh <TAG_NAME> <FILE_PATH> [-u]"
  exit 1
fi

# Get the tag name and the file path from arguments
TAG_NAME="$1"
ZIP_FILE="$2"
UPDATE_RELEASE=false

# Check if the optional -u flag is provided
if [ "$3" == "-u" ]; then
  UPDATE_RELEASE=true
fi

# Check if the specified file exists
if [ ! -f "$ZIP_FILE" ]; then
  echo "File $ZIP_FILE not found!"
  exit 1
fi

# Check if the release already exists
gh release view "$TAG_NAME" --repo "$REPO" > /dev/null 2>&1
if [ $? -eq 0 ]; then
  if [ "$UPDATE_RELEASE" = true ]; then
    echo "Updating existing release: $TAG_NAME"
    gh release upload "$TAG_NAME" "$ZIP_FILE" --repo "$REPO" --clobber
    if [ $? -eq 0 ]; then
      echo "Release $TAG_NAME updated successfully with $ZIP_FILE!"
    else
      echo "Failed to update release."
      exit 1
    fi
  else
    echo "Release $TAG_NAME already exists. Use -u to update the release."
    exit 1
  fi
else
  echo "Creating new release: $TAG_NAME"
  gh release create "$TAG_NAME" "$ZIP_FILE" \
    --repo "$REPO" \
    --title "$TAG_NAME" \
    --notes "$RELEASE_DESCRIPTION"

  if [ $? -eq 0 ]; then
    echo "Release created and $ZIP_FILE uploaded successfully!"
  else
    echo "Failed to create release or upload file. Deleting tag $TAG_NAME..."
    git tag -d "$TAG_NAME"
    git push origin --delete "$TAG_NAME"
    echo "Tag $TAG_NAME deleted."
    exit 1
  fi
fi
