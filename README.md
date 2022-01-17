# DragonBoard_ROM_programmer
Programmer solution for the DragonBoard's I2C EEPROM.

usage: riptide_rom_programmer.py [-h] command file port

positional arguments:
  command     The command to perform [Read, Write, Verify]
  file        The file to read from for a Write or Verify, or write to for a
              Read.
  port        The COM port to use.
