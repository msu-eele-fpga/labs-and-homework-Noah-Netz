#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <errno.h>
#include <string.h>
#include <unistd.h>

#define HPS_LED_CONTROL_OFFSET 0x0
#define BASE_PERIOD_OFFSET 0x8
#define LED_REG_OFFSET 0x4

int main () {
    FILE *file;
    size_t ret;    
    uint32_t val;

    file = fopen("/dev/led_patterns" , "rb+" );
    if (file == NULL) {
        printf("failed to open file\n");
        exit(1);
    }

    // Enable software-control mode
    val = 0x01;
    ret = fseek(file, HPS_LED_CONTROL_OFFSET, SEEK_SET);
    ret = fwrite(&val, 4, 1, file);
    fflush(file);

    printf("Displaying custom pattern...\n");
    
    // Infinite loop for custom pattern
    while (1) {
        // Set LEDs to 0x55 (1010101)
        val = 0x55;
        ret = fseek(file, LED_REG_OFFSET, SEEK_SET);
        ret = fwrite(&val, 4, 1, file);
        fflush(file);

        // Wait for 500ms
        usleep(500000);

        // Set LEDs to 0xAA (0101010)
        val = 0xAA;
        ret = fseek(file, LED_REG_OFFSET, SEEK_SET);
        ret = fwrite(&val, 4, 1, file);
        fflush(file);

        // Wait for another 500ms
        usleep(500000);
    }

    fclose(file);
    return 0;
}
