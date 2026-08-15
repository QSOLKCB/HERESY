files_handler:
    lda kernel_msg_type
    cmp #MSG_INIT
    beq files_init
    cmp #MSG_ACTIVATE
    beq files_refresh
    cmp #MSG_KEY
    beq files_key
    cmp #MSG_DISK_RESULT
    beq files_result
    rts

files_init:
    lda #0
    sta files_count
    sta files_status
    rts

files_key:
    lda kernel_msg_p0
    cmp #'R'
    beq files_refresh
    rts

files_refresh:
    lda #1
    sta files_status
    lda #SERVICE_DISK
    ldx #MSG_DIR_REQUEST
    ldy #0
    jsr kernel_send
    jmp desktop_request_draw

files_result:
    lda kernel_msg_p0
    sta files_count
    lda kernel_msg_p1
    sta files_status
    jmp desktop_request_draw

files_render:
    lda #<str_files_title
    sta video_text_ptr
    lda #>str_files_title
    sta video_text_ptr+1
    lda #3
    ldx #1
    jsr video_print_at
    lda #<str_files_help
    sta video_text_ptr
    lda #>str_files_help
    sta video_text_ptr+1
    lda #2
    ldx #3
    jsr video_print_at
    lda files_count
    bne @names
    lda #<str_files_empty
    sta video_text_ptr
    lda #>str_files_empty
    sta video_text_ptr+1
    lda #2
    ldx #6
    jmp video_print_at
@names:
    lda #<disk_dir_names
    sta video_text_ptr
    lda #>disk_dir_names
    sta video_text_ptr+1
    lda #4
    ldx #6
    jsr video_print_fixed16
    lda files_count
    cmp #2
    bcc @done
    lda #<(disk_dir_names+16)
    sta video_text_ptr
    lda #>(disk_dir_names+16)
    sta video_text_ptr+1
    lda #4
    ldx #8
    jsr video_print_fixed16
    lda files_count
    cmp #3
    bcc @done
    lda #<(disk_dir_names+32)
    sta video_text_ptr
    lda #>(disk_dir_names+32)
    sta video_text_ptr+1
    lda #4
    ldx #10
    jsr video_print_fixed16
    lda files_count
    cmp #4
    bcc @done
    lda #<(disk_dir_names+48)
    sta video_text_ptr
    lda #>(disk_dir_names+48)
    sta video_text_ptr+1
    lda #4
    ldx #12
    jsr video_print_fixed16
    lda files_count
    cmp #5
    bcc @done
    lda #<(disk_dir_names+64)
    sta video_text_ptr
    lda #>(disk_dir_names+64)
    sta video_text_ptr+1
    lda #4
    ldx #14
    jsr video_print_fixed16
@done:
    rts
