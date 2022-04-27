.section .entry, "ax"

.global _start
_start:

	jal ra, serial_init # Initialize serial output
	
1:	
	addi a0, x0, 0xA5 # Load first byte
	jal ra, serial_write_byte # Jump to serial_write_byte function

	li a0, 0x0FFFFFFF # Load delay count
	jal ra, delay # Add delay between bytes

	addi a0, x0, 0x83 # Load second byte
	jal ra, serial_write_byte # Write byte

	li a0, 0x0FFFFFFF # Delay
	jal ra, delay 

	beq x0, x0, 1b # Loop output forever
