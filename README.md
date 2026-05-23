# FFT ECG Project — 16-Point FFT Processor on SKY130 PDK

> Full RTL-to-GDS implementation of a 16-point FFT processor targeting ECG signal processing for smart health wearables. Implemented on the open-source SKY130A PDK using OpenLane.

---

## Project Overview

This project implements a **16-point FFT processor** in two architectures:
- ✅ **Radix-2 DIT** — Completed, silicon-ready GDS generated
- 🔄 **Radix-4 Pipelined** — In progress

The primary application is **ECG signal processing** — extracting frequency-domain features from cardiac signals for real-time anomaly detection in wearable health devices.

---

## Architecture — Radix-2 DIT

### RTL Source Files

| File | Description |
|------|-------------|
| `fft16_r2.v` | Top-level module — 16-point FFT core |
| `butterfly_r2.v` | Butterfly computation unit (complex multiply-add) |
| `twiddle_rom_r2.v` | Fixed-point twiddle factor ROM |
| `bit_reversal_r2.v` | Bit-reversal permutation block |
| `pipeline_regs_r2.v` | Pipeline stage registers |
| `control_fsm_r2.v` | Control FSM for datapath sequencing |

### Block Diagram
```
Input (16 samples)
       │
  [Bit Reversal]
       │
  [Stage 1 Butterflies] ──── Twiddle ROM
       │
  [Stage 2 Butterflies] ──── Twiddle ROM
       │
  [Stage 3 Butterflies] ──── Twiddle ROM
       │
  [Stage 4 Butterflies] ──── Twiddle ROM
       │
Output (16 complex bins)
```

---

## MATLAB Validation

Before RTL implementation, the fixed-point architecture was validated in MATLAB:
- Floating-point FFT reference model built
- Fixed-point model with twiddle factor quantization
- **SQNR analysis** — Signal-to-Quantization-Noise Ratio computed across word lengths
- MIT-BIH ECG database used as test input

> MATLAB scripts available in `/matlab/` directory

---

## OpenLane Physical Design — Radix-2 Results

| Metric | Value |
|--------|-------|
| **PDK** | SKY130A |
| **Tool** | OpenLane |
| **Cell Count** | 14,751 |
| **Die Area** | 0.458 mm² |
| **Timing** | Clean closure |
| **DRC Violations** | **0** |
| **LVS** | Clean |

### Flow Stages Completed
```
RTL (Verilog) → Synthesis (Yosys) → Floorplan → Placement → CTS → Routing → GDS ✅
```

---

## Tools Used

| Tool | Purpose |
|------|---------|
| OpenLane | RTL-to-GDS automation flow |
| Yosys | Logic synthesis |
| OpenROAD | Placement, CTS, routing |
| Magic | DRC, layout viewing |
| KLayout | GDS visualization |
| Sky130A PDK | Open-source process design kit |
| MATLAB | Fixed-point modeling and SQNR validation |
| Cadence Xcelium | RTL simulation |
| Cadence Genus/Innovus | Custom IC flow (planned) |

---

## Repository Structure

```
FFT_ECG_Project/
├── radix2/
│   ├── src/               # Verilog RTL
│   │   ├── fft16_r2.v
│   │   ├── butterfly_r2.v
│   │   ├── twiddle_rom_r2.v
│   │   ├── bit_reversal_r2.v
│   │   ├── pipeline_regs_r2.v
│   │   └── control_fsm_r2.v
│   ├── config.json        # OpenLane configuration
│   └── constraints.sdc    # Timing constraints
├── radix4/                # In progress
│   └── src/
├── matlab/                # MATLAB simulation scripts
└── README.md
```

> **Note:** OpenLane `runs/` directories are excluded from the repo (large generated files). GDS outputs available on request.

---

## How to Reproduce

### Prerequisites
- OpenLane installed (Docker-based recommended)
- SKY130A PDK

### Run the Flow
```bash
cd openlane/
./flow.tcl -design fft_project/radix2 -tag final_run
```

### View GDS
```bash
klayout designs/fft_project/radix2/runs/final_run/results/final/gds/fft16_r2.gds
```

---

## Next Steps

- [ ] Complete Radix-4 RTL-to-GDS flow
- [ ] Compare Radix-2 vs Radix-4: area, power, timing
- [ ] SQNR comparison between architectures
- [ ] Move to Cadence Innovus for custom IC implementation
- [ ] Add testbench with MIT-BIH ECG dataset stimulus

---

## Author

**Raj Joshi**  
B.Tech ECE (Honours — VLSI Design and Testing)  
BVM Engineering College, Vallabh Vidhyanagar  
📧 rajjoshi1220@gmail.com  
🔗 [LinkedIn](https://linkedin.com/in/rajjoshi2012) | [GitHub](https://github.com/rajjoshi2009)

---

*Part of ongoing VLSI Physical Design project work. Targeting internship roles in Physical Design and ASIC design at semiconductor companies.*
