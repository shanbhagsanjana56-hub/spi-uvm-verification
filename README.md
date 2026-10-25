# UVM Verification of an SPI-Controlled 32x8 Memory

A UVM testbench that verifies a Verilog SPI controller talking to a 32x8 SPI memory. It includes constrained-random and directed sequences, a self-checking scoreboard with an independent error check, a functional coverage model, and an SVA assertion.

Simulated on Questa (UVM 1.2) using EDA Playground.

---

## 1. Design Under Test

| Module | Description |
|---|---|
| `spi_intf` | Controller FSM. Takes `wr`, `addr`, `din` and drives `cs`, `mosi`. Raises `done` when finished and `err` for an illegal address. |
| `spi_mem` | 32 x 8-bit memory with an SPI-style serial interface. Provides `ready` and `op_done` handshakes. |
| `top` | Connects the controller and memory (`cs`, `mosi`, `miso`, `ready`, `op_done`). |
| `spi_i` | Interface used by the testbench. |

**Protocol summary**
- **Write:** 17-bit frame sent LSB first: `wr` bit, 8 address bits, 8 data bits. The controller then waits for `op_done`.
- **Read:** 9-bit frame (`wr` bit + 8 address bits), waits for `ready`, then shifts in 8 data bits from MISO.
- **Error:** any address above 31 sends the controller to an error state that raises `err` and `done`.

---

## 2. Testbench Architecture

```
 sequences --> sequencer --> driver --> [ DUT ] --> monitor --+--> scoreboard
                                                              |
                                                              +--> coverage
```

| Component | Role |
|---|---|
| `transaction` | Sequence item with `op`, `addr`, `din`, `dout`, `done`, `err` and address constraints (valid: `addr < 32`, illegal: `addr > 31`). |
| Sequences | Generate valid, illegal, reset and boundary traffic (see test plan). |
| `driver` | Drives `wr`, `addr`, `din`, `rst` and waits for `done`. |
| `mon` | Observes the interface and builds a transaction from the request and the DUT response. |
| `sco` | Reference memory model. Compares read data and checks that `err` matches `addr > 31`. |
| `cov` | Functional coverage subscriber. |
| `agent`, `env`, `test` | Standard UVM structure. |

---

## 3. Test Plan

| Scenario | Sequence | What it checks |
|---|---|---|
| Valid writes | `write_data` | Data is accepted without error |
| Valid reads | `read_data` | Read data matches the scoreboard model |
| Write then read back | `writeb_readb` | Read-back correctness |
| Illegal writes | `write_err` | `err` is raised for addr > 31 |
| Illegal reads | `read_err` | `err` is raised for addr > 31 |
| Boundary addresses | `boundary_seq` | Addresses 0, 1, 30, 31 (valid) and 32, 33, 255 (illegal) |
| Reset | `reset_dut` | Reset applied on an idle bus |

---

## 4. Checking

- **Data check:** the scoreboard keeps a 32x8 reference memory. Every valid read is compared against it.
- **Independent error check:** the scoreboard computes `exp_err = (addr > 31)` itself and compares it with the DUT's `err`. It does not trust the DUT's flag.
- **Assertion (SVA):** a concurrent assertion in the interface checks that `done` and `err` are low after reset. It was verified by deliberately breaking it and observing the failure.

---

## 5. Functional Coverage

| Item | Description | Result |
|---|---|---|
| `cp_op` | read, write | 100% |
| `cp_addr` | low (0-10), mid (11-29), 30, 31, 32, illegal (33-255) | 100% |
| `cp_err` | err = 0, err = 1 | 100% |
| `op x addr` cross | every operation in every address region | 100% |
| **Overall** | | **100%** |

100% applies to the coverage model defined above, not to the design as a whole. See limitations below.

---

## 6. Results

- `UVM_ERROR: 0`, `UVM_FATAL: 0` on the final run
- All valid reads matched the scoreboard model
- Illegal addresses (including the 31/32 boundary) correctly produced `err = 1`
- Functional coverage: 100% on the defined model
- Assertion: passes on the real design, fails when intentionally broken

**Bug-injection test (testbench sanity check)**

| Injected bug | Expected detection | Result |
|---|---|---|
| Controller boundary changed from `addr < 32` to `addr < 30` | `ERR MISMATCH` at addr 30 and 31 | _TODO: fill in after running_ |

---

## 7. Known Limitations / Future Work

- Reset is only applied on an idle bus. Reset in the middle of a transaction is not tested yet.
- Only one SVA is implemented. Handshake and timing assertions (`ready` / `op_done` / `done`) are planned.
- Data-pattern coverage (0x00, 0xFF, alternating bits) is not in the coverage model.
- The DUT has no start signal, so the controller re-issues a transaction while inputs are held. The driver changes inputs when `done` is seen.
- `dout` is not reset in the DUT, so it is unknown until the first read completes. The scoreboard only compares `dout` on valid reads.

---

## 8. How to Run

1. Open EDA Playground and add the files from `design/` and `tb/` (all `tb/` files must sit beside `testbench.sv`, because it includes them by name).
2. Select **Questa** as the simulator and **UVM 1.2** as the methodology.
3. Set `testbench.sv` as the testbench file and run.
4. Check the end of the log for the `[COV]` lines and the UVM Report Summary.

---

## 9. Repository Layout

```
design/   design.sv (spi_intf + top), spi_mem.sv, intf.sv
tb/       testbench.sv (top module, includes the files below)
          config.sv   agent config
          transac.sv  transaction
          seq.sv      sequences
          driv.sv     driver
          mon.sv      monitor
          sco.sv      scoreboard
          cg.sv       functional coverage
          ag.sv       agent
          env.sv      environment
          tst.sv      test
README.md
log.txt   (passing run)
```
