#!/usr/bin/env node

// Test script to trigger memory reload from JSON to ChromaDB
import { ChromaMemoryManager } from './dist/memory-extension.js';
import path from 'path';

async function testReload() {
  console.log('🔄 Testing memory reload functionality...');
  
  // Initialize memory manager (same as your server does)
  const memoryDir = '/Users/kevinbrown/servers/.mcp-memory';
  const memoryManager = new ChromaMemoryManager(memoryDir);
  
  try {
    // Initialize the connection
    await memoryManager.initialize();
    console.log('✓ Memory manager initialized');
    
    // Check if ChromaDB is available
    const isAvailable = await memoryManager.isAvailable();
    console.log('✓ ChromaDB available:', isAvailable);
    
    if (!isAvailable) {
      console.error('❌ ChromaDB not available - cannot proceed with reload');
      return;
    }
    
    // Trigger the reload
    console.log('🚀 Starting bulk reload of JSON memories to ChromaDB...');
    const result = await memoryManager.reloadAllMemoriesFromJson();
    
    console.log('📊 Reload Results:');
    console.log(`• Memories loaded: ${result.loaded}`);
    console.log(`• Errors encountered: ${result.errors}`);
    
    if (result.loaded > 0) {
      console.log('✅ Reload successful! Testing search...');
      
      // Test search after reload
      const searchResults = await memoryManager.searchRelevantMemories('React authentication JWT', undefined, 3);
      console.log(`🔍 Search test returned ${searchResults.length} results`);
      
      if (searchResults.length > 0) {
        console.log('📋 Sample result:');
        console.log(searchResults[0].content.substring(0, 200) + '...');
        console.log('Relevance score:', 1 - searchResults[0].distance);
      }
    }
    
  } catch (error) {
    console.error('❌ Reload test failed:', error);
  }
}

testReload().then(() => {
  console.log('🏁 Test completed');
  process.exit(0);
}).catch(error => {
  console.error('💥 Test failed:', error);
  process.exit(1);
});
