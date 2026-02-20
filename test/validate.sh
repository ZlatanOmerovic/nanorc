#!/bin/sh
# ==============================================================================
# validate.sh — Non-interactive validation of a nano configuration file
# ==============================================================================
# Usage: validate.sh <path-to-nanorc>
#
# Tests:
#   1. Config file exists and is readable
#   2. Nano starts without configuration errors
#   3. Backup directory is functional
#   4. Syntax highlighting files are loadable
# ==============================================================================

set -e

CONFIG="$1"
PASS=0
FAIL=0
TEMPLATE_NAME=$(basename "$CONFIG" .nanorc)
NANO_VERSION=$(nano --version | head -1 | sed 's/.*version //' | sed 's/ .*//')

log_pass() {
    PASS=$((PASS + 1))
    printf "  \033[32mPASS\033[0m  %s\n" "$1"
}

log_fail() {
    FAIL=$((FAIL + 1))
    printf "  \033[31mFAIL\033[0m  %s\n" "$1"
}

printf "\n\033[1m[%s] nano %s\033[0m\n" "$TEMPLATE_NAME" "$NANO_VERSION"
printf "%s\n" "--------------------------------------------"

# --------------------------------------------------------------------------
# Test 1: Config file exists and is readable
# --------------------------------------------------------------------------
if [ -r "$CONFIG" ]; then
    log_pass "Config file is readable"
else
    log_fail "Config file is not readable: $CONFIG"
    printf "\nResults: %d passed, %d failed\n" "$PASS" "$FAIL"
    exit 1
fi

# --------------------------------------------------------------------------
# Test 2: Nano starts without configuration errors
# --------------------------------------------------------------------------
# nano prints config errors to stderr before entering interactive mode.
# We use `script` to provide a pseudo-terminal and `timeout` to exit.
ERROR_LOG=$(mktemp)
touch /tmp/validate_test_file.txt

# Use script to provide a TTY, send 'q' via stdin to quit, capture stderr
script -qc "TERM=xterm timeout 2 nano --rcfile=$CONFIG /tmp/validate_test_file.txt 2>$ERROR_LOG || true" /dev/null < /dev/null > /dev/null 2>&1 || true

# Check for error patterns in the error log
if [ -s "$ERROR_LOG" ] && grep -qi "error\|unknown option\|invalid" "$ERROR_LOG" 2>/dev/null; then
    log_fail "Config has errors:"
    sed 's/^/         /' "$ERROR_LOG"
else
    log_pass "No configuration errors"
fi
rm -f "$ERROR_LOG"

# --------------------------------------------------------------------------
# Test 3: Backup directory is functional
# --------------------------------------------------------------------------
if grep -q 'set backup' "$CONFIG" 2>/dev/null; then
    BACKUP_DIR=$(grep 'set backupdir' "$CONFIG" 2>/dev/null | sed 's/.*"\(.*\)".*/\1/' | sed "s|~|$HOME|")
    if [ -n "$BACKUP_DIR" ]; then
        # Ensure directory exists
        mkdir -p "$BACKUP_DIR" 2>/dev/null
        if [ -d "$BACKUP_DIR" ] && [ -w "$BACKUP_DIR" ]; then
            log_pass "Backup directory is writable: $BACKUP_DIR"
        else
            log_fail "Backup directory not writable: $BACKUP_DIR"
        fi
    else
        log_pass "Backup enabled (using default directory)"
    fi
else
    log_pass "Backup not configured (skipped)"
fi

# --------------------------------------------------------------------------
# Test 4: Syntax highlighting files are loadable
# --------------------------------------------------------------------------
if grep -q 'include /usr/share/nano' "$CONFIG" 2>/dev/null; then
    NANO_SYNTAX_COUNT=$(ls /usr/share/nano/*.nanorc 2>/dev/null | wc -l)
    if [ "$NANO_SYNTAX_COUNT" -gt 0 ]; then
        log_pass "Syntax highlighting: $NANO_SYNTAX_COUNT definitions found"
    else
        log_fail "No syntax highlighting files found in /usr/share/nano/"
    fi
else
    log_pass "No syntax includes configured (skipped)"
fi

# --------------------------------------------------------------------------
# Test 5: All 'set' directives use recognized option names
# --------------------------------------------------------------------------
KNOWN_OPTS="afterends|allow_insecure_backup|atblanks|autoindent|backup|backupdir|boldtext|bookstyle|brackets|breaklonglines|casesensitive|constantshow|cutfromcursor|emptyline|errorcolor|fill|functioncolor|guidestripe|historylog|indicator|jumpyscrolling|keycolor|linenumbers|locking|magic|matchbrackets|minibar|minicolor|mouse|multibuffer|noconvert|nohelp|nonewlines|nowrap|numbercolor|operatingdir|positionlog|preserve|promptcolor|punct|quickblank|quotestr|rawsequences|rebinddelete|regexp|saveonexit|scrollercolor|selectedcolor|showcursor|smarthome|softwrap|speller|spotlightcolor|stateflags|statuscolor|stripecolor|tabsize|tabstospaces|titlecolor|trimblanks|unix|whitespace|wordbounds|wordchars|zap|zero"

BAD_OPTS=""
while IFS= read -r line; do
    opt=$(echo "$line" | sed 's/^set[[:space:]]*//' | sed 's/[[:space:]].*//')
    if ! echo "$opt" | grep -qE "^($KNOWN_OPTS)$"; then
        BAD_OPTS="$BAD_OPTS $opt"
    fi
done <<EOF
$(grep '^set ' "$CONFIG" 2>/dev/null)
EOF

if [ -z "$BAD_OPTS" ]; then
    log_pass "All set directives use recognized option names"
else
    log_fail "Unknown options:$BAD_OPTS"
fi

# --------------------------------------------------------------------------
# Test 6: All 'bind'/'unbind' directives use recognized function names
# --------------------------------------------------------------------------
KNOWN_FUNCS="cancel|help|exit|writeout|savefile|insert|whereis|wherewas|findprevious|findnext|replace|cut|copy|paste|zap|chopwordleft|chopwordright|cutrestoffile|mark|wordcount|execute|spell|speller|formatter|linter|justify|fulljustify|indent|unindent|comment|complete|gotoline|findbracket|pageup|pagedown|firstline|lastline|scrollup|scrolldown|prevword|nextword|home|end|up|down|left|right|center|toprow|bottomrow|prevblock|nextblock|prevbuf|nextbuf|firstfile|lastfile|anchor|prevanchor|nextanchor|toggles|location|refresh|undo|redo|suspend|backspace|delete|enter|tab|verbatim|nohelp|constantshow|softwrap|linenumbers|whitespacedisplay|nosyntax|smarthome|autoindent|cutfromcursor|breaklonglines|mouse|tabstospaces|recordmacro|runmacro|flipreplace|flipgoto|flippipe|flipconvert|flipexecute|flipnewbuffer|flipbrowser|discardbuffer|browser|gotodir|whereisfile|dosformat|macformat|append|prepend|backup|casesens|regexp|backwards|older|newer|search|replacewith|yesno|beginpara|endpara|zero"

BAD_BINDS=""
# Only check 'bind' lines (not 'unbind' — unbind has no function field)
while IFS= read -r line; do
    [ -z "$line" ] && continue
    # Extract function name: bind <key> <function> <menu>
    func=$(echo "$line" | sed 's/^[[:space:]]*bind[[:space:]]*[^[:space:]]*//' | sed 's/^[[:space:]]*//' | sed 's/[[:space:]].*//')
    # Skip if it's a string binding (starts with quote) or empty
    case "$func" in
        \"*|"") continue ;;
    esac
    if ! echo "$func" | grep -qE "^($KNOWN_FUNCS)$"; then
        BAD_BINDS="$BAD_BINDS $func"
    fi
done <<EOF
$(grep -E '^bind ' "$CONFIG" 2>/dev/null)
EOF

# Validate unbind lines: unbind <key> <menu> — check menu names
KNOWN_MENUS="main|search|replace|replacewith|yesno|gotoline|writeout|insert|browser|whereisfile|gotodir|execute|spell|linter|all"
BAD_UNBINDS=""
while IFS= read -r line; do
    [ -z "$line" ] && continue
    # Extract menu: unbind <key> <menu>
    menu=$(echo "$line" | sed 's/^[[:space:]]*unbind[[:space:]]*[^[:space:]]*//' | sed 's/^[[:space:]]*//' | sed 's/[[:space:]].*//')
    if [ -n "$menu" ] && ! echo "$menu" | grep -qE "^($KNOWN_MENUS)$"; then
        BAD_UNBINDS="$BAD_UNBINDS $menu"
    fi
done <<EOF
$(grep -E '^unbind ' "$CONFIG" 2>/dev/null)
EOF

if [ -n "$BAD_BINDS" ]; then
    BAD_BINDS="$BAD_BINDS$BAD_UNBINDS"
elif [ -n "$BAD_UNBINDS" ]; then
    BAD_BINDS="$BAD_UNBINDS"
fi

if [ -z "$BAD_BINDS" ]; then
    BIND_COUNT=$(grep -cE '^(bind|unbind) ' "$CONFIG" 2>/dev/null || true)
    BIND_COUNT="${BIND_COUNT:-0}"
    if [ "$BIND_COUNT" -gt 0 ]; then
        log_pass "All bind/unbind directives valid ($BIND_COUNT bindings)"
    else
        log_pass "No bind/unbind directives (skipped)"
    fi
else
    log_fail "Unknown bind functions:$BAD_BINDS"
fi

# --------------------------------------------------------------------------
# Summary
# --------------------------------------------------------------------------
TOTAL=$((PASS + FAIL))
printf "%s\n" "--------------------------------------------"
if [ "$FAIL" -eq 0 ]; then
    printf "\033[32m  All %d tests passed\033[0m\n\n" "$TOTAL"
    exit 0
else
    printf "\033[31m  %d/%d tests failed\033[0m\n\n" "$FAIL" "$TOTAL"
    exit 1
fi
