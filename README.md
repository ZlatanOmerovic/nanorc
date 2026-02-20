# Nano Configuration for Software Development

A well-configured nano setup optimized for software development with sensible defaults, productivity features, and a custom color scheme. Includes multiple templates for different use cases, all tested against GNU nano 5.x through 8.x.

<img src="logo.webp" alt="Nano Configuration for Software Development" width="100%">

## Templates

Choose the template that fits your workflow:

| Template | Best For | Key Features |
|----------|----------|-------------|
| **[development](templates/development.nanorc)** | Software development (default) | Line numbers, smart navigation, regex search, file backups, bracket matching, custom colors |
| **[minimal](templates/minimal.nanorc)** | Lightweight essentials | Line numbers, auto-indent, mouse, soft wrap — nothing else |
| **[writing](templates/writing.nanorc)** | Prose, markdown, docs | Soft wrap at words, no line numbers, gentle color scheme, distraction-free |
| **[beginner](templates/beginner.nanorc)** | New nano users | Same as minimal + detailed comments explaining every option, help lines visible |
| **[advanced](templates/advanced.nanorc)** | Power users | Everything from development + hidden help lines, whitespace visualization, custom keybindings (Ctrl+S/Q/Z/Y) |

The root `.nanorc` file is identical to the **development** template.

### Template Comparison

| Feature | minimal | beginner | development | writing | advanced |
|---------|:-------:|:--------:|:-----------:|:-------:|:--------:|
| Line numbers | x | x | x | | x |
| Auto-indent | x | x | x | x | x |
| 4-space tabs | x | x | x | x | x |
| Soft wrap | x | x | x | x | x |
| Mouse support | x | x | x | x | x |
| Smart Home key | | x | x | x | x |
| Word boundaries | | | x | | x |
| Jumpy scrolling | | | | | x |
| Zap (select + type) | | x | x | | x |
| Cut from cursor | | | x | | x |
| Trim trailing blanks | | | x | | x |
| File backups | | x | x | x | x |
| File locking | | | x | x | x |
| Search history | | x | x | x | x |
| Position memory | | x | x | x | x |
| Multi-buffer editing | | | x | | x |
| Case-sensitive search | | | x | | x |
| Regex search | | | x | | x |
| Magic syntax detection | | | | | x |
| Bracket matching | | x | x | | x |
| Scroll indicator | | x | x | x | x |
| Guide stripe (col 80) | | | x | | x |
| Whitespace visualization | | | | | x |
| Spotlight (search match) | | | x | x | x |
| Empty line below title | | | | x | x |
| Hidden help lines | | | | | x |
| State flags | | | x | | x |
| Bold text | | | x | x | x |
| Show cursor in browser | | | | | x |
| Raw sequences | | | | | x |
| Book-style paragraphs | | | | x | x |
| Spell checker | | | | x | x |
| Unix format | | | | | x |
| Custom keybindings | | | | | x |
| Custom color scheme | | x | x | x | x |
| Syntax highlighting | x | x | x | x | x |

## Installation

### macOS — Install GNU nano first

macOS ships with **UW Pico** (aliased as `nano`), not GNU nano. Pico does not support `.nanorc` configuration files at all. You must install GNU nano before using any of these configs:

```bash
# Install GNU nano via Homebrew
brew install nano

# Make Homebrew's nano the default (add to ~/.zshrc)
echo 'export PATH="/opt/homebrew/bin:$PATH"' >> ~/.zshrc
source ~/.zshrc

# Verify you're running GNU nano
nano --version  # Should show "GNU nano" not "UW PICO"
```

> **Note:** On Intel Macs, the Homebrew path is `/usr/local/bin` instead of `/opt/homebrew/bin`.

### Quick Install (development template)

```bash
# Download the configuration
curl -o ~/.nanorc https://raw.githubusercontent.com/ZlatanOmerovic/nanorc/master/.nanorc

# Create backup directory
mkdir -p ~/.nano/backups
```

### Install a Specific Template

```bash
# Replace TEMPLATE with: minimal, development, writing, beginner, or advanced
curl -o ~/.nanorc https://raw.githubusercontent.com/ZlatanOmerovic/nanorc/master/templates/TEMPLATE.nanorc

# Create backup directory (required for all templates except minimal)
mkdir -p ~/.nano/backups
```

### Manual Install

1. Clone this repository:
   ```bash
   git clone https://github.com/ZlatanOmerovic/nanorc.git
   cd nanorc
   ```

2. Copy your preferred template:
   ```bash
   cp templates/development.nanorc ~/.nanorc
   ```

3. Create the backup directory:
   ```bash
   mkdir -p ~/.nano/backups
   ```

4. Test the configuration:
   ```bash
   nano test.txt
   ```

## Testing

All templates are validated against multiple GNU nano versions using Docker. This ensures every configuration option is recognized and functional before you use it.

### Compatibility Matrix

| Config | nano 5.9 | nano 6.2 | nano 7.2 | nano 8.0 |
|--------|:--------:|:--------:|:--------:|:--------:|
| minimal | PASS | PASS | PASS | PASS |
| development | PASS | PASS | PASS | PASS |
| writing | PASS | PASS | PASS | PASS |
| beginner | PASS | PASS | PASS | PASS |
| advanced | PASS | PASS | PASS | PASS |
| keymap: default | PASS | PASS | PASS | PASS |
| keymap: gui | PASS | PASS | PASS | PASS |
| keymap: emacs | PASS | PASS | PASS | PASS |

### Running Tests

Requires Docker.

```bash
# Run all tests (5 templates + 3 keymaps) x 4 nano versions = 32 test runs
make test

# Test a specific template
make test-development
make test-minimal

# Test a specific keymap
make test-keymap-gui
make test-keymap-emacs

# Test a specific config against a specific nano version
./test/test.sh development 7.2
./test/test.sh gui-keymap 7.2

# Clean up Docker images
make clean
```

### What the Tests Validate

1. **Config file is readable** — file exists and has correct permissions
2. **No configuration errors** — nano starts without any option errors
3. **Backup directory is functional** — backup dir is writable (if configured)
4. **Syntax highlighting loads** — syntax definition files are found
5. **All options are recognized** — every `set` directive uses a known option name
6. **All bindings are valid** — every `bind`/`unbind` directive uses recognized function and menu names

## Keymaps

Optional keymap files that remap nano's keyboard shortcuts to match other editors. Include one in your `.nanorc` to change the keybindings.

| Keymap | Style | Description |
|--------|-------|-------------|
| **[default](keymaps/default.keymaprc)** | Nano standard | Documents nano's built-in bindings. Use as a reference or starting point. |
| **[gui](keymaps/gui.keymaprc)** | Desktop / GUI | Ctrl+C copy, Ctrl+V paste, Ctrl+X cut, Ctrl+Z undo, Ctrl+S save, Ctrl+F find — like VS Code, Sublime, gedit, Notepad++ |
| **[emacs](keymaps/emacs.keymaprc)** | Emacs | C-f/C-b/C-n/C-p movement, C-k kill line, C-y yank, C-w cut region, C-s search, C-Space mark |

### Using a Keymap

Add an `include` line at the end of your `.nanorc`:

```bash
# Pick ONE of these:
include /path/to/nanorc/keymaps/gui.keymaprc
include /path/to/nanorc/keymaps/emacs.keymaprc
```

Or with curl (standalone download):
```bash
# Download the GUI keymap
curl -o ~/.nano/gui.keymaprc https://raw.githubusercontent.com/ZlatanOmerovic/nanorc/master/keymaps/gui.keymaprc

# Add to your .nanorc
echo 'include "~/.nano/gui.keymaprc"' >> ~/.nanorc
```

### Keymap Comparison

| Action | Nano Default | GUI Keymap | Emacs Keymap |
|--------|-------------|------------|--------------|
| Save | `Ctrl+O` | `Ctrl+S` | `Ctrl+O` |
| Exit | `Ctrl+X` | `Ctrl+W` / `Ctrl+Q` | `Ctrl+X` |
| Copy | `Alt+6` | `Ctrl+C` | `Alt+W` |
| Cut | `Ctrl+K` | `Ctrl+X` | `Ctrl+W` |
| Paste | `Ctrl+U` | `Ctrl+V` | `Ctrl+Y` |
| Undo | `Alt+U` | `Ctrl+Z` | `Ctrl+/` |
| Redo | `Alt+E` | `Ctrl+Y` | — |
| Search | `Ctrl+W` | `Ctrl+F` | `Ctrl+S` |
| Replace | `Ctrl+\` | `Ctrl+H` | `Alt+%` |
| Go to line | `Ctrl+_` | `Ctrl+G` | `Alt+G` |
| Select/Mark | `Alt+A` | `Ctrl+A` | `Ctrl+Space` |
| Help | `Ctrl+G` | `F1` | `F1` |

### Why No Vim Keymap?

Vim's entire model is based on **modal editing** (normal mode vs. insert mode). Nano has no concept of modes — every key always types text. You can't make `h/j/k/l` navigate, `dd` delete a line, or `yy` yank without also inserting those characters. Nano's `bind` system can only remap Ctrl/Alt/Function key combos, not plain letter keys. A "vim keymap" for nano would be misleading.

## Customization

### Change Colors

Modify the color scheme section in your chosen template:
```bash
set titlecolor white,blue      # Change title bar to white on blue
set numbercolor yellow         # Change line numbers to yellow
```

Available colors: `white`, `black`, `red`, `blue`, `green`, `yellow`, `cyan`, `magenta`, and their `bright` variants.

### Add Key Bindings

Add custom key bindings at the end of the file:
```bash
bind ^S savefile main          # Ctrl+S to save
bind ^Q exit main              # Ctrl+Q to quit
```

The **advanced** template includes these bindings by default.

## Keyboard Shortcuts Reference

| Shortcut | Action |
|----------|--------|
| `Ctrl+G` | Show help (full command list) |
| `Ctrl+O` | Save file |
| `Ctrl+X` | Exit nano |
| `Ctrl+W` | Search |
| `Ctrl+\` | Search and replace |
| `Ctrl+K` | Cut line (or from cursor, if `cutfromcursor` is set) |
| `Ctrl+U` | Paste |
| `Ctrl+C` | Show cursor position |
| `Alt+C` | Toggle case-sensitive search |
| `Alt+R` | Toggle regex search |
| `Alt+L` | Toggle whitespace visualization |
| `Alt+N` | Toggle line numbers |
| `Alt+X` | Toggle help lines |

## Requirements

- **GNU nano 5.9** or later (check with `nano --version`)
- **macOS users:** You must install GNU nano via `brew install nano` — macOS ships with UW Pico, which does not support `.nanorc` files (see [Installation](#installation))
- **Docker** (only for running the test suite)
- Syntax highlighting files in `/usr/share/nano/` (usually pre-installed)

## File Structure

```
.
├── .nanorc                    # Default config (= development template)
├── Makefile                   # Test runner (make test, make clean)
├── README.md                  # This file
├── templates/
│   ├── minimal.nanorc         # Lightweight essentials
│   ├── development.nanorc     # Full dev setup
│   ├── writing.nanorc         # Prose and markdown
│   ├── beginner.nanorc        # New users, detailed comments
│   └── advanced.nanorc        # Power users, max features
├── keymaps/
│   ├── default.keymaprc       # Nano default bindings (reference)
│   ├── gui.keymaprc           # Desktop-style (Ctrl+C/V/X/Z/S/F)
│   └── emacs.keymaprc         # Emacs-compatible bindings
└── test/
    ├── Dockerfile             # Multi-version nano test image
    ├── test.sh                # Test runner script
    └── validate.sh            # Config validation script
```

## Troubleshooting

### macOS: nano ignores .nanorc / shows "UW PICO"

macOS bundles UW Pico (not GNU nano) at `/usr/bin/nano`. Pico does not read `.nanorc` files. Install GNU nano and make it the default:

```bash
brew install nano
echo 'export PATH="/opt/homebrew/bin:$PATH"' >> ~/.zshrc  # Apple Silicon
# echo 'export PATH="/usr/local/bin:$PATH"' >> ~/.zshrc   # Intel Mac
source ~/.zshrc
nano --version  # Should now show "GNU nano"
```

### "Unknown option" errors

Your nano version may not support all options. Check your version with `nano --version`, then comment out unsupported lines. Run the test suite to validate your config:
```bash
make test
```

### Backups not working

Ensure the backup directory exists:
```bash
mkdir -p ~/.nano/backups
```

### Colors not showing

Ensure your terminal supports colors:
```bash
echo $TERM  # Should show something like 'xterm-256color'
```

### Syntax highlighting not working

Verify syntax files exist:
```bash
ls /usr/share/nano/  # Should show .nanorc files for various languages
```

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Run the test suite: `make test`
4. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
5. Push to the branch (`git push origin feature/AmazingFeature`)
6. Open a Pull Request

## License

This configuration is released into the public domain. Use it however you like.

## Author

**Zlatan Omerovic**
- GitHub: [@ZlatanOmerovic](https://github.com/ZlatanOmerovic)
- Repository: [nanorc](https://github.com/ZlatanOmerovic/nanorc)
