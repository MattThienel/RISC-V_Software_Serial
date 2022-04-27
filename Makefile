ASM=riscv64-linux-gnu-as
OBJ_COPY=riscv64-linux-gnu-objcopy
LD=riscv64-linux-gnu-ld

PROJECT=serial
ELF=$(PROJECT).elf
HEX=$(PROJECT).hex

LINKER_FILE=linker.ld

BUILD_DIR=build

ASSEMBLY_FILES=$(wildcard src/*.S)
ASSEMBLY_OBJS=$(addprefix $(BUILD_DIR)/obj/,$(notdir $(ASSEMBLY_FILES:.S=.o)))

ASSEMBLER_OPTIONS=-march=rv32imac -mabi=ilp32

LDFLAGS=-m elf32lriscv -nostdlib -nostartfiles

all: clean $(BUILD_DIR)/$(ELF) hex

$(BUILD_DIR)/obj/%.o: src/%.S | obj
	$(ASM) $(ASSEMBLER_OPTIONS) -c $< -o $@

$(BUILD_DIR)/$(ELF): $(ASSEMBLY_OBJS) | build
	$(LD) $(ASSEMBLY_OBJS) $(LDFLAGS) -e _start -T $(LINKER_FILE) -o $@

obj:
	@mkdir -p $(BUILD_DIR)/obj

build:
	@mkdir -p $(BUILD_DIR)

clean:
	@rm -rf $(BUILD_DIR)

hex:
	$(OBJ_COPY) -O ihex $(BUILD_DIR)/$(ELF) $(BUILD_DIR)/$(HEX)

