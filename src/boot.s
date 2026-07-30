entry:
    sei
    cld
    ldx #$FF
    txs
    lda #0
    sta ipc_head
    sta ipc_tail
    sta kernel_tick_count
    sta kernel_tick_count+1
    ldx #0
@clear_tables:
    sta service_handlers_lo,x
    sta service_handlers_hi,x
    sta service_pages,x
    inx
    cpx #SERVICE_COUNT
    bne @clear_tables
    ldx #0
@clear_pages:
    sta page_bitmap,x
    inx
    cpx #PAGE_COUNT
    bne @clear_pages

    lda #SERVICE_KERNEL
    ldx #<kernel_handler
    ldy #>kernel_handler
    jsr boot_register
    lda #SERVICE_INPUT
    ldx #<input_handler
    ldy #>input_handler
    jsr boot_register
    lda #SERVICE_VIDEO
    ldx #<video_handler
    ldy #>video_handler
    jsr boot_register
    lda #SERVICE_DISK
    ldx #<disk_handler
    ldy #>disk_handler
    jsr boot_register
    lda #SERVICE_DESKTOP
    ldx #<desktop_handler
    ldy #>desktop_handler
    jsr boot_register
    lda #SERVICE_FILES
    ldx #<files_handler
    ldy #>files_handler
    jsr boot_register
    lda #SERVICE_NOTES
    ldx #<notes_handler
    ldy #>notes_handler
    jsr boot_register
    lda #SERVICE_CALC
    ldx #<calc_handler
    ldy #>calc_handler
    jsr boot_register
    lda #SERVICE_SYSTEM
    ldx #<system_handler
    ldy #>system_handler
    jsr boot_register
    lda #SERVICE_AUDIO
    ldx #<audio_handler
    ldy #>audio_handler
    jsr boot_register
    lda #SERVICE_DEMO
    ldx #<demo_handler
    ldy #>demo_handler
    jsr boot_register

    ; Allocate one brokered 256-byte page per non-kernel service.
    ldx #1
@allocate:
    txa
    pha
    jsr kernel_page_alloc
    sta kernel_tmp_page
    pla
    tax
    lda kernel_page_hi
    sta service_pages,x
    inx
    cpx #SERVICE_COUNT
    bne @allocate

    ldx #1
@init_services:
    txa
    pha
    lda #0
    sta kernel_arg1
    txa
    ldx #MSG_INIT
    ldy #0
    jsr kernel_send
    pla
    tax
    inx
    cpx #SERVICE_COUNT
    bne @init_services
    lda JIFFY_LO
    sta last_jiffy
    cli

main_loop:
    lda JIFFY_LO
    cmp last_jiffy
    beq @dispatch
    sta last_jiffy
    inc kernel_tick_count
    bne @tick_ready
    inc kernel_tick_count+1
@tick_ready:
    lda #SERVICE_INPUT
    ldx #MSG_TICK
    ldy kernel_tick_count
    jsr kernel_send
    lda #SERVICE_DEMO
    ldx #MSG_TICK
    ldy kernel_tick_count
    jsr kernel_send
@dispatch:
    jsr kernel_dispatch
    jmp main_loop

boot_register:
    ; A=id, X=low, Y=high.
    stx kernel_arg0
    sty kernel_arg1
    jmp kernel_register
