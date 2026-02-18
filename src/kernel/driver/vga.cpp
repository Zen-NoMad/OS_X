#include <driver/vga.h>
#include <libs/types.h>

volatile uint16_t *VGA::vga_buffer = (volatile uint16_t *)0xB8000;
int VGA::cursor_X = 0;
int VGA::cursor_Y = 0;

// TODO: Add scrolling support
// Print a char
void VGA::putChar(char c, uint8_t text_color, uint8_t background_color)
{
    if (c == '\n')
    {
        newLine();
    }

    uint16_t attribute = background_color << 4 | text_color;
    vga_buffer[(cursor_Y * VGA_WIDTH) + cursor_X] = c | attribute << 8;
    cursor_X++;

    if (cursor_X >= VGA_WIDTH)
    {
        newLine();
        return;
    }

    //! Change here
    if (cursor_Y >= VGA_HEIGHT)
    {
        clearScreen();
    }
}

// TODO: Add multiformat printing support
// Print a string
void VGA::print(const char *str, uint8_t text_color, uint8_t background_color)
{
    while (*str)
    {
        putChar(*str++, text_color, background_color);
    }
}

// Go to new line
void VGA::newLine()
{
    cursor_X = 0;
    cursor_Y++;
}

// Clear the screen
void VGA::clearScreen()
{
    for (int i = 0; i < VGA_WIDTH * VGA_HEIGHT; i++)
    {
        putChar(' ', black, black);
    }
    cursor_X = 0;
    cursor_Y = 0;
}