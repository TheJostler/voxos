#!/bin/bash
# Phase 1: Terminal Control Foundation Tests
# Tests alternate screen buffer switching and raw mode

set -e

EDITOR_BIN="./editor"
TEST_FILE="/tmp/editor-test-phase1.txt"

echo "Phase 1: Terminal Control Foundation Tests"
echo "=========================================="
echo ""

# Clean up function
cleanup() {
    if [ -f "$TEST_FILE" ]; then
        rm -f "$TEST_FILE"
    fi
}

trap cleanup EXIT

# Test 1: Alternate screen buffer switch
echo "Test 1: Alternate screen buffer switch"
echo "--------------------------------------"
echo "This test requires manual verification."
echo ""
echo "Running: $EDITOR_BIN $TEST_FILE"
echo "Expected behavior:"
echo "  1. Terminal should switch to alternate buffer (screen clears)"
echo "  2. Editor should display content"
echo "  3. Press Ctrl+Q to exit"
echo "  4. Terminal should return to original state (shell restored)"
echo ""
read -p "Did the terminal switch buffers and restore correctly? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "✓ Test 1 PASSED"
else
    echo "✗ Test 1 FAILED"
    exit 1
fi
echo ""

# Test 2: ANSI escape sequences
echo "Test 2: ANSI escape sequences"
echo "------------------------------"
echo "This test requires manual verification."
echo ""
echo "Running: $EDITOR_BIN $TEST_FILE"
echo "Expected behavior:"
echo "  1. Cursor should move correctly (arrow keys)"
echo "  2. Screen should clear properly"
echo "  3. Status line should appear at bottom"
echo "  4. Text should appear at correct positions"
echo ""
read -p "Do ANSI escape sequences work correctly? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "✓ Test 2 PASSED"
else
    echo "✗ Test 2 FAILED"
    exit 1
fi
echo ""

# Test 3: Raw mode input
echo "Test 3: Raw mode input (single-character reading)"
echo "------------------------------------------------"
echo "This test requires manual verification."
echo ""
echo "Running: $EDITOR_BIN $TEST_FILE"
echo "Expected behavior:"
echo "  1. Characters should appear immediately when typed (no line buffering)"
echo "  2. Arrow keys should work (not print escape codes)"
echo "  3. Ctrl+key combinations should be detected"
echo ""
read -p "Does raw mode input work correctly? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "✓ Test 3 PASSED"
else
    echo "✗ Test 3 FAILED"
    exit 1
fi
echo ""

echo "Phase 1: All tests PASSED"
