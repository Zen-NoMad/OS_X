#include <firmware/multiboot2.h>
#include <driver/vga.h>
#include <libs/types.h>
#include <libs/hex.h>

extern "C" void kernel_main(uintptr_t mbinfo_addr, uintptr_t magic)
{
    uint32_t mbinfo32 = mbinfo_addr & 0xFFFFFFFF;

    VGA::clearScreen();
    Multiboot2::checkMagic(magic);
    Multiboot2::parseMBTag(mbinfo32);
    while (true)
    {
    }

    // Multiboot2::parseMBTag(mbinfo_addr);
}