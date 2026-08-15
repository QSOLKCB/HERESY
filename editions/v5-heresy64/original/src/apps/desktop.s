desktop_handler:
    lda kernel_msg_type
    cmp #MSG_INIT
    beq desktop_init
    cmp #MSG_KEY
    beq desktop_key
    cmp #MSG_POINTER
    beq desktop_pointer
    cmp #MSG_ACTIVATE
    bne @done
    jmp desktop_activate
@done:
    rts

desktop_init:
    lda #VIEW_DESKTOP
    sta active_view
    lda #0
    sta desktop_selection
    jmp desktop_request_draw

desktop_key:
    lda kernel_msg_p0
    cmp #KEY_F1
    bne @not_home
    jmp desktop_home
@not_home:
    cmp #'1'
    bcc @return
    cmp #'6'
    bcs @return
    sec
    sbc #'1'
    sta desktop_selection
    jmp desktop_activate
@return:
    cmp #KEY_RETURN
    beq desktop_activate
    rts

desktop_pointer:
    lda active_view
    bne @done
    lda kernel_msg_p0
    cmp #2
    beq @up
    cmp #3
    beq @down
    cmp #0
    beq @left
@right:
    inc desktop_selection
    lda desktop_selection
    cmp #5
    bcc @draw
    lda #0
    sta desktop_selection
    beq @draw
@left:
    lda desktop_selection
    bne @dec
    lda #5
    sta desktop_selection
@dec:
    dec desktop_selection
    jmp @draw
@up:
    lda desktop_selection
    cmp #4
    bne @draw
    lda #2
    sta desktop_selection
    bne @draw
@down:
    lda desktop_selection
    cmp #4
    beq @draw
    lda #4
    sta desktop_selection
@draw:
    jmp desktop_request_draw
@done:
    rts

desktop_activate:
    lda active_view
    bne @done
    ldx desktop_selection
    txa
    clc
    adc #1
    sta active_view
    lda desktop_service_targets,x
    ldx #MSG_ACTIVATE
    ldy #0
    jsr kernel_send
    jmp desktop_request_draw
@done:
    rts

desktop_home:
    lda #VIEW_DESKTOP
    sta active_view
    lda #SERVICE_AUDIO
    ldx #MSG_AUDIO_SILENCE
    ldy #0
    jsr kernel_send
    jmp desktop_request_draw

desktop_request_draw:
    lda #SERVICE_VIDEO
    ldx #MSG_DRAW
    ldy #0
    jmp kernel_send

desktop_render:
    lda #<str_desktop_title
    sta video_text_ptr
    lda #>str_desktop_title
    sta video_text_ptr+1
    lda #7
    ldx #1
    jsr video_print_at

    lda #<str_files_icon
    sta video_text_ptr
    lda #>str_files_icon
    sta video_text_ptr+1
    lda #1
    ldx #6
    jsr video_print_at
    lda #<str_notes_icon
    sta video_text_ptr
    lda #>str_notes_icon
    sta video_text_ptr+1
    lda #10
    ldx #6
    jsr video_print_at
    lda #<str_calc_icon
    sta video_text_ptr
    lda #>str_calc_icon
    sta video_text_ptr+1
    lda #19
    ldx #6
    jsr video_print_at
    lda #<str_system_icon
    sta video_text_ptr
    lda #>str_system_icon
    sta video_text_ptr+1
    lda #28
    ldx #6
    jsr video_print_at
    lda #<str_demo_icon
    sta video_text_ptr
    lda #>str_demo_icon
    sta video_text_ptr+1
    lda #15
    ldx #12
    jsr video_print_at

    ldx desktop_selection
    lda desktop_marker_cols,x
    sta video_tmp
    lda desktop_marker_rows,x
    tax
    lda #<str_marker
    sta video_text_ptr
    lda #>str_marker
    sta video_text_ptr+1
    lda video_tmp
    jsr video_print_at

    lda #<str_desktop_help
    sta video_text_ptr
    lda #>str_desktop_help
    sta video_text_ptr+1
    lda #2
    ldx #22
    jmp video_print_at
