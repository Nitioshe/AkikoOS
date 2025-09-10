/* Script de liaison AKIKO OS */
ENTRY(_start)

SECTIONS {
    /* Adresse de départ du noyau */
    . = 0x1000;
    
    /* En-tête AKIKO */
    .akiko_header : {
        /* Signature AKIKO */
        LONG(0x4B494B41);  /* 'AKIK'0x4B494B41 en hexa */
        /* Point d'entrée */
        LONG(_start);
    }

    .signature : {
        *(.signature)
    }
    
    /* Section texte */
    .text : {
        *(.text);
        *(.akiko_signature);
    }
    
    /* Données en lecture seule */
    .rodata : {
        *(.rodata);
    }
    
    /* Données initialisées */
    .data : {
        *(.data);
    }
    
    /* Données non initialisées */
    .bss : {
        *(.bss);
        *(COMMON);
    }
    
    /* Sections à ignorer */
    /DISCARD/ : {
        *(.comment);
        *(.note.*);
    }
    
    /* Symboles pour le debug */
    _kernel_end = .;
}