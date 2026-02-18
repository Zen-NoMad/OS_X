#include <libs/types.h>
#include <libs/hex.h>

//! COPY-PASTED I MUST STUDY THIS
char *HEX::toString(uint64_t value, char *buffer)
{
    const char *hexChars = "0123456789ABCDEF";

    for (int i = 0; i < 16; i++)
    {
        uint8_t digit = (value >> ((15 - i) * 4)) & 0xF;
        buffer[i] = hexChars[digit];
    }

    buffer[16] = '\0';
    return buffer;
}

//! COPY-PASTED I MUST STUDY THIS
char *HEX::toDecimal(uint64_t value, char *buffer)
{
    if (value == 0)
    {
        buffer[0] = '0';
        buffer[1] = '\0';
        return buffer;
    }

    char temp[21]; // Max digits for uint64_t + null terminator
    int index = 0;

    while (value > 0)
    {
        temp[index++] = '0' + (value % 10);
        value /= 10;
    }

    // Reverse the string
    for (int i = 0; i < index; i++)
    {
        buffer[i] = temp[index - i - 1];
    }
    buffer[index] = '\0';

    return buffer;
}