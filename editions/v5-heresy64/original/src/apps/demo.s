demo_handler:
    lda kernel_msg_type
    cmp #MSG_INIT
    bne @not_init
    jmp demo_init
@not_init:
    cmp #MSG_ACTIVATE
    bne @not_activate
    jmp demo_activate
@not_activate:
    cmp #MSG_TICK
    bne @not_tick
    jmp demo_tick
@not_tick:
    cmp #MSG_KEY
    bne @done
    jmp demo_key
@done:
    rts

demo_init:
    lda #0
    sta demo_frame
    sta demo_scroll
    sta demo_scroll+1
    sta demo_divider
    lda #1
    sta demo_music
    rts

demo_activate:
    lda #0
    sta demo_frame
    sta demo_scroll
    sta demo_divider
    lda demo_music
    beq @draw
    lda #SERVICE_AUDIO
    ldx #MSG_AUDIO_TONE
    ldy #0
    jsr kernel_send
@draw:
    jmp desktop_request_draw

demo_tick:
    lda active_view
    cmp #VIEW_DEMO
    bne @done
    inc demo_frame
    inc demo_divider
    lda demo_divider
    and #1
    bne @frame
    inc demo_scroll
    lda demo_scroll
    cmp #DEMO_SCROLL_LEN
    bcc @frame
    lda #0
    sta demo_scroll
@frame:
    lda demo_frame
    sta kernel_arg1
    lda #SERVICE_VIDEO
    ldx #MSG_DEMO_FRAME
    ldy demo_scroll
    jsr kernel_send
    lda demo_music
    beq @done
    lda demo_frame
    and #7
    bne @done
    lda demo_frame
    lsr
    lsr
    lsr
    and #7
    tay
    lda #SERVICE_AUDIO
    ldx #MSG_AUDIO_TONE
    jmp kernel_send
@done:
    rts

demo_key:
    lda kernel_msg_p0
    cmp #'M'
    beq demo_toggle_music
    cmp #'R'
    beq demo_activate
    rts

demo_toggle_music:
    lda demo_music
    eor #1
    sta demo_music
    beq @silence
    lda #SERVICE_AUDIO
    ldx #MSG_AUDIO_TONE
    ldy audio_note
    jsr kernel_send
    jmp desktop_request_draw
@silence:
    lda #SERVICE_AUDIO
    ldx #MSG_AUDIO_SILENCE
    ldy #0
    jsr kernel_send
    jmp desktop_request_draw

demo_render:
    lda #<str_demo_title
    sta video_text_ptr
    lda #>str_demo_title
    sta video_text_ptr+1
    lda #2
    ldx #1
    jsr video_print_at
    lda #<str_demo_subtitle
    sta video_text_ptr
    lda #>str_demo_subtitle
    sta video_text_ptr+1
    lda #3
    ldx #3
    jsr video_print_at
    lda #<str_demo_stats
    sta video_text_ptr
    lda #>str_demo_stats
    sta video_text_ptr+1
    lda #4
    ldx #5
    jsr video_print_at
    lda #<str_demo_mindset
    sta video_text_ptr
    lda #>str_demo_mindset
    sta video_text_ptr+1
    lda #2
    ldx #7
    jsr video_print_at
    lda #<str_demo_arch
    sta video_text_ptr
    lda #>str_demo_arch
    sta video_text_ptr+1
    lda #3
    ldx #8
    jsr video_print_at
    lda #<str_demo_nix
    sta video_text_ptr
    lda #>str_demo_nix
    sta video_text_ptr+1
    lda #2
    ldx #10
    jsr video_print_at
    lda #<str_demo_archbtw
    sta video_text_ptr
    lda #>str_demo_archbtw
    sta video_text_ptr+1
    lda #2
    ldx #12
    jsr video_print_at
    lda #<str_demo_lfs
    sta video_text_ptr
    lda #>str_demo_lfs
    sta video_text_ptr+1
    lda #2
    ldx #14
    jsr video_print_at
    lda #<str_demo_bloat
    sta video_text_ptr
    lda #>str_demo_bloat
    sta video_text_ptr+1
    lda #4
    ldx #16
    jsr video_print_at
    lda #<str_demo_pid1
    sta video_text_ptr
    lda #>str_demo_pid1
    sta video_text_ptr+1
    lda #1
    ldx #19
    jsr video_print_at
    lda demo_music
    beq @muted
    lda #<str_demo_music_on
    sta video_text_ptr
    lda #>str_demo_music_on
    bne @help
@muted:
    lda #<str_demo_music_off
    sta video_text_ptr
    lda #>str_demo_music_off
@help:
    sta video_text_ptr+1
    lda #2
    ldx #23
    jmp video_print_at
