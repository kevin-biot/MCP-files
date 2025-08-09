    
    const lastTool = this.metrics[this.metrics.length - 1];
    const efficiency = this.calculateEfficiencyScore(current);
    
    return `📊 Session ${current.sessionId.slice(-6)} | ${current.llmModel} | ${current.totalCalls} calls | ${current.averageDuration.toFixed(1)}ms avg | ${efficiency.toFixed(1)} efficiency | Last: ${lastTool?.toolName}`;
  }
}

// Global instance
export const benchmark = new PerformanceBenchmark();

// Usage examples and integration helpers
export class BenchmarkWrapper {
  static async wrapTool<T>(toolName: string, args: any, toolFunction: () => Promise<T>): Promise<T> {
    const callId = benchmark.startTool(toolName, args);
    
    try {
      const result = await toolFunction();
      benchmark.endTool(callId, result);
      return result;
    } catch (error) {
      benchmark.endTool(callId, null, error as Error);
      throw error;
    }
  }
  
  static setModel(model: string) {
    benchmark.setLLMModel(model);
  }
  
  static getReport(includeComparison: boolean = true): string {
    return benchmark.generateReport(includeComparison);
  }
  
  static getSummary(): string {
    return benchmark.getRealTimeSummary();
  }
  
  static reset() {
    benchmark.resetSession();
  }
}

/*
Usage Examples:

1. Basic Integration:
   const result = await BenchmarkWrapper.wrapTool('read_file', args, async () => {
     return await readFileImplementation(args);
   });

2. Set LLM Model:
   BenchmarkWrapper.setModel('claude-sonnet-4');

3. Get Performance Report:
   console.log(BenchmarkWrapper.getReport(true));

4. Real-time Summary:
   console.log(BenchmarkWrapper.getSummary());

5. Compare LLMs:
   // Test with Claude
   BenchmarkWrapper.setModel('claude-sonnet-4');
   // ... run tests ...
   const claudeReport = BenchmarkWrapper.getReport();
   
   // Reset and test with GPT-4
   BenchmarkWrapper.reset();
   BenchmarkWrapper.setModel('gpt-4');
   // ... run same tests ...
   const gptReport = BenchmarkWrapper.getReport(true); // Includes comparison
*/
