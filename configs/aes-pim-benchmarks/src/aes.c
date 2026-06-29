#include <ctype.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>
#include <openssl/evp.h>
#include "gem5/m5ops.h"

const EVP_CIPHER* cipher_type;

void toUppercase(char *str) {
    for (int i = 0; str[i] != '\0'; i++) {
        str[i] = toupper(str[i]);
    }
}

int main(int argc, char *argv[]) {
    // Check command line arguments
    if (argc != 3) {
        printf("Usage: %s <cipher_type> <num_blocks>\n", argv[0]);
        return 1;
    }

    char* cipher_type_arg = argv[1];
    if (!strcmp(cipher_type_arg, "cbc")) {
        cipher_type = EVP_aes_256_cbc();
    } else if (!strcmp(cipher_type_arg, "gcm")) {
        cipher_type = EVP_aes_256_gcm();
    } else {
        printf("Error: cipher_type must be either cbc or gcm\n");
        return 1;
    }
    toUppercase(cipher_type_arg);

    int num_blocks = atoi(argv[2]);
    if (num_blocks <= 0) {
        printf("Error: num_blocks must be a positive integer\n");
        return 1;
    }

    // Prepare key and IV (random or fixed for benchmarking)
    unsigned char key[32]; // 256 bits
    unsigned char iv[16]; // 16 bytes
    memset(key, 0x00, sizeof(key));
    memset(iv,  0x00, sizeof(iv));

    // Prepare input buffer - allocate extra block for initialization
    size_t block_size = 16; // 16 bytes
    unsigned char *plaintext = malloc((num_blocks + 1) * block_size);
    unsigned char *ciphertext = malloc((num_blocks + 1) * block_size + 32);
    memset(plaintext, 0x00, (num_blocks + 1) * block_size);

    // First test
    EVP_CIPHER_CTX *ctx1 = EVP_CIPHER_CTX_new();
    int outlen1, tmplen1, outlen_init1;

    EVP_EncryptInit_ex(ctx1, cipher_type, NULL, key, iv);

    // Initialize with one block (warmup - not timed)
    EVP_EncryptUpdate(ctx1, ciphertext, &outlen_init1, plaintext, block_size);

    // Reset statistics before starting the first benchmark
    m5_reset_stats(0, 0);

    // Start timing using Gem5 pseudo-instructions
    uint64_t start_time1 = m5_rpns(); // Get current simulation time in nanoseconds

    // Run update operation for remaining blocks
    EVP_EncryptUpdate(ctx1, ciphertext + outlen_init1, &outlen1, plaintext + block_size, num_blocks * block_size);

    // Get end time and calculate accurate simulation timing
    uint64_t end_time1 = m5_rpns();
    uint64_t simulation_ns1 = end_time1 - start_time1;
    double simulation_seconds1 = (double)simulation_ns1 / 1e9;
    double throughput1 = ((double)block_size * num_blocks) / (simulation_seconds1 * 1024 * 1024); // MB/s

    printf("=== FIRST TEST ===\n");
    printf("AES-256-%s benchmark: encryption of %lu bytes in %.2f simulation seconds\n",
        cipher_type_arg, num_blocks * block_size, simulation_seconds1);
    printf("Simulation time: %lu nanoseconds\n", simulation_ns1);
    printf("Throughput: %.2f MB/s\n", throughput1);

    EVP_EncryptFinal_ex(ctx1, ciphertext + outlen_init1 + outlen1, &tmplen1);
    EVP_CIPHER_CTX_free(ctx1);

    // Reset ciphertext for second test
    memset(ciphertext, 0x00, (num_blocks + 1) * block_size + 32);

    // Second test
    EVP_CIPHER_CTX *ctx2 = EVP_CIPHER_CTX_new();
    int outlen2, tmplen2, outlen_init2;

    EVP_EncryptInit_ex(ctx2, cipher_type, NULL, key, iv);

    // Initialize with one block (warmup - not timed)
    EVP_EncryptUpdate(ctx2, ciphertext, &outlen_init2, plaintext, block_size);

    // Reset statistics before starting the second benchmark
    m5_reset_stats(0, 0);

    // Start timing using Gem5 pseudo-instructions
    uint64_t start_time2 = m5_rpns(); // Get current simulation time in nanoseconds

    // Run update operation for remaining blocks
    EVP_EncryptUpdate(ctx2, ciphertext + outlen_init2, &outlen2, plaintext + block_size, num_blocks * block_size);

    // Get end time and calculate accurate simulation timing
    uint64_t end_time2 = m5_rpns();
    uint64_t simulation_ns2 = end_time2 - start_time2;
    double simulation_seconds2 = (double)simulation_ns2 / 1e9;
    double throughput2 = ((double)block_size * num_blocks) / (simulation_seconds2 * 1024 * 1024); // MB/s

    printf("=== SECOND TEST ===\n");
    printf("AES-256-%s benchmark: encryption of %lu bytes in %.2f simulation seconds\n",
        cipher_type_arg, num_blocks * block_size, simulation_seconds2);
    printf("Simulation time: %lu nanoseconds\n", simulation_ns2);
    printf("Throughput: %.2f MB/s\n", throughput2);

    // Dump statistics for detailed analysis
    m5_dump_stats(0, 0);

    EVP_EncryptFinal_ex(ctx2, ciphertext + outlen_init2 + outlen2, &tmplen2);
    EVP_CIPHER_CTX_free(ctx2);

    // Reset ciphertext for third test
    memset(ciphertext, 0x00, (num_blocks + 1) * block_size + 32);

    // Third test
    EVP_CIPHER_CTX *ctx3 = EVP_CIPHER_CTX_new();
    int outlen3, tmplen3, outlen_init3;

    EVP_EncryptInit_ex(ctx3, cipher_type, NULL, key, iv);

    // Initialize with one block (warmup - not timed)
    EVP_EncryptUpdate(ctx3, ciphertext, &outlen_init3, plaintext, block_size);

    // Reset statistics before starting the third benchmark
    m5_reset_stats(0, 0);

    // Start timing using Gem5 pseudo-instructions
    uint64_t start_time3 = m5_rpns(); // Get current simulation time in nanoseconds

    // Run update operation for remaining blocks
    EVP_EncryptUpdate(ctx3, ciphertext + outlen_init3, &outlen3, plaintext + block_size, num_blocks * block_size);

    // Get end time and calculate accurate simulation timing
    uint64_t end_time3 = m5_rpns();
    uint64_t simulation_ns3 = end_time3 - start_time3;
    double simulation_seconds3 = (double)simulation_ns3 / 1e9;
    double throughput3 = ((double)block_size * num_blocks) / (simulation_seconds3 * 1024 * 1024); // MB/s

    printf("=== THIRD TEST ===\n");
    printf("AES-256-%s benchmark: encryption of %lu bytes in %.2f simulation seconds\n",
        cipher_type_arg, num_blocks * block_size, simulation_seconds3);
    printf("Simulation time: %lu nanoseconds\n", simulation_ns3);
    printf("Throughput: %.2f MB/s\n", throughput3);

    // Dump statistics for detailed analysis
    m5_dump_stats(0, 0);

    EVP_EncryptFinal_ex(ctx3, ciphertext + outlen_init3 + outlen3, &tmplen3);
    EVP_CIPHER_CTX_free(ctx3);
    free(plaintext);
    free(ciphertext);

    return 0;
}
