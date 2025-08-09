// Quick test to count JSON memories and see what should be in ChromaDB
import fs from 'fs';
import path from 'path';

const memoryDir = '/Users/kevinbrown/servers/.mcp-memory';

async function analyzeMemories() {
  console.log('📊 Analyzing JSON memories that should be in ChromaDB...\n');
  
  const files = await fs.promises.readdir(memoryDir);
  const jsonFiles = files.filter(f => f.endsWith('.json'));
  
  let totalMemories = 0;
  let totalCharacters = 0;
  
  for (const file of jsonFiles.slice(0, 10)) { // Check first 10 files
    try {
      const content = await fs.promises.readFile(path.join(memoryDir, file), 'utf8');
      const memories = JSON.parse(content);
      
      console.log(`📁 ${file}: ${memories.length} memories`);
      totalMemories += memories.length;
      
      // Show sample content from first memory in each file
      if (memories.length > 0) {
        const sample = memories[0];
        const contentLength = sample.userMessage.length + sample.assistantResponse.length;
        totalCharacters += contentLength;
        console.log(`   Sample: "${sample.userMessage.substring(0, 50)}..."`);
        console.log(`   Tags: [${sample.tags.slice(0, 3).join(', ')}]`);
        console.log('');
      }
    } catch (error) {
      console.log(`❌ Error reading ${file}:`, error.message);
    }
  }
  
  console.log(`\n📈 Summary (first 10 files):`);
  console.log(`• Total memories: ${totalMemories}`);
  console.log(`• Average content per memory: ${Math.round(totalCharacters / totalMemories)} characters`);
  console.log(`• Estimated total across all ${jsonFiles.length} files: ~${Math.round(totalMemories * jsonFiles.length / 10)} memories`);
}

analyzeMemories().catch(console.error);
