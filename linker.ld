MEMORY
{
	flash (rx) : ORIGIN = 0x20010000, LENGTH = 512M
	ram (rwx) : ORIGIN = 0x80000000, LENGTH = 16K
}

ENTRY(_start)

SECTIONS
{

	.text :
	{
		KEEP(*(.entry))
		*(.text)
	} > flash

	.rodata :
	{
		*(.rodata)
	} > flash

	.data :
	{
		*(.tile_memory)
	} > ram
}
