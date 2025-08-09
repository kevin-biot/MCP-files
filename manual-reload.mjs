#!/usr/bin/env node

// Manual reload script to load JSON memories into ChromaDB
// This simulates what the reload_memories_from_json tool should do

import { ChromaClient } from 'chromadb';
import { DefaultEmbeddingFunction } from '@chroma-core/default-embed';
import { promises as fs } from 'fs';
import path from 'path';

async function manualReload() {
  console.log('🔄 Manual reload of JSON memories to ChromaDB\n');
  
  const memoryDir = '/Users/kevinbrown/servers/.mcp-memory';
  
  // Initialize ChromaDB client
  let client, collection;
  
  try {
    client = new ChromaClient({
      host: "127.0.0.1",
      port: 8000
    });
    
    console.log('✓ ChromaDB client initialized');
    
    // Get or create collection
    try {
      collection = await client.getCollection({
        name: "llm_conversation_memory",
        embeddingFunction: new DefaultEmbeddingFunction()
      });
      console.log('✓ Connected to existing collection');
    } catch (error) {
      collection = await client.createCollection({
        name: "llm_conversation_memory", 
        embeddingFunction: new DefaultEmbeddingFunction(),
        metadata: { "hnsw:space": "cosine" }
      });
      console.log('✓ Created new collection');
    }
    
  } catch (error) {
    console.error('❌ ChromaDB initialization failed:', error);
    return;
  }
  
  // Load JSON files
  try {
    const sessionFiles = await fs.readdir(memoryDir);
    const jsonFiles = sessionFiles.filter(f => f.endsWith('.json'));
    
    let loaded = 0;
    let errors = 0;
    
    console.log(`📁 Found ${jsonFiles.length} JSON files to process\n`);
    
    for (const file of jsonFiles) {
      try {
        const filePath = path.join(memoryDir, file);
        const content = await fs.readFile(filePath, 'utf8');
        const memories = JSON.parse(content);
        
        console.log(`Processing ${file}: ${memories.length} memories`);
        
        for (const memory of memories) {
          const id = `${memory.sessionId}_${memory.timestamp}`;
          const document = `User: ${memory.userMessage}\nAssistant: ${memory.assistantResponse}`;
          
          await collection.add({
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
          
          loaded++;
        }
        
        console.log(`  ✓ Loaded ${memories.length} memories`);
        
      } catch (error) {
        console.error(`  ✗ Failed to load ${file}:`, error.message);
        errors++;
      }
    }
    
    console.log(`\n🎉 Bulk reload complete!`);
    console.log(`• Total memories loaded: ${loaded}`);
    console.log(`• Files processed: ${jsonFiles.length - errors}`);
    console.log(`• Errors: ${errors}`);
    
    // Test search after reload
    if (loaded > 0) {
      console.log('\n🔍 Testing search functionality...');
      
      const searchResults = await collection.query({
        queryTexts: ['React authentication JWT tokens'],
        nResults: 3
      });
      
      console.log(`Search returned ${searchResults.documents[0]?.length || 0} results`);
      
      if (searchResults.documents[0] && searchResults.documents[0].length > 0) {
        console.log('\n📋 Sample search result:');
        console.log(searchResults.documents[0][0].substring(0, 200) + '...');
        console.log('Distance:', searchResults.distances[0][0]);
        console.log('Relevance:', (1 - searchResults.distances[0][0]).toFixed(3));
      }
    }
    
  } catch (error) {
    console.error('❌ Bulk reload failed:', error);
  }
}

manualReload();
