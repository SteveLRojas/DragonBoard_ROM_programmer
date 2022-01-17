import argparse
import serial 
from enum import Enum

####################
# Constants        #
####################
# CLI Commands
class Command(Enum):
	READ = 1
	WRITE = 2
	VERIFY = 3

# Ping
HS_PINGREQ = "AA55"
HS_PINGRES = "55AA"
PING_RESPONSE_SIZE = 2
SIZE_RESPONSE_SIZE = 3

# Read
HS_READ_CMD ="01"
READ_CMD_RESPONSE_SIZE = 3

# Write
HS_WRITE_CMD = "02"
WRITE_CMD_RESPONSE_SIZE = 3


####################
# Command Parsers  #
####################
def parseCommand(cleanCommandString):
	if (cleanCommandString == ""):
		print("No command provided!")
		exit(1)
	if (cleanCommandString == "READ"):
		return Command.READ 
	if (cleanCommandString == "WRITE"):
		return Command.WRITE 
	if (cleanCommandString == "VERIFY"):
		return Command.VERIFY 
	else:
		print("Invalid command provided!")
		exit(1)


# Command Helpers  #


def readTarget(serialObj):
	# Ping w/ $AA55
	packetPing = bytes.fromhex(HS_PINGREQ)
	serialObj.write(packetPing)

	# Expect $55AA Size[3] back
	res = serialObj.read(PING_RESPONSE_SIZE)
	resHexString = ''.join(format(x, '02X') for x in res)
	print(resHexString)
	if (resHexString != HS_PINGRES):
		if (resHexString == "0000"):	#if we get an error response (size response with value 0)
			res = serialObj.read(1)	#read the last size response byte
			return readTarget(serialObj)	#try again
		else:
			print ("Invalid handshake response from target! Exiting...")
			exit(1)

	res = serialObj.read(SIZE_RESPONSE_SIZE)

	# Send READ Command
	serialObj.write(bytes.fromhex(HS_READ_CMD))
	serialObj.write(res)
	readCmdRes = serialObj.read(READ_CMD_RESPONSE_SIZE) 
	readSize = int.from_bytes(readCmdRes, byteorder='big', signed=False)
	print ("readSize: " + str(readSize))

	# Read data from Target and write to file
	serialObj.timeout = 100
	return serialObj.read(readSize)

####################
# Command Handlers #
####################
def handleRead(serialObj, fileName):
	file = open(fileName,"wb+")

	data = readTarget(serialObj)

	print(len(data))
	file.write(data)
	file.close()

def handleWrite(serialObj, fileName):
	file = open(fileName,"rb")
	file_data = bytearray(file.read())
	file_size = len(file_data)

	# Ping w/ $AA55
	packetPing = bytes.fromhex(HS_PINGREQ)
	serialObj.write(packetPing)

	# Expect $55AA Size[3] back
	res = serialObj.read(PING_RESPONSE_SIZE)
	resHexString = ''.join(format(x, '02X') for x in res)
	print(resHexString)
	if (resHexString != HS_PINGRES):
		if (resHexString == "0000"):	#if we get an error response (size response with value 0)
			res = serialObj.read(1)	#read the last size response byte
			return handleWrite(serialObj, fileName)	#try again
		else:
			print ("Invalid handshake response from target! Exiting...")
			exit(1)

	res = serialObj.read(SIZE_RESPONSE_SIZE)
	mem_size = int.from_bytes(res, byteorder='big', signed=False)
	if(file_size > mem_size):
		print("File is larger than memory")
		exit(1)

	# Send WRITE Command
	serialObj.write(bytes.fromhex(HS_WRITE_CMD))
	serialObj.write(file_size.to_bytes(3, 'big'))

	#transfer blocks
	bytes_written = 0
	while bytes_written != file_size:
		serialObj.timeout = 10
		res = serialObj.read(WRITE_CMD_RESPONSE_SIZE)
		block_size = int.from_bytes(res, byteorder='big', signed=False)
		print(block_size)
		if (block_size == 0):
			print("Error transfering data!")
			exit(1)
		current_block = file_data[bytes_written : bytes_written + block_size]
		serialObj.timeout = 100
		serialObj.write(current_block)
		bytes_written = bytes_written + block_size
	serialObj.timeout = 10
	res = serialObj.read(WRITE_CMD_RESPONSE_SIZE)
	resHexString = ''.join(format(x, '02X') for x in res)
	print(resHexString)
	file.close()

def handleVerify(serialObj, fileName):
	file = open(fileName,"rb")
	refData = bytes(file.read())
	refDataLen = len(refData)

	targetData = readTarget(serialObj)
	print("Target data matches reference file? -- " + str(targetData == refData).upper())

	file.close()

####################
# Entry            #
####################
def main():
	parser = argparse.ArgumentParser()
	parser.add_argument("command", help="The command to perform [Read, Write, Verify]")
	parser.add_argument("file", help="The file to read from for a Write or Verify, or write to for a Read.")
	parser.add_argument("port", help="The COM port to use.")
	args = parser.parse_args()

	cmd = parseCommand(args.command.strip().upper())

	baudrate = 115200
	ser = serial.Serial()
	ser.baudrate = baudrate
	ser.port = args.port
	ser.dsrdtr = False
	ser.dtr = False
	ser.timeout = 1
	ser.open()

	if (cmd == Command.READ):
		handleRead(ser, args.file)
	elif (cmd == Command.WRITE):
		handleWrite(ser, args.file)
	elif (cmd == Command.VERIFY):
		handleVerify(ser, args.file)
	else:
		print("No handler for command! Command:[" + cmd + "]")

	ser.close()


if __name__ == "__main__":
    # execute only if run as a script
    main()