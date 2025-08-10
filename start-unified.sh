#!/bin/bash

# Unified startup script for ChromaDB + MCP File Server
# Usage: ./start-unified.sh [port]

set -e

# Configuration
CHROMA_HOST="127.0.0.1"
CHROMA_PORT="8000"
MCP_PORT="${1:-8080}"  # Use first argument or default to 8080

# Directory paths - all your working directories
DIRECTORIES=(
    "/Users/kevinbrown/servers"
    "/Users/kevinbrown/code-server-student-image"
    "/Users/kevinbrown/devops-test/java-webapp"
    "/Users/kevinbrown/IaC"
    "/Users/kevinbrown/MCP-files"
    "/Users/kevinbrown/MCP-ocs"
    "/Users/kevinbrown/MCP-router"
)

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# PID file for tracking processes
PID_FILE="/tmp/unified-mcp.pids"

# Cleanup function
cleanup() {
    echo -e "\n${YELLOW}🛑 Shutting down services...${NC}"
    
    if [ -f "$PID_FILE" ]; then
        while read -r pid name; do
            if [ -n "$pid" ] && kill -0 "$pid" 2>/dev/null; then
                echo -e "${YELLOW}   Stopping $name (PID: $pid)${NC}"
                kill "$pid" 2>/dev/null || true
                # Wait a bit for graceful shutdown
                sleep 2
                # Force kill if still running
                if kill -0 "$pid" 2>/dev/null; then
                    echo -e "${RED}   Force killing $name${NC}"
                    kill -9 "$pid" 2>/dev/null || true
                fi
            fi
        done < "$PID_FILE"
        rm -f "$PID_FILE"
    fi
    
    echo -e "${GREEN}✅ All services stopped${NC}"
    exit 0
}

# Set trap to cleanup on script exit
trap cleanup EXIT INT TERM

# Function to check if a port is in use
check_port() {
    local port=$1
    if lsof -i :$port >/dev/null 2>&1; then
        return 0  # Port is in use
    else
        return 1  # Port is free
    fi
}

# Function to wait for service to be ready
wait_for_service() {
    local host=$1
    local port=$2
    local service_name=$3
    local max_attempts=30
    local attempt=1
    
    echo -e "${BLUE}⏳ Waiting for $service_name to be ready...${NC}"
    
    while [ $attempt -le $max_attempts ]; do
        if nc -z "$host" "$port" 2>/dev/null; then
            echo -e "${GREEN}✅ $service_name is ready!${NC}"
            return 0
        fi
        
        echo -e "${YELLOW}   Attempt $attempt/$max_attempts - waiting for $service_name...${NC}"
        sleep 2
        attempt=$((attempt + 1))
    done
    
    echo -e "${RED}❌ $service_name failed to start within expected time${NC}"
    return 1
}

# Function to validate directories
validate_directories() {
    echo -e "${BLUE}📁 Validating directories...${NC}"
    local invalid_dirs=()
    
    for dir in "${DIRECTORIES[@]}"; do
        if [ ! -d "$dir" ]; then
            invalid_dirs+=("$dir")
            echo -e "${YELLOW}⚠️  Directory does not exist: $dir${NC}"
        else
            echo -e "${GREEN}✅ $dir${NC}"
        fi
    done
    
    if [ ${#invalid_dirs[@]} -gt 0 ]; then
        echo -e "\n${YELLOW}⚠️  Some directories don't exist yet. The MCP server will still start with existing directories.${NC}"
        echo -e "${YELLOW}   You can create these directories later:${NC}"
        for dir in "${invalid_dirs[@]}"; do
            echo -e "${YELLOW}     mkdir -p '$dir'${NC}"
        done
        echo ""
    fi
}

# Function to start ChromaDB
start_chromadb() {
    echo -e "\n${BLUE}🗄️  Starting ChromaDB...${NC}"
    
    # Check if ChromaDB is already running
    if check_port $CHROMA_PORT; then
        echo -e "${YELLOW}⚠️  ChromaDB appears to be already running on port $CHROMA_PORT${NC}"
        echo -e "${YELLOW}   Trying to connect...${NC}"
        if wait_for_service "$CHROMA_HOST" "$CHROMA_PORT" "ChromaDB" 5; then
            echo -e "${GREEN}✅ Using existing ChromaDB instance${NC}"
            return 0
        else
            echo -e "${RED}❌ Port $CHROMA_PORT is occupied but not responding to ChromaDB requests${NC}"
            echo -e "${RED}   Please stop the service using port $CHROMA_PORT or use a different port${NC}"
            return 1
        fi
    fi
    
    # Check if chroma command exists
    if ! command -v chroma &> /dev/null; then
        echo -e "${RED}❌ ChromaDB (chroma) command not found${NC}"
        echo -e "${RED}   Please install ChromaDB: pip install chromadb${NC}"
        return 1
    fi
    
    # Start ChromaDB in background
    echo -e "${BLUE}   Command: chroma run --host $CHROMA_HOST --port $CHROMA_PORT${NC}"
    chroma run --host "$CHROMA_HOST" --port "$CHROMA_PORT" > /tmp/chromadb.log 2>&1 &
    local chroma_pid=$!
    
    # Store PID
    echo "$chroma_pid ChromaDB" >> "$PID_FILE"
    
    # Wait for ChromaDB to be ready
    if wait_for_service "$CHROMA_HOST" "$CHROMA_PORT" "ChromaDB"; then
        echo -e "${GREEN}✅ ChromaDB started successfully (PID: $chroma_pid)${NC}"
        echo -e "${BLUE}   Log file: /tmp/chromadb.log${NC}"
        return 0
    else
        echo -e "${RED}❌ ChromaDB failed to start${NC}"
        echo -e "${RED}   Check log: tail -f /tmp/chromadb.log${NC}"
        return 1
    fi
}

# Function to start MCP Server
start_mcp_server() {
    echo -e "\n${BLUE}🚀 Starting MCP File Server...${NC}"
    
    # Check if MCP port is available
    if check_port $MCP_PORT; then
        echo -e "${RED}❌ Port $MCP_PORT is already in use${NC}"
        echo -e "${RED}   Please choose a different port or stop the service using port $MCP_PORT${NC}"
        return 1
    fi
    
    # Filter existing directories
    local existing_dirs=()
    for dir in "${DIRECTORIES[@]}"; do
        if [ -d "$dir" ]; then
            existing_dirs+=("$dir")
        fi
    done
    
    if [ ${#existing_dirs[@]} -eq 0 ]; then
        echo -e "${RED}❌ No valid directories found${NC}"
        return 1
    fi
    
    # Build the command
    local mcp_command="npm run start:http"
    for dir in "${existing_dirs[@]}"; do
        mcp_command="$mcp_command '$dir'"
    done
    
    echo -e "${BLUE}   Port: $MCP_PORT${NC}"
    echo -e "${BLUE}   Directories: ${#existing_dirs[@]} directories${NC}"
    for dir in "${existing_dirs[@]}"; do
        echo -e "${BLUE}     📁 $dir${NC}"
    done
    
    # Start MCP server in background
    env PORT="$MCP_PORT" bash -c "$mcp_command" > /tmp/mcp-server.log 2>&1 &
    local mcp_pid=$!
    
    # Store PID
    echo "$mcp_pid MCP-Server" >> "$PID_FILE"
    
    # Wait for MCP server to be ready
    if wait_for_service "localhost" "$MCP_PORT" "MCP Server"; then
        echo -e "${GREEN}✅ MCP Server started successfully (PID: $mcp_pid)${NC}"
        echo -e "${BLUE}   Log file: /tmp/mcp-server.log${NC}"
        echo -e "${GREEN}🌐 MCP Server available at: http://localhost:$MCP_PORT/mcp${NC}"
        return 0
    else
        echo -e "${RED}❌ MCP Server failed to start${NC}"
        echo -e "${RED}   Check log: tail -f /tmp/mcp-server.log${NC}"
        return 1
    fi
}

# Main execution
main() {
    echo -e "${GREEN}🌟 Unified MCP + ChromaDB Startup Script${NC}"
    echo -e "${GREEN}======================================${NC}"
    
    # Create PID file
    > "$PID_FILE"
    
    # Validate directories
    validate_directories
    
    # Start ChromaDB
    if ! start_chromadb; then
        echo -e "${RED}❌ Failed to start ChromaDB${NC}"
        exit 1
    fi
    
    # Start MCP Server
    if ! start_mcp_server; then
        echo -e "${RED}❌ Failed to start MCP Server${NC}"
        exit 1
    fi
    
    # Success message
    echo -e "\n${GREEN}🎉 All services started successfully!${NC}"
    echo -e "${GREEN}=================================${NC}"
    echo -e "${GREEN}📊 ChromaDB:   http://$CHROMA_HOST:$CHROMA_PORT${NC}"
    echo -e "${GREEN}🔧 MCP Server: http://localhost:$MCP_PORT/mcp${NC}"
    echo -e "\n${BLUE}📋 Service Status:${NC}"
    echo -e "${BLUE}   ChromaDB PID: $(grep ChromaDB $PID_FILE | cut -d' ' -f1)${NC}"
    echo -e "${BLUE}   MCP Server PID: $(grep MCP-Server $PID_FILE | cut -d' ' -f1)${NC}"
    echo -e "\n${BLUE}📝 Log Files:${NC}"
    echo -e "${BLUE}   ChromaDB: tail -f /tmp/chromadb.log${NC}"
    echo -e "${BLUE}   MCP Server: tail -f /tmp/mcp-server.log${NC}"
    echo -e "\n${YELLOW}🛑 Press Ctrl+C to stop all services${NC}"
    
    # Keep script running and wait for termination
    while true; do
        sleep 10
        
        # Check if services are still running
        local services_running=0
        while read -r pid name; do
            if [ -n "$pid" ] && kill -0 "$pid" 2>/dev/null; then
                services_running=$((services_running + 1))
            else
                echo -e "${RED}⚠️  $name (PID: $pid) has stopped unexpectedly${NC}"
            fi
        done < "$PID_FILE"
        
        if [ $services_running -eq 0 ]; then
            echo -e "${RED}❌ All services have stopped${NC}"
            exit 1
        fi
    done
}

# Check for help flag
if [[ "$1" == "-h" || "$1" == "--help" ]]; then
    echo "Unified MCP + ChromaDB Startup Script"
    echo ""
    echo "Usage: $0 [port]"
    echo ""
    echo "Arguments:"
    echo "  port    MCP server port (default: 8080)"
    echo ""
    echo "Environment:"
    echo "  PORT    Alternative way to set MCP server port"
    echo ""
    echo "Examples:"
    echo "  $0          # Start with default port 8080"
    echo "  $0 9000     # Start with MCP server on port 9000"
    echo "  PORT=9000 $0  # Same as above using environment variable"
    echo ""
    echo "Services started:"
    echo "  - ChromaDB on $CHROMA_HOST:$CHROMA_PORT"
    echo "  - MCP File Server on localhost:[port]/mcp"
    echo ""
    echo "Directories included:"
    for dir in "${DIRECTORIES[@]}"; do
        echo "  - $dir"
    done
    exit 0
fi

# Check if nc (netcat) is available for port checking
if ! command -v nc &> /dev/null; then
    echo -e "${YELLOW}⚠️  netcat (nc) not found. Port checking may not work properly${NC}"
    echo -e "${YELLOW}   Install with: brew install netcat (macOS) or apt-get install netcat (Linux)${NC}"
fi

# Run main function
main "$@"
