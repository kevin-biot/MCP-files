#!/bin/bash
# Make the unified startup script executable
chmod +x /Users/kevinbrown/MCP-files/start-unified.sh
echo "✅ start-unified.sh is now executable"
echo ""
echo "Usage examples:"
echo "  ./start-unified.sh          # Start with default port 8080"
echo "  ./start-unified.sh 9000     # Start with MCP server on port 9000"
echo "  ./start-unified.sh --help   # Show help"
echo ""
echo "The script will:"
echo "  1. Start ChromaDB on 127.0.0.1:8000"
echo "  2. Start MCP File Server on localhost:[port]/mcp"
echo "  3. Include all your project directories"
echo "  4. Handle graceful shutdown with Ctrl+C"
