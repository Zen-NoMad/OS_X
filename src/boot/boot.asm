BITS 32

section .multiboot2 align=8
header_start:
    dd 0xE85250D6               ; Magic
    dd 0                        ; Architecture
    dd header_end - header_start ; Header length
    dd -(0xE85250D6 + 0 + (header_end - header_start))
    dw 0
    dw 0
    dd 8
header_end:

section .bss align=4096
pml4:   resb 4096
pdpt:   resb 4096
pd:     resb 4096 * 512         ; 512 entries → 512 * 2 MiB = 1 GiB identity mapping

stack_bottom:
        resb 32768              ; 32 KiB stack (safer than 16 KiB)
stack_top:

section .data align=8
gdt64:
        dq 0                    ; null descriptor

        ; 64-bit code segment (selector 0x08)
        dw 0                    ; limit low
        dw 0                    ; base low
        db 0                    ; base mid
        db 10011010b            ; present, ring0, code, exec/read
        db 00101111b            ; L=1, D/B=0, G=0 (64-bit)
        db 0                    ; base high

        ; 64-bit data segment (selector 0x10)
        dw 0
        dw 0
        db 0
        db 10010010b            ; present, ring0, data, read/write
        db 11001111b            ; G=1, D/B=1, L=0
        db 0

gdt64_ptr:
        dw gdt64_ptr - gdt64 - 1
        dd gdt64

section .text
global _start_32
extern kernel_main

_start_32:
    cli
    mov esp, stack_top

    ; Check multiboot2 magic
    cmp eax, 0x36d76289
    jne .error

    ; Save multiboot2 info pointer (ebx = physical address of multiboot2 structure)
    mov edi, ebx        ; edi = multiboot2 info ptr
    mov esi, eax        ; esi = magic

    ; Check if long mode is supported
    mov eax, 0x80000000
    cpuid
    cmp eax, 0x80000001
    jb .no_long_mode

    ; Setup simple identity mapping: 1 GiB (512 x 2 MiB pages)
    mov eax, pdpt
    or  eax, 3                  ; present + writable
    mov [pml4], eax             ; PML4[0] -> PDPT (covers 0..512 GiB virtual)

    mov eax, pd
    or  eax, 3
    mov [pdpt], eax             ; PDPT[0] -> PD (covers 0..1 GiB virtual)

    ; Fill PD with 512 entries: 2 MiB huge pages, identity mapped
    mov ecx, 512
    mov ebx, 0x00000083         ; 2 MiB page + present + writable
    mov edi, pd
.fill_pd:
    mov [edi], ebx
    add edi, 8
    add ebx, 0x00200000         ; next 2 MiB block
    loop .fill_pd

    ; Disable paging (already off, but make sure)
    mov eax, cr0
    and eax, ~(1 << 31)
    mov cr0, eax

    ; Enable PAE
    mov eax, cr4
    or  eax, (1 << 5)
    mov cr4, eax

    ; Load PML4 into CR3
    mov eax, pml4
    mov cr3, eax

    ; Enable long mode (set LME bit in EFER)
    mov ecx, 0xC0000080
    rdmsr
    or  eax, (1 << 8)
    wrmsr

    ; Load 64-bit GDT
    lgdt [gdt64_ptr]

    ; Enable paging → enter compatibility mode
    mov eax, cr0
    or  eax, (1 << 31)
    mov cr0, eax

    ; Far jump to 64-bit code segment to enter full long mode
    jmp 0x08:.start_64

.start_64:
    BITS 64

    ; Reload segment registers with 64-bit data segment
    mov ax, 0x10
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax

    ; Setup stack in 64-bit mode
    mov rsp, stack_top

    ; Pass multiboot2 info to kernel_main (rdi = 1st arg in System V ABI)
    mov rdi, rdi    ; 1st arg = multiboot2 info ptr
    mov rsi, rsi    ; 2nd arg = magic

    call kernel_main

    ; If kernel_main returns, hang
    cli
    hlt
    jmp $ - 2

.no_long_mode:
    mov byte [0xb8000], 'N'     ; Display 'N' for No long mode
    mov byte [0xb8001], 0x0f
    jmp .error

.error:
    hlt
    jmp .error