# MCP-files Testing Guide

Complete testing suite for verifying your MCP-files server setup with ChromaDB memory system.

## 🎯 Quick Test Status Check

Run this first to verify your setup:

### **Prerequisites Check**
```bash
# 1. Check ChromaDB is running
curl -s http://localhost:8000/api/v1/heartbeat || echo "❌ ChromaDB not running"

# 2. Check MCP server is running  
curl -s http://localhost:8080/mcp || echo "❌ MCP server not running"

# 3. Check Node.js version
node --version  # Should be >= 18

# 4. Check build status
ls -la dist/index.js || echo "❌ Run 'npm run build'"
```

## 🧪 Test Suite Overview

### **Phase 1: Basic Setup Verification** ⚡
- [x] Server startup and health checks
- [x] Filesystem access verification
- [x] ChromaDB connection testing

### **Phase 2: Memory System Testing** 🧠  
- [x] Memory storage and retrieval
- [x] Vector search functionality
- [x] Semantic similarity scoring
- [x] Session management

### **Phase 3: Advanced Features** 🚀
- [x] Cross-session searches
- [x] Context building and injection
- [x] Error handling and fallbacks
- [x] Performance benchmarking

## 📋 Phase 1: Basic Setup Verification

### **Test 1.1: Server Health Check**

**Start your servers:**
```bash
# Terminal 1: ChromaDB
chroma run --host 127.0.0.1 --port 8000

# Terminal 2: MCP Server
cd /path/to/MCP-files
npm run start:http ~/Documents ~/Projects
```

**Expected Output:**
```
✓ ChromaDB client initialized
✓ Deleted existing ChromaDB collection
✓ Created new ChromaDB collection with cosine distance
✓ Chroma memory manager initialized with vector search
MCP Filesystem Server running on http://localhost:8080/mcp
```

**✅ PASS Criteria:** All checkmarks appear, no error messages

### **Test 1.2: Filesystem Access**

**Prompt your LLM client:**
```
"List the files in my Documents directory"
```

**Expected Response:**
- Directory contents displayed
- No permission errors
- Proper file/directory formatting

**✅ PASS Criteria:** Files listed successfully, no errors

### **Test 1.3: Tool Availability Check**

**Prompt:**
```
"What MCP tools are available to you?"
```

**Expected Tools (Filesystem):**
- `read_text_file`
- `write_file`
- `edit_file`
- `list_directory`
- `search_files`
- `create_directory`
- `move_file`
- `get_file_info`
- `list_allowed_directories`

**Expected Tools (Memory - with ChromaDB):**
- `store_conversation_memory`
- `search_conversation_memory`
- `list_memory_sessions`
- `get_session_summary`
- `build_context_prompt`
- `memory_status`

**✅ PASS Criteria:** All tools available, memory tools present when ChromaDB running

## 🧠 Phase 2: Memory System Testing

### **Test 2.1: Memory Storage**

**Prompt:**
```
Store this test memory in session 'test-setup': "I'm testing the MCP-files server with ChromaDB vector search. The system should automatically extract tags like 'testing', 'chromadb', 'vector search' and store this conversation for later retrieval."
```

**Expected Response:**
- Success confirmation message
- Session created
- Auto-extracted tags mentioned

**Server Logs Should Show:**
```
💾 Storing to ChromaDB: {
  id: 'test-setup_[timestamp]',
  documentLength: [length],
  sessionId: 'test-setup'
}
✅ Successfully stored to ChromaDB
```

**✅ PASS Criteria:** Storage successful, server logs confirm ChromaDB storage

### **Test 2.2: Basic Memory Retrieval**

**Prompt:**
```
Search for memories about "testing MCP server"
```

**Expected Response:**
- Finds the stored test memory
- Shows relevance/similarity score
- Content matches what was stored

**Server Logs Should Show:**
```
🔍 Searching for: "testing MCP server" (sessionId: all, limit: 5)
📊 Attempting ChromaDB vector search...
✅ ChromaDB search successful: {
  documentsCount: 1,
  distances: [some_score]
}
```

**✅ PASS Criteria:** Memory found, positive similarity score, no fallback to JSON search

### **Test 2.3: Semantic Search Testing**

**Store diverse content:**
```
Store in session 'tech-test-1': "Working with PostgreSQL database deployment using Docker containers and Kubernetes orchestration for persistent data storage."

Store in session 'tech-test-2': "Building a React application with TypeScript, implementing JWT authentication and state management with Redux Toolkit."

Store in session 'cooking-test': "Making chocolate chip cookies requires butter, sugar, eggs, and flour mixed together before baking at 350 degrees."
```

**Then search:**
```
Search for memories about "database deployment issues"
```

**Expected Results:**
1. **PostgreSQL/Docker content** (high similarity ~0.4 to 0.6)
2. **React/TypeScript content** (low similarity ~-0.2 to -0.8)  
3. **Cooking content** (very low similarity ~-1.0 to -1.5)

**✅ PASS Criteria:** Results ranked by semantic relevance, database content scores highest

### **Test 2.4: Session Management**

**Prompt:**
```
List all my memory sessions
```

**Expected Response:**
- Shows all created sessions: `test-setup`, `tech-test-1`, `tech-test-2`, `cooking-test`
- Session metadata if available

**Prompt:**
```
Get summary of session 'tech-test-1'
```

**Expected Response:**
- Session details
- Conversation count  
- Auto-extracted tags: `postgresql`, `docker`, `kubernetes`, `database`, `deployment`
- Timestamp information

**✅ PASS Criteria:** Sessions listed correctly, summaries contain extracted metadata

## 🚀 Phase 3: Advanced Features Testing

### **Test 3.1: Cross-Session Semantic Search**

**Prompt:**
```
Search across all sessions for discussions about "container technology"
```

**Expected Results:**
- Finds PostgreSQL/Docker content from `tech-test-1`
- May find related container concepts from other sessions
- Scores show semantic understanding (Docker = containers)

**✅ PASS Criteria:** Semantic connections found across different sessions

### **Test 3.2: Context Building**

**Prompt:**
```
Build context from my previous conversations about database deployment and help me with a new PostgreSQL scaling issue.
```

**Expected Response:**
- References previous PostgreSQL/Docker discussion
- Builds on stored knowledge
- Provides informed recommendations based on context

**✅ PASS Criteria:** Response incorporates previous conversation context

### **Test 3.3: Memory Status Check**

**Prompt:**
```
Check my memory system status
```

**Expected Response:**
```
Memory System Status:
✅ ChromaDB: Connected and operational
✅ Sessions: 4 active sessions  
✅ Total Conversations: 4 stored
✅ Storage: JSON backup + vector search enabled
✅ Search Type: Semantic similarity (ChromaDB)
📊 Session Details: [session breakdown]
```

**✅ PASS Criteria:** All systems show as operational, accurate counts

### **Test 3.4: Error Handling - ChromaDB Disconnection**

**Steps:**
1. Stop ChromaDB server (Ctrl+C in ChromaDB terminal)
2. Try a memory search:
   ```
   Search for memories about "database"
   ```

**Expected Behavior:**
- Search still works (fallback to JSON)
- Server logs show fallback:
  ```
  ❌ Chroma search failed, falling back to JSON search
  📄 Using JSON search fallback...
  📄 JSON search returned X results
  ```
- Results have similarity score of 0.5 (JSON search indicator)

**✅ PASS Criteria:** System continues working with JSON fallback

### **Test 3.5: Recovery Test**

**Steps:**
1. Restart ChromaDB: `chroma run --host 127.0.0.1 --port 8000`
2. Try the same search again

**Expected Behavior:**
- Vector search resumes automatically
- Server logs show ChromaDB reconnection
- Similarity scores return to varied values (not 0.5)

**✅ PASS Criteria:** Seamless recovery to vector search

## 📊 Performance Benchmarking

### **Test 4.1: Response Time Testing**

**File Operation Benchmark:**
```
Time this: "List all files in my Documents directory recursively"
```
**Target:** < 500ms for typical directory

**Memory Search Benchmark:**
```
Time this: "Search for memories about technology"
```
**Target:** < 200ms with vector search, < 100ms with JSON fallback

### **Test 4.2: Storage Efficiency**

**Check storage growth:**
```bash
# Before storing memories
du -sh .mcp-memory/
ls -la chroma/

# Store 10 technical conversations
# Check growth again
du -sh .mcp-memory/
ls -la chroma/
```

**Expected:**
- JSON: ~1-2KB per conversation
- ChromaDB: ~10-20KB per conversation (including embeddings)

### **Test 4.3: Similarity Score Validation**

**Store identical content:**
```
Store in session 'identical-test': "Node.js filesystem operations using fs.readFile and path.join"
```

**Search for exact match:**
```
Search for "Node.js filesystem operations using fs.readFile and path.join"
```

**Expected:** High similarity score (0.8+, potentially 0.99+)

**Search for related content:**
```
Search for "file system operations"  
```

**Expected:** Moderate similarity score (0.3-0.7)

**Search for unrelated content:**
```
Search for "cooking recipes"
```

**Expected:** Low/negative similarity score (-0.5 to -1.2)

**✅ PASS Criteria:** Clear score differentiation based on semantic similarity

## 🔧 Troubleshooting Test Failures

### **❌ Test 1.1 Fails: Server Won't Start**

**Common Issues:**
```bash
# Port already in use
lsof -ti:8080 | xargs kill -9
lsof -ti:8000 | xargs kill -9

# ChromaDB not installed
pip install chromadb

# Build not current
npm run build
```

### **❌ Test 2.1 Fails: Memory Storage Issues**

**Debug Steps:**
```bash
# Check ChromaDB is responding
curl http://localhost:8000/api/v1/heartbeat

# Check MCP server logs for errors
# Look for: "ChromaDB storage failed"

# Verify ChromaDB collection exists
curl http://localhost:8000/api/v1/collections
```

### **❌ Test 2.2 Fails: Search Returns No Results**

**Common Causes:**
- No memories stored yet (run Test 2.1 first)
- ChromaDB connection lost (check server logs)
- Search terms too specific (try broader terms)

### **❌ Test 2.3 Fails: All Scores Are 0.5**

**This indicates JSON fallback mode:**
- ChromaDB server stopped or not connected
- Check for error messages in MCP server logs
- Restart ChromaDB and MCP server in correct order

### **❌ Memory Tools Not Available**

**Client Configuration Issues:**
```json
// Ensure client config has correct settings
{
  "mcpServers": {
    "files": {
      "command": "npm",
      "args": ["run", "start:stdio", "~/Documents"],
      "cwd": "/path/to/MCP-files"
    }
  }
}
```

## 📈 Expected Performance Baselines

### **Healthy System Metrics:**

**Response Times:**
- File operations: 10-100ms
- Memory storage: 50-200ms  
- Vector search: 50-150ms
- JSON fallback: 20-80ms

**Similarity Score Ranges:**
- Identical content: 0.8-0.99
- Very similar: 0.4-0.8
- Related concepts: 0.1-0.4
- Different topics: -0.2 to -0.8
- Unrelated content: -0.8 to -1.5

**Storage Efficiency:**
- JSON backup: ~1.5KB per conversation
- Vector embeddings: ~15KB per conversation
- Total overhead: ~10x for semantic search capability

## ✅ Test Completion Checklist

### **Basic Functionality:**
- [ ] Server starts without errors
- [ ] ChromaDB connection established
- [ ] Filesystem tools work correctly
- [ ] Memory tools available

### **Memory System:**
- [ ] Conversations store successfully
- [ ] Vector search finds relevant content
- [ ] Similarity scores vary appropriately
- [ ] Session management works
- [ ] Auto-tagging extracts keywords

### **Advanced Features:**
- [ ] Cross-session search works
- [ ] Context building incorporates past conversations
- [ ] JSON fallback activates when ChromaDB unavailable
- [ ] System recovers when ChromaDB reconnects
- [ ] Performance meets baseline expectations

### **Error Handling:**
- [ ] Graceful degradation to JSON search
- [ ] Clear error messages for common issues
- [ ] System remains stable during failures
- [ ] Recovery works after fixing issues

## 🎯 Success Criteria Summary

**Your MCP-files setup is working correctly if:**

1. **✅ All server health checks pass**
2. **✅ Memory storage and retrieval work with varied similarity scores**  
3. **✅ Semantic search finds conceptually related content**
4. **✅ System gracefully handles ChromaDB disconnection**
5. **✅ Performance meets baseline expectations**
6. **✅ Auto-extracted tags reflect conversation content**

## 📞 Getting Help

If tests fail, check:

1. **Server Logs:** Look for error messages in MCP server output
2. **ChromaDB Logs:** Check ChromaDB terminal for connection issues  
3. **Client Configuration:** Verify MCP client config matches examples
4. **GitHub Issues:** Report bugs with test results and logs
5. **Main README:** Review setup instructions for missed steps

**Successful test completion means your MCP-files server is ready for production use with full ChromaDB memory capabilities!** 🚀