// Gestionnaire de memoire AKIKO OS
#define AKIKO_MEMORY_SIZE 0x100000
#define AKIKO_BLOCK_SIZE 4096

unsigned char akiko_memory_map[AKIKO_MEMORY_SIZE/AKIKO_BLOCK_SIZE/8] = {0};
unsigned int akiko_memory_used = 0;
unsigned int akiko_memory_total = AKIKO_MEMORY_SIZE / 1024;

// Initialiser memoire AKIKO
void akiko_init_memory(void) {
    // Marquer les premiers 1 Mo comme utilise
    for (unsigned int i = 0; i < 0x100000/AKIKO_BLOCK_SIZE; i++) {
        akiko_memory_map[i/8] |= (1 << (i % 8));
        akiko_memory_used += AKIKO_BLOCK_SIZE / 1024;
    }
}

// Allouer memoire AKIKO
void* akiko_kmalloc(unsigned int size) {
    unsigned int blocks_needed = (size + AKIKO_BLOCK_SIZE - 1) / AKIKO_BLOCK_SIZE;
    int start_block = -1;
    unsigned int consecutive = 0;
    
    for (unsigned int i = 0; i < sizeof(akiko_memory_map)*8; i++) {
        if (!(akiko_memory_map[i/8] & (1 << (i % 8)))) {
            if (start_block == -1) start_block = i;
            consecutive++;
            if (consecutive == blocks_needed) {
                for (unsigned int j = start_block; j < start_block + blocks_needed; j++) {
                    akiko_memory_map[j/8] |= (1 << (j % 8));
                }
                akiko_memory_used += blocks_needed * AKIKO_BLOCK_SIZE / 1024;
                return (void*)(start_block * AKIKO_BLOCK_SIZE);
            }
        } else {
            start_block = -1;
            consecutive = 0;
        }
    }
    return 0;
}

// Liberer memoire AKIKO
void akiko_kfree(void* ptr, unsigned int size) {
    if (!ptr) return;
    
    unsigned int start_block = (unsigned int)ptr / AKIKO_BLOCK_SIZE;
    unsigned int blocks = (size + AKIKO_BLOCK_SIZE - 1) / AKIKO_BLOCK_SIZE;
    
    for (unsigned int i = start_block; i < start_block + blocks; i++) {
        akiko_memory_map[i/8] &= ~(1 << (i % 8));
    }
    akiko_memory_used -= blocks * AKIKO_BLOCK_SIZE / 1024;
}

// Obtenir memoire totale AKIKO
unsigned int akiko_get_memory_total(void) {
    return akiko_memory_total;
}

// Obtenir memoire utilisee AKIKO
unsigned int akiko_get_memory_used(void) {
    return akiko_memory_used;
}

// Statistiques memoire AKIKO
void akiko_memory_stats(void) {
    unsigned int free_blocks = 0;
    unsigned int total_blocks = sizeof(akiko_memory_map) * 8;
    
    for (unsigned int i = 0; i < total_blocks; i++) {
        if (!(akiko_memory_map[i/8] & (1 << (i % 8)))) {
            free_blocks++;
        }
    }
    
    // Ces fonctions seraient implementees dans le noyau
    // akiko_print("Blocs libres: ");
    // akiko_print_num(free_blocks);
    // akiko_print("/");
    // akiko_print_num(total_blocks);
}