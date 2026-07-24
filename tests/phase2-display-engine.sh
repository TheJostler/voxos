#!/bin/bash
# Phase 2: Display Engine Tests
# Tests file loading, rendering, and status line

set -e

EDITOR_BIN="./editor"
TEST_FILE="/tmp/editor-test-phase2.txt"
TEST_CONTENT="Hello World
Line 2
Line 3
This is a longer line to test wrapping behavior"

echo "Phase 2: Display Engine Tests"
echo "=============================="
echo ""

# Clean up function
cleanup() {
    if [ -f "$TEST_FILE" ]; then
        rm -f "$TEST_FILE"
    fi
}

trap cleanup EXIT

# Test 1: File loading and display
echo "Test 1: File loading and display"
echo "--------------------------------"
echo "$TEST_CONTENT" > "$TEST_FILE"
echo "Created test file with content:"
echo "$TEST_CONTENT"
echo ""
echo "Running: $EDITOR_BIN $TEST_FILE"
echo "Expected behavior:"
echo "  1. File contents should display correctly"
echo "  2. Line breaks should be preserved"
echo "  3. Status line should appear at bottom"
echo ""
read -p "Does the file display correctly with proper line breaks? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "✓ Test 1 PASSED"
else
    echo "✗ Test 1 FAILED"
    exit 1
fi
echo ""

# Test 2: Empty file handling
echo "Test 2: Empty file handling"
echo "----------------------------"
> "$TEST_FILE"
echo "Created empty test file"
echo ""
echo "Running: $EDITOR_BIN $TEST_FILE"
echo "Expected behavior:"
echo "  1. Editor should open with empty buffer"
echo "  2. Status line should show 0 lines"
echo "  3. Should not crash or display errors"
echo ""
read -p "Does empty file handling work correctly? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "✓ Test 2 PASSED"
else
    echo "✗ Test 2 FAILED"
    exit 1
fi
echo ""

# Test 3: Status line display
echo "Test 3: Status line display"
echo "---------------------------"
echo "Line 1" > "$TEST_FILE"
echo ""
echo "Running: $EDITOR_BIN $TEST_FILE"
echo "Expected behavior:"
echo "  1. Status line should appear at bottom of screen"
echo "  2. Status line should show: Position, Line count, Modified status"
echo "  3. Status line should be in reverse video (different color)"
echo ""
read -p "Does the status line display correctly? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "✓ Test 3 PASSED"
else
    echo "✗ Test 3 FAILED"
    exit 1
fi
echo ""

echo "Phase 2: All tests PASSED"
