; Bootloader AKIKO OS
[BITS 16]
[ORG 0x7C00]

%define KERNEL_OFFSET 0x1000
%define KERNEL_SECTORS 32

jmp start
nop

; BPB pour AKIKO OS
bpb_oem:            db "AKIKO OS"
bpb_bytes_per_sect: dw 512
bpb_sect_per_clust: db 1
bpb_reserved_sects: dw 1
bpb_num_fats:       db 2
bpb_root_entries:   dw 224
bpb_total_sects:    dw 2880
bpb_media:          db 0xF0
bpb_sect_per_fat:   dw 9
bpb_sect_per_track: dw 18
bpb_num_heads:      dw 2
bpb_hidden_sects:   dd 0
bpb_drive_num:      db 0
bpb_reserved:       db 0
bpb_signature:      db 0x29
bpb_volume_id:      dd 0x12345678    ; Correction: valeur hexa valide
bpb_volume_label:   db "AKIKO OS  "
bpb_file_system:    db "FAT12   "

start:
    cli
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7C00
    sti
    
    mov [bpb_drive_num], dl
    
    ; Afficher message de démarrage AKIKO
    mov si, msg_welcome
    call print_string
    
    ; Charger le noyau AKIKO
    mov bx, KERNEL_OFFSET
    mov ah, 0x02
    mov al, KERNEL_SECTORS
    mov ch, 0
    mov cl, 2
    mov dh, 0
    mov dl, [bpb_drive_num]
    int 0x13
    jc disk_error
    
    ; Vérifier signature AKIKO (vérification simplifiée)
    cmp dword [KERNEL_OFFSET], 0x4B494B41  ; "AKIK"
    jne kernel_error

    
    ; Passer en mode protégé
    cli
    lgdt [gdt_descriptor]
    mov eax, cr0
    or eax, 1
    mov cr0, eax
    jmp 0x08:pm_start

[BITS 32]
pm_start:
    mov ax, 0x10
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax
    mov esp, 0x90000
    
    ; Appeler le noyau AKIKO
    jmp KERNEL_OFFSET + 4

[BITS 16]
print_string:
    mov ah, 0x0E
    mov bh, 0
.print_loop:
    lodsb
    test al, al
    jz .done
    int 0x10
    jmp .print_loop
.done:
    ret

disk_error:
    mov si, msg_disk_error
    call print_string
    jmp $

kernel_error:
    mov si, msg_kernel_error
    call print_string
    jmp $

; GDT AKIKO OS
gdt_start:
    dq 0x0000000000000000    ; Null descriptor
    dq 0x00CF9A000000FFFF    ; Code segment
    dq 0x00CF92000000FFFF    ; Data segment
gdt_end:

gdt_descriptor:
    dw gdt_end - gdt_start - 1
    dd gdt_start

; Messages AKIKO
msg_welcome      db "AKIKO OS Bootloader v1.0", 13, 10
                 db "Chargement du noyau...", 13, 10, 0
msg_disk_error   db "Erreur disque!", 0
msg_kernel_error db "Signature noyau invalide!", 0

; Signature AKIKO
times 510-($-$$) db 0
dw 0xAA55