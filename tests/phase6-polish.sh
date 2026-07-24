#!/bin/bash
# Phase 6: Polish Tests
# Tests screen scrolling, error handling, and overall UX

set -e

EDITOR_BIN="./editor"
TEST_FILE="/tmp/editor-test-phase6.txt"

echo "Phase 6: Polish Tests"
echo "====================="
echo ""

# Clean up function
cleanup() {
    if [ -f "$TEST_FILE" ]; then
        rm -f "$TEST_FILE"
    fi
}

trap cleanup EXIT

# Test 1: Screen scrolling
echo "Test 1: Screen scrolling"
echo "------------------------"
# Create a file with many lines
for i in {1..50}; do
    echo "Line $i of 50 - This is a test line for scrolling"
done > "$TEST_FILE"
echo "Created test file with 50 lines"
echo ""
echo "Running: $EDITOR_BIN $TEST_FILE"
echo "Expected behavior:"
echo "  1. File should display with visible portion"
echo "  2. Use arrow keys to move down past visible area"
echo "  3. Screen should scroll to keep cursor visible"
echo "  4. Scroll should be smooth and responsive"
echo ""
read -p "Does screen scrolling work correctly? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "✓ Test 1 PASSED"
else
    echo "✗ Test 1 FAILED"
    exit 1
fi
echo ""

# Test 2: Error handling - file not found
echo "Test 2: Error handling - file not found"
echo "--------------------------------------"
if [ -f "$TEST_FILE" ]; then
    rm -f "$TEST_FILE"
fi
echo "File does not exist"
echo ""
echo "Running: $EDITOR_BIN /nonexistent/path/to/file.txt"
echo "Expected behavior:"
echo "  1. Editor should start with empty buffer (creates on save)"
echo "  2. Should not crash or show cryptic errors"
echo "  3. Should handle gracefully"
echo ""
read -p "Does file not found handling work correctly? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "✓ Test 2 PASSED"
else
    echo "✗ Test 2 FAILED"
    exit 1
fi
echo ""

# Test 3: Error handling - permission denied
echo "Test 3: Error handling - permission denied"
echo "-----------------------------------------"
echo "Test content" > "$TEST_FILE"
chmod 000 "$TEST_FILE"
echo "Made file read-only (no permissions)"
echo ""
echo "Running: $EDITOR_BIN $TEST_FILE"
echo "Expected behavior:"
echo "  1. Editor should open file for reading"
echo "  2. Attempt to save should show clear error message"
echo "  3. Should not crash"
echo "  4. Exit should work normally"
echo ""
read -p "Does permission error handling work correctly? (y/n) " -n 1 -r
echo
chmod 644 "$TEST_FILE"  # Restore permissions
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "✓ Test 3 PASSED"
else
    echo "✗ Test 3 FAILED"
    exit 1
fi
echo ""

# Test 4: Help screen (Ctrl+G)
echo "Test 4: Help screen (Ctrl+G)"
echo "-----------------------------"
echo "Test content" > "$TEST_FILE"
echo ""
echo "Running: $EDITOR_BIN $TEST_FILE"
echo "Expected behavior:"
echo "  1. Press Ctrl+G"
echo "  2. Help screen should display"
echo "  3. Help should show key bindings"
echo "  4. Press any key to dismiss help"
echo ""
read -p "Does help screen work correctly? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "✓ Test 4 PASSED"
else
    echo "✗ Test 4 FAILED"
    exit 1
fi
echo ""

# Test 5: Overall responsiveness
echo "Test 5: Overall responsiveness"
echo "------------------------------"
echo "Test content" > "$TEST_FILE"
echo ""
echo "Running: $EDITOR_BIN $TEST_FILE"
echo "Expected behavior:"
echo "  1. Typing should be responsive (no lag)"
echo "  2. Arrow keys should move cursor immediately"
echo "  3. Screen redraws should be clean (no flicker)"
echo "  4. Overall feel should be smooth"
echo ""
read -p "Is the editor responsive and smooth? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "✓ Test 5 PASSED"
else
    echo "✗ Test 5 FAILED"
    exit 1
fi
echo ""

# Test 6: Large file handling (100KB test)
echo "Test 6: Large file handling (100KB test)"
echo "-----------------------------------------"
# Create a ~100KB file
dd if=/dev/urandom bs=1024 count=100 of="$TEST_FILE" 2>/dev/null
echo "Created ~100KB test file"
echo ""
echo "Running: $EDITOR_BIN $TEST_FILE"
echo "Expected behavior:"
echo "  1. File should load without significant delay"
echo "  2. Navigation should remain responsive"
echo "  3. No performance degradation"
echo ""
read -p "Does large file handling work acceptably? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "✓ Test 6 PASSED"
else
    echo "✗ Test 6 FAILED"
    exit 1
fi
echo ""

echo "Phase 6: All tests PASSED"
