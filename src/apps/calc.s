calc_handler:
    lda kernel_msg_type
    cmp #MSG_INIT
    beq calc_clear
    cmp #MSG_ACTIVATE
    beq calc_activate
    cmp #MSG_KEY
    beq calc_key
    rts

calc_activate:
    jmp desktop_request_draw

calc_clear:
    lda #0
    sta calc_value
    sta calc_value+1
    sta calc_left
    sta calc_left+1
    sta calc_op
    sta calc_entry
    rts

calc_key:
    lda kernel_msg_p0
    cmp #'0'
    bcc @operator
    cmp #'9'+1
    bcs @operator
    sec
    sbc #'0'
    sta calc_temp
    lda calc_entry
    bne @append
    lda #0
    sta calc_value
    sta calc_value+1
    lda #1
    sta calc_entry
@append:
    ; Deliberately bounded 8-bit pocket arithmetic: value=value*10+digit.
    lda calc_value
    asl
    sta calc_aux
    asl
    asl
    clc
    adc calc_aux
    clc
    adc calc_temp
    sta calc_value
    jmp desktop_request_draw
@operator:
    cmp #'C'
    beq @clear_draw
    cmp #'='
    beq calc_equals
    cmp #'+'
    beq @set_op
    cmp #'-'
    beq @set_op
    cmp #'*'
    beq @set_op
    cmp #'/'
    beq @set_op
    rts
@set_op:
    sta calc_op
    lda calc_value
    sta calc_left
    lda #0
    sta calc_entry
    jmp desktop_request_draw
@clear_draw:
    jsr calc_clear
    jmp desktop_request_draw

calc_equals:
    lda calc_op
    cmp #'+'
    beq @add
    cmp #'-'
    beq @subtract
    cmp #'*'
    beq @multiply
    cmp #'/'
    beq @divide
    rts
@add:
    lda calc_left
    clc
    adc calc_value
    sta calc_value
    jmp @finished
@subtract:
    lda calc_left
    sec
    sbc calc_value
    sta calc_value
    jmp @finished
@multiply:
    lda #0
    sta calc_temp
    lda calc_left
    sta calc_aux
    lda calc_value
    sta calc_value+1
    ldx #8
@mul_loop:
    lsr calc_value+1
    bcc @mul_shift
    lda calc_temp
    clc
    adc calc_aux
    sta calc_temp
@mul_shift:
    asl calc_aux
    dex
    bne @mul_loop
    lda calc_temp
    sta calc_value
    jmp @finished
@divide:
    lda calc_value
    beq @zero
    sta calc_aux
    lda calc_left
    ldx #0
@div_loop:
    cmp calc_aux
    bcc @div_done
    sec
    sbc calc_aux
    inx
    bne @div_loop
@div_done:
    stx calc_value
    jmp @finished
@zero:
    lda #0
    sta calc_value
@finished:
    lda #0
    sta calc_entry
    sta calc_op
    jmp desktop_request_draw

calc_format_value:
    lda #' '
    sta calc_display
    sta calc_display+1
    sta calc_display+2
    lda #0
    sta calc_display+3
    lda calc_value
    ldx #0
@hundreds:
    cmp #100
    bcc @tens_start
    sec
    sbc #100
    inx
    bne @hundreds
@tens_start:
    stx calc_temp
    ldx #0
@tens:
    cmp #10
    bcc @ones
    sec
    sbc #10
    inx
    bne @tens
@ones:
    pha
    lda calc_temp
    beq @no_hundreds
    clc
    adc #'0'
    sta calc_display
@no_hundreds:
    txa
    cpx #0
    bne @write_tens
    lda calc_temp
    beq @skip_tens
    lda #0
@write_tens:
    clc
    adc #'0'
    sta calc_display+1
@skip_tens:
    pla
    clc
    adc #'0'
    sta calc_display+2
    rts

calc_render:
    jsr calc_format_value
    lda #<str_calc_title
    sta video_text_ptr
    lda #>str_calc_title
    sta video_text_ptr+1
    lda #6
    ldx #1
    jsr video_print_at
    lda #<str_calc_help
    sta video_text_ptr
    lda #>str_calc_help
    sta video_text_ptr+1
    lda #2
    ldx #3
    jsr video_print_at
    lda #<str_calc_box
    sta video_text_ptr
    lda #>str_calc_box
    sta video_text_ptr+1
    lda #10
    ldx #7
    jsr video_print_at
    lda #<calc_display
    sta video_text_ptr
    lda #>calc_display
    sta video_text_ptr+1
    lda #17
    ldx #7
    jmp video_print_at
