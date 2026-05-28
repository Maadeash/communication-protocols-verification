# I2C Protocol Design using Verilog

## Introduction

I2C (Inter-Integrated Circuit) is a synchronous serial communication protocol used for communication between multiple devices using only two wires.

I2C is widely used in:

- EEPROM communication
- Sensor interfacing
- RTC modules
- ADC/DAC devices
- Embedded systems
- FPGA peripheral communication

I2C mainly uses two signals:

- SDA (Serial Data Line)
- SCL (Serial Clock Line)

The protocol supports master-slave communication where the master controls the communication and generates the clock signal.

This project implements an I2C master and slave communication using Verilog HDL.

---

# Features of I2C

- Synchronous serial communication
- Two-wire communication protocol
- Master-slave architecture
- Address-based communication
- Read and write operations
- Multi-device communication support
- Simple hardware implementation

---

# I2C Communication

I2C communication uses:

- START condition
- Address transfer
- ACK/NACK mechanism
- Data transfer
- STOP condition

---

# I2C Architecture

The design consists of:

- I2C Master
- I2C Slave
- Verilog Testbench

The I2C master controls:

- SDA line
- SCL line
- Address transmission
- Data transmission
- Read/Write operation

The I2C slave performs:

- Address detection
- ACK generation
- Data reception
- Data transmission

---

# START and STOP Conditions

## START Condition

START occurs when:

- SDA transitions from HIGH to LOW
- While SCL remains HIGH

This indicates the beginning of communication.

---

## STOP Condition

STOP occurs when:

- SDA transitions from LOW to HIGH
- While SCL remains HIGH

This indicates the end of communication.

---

# I2C Master FSM

The I2C master uses the following FSM states:

## IDLE
- Waits for enable signal

## START
- Generates START condition

## ADDRESS
- Sends slave address and read/write bit

## READ_ACK
- Waits for slave acknowledgment

## WRITE_DATA
- Sends data to slave

## READ_ACK2
- Waits for acknowledgment after data transfer

## READ_DATA
- Reads data from slave

## WRITE_ACK
- Sends acknowledgment to slave

## STOP
- Generates STOP condition

---

# I2C Slave FSM

The I2C slave uses the following FSM states:

## READ_ADDR
- Receives slave address

## ACK1
- Sends acknowledgment to master

## READ_DATA
- Receives data from master

## ACK2
- Sends acknowledgment after data reception

## WRITE_DATA
- Sends data to master

---

# Important I2C Signals

| Signal | Description |
|--------|-------------|
| clk | System clock |
| rst | Reset signal |
| enable | Starts I2C communication |
| addr | 7-bit slave address |
| rw | Read/Write control bit |
| w_data | Data written by master |
| dout | Data received from slave |
| sda | Serial data line |
| scl | Serial clock line |

---

# Read and Write Operations

## Write Operation

The master:

- Sends slave address
- Receives acknowledgment
- Sends data to slave
- Receives final acknowledgment
- Generates STOP condition

---

## Read Operation

The master:

- Sends slave address with read bit
- Receives acknowledgment
- Reads data from slave
- Sends acknowledgment
- Generates STOP condition

---

# Clock Generation

The I2C master generates SCL internally using clock division.

Clock division is implemented using:

- divide_by parameter
- Internal counters

---
# Output Waveform

<img width="1551" height="715" alt="image" src="https://github.com/user-attachments/assets/b950b62f-11d6-4e86-829d-c1ca8f35ac74" />

# Synthesized design

<img width="1565" height="728" alt="image" src="https://github.com/user-attachments/assets/0a7ba5f7-cedb-4711-8557-7aedbdcf07d8" />

# Conclusion

I2C protocol was successfully designed using Verilog HDL. The project includes I2C master and slave modules supporting address-based communication, acknowledgment handling, and data transfer operations. Simulation results verified correct communication between master and slave devices using the Verilog testbench.
