# Nano Configuration for Software Development

A well-configured nano setup optimized for software development with sensible defaults, productivity features, and a custom color scheme.

## Features

### 📝 Editor Enhancements
- **Line numbers** with custom color
- **Smart indentation** with 4-space tabs converted to spaces
- **Soft wrapping** at whitespace for better readability
- **Bracket matching** for `()`, `[]`, `{}`, and `<>`
- **Smart Home key** (jump to text start, then line start)
- **Intelligent word boundaries** for better navigation

### 💾 File Management
- **Automatic backups** stored in `~/.nano/backups/`
- **Search history** persists across sessions
- **Vim-style file locking** to prevent concurrent edits
- **Preserve file endings** (no automatic newlines)

### 🔍 Search & Replace
- **Case-sensitive search** enabled by default
- **Regular expressions** enabled by default
- Both can be toggled with `Alt+C` and `Alt+R`

### 🎨 Visual Improvements
- **Scroll indicator** shows position in file
- **Constant status display** with line/column/percentage
- **Whitespace visualization** (tabs as `»`, spaces as `·`)
- **Custom color scheme** for better visibility
- **Bold text** instead of reverse video

### ⌨️ Editing Behavior
- **Zap mode** for quick line deletion with `Ctrl+K`
- **Cut from cursor** (cut to end of line, not whole line)
- **Trim trailing whitespace** when wrapping
- **Mouse support** for clicking and selecting

## Installation

### Quick Install

```bash
# Download the configuration
curl -o ~/.nanorc https://raw.githubusercontent.com/ZlatanOmerovic/nanorc/main/.nanorc

# Create backup directory
mkdir -p ~/.nano/backups
```

### Manual Install

1. Clone this repository:
   ```bash
   git clone https://github.com/ZlatanOmerovic/nanorc.git
   cd nanorc
   ```

2. Copy the configuration file:
   ```bash
   cp .nanorc ~/.nanorc
   ```

3. Create the backup directory:
   ```bash
   mkdir -p ~/.nano/backups
   ```

4. Test the configuration:
   ```bash
   nano test.txt
   ```

## Customization

### Disable Help Lines

Uncomment this line in `~/.nanorc` for more screen space:
```bash
set nohelp
```

### Change Colors

Modify the color scheme section to your preference:
```bash
set titlecolor white,blue      # Change title bar to white on blue
set numbercolor yellow         # Change line numbers to yellow
```

Available colors: `white`, `black`, `red`, `blue`, `green`, `yellow`, `cyan`, `magenta`, and their `bright` variants.

### Adjust Key Bindings

You can add custom key bindings at the end of the file:
```bash
bind ^S savefile main          # Ctrl+S to save
bind ^Q exit main              # Ctrl+Q to quit
```

## Keyboard Shortcuts Reference

| Shortcut | Action |
|----------|--------|
| `Ctrl+G` | Show help (full command list) |
| `Ctrl+O` | Save file |
| `Ctrl+X` | Exit nano |
| `Ctrl+W` | Search |
| `Ctrl+\` | Search and replace |
| `Ctrl+K` | Cut line (or from cursor) |
| `Ctrl+U` | Paste |
| `Ctrl+C` | Show cursor position |
| `Alt+C` | Toggle case-sensitive search |
| `Alt+R` | Toggle regex search |
| `Alt+X` | Toggle help lines |

## Requirements

- **GNU nano 7.2** or later (check with `nano --version`)
- Syntax highlighting files in `/usr/share/nano/` (usually pre-installed)

## File Structure

```
.
├── .nanorc           # Main configuration file
└── README.md         # This file
```

## Troubleshooting

### "Unknown option" errors

If you see errors when opening nano, your version may not support all options. Simply comment out the problematic lines:

```bash
# set someOption    # Commented out - not available in this version
```

### Backups not working

Ensure the backup directory exists:
```bash
mkdir -p ~/.nano/backups
ls -la ~/.nano/backups  # Verify it exists
```

### Colors not showing

Ensure your terminal supports colors. Test with:
```bash
echo $TERM  # Should show something like 'xterm-256color'
```

### Syntax highlighting not working

Verify syntax files exist:
```bash
ls /usr/share/nano/  # Should show .nanorc files for various languages
```

## Configuration Options Explained

### Basic Settings
- `set linenumbers` - Shows line numbers for easy navigation
- `set autoindent` - Maintains indentation level on new lines
- `set tabsize 4` - Sets tab width to 4 spaces (standard for most code)
- `set tabstospaces` - Converts tabs to spaces for consistent formatting

### Advanced Features
- `set constantshow` - Always displays cursor position (line, column, percentage)
- `set indicator` - Shows a scroll bar indicator on the right edge
- `set matchbrackets` - Highlights matching brackets when cursor is on one
- `set whitespace "»·"` - Makes tabs and spaces visible for debugging

### File Safety
- `set backup` - Creates backup files before saving
- `set backupdir "~/.nano/backups"` - Stores backups in dedicated directory
- `set locking` - Prevents multiple editors from modifying the same file

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## License

This configuration is released into the public domain. Use it however you like.

## Acknowledgments

- Built for GNU nano 7.2
- Inspired by the software development community's best practices
- Tested on Ubuntu/Debian-based systems and WSL

## Author

**Zlatan Omerovic**
- GitHub: [@ZlatanOmerovic](https://github.com/ZlatanOmerovic)
- Repository: [nanorc](https://github.com/ZlatanOmerovic/nanorc)

---

**⚠️ Important**: Don't forget to create the backup directory after installation!

```bash
mkdir -p ~/.nano/backups
```

**💡 Tip**: Press `Ctrl+G` in nano to see the full list of available commands and shortcuts.

