#!/bin/bash
set -e

# ============================================
# Sync Markdown Docs to ClickUp Docs/Pages
# ============================================

WORKSPACE_ID="${CLICKUP_WORKSPACE_ID}"
TEAM_PROCESSES_DOC_ID="${CLICKUP_TEAM_PROCESSES_DOC_ID}"
TECH_SPECS_DOC_ID="${CLICKUP_TECH_SPECS_DOC_ID}"
API_KEY="${CLICKUP_API_KEY}"

if [ -z "$API_KEY" ]; then
  echo "❌ CLICKUP_API_KEY not set"
  exit 1
fi

# Get all markdown files in docs/ (simpler approach - sync all files on every run)
echo "📂 Searching for docs to sync..."
CHANGED_FILES=$(find docs/team-processes docs/tech-specs -name '*.md' -type f 2>/dev/null || true)

if [ -z "$CHANGED_FILES" ]; then
  echo "✅ No docs found"
  exit 0
fi

echo "📄 Docs to sync:"
echo "$CHANGED_FILES"

# Function to extract frontmatter value
get_frontmatter_value() {
  local file=$1
  local key=$2
  # Simple grep + sed extraction (assumes YAML frontmatter)
  sed -n '/^---$/,/^---$/p' "$file" | grep "^$key:" | sed "s/^$key: *//; s/\"//g; s/'//g" || echo ""
}

# Function to update frontmatter value
update_frontmatter_value() {
  local file=$1
  local key=$2
  local value=$3
  
  # Use sed to update the value in frontmatter
  sed -i.bak "s/^$key:.*/$key: \"$value\"/" "$file"
  rm -f "${file}.bak"
}

# Function to get markdown content (excluding frontmatter)
get_markdown_content() {
  local file=$1
  # Skip frontmatter, return rest
  sed '/^---$/,/^---$/d' "$file"
}

# Function to get page title from filename or frontmatter
get_page_title() {
  local file=$1
  local title=$(get_frontmatter_value "$file" "title")
  
  if [ -z "$title" ]; then
    # Use filename without extension
    basename "$file" .md | sed 's/-/ /g; s/\b\(.\)/\u\1/g'
  else
    echo "$title"
  fi
}

# Process each changed file
for FILE in $CHANGED_FILES; do
  echo ""
  echo "=== Processing: $FILE ===\"
  
  # Determine parent doc ID based on path
  if [[ "$FILE" == docs/team-processes/* ]]; then
    DOC_ID="$TEAM_PROCESSES_DOC_ID"
    echo "📂 Target: Team Processes"
  elif [[ "$FILE" == docs/tech-specs/* ]]; then
    DOC_ID="$TECH_SPECS_DOC_ID"
    echo "📂 Target: Tech Specs & Architecture"
  else
    echo "⚠️  Skipping (unknown folder)"
    continue
  fi
  
  # Extract metadata
  PAGE_ID=$(get_frontmatter_value "$FILE" "clickup_page_id")
  PAGE_TITLE=$(get_page_title "$FILE")
  CONTENT=$(get_markdown_content "$FILE")
  
  echo "📝 Title: $PAGE_TITLE"
  
  # Prepare JSON payload
  JSON_PAYLOAD=$(jq -n \
    --arg title "$PAGE_TITLE" \
    --arg content "$CONTENT" \
    '{
      name: $title,
      content: $content,
      content_format: "text/md"
    }')
  
  if [ -z "$PAGE_ID" ] || [ "$PAGE_ID" == "null" ]; then
    # CREATE new page
    echo "➕ Creating new page..."
    
    RESPONSE=$(curl -s -X POST \
      "https://api.clickup.com/api/v3/workspaces/$WORKSPACE_ID/docs/$DOC_ID/pages" \
      -H "Authorization: $API_KEY" \
      -H "Content-Type: application/json" \
      -d "$JSON_PAYLOAD")
    
    # Extract page ID from response
    NEW_PAGE_ID=$(echo "$RESPONSE" | jq -r '.id // empty')
    
    if [ -z "$NEW_PAGE_ID" ]; then
      echo "❌ Failed to create page"
      echo "Response: $RESPONSE"
      exit 1
    fi
    
    echo "✅ Created page: $NEW_PAGE_ID"
    
    # Write back to frontmatter
    update_frontmatter_value "$FILE" "clickup_page_id" "$NEW_PAGE_ID"
    echo "📌 Updated frontmatter with page_id"
    
  else
   # UPDATE existing page
    echo "♻️  Updating page: $PAGE_ID..."
    
    # Add content_edit_mode for updates
    JSON_PAYLOAD=$(echo "$JSON_PAYLOAD" | jq '. + {content_edit_mode: "replace"}')
    
    RESPONSE=$(curl -s -X PUT \
      "https://api.clickup.com/api/v3/workspaces/$WORKSPACE_ID/docs/$DOC_ID/pages/$PAGE_ID" \
      -H "Authorization: $API_KEY" \
      -H "Content-Type: application/json" \
      -d "$JSON_PAYLOAD")
    
    # Check for errors
    ERROR=$(echo "$RESPONSE" | jq -r '.err // empty')
    if [ -n "$ERROR" ]; then
      echo "❌ Failed to update page"
      echo "Error: $ERROR"
      exit 1
    fi
    
    echo "✅ Updated page successfully"
  fi
done

echo ""
echo "🎉 All docs synced to ClickUp!"

# Commit frontmatter changes (page IDs) back to repo
if git diff --quiet; then
  echo "✅ No frontmatter changes to commit"
else
  echo "📝 Committing page ID updates..."
  git config user.name "GitHub Actions Bot"
  git config user.email "actions@github.com"
  git add docs/
  git commit -m "chore: Update ClickUp page IDs [skip ci]"
  git push
  echo "✅ Pushed frontmatter updates"
fi
