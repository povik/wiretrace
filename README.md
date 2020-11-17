# wiretrace -- poor man's logic analyzer

`wiretrace` is a logic design for Lattice's ICE40 UP5K FPGA that constitutes a basic logic analyzer.

Features:

 * 8 inputs sampled at 24 MHz
 * Connected through UART to a PC, which then displays the captured traces
 * Holds upto 2048 transitions in a queue for transmission over UART
 * A decoding program on a PC provides either textual output or VCD file

## Hardware

`wiretrace` as written is expected to be programmed onto a [PROGLOG01A](https://www.mlab.cz/module/PROGLOG01A) module from the MLAB brick system. Consult and modify `system.pcf` if programming other boards.

### I/O

 * Input probes on `6a` to `51a`, i.e. the bottom pin header of PROGLOG01A

 * UART output on `23b`

 * Blue LED indication of activity, yellow LED indication of overflow

## Usage

Build the `system.bin` with `make`, or download a binary from a release. Program the FPGA, then on your PC set the serial line baudrate to 115200 and connect the line to the standard input of `./decode`.

After programming the FPGA, with wiretrace connected on e.g. `/dev/ttyUSB0`, run from directory of the repo:

```
 # ./setserial.sh /dev/ttyUSB0
 # ./decode < /dev/ttyUSB0
```

### Decoding options


```
usage: decode [-h] [-n NAMES] [-f F] [-F FRAME] [-w VCD]

optional arguments:
  -h, --help  show this help message and exit
  -n NAMES    comma-separated wire labels
  -f F        sampling frequency in MHz
  -F FRAME    frame wire
  -w VCD      name for a VCD file to write


```

If `-F` is passed and a wire name is provided, the times of transitions in the textual output will be printed relative to the last occurence of low-to-high transition on the named wire. The wire name can be prefixed with `~`, in which case high-to-low, not low-to-high transitions are considered.
