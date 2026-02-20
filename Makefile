# ==============================================================================
# Makefile — Nano Configuration Test Runner
# ==============================================================================
# Usage:
#   make test                    # Run all tests (templates + keymaps)
#   make test-templates          # Test only templates
#   make test-keymaps            # Test only keymaps
#   make test-minimal            # Test only the minimal template
#   make test-development        # Test only the development template
#   make test-writing            # Test only the writing template
#   make test-beginner           # Test only the beginner template
#   make test-advanced           # Test only the advanced template
#   make test-keymap-default     # Test only the default keymap
#   make test-keymap-gui         # Test only the gui keymap
#   make test-keymap-emacs       # Test only the emacs keymap
#   make clean                   # Remove test Docker images
# ==============================================================================

SHELL := /bin/bash
TEST_SCRIPT := test/test.sh

.PHONY: test test-templates test-keymaps \
        test-minimal test-development test-writing test-beginner test-advanced \
        test-keymap-default test-keymap-gui test-keymap-emacs \
        clean

test:
	@bash $(TEST_SCRIPT)

# --- Template tests ---

test-templates:
	@for t in minimal development writing beginner advanced; do \
		bash $(TEST_SCRIPT) $$t || exit 1; \
	done

test-minimal:
	@bash $(TEST_SCRIPT) minimal

test-development:
	@bash $(TEST_SCRIPT) development

test-writing:
	@bash $(TEST_SCRIPT) writing

test-beginner:
	@bash $(TEST_SCRIPT) beginner

test-advanced:
	@bash $(TEST_SCRIPT) advanced

# --- Keymap tests ---

test-keymaps:
	@for k in default gui emacs; do \
		bash $(TEST_SCRIPT) $$k-keymap || exit 1; \
	done

test-keymap-default:
	@bash $(TEST_SCRIPT) default-keymap

test-keymap-gui:
	@bash $(TEST_SCRIPT) gui-keymap

test-keymap-emacs:
	@bash $(TEST_SCRIPT) emacs-keymap

# --- Cleanup ---

clean:
	@echo "Removing test Docker images..."
	@docker rmi -f nanorc-test:nano-5.9 nanorc-test:nano-6.2 nanorc-test:nano-7.2 nanorc-test:nano-8.0 2>/dev/null || true
	@echo "Done."
