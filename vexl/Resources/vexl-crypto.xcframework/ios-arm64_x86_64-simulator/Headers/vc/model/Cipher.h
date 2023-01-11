//
// Created by Adam Salih on 20.03.2022.
//

#ifndef CIPHER_H
#define CIPHER_H

#include <stdio.h>
#include <math.h>
#include <string.h>

#include "../common/Base64.h"
#include "../common/Constants.h"

# ifdef __cplusplus
extern "C" {
# endif

typedef struct {
    char *cipher;
    unsigned int cipher_len;
    char *public_key;
    unsigned int public_key_len;
    char *mac;
    unsigned int mac_len;
    char *tag;
    unsigned int tag_len;
} Cipher;

Cipher *cipher_new();
void cipher_free(Cipher *cipher);

char *cipher_encode(Cipher *cipher);
Cipher *cipher_decode(char *digest);

# ifdef  __cplusplus
}
# endif

#endif
