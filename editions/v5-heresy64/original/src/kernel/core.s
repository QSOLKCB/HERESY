; Stable kernel entry table. Keep order: external tests use the map to prove
; these facilities remain in the kernel rather than becoming app-local tricks.
kernel_jump_table:
    jmp kernel_send
    jmp kernel_dispatch
    jmp kernel_register
    jmp kernel_page_alloc
    jmp kernel_page_free
    jmp kernel_pending
    jmp kernel_ticks
    jmp kernel_pages_used
    jmp kernel_yield
kernel_core_start:

kernel_send:
    ; A=target, X=message type, Y=p0, kernel_arg1..5=remaining bytes.
    sta kernel_tmp_target
    stx kernel_tmp_type
    sty kernel_tmp_p0
    lda ipc_head
    clc
    adc #1
    and #IPC_MASK
    cmp ipc_tail
    beq @full
    sta kernel_tmp_next
    lda ipc_head
    asl
    asl
    asl
    tay
    lda kernel_tmp_target
    sta ipc_ring,y
    iny
    lda kernel_tmp_type
    sta ipc_ring,y
    iny
    lda kernel_tmp_p0
    sta ipc_ring,y
    iny
    lda kernel_arg1
    sta ipc_ring,y
    iny
    lda kernel_arg2
    sta ipc_ring,y
    iny
    lda kernel_arg3
    sta ipc_ring,y
    iny
    lda kernel_arg4
    sta ipc_ring,y
    iny
    lda kernel_arg5
    sta ipc_ring,y
    lda kernel_tmp_next
    sta ipc_head
    clc
    lda #0
    rts
@full:
    sec
    lda #1
    rts

kernel_dispatch:
    lda ipc_tail
    cmp ipc_head
    beq @empty
    asl
    asl
    asl
    tay
    lda ipc_ring,y
    sta kernel_msg_target
    iny
    lda ipc_ring,y
    sta kernel_msg_type
    iny
    lda ipc_ring,y
    sta kernel_msg_p0
    iny
    lda ipc_ring,y
    sta kernel_msg_p1
    iny
    lda ipc_ring,y
    sta kernel_msg_p2
    iny
    lda ipc_ring,y
    sta kernel_msg_p3
    iny
    lda ipc_ring,y
    sta kernel_msg_p4
    iny
    lda ipc_ring,y
    sta kernel_msg_p5
    lda ipc_tail
    clc
    adc #1
    and #IPC_MASK
    sta ipc_tail
    ldx kernel_msg_target
    cpx #SERVICE_COUNT
    bcs @empty
    lda service_handlers_lo,x
    sta kernel_call_ptr
    lda service_handlers_hi,x
    sta kernel_call_ptr+1
    ora kernel_call_ptr
    beq @empty
    jsr kernel_call_handler
    clc
    lda #1
    rts
@empty:
    clc
    lda #0
    rts

kernel_call_handler:
    jmp (kernel_call_ptr)

kernel_register:
    ; A=service id, kernel_arg0/1=handler.
    tax
    cpx #SERVICE_COUNT
    bcs @bad
    lda kernel_arg0
    sta service_handlers_lo,x
    lda kernel_arg1
    sta service_handlers_hi,x
    clc
    rts
@bad:
    sec
    rts

kernel_page_alloc:
    ldx #0
@scan:
    lda page_bitmap,x
    beq @claim
    inx
    cpx #PAGE_COUNT
    bne @scan
    sec
    lda #$FF
    rts
@claim:
    lda #1
    sta page_bitmap,x
    txa
    pha
    clc
    adc #PAGE_BASE_HI
    sta kernel_page_hi
    pla
    clc
    rts

kernel_page_free:
    ; A=page index.
    tax
    cpx #PAGE_COUNT
    bcs @bad
    lda #0
    sta page_bitmap,x
    clc
    rts
@bad:
    sec
    rts

kernel_pending:
    lda ipc_head
    cmp ipc_tail
    beq @none
    lda #1
    rts
@none:
    lda #0
    rts

kernel_ticks:
    lda kernel_tick_count
    ldx kernel_tick_count+1
    rts

kernel_pages_used:
    ldx #0
    ldy #0
@count:
    lda page_bitmap,x
    beq @next
    iny
@next:
    inx
    cpx #PAGE_COUNT
    bne @count
    tya
    rts

kernel_yield:
    jmp kernel_dispatch

kernel_handler:
    rts

kernel_core_end:
