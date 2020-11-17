TARGET       = system
SRC          = system.v fifo.v uart_tx.v
TECH_LIB     = `yosys-config --datdir`/ice40/cells_sim.v
NEXTPNR_ARGS = --up5k --freq 24

all: $(TARGET).bin

clean:
	rm -f *.json *.asc *.bin

system_tb: $(SRC) system_tb.v
	iverilog $^ -o $@

%.bin: %.asc
	icepack $< $@

%.asc: %.json $(TARGET).pcf
	nextpnr-ice40 $(NEXTPNR_ARGS) --json $< --pcf $(TARGET).pcf --asc $@

%.json: $(SRC)
	yosys -p 'synth_ice40 -dsp -top $(TARGET) -json $@' $(SRC)

.PHONY: all clean
