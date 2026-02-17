#include <common/types.h>

#define VGA_ADDR 0xB8000
#define VGA_WIDTH 80
#define VGA_HEIGHT 25

class VGA
{
private:
    static volatile uint16_t *vga_buffer;
    static int cursor_X;
    static int cursor_Y;

    enum
    {
        black = 0x0,
        blue = 0x1,
        green = 0x2,
        cyan = 0x3,
        red = 0x4,
        magenta = 0x5,
        brown = 0x6,
        light_gray = 0x7,
        dark_gray = 0x8,
        light_blue = 0x9,
        light_green = 0xA,
        light_cyan = 0xB,
        light_red = 0xC,
        light_magenta = 0xD,
        yellow = 0xE,
        white = 0xF,
    };

public:
    VGA() {}
    static void putChar(char C, uint8_t text_color = (uint8_t)white, uint8_t background_color = (uint8_t)black);
    static void print(const char *str, uint8_t text_color = (uint8_t)white, uint8_t background_color = (uint8_t)black);
    static void clearScreen();
};