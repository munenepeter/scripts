// Type your code here, or load an example
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <stdbool.h>

typedef struct {
    char *op;
    bool isDivisible;
} tDivisible;

char *substr(const char *s, size_t pos, size_t n) {
    char *result = NULL;
    size_t length = strlen(s);

    if (pos >= length) {
        return NULL;
    }

    if (n > length - pos) {
        n = length - pos;
    }

    result = malloc(n + 1);

    if (result != NULL) {
        memcpy(result, s + pos, n);
        result[n] = '\0';
    }

    return result;
}


int* getDigits(int number, int size, int* digits) {
    for (int i = 0; i < size; i++)
        digits[i] = (int)substr((char*)number, i, 1);

    return digits;
}





int main() {

    
    int number = 0;
    
    while (number < 10000) {
    int size = strlen((char*)number);

     int digits[size];

     digits = getDigits(number, size, digits);
        
        //[op, isDivisible] = testDivisiblity(number, digits);
        
        // printf("Number: %d\tdigits: %s\tOperation: %s\tDivisible: %s\n", number,  op, isDivisible);

        printf("Number: %d\tdigits: %s\n", number) ;
        
        number++;
    }
}


// tDivisible testDivisiblity(int number,  int *digits) {
//     op = "number-" . implode('-', digits);

//     val = 0;

//     eval("\val = op;");

//     op = op . "=val";

//     isDivisible = 'FALSE';

//     if (val % 9 === 0) {
//         isDivisible = 'TRUE';
//     }

   
// }
