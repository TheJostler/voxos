# Vox Text Editor (Level 2) - Implementation Plan

## Overview
A minimal visual text editor for Vox, targeting nano-style functionality with full-screen editing, cursor movement, and shell restoration capabilities.

## User Stories

### US1: Basic File Operations
**As a user**, I want to open a file for editing so that I can modify its contents.
- Accept filename as command-line argument
- If no argument, start with empty buffer
- Display file contents on screen

**Acceptance Criteria:**
- Given an existing file, running `editor.vox file.txt` opens and displays its contents
- Given no argument, running `editor.vox` opens with empty buffer
- Given a non-existent file, editor starts with empty buffer (creates on save)
- File contents display correctly including newlines and special characters

### US2: Navigate with Cursor
**As a user**, I want to move the cursor around the screen so that I can position it where I want to edit.
- Arrow keys (up, down, left, right)
- Cursor stays within file bounds
- Screen scrolls if file is larger than display

**Acceptance Criteria:**
- Pressing up arrow moves cursor up one line (or to top of file)
- Pressing down arrow moves cursor down one line (or to bottom of file)
- Pressing left arrow moves cursor left one character (or to start of line)
- Pressing right arrow moves cursor right one character (or to end of line)
- Cursor cannot move beyond file boundaries
- When cursor moves past visible screen, content scrolls to keep cursor visible

### US3: Edit Text
**As a user**, I want to insert and delete characters so that I can modify the file.
- Type characters to insert at cursor position
- Backspace deletes character before cursor
- Delete key deletes character at cursor
- Enter key inserts newline

**Acceptance Criteria:**
- Typing a printable character inserts it at cursor position
- Backspace deletes character immediately before cursor
- Delete key deletes character at cursor position
- Enter key inserts newline and moves cursor to start of next line
- Modified flag is set when any edit operation occurs
- Edits are reflected immediately on screen

### US4: Save and Exit
**As a user**, I want to save my changes and exit the editor so that my work persists.
- Ctrl+O to write file to disk
- Ctrl+X to exit (prompt if unsaved changes)
- Ctrl+Q to quit without saving

**Acceptance Criteria:**
- Pressing Ctrl+O writes current buffer to file
- After save, modified flag is cleared
- Pressing Ctrl+X with unsaved changes prompts user to save
- Pressing Ctrl+X with no unsaved changes exits immediately
- Pressing Ctrl+Q exits immediately without saving (no prompt)
- Save operation handles write errors (permission denied, disk full) gracefully

### US5: Restore Shell
**As a user**, I want the editor to cleanly exit and restore my shell session so that I can continue working.
- Terminal returns to exact state before editor launched
- No leftover artifacts on screen
- Shell history intact

**Acceptance Criteria:**
- After editor exits, terminal displays exactly where it was before launch
- Shell command history is preserved and accessible
- No editor text remains visible on screen
- Terminal is in normal (cooked) mode after exit
- Cursor is positioned at shell prompt ready for input
- Alternate screen buffer is properly released

## Technical Architecture

### Terminal Control Strategy

#### 1. Screen Buffer Switching
The editor uses the terminal's alternate screen buffer to avoid disturbing the shell session:

**On startup:**
```
write "\e[?1049h"  # Switch to alternate screen buffer
write "\e[2J"      # Clear screen
write "\e[H"       # Move cursor to top-left (1,1)
```

**On exit:**
```
write "\e[2J"      # Clear alternate buffer
write "\e[?1049l"  # Switch back to main buffer (shell restored)
```

This ensures the shell's scrollback and current state are preserved - the editor writes to a completely separate buffer.

#### 2. Raw Mode for Single-Character Input
Normal terminal mode (cooked mode) buffers input line-by-line and echoes characters. The editor needs raw mode:

**Required termios flags:**
- Disable `ICANON` - Disable line buffering (get chars immediately)
- Disable `ECHO` - Don't echo input (editor handles display)
- Disable `ISIG` - Disable signal handling (Ctrl+C doesn't kill editor)
- Optional: Disable `IXON` - Disable XON/XOFF flow control

**Implementation approach:**
1. Use `ioctl` with `TCGETS` to get current termios
2. Modify flags to enable raw mode
3. Use `ioctl` with `TCSETS` to apply new settings
4. On exit, restore original termios settings

**Fallback if ioctl unavailable:**
- Use stty subprocess: `stty raw -echo` before editor, `stty sane` after
- Less elegant but functional

#### 3. ANSI Escape Sequences for Display

**Cursor positioning:**
```
\e[row;colH    # Move cursor to 1-indexed row, col
\e[A            # Up 1
\e[B            # Down 1
\e[C            # Right 1
\e[D            # Left 1
```

**Screen clearing:**
```
\e[2J           # Clear entire screen
\e[K            # Clear from cursor to end of line
\e[0K           # Clear from cursor to beginning of line
\e[2K           # Clear entire line
```

**Text styling (for future syntax highlighting):**
```
\e[0m           # Reset all attributes
\e[1m           # Bold
\e[4m           # Underline
\e[30m-37m      # Foreground colors (black to white)
\e[40m-47m      # Background colors
```

**Status line:**
```
\e[row;colH     # Position cursor
\e[7m           # Reverse video (for status bar)
\e[0m           # Reset
```

### Data Structures

#### File Buffer
- **Dynamic buffer** containing entire file contents
- Stored as-is with newlines preserved
- Line breaks: `\n` (Unix style)

#### Line Table
- **List of line start offsets** into the buffer
- Enables O(1) line-to-offset lookup
- Updated on insert/delete

#### Cursor State
- **Row, col** (1-indexed, relative to file, not screen)
- **Screen offset** (top line currently displayed)
- **Dirty flag** (unsaved changes)

#### Screen State
- **Rows, cols** (terminal dimensions)
- **Top line** (first line currently visible)
- **Bottom line** (last line currently visible)

### Input Handling

#### Key Reading Loop
```
While not exiting,
    read 1 byte from stdin into key
    if key is ESC (27),
        read 2 more bytes (escape sequence)
        decode arrow keys, function keys
    else if key is Ctrl+O (15),
        save file
    else if key is Ctrl+X (24),
        prompt to save if dirty
        exit
    else if key is Ctrl+Q (17),
        exit without saving
    else if key is Backspace (127),
        delete character before cursor
    else if key is Enter (10),
        insert newline
    else if key is printable (32-126),
        insert character at cursor
    redraw screen
```

#### Escape Sequence Decoding
Arrow keys send 3-byte sequences:
- Up: `\e[A` (27, 91, 65)
- Down: `\e[B` (27, 91, 66)
- Right: `\e[C` (27, 91, 67)
- Left: `\e[D` (27, 91, 68)

### Screen Rendering

#### Redraw Strategy
**Full redraw (simple but slower):**
```
write "\e[H"           # Move to top-left
For each visible line,
    write line content
    write "\e[K"       # Clear to end of line
    write "\r\n"       # Newline
Draw status line
Move cursor to current position
```

**Optimized redraw (future):**
- Only redraw changed lines
- Use `\e[row;colH` to jump to dirty lines
- Track line-by-line dirty flags

#### Status Line Format
```
Position: row,col    Lines: N    Modified: [Y/N]    Ctrl+O:Save  Ctrl+X:Exit
```

Displayed at bottom of screen in reverse video.

### File Operations

#### Loading
```
Open file for reading
Read entire file into buffer
Build line table by scanning for \n
Close file
```

#### Saving
```
Open file for writing (truncate)
Write buffer contents
Close file
Clear dirty flag
```

## Implementation Phases

### Phase 1: Terminal Control Foundation
**Goal:** Establish terminal switching and raw mode

**Tasks:**
1. Implement alternate screen buffer switch (startup/exit)
2. Implement raw mode switch (termios ioctl or stty fallback)
3. Implement basic ANSI escape sequence writing
4. Test: program that switches buffers, prints "Hello", waits for key, exits

**Acceptance:** Running the program shows clean buffer switch and restoration.

### Phase 2: Display Engine
**Goal:** Render file contents to screen

**Tasks:**
1. Load file into buffer
2. Build line table
3. Implement screen clearing and cursor positioning
4. Render visible lines with line wrapping
5. Draw status line
6. Implement terminal size detection (ioctl TIOCGWINSZ or fallback)

**Acceptance:** File contents display correctly with status line.

### Phase 3: Input Handling
**Goal:** Process keyboard input

**Tasks:**
1. Implement single-byte read loop
2. Decode escape sequences (arrow keys)
3. Implement Ctrl+key detection
4. Map keys to actions (up/down/left/right, insert, delete)

**Acceptance:** Arrow keys move cursor, typing inserts characters.

### Phase 4: Editing Operations
**Goal:** Implement insert/delete

**Tasks:**
1. Insert character at cursor (shift buffer content)
2. Delete character at cursor (shift buffer content)
3. Backspace (delete before cursor)
4. Insert newline (split line, update line table)
5. Update dirty flag on modifications

**Acceptance:** Can type and edit text with cursor movement.

### Phase 5: File Operations
**Goal:** Save and exit cleanly

**Tasks:**
1. Implement save (write buffer to file)
2. Implement exit with unsaved prompt
3. Implement quit without saving
4. Ensure termios restoration on all exit paths

**Acceptance:** Can save changes and exit cleanly with shell restoration.

### Phase 6: Polish
**Goal:** Improve UX

**Tasks:**
1. Screen scrolling when cursor moves off-screen
2. Line number display (optional)
3. Better status line information
4. Error handling (file not found, permission denied)
5. Help screen (Ctrl+G)

**Acceptance:** Smooth, usable editor experience.

## Key Technical Challenges

### Challenge 1: Termios ioctl Availability
**Issue:** Vox may not have termios ioctl support yet.

**Solutions:**
1. Add ioctl syscall to Vox (if not present)
2. Fallback to stty subprocess: `stty raw -echo` before, `stty sane` after
3. Use cooked mode with line buffering (limited functionality)

**Decision:** Check Vox's current syscall surface first. Use stty fallback as interim.

### Challenge 2: Escape Sequence Reading Race
**Issue:** ESC key vs escape sequence - need to distinguish.

**Solution:**
- When ESC (27) is read, set a short timeout (e.g., 50ms)
- If more bytes arrive within timeout, it's an escape sequence
- If timeout expires, it's the ESC key alone
- Use select/poll for timeout (if available) or simple busy-wait loop

**Simpler approach for MVP:**
- Assume all ESC starts an escape sequence
- Read 2 more bytes immediately
- If invalid sequence, treat as ESC + two characters

### Challenge 3: Buffer Reallocation on Insert
**Issue:** Inserting characters in middle of buffer requires shifting.

**Solution:**
- Vox's dynamic buffers grow automatically
- Insert operation: read from cursor to end, write back at cursor+1
- Or: use append + manual shift with byte operations

**Optimization:** For large files, consider gap buffer or rope data structure (future).

### Challenge 4: Terminal Size Detection
**Issue:** Need to know screen dimensions for scrolling.

**Solutions:**
1. ioctl TIOCGWINSZ (if available)
2. Parse environment variables LINES and COLUMNS
3. Fallback to 24x80 (VT100 default)
4. Handle SIGWINCH to detect resize (advanced)

**Decision:** Try ioctl first, then env vars, then 24x80 fallback.

### Challenge 5: Line Wrapping
**Issue:** Long lines need to wrap across screen rows.

**Solutions:**
1. Simple: truncate at screen width (MVP)
2. Better: soft wrap with visual continuation marker
3. Advanced: track wrapped line positions in line table

**Decision:** MVP truncates with visual indicator (>).

## Dependencies on Vox Capabilities

### Required (must exist or be added):
- File I/O (open/read/write/close) - ✓ exists
- Dynamic buffers - ✓ exists
- Lists - ✓ exists
- Control flow (while/if/for) - ✓ exists
- ioctl with TCGETS/TCSETS - ? check
- ioctl with TIOCGWINSZ - ? check
- Single-byte read without newline - ? check (may need raw mode)

### Nice to have (can work around):
- select/poll for timeout - can use busy-wait
- Signal handling (SIGWINCH) - not needed for MVP
- Multi-byte buffer operations - can do byte-by-byte

## Success Criteria

### Overall Project Success
The editor is considered complete when all of the following are met:

1. **Functional Completeness:**
   - Can open existing files, create new files, edit content, and save changes
   - All user stories (US1-US5) have passing acceptance criteria
   - Editor can handle files up to at least 100KB without performance degradation

2. **Shell Restoration:**
   - Terminal returns to exact pre-launch state after exit (verified by visual inspection)
   - Shell command history is preserved (up-arrow recalls previous commands)
   - Terminal mode is restored to cooked mode (echo works, line buffering works)
   - No escape sequence artifacts remain in terminal buffer

3. **Usability:**
   - Cursor movement is responsive (no perceptible lag on arrow keys)
   - Typing is responsive (characters appear immediately)
   - Screen redraws cleanly without flicker
   - Status line accurately reflects editor state

4. **Robustness:**
   - Handles non-existent files gracefully (creates on save)
   - Handles permission denied errors with clear error message
   - Handles disk full errors with clear error message
   - Does not crash on invalid input or unexpected key sequences
   - Restores terminal state even if editor crashes (via signal handlers or cleanup on exit)

5. **Vox-Idiomatic Code:**
   - Code follows Vox language patterns from LANGUAGE.md
   - Uses Vox's memory safety features (bounds-checked buffers, resource tracking)
   - No raw pointer manipulation or unsafe operations
   - Proper use of Vox's control flow and function definitions
   - Comments explain non-obvious Vox-specific patterns

### Phase-Specific Success Criteria

**Phase 1 (Terminal Control Foundation):**
- Test program switches to alternate buffer, displays text, waits for keypress, switches back
- Shell is restored exactly to pre-launch state after test program exits
- Raw mode is enabled (single-character input works without line buffering)
- ANSI escape sequences are correctly written and interpreted by terminal

**Phase 2 (Display Engine):**
- File contents display correctly with proper line breaks
- Status line appears at bottom of screen in reverse video
- Terminal size is detected correctly (or fallback to 24x80)
- Lines longer than screen width are truncated with visual indicator

**Phase 3 (Input Handling):**
- Arrow keys are correctly decoded from escape sequences
- Ctrl+key combinations are correctly detected
- Printable characters are correctly identified
- Backspace, Enter, and Delete keys are correctly identified

**Phase 4 (Editing Operations):**
- Character insertion works at any cursor position
- Character deletion works at any cursor position
- Backspace works at any cursor position
- Newline insertion works and updates line table
- Modified flag is set on any edit operation

**Phase 5 (File Operations):**
- Save operation writes correct content to disk
- Exit with unsaved changes prompts user
- Exit without saving bypasses prompt
- Termios is restored on all exit paths (normal exit, error exit, Ctrl+C)

**Phase 6 (Polish):**
- Screen scrolling keeps cursor visible
- Error messages are clear and actionable
- Help screen displays with Ctrl+G
- Overall editor feels smooth and responsive

## Future Enhancements (Beyond Level 2)

- Syntax highlighting for Vox files
- Search and replace (reuse `contains token` pattern)
- Multiple file buffers (tabs)
- Undo/redo
- Macro recording
- External command execution
- Line numbers
- Auto-indentation
- Bracket matching
