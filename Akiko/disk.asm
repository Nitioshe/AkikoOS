; Contrôleur de disque AKIKO OS
[BITS 16]

; Constantes AKIKO
%define AKIKO_DISK_RETRIES 3
%define AKIKO_SECTOR_SIZE 512

; Variables AKIKO
akiko_disk_error_count db 0

; Initialiser le contrôleur de disque AKIKO
akiko_disk_init:
    push ax
    push dx
    mov ah, 0x00
    mov dl, [bpb_drive_num]
    int 0x13
    jc .error
    pop dx
    pop ax
    ret
.error:
    mov si, akiko_disk_init_error
    call akiko_print_string
    jmp akiko_disk_fatal_error

; Lire des secteurs AKIKO
; AL = nombre de secteurs, CH = cylindre, CL = secteur
; DH = tête, DL = lecteur, ES:BX = buffer
akiko_disk_read:
    pusha
    mov byte [akiko_disk_error_count], 0
    
.retry:
    mov ah, 0x02
    int 0x13
    jnc .success
    
    ; Erreur - réessayer
    inc byte [akiko_disk_error_count]
    cmp byte [akiko_disk_error_count], AKIKO_DISK_RETRIES
    jge .error
    
    ; Reset du disque
    push ax
    mov ah, 0x00
    int 0x13
    pop ax
    jmp .retry

.success:
    popa
    ret

.error:
    mov si, akiko_disk_read_error
    call akiko_print_string
    jmp akiko_disk_fatal_error

; Écrire des secteurs AKIKO
; AL = nombre de secteurs, CH = cylindre, CL = secteur  
; DH = tête, DL = lecteur, ES:BX = buffer
akiko_disk_write:
    pusha
    mov byte [akiko_disk_error_count], 0
    
.retry:
    mov ah, 0x03
    int 0x13
    jnc .success
    
    ; Erreur - réessayer
    inc byte [akiko_disk_error_count]
    cmp byte [akiko_disk_error_count], AKIKO_DISK_RETRIES
    jge .error
    
    ; Reset du disque
    push ax
    mov ah, 0x00
    int 0x13
    pop ax
    jmp .retry

.success:
    popa
    ret

.error:
    mov si, akiko_disk_write_error
    call akiko_print_string
    jmp akiko_disk_fatal_error

; Obtenir les paramètres du disque AKIKO
; Retourne: CH = cylindres, CL = secteurs/piste, DH = têtes
akiko_disk_get_params:
    push ax
    mov ah, 0x08
    mov dl, [bpb_drive_num]
    int 0x13
    jc .error
    pop ax
    ret

.error:
    mov si, akiko_disk_params_error
    call akiko_print_string
    jmp akiko_disk_fatal_error

; Erreur fatale du disque AKIKO
akiko_disk_fatal_error:
    mov si, akiko_disk_fatal_msg
    call akiko_print_string
    cli
    hlt

; Messages d'erreur AKIKO
akiko_disk_init_error    db "AKIKO: Erreur init disque", 0
akiko_disk_read_error    db "AKIKO: Erreur lecture", 0  
akiko_disk_write_error   db "AKIKO: Erreur ecriture", 0
akiko_disk_params_error  db "AKIKO: Erreur parametres", 0
akiko_disk_fatal_msg     db "AKIKO: Erreur disque fatale", 0

; Fonction d'affichage pour le bootloader
akiko_print_string:
    mov ah, 0x0E
.loop:
    lodsb
    test al, al
    jz .done
    int 0x10
    jmp .loop
.done:
    ret