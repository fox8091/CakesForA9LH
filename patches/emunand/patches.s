.nds

#!variables

.create "patch1.bin"
.arm
nand_sd:
    ; Original code that still needs to be executed.
    mov r4, r0
    mov r5, r1
    mov r7, r2
    mov r6, r3
    ; End.

    ; If we're already trying to access the SD, return.
    ldr r2, [r0, #4]
    ldr r1, =sdmmc
    cmp r2, r1
    beq nand_sd_ret

    str r1, [r0, #4]  ; Set object to be SD
    ldr r2, [r0, #8]  ; Get sector to read
    cmp r2, #0  ; For GW compatibility, see if we're trying to read the ncsd header (sector 0)

    ldr r3, =nand_offset
    ldr r3, [r3]
    add r2, r3  ; Add the offset to the NAND in the SD.

    ldreq r3, =ncsd_header_offset
    ldreq r3, [r3]
    addeq r2, r3  ; If we're reading the ncsd header, add the offset of that sector.

    str r2, [r0, #8]  ; Store sector to read

    nand_sd_ret:
        ; Restore registers.
        mov r1, r5
        mov r2, r7
        mov r3, r6

        ; Return 4 bytes behind where we got called,
        ;   due to the offset of this function being stored there.
        mov r0, lr
        add r0, #4
        bx r0
.pool
nand_offset:		.ascii "NAND"       ; for rednand this should be 1
ncsd_header_offset:	.ascii "NCSD"       ; depends on nand manufacturer + emunand type (GW/RED)
.close

.create "patch2.bin"
.arm
	.word 0x360003
	.word 0x10100000
	.word 0x1000001
	.word 0x360003
	.word 0x20000000
	.word 0x1010101
	.word 0x200603
	.word 0x8000000
	.word 0x1010101
	.word 0x1C0603
	.word 0x8020000
.close

.create "patch3.bin"
.thumb
	ldr r4, =nand_sd
	blx r4
.pool
.close

.create "patch4.bin"
.thumb
	ldr r4, =nand_sd
	blx r4
.pool
.close
