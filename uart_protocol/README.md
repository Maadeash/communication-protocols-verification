# UART Protocol RTL-to-GDSII Implementation with UVM Verification

A complete UART design and implementation project covering RTL development, UVM-based functional verification, synthesis, physical design, and GDSII generation.

## Overview

This project implements a FIFO-based UART architecture with a full verification and implementation flow. The design includes a baud rate generator, UART transmitter, UART receiver, transmit FIFO, and receive FIFO. The RTL was verified using a SystemVerilog UVM environment with directed and constrained-random stimulus, scoreboard-based checking, assertions, and functional coverage. The design was then taken through synthesis and physical implementation using Cadence Genus and Cadence Innovus.

## Key Features

* Parameterized UART RTL design
* FIFO-based transmit and receive buffering
* Baud rate generation for serial communication
* Start-bit and stop-bit handling
* UVM-based self-checking verification environment
* Directed and constrained-random test generation
* Scoreboard-based result comparison
* Assertion-based protocol and reset checks
* Functional coverage closure
* RTL synthesis and physical design flow
* Timing closure achieved

## RTL Modules

### `baudgen`

Generates baud-tick pulses required for UART timing control.

### `fifo`

Implements synchronous FIFO buffering for both transmit and receive paths.

### `uart_tx`

Handles serial transmission of data using a finite state machine.

### `uart_rx`

Captures incoming serial data and reconstructs received bytes.

### `top`

Top-level module integrating the baud generator, UART TX, UART RX, and FIFOs.

## UVM Verification Environment

The original SystemVerilog testbench was converted into a reusable UVM architecture. The environment is organized using standard UVM components:

* `uart_seq_item` for transaction modeling
* `uart_sequencer` for sequence control
* `uart_driver` for DUT stimulus generation
* `uart_monitor` for transaction capture
* `uart_scoreboard` for data comparison and pass/fail tracking
* `uart_coverage` for functional coverage collection
* `uart_assertions` for SVA-based protocol checking
* `uart_env` for top-level integration
* `uart_test` for test execution and simulation control

### Verification Strategy

The verification flow combines:

* Directed tests for known values and corner cases
* Constrained-random transactions for broader stimulus
* Scoreboard comparison for expected vs actual data
* Assertions for reset and interface behavior
* Functional coverage for closure tracking

### Coverage Points

The coverage model includes:

* Data range bins
* Corner-case values such as `0x00`, `0xFF`, `0xAA`, and `0x55`
* Balanced stimulus distribution across low, mid, and high data ranges

## Verification Result

* Scoreboard result: PASS
* Functional coverage: 100%
* Corner cases covered: 100%
* Data bins covered: 100%

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
./simv +UVM_TESTNAME=uart_random_test -cm line+cond+fsm+tgl+branch -l sim.log
```

## Physical Design Flow

The design was implemented using the following tools:

* **Cadence Genus** for synthesis
* **Cadence Innovus** for floorplanning, placement, CTS, routing, and GDSII generation


## Proof / Results

### Functional Verification 

<img width="1600" height="900" alt="WhatsApp Image 2026-08-08 at 10 41 00 AM" src="https://github.com/user-attachments/assets/e14f21ea-9569-4c9e-97c7-805b3866fa4c" />

<img width="1600" height="760" alt="WhatsApp Image 2026-08-08 at 10 41 55 AM" src="https://github.com/user-attachments/assets/204cfe02-4af9-4556-ab8b-043920867553" />

### Coverage Report

<img width="1486" height="571" alt="Screenshot 2026-08-08 181037" src="https://github.com/user-attachments/assets/93b3ab18-d8f1-4042-b30c-f8004fbe7352" />


### Synthesis Result

<img width="1600" height="900" alt="image" src="https://github.com/user-attachments/assets/2f5ff9d8-8981-4b01-9403-2c203d30c978" />


### Layout / Floorplan

<img width="1600" height="900" alt="image" src="https://github.com/user-attachments/assets/f1eb7b6b-0c9f-445c-af5d-43d03d9eeba3" />

<img width="1600" height="900" alt="image" src="https://github.com/user-attachments/assets/bee9e260-828b-4f7e-8676-93d2f6c7e635" />


### Timing Report

<img width="1600" height="900" alt="image" src="https://github.com/user-attachments/assets/01c022c2-c50b-445f-a36e-584885fae595" />


### Implementation Outcome

* Timing constraints met
* Setup slack achieved
* Final design closed successfully

## Project Summary

This project demonstrates a complete UART development flow from RTL design to verified implementation. It shows both functional correctness through UVM-based verification and physical readiness through synthesis and PnR flow.

## Tools and Technologies

* SystemVerilog
* UVM
* SVA
* Cadence Genus
* Cadence Innovus
* Synopsys VCS


