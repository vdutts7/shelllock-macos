# shelllock - Touch ID gated shell commands for macOS

BINARY = shelllock
SOURCES = Sources/shelllock.swift
BUILD_DIR = bin

# Build universal binary (Intel + Apple Silicon)
.PHONY: build
build:
	@echo "Building $(BINARY)..."
	@mkdir -p $(BUILD_DIR)
	swiftc -O -target arm64-apple-macos11 -o $(BUILD_DIR)/$(BINARY)-arm64 $(SOURCES)
	swiftc -O -target x86_64-apple-macos11 -o $(BUILD_DIR)/$(BINARY)-x86_64 $(SOURCES)
	lipo -create -output $(BUILD_DIR)/$(BINARY) $(BUILD_DIR)/$(BINARY)-arm64 $(BUILD_DIR)/$(BINARY)-x86_64
	@rm -f $(BUILD_DIR)/$(BINARY)-arm64 $(BUILD_DIR)/$(BINARY)-x86_64
	@echo "Built: $(BUILD_DIR)/$(BINARY)"

# Build for current architecture only (faster)
.PHONY: build-fast
build-fast:
	@mkdir -p $(BUILD_DIR)
	swiftc -O -o $(BUILD_DIR)/$(BINARY) $(SOURCES)

# Install to /usr/local/bin
.PHONY: install
install: build
	@echo "Installing to /usr/local/bin/$(BINARY)..."
	@sudo cp $(BUILD_DIR)/$(BINARY) /usr/local/bin/$(BINARY)
	@sudo chmod +x /usr/local/bin/$(BINARY)
	@echo "Installed. Run: shelllock --help"

# Install without sudo (to ~/.local/bin)
.PHONY: install-user
install-user: build
	@mkdir -p ~/.local/bin
	@cp $(BUILD_DIR)/$(BINARY) ~/.local/bin/$(BINARY)
	@chmod +x ~/.local/bin/$(BINARY)
	@echo "Installed to ~/.local/bin/$(BINARY)"
	@echo "Make sure ~/.local/bin is in your PATH"

# Uninstall
.PHONY: uninstall
uninstall:
	@sudo rm -f /usr/local/bin/$(BINARY)
	@rm -f ~/.local/bin/$(BINARY)
	@echo "Uninstalled"

# Clean build artifacts
.PHONY: clean
clean:
	@rm -rf $(BUILD_DIR)
	@echo "Cleaned"

# Run tests
.PHONY: test
test: build
	@echo "Testing..."
	@$(BUILD_DIR)/$(BINARY) --version
	@$(BUILD_DIR)/$(BINARY) --help
	@echo "Basic tests passed"
