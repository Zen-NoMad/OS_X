# =============================================================================
# Makefile - OS_X (64-bit kernel project)
# =============================================================================

# Tools
NASM           := nasm
CXX            := x86_64-elf-g++
LD             := x86_64-elf-ld
GRUB_MKRESCUE  := grub-mkrescue
QEMU           := qemu-system-x86_64

# Flags
NASMFLAGS      := -f elf64
CXXFLAGS       := -ffreestanding -m64 -mcmodel=kernel -mno-red-zone -mno-mmx -mno-sse \
                  -fno-stack-protector -fno-exceptions -fno-rtti -Wall -Wextra -O2 \
                  -I src/include

LDFLAGS = -T src/linker.ld -nostdlib -static --no-dynamic-linker -z max-page-size=0x1000

QEMU_FLAGS     := -serial stdio \
                  -m 512M \
                  -no-reboot \
                  -machine q35 \
                  -cpu qemu64 \
                  -d guest_errors,int,cpu_reset

# Directories and targets
SRC_DIR        := src
BUILD_DIR      := build
ISO_DIR        := iso
KERNEL         := $(BUILD_DIR)/kernel.bin
ISO            := myos.iso

# Find all source files
CPP_SOURCES    := $(shell find $(SRC_DIR)/kernel -name '*.cpp')
CPP_OBJECTS    := $(patsubst $(SRC_DIR)/%.cpp,$(BUILD_DIR)/%.o,$(CPP_SOURCES))

BOOT_OBJ       := $(BUILD_DIR)/boot/boot.o
OBJECTS        := $(BOOT_OBJ) $(CPP_OBJECTS)

# =============================================================================
# Main targets
# =============================================================================

.PHONY: all iso run debug clean help

all: iso

iso: $(ISO)

$(ISO): $(KERNEL) $(ISO_DIR)/boot/grub/grub.cfg
	@mkdir -p $(ISO_DIR)/boot/grub
	cp $(KERNEL) $(ISO_DIR)/boot/kernel.bin
	@echo "Creating bootable ISO..."
	$(GRUB_MKRESCUE) -o $@ $(ISO_DIR) 2>/dev/null || { echo "ERROR: grub-mkrescue failed! Check grub.cfg or directory structure."; exit 1; }

$(KERNEL): $(OBJECTS) src/linker.ld
	@echo "Linking kernel..."
	$(LD) $(LDFLAGS) -o $@ $(OBJECTS)

# Assemble boot.asm
$(BOOT_OBJ): src/boot/boot.asm
	@mkdir -p $(@D)
	$(NASM) $(NASMFLAGS) $< -o $@

# Compile all .cpp files (preserves directory structure)
$(BUILD_DIR)/%.o: $(SRC_DIR)/%.cpp
	@mkdir -p $(@D)
	$(CXX) $(CXXFLAGS) -c $< -o $@

# =============================================================================
# Run targets
# =============================================================================

run: $(ISO)
	@echo "Starting QEMU..."
	@ls
	$(QEMU) -cdrom $(ISO) $(QEMU_FLAGS)

debug: $(ISO)
	@echo "Starting QEMU in debug mode (GDB server on tcp::1234)"
	$(QEMU) $(QEMU_FLAGS) -s -S

# =============================================================================
# Clean
# =============================================================================

clean:
	rm -rf $(BUILD_DIR) $(ISO)
	@echo "Cleaned."

# =============================================================================
# Help
# =============================================================================

help:
	@echo "Available commands:"
	@echo "  make          → build + create ISO"
	@echo "  make iso      → create ISO only"
	@echo "  make run      → run in QEMU"
	@echo "  make debug    → run in QEMU with GDB support"
	@echo "  make clean    → remove build files and ISO"
	@echo "  make help     → show this message"