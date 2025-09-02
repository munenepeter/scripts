#!/bin/bash
# .git/hooks/pre-push

# Get the project root directory
PROJECT_ROOT=$(git rev-parse --show-toplevel)

# Create storage/app directory if it doesn't exist
mkdir -p "$PROJECT_ROOT/storage/app"

# Get the latest commit hash and date
COMMIT_HASH=$(git rev-parse --short HEAD)
COMMIT_DATE=$(git log -1 --pretty=format:"%ad" --date=iso)

# Check if commit.json exists and has the same hash
EXISTING_HASH=""
if [ -f "$PROJECT_ROOT/storage/app/commit.json" ]; then
    EXISTING_HASH=$(grep -o '"hash": "[^"]*"' "$PROJECT_ROOT/storage/app/commit.json" | cut -d'"' -f4)
fi

# Only update if the hash is different (new commits since last push)
if [ "$EXISTING_HASH" != "$COMMIT_HASH" ]; then
    # Create proper JSON file
    cat > "$PROJECT_ROOT/storage/app/commit.json" << EOF
{
  "hash": "$COMMIT_HASH",
  "date": "$COMMIT_DATE",
  "generated_at": "$(date -u +"%Y-%m-%d %H:%M:%S UTC")"
}
EOF

    # Create a new commit for the commit.json update
    git add storage/app/commit.json
    git commit -m "Update deployment info: $COMMIT_HASH"
    
    echo "✓ Created new commit with updated commit.json: $COMMIT_HASH ($COMMIT_DATE)"
else
    echo "✓ commit.json already up to date: $COMMIT_HASH ($COMMIT_DATE)"
fi

exit 0
