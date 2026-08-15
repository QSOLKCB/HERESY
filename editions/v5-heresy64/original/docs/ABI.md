# HERESY/64 service ABI

HERESY/64 uses one bounded, cooperative message queue. Every record is exactly
eight bytes:

| Byte | Meaning |
| ---: | --- |
| 0 | target service ID |
| 1 | message type |
| 2 | parameter 0 |
| 3 | parameter 1 |
| 4 | parameter 2 |
| 5 | parameter 3 |
| 6 | parameter 4 |
| 7 | parameter 5 |

The ring has 32 slots at `$C000`. `ipc_head` identifies the next write slot and
`ipc_tail` the next dispatch slot. One slot remains empty so full and empty
states are unambiguous. `kernel_send` returns carry set and `A=1` when the ring
is full; it never allocates, blocks, retries, or starts Kafka.

## Calling convention

For `kernel_send`:

- `A`: target service;
- `X`: message type;
- `Y`: parameter 0;
- `kernel_arg1` … `kernel_arg5`: parameters 1 … 5.

On dispatch, the kernel copies a record to `kernel_msg_target`,
`kernel_msg_type`, and `kernel_msg_p0` … `kernel_msg_p5`, advances the tail,
then calls the registered handler. Handlers use normal `RTS` semantics and
must return promptly.

## Service IDs

| ID | Service |
| ---: | --- |
| 0 | kernel |
| 1 | input |
| 2 | video |
| 3 | disk |
| 4 | desktop |
| 5 | files |
| 6 | notes |
| 7 | calculator |
| 8 | system |
| 9 | audio |
| 10 | demo |

## Messages

| ID | Name | Primary use |
| ---: | --- | --- |
| 1 | `MSG_INIT` | initialise service state |
| 2 | `MSG_TICK` | cooperative clock event |
| 3 | `MSG_KEY` | PETSCII key in parameter 0 |
| 4 | `MSG_POINTER` | joystick direction in parameter 0 |
| 5 | `MSG_ACTIVATE` | application activation |
| 6 | `MSG_DRAW` | redraw active view |
| 7 | `MSG_DIR_REQUEST` | request device-8 directory |
| 8 | `MSG_DISK_RESULT` | disk result/status |
| 9 | `MSG_NOTE_SAVE` | commit note |
| 10 | `MSG_NOTE_LOAD` | recover note |
| 11 | `MSG_THEME` | toggle video theme |
| 12 | `MSG_DEMO_FRAME` | render raster/scroller frame |
| 13 | `MSG_AUDIO_TONE` | play indexed SID tone |
| 14 | `MSG_AUDIO_SILENCE` | close SID gate |

The ABI is intentionally fixed. Version negotiation was rejected because all
eleven participants ship inside the same 5,424-byte executable.
