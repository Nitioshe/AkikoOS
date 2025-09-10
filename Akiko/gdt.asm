; Gestionnaire GDT AKIKO OS
[BITS 32]

; Définition des segments AKIKO
%define AKIKO_NULL_SEG 0x00
%define AKIKO_CODE_SEG 0x08
%define AKIKO_DATA_SEG 0x10
%define AKIKO_USER_CODE_SEG 0x18
%define AKIKO_USER_DATA_SEG 0x20

section .data
align 4

; GDT AKIKO - 5 descripteurs
akiko_gdt_start:
    ; Descripteur nul (0x00)
    dq 0x0000000000000000

    ; Segment de code noyau (0x08)
    dw 0xFFFF       ; Limit 0-15
    dw 0x0000       ; Base 0-15
    db 0x00         ; Base 16-23
    db 0x9A         ; Access: Present=1, DPL=00, Code=1, Conforming=0, Readable=1, Accessed=0
    db 0xCF         ; Granularity: Gran=1, 32-bit=1, AVL=0, Limit 16-19=1111
    db 0x00         ; Base 24-31

    ; Segment de données noyau (0x10)
    dw 0xFFFF       ; Limit 0-15
    dw 0x0000       ; Base 0-15
    db 0x00         ; Base 16-23
    db 0x92         ; Access: Present=1, DPL=00, Code=0, ExpandDown=0, Writable=1, Accessed=0
    db 0xCF         ; Granularity: Gran=1, 32-bit=1, AVL=0, Limit 16-19=1111
    db 0x00         ; Base 24-31

    ; Segment de code utilisateur (0x18)
    dw 0xFFFF       ; Limit 0-15
    dw 0x0000       ; Base 0-15
    db 0x00         ; Base 16-23
    db 0xFA         ; Access: Present=1, DPL=11, Code=1, Conforming=0, Readable=1, Accessed=0
    db 0xCF         ; Granularity: Gran=1, 32-bit=1, AVL=0, Limit 16-19=1111
    db 0x00         ; Base 24-31

    ; Segment de données utilisateur (0x20)
    dw 0xFFFF       ; Limit 0-15
    dw 0x0000       ; Base 0-15
    db 0x00         ; Base 16-23
    db 0xF2         ; Access: Present=1, DPL=11, Code=0, ExpandDown=0, Writable=1, Accessed=0
    db 0xCF         ; Granularity: Gran=1, 32-bit=1, AVL=0, Limit 16-19=1111
    db 0x00         ; Base 24-31

akiko_gdt_end:

; Descripteur GDT AKIKO
akiko_gdt_descriptor:
    dw akiko_gdt_end - akiko_gdt_start - 1
    dd akiko_gdt_start

section .text
global akiko_gdt_load
global akiko_gdt_flush

; Charger la GDT AKIKO
akiko_gdt_load:
    cli
    lgdt [akiko_gdt_descriptor]
    sti
    ret

; Recharger les segments AKIKO
akiko_gdt_flush:
    ; Recharger les segments de données
    mov ax, AKIKO_DATA_SEG
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax
    
    ; Recharger le segment de code
    jmp AKIKO_CODE_SEG:.flush
.flush:
    ret

; Configurer la GDT pour les utilisateurs
akiko_gdt_setup_user:
    ; Cette fonction serait utilisée pour créer des processus utilisateur
    ; Pour l'instant, elle retourne simplement
    ret

; Obtenir l'adresse de la GDT AKIKO
akiko_gdt_get_address:
    mov eax, akiko_gdt_start
    ret

; Obtenir la taille de la GDT AKIKO  
akiko_gdt_get_size:
    mov eax, akiko_gdt_end - akiko_gdt_start
    ret