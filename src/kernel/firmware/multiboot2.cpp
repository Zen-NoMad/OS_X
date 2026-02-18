#include <firmware/multiboot2.h>
#include <driver/vga.h>
#include <libs/types.h>
#include <libs/hex.h>

multiboot_tag_basic_meminfo *Multiboot2::memInfo = (multiboot_tag_basic_meminfo *)nullptr;
multiboot_tag_mmap *Multiboot2::mmapInfo = (multiboot_tag_mmap *)nullptr;

void multibootTitle()
{
    VGA::print("[ ");
    VGA::print("Multiboot 2", (uint8_t)0x2, (uint8_t)0x0);
    VGA::print(" ] ");
}

/**
 * @param magic required
 */
void Multiboot2::checkMagic(uintptr_t magic)
{
    multibootTitle();
    VGA::print(HEX::toString(magic, (char *)nullptr));
    VGA::newLine();

    if (magic == MULTIBOOT2_BOOTLOADER_MAGIC)
    {
        multibootTitle();
        VGA::print("Magic is correct!");
        VGA::newLine();
    }
}

/**
 * @param MB_header_tag required
 */
void Multiboot2::parseMBTag(uintptr_t MB_header_tag)
{
    multibootTitle();
    VGA::print(HEX::toString(MB_header_tag, (char *)nullptr));
    VGA::newLine();

    uint8_t *addr = (uint8_t *)MB_header_tag + 8;
    multiboot_tag *tag = (multiboot_tag *)addr;

    multibootTitle();
    VGA::print("Tag type: ");
    VGA::print(HEX::toString(tag->type, (char *)nullptr));
    VGA::newLine();

    while (tag->type != MULTIBOOT_TAG_TYPE_END)
    {

        switch (tag->type)
        {
        case 4: /*  Basic memory info. */
            multibootTitle();
            VGA::print("Found basic memory info tag!");
            VGA::newLine();
            setMemInfo((multiboot_tag_basic_meminfo *)tag);
            break;

        case 6: /*  Memory map. */
            multibootTitle();
            VGA::print("Found memory map tag!");
            VGA::newLine();
            setMmapInfo((multiboot_tag_mmap *)tag);
            break;

        default:
            break;
        }
        tag = (multiboot_tag *)((uint8_t *)tag + ((tag->size + 7) & ~7));
    }
}

void Multiboot2::setMemInfo(multiboot_tag_basic_meminfo *memInfo)
{
    Multiboot2::memInfo = memInfo;
    multibootTitle();
    VGA::print("Total memory in MB: ");
    VGA::print(HEX::toDecimal((memInfo->mem_lower + memInfo->mem_upper) / 1024));
    VGA::newLine();
}

void Multiboot2::setMmapInfo(multiboot_tag_mmap *mmapInfo)
{
    Multiboot2::mmapInfo = mmapInfo;
}
