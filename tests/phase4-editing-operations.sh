#!/bin/bash
# Phase 4: Editing Operations Tests
# Tests character insertion, deletion, and buffer modifications

set -e

EDITOR_BIN="./editor"
TEST_FILE="/tmp/editor-test-phase4.txt"

echo "Phase 4: Editing Operations Tests"
echo "=================================="
echo ""

# Clean up function
cleanup() {
    if [ -f "$TEST_FILE" ]; then
        rm -f "$TEST_FILE"
    fi
}

trap cleanup EXIT

# Test 1: Character insertion at cursor
echo "Test 1: Character insertion at cursor"
echo "-------------------------------------"
echo "Initial text" > "$TEST_FILE"
echo "Initial file content: $(cat $TEST_FILE)"
echo ""
echo "Running: $EDITOR_BIN $TEST_FILE"
echo "Expected behavior:"
echo "  1. Move cursor to middle of line"
echo "  2. Type characters"
echo "  3. Characters should insert at cursor position"
echo "  4. Existing text should shift right"
echo "  5. Save with Ctrl+O and exit with Ctrl+X"
echo ""
read -p "Test complete? Check file content: " -r
echo ""
if [ -f "$TEST_FILE" ]; then
    echo "File content after edit: $(cat $TEST_FILE)"
    read -p "Did character insertion work correctly? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo "✓ Test 1 PASSED"
    else
        echo "✗ Test 1 FAILED"
        exit 1
    fi
else
    echo "✗ Test 1 FAILED - file not found"
    exit 1
fi
echo ""

# Test 2: Backspace deletion
echo "Test 2: Backspace deletion"
echo "---------------------------"
echo "Test line with text" > "$TEST_FILE"
echo "Initial file content: $(cat $TEST_FILE)"
echo ""
echo "Running: $EDITOR_BIN $TEST_FILE"
echo "Expected behavior:"
echo "  1. Move cursor to end of line"
echo "  2. Press Backspace multiple times"
echo "  3. Characters before cursor should be deleted"
echo "  4. Cursor should move left after each deletion"
echo "  5. Save and exit"
echo ""
read -p "Test complete? Check file content: " -r
echo ""
if [ -f "$TEST_FILE" ]; then
    echo "File content after edit: $(cat $TEST_FILE)"
    read -p "Did backspace deletion work correctly? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo "✓ Test 2 PASSED"
    else
        echo "✗ Test 2 FAILED"
        exit 1
    fi
else
    echo "✗ Test 2 FAILED - file not found"
    exit 1
fi
echo ""

# Test 3: Delete key
echo "Test 3: Delete key"
echo "------------------"
echo "Test line" > "$TEST_FILE"
echo "Initial file content: $(cat $TEST_FILE)"
echo ""
echo "Running: $EDITOR_BIN $TEST_FILE"
echo "Expected behavior:"
echo "  1. Move cursor to start of line"
echo "  2. Press Delete key multiple times"
echo "  3. Characters at cursor should be deleted"
echo "  4. Cursor should stay in place"
echo "  5. Save and exit"
echo ""
read -p "Test complete? Check file content: " -r
echo ""
if [ -f "$TEST_FILE" ]; then
    echo "File content after edit: $(cat $TEST_FILE)"
    read -p "Did delete key work correctly? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo "✓ Test 3 PASSED"
    else
        echo "✗ Test 3 FAILED"
        exit 1
    fi
else
    echo "✗ Test 3 FAILED - file not found"
    exit 1
fi
echo ""

# Test 4: Newline insertion
echo "Test 4: Newline insertion"
echo "-------------------------"
echo "Single line" > "$TEST_FILE"
echo "Initial file content: $(cat $TEST_FILE)"
echo ""
echo "Running: $EDITOR_BIN $TEST_FILE"
echo "Expected behavior:"
echo "  1. Move cursor to middle of line"
echo "  2. Press Enter"
echo "  3. Line should split at cursor position"
echo "  4. Cursor should move to start of new line"
echo "  5. Save and exit"
echo ""
read -p "Test complete? Check file content: " -r
echo ""
if [ -f "$TEST_FILE" ]; then
    echo "File content after edit:"
    cat "$TEST_FILE"
    echo ""
    read -p "Did newline insertion work correctly? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo "✓ Test 4 PASSED"
    else
        echo "✗ Test 4 FAILED"
        exit 1
    fi
else
    echo "✗ Test 4 FAILED - file not found"
    exit 1
fi
echo ""

# Test 5: Modified flag
echo "Test 5: Modified flag"
echo "---------------------"
echo "Original content" > "$TEST_FILE"
echo ""
echo "Running: $EDITOR_BIN $TEST_FILE"
echo "Expected behavior:"
echo "  1. Status line should show 'Modified: N' initially"
echo "  2. Type a character"
echo "  3. Status line should change to 'Modified: Y'"
echo "  4. Save with Ctrl+O"
echo "  5. Status line should change back to 'Modified: N'"
echo ""
read -p "Does the modified flag work correctly? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "✓ Test 5 PASSED"
else
    echo "✗ Test 5 FAILED"
    exit 1
fi
echo ""

echo "Phase 4: All tests PASSED"
