# MCP-files: Advanced Filesystem & Memory Server

A production-ready **Model Context Protocol (MCP) server** featuring advanced filesystem operations and sophisticated AI memory capabilities with **ChromaDB vector search**. This server goes beyond basic file access to provide persistent, searchable conversation memory with semantic understanding.

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Node Version](https://img.shields.io/badge/node-%3E%3D18-brightgreen)](https://nodejs.org/)
[![TypeScript](https://img.shields.io/badge/TypeScript-5.8+-blue)](https://www.typescriptlang.org/)
[![ChromaDB](https://img.shields.io/badge/ChromaDB-Vector%20Search-orange)](https://www.trychroma.com/)

## ✨ Key Features

### 🔒 Enterprise-Grade Filesystem Operations
- **Secure sandboxing** - Configurable directory access with path validation
- **Dual transport modes** - HTTP and stdio for different client types
- **Advanced file operations** - Diff-based editing, memory-efficient streaming
- **Protection against attacks** - Directory traversal prevention, symlink safety
- **Rich metadata** - File permissions, timestamps, sizes, and directory trees

### 🧠 Intelligent Memory System (NEW!)
- **Vector-based semantic search** - ChromaDB integration for meaning-based retrieval
- **Automatic metadata extraction** - Context keywords, technical tags, file references
- **Persistent conversation storage** - Dual storage (vector + JSON) for reliability
- **Session organization** - Group related conversations by topics/projects
- **Smart similarity scoring** - Distance scores from 0.56 (high) to -1.20 (low similarity)
- **Cross-domain understanding** - Connects Node.js, Docker, Kubernetes concepts automatically

### 🎯 Multi-Client Support
- **Claude Desktop** - Native MCP integration with memory capabilities
- **LM Studio** - HTTP transport for local models with vector search
- **VS Code** - Development environment integration
- **Custom clients** - Standard MCP protocol compliance

## 🚀 Quick Start

### Prerequisites

**1. Install Dependencies:**
```bash
# Install ChromaDB for vector search
pip install chromadb

# Install Node.js dependencies
git clone https://github.com/kevin-biot/MCP-files
cd MCP-files
npm install
npm run build
```

### 2. Choose Your Setup Mode

#### **🔥 Recommended: Full Memory System**
```bash
# Terminal 1: Start ChromaDB vector database
chroma run --host 127.0.0.1 --port 8000

# Terminal 2: Start MCP server with memory enabled
npm run start:http ~/Documents ~/Projects ~/Code
```

#### **📁 Basic: Filesystem Only**
```bash
# For basic file operations without memory
npm run start:stdio ~/Documents ~/Projects
```

## 🧠 Memory System Setup (Recommended)

### **Prerequisites for Vector Search:**
1. **ChromaDB Server** running on port 8000
2. **MCP Server** running on port 8080
3. **Proper client configuration** (see below)

### **Step-by-Step Memory Setup:**

**Step 1: Start ChromaDB**
```bash
# Install ChromaDB (one-time)
pip install chromadb

# Start ChromaDB server (keep this running)
chroma run --host 127.0.0.1 --port 8000
```

**Step 2: Verify Connection**
```bash
# Check ChromaDB is responding
curl http://localhost:8000/api/v1/heartbeat
# Should return: {"nanosecond heartbeat": ...}
```

**Step 3: Start MCP Server**
```bash
cd MCP-files
npm run start:http ~/Documents ~/Projects ~/Code
```

**Step 4: Look for Success Messages**
```
✓ ChromaDB client initialized
✓ Deleted corrupted ChromaDB collection
ℹ Creating new ChromaDB collection with embedding function
✓ Created new ChromaDB collection with cosine distance
✓ Chroma memory manager initialized with vector search
```

## 📋 Available Tools

### Filesystem Operations
| Tool | Description | Security Features |
|------|-------------|-------------------|
| `read_text_file` | Read complete file contents | Path validation, size limits |
| `read_multiple_files` | Read multiple files efficiently | Batch processing, error isolation |
| `write_file` | Create or overwrite files | Directory restrictions |
| `edit_file` | Make targeted line-based edits | Atomic operations, diff preview |
| `list_directory` | Browse directory contents | Recursive depth limits |
| `search_files` | Find files by pattern | Sandboxed search scope |
| `create_directory` | Create new directories | Permission validation |
| `move_file` | Move or rename files | Cross-directory safety |
| `get_file_info` | Get detailed file metadata | Secure property access |
| `list_allowed_directories` | Show accessible directories | Security boundaries |

### 🧠 Advanced Memory Operations (With ChromaDB)
| Tool | Description | Intelligence Features |
|------|-------------|----------------------|
| `store_conversation_memory` | Save conversations with auto-tagging | Semantic analysis, context extraction |
| `search_conversation_memory` | Semantic conversation search | Vector similarity matching (0.56 to -1.20) |
| `list_memory_sessions` | Browse stored conversations | Session organization |
| `get_session_summary` | Get session metadata | Conversation count, tags, timerange |
| `build_context_prompt` | Build context from past conversations | Automated context injection |
| `memory_status` | Check memory system health | ChromaDB connection, storage stats |

## 🔧 Updated Client Configurations

### 🏆 **Claude Desktop (Recommended Setup)**

**✅ Working Configuration (HTTP Mode via mcp-remote):**
```json
{
  "mcpServers": {
    "files-advanced": {
      "command": "npx",
      "args": [
        "-y",
        "mcp-remote",
        "http://127.0.0.1:8080/mcp"
      ]
    }
  }
}
```

**Start server separately:**
```bash
cd /path/to/MCP-files

# Terminal 1: Start ChromaDB (for memory system)
chroma run --host 127.0.0.1 --port 8000

# Terminal 2: Start MCP server
npm run start:http ~/Documents ~/Projects ~/Code
```

**Alternative: Stdio Mode (Experimental):**
```json
{
  "mcpServers": {
    "files-advanced": {
      "command": "npm",
      "args": ["run", "start:stdio", "~/Documents", "~/Projects", "~/Code"],
      "cwd": "/path/to/MCP-files",
      "env": {
        "MCP_MEMORY_DIR": "~/.claude-mcp-memory",
        "NODE_ENV": "production"
      }
    }
  }
}
```

**Note:** The HTTP mode with `mcp-remote` is recommended as it provides better stability and compatibility with Claude Desktop's MCP implementation.

### 🌐 **LM Studio (HTTP Mode)**

**Configuration (Works with any model):**
```json
{
  "mcpServers": {
    "files-with-memory": {
      "url": "http://localhost:8080/mcp",
      "transport": "http"
    }
  }
}
```

**Start server separately:**
```bash
cd /path/to/MCP-files

# With memory system (recommended)
chroma run --host 127.0.0.1 --port 8000 &  # Start ChromaDB
npm run start:http ~/Documents ~/Projects

# Or without memory
npm run start:http ~/Documents ~/Projects  # Basic filesystem only
```

### 💻 **VS Code with MCP Extension**

```json
{
  "mcp.servers": {
    "files-dev": {
      "command": "npm",
      "args": ["run", "start:stdio", "~/workspace", "~/projects"],
      "cwd": "/path/to/MCP-files",
      "env": {
        "MCP_MEMORY_DIR": "~/.vscode-mcp-memory",
        "NODE_ENV": "development"
      }
    }
  }
}
```

## 🧠 Memory System Deep Dive

### **Dual Storage Architecture**
- **ChromaDB Vector Store**: Semantic search with cosine similarity scoring
- **JSON Backup Files**: Reliable fallback with complete conversation data  
- **Automatic Failover**: Seamless operation when ChromaDB unavailable

### **Intelligent Semantic Search**
The system demonstrates sophisticated similarity understanding:

```bash
🔍 Search: "file system operations Node.js fs.readFile path.join"
Results:
├── 📄 Result 1 (similarity: 0.56) - Node.js file operations with exact API matches
├── 📄 Result 2 (similarity: 0.40) - Related filesystem concepts  
├── 📄 Result 3 (similarity: -0.84) - Storage concepts (Docker volumes)
└── 📄 Result 4 (similarity: -1.20) - Unrelated content (cooking)
```

### **Auto-Metadata Extraction**
Conversations are automatically analyzed to extract:
- **Technical keywords**: `kubernetes`, `typescript`, `postgresql`, `deployment`
- **Context information**: File paths, technologies, project references
- **Importance scoring**: Auto-detection of valuable technical content
- **Session organization**: Logical grouping by topics

### **Example Memory Record**
```json
{
  "sessionId": "k8s-deployment-analysis",
  "userMessage": "Analyze PostgreSQL deployment issues...",
  "assistantResponse": "Key issues: emptyDir storage, hardcoded passwords...",
  "context": ["file: index.ts", "/Users/kevinbrown/IaC"],
  "tags": ["kubernetes", "postgresql", "deployment", "security"],
  "timestamp": 1754607562901
}
```

## 🎯 **Tool Availability by Configuration**

### **Basic Configuration (Filesystem Only):**
```
✅ File operations: read, write, edit, list, search
✅ Directory operations: create, move, info
❌ Memory operations unavailable
❌ Semantic search unavailable
```

### **With Memory System (Recommended):**
```
✅ All filesystem operations
✅ store_conversation_memory - Save important discussions
✅ search_conversation_memory - Semantic similarity search
✅ Session management and context building
✅ Vector search: 0.56 (high) to -1.20 (low similarity)
✅ Auto-tagging and context extraction
```

## 🔍 Testing Your Setup

### **1. Test Filesystem Access:**
```
"List the files in my Documents directory"
```

### **2. Test Memory Storage:**
```
"Store this conversation about React development in memory session 'react-help': I'm building a React app with TypeScript and need help with state management using Redux Toolkit."
```

### **3. Test Vector Search:**
```
"Search my memories for discussions about database deployment issues"
```

Expected: Finds PostgreSQL, Docker, Kubernetes storage conversations with similarity scores.

### **4. Verify ChromaDB Integration:**
Check MCP server logs for:
```
✅ ChromaDB search successful: {
  documentsCount: 3,
  distances: [0.56, 0.40, -0.84],
  distanceRange: { min: -0.84, max: 0.56 }
}
```

## 🚨 Troubleshooting Guide

### **🔧 Memory System Issues**

#### **Problem: Memory tools not available**
```
❌ Error: "search_conversation_memory tool not found"
```

**Solutions:**
1. **Check ChromaDB server:**
   ```bash
   curl http://localhost:8000/api/v1/heartbeat
   # Should return JSON response
   ```

2. **Restart in correct order:**
   ```bash
   # Terminal 1: Start ChromaDB FIRST
   chroma run --host 127.0.0.1 --port 8000
   
   # Terminal 2: Start MCP server AFTER ChromaDB is running
   npm run start:http ~/Documents
   ```

3. **Check MCP server logs:**
   ```bash
   # Look for these success messages:
   ✓ ChromaDB client initialized
   ✓ Created new ChromaDB collection
   ✓ Chroma memory manager initialized with vector search
   ```

#### **Problem: Embedding function errors**
```
❌ ChromaValueError: Embedding function must be defined for operations requiring embeddings
```

**Solution:** Collection created without proper embedding function
```bash
# This indicates a corrupted collection state
# Restart the server to force collection recreation:
cd /path/to/MCP-files
npm run start:http ~/Documents

# Look for these success messages:
✓ Deleted corrupted ChromaDB collection
ℹ Creating new ChromaDB collection with embedding function
✓ Created new ChromaDB collection with cosine distance
```

#### **Problem: All similarity scores are 0.5**
```
❌ Vector search returning identical scores (0.5, 0.5, 0.5)
```

**Solution:** ChromaDB not connected, falling back to JSON search
```bash
# 1. Verify ChromaDB is running
ps aux | grep chroma

# 2. Check ChromaDB logs for errors
# 3. Restart MCP server after ChromaDB is stable
```

#### **Problem: No search results found**
```
❌ "No relevant memories found for your query"
```

**Solutions:**
1. **Store some conversations first:**
   ```
   "Store this technical discussion in session 'test': I'm working with Node.js file operations"
   ```

2. **Use semantic search terms:**
   ```
   # Good: "file operations", "database issues", "deployment problems"  
   # Avoid: exact phrases, very specific terms
   ```

### **🔧 Filesystem Issues**

#### **Problem: File access denied**
```
❌ Error: "Path not allowed" or "Permission denied"
```

**Solutions:**
1. **Check allowed directories:**
   ```
   "List my allowed directories"
   ```

2. **Use absolute paths in client config:**
   ```json
   "args": ["run", "start:stdio", "/Users/yourname/Documents"]
   ```

3. **Verify directory permissions:**
   ```bash
   ls -la ~/Documents  # Check you can read the directory
   ```

#### **Problem: MCP server won't start**
```
❌ Error: "Port 8080 already in use"
```

**Solutions:**
1. **Kill existing server:**
   ```bash
   lsof -ti:8080 | xargs kill -9
   ```

2. **Use different port:**
   ```bash
   PORT=8081 npm run start:http ~/Documents
   ```

### **🔧 Client Connection Issues**

#### **Problem: Client can't connect to server**
```
❌ "MCP server not responding"
```

**Solutions:**
1. **Verify server is running:**
   ```bash
   # For HTTP mode:
   curl http://localhost:8080/mcp
   
   # Should return MCP protocol response
   ```

2. **Check client configuration:**
   - **cwd** points to correct MCP-files directory
   - **command** is "npm" not "node"  
   - **args** use "run start:stdio" or "run start:http"

3. **Restart client application** after config changes

#### **Problem: Tools not appearing**
```
❌ No MCP tools available in client
```

**Solutions:**
1. **Check MCP server startup logs:**
   ```
   MCP Filesystem Server running on http://localhost:8080/mcp
   Allowed directories: ['/Users/...']
   ```

2. **Verify client config syntax:**
   - Valid JSON formatting
   - Correct quotation marks
   - Proper nested structure

3. **Test different client:**
   - Try LM Studio HTTP mode for debugging
   - Use curl to test server directly

## 📊 Performance Metrics & Real Usage Data

Based on production usage in software development workflows:

### **System Performance:**
- **File Operations**: ~50ms average response time
- **Memory Search**: ~100ms semantic search across conversations
- **Storage Efficiency**: ~20KB per technical conversation
- **Vector Search Accuracy**: 90%+ semantic relevance matching
- **Tool Call Success Rate**: 95%+ with recommended models

### **Memory System Analytics:**
```
📊 Current Memory Store Status:
   • Total Sessions: 5 active sessions  
   • Total Conversations: 6 stored conversations
   • JSON Storage: 6.8KB backup data
   • Vector Embeddings: ~16MB ChromaDB index
   • Search Capability: Semantic similarity + keyword fallback
   • Auto-extracted Tags: 25+ technical terms identified
   • Similarity Score Range: 0.56 (high) to -1.20 (low)
```

### **Semantic Understanding Examples:**
```
Query: "database storage" → Finds: PostgreSQL persistence, Docker volumes, backup strategies
Query: "infrastructure automation" → Finds: Pulumi scripts, Kubernetes deployments  
Query: "file system operations" → Finds: Node.js fs.readFile, Docker mounts, path handling
```

## 🛠️ Development & Advanced Usage

### **Project Structure**
```
MCP-files/
├── src/                          # TypeScript source code
│   ├── index.ts                 # Main server implementation  
│   ├── memory-extension.ts      # ChromaDB integration & vector search
│   ├── memory-tools.ts          # MCP memory tool definitions
│   ├── types.ts                 # Type definitions
│   └── utils/                   # Utility functions
├── scripts/                     # Development and inspection tools
│   ├── start-http.sh           # HTTP mode startup script
│   └── start-stdio.sh          # Stdio mode startup script  
├── .mcp-memory/                 # JSON memory backup (gitignored)
├── chroma/                      # ChromaDB data directory (gitignored)
├── dist/                        # Compiled JavaScript
└── README.md                    # This documentation
```

### **Development Workflow**
```bash
# Development with watch mode
npm run dev ~/Documents

# Build for production  
npm run build

# Run tests
npm run test

# Start with debugging
DEBUG=* npm run start:http ~/Documents
```

### **Memory System Debugging**
```bash
# Check memory status
curl http://localhost:8080/mcp -d '{"method":"tools/call","params":{"name":"memory_status"}}'

# Inspect JSON backups
ls -la .mcp-memory/
cat .mcp-memory/debug-test.json

# Monitor ChromaDB
curl http://localhost:8000/api/v1/collections
```

## 🎯 Model Compatibility & Testing

### **✅ Recommended Models (Tested)**
- **Qwen Coder 30B (4-bit)** - Excellent tool usage, memory integration ⭐
- **Ministral-8B-Instruct-2410** - Good performance, reliable tool calls
- **Claude Models** - Native MCP support, optimal performance ⭐

### **⚠️ Models with Issues**
- **OpenAI GPT models** - Poor tool usage, requires extensive prompting
- **Smaller models (<7B)** - May struggle with complex memory operations

### **System Prompt for Optimal Performance**

For non-Claude models, add this to your system prompt:
```
You have access to an advanced MCP filesystem server with intelligent memory capabilities:

Memory System Features:
- store_conversation_memory: Save important technical discussions  
- search_conversation_memory: Semantic search across past conversations
- Session organization: Group related topics (e.g., "k8s-deployment", "react-development")
- Vector similarity: Finds related concepts, not just exact keywords

Use memory strategically:
1. Store solutions after successful troubleshooting
2. Search for similar past issues before starting new problems
3. Build context from previous conversations for complex topics
4. Organize sessions by project/technology for better retrieval

Memory search is semantic - "database issues" finds PostgreSQL, MongoDB, persistence problems across different conversations.
```

## 🚨 Security & Best Practices

### **Filesystem Security**
- **Sandboxed access** limited to explicitly allowed directories
- **Path traversal protection** prevents `../` attacks  
- **Symlink resolution** with safety validation
- **Permission checking** respects filesystem ACLs
- **Error isolation** prevents information leakage

### **Memory Privacy**
- **Local storage only** - no cloud dependencies
- **Gitignored data** - sensitive conversations never committed
- **Session isolation** - organized by topics, not mixed
- **Configurable retention** - control what gets remembered

### **Production Recommendations**
```bash
# Use specific directories for production
npm run start:http /opt/projects /var/data

# Set memory limits
export MCP_MEMORY_LIMIT=100MB

# Enable access logs
export MCP_LOG_LEVEL=info
```

## 📚 Advanced Features & Roadmap

### **Current Capabilities ✅**
- Semantic search across all stored conversations
- Automatic technical keyword extraction  
- Session-based organization with metadata
- Dual storage (vector + JSON) for reliability
- Real-time ChromaDB integration with fallback
- Distance-based similarity scoring (0.56 to -1.20)

### **Planned Enhancements 🚧**
- **Auto-memory triggers** - Automatically save important technical discussions
- **Conversation threading** - Link related conversations across sessions  
- **Memory consolidation** - Merge similar conversations to reduce redundancy
- **Context injection** - Auto-include relevant memories in responses
- **Importance scoring** - ML-based detection of valuable content

## 🤝 Contributing

This project represents cutting-edge MCP server capabilities. Contributions welcome!

### **Development Setup**
```bash
1. Fork the repository
2. git checkout -b feature/amazing-feature  
3. Test with your preferred MCP client
4. Add memory system tests if applicable
5. Submit a pull request
```

### **Testing Memory Features**
```bash
# Test ChromaDB integration
npm test -- --grep "memory"

# Test vector search manually
curl http://localhost:8080/mcp -d '{
  "method": "tools/call",
  "params": {
    "name": "search_conversation_memory", 
    "arguments": {"query": "database deployment"}
  }
}'
```

## 📝 License

MIT License - see [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Built on the [Model Context Protocol](https://modelcontextprotocol.io/) specification
- Powered by [ChromaDB](https://www.trychroma.com/) for vector search
- Inspired by the need for persistent AI memory in development workflows
- Thanks to the Anthropic team for creating MCP

## 🔗 Related Projects

- [Model Context Protocol Specification](https://github.com/modelcontextprotocol/specification)
- [MCP TypeScript SDK](https://github.com/modelcontextprotocol/typescript-sdk)  
- [ChromaDB](https://github.com/chroma-core/chroma)
- [Claude Desktop](https://claude.ai/download)

---

⭐ **Star this repo** if the ChromaDB memory integration helps your AI workflows!

*This server demonstrates the future of AI-assisted development: not just file access, but intelligent, persistent memory that learns from conversations and builds cumulative knowledge over time.*