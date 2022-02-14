# DragonBoard_ROM_programmer
Programmer solution for the DragonBoard's I2C EEPROM.

## Usage

#### Hardware
Use the Quartus project provided to program your DragonBoard. Connect the board to your PC using the USB port.

#### Assembly
_The Quartus project already contains the assembled code, so this step is only needed if you make any changes to asm source files._

Assemble the [asm/riptide_rom_programmer.asm](asm/riptide_rom_programmer.asm) file to create a mif file (use the 8X-RIPTIDE_Assembler project).  
Put the mif file in the Quartus project folder and press the compile button to generate a new programming file.  

#### Programming the EEPROM

Use the Python script [py/riptide_rom_programmer.py](py/riptide_rom_programmer.py) to program the board's EEPROM, read the target board's EEPROM's data to an output file, or verify the contents of the target against a reference file.

```
usage: riptide_rom_programmer.py [-h] command file port

positional arguments:
  command     The command to perform [Read, Write, Verify]
  file        The file to read from for a Write or Verify, or write to for a Read.
  port        The COM port to use.
```
