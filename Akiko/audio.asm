; audio.asm - Gestion audio AKIKO OS
[BITS 32]

global akiko_beep
global akiko_silence

akiko_beep:
    push ebp
    mov ebp, esp
    push eax
    push ebx
    
    ; Récupérer le paramètre frequency
    mov ebx, [ebp + 8]
    
    ; Calculer divisor = 1193180 / frequency
    mov eax, 1193180
    xor edx, edx
    div ebx
    
    ; Programmer le PIT
    mov al, 0xB6
    out 0x43, al
    
    ; Envoyer low byte
    mov al, al
    out 0x42, al
    
    ; Envoyer high byte
    mov al, ah
    out 0x42, al
    
    ; Activer le speaker
    in al, 0x61
    or al, 0x03
    out 0x61, al
    
    pop ebx
    pop eax
    pop ebp
    ret

akiko_silence:
    push eax
    in al, 0x61
    and al, 0xFC
    out 0x61, al
    pop eax
    ret