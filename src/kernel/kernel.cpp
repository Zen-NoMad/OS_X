#include <firmware/multiboot2.h>
#include <common/types.h>
#include <driver/vga.h>

extern "C" void kernel_main(uint32_t mbinfo_addr, uint32_t magic)
{
    VGA::clearScreen();
    VGA::print("Hi from kernel!");
}