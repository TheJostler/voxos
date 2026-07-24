#!/bin/bash
# Phase 3: Input Handling Tests
# Tests keyboard input decoding and key mapping

set -e

EDITOR_BIN="./editor"
TEST_FILE="/tmp/editor-test-phase3.txt"

echo "Phase 3: Input Handling Tests"
echo "=============================="
echo ""

# Clean up function
cleanup() {
    if [ -f "$TEST_FILE" ]; then
        rm -f "$TEST_FILE"
    fi
}

trap cleanup EXIT

# Test 1: Arrow key decoding
echo "Test 1: Arrow key decoding"
echo "--------------------------"
echo "Test content" > "$TEST_FILE"
echo ""
echo "Running: $EDITOR_BIN $TEST_FILE"
echo "Expected behavior:"
echo "  1. Press arrow keys (up, down, left, right)"
echo "  2. Cursor should move in the expected direction"
echo "  3. No escape codes should be printed on screen"
echo "  4. Cursor should stay within file bounds"
echo ""
read -p "Do arrow keys work correctly? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "✓ Test 1 PASSED"
else
    echo "✗ Test 1 FAILED"
    exit 1
fi
echo ""

# Test 2: Ctrl+key detection
echo "Test 2: Ctrl+key detection"
echo "-------------------------"
echo "Test content" > "$TEST_FILE"
echo ""
echo "Running: $EDITOR_BIN $TEST_FILE"
echo "Expected behavior:"
echo "  1. Press Ctrl+O - should trigger save (or show save prompt)"
echo "  2. Press Ctrl+X - should trigger exit (or show exit prompt)"
echo "  3. Press Ctrl+Q - should exit immediately"
echo "  4. Ctrl+keys should not print characters on screen"
echo ""
read -p "Do Ctrl+key combinations work correctly? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy$ ]]; then
    echo "✓ Test 2 PASSED"
else
    echo "✗ Test 2 FAILED"
    exit 1
fi
echo ""

# Test 3: Printable character input
echo "Test 3: Printable character input"
echo "----------------------------------"
echo "" > "$TEST_FILE"
echo ""
echo "Running: $EDITOR_BIN $TEST_FILE"
echo "Expected behavior:"
echo "  1. Type letters, numbers, and symbols"
echo "  2. Characters should appear immediately at cursor position"
echo "  3. Cursor should move after each character"
echo "  4. Modified flag should be set"
echo ""
read -p "Does printable character input work correctly? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "✓ Test 3 PASSED"
else
    echo "✗ Test 3 FAILED"
    exit 1
fi
echo ""

# Test 4: Special keys (Backspace, Enter, Delete)
echo "Test 4: Special keys (Backspace, Enter, Delete)"
echo "----------------------------------------------"
echo "Test line" > "$TEST_FILE"
echo ""
echo "Running: $EDITOR_BIN $TEST_FILE"
echo "Expected behavior:"
echo "  1. Press Backspace - should delete character before cursor"
echo "  2. Press Enter - should insert newline"
echo "  3. Press Delete - should delete character at cursor"
echo "  4. Screen should update immediately"
echo ""
read -p "Do special keys work correctly? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "✓ Test 4 PASSED"
else
    echo "✗ Test 4 FAILED"
    exit 1
fi
echo ""

echo "Phase 3: All tests PASSED"
