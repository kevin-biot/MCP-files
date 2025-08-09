#!/bin/bash
cd "$(dirname "$0")"
echo "🔨 Building MCP-files project..."
npm run build
echo "✅ Build completed!"
