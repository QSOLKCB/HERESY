theme_text_colors:
    .byte COLOR_LIGHT_GREY, COLOR_LIGHT_GREEN

input_view_services:
    .byte SERVICE_DESKTOP, SERVICE_FILES, SERVICE_NOTES
    .byte SERVICE_CALC, SERVICE_SYSTEM, SERVICE_DEMO

desktop_service_targets:
    .byte SERVICE_FILES, SERVICE_NOTES, SERVICE_CALC
    .byte SERVICE_SYSTEM, SERVICE_DEMO
desktop_marker_cols:
    .byte 3, 12, 21, 30, 17
desktop_marker_rows:
    .byte 9, 9, 9, 9, 15

screen_rows_lo:
    .repeat 25, I
        .byte <(SCREEN_RAM + I * 40)
    .endrepeat
screen_rows_hi:
    .repeat 25, I
        .byte >(SCREEN_RAM + I * 40)
    .endrepeat
color_rows_lo:
    .repeat 25, I
        .byte <(COLOR_RAM + I * 40)
    .endrepeat
color_rows_hi:
    .repeat 25, I
        .byte >(COLOR_RAM + I * 40)
    .endrepeat

demo_raster_lines:
    .byte 52, 68, 84, 100, 116, 132
demo_raster_colors:
    .byte COLOR_BLUE, COLOR_PURPLE, COLOR_RED
    .byte COLOR_ORANGE, COLOR_YELLOW, COLOR_BLACK

sid_freq_lo:
    .byte $17, $4B, $90, $E2, $43, $B5, $3B, $D4
sid_freq_hi:
    .byte $11, $13, $15, $16, $19, $1C, $20, $22

disk_dir_spec:         .byte "$"
disk_new_write:        .byte "HERESY NEW,S,W"
disk_new_read:         .byte "HERESY NEW"
disk_note_read:        .byte "HERESY NOTE"
disk_cmd_scratch_new:  .byte "S0:HERESY NEW"
disk_cmd_scratch_note: .byte "S0:HERESY NOTE"
disk_cmd_rename:       .byte "R0:HERESY NOTE=HERESY NEW"

str_desktop_title: .asciiz "HERESY/64 MICROKERNEL DESKTOP"
str_files_icon:    .asciiz "[1 FILES]"
str_notes_icon:    .asciiz "[2 NOTES]"
str_calc_icon:     .asciiz "[3 CALC ]"
str_system_icon:   .asciiz "[4 SYSTEM]"
str_demo_icon:     .asciiz "[5 FORCEOS '38]"
str_marker:        .asciiz "^^^^^^"
str_desktop_help:  .asciiz "1-5 SELECT  RETURN/FIRE OPEN"

str_files_title: .asciiz "FILES / DEVICE 8"
str_files_help:  .asciiz "R REFRESH                 F1 HOME"
str_files_empty: .asciiz "NO DIRECTORY RECORDS OR DRIVE OFFLINE"

str_notes_title:   .asciiz "NOTES / 1541 TRANSACTIONAL EDITION"
str_notes_help:    .asciiz "TYPE  DEL  F3 SAVE  F5 LOAD  F1 HOME"
str_note_ready:    .asciiz "READY - 160 BYTE DOCUMENT BUDGET"
str_note_saving:   .asciiz "WRITING TEMPORARY SEQUENTIAL FILE..."
str_note_loading:  .asciiz "SEARCHING RECOVERY FILES..."
str_note_saved:    .asciiz "SAVED VIA SCRATCH/WRITE/RENAME"
str_note_loaded:   .asciiz "LOADED RECOVERABLE NOTE"
str_disk_error:    .asciiz "DEVICE 8 DECLINED THE CHANGE REQUEST"

str_calc_title: .asciiz "CALCULATOR / 8-BIT FINANCE"
str_calc_help:  .asciiz "0-9  + - * / =  C CLEAR       F1 HOME"
str_calc_box:   .asciiz "[            ]"

str_system_title:    .asciiz "SYSTEM / NO CONTROL PLANE"
str_system_kernel:   .asciiz "KERNEL: COOPERATIVE 6510 CORE"
str_system_ipc:      .asciiz "IPC: 32 X 8-BYTE FIXED RECORDS"
str_system_pages:    .asciiz "MEMORY: 16 BROKERED 256-BYTE PAGES"
str_system_services: .asciiz "SERVICES: 11, INCLUDING SID AUDIOD"
str_system_storage:  .asciiz "STORAGE: 1541, ZERO DATABASE DAEMONS"
str_system_help:     .asciiz "T THEME                    F1 HOME"

str_demo_title:     .asciiz "FORCEOS '38 - FLAKE RELIGION"
str_demo_subtitle:  .asciiz "A REAL C64 DEMO FOR FAKE NECESSITY"
str_demo_stats:     .asciiz "8 COMMITS / 252 LINES / 0 CHECKS"
str_demo_mindset:   .asciiz "MINDSET: CONFIGURATION IS MORAL VIRTUE"
str_demo_arch:      .asciiz "INFRASTRUCTURE IS NOT A PERSONALITY"
str_demo_nix:       .asciiz "NIXOS IS THE NEW DECLARATIVE RELIGION"
str_demo_archbtw:   .asciiz "ARCH BTW: NOW THE OLD TESTAMENT"
str_demo_lfs:       .asciiz "LFS REJECTED: MISSING FLAKE.LOCK"
str_demo_bloat:     .asciiz "SMALL IS BEAUTIFUL. BLOAT IS UNHOLY."
str_demo_pid1:      .asciiz "PID 1: SYSTEMD NOW PROVIDES AFTERLIFE"
str_demo_music_on:  .asciiz "M MUSIC: ON / R RESTART / F1 APOSTASY"
str_demo_music_off: .asciiz "M MUSIC: OFF / R RESTART / F1 APOSTASY"

demo_scroll_text:
    .byte "   PR 38: 8 COMMITS, 252 LINES, 0 CHECKS. "
    .byte "ARCH BTW WAS THE STREET PREACHER. NIXOS IS "
    .byte "THE DECLARATIVE RELIGION. FLAKES ARE "
    .byte "SACRAMENTS. PURITY IS POLICY. XORG IS HERESY. "
    .byte "HYFETCH IS MANDATORY. LFS HAS NO FLAKE.LOCK. "
    .byte "SMALL IS BEAUTIFUL. BLOAT IS UNHOLY.   "
demo_scroll_end:
DEMO_SCROLL_LEN = demo_scroll_end - demo_scroll_text

image_end:
