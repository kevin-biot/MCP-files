#!/bin/bash

echo "📁 JSON Memory Storage Inspection..."
echo "===================================="

MEMORY_DIR="/Users/kevinbrown/servers/.mcp-memory"

if [ -d "$MEMORY_DIR" ]; then
    echo "✅ Memory directory found: $MEMORY_DIR"
    echo ""
    
    echo "📋 Available session files:"
    ls -la "$MEMORY_DIR"/*.json 2>/dev/null || echo "No JSON files found"
    
    echo ""
    echo "📊 File sizes and record counts:"
    for file in "$MEMORY_DIR"/*.json; do
        if [ -f "$file" ]; then
            SESSION_NAME=$(basename "$file" .json)
            FILE_SIZE=$(stat -f%z "$file" 2>/dev/null || stat -c%s "$file" 2>/dev/null)
            RECORD_COUNT=$(jq '. | length' "$file" 2>/dev/null || echo "unknown")
            
            echo "Session: $SESSION_NAME"
            echo "  File size: $FILE_SIZE bytes"
            echo "  Records: $RECORD_COUNT conversations"
            echo "  Location: $file"
            echo ""
        fi
    done
    
    echo "🔍 Sample detailed record (first session):"
    FIRST_FILE=$(ls "$MEMORY_DIR"/*.json 2>/dev/null | head -1)
    if [ -f "$FIRST_FILE" ]; then
        echo "From: $(basename "$FIRST_FILE")"
        echo "Structure:"
        jq '.[0] | keys' "$FIRST_FILE" 2>/dev/null || echo "Raw content preview:"
        head -20 "$FIRST_FILE"
        
        echo ""
        echo "📏 Data size breakdown for first record:"
        jq -r '.[0] | 
        "User message length: " + (.userMessage | length | tostring) + " chars\n" +
        "Assistant response length: " + (.assistantResponse | length | tostring) + " chars\n" + 
        "Context items: " + (.context | length | tostring) + "\n" +
        "Tags: " + (.tags | length | tostring) + "\n" +
        "Total JSON size: ~" + (. | tostring | length | tostring) + " chars"' "$FIRST_FILE" 2>/dev/null
    fi
    
else
    echo "❌ Memory directory not found: $MEMORY_DIR"
fi

echo ""
echo "💡 This shows you:"
echo "- Exact JSON structure stored for each conversation"
echo "- File sizes and storage overhead"
echo "- Auto-extracted tags and context"
echo "- Complete conversation content"