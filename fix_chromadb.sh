#!/bin/bash

echo "🔧 Fixing ChromaDB Embedding Configuration"
echo "=========================================="

# The issue is that ChromaDB needs an embedding function defined
# Let's create a fixed version of the memory extension

echo "Creating fixed memory extension..."

cat > /Users/kevinbrown/MCP-files/src/memory-extension-fixed.ts << 'EOF'
import { ChromaClient, OpenAIEmbeddingFunction } from 'chromadb';
import { promises as fs } from 'fs';
import path from 'path';

export interface ConversationMemory {
  sessionId: string;
  timestamp: number;
  userMessage: string;
  assistantResponse: string;
  context: string[];
  tags: string[];
}

export interface MemorySearchResult {
  content: string;
  metadata: any;
  distance: number;
}

export class ChromaMemoryManager {
  private client: ChromaClient | null;
  private collection: any;
  private memoryDir: string;
  private initialized = false;
  private embeddingFunction: OpenAIEmbeddingFunction | null = null;

  constructor(memoryDir: string) {
    this.memoryDir = memoryDir;
    
    try {
      // Create embedding function (this is what was missing!)
      this.embeddingFunction = new OpenAIEmbeddingFunction({
        openai_api_key: process.env.OPENAI_API_KEY || "dummy_key_for_chroma_server",
        openai_model: "text-embedding-ada-002"
      });
      
      // Connect to ChromaDB HTTP server
      this.client = new ChromaClient({
        path: "http://127.0.0.1:8000"
      });
      
      console.log("✓ ChromaDB client initialized");
    } catch (error) {
      console.error('ChromaDB initialization failed, will use JSON-only mode:', error);
      this.client = null;
      this.embeddingFunction = null;
    }
  }

  async initialize(): Promise<void> {
    if (this.initialized) return;

    try {
      // Ensure memory directory exists
      await fs.mkdir(this.memoryDir, { recursive: true });

      // Only try ChromaDB if client was successfully created
      if (this.client && this.embeddingFunction) {
        try {
          // Try to get existing collection
          this.collection = await this.client.getCollection({
            name: "llm_conversation_memory",
            embeddingFunction: this.embeddingFunction
          });
          console.log("✓ Found existing ChromaDB collection");
        } catch (error) {
          // Create new collection with embedding function
          this.collection = await this.client.createCollection({
            name: "llm_conversation_memory",
            embeddingFunction: this.embeddingFunction,
            metadata: { "hnsw:space": "cosine" }
          });
          console.log("✓ Created new ChromaDB collection with embeddings");
        }
        console.log("✓ Chroma memory manager initialized with vector search");
      } else {
        console.log("✓ Memory manager initialized (JSON-only mode)");
      }

      this.initialized = true;
    } catch (error) {
      console.error("✗ ChromaDB failed, using JSON-only mode:", error);
      this.client = null;
      this.collection = null;
      this.embeddingFunction = null;
      this.initialized = true; // Still consider it initialized, just without ChromaDB
    }
  }

  async isAvailable(): Promise<boolean> {
    return this.initialized && this.client !== null && this.collection !== null;
  }

  // Rest of the methods remain the same...
  async storeConversation(memory: ConversationMemory): Promise<boolean> {
    if (!this.initialized) {
      await this.initialize();
    }
    
    // Always store to JSON as backup
    await this.storeConversationToJson(memory);
    
    if (!this.client || !this.collection) {
      return true; // JSON storage succeeded
    }

    try {
      const id = \`\${memory.sessionId}_\${memory.timestamp}\`;
      const document = \`User: \${memory.userMessage}\\nAssistant: \${memory.assistantResponse}\`;
      
      await this.collection.add({
        ids: [id],
        documents: [document],
        metadatas: [{
          sessionId: memory.sessionId,
          timestamp: memory.timestamp,
          userMessage: memory.userMessage,
          assistantResponse: memory.assistantResponse,
          context: memory.context.join(', '),
          tags: memory.tags.join(', ')
        }]
      });
      
      return true;
    } catch (error) {
      console.error('ChromaDB storage failed, but JSON backup succeeded:', error);
      return true; // JSON storage is still working
    }
  }

  async storeConversationToJson(memory: ConversationMemory): Promise<boolean> {
    try {
      const sessionFile = path.join(this.memoryDir, \`\${memory.sessionId}.json\`);
      
      let existingData: ConversationMemory[] = [];
      try {
        const content = await fs.readFile(sessionFile, 'utf8');
        existingData = JSON.parse(content);
      } catch (error) {
        // File doesn't exist or is invalid, start with empty array
      }
      
      existingData.push(memory);
      
      await fs.writeFile(sessionFile, JSON.stringify(existingData, null, 2));
      return true;
    } catch (error) {
      console.error('JSON storage failed:', error);
      return false;
    }
  }

  async searchRelevantMemories(query: string, sessionId?: string, limit: number = 5): Promise<MemorySearchResult[]> {
    // First try vector search
    if (this.collection && this.client) {
      try {
        const results = await this.collection.query({
          queryTexts: [query],
          nResults: limit,
          where: sessionId ? { sessionId } : undefined
        });

        return results.documents[0].map((doc: string, index: number) => ({
          content: doc,
          metadata: results.metadatas[0][index],
          distance: results.distances[0][index]
        }));
      } catch (error) {
        console.error('Chroma search failed, falling back to JSON search:', error);
      }
    }

    // Fallback to JSON search
    return this.searchJsonMemories(query, sessionId, limit);
  }

  async searchJsonMemories(query: string, sessionId?: string, limit: number = 5): Promise<MemorySearchResult[]> {
    try {
      const results: MemorySearchResult[] = [];
      const queryLower = query.toLowerCase();
      
      // Read all session files or specific session
      const files = sessionId 
        ? [\`\${sessionId}.json\`]
        : await fs.readdir(this.memoryDir);
      
      for (const file of files) {
        if (!file.endsWith('.json')) continue;
        
        try {
          const filePath = path.join(this.memoryDir, file);
          const content = await fs.readFile(filePath, 'utf8');
          const memories: ConversationMemory[] = JSON.parse(content);
          
          for (const memory of memories) {
            const searchText = \`\${memory.userMessage} \${memory.assistantResponse} \${memory.tags.join(' ')}\`.toLowerCase();
            
            if (searchText.includes(queryLower)) {
              results.push({
                content: \`User: \${memory.userMessage}\\nAssistant: \${memory.assistantResponse}\`,
                metadata: {
                  sessionId: memory.sessionId,
                  timestamp: memory.timestamp,
                  tags: memory.tags,
                  context: memory.context
                },
                distance: 0.5 // Dummy distance for JSON search
              });
            }
          }
        } catch (error) {
          // Skip invalid files
          continue;
        }
      }
      
      return results.slice(0, limit);
    } catch (error) {
      console.error('JSON search failed:', error);
      return [];
    }
  }

  async listSessions(): Promise<string[]> {
    try {
      const files = await fs.readdir(this.memoryDir);
      return files
        .filter(file => file.endsWith('.json'))
        .map(file => file.replace('.json', ''));
    } catch (error) {
      console.error('Failed to list sessions:', error);
      return [];
    }
  }

  async getSessionSummary(sessionId: string): Promise<any> {
    try {
      // Try to get from vector search first
      if (this.collection) {
        const results = await this.searchRelevantMemories("", sessionId, 10);
        if (results.length > 0) {
          return {
            sessionId,
            conversationCount: results.length,
            recentMemories: results.slice(0, 3)
          };
        }
      }
      
      // Fallback to JSON
      const sessionFile = path.join(this.memoryDir, \`\${sessionId}.json\`);
      const content = await fs.readFile(sessionFile, 'utf8');
      const memories: ConversationMemory[] = JSON.parse(content);
      
      return {
        sessionId,
        conversationCount: memories.length,
        tags: [...new Set(memories.flatMap(m => m.tags))],
        context: [...new Set(memories.flatMap(m => m.context))],
        timeRange: {
          earliest: Math.min(...memories.map(m => m.timestamp)),
          latest: Math.max(...memories.map(m => m.timestamp))
        }
      };
    } catch (error) {
      console.error(\`Failed to get session summary for \${sessionId}:\`, error);
      return null;
    }
  }
}

// Utility functions
export function extractTags(text: string): string[] {
  const commonTags = [
    'javascript', 'typescript', 'python', 'react', 'node', 'docker', 
    'kubernetes', 'aws', 'database', 'api', 'frontend', 'backend',
    'deployment', 'security', 'performance', 'testing', 'debugging',
    'configuration', 'integration', 'authentication', 'monitoring'
  ];
  
  const textLower = text.toLowerCase();
  return commonTags.filter(tag => textLower.includes(tag));
}

export function extractContext(text: string): string[] {
  const context: string[] = [];
  
  // Extract file references
  const fileRegex = /(?:file:|filename:|path:)\s*([^\s,]+)/gi;
  let match;
  while ((match = fileRegex.exec(text)) !== null) {
    context.push(\`file: \${match[1]}\`);
  }
  
  // Extract URLs
  const urlRegex = /https?:\\/\\/[^\s,]+/gi;
  while ((match = urlRegex.exec(text)) !== null) {
    context.push(\`url: \${match[0]}\`);
  }
  
  return [...new Set(context)];
}
EOF

echo "✅ Fixed memory extension created!"
echo ""
echo "Now let's update the TypeScript and rebuild:"
echo "1. Stop your current server (Ctrl+C)"
echo "2. Run these commands:"
echo ""
echo "   cd /Users/kevinbrown/MCP-files"
echo "   mv src/memory-extension.ts src/memory-extension-backup.ts"
echo "   mv src/memory-extension-fixed.ts src/memory-extension.ts"
echo "   npm run build"
echo "   npm run start:http /Users/kevinbrown/servers /Users/kevinbrown/code-server-student-image /Users/kevinbrown/devops-test/java-webapp /Users/kevinbrown/IaC /Users/kevinbrown/MCP-files"
echo ""
echo "The fix includes:"
echo "✅ Proper OpenAI embedding function configuration"
echo "✅ Better error handling and fallbacks"  
echo "✅ JSON-first storage with ChromaDB as enhancement"
echo "✅ More robust initialization"
