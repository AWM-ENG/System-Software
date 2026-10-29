# x86_64 CLI Argument Summation & Integer I/O Utility

A low-level Command-Line Interface (CLI) utility written in raw 64-bit Assembly (`x86_64`) targeting Linux environments using the System V AMD64 Application Binary Interface (ABI) and Intel syntax.

This repository demonstrates bare-metal CLI parsing directly from the process stack without standard library (`libc`) dependencies, manual memory layout handling, custom string-to-integer (`atoi`) and integer-to-string (`itoa`) conversion subroutines, dynamic stack buffer management, and raw System V Linux kernel syscalls.

## Architecture & Systems Overview

### 1. Process Startup & Stack Frame Structure (`_start`)

Unlike standard C runtimes that wrap execution around `main(int argc, char **argv)`, Linux populates the process stack upon entry (`_start`) following the System V AMD64 ABI specification:

```
+---------------------------------+  <-- Initial rsp
| argc (8 bytes)                  |  Total argument count
+---------------------------------+
| argv[0] pointer (8 bytes)       |  Program invocation path
+---------------------------------+
| argv[1] pointer (8 bytes)       |  First argument string
+---------------------------------+
| ...                             |
+---------------------------------+
| argv[n] pointer (8 bytes)       |  N-th argument string
+---------------------------------+
| NULL (8 bytes)                  |  End of argv array
+---------------------------------+
```

The program traverses `argv` directly off the stack frame using an offset index derived from `rsp`, bypassing `libc` initializations to maintain a minimal execution footprint and zero overhead.

### 2. Manual Stack Frame Allocation & Scratch Buffer Management

To convert the calculated summation into an ASCII string without relying on static global variables (`.data` or `.bss` sections), the utility dynamically allocates a local scratch space directly on the runtime execution stack:

* **Buffer Allocation (`sub rsp, 64`):** Decrements the Stack Pointer (`rsp`) by 64 bytes to reserve contiguous scratch space for string formatting.
* **Buffer Writing (`itoa` Routine):** Passes the destination buffer pointer via `rsi` (`mov rsi, rsp`). The `itoa` function uses indexed byte moves (`mov byte ptr [rsi + index], dl`) to write formatted ASCII digits into this newly allocated stack region.
* **Buffer Reading (`sys_write` Syscall):** Serves the starting address of the stack buffer (`mov rsi, rsp`) to the Linux kernel via System Call (`RAX = 1`), allowing `sys_write` to read the formatted string directly from stack memory for `stdout`.
* **Stack Cleanup (`add rsp, 64`):** Increments `rsp` back to its original state after output completion, preserving stack frame integrity before program termination.

### 3. Custom Conversion Routines

* **`atoi` (ASCII to Integer):**
  * Parses null-terminated ASCII strings provided via CLI pointers.
  * Handles signed inputs (detecting leading `-` `0x2D` ASCII character).
  * Iteratively reconstructs signed 64-bit integers (`r8` accumulator) using base-10 positional arithmetic (`imul r8, 10`).

* **`itoa` (Integer to ASCII):**
  * Converts a signed 64-bit integer into its ASCII representation for standard output stream consumption.
  * Preserves sign handling for negative values.
  * Utilizes modulo base-10 arithmetic (`div`), pushing extracted digit remainders onto the thread stack to naturally reverse digit order prior to memory buffer insertion.

### 4. Native Linux System Calls

The application interfaces directly with the Linux kernel via the `syscall` instruction:

* **`sys_write` (RAX = 1):** Outputs converted string buffer from stack memory to `stdout` (`RDI = 1`).
* **`sys_exit` (RAX = 60):** Terminates execution with a defined exit code (`RDI = 42`).

## Technical Specifications

| Property | Value / Specification |
| ----- | ----- |
| **Architecture** | x86_64 / AMD64 |
| **Syntax** | Intel Syntax (`.intel_syntax noprefix`) |
| **ABI Target** | System V AMD64 ABI (Linux) |
| **Dependencies** | None (Freestanding / No `libc`) |
| **Syscalls Used** | `sys_write` (1), `sys_exit` (60) |

## Build & Execution Instructions

### Prerequisites

* **GNU Assembler (`as`)** or **NASM**
* **GNU Linker (`ld`)**
* **GNU Make** (optional)

### 1. Assembly & Linking (GNU Toolchain)

To assemble and link the source code into a freestanding 64-bit ELF binary using the GNU assembler:

```bash
# Assemble source file into an object file
as -o main.o  main.s

# Link object file into a freestanding executable
ld -d -M main main.o
```

### 2. Running the Utility

Pass any number of integer arguments (positive or negative) directly through the command line:

```bash
./main 10 20 30 -5
```

**Expected Output:**

```
55
```

### 3. Checking Exit Status

Verify the return code set by `sys_exit`:

```bash
echo $?
# Output: 42
```
