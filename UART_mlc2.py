import argparse
import serial
import threading
from time import sleep

# Convert hex string to byte stream
def hexstr2byte(hexstream):

  if (len(hexstream)%2) != 0:
    print('Error converting hex string to bytes: odd number of chars')
    print('-> {}'.format(hexstream))
    return b''

  bytestream = b''
  for i in range(len(hexstream)):
    if (i%2)==0:
      curr_int = int(hexstream[i:(i+2)],16)
      bytestream = bytestream + (curr_int).to_bytes(1,'big')

  return bytestream

# Parser
parser = argparse.ArgumentParser()
parser.add_argument("-d", "--device", help="UART device")
parser.add_argument("-b", "--baud", help="UART device")
parser.add_argument("-t", "--timeout", help="Timeout")
parser.add_argument("-w", "--wait", help="Wait time after last tx before closing")
parser.add_argument("-r", "--register", help="1-byte register address in hex")
parser.add_argument("data", help="32-bit data in hex")
args = parser.parse_args()

if args.device:
  serdev = args.device
else:
  serdev = '/dev/ttyUSB2'

if args.baud:
  baud = int(args.baud)
else:
  baud = 9600

if args.timeout:
  timeout = float(args.timeout)
else:
  timeout = 1

if args.wait:
  waittime = float(args.wait)
else:
  waittime = 0.1

if args.register:
  addr = args.register
  if len(addr) > 8:
    print('Invalid address')
    quit()
  if len(addr) != 8:
    for i in range(8-len(addr)):
      addr = '0' + addr
else:
  addr = '00000000'

data = args.data 
if len(data) > 8:
  print('Invalid data')
  quit()
if len(data) != 8:
  for i in range(8-len(data)):
    data = '0' + data

# Intialize serial
ser = serial.Serial(port=serdev, baudrate=baud, timeout=timeout)

# Thread for logging data
def uart_rx(ser):
  while True:
    rxdata = ser.readline()
    if rxdata != '':
      rxalldata = rxalldata + rxdata
      for i in rxdata:
        print('{:02X}'.format(i))
    global stop_threads
    if stop_threads:
      break

## Send Command

  print('cmd: {}'.format(str))
  cmd = hexstr2byte(str)
  ser.write(cmd)
  sleep(0.1)
  
success = 0
while success==0:

  #stop_threads = False
  #thread = threading.Thread(target=uart_rx, args=(ser,))
  #thread.start()

  str = '53' + '00' + '01' + '15'
  print('cmd: {}'.format(str))
  ser.write(hexstr2byte('53'))
  sleep(0.00001)
  ser.write(hexstr2byte('00'))
  sleep(0.00001)
  ser.write(hexstr2byte('01'))
  sleep(0.00001)
  ser.write(hexstr2byte('15'))
  sleep(0.1)
  
  str = '5c' + '00'
  print('cmd: {}'.format(str))
  ser.write(hexstr2byte('5c'))
  sleep(0.00001)
  ser.write(hexstr2byte('00'))
  sleep(0.1)

  str = '53' + '00' + '00' + '00'
  print('cmd: {}'.format(str))
  ser.write(hexstr2byte('53'))
  sleep(0.00001)
  ser.write(hexstr2byte('00'))
  sleep(0.00001)
  ser.write(hexstr2byte('00'))
  sleep(0.00001)
  ser.write(hexstr2byte('00'))
  sleep(0.1)

  str = '5c' + '00'
  print('cmd: {}'.format(str))
  ser.write(hexstr2byte('5c'))
  sleep(0.00001)
  ser.write(hexstr2byte('00'))
  sleep(0.1)

  str = '53' + '00' + '02' + '20'
  print('cmd: {}'.format(str))
  ser.write(hexstr2byte('53'))
  sleep(0.00001)
  ser.write(hexstr2byte('00'))
  sleep(0.00001)
  ser.write(hexstr2byte('02'))
  sleep(0.00001)
  ser.write(hexstr2byte('20'))
  sleep(0.1)


  str = '5c' + '00'
  print('cmd: {}'.format(str))
  ser.write(hexstr2byte('5c'))
  sleep(0.00001)
  ser.write(hexstr2byte('00'))
  sleep(0.1)

  str = '53' + '00' + '01' + '15'
  print('cmd: {}'.format(str))
  ser.write(hexstr2byte('53'))
  sleep(0.00001)
  ser.write(hexstr2byte('00'))
  sleep(0.00001)
  ser.write(hexstr2byte('01'))
  sleep(0.00001)
  ser.write(hexstr2byte('15'))
  sleep(0.1)
  
  str = '5c' + '00'
  print('cmd: {}'.format(str))
  ser.write(hexstr2byte('5c'))
  sleep(0.00001)
  ser.write(hexstr2byte('00'))
  sleep(0.1)

  str = '53' + '00' + '00' + '00'
  print('cmd: {}'.format(str))
  ser.write(hexstr2byte('53'))
  sleep(0.00001)
  ser.write(hexstr2byte('00'))
  sleep(0.00001)
  ser.write(hexstr2byte('00'))
  sleep(0.00001)
  ser.write(hexstr2byte('00'))
  sleep(0.1)

  str = '5c' + '00'
  print('cmd: {}'.format(str))
  ser.write(hexstr2byte('5c'))
  sleep(0.00001)
  ser.write(hexstr2byte('00'))
  sleep(0.1)

  str = '53' + '00' + '02' + '20'
  print('cmd: {}'.format(str))
  ser.write(hexstr2byte('53'))
  sleep(0.00001)
  ser.write(hexstr2byte('00'))
  sleep(0.00001)
  ser.write(hexstr2byte('02'))
  sleep(0.00001)
  ser.write(hexstr2byte('20'))
  sleep(0.1)


  str = '5c' + '00'
  print('cmd: {}'.format(str))
  ser.write(hexstr2byte('5c'))
  sleep(0.00001)
  ser.write(hexstr2byte('00'))
  sleep(0.1)

  str = '53' + '00' + '01' + '15'
  print('cmd: {}'.format(str))
  ser.write(hexstr2byte('53'))
  sleep(0.00001)
  ser.write(hexstr2byte('00'))
  sleep(0.00001)
  ser.write(hexstr2byte('01'))
  sleep(0.00001)
  ser.write(hexstr2byte('15'))
  sleep(0.1)
  
  str = '5c' + '00'
  print('cmd: {}'.format(str))
  ser.write(hexstr2byte('5c'))
  sleep(0.00001)
  ser.write(hexstr2byte('00'))
  sleep(0.1)

  str = '53' + '00' + '00' + '00'
  print('cmd: {}'.format(str))
  ser.write(hexstr2byte('53'))
  sleep(0.00001)
  ser.write(hexstr2byte('00'))
  sleep(0.00001)
  ser.write(hexstr2byte('00'))
  sleep(0.00001)
  ser.write(hexstr2byte('00'))
  sleep(0.1)

  str = '5c' + '00'
  print('cmd: {}'.format(str))
  ser.write(hexstr2byte('5c'))
  sleep(0.00001)
  ser.write(hexstr2byte('00'))
  sleep(0.1)

  str = '53' + '00' + '02' + '20'
  print('cmd: {}'.format(str))
  ser.write(hexstr2byte('53'))
  sleep(0.00001)
  ser.write(hexstr2byte('00'))
  sleep(0.00001)
  ser.write(hexstr2byte('02'))
  sleep(0.00001)
  ser.write(hexstr2byte('20'))
  sleep(0.1)


  str = '5c' + '00'
  print('cmd: {}'.format(str))
  ser.write(hexstr2byte('5c'))
  sleep(0.00001)
  ser.write(hexstr2byte('00'))
  sleep(0.1)

  success = 1


quit()
