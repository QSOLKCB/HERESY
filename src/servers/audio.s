audio_handler:
    lda kernel_msg_type
    cmp #MSG_INIT
    beq audio_init
    cmp #MSG_AUDIO_TONE
    beq audio_tone
    cmp #MSG_AUDIO_SILENCE
    beq audio_silence
    rts

audio_init:
    lda #0
    sta SID_V1_CTRL
    lda #$09
    sta SID_V1_AD
    lda #$88
    sta SID_V1_SR
    lda #$0F
    sta SID_VOLUME
    lda #1
    sta audio_enabled
    rts

audio_tone:
    lda audio_enabled
    beq @done
    lda kernel_msg_p0
    and #7
    tax
    stx audio_note
    lda sid_freq_lo,x
    sta SID_V1_FREQ_LO
    lda sid_freq_hi,x
    sta SID_V1_FREQ_HI
    lda #$21
    sta SID_V1_CTRL
@done:
    rts

audio_silence:
    lda #0
    sta SID_V1_CTRL
    rts
