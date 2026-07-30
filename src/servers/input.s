input_handler:
    lda kernel_msg_type
    cmp #MSG_INIT
    beq input_init
    cmp #MSG_TICK
    beq input_tick
    rts

input_init:
    lda #$1F
    sta input_last_joy
    rts

input_tick:
    jsr KERNAL_GETIN
    beq @joystick
    tay
    cpy #KEY_F1
    beq @desktop_key
    ldx active_view
    lda input_view_services,x
    ldx #MSG_KEY
    jsr kernel_send
    jmp @joystick
@desktop_key:
    lda #SERVICE_DESKTOP
    ldx #MSG_KEY
    jsr kernel_send
@joystick:
    lda CIA1_PORTA
    and #$1F
    cmp input_last_joy
    beq @done
    sta input_last_joy
    cmp #$1F
    beq @done
    and #$10
    beq @fire
    lda input_last_joy
    and #$01
    beq @up
    lda input_last_joy
    and #$02
    beq @down
    lda input_last_joy
    and #$04
    beq @left
    lda input_last_joy
    and #$08
    beq @right
    rts
@up:
    ldy #2
    bne @pointer
@down:
    ldy #3
    bne @pointer
@left:
    ldy #0
    beq @pointer
@right:
    ldy #1
@pointer:
    lda #SERVICE_DESKTOP
    ldx #MSG_POINTER
    jmp kernel_send
@fire:
    lda #SERVICE_DESKTOP
    ldx #MSG_ACTIVATE
    ldy #0
    jmp kernel_send
@done:
    rts
