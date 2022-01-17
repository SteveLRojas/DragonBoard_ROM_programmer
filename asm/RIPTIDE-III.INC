;                     /\         /\__
;                   // \       (  0 )_____/\            __
;                  // \ \     (vv          o|          /^v\
;                //    \ \   (vvvv  ___-----^        /^^/\vv\
;              //  /     \ \ |vvvvv/               /^^/    \v\
;             //  /       (\\/vvvv/              /^^/       \v\
;            //  /  /  \ (  /vvvv/              /^^/---(     \v\
;           //  /  /    \( /vvvv/----(O        /^^/           \v\
;          //  /  /  \  (/vvvv/               /^^/             \v|
;        //  /  /    \( vvvv/                /^^/               ||
;       //  /  /    (  vvvv/                 |^^|              //
;      //  / /    (  |vvvv|                  /^^/            //
;     //  / /   (    \vvvvv\          )-----/^^/           //
;    // / / (          \vvvvv\            /^^^/          //
;   /// /(               \vvvvv\        /^^^^/          //
;  ///(              )-----\vvvvv\    /^^^^/-----(      \\
; //(                        \vvvvv\/^^^^/               \\
;/(                            \vvvv^^^/                 //
;                                \vv^/         /        //
;                                             /<______//
;                                            <<<------/
;                                             \<
;                                              \
;**************************************************
;* RIPTIDE-II.INC     HEADER FILE                 *
;* Copyright (C) 2021 Esteban Looser-Rojas.       *
;* Contains register defines the RIPTIDE-II CPU   *
;* and address defines for platform peripherals.  *
;* Addresses are for the RIPTIDE-II test platform.*
;**************************************************

; Address map for left bank:
; 0x0000 to 0x0FFF video memory (read write)
; 0x1000 to 0xFFEB	reserved
; 0xFFEC to 0xFFED	I2C module (read write)
; 0xFFEE to 0xFFEF	interrupt controller (read write)
; 0xFFF0 to 0xFFF3	timer module
; 0xFFF4 to 0xFFF5 keyboard module (read write)
; 0xFFF6 to 0xFFF7 video mode register (write only)
; 0xFFF8 to 0xFFFB memory subsystem control registers	(write only)
; 0xFFFC to 0xFFFD	HEX display registers	(write only)
; 0xFFFE to 0xFFFF	RS-232 module	(read write)

; MSC Address map
; 0x0 program space control register
; 	bit0	reset bit (LSB)
; 	bit1	reserved
; 	bit2	reserved
; 	bit3	control enable bit
; 0x1 program space page register
; 0x2 data space control register
; 	bit0	reset bit (LSB)
; 	bit1	flush bit
; 	bit2	reserved
; 	bit3	control enable bit
; 0x3 data space page register

; RS-232 module address map
; 0 data register
; 1 status register
;		bit 0: TX overwrite (LSB)
;		bit 1: RX overwrite
;		bit 2: TX ready
;		bit 3: RX ready
;		bit 4: TX queue empty
;		bit 5: RX queue full

; keyboard module address map
; 0 data register
; 1 status register
;		bit 0: TX overwrite (LSB)
;		bit 1: RX overwrite
;		bit 2: TX ready
;		bit 3: RX ready
;		bit 4: TX queue empty
;		bit 5: RX queue full

; Timer module address map
; 0 counter bits 7:0
; 1 counter bits 15:8
; 2 counter bits 23:16
; 3 status
;		bit 0: counter 7:0 not zero
;		bit 1: counter 15:8 not zero
;		bit 2: counter 23:16 not zero
;		bit 3: counter 23:0 not zero
;		bit 4: VSYNC
;		bit 5: HSYNC

; Interrupt controller address map
; 0 status register
; 1 control register

; I2C module address map
; 0 data register
; 1 status and control register
;		bit 0: START
;		bit 1: STOP
;		bit 2: READ_REQ
;		bit 3: WRITE_REQ
;		bit 4: MASTER_ACK
;		bit 5: SLAVE_ACK
;		bit 6: READY
;REMEMBER: READING OR WRITING I2C_DATA CLEARS THE READY BIT.
;WRITING I2C_STATUS ALSO CLEARS THE READY FLAG, BUT READING I2C_STATUS DOES NOT.
;THE I2C MODULE HAS 2 CYCLE LATENCY, DO NOT READ I2C_STATUS IMMEDIATELY AFTER CLEARING IT.

; Address map for right bank:
; 0x0000 to 0xFFFF	active data memory page (cached)

; Address map for program space:
; 0x0000 to 0xFFFF	active program memory page (cached)

; REMEMBER: PROGRAM MEMORY IS WORD ADDRESSABLE WHILE DATA MEMORY IS BYTE ADDRESSABLE!
; THE TWO MEMORY SPACES ARE SHARED THROUGH THE CACHE CONTROLLERS, BOTH CACHES MUST BE FLUSHED FOR CHANGES TO THE DATA SPACE TO SHOW UP IN THE PROGRAM SPACE.

IVL EQU R7
IVR EQU R17
AUX EQU R0
OVF EQU R10

DATA0 EQU RIV0
DATA1 EQU RIV1
DATA2 EQU RIV2
DATA3 EQU RIV3
DATA4 EQU RIV4
DATA5 EQU RIV5
DATA6 EQU RIV6
DATA7 EQU RIV7

IO0 EQU LIV0
IO1 EQU LIV1
IO2 EQU LIV2
IO3 EQU LIV3
IO4 EQU LIV4
IO5 EQU LIV5
IO6 EQU LIV6
IO7 EQU LIV7

ADDR_HIGH EQU IVL
ADDR_LOW EQU IVR

TIMER_COUNT_0 EQU $FFF0
TIMER_COUNT_1 EQU $FFF1
TIMER_COUNT_2 EQU $FFF2
TIMER_STATUS EQU $FFF3

KB_DATA EQU $FFF4
KB_STATUS EQU $FFF5

V_MODE EQU $FFF6
VGA_MODE EQU $FFF7	;THESE TWO ARE THE SAME REGISTER

MSC_P_CONTROL EQU $FFF8
MSC_P_PAGE EQU $FFF9
MSC_D_CONTROL EQU $FFFA
MSC_D_PAGE EQU $FFFB

HEX_LOW EQU $FFFC
HEX_HIGH EQU $FFFD

UART_DATA EQU $FFFE
UART_STATUS EQU $FFFF

INTERRUPT_STATUS EQU $FFEE
INTERRUPT_CONTROL EQU $FFEF

I2C_DATA EQU $FFEC
I2C_STATUS EQU $FFED
