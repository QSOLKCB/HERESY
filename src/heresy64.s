.setcpu "6502"
.include "abi.inc"

.segment "LOADADDR"
    .word $0801

.segment "BASIC"
    .word basic_end
    .word 10
    .byte $9E
    .byte "2061", 0
basic_end:
    .word 0

.segment "ZEROPAGE"
video_text_ptr:   .res 2
video_screen_ptr: .res 2
video_color_ptr:  .res 2

.segment "CODE"
boot_trampoline:
    jmp entry
.include "kernel/core.s"
.include "boot.s"
.include "servers/video.s"
.include "servers/input.s"
.include "servers/disk.s"
.include "servers/audio.s"
.include "apps/desktop.s"
.include "apps/files.s"
.include "apps/notes.s"
.include "apps/calc.s"
.include "apps/system.s"
.include "apps/demo.s"

.segment "RODATA"
.include "data.s"

.segment "BSS"
image_bss_start:
    .include "state.s"
image_bss_end:
