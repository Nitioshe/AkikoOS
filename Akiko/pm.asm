; Gestionnaire mode protégé AKIKO OS
[BITS 16]

section .text
global akiko_switch_to_pm

; Passer en mode protégé AKIKO
akiko_switch_to_pm:
    cli
    
    ; Charger la GDT AKIKO
    call akiko_gdt_load
    
    ; Activer le mode protégé
    mov eax, cr0
    or eax, 0x1
    mov cr0, eax
    
    ; Saut far pour vider le pipeline
    jmp 0x08:akiko_pm_entry

[BITS 32]

; Point d'entrée mode protégé AKIKO
akiko_pm_entry:
    ; Configurer les segments de données
    mov ax, 0x10
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax
    
    ; Configurer la pile
    mov ebp, 0x90000
    mov esp, ebp
    
    ; Initialiser les interruptions
    call akiko_pm_init_interrupts
    
    ; Appeler le noyau AKIKO
    jmp 0x1000

; Initialiser les interruptions en mode protégé AKIKO
akiko_pm_init_interrupts:
    ; Désactiver les interruptions PIC
    mov al, 0xFF
    out 0xA1, al
    out 0x21, al
    
    ; Configurer le PIC
    mov al, 0x11
    out 0x20, al
    out 0xA0, al
    
    mov al, 0x20
    out 0x21, al
    mov al, 0x28
    out 0xA1, al
    
    mov al, 0x04
    out 0x21, al
    mov al, 0x02
    out 0xA1, al
    
    mov al, 0x01
    out 0x21, al
    out 0xA1, al
    
    ; Activer les interruptions
    sti
    ret

; Fonctions utilitaires mode protégé AKIKO

; Lire un octet d'un port
global akiko_inb
akiko_inb:
    mov edx, [esp + 4]
    in al, dx
    ret

; Écrire un octet vers un port
global akiko_outb
akiko_outb:
    mov edx, [esp + 4]
    mov al, [esp + 8]
    out dx, al
    ret

; Lire un mot d'un port
global akiko_inw
akiko_inw:
    mov edx, [esp + 4]
    in ax, dx
    ret

; Écrire un mot vers un port
global akiko_outw
akiko_outw:
    mov edx, [esp + 4]
    mov ax, [esp + 8]
    out dx, ax
    ret

; Activer les interruptions
global akiko_enable_interrupts
akiko_enable_interrupts:
    sti
    ret

; Désactiver les interruptions
global akiko_disable_interrupts
akiko_disable_interrupts:
    cli
    ret

; Obtenir l'état des interruptions
global akiko_get_interrupts_state
akiko_get_interrupts_state:
    pushf
    pop eax
    and eax, 0x200
    ret

; Redémarrer le système AKIKO
global akiko_reboot
akiko_reboot:
    ; Essayer le reset via le clavier
    mov al, 0xFE
    out 0x64, al
    
    ; Si ça échoue, faire un triple fault
    mov eax, cr0
    and eax, 0x7FFFFFFF
    mov cr0, eax
    jmp 0xF000:0xFFF0

; Arrêter le système AKIKO
global akiko_shutdown
akiko_shutdown:
    ; Essayer l'arrêt via ACPI
    mov ax, 0x1000
    mov ax, ss
    mov sp, 0xF000
    mov ax, 0x5307
    mov bx, 0x0001
    mov cx, 0x0003
    int 0x15
    
    ; Si ça échoue, faire une boucle infinie
    cli
    hlt
    jmp $

; Message de succès mode protégé AKIKO
akiko_pm_success_msg db "AKIKO: Mode protege active", 0