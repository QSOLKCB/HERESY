video_handler:
    lda kernel_msg_type
    cmp #MSG_INIT
    bne @not_init
    jmp video_init
@not_init:
    cmp #MSG_DRAW
    bne @not_draw
    jmp video_render_active
@not_draw:
    cmp #MSG_THEME
    bne @not_theme
    jmp video_toggle_theme
@not_theme:
    cmp #MSG_DEMO_FRAME
    bne @done
    jmp video_demo_frame
@done:
    rts

video_init:
    sei
    lda CPU_PORT
    pha
    lda #$33
    sta CPU_PORT
    lda #<$D000
    sta video_text_ptr
    lda #>$D000
    sta video_text_ptr+1
    lda #<$3000
    sta video_screen_ptr
    lda #>$3000
    sta video_screen_ptr+1
    ldx #8
@copy_page:
    ldy #0
@copy_byte:
    lda (video_text_ptr),y
    sta (video_screen_ptr),y
    iny
    bne @copy_byte
    inc video_text_ptr+1
    inc video_screen_ptr+1
    dex
    bne @copy_page
    pla
    sta CPU_PORT
    lda CIA2_PORTA
    ora #$03
    sta CIA2_PORTA
    lda #$1C
    sta VIC_MEMPTR
    lda #0
    sta VIC_SPR_EN
    sta video_theme
    lda #COLOR_DARK_GREY
    sta VIC_BORDER
    lda #COLOR_BLACK
    sta VIC_BG
    cli
    jmp video_render_active

video_toggle_theme:
    lda video_theme
    eor #1
    sta video_theme
    jmp video_render_active

video_clear:
    lda #$20
    ldx #0
@screen:
    sta SCREEN_RAM,x
    sta SCREEN_RAM+$100,x
    sta SCREEN_RAM+$200,x
    sta SCREEN_RAM+$300,x
    inx
    bne @screen
    ldx video_theme
    lda theme_text_colors,x
    ldx #0
@color:
    sta COLOR_RAM,x
    sta COLOR_RAM+$100,x
    sta COLOR_RAM+$200,x
    sta COLOR_RAM+$300,x
    inx
    bne @color
    rts

video_render_active:
    jsr video_clear
    lda active_view
    beq @desktop
    cmp #VIEW_FILES
    beq @files
    cmp #VIEW_NOTES
    beq @notes
    cmp #VIEW_CALC
    beq @calc
    cmp #VIEW_SYSTEM
    beq @system
    cmp #VIEW_DEMO
    beq @demo
@desktop:
    jmp desktop_render
@files:
    jmp files_render
@notes:
    jmp notes_render
@calc:
    jmp calc_render
@system:
    jmp system_render
@demo:
    jmp demo_render

video_set_cursor:
    ; A=column, X=row.
    sta video_tmp
    lda screen_rows_lo,x
    clc
    adc video_tmp
    sta video_screen_ptr
    lda screen_rows_hi,x
    adc #0
    sta video_screen_ptr+1
    lda color_rows_lo,x
    clc
    adc video_tmp
    sta video_color_ptr
    lda color_rows_hi,x
    adc #0
    sta video_color_ptr+1
    rts

video_print_at:
    ; A=column, X=row, video_text_ptr=zero-terminated PETSCII/ASCII.
    jsr video_set_cursor
    ldy #0
@loop:
    lda (video_text_ptr),y
    beq @done
    jsr video_to_screen
    sta (video_screen_ptr),y
    lda video_theme
    tax
    lda theme_text_colors,x
    sta (video_color_ptr),y
    iny
    cpy #40
    bne @loop
@done:
    rts

video_print_fixed16:
    ; A=column, X=row, video_text_ptr points at a padded 16-byte filename.
    jsr video_set_cursor
    ldy #0
@loop:
    lda (video_text_ptr),y
    beq @space
    cmp #$A0
    bne @convert
@space:
    lda #$20
@convert:
    jsr video_to_screen
    sta (video_screen_ptr),y
    lda #COLOR_LIGHT_BLUE
    sta (video_color_ptr),y
    iny
    cpy #16
    bne @loop
    rts

video_print_wrapped:
    ; A=length, source at video_text_ptr. Draw 36 columns from row 6.
    sta video_tmp2
    lda #2
    ldx #6
    jsr video_set_cursor
    ldx #0
    ldy #0
@loop:
    cpx video_tmp2
    beq @done
    lda (video_text_ptr),y
    jsr video_to_screen
    sta (video_screen_ptr),y
    lda #COLOR_WHITE
    sta (video_color_ptr),y
    inx
    iny
    cpy #36
    bne @loop
    lda video_text_ptr
    clc
    adc #36
    sta video_text_ptr
    bcc @source_ok
    inc video_text_ptr+1
@source_ok:
    lda video_screen_ptr
    clc
    adc #40
    sta video_screen_ptr
    bcc @screen_ok
    inc video_screen_ptr+1
@screen_ok:
    lda video_color_ptr
    clc
    adc #40
    sta video_color_ptr
    bcc @color_ok
    inc video_color_ptr+1
@color_ok:
    ldy #0
    cpx video_tmp2
    bne @loop
@done:
    rts

video_to_screen:
    cmp #'A'
    bcc @done
    cmp #'Z'+1
    bcs @done
    sec
    sbc #$40
@done:
    rts

video_demo_frame:
    lda active_view
    cmp #VIEW_DEMO
    bne @done
    jsr video_demo_scroller
    lda VIC_BG
    sta video_raster_saved
    ldx #0
@bar:
    lda demo_raster_lines,x
@wait:
    cmp VIC_RASTER
    bne @wait
    lda demo_raster_colors,x
    sta VIC_BG
    sta VIC_BORDER
    inx
    cpx #6
    bne @bar
    lda video_raster_saved
    sta VIC_BG
    lda #COLOR_DARK_GREY
    sta VIC_BORDER
@done:
    rts

video_demo_scroller:
    ldy #0
@char:
    tya
    clc
    adc kernel_msg_p0
    bcc @no_overflow
    clc
    adc #(256-DEMO_SCROLL_LEN)
    jmp @index
@no_overflow:
    cmp #DEMO_SCROLL_LEN
    bcc @index
    sbc #DEMO_SCROLL_LEN
@index:
    tax
    lda demo_scroll_text,x
    jsr video_to_screen
    sta SCREEN_RAM+(21*40),y
    lda #COLOR_LIGHT_GREEN
    sta COLOR_RAM+(21*40),y
    iny
    cpy #40
    bne @char
    ; A tiny activity meter proves the frame service is live.
    lda kernel_msg_p1
    and #$0F
    tax
    ldy #0
@meter:
    cpy #16
    beq @meter_done
    lda #$2E
    cpy #0
    beq @write_meter
    txa
    cmp #0
    beq @write_meter
    dex
    lda #$2A
@write_meter:
    jsr video_to_screen
    sta SCREEN_RAM+(18*40)+12,y
    lda #COLOR_YELLOW
    sta COLOR_RAM+(18*40)+12,y
    iny
    bne @meter
@meter_done:
    rts
