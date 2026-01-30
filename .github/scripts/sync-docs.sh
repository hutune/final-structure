#!/bin/bash
set -e

# ============================================
# Sync Markdown Docs to ClickUp Docs/Pages
# Enhanced: Standalone Docs + Nested Pages
# ============================================

WORKSPACE_ID="${CLICKUP_WORKSPACE_ID}"
TEAM_PROCESSES_DOC_ID="${CLICKUP_TEAM_PROCESSES_DOC_ID}"
TECH_SPECS_DOC_ID="${CLICKUP_TECH_SPECS_DOC_ID}"
API_KEY="${CLICKUP_API_KEY}"

if [ -z "$API_KEY" ]; then
  echo "❌ CLICKUP_API_KEY not set"
  exit 1
fi

# Get all markdown files to sync
echo "📂 Searching for docs to sync..."
CHANGED_FILES=""

# Include README.md if it exists
if [ -f "README.md" ]; then
  CHANGED_FILES="README.md"
fi

# Add docs from team-processes and tech-specs
DOCS_FILES=$(find docs/team-processes docs/tech-specs docs/bmad_onboarding -name '*.md' -type f 2>/dev/null || true)
if [ -n "$DOCS_FILES" ]; then
  CHANGED_FILES="$CHANGED_FILES $DOCS_FILES"
fi

# Trim leading/trailing whitespace
CHANGED_FILES=$(echo "$CHANGED_FILES" | xargs)

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
  sed -n '/^---$/,/^---$/p' "$file" | grep "^$key:" | sed "s/^$key: *//; s/\"//g; s/'//g" || echo ""
}

# Function to update frontmatter value
update_frontmatter_value() {
  local file=$1
  local key=$2
  local value=$3
  sed -i.bak "s/^$key:.*/$key: \"$value\"/" "$file"
  rm -f "${file}.bak"
}

# Function to get markdown content (excluding frontmatter)
get_markdown_content() {
  local file=$1
  sed '/^---$/,/^---$/d' "$file"
}

# Function to get title from filename or frontmatter
get_title() {
  local file=$1
  local title=$(get_frontmatter_value "$file" "title")
  
  if [ -z "$title" ]; then
    basename "$file" .md | sed 's/-/ /g; s/\b\(.\)/\u\1/g'
  else
    echo "$title"
  fi
}

# ===========================================
# MAIN PROCESSING LOOP
# ===========================================
for FILE in $CHANGED_FILES; do
  echo ""
  echo "=== Processing: $FILE ==="
  
  # Extract metadata
  DOC_TYPE=$(get_frontmatter_value "$FILE" "type")
  TITLE=$(get_title "$FILE")
  CONTENT=$(get_markdown_content "$FILE")
  
  echo "📝 Title: $TITLE"
  
  # =========================================
  # STANDALONE DOC (type: "doc")
  # Uses a root page inside the Doc to store content
  # (ClickUp API v3 doesn't support updating Doc root content)
  # =========================================
  if [ "$DOC_TYPE" == "doc" ]; then
    echo "📚 Type: Standalone Doc"
    
    DOC_ID=$(get_frontmatter_value "$FILE" "clickup_doc_id")
    ROOT_PAGE_ID=$(get_frontmatter_value "$FILE" "clickup_root_page_id")
    
    # For standalone Docs, we need to create the Doc first, then add content as a page
    if [ -z "$DOC_ID" ] || [ "$DOC_ID" == "null" ]; then
      # CREATE new standalone Doc (empty, just the container)
      echo "➕ Creating new standalone Doc..."
      
      DOC_PAYLOAD=$(jq -n \
        --arg name "$TITLE" \
        '{
          name: $name
        }')
      
      RESPONSE=$(curl -s -X POST \
        "https://api.clickup.com/api/v3/workspaces/$WORKSPACE_ID/docs" \
        -H "Authorization: $API_KEY" \
        -H "Content-Type: application/json" \
        -d "$DOC_PAYLOAD")
      
      NEW_DOC_ID=$(echo "$RESPONSE" | jq -r '.id // empty')
      
      if [ -z "$NEW_DOC_ID" ]; then
        echo "❌ Failed to create Doc"
        echo "Response: $RESPONSE"
        exit 1
      fi
      
      echo "✅ Created Doc: $NEW_DOC_ID"
      DOC_ID="$NEW_DOC_ID"
      
      # Write back to frontmatter
      update_frontmatter_value "$FILE" "clickup_doc_id" "$NEW_DOC_ID"
      echo "📌 Updated frontmatter with doc_id"
    else
      echo "📋 Using existing Doc: $DOC_ID"
    fi
    
    # Now create or update the root page inside this Doc
    PAGE_PAYLOAD=$(jq -n \
      --arg title "$TITLE" \
      --arg content "$CONTENT" \
      '{
        name: $title,
        content: $content,
        content_format: "text/md"
      }')
    
    if [ -z "$ROOT_PAGE_ID" ] || [ "$ROOT_PAGE_ID" == "null" ]; then
      # CREATE root page inside Doc
      echo "➕ Creating root page with content..."
      
      RESPONSE=$(curl -s -X POST \
        "https://api.clickup.com/api/v3/workspaces/$WORKSPACE_ID/docs/$DOC_ID/pages" \
        -H "Authorization: $API_KEY" \
        -H "Content-Type: application/json" \
        -d "$PAGE_PAYLOAD")
      
      NEW_PAGE_ID=$(echo "$RESPONSE" | jq -r '.id // empty')
      
      if [ -z "$NEW_PAGE_ID" ]; then
        echo "❌ Failed to create root page"
        echo "Response: $RESPONSE"
        exit 1
      fi
      
      echo "✅ Created root page: $NEW_PAGE_ID"
      
      # Write back to frontmatter
      update_frontmatter_value "$FILE" "clickup_root_page_id" "$NEW_PAGE_ID"
      echo "📌 Updated frontmatter with root_page_id"
      
    else
      # UPDATE existing root page
      echo "♻️  Updating root page: $ROOT_PAGE_ID..."
      
      PAGE_PAYLOAD=$(echo "$PAGE_PAYLOAD" | jq '. + {content_edit_mode: "replace"}')
      
      RESPONSE=$(curl -s -X PUT \
        "https://api.clickup.com/api/v3/workspaces/$WORKSPACE_ID/docs/$DOC_ID/pages/$ROOT_PAGE_ID" \
        -H "Authorization: $API_KEY" \
        -H "Content-Type: application/json" \
        -d "$PAGE_PAYLOAD")
      
      # Check for errors
      if echo "$RESPONSE" | jq -e . >/dev/null 2>&1; then
        ERROR=$(echo "$RESPONSE" | jq -r '.err // empty')
        if [ -n "$ERROR" ]; then
          echo "❌ Failed to update root page"
          echo "Error: $ERROR"
          exit 1
        fi
      fi
      
      echo "✅ Updated root page successfully"
    fi
    
    continue
  fi
  
  # =========================================
  # REGULAR PAGE (default)
  # =========================================
  
  # Determine parent doc ID based on path
  if [[ "$FILE" == docs/team-processes/* ]]; then
    DOC_ID="$TEAM_PROCESSES_DOC_ID"
    echo "📂 Target: Team Processes"
  elif [[ "$FILE" == docs/tech-specs/* ]]; then
    DOC_ID="$TECH_SPECS_DOC_ID"
    echo "📂 Target: Tech Specs & Architecture"
  elif [[ "$FILE" == docs/bmad_onboarding/* ]]; then
    # For bmad_onboarding, get parent doc ID from frontmatter
    DOC_ID=$(get_frontmatter_value "$FILE" "clickup_parent_doc_id")
    if [ -z "$DOC_ID" ] || [ "$DOC_ID" == "null" ]; then
      echo "⚠️  Skipping (no clickup_parent_doc_id in frontmatter)"
      continue
    fi
    echo "📂 Target: BMAD Onboarding Doc ($DOC_ID)"
  else
    echo "⚠️  Skipping (unknown folder)"
    continue
  fi
  
  # Extract page metadata
  PAGE_ID=$(get_frontmatter_value "$FILE" "clickup_page_id")
  PARENT_PAGE_ID=$(get_frontmatter_value "$FILE" "parent_page_id")
  
  # Prepare JSON payload for Page
  JSON_PAYLOAD=$(jq -n \
    --arg title "$TITLE" \
    --arg content "$CONTENT" \
    '{
      name: $title,
      content: $content,
      content_format: "text/md"
    }')
  
  # Add parent_page_id if specified (for nested pages)
  if [ -n "$PARENT_PAGE_ID" ] && [ "$PARENT_PAGE_ID" != "null" ]; then
    echo "📎 Parent Page: $PARENT_PAGE_ID"
    JSON_PAYLOAD=$(echo "$JSON_PAYLOAD" | jq --arg parent "$PARENT_PAGE_ID" '. + {parent_page_id: $parent}')
  fi
  
  if [ -z "$PAGE_ID" ] || [ "$PAGE_ID" == "null" ]; then
    # CREATE new page
    echo "➕ Creating new page..."
    
    RESPONSE=$(curl -s -X POST \
      "https://api.clickup.com/api/v3/workspaces/$WORKSPACE_ID/docs/$DOC_ID/pages" \
      -H "Authorization: $API_KEY" \
      -H "Content-Type: application/json" \
      -d "$JSON_PAYLOAD")
    
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
    
    JSON_PAYLOAD=$(echo "$JSON_PAYLOAD" | jq '. + {content_edit_mode: "replace"}')
    
    RESPONSE=$(curl -s -X PUT \
      "https://api.clickup.com/api/v3/workspaces/$WORKSPACE_ID/docs/$DOC_ID/pages/$PAGE_ID" \
      -H "Authorization: $API_KEY" \
      -H "Content-Type: application/json" \
      -d "$JSON_PAYLOAD")
    
    # Check for errors (only if response is valid JSON)
    if echo "$RESPONSE" | jq -e . >/dev/null 2>&1; then
      ERROR=$(echo "$RESPONSE" | jq -r '.err // empty')
      if [ -n "$ERROR" ]; then
        echo "❌ Failed to update page"
        echo "Error: $ERROR"
        exit 1
      fi
    fi
    
    echo "✅ Updated page successfully"
  fi
done

echo ""
echo "🎉 All docs synced to ClickUp!"

# Commit frontmatter changes back to repo
if git diff --quiet; then
  echo "✅ No frontmatter changes to commit"
else
  echo "📝 Committing ID updates..."
  git config user.name "GitHub Actions Bot"
  git config user.email "actions@github.com"
  git add README.md docs/ 2>/dev/null || git add docs/
  git commit -m "chore: Update ClickUp doc/page IDs [skip ci]"
  git push
  echo "✅ Pushed frontmatter updates"
fi
