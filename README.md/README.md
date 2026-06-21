# Direct-Mapped Cache Controller in SystemVerilog

## Overview

This project implements a parameterized Direct-Mapped Cache Controller using SystemVerilog.

The controller supports:
- Address decoding (Tag, Index, Offset)
- Cache hit/miss detection
- FSM-based control
- Cache refill on miss
- Conflict miss replacement

## Architecture

```text
                    +------------------+
                    |       CPU        |
                    +------------------+
                              |
                              | cpu_addr
                              v
                    +------------------+
                    | Address Decoder  |
                    +------------------+
                      |      |      |
                     Tag   Index  Offset
                      |
                      v
                    +------------------+
                    |  Cache Storage   |
                    |------------------|
                    | Tag Memory       |
                    | Data Memory      |
                    | Valid Bits       |
                    +------------------+
                              |
                              v
                    +------------------+
                    | Tag Comparator   |
                    +------------------+
                              |
                              v
                    +------------------+
                    |  Hit Detector    |
                    +------------------+
                              |
                        Hit / Miss
                              |
                              v
                    +------------------+
                    | Cache Controller |
                    |      (FSM)       |
                    +------------------+
                              |
                              v
                    +------------------+
                    |   Main Memory    |
                    +------------------+
```

---

## FSM State Diagram

```text
                 cpu_req
            +------------+
            |            |
            v            |
        +--------+       |
        |  IDLE  |-------+
        +--------+
             |
             v
        +---------+
        |  CHECK  |
        +---------+
          |     |
     hit  |     | miss
          |     |
          v     v
      +------+ +--------+
      | HIT  | | REFILL |
      +------+ +--------+
          |        |
          +--------+
               |
               v
             IDLE
```

### State Description

| State | Description |
|---------|------------|
| IDLE | Waits for CPU request |
| CHECK | Checks cache for hit or miss |
| HIT | Returns cached data to CPU |
| REFILL | Fetches data from memory and updates cache |


## Project Structure

```text
Direct_Mapped_Cache_Controller/
│
├── rtl/
│   ├── address_decoder.sv
│   ├── cache_storage.sv
│   ├── tag_comparator.sv
│   ├── hit_detector.sv
│   ├── main_memory.sv
│   └── cache_controller.sv
│
├── tb/
│   └── tb_cache_controller.sv
│
├── docs/
│   ├── waveform.png
│   └── simulation_results.png
│
├── README.md
├── LICENSE
```

## Features

- Parameterized cache size
- Parameterized block size
- Direct-mapped organization
- Tag comparator
- Hit detector
- Main memory model
- Self-checking testbench

## Verification

Test cases verified:

- Cold Miss
- Cache Hit
- Different Address Miss
- Conflict Miss
- Cache Replacement

## Tools Used

- SystemVerilog
- Xilinx Vivado

## Future Improvements

- Write-through cache
- Write-back cache
- Multi-word cache blocks
- 2-way set associative cache