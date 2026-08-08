# SPI Master-Slave RTL Design and UVM-Based Functional Verification

## Overview

This project implements a full-duplex SPI (Serial Peripheral Interface) communication system with separate SPI Master and SPI Slave RTL blocks designed in Verilog HDL. The design was verified using a layered UVM-based SystemVerilog verification environment with constrained-random stimulus, scoreboard-based checking, functional coverage, and SystemVerilog Assertions (SVA).

The complete verification flow was used to validate master-to-slave and slave-to-master data transfer behavior, chip-select handling, and protocol correctness.

## Project Highlights

* SPI Master RTL design
* SPI Slave RTL design
* Full-duplex serial communication
* SCLK generation logic
* MOSI and MISO data transfer
* Chip Select (CS) control
* UVM-based verification environment
* Constrained-random transaction generation
* Functional coverage collection
* Cross coverage implementation
* Assertion-based protocol checks
* Scoreboard-based data comparison
* Mailbox communication
* Synopsys VCS simulation
* Synopsys DVE waveform analysis

## SPI Protocol

SPI uses four main signals:

| Signal | Description         |
| ------ | ------------------- |
| MOSI   | Master Out Slave In |
| MISO   | Master In Slave Out |
| SCLK   | Serial Clock        |
| CS     | Chip Select         |

### Protocol Configuration

* CPOL = 0
* CPHA = 0
* 8-bit data transfer
* Full-duplex communication

## RTL Architecture

### SPI Master

The SPI Master is responsible for:

* Generating the serial clock
* Controlling chip select
* Transmitting data on MOSI
* Receiving data on MISO
* Detecting transfer completion

### SPI Slave

The SPI Slave is responsible for:

* Receiving MOSI data
* Driving MISO data
* Capturing transmitted values
* Supporting full-duplex transfer behavior

## UVM Verification Environment

The DUT was verified using a layered UVM testbench architecture.

### Verification Components

* Interface
* Transaction
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

Generator → Driver → SPI DUT → Monitor → Scoreboard

## Functional Coverage

Functional coverage was implemented using SystemVerilog covergroups to ensure complete transaction visibility across the SPI data space.

### Coverage Points

#### MASTER_TX

* LOW range
* MID range
* HIGH range

#### SLAVE_TX

* LOW range
* MID range
* HIGH range

#### Corner Cases

* `0x00`
* `0xFF`
* `0xAA`
* `0x55`

#### Cross Coverage

* `MASTER_TX × SLAVE_TX`

The coverage report shows complete closure for the SPI coverage group, including all variables and cross bins. The report also indicates one test was used to generate the final result.

## Assertions

SystemVerilog Assertions were implemented to verify core SPI protocol behavior.

### Example Checks

* CS remains HIGH during reset
* DONE remains LOW during reset
* SCLK remains LOW when CS is HIGH
* CS returns HIGH after transaction completion

### Assertion Status

* PASS

## Scoreboard

The scoreboard verifies full-duplex data integrity between master and slave.

### Verification Checks

* `MASTER_RX == SLAVE_TX`
* `SLAVE_RX == MASTER_TX`

The received data is compared automatically against expected values for each transaction.

## Simulation Results

| Metric               | Result |
| -------------------- | ------ |
| Functional Coverage  | PASS   |
| Assertions           | PASS   |
| Scoreboard           | PASS   |
| Master Receive Check | PASS   |
| Slave Receive Check  | PASS   |

## Source Files

### RTL Design

* `spi_master.v`
* `spi_slave.v`

### Verification

* `spi_if.sv`
* `spi_pkg.sv`
* `spi_seq_item.sv`
* `spi_sequencer.sv`
* `spi_sequences.sv`
* `spi_driver.sv`
* `spi_monitor.sv`
* `spi_scoreboard.sv`
* `spi_coverage.sv`
* `spi_assertions.sv`
* `spi_agent.sv`
* `spi_env.sv`
* `spi_test.sv`
* `spi_tb_top.sv`

## How to Run

### Setup Environment

```
source /path/to/synopsys_setup.sh 
```

### Compile

```
vcs -full64 -sverilog -ntb_opts uvm -debug_access+all -kdb -f filelist.f -l compile.log
```

### Simulate

```
./simv +UVM_TESTNAME=spi_random_test -cm line+cond+fsm+tgl+branch -l sim.log
```


# Synthesized and Implemented Design(Using Vivado)

<img width="1485" height="519" alt="image" src="https://github.com/user-attachments/assets/9ce50914-d6b8-44b2-bc85-048e9b389f4d" />

---

## Synopsys VCS Coverage Results

<img width="1600" height="835" alt="image" src="https://github.com/user-attachments/assets/663a8bc1-cb25-41e4-a312-1202394bee9d" />

<img width="1600" height="900" alt="image" src="https://github.com/user-attachments/assets/9eff887f-25f4-4bb0-b475-ef1fdb284f0e" />

---

## Coverage Report

<img width="1440" height="700" alt="image" src="https://github.com/user-attachments/assets/20eeaa85-0f1c-4396-9687-b6d66c80698c" />

---

## Tools Used

* Verilog HDL
* SystemVerilog
* UVM
* Synopsys VCS
* Synopsys DVE

## Result

This project demonstrates a complete SPI design and verification flow, from RTL implementation to a reusable UVM-based verification environment with full coverage closure and protocol validation.
