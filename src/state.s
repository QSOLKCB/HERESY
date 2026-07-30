; Kernel state
ipc_ring:             .res 256
ipc_head:             .res 1
ipc_tail:             .res 1
service_handlers_lo:  .res SERVICE_COUNT
service_handlers_hi:  .res SERVICE_COUNT
service_pages:        .res SERVICE_COUNT
page_bitmap:          .res PAGE_COUNT
kernel_tick_count:    .res 2
last_jiffy:           .res 1
kernel_arg0:          .res 1
kernel_arg1:          .res 1
kernel_arg2:          .res 1
kernel_arg3:          .res 1
kernel_arg4:          .res 1
kernel_arg5:          .res 1
kernel_msg_target:    .res 1
kernel_msg_type:      .res 1
kernel_msg_p0:        .res 1
kernel_msg_p1:        .res 1
kernel_msg_p2:        .res 1
kernel_msg_p3:        .res 1
kernel_msg_p4:        .res 1
kernel_msg_p5:        .res 1
kernel_tmp_target:    .res 1
kernel_tmp_type:      .res 1
kernel_tmp_p0:        .res 1
kernel_tmp_next:      .res 1
kernel_tmp_page:      .res 1
kernel_page_hi:       .res 1
kernel_call_ptr:      .res 2

; Shared drawing scratch, exclusively used by VIDEOD.
video_tmp:            .res 1
video_tmp2:           .res 1
video_theme:          .res 1
video_raster_saved:   .res 1

; Input state
input_last_joy:       .res 1

; Desktop and application state
active_view:          .res 1
desktop_selection:    .res 1
files_count:          .res 1
files_status:         .res 1
notes_length:         .res 1
notes_status:         .res 1
notes_buffer:         .res 161
calc_value:           .res 2
calc_left:            .res 2
calc_op:              .res 1
calc_entry:           .res 1
calc_display:         .res 8
calc_temp:            .res 2
calc_aux:             .res 2
system_status:        .res 1

; DISKD state
disk_name_length:     .res 1
disk_capture:         .res 1
disk_name_index:      .res 1
disk_char:            .res 1
disk_dir_names:       .res 80
disk_io_mode:         .res 1
disk_io_index:        .res 1

; AUDIOD and DEMOD state
audio_enabled:        .res 1
audio_note:           .res 1
demo_frame:           .res 1
demo_scroll:          .res 2
demo_music:           .res 1
demo_divider:         .res 1
