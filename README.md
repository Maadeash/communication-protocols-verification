# Communication Protocols Verification

A collection of UVM-based functional verification testbenches for common serial communication protocols, built as part of RTL design and verification practice.

## Protocols Covered

| Protocol | Description | Status |
|----------|-------------|--------|
| [UART](./uart_protocol) | Universal Asynchronous Receiver/Transmitter | ✅ Verified |
| [SPI](./spi_protocol) | Serial Peripheral Interface | ✅ Verified |
| [I2C](./i2c-protocol) | Inter-Integrated Circuit | ✅ Verified |

## Repository Structure

## Repository Structure

Each protocol folder is self-contained and follows a similar structure:

```
communication-protocols-verification/
├── uart_protocol/
│   ├── RTL/                # Design under test (DUT)
│   ├── UVM_VIP/             # UVM testbench components (agent, driver, monitor, scoreboard, etc.)
│   ├── Coverage_Report/      # Functional coverage reports (HTML)
│   ├── filelist.f            # Compile file list
│   └── README.md             # Protocol-specific details
│
├── spi_protocol/
│   ├── RTL/
│   ├── UVM_VIP/
│   ├── Coverage_Report/
│   ├── filelist.f
│   └── README.md
│
├── i2c-protocol/
│   ├── RTL/
│   ├── UVM_VIP/
│   ├── Coverage_Report/
│   ├── filelist.f
│   └── README.md
│
└── README.md              # This file — top-level overview
```

## Verification Methodology

Each testbench is built using the **UVM (Universal Verification Methodology)** and typically includes:

- **Driver** – drives stimulus onto the DUT interface
- **Monitor** – observes DUT signals and captures transactions
- **Sequencer & Sequences** – generate randomized/directed test scenarios
- **Scoreboard** – checks DUT behavior against expected results
- **Coverage Model** – tracks functional coverage to measure verification completeness
- **Assertions** – protocol-level checks (where applicable)

## How to Run

Each protocol folder includes its own `filelist.f` for compilation with your simulator of choice (e.g., QuestaSim, VCS, Xcelium). Refer to the individual protocol's README for simulator-specific run commands.

## Author

**Maadeash K**  
ECE Undergrad, Saveetha Engineering College, Chennai.
