// Signature AKIKO au début du noyau
__attribute__((section(".signature")))
const char akiko_signature[4] = { 'A', 'K', 'I', 'K' };
 // "AKIK 0x4B494B41 equivalence hexa

// AKIKO OS Kernel
#define VGA_MEMORY ((unsigned char*) 0xB8000)
#define VGA_WIDTH 80
#define VGA_HEIGHT 25

// Signature AKIKO
//#define AKIKO_SIGNATURE 0xAKIK
//#define AKIKO_SIGNATURE 0x4B49(KI) | 414B494B(AKIK)

// Couleurs AKIKO
enum akiko_color {
    AKIKO_BLACK = 0,
    AKIKO_BLUE = 1,
    AKIKO_GREEN = 2,
    AKIKO_CYAN = 3,
    AKIKO_RED = 4,
    AKIKO_MAGENTA = 5,
    AKIKO_BROWN = 6,
    AKIKO_LIGHT_GREY = 7,
    AKIKO_DARK_GREY = 8,
    AKIKO_LIGHT_BLUE = 9,
    AKIKO_LIGHT_GREEN = 10,
    AKIKO_LIGHT_CYAN = 11,
    AKIKO_LIGHT_RED = 12,
    AKIKO_LIGHT_MAGENTA = 13,
    AKIKO_LIGHT_BROWN = 14,
    AKIKO_WHITE = 15,
};

// Structure terminal AKIKO
struct akiko_terminal {
    unsigned int row;
    unsigned int column;
    unsigned char color;
    unsigned char border_color;
};

static struct akiko_terminal terminal = {0, 0, 0, 0};

// Déclarations externes
extern void akiko_init_memory(void);
extern void* akiko_kmalloc(unsigned int size);
extern void akiko_kfree(void* ptr, unsigned int size);
extern unsigned int akiko_get_memory_total(void);
extern unsigned int akiko_get_memory_used(void);

// Signature AKIKO
//__attribute__((section(".akiko_signature")))
//const unsigned int akiko_signature = AKIKO_SIGNATURE;

// Fonction couleur AKIKO
unsigned char akiko_vga_color(enum akiko_color fg, enum akiko_color bg) {
    return (unsigned char)(fg | (bg << 4));
}

// Initialiser terminal AKIKO
void akiko_terminal_init(void) {
    terminal.row = 0;
    terminal.column = 0;
    terminal.color = akiko_vga_color(AKIKO_LIGHT_GREY, AKIKO_BLACK);
    terminal.border_color = akiko_vga_color(AKIKO_BLUE, AKIKO_BLACK);
    
    // Effacer l'écran
    for (unsigned int y = 0; y < VGA_HEIGHT; y++) {
        for (unsigned int x = 0; x < VGA_WIDTH; x++) {
            const unsigned int index = y * VGA_WIDTH + x;
            VGA_MEMORY[index * 2] = ' ';
            VGA_MEMORY[index * 2 + 1] = terminal.color;
        }
    }
}

// Afficher caractère AKIKO
void akiko_putchar(char c) {
    if (c == '\n') {
        terminal.column = 0;
        if (++terminal.row >= VGA_HEIGHT) {
            terminal.row = VGA_HEIGHT - 1;
        }
        return;
    }
    
    const unsigned int index = terminal.row * VGA_WIDTH + terminal.column;
    VGA_MEMORY[index * 2] = c;
    VGA_MEMORY[index * 2 + 1] = terminal.color;
    
    if (++terminal.column >= VGA_WIDTH) {
        terminal.column = 0;
        if (++terminal.row >= VGA_HEIGHT) {
            terminal.row = VGA_HEIGHT - 1;
        }
    }
}

// Afficher chaîne AKIKO
void akiko_print(const char* data) {
    for (unsigned int i = 0; data[i] != '\0'; i++) {
        akiko_putchar(data[i]);
    }
}

// Afficher nombre AKIKO
void akiko_print_num(int num) {
    if (num == 0) {
        akiko_putchar('0');
        return;
    }
    
    if (num < 0) {
        akiko_putchar('-');
        num = -num;
    }
    
    char buffer[12];
    int i = 0;
    
    while (num > 0) {
        buffer[i++] = '0' + (num % 10);
        num /= 10;
    }
    
    while (i > 0) {
        akiko_putchar(buffer[--i]);
    }
}

// Afficher hexadécimal AKIKO
void akiko_print_hex(unsigned int num) {
    akiko_print("0x");
    
    for (int i = 7; i >= 0; i--) {
        unsigned char nibble = (num >> (i * 4)) & 0xF;
        akiko_putchar(nibble < 10 ? '0' + nibble : 'A' + nibble - 10);
    }
}

// Curseur AKIKO
void akiko_set_cursor(unsigned int row, unsigned int column) {
    terminal.row = row;
    terminal.column = column;
}

// Couleur AKIKO
void akiko_set_color(enum akiko_color fg, enum akiko_color bg) {
    terminal.color = akiko_vga_color(fg, bg);
}

// Déclarations externes
extern void akiko_beep(unsigned int frequency);
extern void akiko_silence(void);

// Délai AKIKO
void akiko_delay(unsigned int ms) {
    for (volatile unsigned int i = 0; i < ms * 1000; i++) {
        asm volatile ("nop");
    }
}

// Handler d'interruptions AKIKO
void akiko_isr_handler(int interrupt_number) {
    akiko_set_color(AKIKO_LIGHT_RED, AKIKO_BLACK);
    akiko_print("AKIKO: Interruption ");
    akiko_print_num(interrupt_number);
    akiko_print(" recue");
    akiko_putchar('\n');
    
    // Pour les erreurs critiques, arrêter le système
    if (interrupt_number <= 16) {
        akiko_print("ERREUR CRITIQUE - Systeme arrete");
        asm volatile ("cli; hlt");
    }
}


// Point d'entrée AKIKO OS
void akiko_kernel_main(void) {
    // Initialiser le terminal
    akiko_terminal_init();
    
    // Afficher en-tête AKIKO
    akiko_set_color(AKIKO_LIGHT_CYAN, AKIKO_BLACK);
    akiko_print("========================================");
    akiko_putchar('\n');
    akiko_print("            AKIKO OS v1.0");
    akiko_putchar('\n');
    akiko_print("   Systeme leger et performant");
    akiko_putchar('\n');
    akiko_print("========================================");
    akiko_putchar('\n');
    akiko_putchar('\n');
    
    // Initialiser la mémoire
    akiko_set_color(AKIKO_LIGHT_GREEN, AKIKO_BLACK);
    akiko_print("Initialisation de la memoire...");
    akiko_putchar('\n');
    
    akiko_init_memory();
    unsigned int total_mem = akiko_get_memory_total();
    unsigned int used_mem = akiko_get_memory_used();
    
    akiko_print("Memoire totale: ");
    akiko_print_num(total_mem);
    akiko_print(" Ko");
    akiko_putchar('\n');
    
    akiko_print("Memoire utilisee: ");
    akiko_print_num(used_mem);
    akiko_print(" Ko");
    akiko_putchar('\n');
    akiko_putchar('\n');
    
    // Test allocation mémoire
    akiko_set_color(AKIKO_LIGHT_BLUE, AKIKO_BLACK);
    akiko_print("Test d'allocation memoire...");
    akiko_putchar('\n');
    
    void* ptr1 = akiko_kmalloc(1024);
    void* ptr2 = akiko_kmalloc(2048);
    void* ptr3 = akiko_kmalloc(4096);
    
    if (ptr1 && ptr2 && ptr3) {
        akiko_print("Allocations reussies: ");
        akiko_print_hex((unsigned int)ptr1);
        akiko_print(", ");
        akiko_print_hex((unsigned int)ptr2);
        akiko_print(", ");
        akiko_print_hex((unsigned int)ptr3);
        akiko_putchar('\n');
    }
    
    akiko_kfree(ptr1, 1024);
    akiko_kfree(ptr2, 2048);
    akiko_kfree(ptr3, 4096);
    
    akiko_print("Liberation memoire reussie");
    akiko_putchar('\n');
    akiko_putchar('\n');
    
    // Test son AKIKO
    akiko_set_color(AKIKO_LIGHT_MAGENTA, AKIKO_BLACK);
    akiko_print("Test audio AKIKO...");
    akiko_putchar('\n');
    
    akiko_beep(1000);
    akiko_delay(200);
    akiko_silence();
    akiko_delay(100);
    
    akiko_beep(1500);
    akiko_delay(200);
    akiko_silence();
    
    akiko_print("Test audio complete");
    akiko_putchar('\n');
    akiko_putchar('\n');
    
    // Message final AKIKO
    akiko_set_color(AKIKO_WHITE, AKIKO_BLUE);
    akiko_print(" AKIKO OS est operationnel! ");
    akiko_set_color(AKIKO_LIGHT_GREY, AKIKO_BLACK);
    akiko_putchar('\n');
    akiko_putchar('\n');
    
    akiko_print(">>> ");
    
    // Boucle principale AKIKO
    unsigned int counter = 0;
    while (1) {
        // Clignotement du curseur AKIKO
        if (counter++ % 1000 == 0) {
            unsigned int index = terminal.row * VGA_WIDTH + terminal.column;
            VGA_MEMORY[index * 2 + 1] ^= 0x0F;
        }
        akiko_delay(1);
    }
}

// Point d'entrée pour le linker
void _start(void) {
    akiko_kernel_main();
}