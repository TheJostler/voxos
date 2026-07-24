#!/bin/bash
# Phase 5: File Operations Tests
# Tests save, exit, and error handling

set -e

EDITOR_BIN="./editor"
TEST_FILE="/tmp/editor-test-phase5.txt"
BACKUP_FILE="/tmp/editor-test-phase5-backup.txt"

echo "Phase 5: File Operations Tests"
echo "=============================="
echo ""

# Clean up function
cleanup() {
    if [ -f "$TEST_FILE" ]; then
        rm -f "$TEST_FILE"
    fi
    if [ -f "$BACKUP_FILE" ]; then
        rm -f "$BACKUP_FILE"
    fi
}

trap cleanup EXIT

# Test 1: Save operation (Ctrl+O)
echo "Test 1: Save operation (Ctrl+O)"
echo "--------------------------------"
echo "Original content" > "$TEST_FILE"
echo "Initial file content: $(cat $TEST_FILE)"
echo ""
echo "Running: $EDITOR_BIN $TEST_FILE"
echo "Expected behavior:"
echo "  1. Modify the file content"
echo "  2. Press Ctrl+O to save"
echo "  3. Modified flag should clear"
echo "  4. Exit with Ctrl+X"
echo ""
read -p "Test complete? Check file content: " -r
echo ""
if [ -f "$TEST_FILE" ]; then
    echo "File content after save: $(cat $TEST_FILE)"
    read -p "Did the save operation work correctly? (y/n) " -n 1 -r
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

# Test 2: Exit with unsaved changes prompt
echo "Test 2: Exit with unsaved changes prompt"
echo "----------------------------------------"
echo "Original content" > "$TEST_FILE"
echo ""
echo "Running: $EDITOR_BIN $TEST_FILE"
echo "Expected behavior:"
echo "  1. Modify the file content (do not save)"
echo "  2. Press Ctrl+X to exit"
echo "  3. Should prompt: 'Save changes? (y/n)'"
echo "  4. Answer 'n' to exit without saving"
echo "  5. File should remain unchanged"
echo ""
read -p "Test complete? Check if original file unchanged: " -r
echo ""
if [ -f "$TEST_FILE" ]; then
    echo "File content: $(cat $TEST_FILE)"
    read -p "Did the unsaved prompt work correctly? (y/n) " -n 1 -r
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

# Test 3: Exit without saving (Ctrl+Q)
echo "Test 3: Exit without saving (Ctrl+Q)"
echo "------------------------------------"
echo "Original content" > "$TEST_FILE"
cp "$TEST_FILE" "$BACKUP_FILE"
echo "Initial file content: $(cat $TEST_FILE)"
echo ""
echo "Running: $EDITOR_BIN $TEST_FILE"
echo "Expected behavior:"
echo "  1. Modify the file content"
echo "  2. Press Ctrl+Q to quit immediately"
echo "  3. Should NOT prompt for save"
echo "  4. File should remain unchanged"
echo ""
read -p "Test complete? " -r
echo ""
if [ -f "$TEST_FILE" ]; then
    echo "File content after Ctrl+Q: $(cat $TEST_FILE)"
    echo "Original content: $(cat $BACKUP_FILE)"
    if diff -q "$TEST_FILE" "$BACKUP_FILE" > /dev/null; then
        echo "✓ Test 3 PASSED - file unchanged"
    else
        read -p "File changed. Did Ctrl+Q work as expected (no prompt)? (y/n) " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            echo "✓ Test 3 PASSED"
        else
            echo "✗ Test 3 FAILED"
            exit 1
        fi
    fi
else
    echo "✗ Test 3 FAILED - file not found"
    exit 1
fi
echo ""

# Test 4: Create new file
echo "Test 4: Create new file"
echo "-----------------------"
if [ -f "$TEST_FILE" ]; then
    rm -f "$TEST_FILE"
fi
echo "File does not exist initially"
echo ""
echo "Running: $EDITOR_BIN $TEST_FILE"
echo "Expected behavior:"
echo "  1. Editor should open with empty buffer"
echo "  2. Type some content"
echo "  3. Save with Ctrl+O"
echo "  4. Exit with Ctrl+X"
echo "  5. File should be created with the content"
echo ""
read -p "Test complete? Check if file created: " -r
echo ""
if [ -f "$TEST_FILE" ]; then
    echo "File created with content: $(cat $TEST_FILE)"
    read -p "Did new file creation work correctly? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo "✓ Test 4 PASSED"
    else
        echo "✗ Test 4 FAILED"
        exit 1
    fi
else
    echo "✗ Test 4 FAILED - file not created"
    exit 1
fi
echo ""

# Test 5: Terminal mode restoration
echo "Test 5: Terminal mode restoration"
echo "----------------------------------"
echo "Original content" > "$TEST_FILE"
echo ""
echo "Running: $EDITOR_BIN $TEST_FILE"
echo "Expected behavior:"
echo "  1. Make some edits"
echo "  2. Exit with Ctrl+X (save or don't save)"
echo "  3. Terminal should return to normal (cooked) mode"
echo "  4. Typing in shell should echo characters"
echo "  5. Press Enter should execute commands (line buffering)"
echo ""
read -p "Is terminal in normal mode after exit? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "✓ Test 5 PASSED"
else
    echo "✗ Test 5 FAILED"
    exit 1
fi
echo ""

echo "Phase 5: All tests PASSED"
