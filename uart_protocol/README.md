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

<img width="1600" height="900" alt="image" src="https://github.com/user-attachments/assets/200cc828-78f0-45d0-8e75-43660e64260d" />

<img width="1600" height="760" alt="image" src="https://github.com/user-attachments/assets/b5b84b41-7fca-4bb2-b062-25f208dc95fe" />

<img width="1486" height="571" alt="image" src="https://github.com/user-attachments/assets/c83f7045-4ff9-4b57-ad08-f5720c58b705" />


### Synthesis Result

<img width="1600" height="900" alt="image" src="https://github.com/user-attachments/assets/4c8ec35c-0349-4a9a-9a30-3c5e4aca5be1" />


### Layout / Floorplan

<img width="1600" height="900" alt="image" src="https://github.com/user-attachments/assets/a28c7b8c-d522-4269-9827-f1a225cd8595" />

<img width="1600" height="900" alt="image" src="https://github.com/user-attachments/assets/33fe5997-a288-467e-9762-4f6b6084bc66" />



### Timing Report

<img width="1600" height="900" alt="image" src="https://github.com/user-attachments/assets/b8e6c1a8-de8e-4acd-aa6b-6b811a07bda7" />

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


