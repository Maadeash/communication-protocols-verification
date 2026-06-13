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



# I2C Master-Slave RTL Design and Functional Verification using Verilog,SystemVerilog and Synopsys VCS

## Overview

This project implements an I2C (Inter-Integrated Circuit) communication system consisting of a Master and Slave designed in Verilog HDL. The design supports both read and write operations using a 7-bit slave address and was verified using a layered SystemVerilog verification environment.

The verification environment includes randomized transaction generation,driver-monitor-scoreboard architecture,functional coverage collection and SystemVerilog Assertions (SVA).

---

## Project Highlights

- I2C Master RTL Design
- I2C Slave RTL Design
- 7-Bit Addressing
- Read Transactions
- Write Transactions
- ACK Generation and Detection
- Start and Stop Condition Handling
- Bidirectional SDA Communication
- SystemVerilog Verification Environment
- Functional Coverage Collection
- Assertions (SVA)
- Scoreboard-Based Data Checking
- Mailbox Communication
- Synopsys VCS Simulation
- Synopsys DVE Waveform Analysis

---

## Protocol Configuration

| Parameter | Value |
|------------|------------|
| Address Width | 7-bit |
| Slave Address | 0x2A |
| Communication | Read / Write |
| Data Width | 8-bit |
| Bus Signals | SDA,SCL |

---

## RTL Architecture

### Master

The I2C Master performs:

- Start Condition Generation
- Slave Address Transmission
- Read/Write Control
- ACK Detection
- Data Transmission
- Data Reception
- Stop Condition Generation

### Slave

The I2C Slave performs:

- Address Recognition
- ACK Generation
- Data Storage
- Data Transmission
- Read and Write Operation Handling

---

## Verification Environment

The DUT was verified using a layered SystemVerilog testbench.

### Verification Components

- Interface
- Transaction Class
- Generator
- Driver
- Monitor
- Scoreboard
- Functional Coverage
- Assertions

### Verification Flow

Generator

↓

Driver

↓

I2C DUT

↓

Monitor

↓

Scoreboard

---

## Functional Coverage

Functional coverage was implemented using SystemVerilog covergroups and Achieved 91.67% functional coverage.

### Coverage Points

#### Address Coverage

```text
VALID ADDRESS = 7'b0101010
```

#### Operation Coverage

```text
READ
WRITE
```

#### Data Coverage

```text
LOW  : 0x00 - 0x3F
MID  : 0x40 - 0xAF
HIGH : 0xB0 - 0xFF
```

#### Cross Coverage

```text
ADDRESS × READ/WRITE
```

This ensures both read and write operations are exercised for the valid slave address.

---

## Assertions

SystemVerilog Assertions were implemented to verify protocol behavior.

### Reset Check

```text
ENABLE remains LOW during RESET
```

### Start Condition Check

```text
SDA falling edge occurs while SCL is HIGH
```

Assertion Status:

PASS

---

## Scoreboard

The scoreboard verifies successful data readback from the slave.

Verification Logic:

```text
WRITE DATA

↓

STORE EXPECTED VALUE

↓

READ DATA

↓

COMPARE EXPECTED vs ACTUAL
```

Pass Condition:

```text
LAST_WRITE_DATA == READ_DATA
```

---

## Simulation Results

| Metric | Status |
|----------|----------|
| Write Transactions | PASS |
| Read Transactions | PASS |
| Assertions | PASS |
| Scoreboard | PASS |
| Functional Coverage | PASS |

---

## Synopsys VCS Functional Coverage

<img width="1600" height="835" alt="image" src="https://github.com/user-attachments/assets/3efcf2dd-c8ac-4076-a832-5fb55f95cab4" />


---

## Synopsys DVE Waveforms

<img width="1600" height="857" alt="image" src="https://github.com/user-attachments/assets/959f6e7c-d5d0-42dd-980c-72f556730b8a" />


---

## Synthesized design

<img width="1565" height="728" alt="image" src="https://github.com/user-attachments/assets/0a7ba5f7-cedb-4711-8557-7aedbdcf07d8" />

---

## Source Files

### RTL Design

- master.v
- slave.v

### Verification

- i2c_if.sv
- i2c_transaction.sv
- i2c_generator.sv
- i2c_driver.sv
- i2c_monitor.sv
- i2c_scoreboard.sv
- i2c_coverage.sv
- i2c_assertions.sv
- tb_i2c_vip.sv

---

## Tools Used

- Vivado
- Synopsys VCS
- Synopsys DVE

---

## Conclusion

Designed and verified an I2C Master-Slave communication system using Verilog HDL and SystemVerilog. The verification environment incorporated randomized read/write transactions,functional coverage,assertions and scoreboard-based checking. Simulation results demonstrated successful address recognition,data transfer,ACK handling and readback verification across multiple transactions.
