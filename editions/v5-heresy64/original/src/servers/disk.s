disk_handler:
    lda kernel_msg_type
    cmp #MSG_INIT
    bne @not_init
    jmp disk_init
@not_init:
    cmp #MSG_DIR_REQUEST
    bne @not_dir
    jmp disk_directory
@not_dir:
    cmp #MSG_NOTE_SAVE
    bne @not_save
    jmp disk_note_save
@not_save:
    cmp #MSG_NOTE_LOAD
    bne @done
    jmp disk_note_load
@done:
    rts

disk_init:
    lda #0
    sta files_count
    sta notes_status
    rts

disk_directory:
    lda #0
    sta disk_name_length
    sta disk_capture
    ldx #0
@clear:
    sta disk_dir_names,x
    inx
    cpx #80
    bne @clear
    lda #0
    sta KERNAL_STATUS
    lda #1
    ldx #<disk_dir_spec
    ldy #>disk_dir_spec
    jsr KERNAL_SETNAM
    lda #2
    ldx #8
    ldy #0
    jsr KERNAL_SETLFS
    jsr KERNAL_OPEN
    lda KERNAL_STATUS
    beq @opened
    jmp @error_close
@opened:
    ldx #2
    jsr KERNAL_CHKIN
@read:
    jsr KERNAL_CHRIN
    sta disk_char
    lda KERNAL_STATUS
    bne @done
    lda disk_char
    cmp #$22
    beq @quote
    lda disk_capture
    beq @read
    ldx disk_name_index
    cpx #16
    bcs @read
    txa
    clc
    adc disk_io_index
    tax
    lda disk_char
    sta disk_dir_names,x
    inc disk_name_index
    jmp @read
@quote:
    lda disk_capture
    beq @start_name
    lda #0
    sta disk_capture
    lda disk_name_length
    cmp #5
    bcs @done
    inc disk_name_length
    jmp @read
@start_name:
    lda disk_name_length
    cmp #5
    bcs @done
    asl
    asl
    asl
    asl
    sta disk_io_index
    lda #0
    sta disk_name_index
    lda #1
    sta disk_capture
    jmp @read
@done:
    jsr KERNAL_CLRCHN
    lda #2
    jsr KERNAL_CLOSE
    lda disk_name_length
    sta kernel_tmp_p0
    lda #0
    sta kernel_arg1
    lda #SERVICE_FILES
    ldx #MSG_DISK_RESULT
    ldy kernel_tmp_p0
    jmp kernel_send
@error_close:
    lda #2
    jsr KERNAL_CLOSE
@error:
    lda #$FF
    sta kernel_arg1
    lda #SERVICE_FILES
    ldx #MSG_DISK_RESULT
    ldy #0
    jmp kernel_send

disk_note_save:
    ; Never SAVE@ over an existing 1541 file. Build a new sequential file,
    ; retire the old name, then atomically rename the survivor.
    lda #<disk_cmd_scratch_new
    ldx #>disk_cmd_scratch_new
    ldy #14
    jsr disk_command

    lda #0
    sta KERNAL_STATUS
    lda #14
    ldx #<disk_new_write
    ldy #>disk_new_write
    jsr KERNAL_SETNAM
    lda #2
    ldx #8
    ldy #2
    jsr KERNAL_SETLFS
    jsr KERNAL_OPEN
    lda KERNAL_STATUS
    bne @save_error_close
    ldx #2
    jsr KERNAL_CHKOUT
    ldx #0
@write:
    cpx notes_length
    beq @written
    lda notes_buffer,x
    jsr KERNAL_CHROUT
    inx
    bne @write
@written:
    jsr KERNAL_CLRCHN
    lda #2
    jsr KERNAL_CLOSE
    lda KERNAL_STATUS
    bne @save_error

    lda #<disk_cmd_scratch_note
    ldx #>disk_cmd_scratch_note
    ldy #14
    jsr disk_command
    lda #<disk_cmd_rename
    ldx #>disk_cmd_rename
    ldy #25
    jsr disk_command
    lda KERNAL_STATUS
    bne @save_error
    lda #1
    sta kernel_arg1
    lda #SERVICE_NOTES
    ldx #MSG_DISK_RESULT
    ldy #1
    jmp kernel_send
@save_error_close:
    lda #2
    jsr KERNAL_CLOSE
@save_error:
    lda #$FF
    sta kernel_arg1
    lda #SERVICE_NOTES
    ldx #MSG_DISK_RESULT
    ldy #1
    jmp kernel_send

disk_note_load:
    lda #10
    ldx #<disk_new_read
    ldy #>disk_new_read
    jsr disk_try_load
    bcc @loaded
    lda #11
    ldx #<disk_note_read
    ldy #>disk_note_read
    jsr disk_try_load
    bcc @loaded
    lda #$FF
    sta kernel_arg1
    lda #SERVICE_NOTES
    ldx #MSG_DISK_RESULT
    ldy #2
    jmp kernel_send
@loaded:
    lda #2
    sta kernel_arg1
    lda #SERVICE_NOTES
    ldx #MSG_DISK_RESULT
    ldy #2
    jmp kernel_send

disk_try_load:
    ; A=filename length, X/Y=pointer. Carry clear on success.
    sta disk_name_length
    stx kernel_arg2
    sty kernel_arg3
    lda #0
    sta KERNAL_STATUS
    lda disk_name_length
    ldx kernel_arg2
    ldy kernel_arg3
    jsr KERNAL_SETNAM
    lda #2
    ldx #8
    ldy #2
    jsr KERNAL_SETLFS
    jsr KERNAL_OPEN
    lda KERNAL_STATUS
    bne @fail_close
    ldx #2
    jsr KERNAL_CHKIN
    ldx #0
@read:
    jsr KERNAL_CHRIN
    sta disk_char
    lda KERNAL_STATUS
    and #$3F
    bne @finish
    cpx #160
    bcs @finish
    lda KERNAL_STATUS
    and #$40
    beq @store
    lda disk_char
    beq @finish
@store:
    lda disk_char
    sta notes_buffer,x
    inx
    lda KERNAL_STATUS
    and #$40
    beq @read
@finish:
    stx notes_length
    lda #0
    sta notes_buffer,x
    jsr KERNAL_CLRCHN
    lda #2
    jsr KERNAL_CLOSE
    clc
    rts
@fail_close:
    lda #2
    jsr KERNAL_CLOSE
    sec
    rts

disk_command:
    ; A=low pointer, X=high pointer, Y=length.
    sta kernel_arg2
    stx kernel_arg3
    sty disk_name_length
    lda #0
    sta KERNAL_STATUS
    lda disk_name_length
    ldx kernel_arg2
    ldy kernel_arg3
    jsr KERNAL_SETNAM
    lda #15
    ldx #8
    ldy #15
    jsr KERNAL_SETLFS
    jsr KERNAL_OPEN
    lda #15
    jmp KERNAL_CLOSE
