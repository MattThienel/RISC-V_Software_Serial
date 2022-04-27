.section .text

.equ GPIO_BASE_ADDRESS, 0x10012000

.equ output_en, 0x08
.equ output_val, 0x0C

.equ SERIAL_CLK_PIN, 20
.equ SERIAL_DATA_PIN, 21
.equ SERIAL_PINS, 1<<SERIAL_CLK_PIN + 1<<SERIAL_DATA_PIN
.equ SERIAL_PINS_MASK, ~SERIAL_PINS
.equ DATA_PIN_ON, 1<<SERIAL_DATA_PIN
.equ DATA_PIN_OFF, ~DATA_PIN_ON

# Transmit Only Serial Interface
# GPIO Pins Digital 14 (clk) & 15 (data)
# Clock is active high 

.global serial_init 
serial_init:
	li t0, GPIO_BASE_ADDRESS # Load address of gpio memory
	li t1, SERIAL_PINS # Load which pins should be output enabled

	sw t1, output_en(t0) # Set clock and data pin to output enable
	not t1, t1
	lw t2, output_val(t0) # Read gpio output memory
	and t2, t2, t1 # Clear output of clock and data pins
	sw t2, output_val(t0) # Load cleared output into gpio memory

	ret

# a0 holds byte to put on parallel bus
.global serial_write_byte
serial_write_byte:
	# Push registers to stack
	addi sp, sp, -36
	sw ra, 0(sp)
	sw s0, 4(sp)
	sw s1, 8(sp)
	sw s2, 12(sp)
	sw s3, 16(sp)
	sw s4, 20(sp)
	sw s5, 24(sp)
	sw s6, 28(sp)
	sw s7, 32(sp)

	li s0, GPIO_BASE_ADDRESS
	addi s1, x0, 8	 # Bit counter
	addi s2, x0, 0x1 # Data mask
	li s5, DATA_PIN_ON # Data pin on bitfield
	li s6, DATA_PIN_OFF # Data pin off mask
	addi s7, a0, 0

loop:
	and s3, s7, s2 # Mask next data bit
	lw s4, output_val(s0) # Load gpio output
	beq s3, x0, 2f # Branch if next data bit is zero
   # Data is a one, set output
	or s3, s3, s5 # Set gpio data pin
	beq x0, x0, 3f
2: # Data is a zero, clear output
	and s3, s3, s6 # Clear gpio data pin
3:
	sw s3, output_val(s0) # Update data output
	# Set clock	
	li s4, 1<<SERIAL_CLK_PIN # Generate clock on bitfield
	or s3, s3, s4 # Set clock pin to high
	sw s3, output_val(s0)
	
	# Delay 
	li a0, 0xFA2400
	jal ra, delay
	
	# Clear clock
	not s4, s4 # Generate clock off mask
	and s3, s3, s4 # Set clock pin to low
	sw s3, output_val(s0) 

	# Delay 
	li a0, 0xFA2400
	jal ra, delay

	srli s7, s7, 1 # Get next bit
	addi s1, s1, -1 # Decrement bit counter
	bgtz s1, loop # Loop until byte is written to data output

	# Pop registers from stack
	lw s7, 32(sp)
	lw s6, 28(sp)
	lw s5, 24(sp)
	lw s4, 20(sp)
	lw s3, 16(sp)
	lw s2, 12(sp)
	lw s1, 8(sp)
	lw s0, 4(sp)
	lw ra, 0(sp)
	addi sp, sp, 36

	ret

.global delay
# a0 number of instructions to delay by
delay:
1:
	addi a0, a0, -1
	bne a0, x0, 1b

	ret

