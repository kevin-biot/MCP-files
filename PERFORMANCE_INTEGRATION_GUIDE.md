# Enhanced Performance Benchmarking Integration Guide

## 🚀 Quick Integration Steps

### 1. Add Performance Tools to Your Server

Add these tools to your tools array in `src/index.ts`:

```typescript
import { benchmark } from './performance-benchmark.js';

// Add to your existing tools array:
const performanceTools = [
  {
    name: "get_performance_report",
    description: "Generate detailed performance benchmarking report for tool usage analysis and LLM comparison",
    inputSchema: {
      type: "object",
      properties: {
        includeComparison: { 
          type: "boolean", 
          description: "Include LLM performance comparison if multiple models tested",
          default: true 
        }
      }
    }
  },
  {
    name: "set_llm_model",
    description: "Set the current LLM model name for performance tracking and comparison",
    inputSchema: {
      type: "object",
      properties: {
        modelName: { 
          type: "string", 
          description: "Name of the LLM model (e.g., 'claude-sonnet-4', 'gpt-4', 'llama-3.1-405b')" 
        }
      },
      required: ["modelName"]
    }
  },
  {
    name: "reset_performance_session",
    description: "Reset current performance tracking session (useful when switching LLMs)",
    inputSchema: {
      type: "object",
      properties: {}
    }
  }
];

// Merge with existing tools:
const allTools = [...tools, ...memoryTools, ...performanceTools];
```

### 2. Add Performance Tool Handlers

Add these cases to your tool handler switch statement:

```typescript
import { BenchmarkWrapper } from './performance-benchmark.js';

// In your tool handler:
case "get_performance_report":
  return {
    content: [{
      type: "text",
      text: BenchmarkWrapper.getReport(args.includeComparison ?? true)
    }]
  };

case "set_llm_model":
  BenchmarkWrapper.setModel(args.modelName);
  return {
    content: [{
      type: "text",
      text: `✅ LLM model set to: ${args.modelName}\nPerformance tracking enabled for comparison analysis.`
    }]
  };

case "reset_performance_session":
  BenchmarkWrapper.reset();
  return {
    content: [{
      type: "text",
      text: `🔄 Performance session reset. New session started for clean metrics.`
    }]
  };
```

### 3. Wrap Your Existing Tools

Replace your existing tool calls with benchmarked versions:

**Before:**
```typescript
case "read_file":
  const resolvedPath = await validatePath(args.path);
  // ... existing implementation
  return result;
```

**After:**
```typescript
case "read_file":
  return await BenchmarkWrapper.wrapTool("read_file", args, async () => {
    const resolvedPath = await validatePath(args.path);
    // ... existing implementation
    return result;
  });
```

### 4. Example Integration for Common Tools

```typescript
// File operations
case "read_file":
  return await BenchmarkWrapper.wrapTool("read_file", args, async () => {
    const resolvedPath = await validatePath(args.path);
    // Your existing read_file logic
  });

case "write_file":
  return await BenchmarkWrapper.wrapTool("write_file", args, async () => {
    const resolvedPath = await validatePath(args.path);
    // Your existing write_file logic
  });

// Memory operations
case "search_conversation_memory":
  return await BenchmarkWrapper.wrapTool("search_conversation_memory", args, async () => {
    // Your existing memory search logic
  });

case "store_conversation_memory":
  return await BenchmarkWrapper.wrapTool("store_conversation_memory", args, async () => {
    // Your existing memory storage logic
  });
```

## 📊 Usage Examples

### Basic LLM Performance Tracking

1. **Set your LLM model:**
   ```
   set_llm_model { "modelName": "claude-sonnet-4" }
   ```

2. **Use tools normally** - they'll be automatically benchmarked

3. **Get performance report:**
   ```
   get_performance_report { "includeComparison": true }
   ```

### Comparing Different LLMs

1. **Test with Claude:**
   ```
   set_llm_model { "modelName": "claude-sonnet-4" }
   # Use various tools...
   get_performance_report { "includeComparison": false }
   ```

2. **Switch to GPT-4:**
   ```
   reset_performance_session {}
   set_llm_model { "modelName": "gpt-4" }
   # Use same tools...
   get_performance_report { "includeComparison": true }
   ```

## 🔧 Build and Deploy

1. **Build your updated server:**
   ```bash
   cd /Users/kevinbrown/MCP-files
   npm run build
   ```

2. **Restart your MCP server**

3. **Test the new tools:**
   - `set_llm_model`
   - `get_performance_report`
   - `reset_performance_session`

## 📈 What You'll Get

### Enhanced Console Output:
```
🚀 [14:42:01] read_file started (input: 45 chars, session: abc123)
✅ [14:42:01] read_file completed in 23.4ms 🚀 (1247 chars output)
```

### Detailed Performance Reports:
```
📊 LLM Performance Benchmark Report
═══════════════════════════════════

🤖 LLM Model: claude-sonnet-4
🔧 Session: abc12345
📅 Duration: 5.2 minutes

📈 Overall Performance:
• Total Tool Calls: 15
• Average Response Time: 156.7ms
• Success Rate: 100.0%
• Tool Efficiency Score: 84.2/100

🛠️ Tool Performance Breakdown:
• search_conversation_memory: ⚡
  - Calls: 5 | Avg: 234.1ms (180-320ms)
  - Success: 100% | Total: 1.2s

• read_file: 🚀
  - Calls: 8 | Avg: 67.3ms (45-120ms)
  - Success: 100% | Total: 0.5s

🧠 LLM Performance Insights:
• Fastest Tool: read_file (67.3ms avg)
• Slowest Tool: search_conversation_memory (234.1ms avg)
• 🚀 Excellent response times - this LLM is well-optimized for tool use
```

This will give you **much more useful performance data** than the basic "Tool called" timestamps you had before!
