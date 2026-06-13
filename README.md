# I2C Master-Slave RTL Design and Functional Verification using Verilog and SystemVerilog

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
