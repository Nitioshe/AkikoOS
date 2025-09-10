; Gestionnaire d'interruptions AKIKO OS
[BITS 32]

; Définitions AKIKO
%define AKIKO_ISR_COUNT 32

section .text

; Table des gestionnaires d'interruptions AKIKO
global akiko_isr_table
akiko_isr_table:
    dd akiko_isr0, akiko_isr1, akiko_isr2, akiko_isr3
    dd akiko_isr4, akiko_isr5, akiko_isr6, akiko_isr7
    dd akiko_isr8, akiko_isr9, akiko_isr10, akiko_isr11
    dd akiko_isr12, akiko_isr13, akiko_isr14, akiko_isr15
    dd akiko_isr16, akiko_isr17, akiko_isr18, akiko_isr19
    dd akiko_isr20, akiko_isr21, akiko_isr22, akiko_isr23
    dd akiko_isr24, akiko_isr25, akiko_isr26, akiko_isr27
    dd akiko_isr28, akiko_isr29, akiko_isr30, akiko_isr31

; Messages d'erreur AKIKO
akiko_isr_messages:
    dd akiko_isr0_msg, akiko_isr1_msg, akiko_isr2_msg, akiko_isr3_msg
    dd akiko_isr4_msg, akiko_isr5_msg, akiko_isr6_msg, akiko_isr7_msg
    dd akiko_isr8_msg, akiko_isr9_msg, akiko_isr10_msg, akiko_isr11_msg
    dd akiko_isr12_msg, akiko_isr13_msg, akiko_isr14_msg, akiko_isr15_msg
    dd akiko_isr16_msg, akiko_isr17_msg, akiko_isr18_msg, akiko_isr19_msg
    dd akiko_isr20_msg, akiko_isr21_msg, akiko_isr22_msg, akiko_isr23_msg
    dd akiko_isr24_msg, akiko_isr25_msg, akiko_isr26_msg, akiko_isr27_msg
    dd akiko_isr28_msg, akiko_isr29_msg, akiko_isr30_msg, akiko_isr31_msg

extern akiko_isr_handler

; Gestionnaires d'interruptions AKIKO
akiko_isr0:  ; Division par zéro
    push byte 0
    push byte 0
    jmp akiko_isr_common

akiko_isr1:  ; Débogage
    push byte 0
    push byte 1
    jmp akiko_isr_common

akiko_isr2:  ; Interruption non masquable
    push byte 0
    push byte 2
    jmp akiko_isr_common

akiko_isr3:  ; Point d'arrêt
    push byte 0
    push byte 3
    jmp akiko_isr_common

akiko_isr4:  ; Dépassement
    push byte 0
    push byte 4
    jmp akiko_isr_common

akiko_isr5:  ; Borne
    push byte 0
    push byte 5
    jmp akiko_isr_common

akiko_isr6:  ; Opcode invalide
    push byte 0
    push byte 6
    jmp akiko_isr_common

akiko_isr7:  ; Coprocesseur non disponible
    push byte 0
    push byte 7
    jmp akiko_isr_common

akiko_isr8:  ; Double faute
    push byte 8
    jmp akiko_isr_common

akiko_isr9:  ; Coprocesseur segment overrun
    push byte 0
    push byte 9
    jmp akiko_isr_common

akiko_isr10: ; TSS invalide
    push byte 10
    jmp akiko_isr_common

akiko_isr11: ; Segment non présent
    push byte 11
    jmp akiko_isr_common

akiko_isr12: ; Erreur de pile
    push byte 12
    jmp akiko_isr_common

akiko_isr13: ; Protection générale
    push byte 13
    jmp akiko_isr_common

akiko_isr14: ; Page fault
    push byte 14
    jmp akiko_isr_common

akiko_isr15: ; Réservé
    push byte 0
    push byte 15
    jmp akiko_isr_common

akiko_isr16: ; Erreur mathématique
    push byte 0
    push byte 16
    jmp akiko_isr_common

; Interruptions 17-31 (réservées)
akiko_isr17:
    push byte 0
    push byte 17
    jmp akiko_isr_common

akiko_isr18:
    push byte 0
    push byte 18
    jmp akiko_isr_common

akiko_isr19:
    push byte 0
    push byte 19
    jmp akiko_isr_common

akiko_isr20:
    push byte 0
    push byte 20
    jmp akiko_isr_common

akiko_isr21:
    push byte 0
    push byte 21
    jmp akiko_isr_common

akiko_isr22:
    push byte 0
    push byte 22
    jmp akiko_isr_common

akiko_isr23:
    push byte 0
    push byte 23
    jmp akiko_isr_common

akiko_isr24:
    push byte 0
    push byte 24
    jmp akiko_isr_common

akiko_isr25:
    push byte 0
    push byte 25
    jmp akiko_isr_common

akiko_isr26:
    push byte 0
    push byte 26
    jmp akiko_isr_common

akiko_isr27:
    push byte 0
    push byte 27
    jmp akiko_isr_common

akiko_isr28:
    push byte 0
    push byte 28
    jmp akiko_isr_common

akiko_isr29:
    push byte 0
    push byte 29
    jmp akiko_isr_common

akiko_isr30:
    push byte 0
    push byte 30
    jmp akiko_isr_common

akiko_isr31:
    push byte 0
    push byte 31
    jmp akiko_isr_common

; Gestionnaire commun AKIKO
akiko_isr_common:
    pusha
    push ds
    push es
    push fs
    push gs
    
    mov ax, 0x10
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    
    mov eax, esp
    push eax
    
    extern akiko_isr_handler
    call akiko_isr_handler
    
    pop eax
    pop gs
    pop fs
    pop es
    pop ds
    popa
    
    add esp, 8
    iret

; Handler par défaut AKIKO
global akiko_isr_handler_default
akiko_isr_handler_default:
    ; Afficher un message d'erreur
    pusha
    mov esi, akiko_isr_default_msg
    call akiko_isr_print_message
    popa
    ret

; Fonction d'affichage pour ISR
akiko_isr_print_message:
    ; Cette fonction serait implémentée en C
    ret

; Messages d'erreur AKIKO
akiko_isr0_msg db "AKIKO: Division par zero", 0
akiko_isr1_msg db "AKIKO: Debug", 0
akiko_isr2_msg db "AKIKO: NMI", 0
akiko_isr3_msg db "AKIKO: Breakpoint", 0
akiko_isr4_msg db "AKIKO: Overflow", 0
akiko_isr5_msg db "AKIKO: Bound Range", 0
akiko_isr6_msg db "AKIKO: Opcode invalide", 0
akiko_isr7_msg db "AKIKO: Coprocesseur absent", 0
akiko_isr8_msg db "AKIKO: Double faute", 0
akiko_isr9_msg db "AKIKO: Coprocesseur segment", 0
akiko_isr10_msg db "AKIKO: TSS invalide", 0
akiko_isr11_msg db "AKIKO: Segment absent", 0
akiko_isr12_msg db "AKIKO: Erreur pile", 0
akiko_isr13_msg db "AKIKO: Protection generale", 0
akiko_isr14_msg db "AKIKO: Page fault", 0
akiko_isr15_msg db "AKIKO: Reserve", 0
akiko_isr16_msg db "AKIKO: Erreur math", 0
akiko_isr17_msg db "AKIKO: Interruption 17", 0
akiko_isr18_msg db "AKIKO: Interruption 18", 0
akiko_isr19_msg db "AKIKO: Interruption 19", 0
akiko_isr20_msg db "AKIKO: Interruption 20", 0
akiko_isr21_msg db "AKIKO: Interruption 21", 0
akiko_isr22_msg db "AKIKO: Interruption 22", 0
akiko_isr23_msg db "AKIKO: Interruption 23", 0
akiko_isr24_msg db "AKIKO: Interruption 24", 0
akiko_isr25_msg db "AKIKO: Interruption 25", 0
akiko_isr26_msg db "AKIKO: Interruption 26", 0
akiko_isr27_msg db "AKIKO: Interruption 27", 0
akiko_isr28_msg db "AKIKO: Interruption 28", 0
akiko_isr29_msg db "AKIKO: Interruption 29", 0
akiko_isr30_msg db "AKIKO: Interruption 30", 0
akiko_isr31_msg db "AKIKO: Interruption 31", 0
akiko_isr_default_msg db "AKIKO: Interruption inconnue", 0

; Initialiser les ISR AKIKO
global akiko_isr_init
akiko_isr_init:
    ; Cette fonction initialiserait l'IDT
    ; Pour l'instant, c'est un stub
    ret