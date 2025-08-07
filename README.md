# MCP-files: Enhanced Filesystem & Memory Server

A production-ready **Model Context Protocol (MCP) server** with advanced filesystem access and enhanced memory capabilities for AI assistants.

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Node Version](https://img.shields.io/badge/node-%3E%3D18-brightgreen)](https://nodejs.org/)

## ✨ Features

### Core Filesystem Operations
- 🔒 **Secure sandboxing** - Access limited to specified directories
- 🌐 **Dual transport** - Supports both HTTP and stdio modes
- 📁 **Complete filesystem operations** - Read, write, edit, search, and manage files
- 🔍 **Advanced file operations** - Memory-efficient tail/head, diff-based editing

### Enhanced Memory Capabilities
- 🧠 **Vector memory system** - Semantic search across conversations
- 📚 **Persistent knowledge** - Remember conversations across sessions
- 🔍 **Smart retrieval** - Auto-context from previous discussions
- 🏷️ **Auto-tagging** - Intelligent metadata extraction

### Security & Performance
- 🛡️ **Path validation** - Protection against directory traversal attacks
- 🔗 **Symlink safety** - Proper symlink resolution and validation
- 📊 **Rich metadata** - File sizes, permissions, timestamps
- 🎯 **Multiple clients** - Works with Claude Desktop, LM Studio, VS Code, and more

## 🚀 Quick Start

### Installation

```bash
# Clone the repository
git clone https://github.com/kevin-biot/MCP-files
cd MCP-files

# Install dependencies
npm install

# Build the project
npm run build
```

### Basic Usage

```bash
# HTTP mode (for LM Studio, web clients)
npm run start:http ~/Documents ~/Projects

# Stdio mode (for Claude Desktop)
npm run start:stdio ~/Documents ~/Projects
```

## 📋 Available Tools

### Filesystem Operations
| Tool | Description | Example Use |
|------|-------------|-------------|
| `read_file` | Read complete file contents | Code review, documentation |
| `write_file` | Create or overwrite files | Generate code, save content |
| `edit_file` | Make targeted edits with diffs | Refactor code, update configs |
| `list_directory` | Browse directory contents | Explore project structure |
| `search_files` | Find files by pattern | Locate specific files |
| `create_directory` | Create new directories | Set up project structure |
| `move_file` | Move or rename files | Organize files |

### Memory Operations
| Tool | Description | Example Use |
|------|-------------|-------------|
| `store_memory` | Save conversation for later | Store solutions, decisions |
| `search_memory` | Find relevant past conversations | Retrieve previous solutions |
| `list_memories` | Browse stored conversations | Review project history |

## 🔧 Client Configuration

### Claude Desktop
```json
{
  "mcpServers": {
    "files": {
      "command": "node",
      "args": ["/path/to/MCP-files/dist/index.js", "~/Documents", "~/Projects"]
    }
  }
}
```

### LM Studio
```json
{
  "mcpServers": {
    "files": {
      "url": "http://localhost:8080/mcp",
      "transport": "http"
    }
  }
}
```

## 🧠 Memory System

### Vector Database Storage
- **ChromaDB integration** for semantic search
- **JSON fallback** for reliability
- **Auto-tagging** of technical concepts
- **Session organization** by topics

### Smart Context Retrieval
- Finds related conversations by meaning
- Auto-includes relevant context in responses
- Clusters similar technical discussions
- Persistent across sessions

## 🛠️ Development

### Project Structure
```
MCP-files/
├── src/                     # TypeScript source code
├── dist/                    # Compiled JavaScript
├── scripts/                 # Utility scripts
├── examples/                # Configuration examples
├── __tests__/              # Test files
├── .mcp-memory/            # Local memory data (gitignored)
├── chroma/                 # ChromaDB data (gitignored)
└── README.md               # This file
```

### Building and Testing
```bash
# Development with watch mode
npm run dev

# Build for production
npm run build

# Run tests
npm run test

# Start development server
npm run start:http ~/Documents
```

### Memory System Inspection
```bash
# Check stored memory data
./scripts/inspect-json-memory.sh

# Full vector database inspection
./scripts/vector_data_inspection.sh
```

## 📚 Enhanced Features Coming Soon

- **Auto-memory storage** - Automatically save important conversations
- **Conversation threading** - Link related discussions
- **Smart importance detection** - Auto-identify valuable content
- **Memory consolidation** - Merge similar conversations
- **Enhanced context** - Automatic relevant context inclusion

## 🤝 Contributing

Contributions are welcome! This project aims to become the most advanced MCP server for filesystem and memory operations.

## 📝 License

MIT License - see [LICENSE](LICENSE) file for details.

---

⭐ **Star this repo** if you find it useful!
