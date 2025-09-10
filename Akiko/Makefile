# AKIKO OS Makefile
CC = gcc
CFLAGS = -m32 -nostdlib -nostdinc -fno-builtin -fno-stack-protector -Wall -Wextra -ffreestanding -DAKIKO_OS
ASM = nasm
ASMFLAGS = -f elf32
LD = ld
LDFLAGS = -m elf_i386 -T link.ld -nostdlib

# Fichiers sources AKIKO
KERNEL_SRC = kernel.c memory.c
KERNEL_ASM = isr.asm gdt.asm
BOOT_SRC = boot.asm

# Fichiers objets AKIKO
OBJS = $(KERNEL_SRC:.c=.o) $(KERNEL_ASM:.asm=.o)

# Cibles AKIKO
all: akiko-image

# Ajouter audio.o aux objets
OBJS = $(KERNEL_SRC:.c=.o) $(KERNEL_ASM:.asm=.o) audio.o

# Règle pour audio.asm
audio.o: audio.asm
	$(ASM) $(ASMFLAGS) $< -o $@

# Bootloader AKIKO
bootsect.bin: $(BOOT_SRC)
	$(ASM) -f bin $< -o $@

# Noyau AKIKO
kernel.bin: $(OBJS)
	$(LD) $(LDFLAGS) -o $@ $^
	@echo "Taille du noyau AKIKO:" $$(wc -c < kernel.bin) "octets"

# Image AKIKO complete
akiko-image: bootsect.bin kernel.bin
	cat $^ > akiko-os.img
	@echo "Image AKIKO OS creee: akiko-os.img"
	@echo "Taille totale:" $$(wc -c < akiko-os.img) "octets"

# Regles de compilation
%.o: %.c
	$(CC) $(CFLAGS) -c $< -o $@

%.o: %.asm
	$(ASM) $(ASMFLAGS) $< -o $@

# Nettoyage AKIKO
clean:
	rm -f *.bin *.o *.img akiko-os.img

# Emulation AKIKO
run: akiko-image
	qemu-system-i386 -fda akiko-os.img -m 2M -cpu 486 -name "AKIKO OS"

# Debug AKIKO
debug: akiko-image
	qemu-system-i386 -fda akiko-os.img -m 2M -s -S -monitor stdio
	
#Test avec interface graphique
run-vga: akiko-image
	qemu-system-i386 -fda akiko-os.img -m 2M -vga std

# Verification
check:
	@echo "=== Verification AKIKO OS ==="
	@file bootsect.bin || echo "Bootloader manquant"
	@file kernel.bin || echo "Noyau manquant"
	@test -f akiko-os.img && echo "Image AKIKO presente" || echo "Image manquante"

.PHONY: all clean run debug check