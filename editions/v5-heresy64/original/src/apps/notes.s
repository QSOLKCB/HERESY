notes_handler:
    lda kernel_msg_type
    cmp #MSG_INIT
    beq notes_init
    cmp #MSG_ACTIVATE
    beq notes_activate
    cmp #MSG_KEY
    beq notes_key
    cmp #MSG_DISK_RESULT
    beq notes_result
    rts

notes_init:
    lda #0
    sta notes_length
    sta notes_status
    sta notes_buffer
    rts

notes_activate:
    jmp desktop_request_draw

notes_key:
    lda kernel_msg_p0
    cmp #KEY_F3
    beq notes_save
    cmp #KEY_F5
    beq notes_load
    cmp #KEY_DELETE
    beq notes_delete
    cmp #$20
    bcc @done
    cmp #$7F
    bcs @done
    ldx notes_length
    cpx #160
    bcs @done
    sta notes_buffer,x
    inx
    stx notes_length
    lda #0
    sta notes_buffer,x
    jmp desktop_request_draw
@done:
    rts

notes_delete:
    ldx notes_length
    beq @done
    dex
    stx notes_length
    lda #0
    sta notes_buffer,x
    jmp desktop_request_draw
@done:
    rts

notes_save:
    lda #3
    sta notes_status
    lda #SERVICE_DISK
    ldx #MSG_NOTE_SAVE
    ldy notes_length
    jsr kernel_send
    jmp desktop_request_draw

notes_load:
    lda #4
    sta notes_status
    lda #SERVICE_DISK
    ldx #MSG_NOTE_LOAD
    ldy #0
    jsr kernel_send
    jmp desktop_request_draw

notes_result:
    lda kernel_msg_p1
    sta notes_status
    jmp desktop_request_draw

notes_render:
    lda #<str_notes_title
    sta video_text_ptr
    lda #>str_notes_title
    sta video_text_ptr+1
    lda #5
    ldx #1
    jsr video_print_at
    lda #<str_notes_help
    sta video_text_ptr
    lda #>str_notes_help
    sta video_text_ptr+1
    lda #2
    ldx #3
    jsr video_print_at
    lda #<notes_buffer
    sta video_text_ptr
    lda #>notes_buffer
    sta video_text_ptr+1
    lda notes_length
    jsr video_print_wrapped
    lda notes_status
    beq @ready
    cmp #1
    beq @saved
    cmp #2
    beq @loaded
    cmp #3
    beq @saving
    cmp #4
    beq @loading
    lda #<str_disk_error
    sta video_text_ptr
    lda #>str_disk_error
    bne @status
@saved:
    lda #<str_note_saved
    sta video_text_ptr
    lda #>str_note_saved
    bne @status
@loaded:
    lda #<str_note_loaded
    sta video_text_ptr
    lda #>str_note_loaded
    bne @status
@saving:
    lda #<str_note_saving
    sta video_text_ptr
    lda #>str_note_saving
    bne @status
@loading:
    lda #<str_note_loading
    sta video_text_ptr
    lda #>str_note_loading
    bne @status
@ready:
    lda #<str_note_ready
    sta video_text_ptr
    lda #>str_note_ready
@status:
    sta video_text_ptr+1
    lda #2
    ldx #22
    jmp video_print_at
