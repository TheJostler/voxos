#!/bin/bash
# Test runner for Vox editor
# Runs each test and reports results

set -e

VOX_COMPILER="/home/josj/scr/english/vox/target/release/vox"
EDITOR_BIN="./editor"
TEST_DIR="./tests"
RESULTS_FILE="./test-results.txt"

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Initialize results
echo "Vox Editor Test Results" > "$RESULTS_FILE"
echo "========================" >> "$RESULTS_FILE"
echo "" >> "$RESULTS_FILE"

total_tests=0
passed_tests=0
failed_tests=0

run_test() {
    local test_name="$1"
    local test_script="$2"
    
    total_tests=$((total_tests + 1))
    
    echo -n "Running: $test_name ... "
    
    if bash "$test_script"; then
        echo -e "${GREEN}PASSED${NC}"
        echo "✓ $test_name: PASSED" >> "$RESULTS_FILE"
        passed_tests=$((passed_tests + 1))
    else
        echo -e "${RED}FAILED${NC}"
        echo "✗ $test_name: FAILED" >> "$RESULTS_FILE"
        failed_tests=$((failed_tests + 1))
    fi
}

# Check if vox compiler exists
if [ ! -f "$VOX_COMPILER" ]; then
    echo "Error: Vox compiler not found at $VOX_COMPILER"
    echo "Please build vox first: cd /home/josj/scr/english/vox && cargo build --release"
    exit 1
fi

# Check if editor.vox exists
if [ ! -f "editor.vox" ]; then
    echo "Error: editor.vox not found"
    exit 1
fi

# Compile editor
echo "Compiling editor.vox..."
"$VOX_COMPILER" editor.vox
if [ ! -f "editor" ]; then
    echo "Error: Compilation failed"
    exit 1
fi
echo "Compilation successful"
echo ""

# Run tests
echo "Running tests..."
echo ""

# Phase 1 tests
if [ -f "$TEST_DIR/phase1-terminal-control.sh" ]; then
    run_test "Phase 1: Terminal Control Foundation" "$TEST_DIR/phase1-terminal-control.sh"
fi

# Phase 2 tests
if [ -f "$TEST_DIR/phase2-display-engine.sh" ]; then
    run_test "Phase 2: Display Engine" "$TEST_DIR/phase2-display-engine.sh"
fi

# Phase 3 tests
if [ -f "$TEST_DIR/phase3-input-handling.sh" ]; then
    run_test "Phase 3: Input Handling" "$TEST_DIR/phase3-input-handling.sh"
fi

# Phase 4 tests
if [ -f "$TEST_DIR/phase4-editing-operations.sh" ]; then
    run_test "Phase 4: Editing Operations" "$TEST_DIR/phase4-editing-operations.sh"
fi

# Phase 5 tests
if [ -f "$TEST_DIR/phase5-file-operations.sh" ]; then
    run_test "Phase 5: File Operations" "$TEST_DIR/phase5-file-operations.sh"
fi

# Phase 6 tests
if [ -f "$TEST_DIR/phase6-polish.sh" ]; then
    run_test "Phase 6: Polish" "$TEST_DIR/phase6-polish.sh"
fi

# Print summary
echo ""
echo "========================"
echo "Test Summary"
echo "========================"
echo "Total tests: $total_tests"
echo -e "${GREEN}Passed: $passed_tests${NC}"
echo -e "${RED}Failed: $failed_tests${NC}"
echo ""

if [ $failed_tests -eq 0 ]; then
    echo -e "${GREEN}All tests passed!${NC}"
    exit 0
else
    echo -e "${RED}Some tests failed. See $RESULTS_FILE for details.${NC}"
    exit 1
fi
