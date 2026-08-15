system_handler:
    lda kernel_msg_type
    cmp #MSG_INIT
    beq system_init
    cmp #MSG_ACTIVATE
    beq system_activate
    cmp #MSG_KEY
    beq system_key
    rts

system_init:
    lda #0
    sta system_status
    rts

system_activate:
    jmp desktop_request_draw

system_key:
    lda kernel_msg_p0
    cmp #'T'
    bne @done
    lda #SERVICE_VIDEO
    ldx #MSG_THEME
    ldy #0
    jmp kernel_send
@done:
    rts

system_render:
    lda #<str_system_title
    sta video_text_ptr
    lda #>str_system_title
    sta video_text_ptr+1
    lda #4
    ldx #1
    jsr video_print_at
    lda #<str_system_kernel
    sta video_text_ptr
    lda #>str_system_kernel
    sta video_text_ptr+1
    lda #2
    ldx #5
    jsr video_print_at
    lda #<str_system_ipc
    sta video_text_ptr
    lda #>str_system_ipc
    sta video_text_ptr+1
    lda #2
    ldx #7
    jsr video_print_at
    lda #<str_system_pages
    sta video_text_ptr
    lda #>str_system_pages
    sta video_text_ptr+1
    lda #2
    ldx #9
    jsr video_print_at
    lda #<str_system_services
    sta video_text_ptr
    lda #>str_system_services
    sta video_text_ptr+1
    lda #2
    ldx #11
    jsr video_print_at
    lda #<str_system_storage
    sta video_text_ptr
    lda #>str_system_storage
    sta video_text_ptr+1
    lda #2
    ldx #13
    jsr video_print_at
    lda #<str_system_help
    sta video_text_ptr
    lda #>str_system_help
    sta video_text_ptr+1
    lda #2
    ldx #22
    jmp video_print_at
