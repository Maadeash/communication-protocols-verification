# I2C Master-Slave RTL Design and UVM-Based Functional Verification

## Overview

This project implements an I2C communication system with separate Master and Slave RTL blocks designed in Verilog HDL. The design supports both read and write transactions using a 7-bit slave address and was verified using a layered UVM-based SystemVerilog verification environment.

The verification flow includes transaction generation, driver-monitor-scoreboard architecture, functional coverage collection, and SystemVerilog Assertions (SVA) to validate protocol behavior and data integrity.

## Project Highlights

* I2C Master RTL design
* I2C Slave RTL design
* 7-bit slave addressing
* Read and write transaction support
* Start and stop condition handling
* ACK generation and detection
* Bidirectional SDA communication
* UVM-based verification environment
* Constrained-random transaction generation
* Scoreboard-based data checking
* Functional coverage collection
* Assertion-based protocol checks
* Mailbox-based communication
* Synopsys VCS simulation
* Synopsys DVE waveform debug

## Protocol Configuration

| Parameter         | Value        |
| ----------------- | ------------ |
| Address Width     | 7-bit        |
| Slave Address     | 0x2A         |
| Transaction Types | Read / Write |
| Data Width        | 8-bit        |
| Bus Signals       | SDA, SCL     |

## RTL Architecture

### Master

The I2C Master is responsible for:

* Generating the start condition
* Sending the slave address
* Selecting read or write operation
* Detecting ACK from the slave
* Writing data to the bus
* Reading data from the bus
* Generating the stop condition

### Slave

The I2C Slave is responsible for:

* Detecting its assigned address
* Generating ACK responses
* Receiving write data
* Driving read data back to the master
* Handling both read and write transfers correctly

## UVM Verification Environment

The DUT is verified using a layered UVM testbench architecture.

### Verification Components

* Interface
* Sequence item
* Sequencer
* Driver
* Monitor
* Scoreboard
* Coverage collector
* Assertions
* Environment
* Test

### Verification Flow

Generator → Driver → DUT → Monitor → Scoreboard

## Functional Coverage

Functional coverage was collected using SystemVerilog covergroups to ensure protocol activity was exercised across key scenarios.

### Coverage Points

#### Address Coverage

* Valid I2C slave address: `7'b0101010`

#### Operation Coverage

* Read
* Write

#### Data Coverage

* Low range: `0x00 - 0x3F`
* Mid range: `0x40 - 0xAF`
* High range: `0xB0 - 0xFF`

#### Cross Coverage

* Address × Read/Write operation

The coverage report shows full closure for the coverage model, with all variables and cross bins covered. The report also indicates a single simulation test was used to generate the final result.

## Assertions

SystemVerilog Assertions were implemented to verify protocol-level behavior.

### Example Checks

* Reset behavior
* Start condition validation
* SDA transitions with SCL high
* ACK-related protocol correctness

### Assertion Result

* PASS

## Scoreboard

The scoreboard checks that data written to the slave can be read back correctly.

### Verification Logic

Write data → store expected value → read data → compare expected vs actual

### Pass Condition

Expected data must match the read-back data from the slave.

## Simulation Results

| Metric              | Status |
| ------------------- | ------ |
| Write Transactions  | PASS   |
| Read Transactions   | PASS   |
| Assertions          | PASS   |
| Scoreboard          | PASS   |
| Functional Coverage | PASS   |

## Source Files

### RTL Design

* `i2c_master.v`
* `i2c_slave.v`

### Verification

* `i2c_if.sv`
* `i2c_pkg.sv`
* `i2c_assertions.sv`
* `tb_top.sv`

## Tools Used

* Verilog HDL
* SystemVerilog
* UVM
* Synopsys VCS
* Synopsys DVE

## Result

This project demonstrates a complete I2C design and verification flow, from RTL implementation to a reusable UVM-based verification environment with full coverage closure and protocol validation.


## Synopsys VCS Functional Coverage

<img width="1600" height="900" alt="image" src="https://github.com/user-attachments/assets/8666c5c3-63f4-44a3-bfc5-74d1f51e64f1" />

<img width="1600" height="900" alt="image" src="https://github.com/user-attachments/assets/7af378fb-8b5d-4ded-b5d3-418c7f70a326" />

---

## Coverage Report

<img width="1362" height="624" alt="image" src="https://github.com/user-attachments/assets/852c0cda-2598-4636-8268-9ddd0069e273" />

---

## Synthesized design

<img width="1565" height="728" alt="image" src="https://github.com/user-attachments/assets/0a7ba5f7-cedb-4711-8557-7aedbdcf07d8" />

---

## Conclusion

Designed and verified an I2C Master-Slave communication system using Verilog HDL and UVM. The verification environment incorporated randomized read/write transactions,functional coverage,assertions and scoreboard-based checking. Simulation results demonstrated successful address recognition,data transfer,ACK handling and readback verification across multiple transactions.
