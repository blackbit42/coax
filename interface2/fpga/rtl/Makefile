# Yosys + nextpnr-ice40 + icepack flow for iCE40UP5K-SG48
# Replaces the IceCube2 flow

# Tools
YOSYS := yosys
NEXTPNR := nextpnr-ice40
ICEPACK := icepack
ICEPLL := icepll

# Target device
DEVICE := up5k
PACKAGE := sg48

# Source files
RTL_DIR := .
V_SOURCES := $(RTL_DIR)/top.v \
             $(RTL_DIR)/control.v \
             $(RTL_DIR)/coax_tx.v \
             $(RTL_DIR)/coax_rx.v \
             $(RTL_DIR)/coax_buffer.v \
             $(RTL_DIR)/coax_buffered_tx.v \
             $(RTL_DIR)/coax_buffered_rx.v \
             $(RTL_DIR)/coax_tx_rx_frontend.v \
             $(RTL_DIR)/coax_tx_bit_timer.v \
             $(RTL_DIR)/coax_tx_distorter.v \
             $(RTL_DIR)/coax_rx_blanker.v \
             $(RTL_DIR)/coax_rx_ss_detector.v \
             $(RTL_DIR)/dual_clock_spi_device.v \
             $(RTL_DIR)/spi_device.v \
             $(RTL_DIR)/strobe_cdc.v \
             $(RTL_DIR)/third_party/ram_sdp.v \
             $(RTL_DIR)/third_party/fifo_sync_ram.v \
             $(RTL_DIR)/pll.v

# Constraints
PCF := $(RTL_DIR)/pins.pcf

# Outputs
TOP_JSON := top.json
TOP_ASC := top.asc
TOP_BIN := top.bin
TOP_TIMING := top_timing.rpt

# Default target
all: $(TOP_BIN) $(TOP_TIMING)

# Synthesize with Yosys
$(TOP_JSON): $(V_SOURCES)
	$(YOSYS) -p "read_verilog -sv $(V_SOURCES); synth_ice40 -top top -json $@"

# Place and route with nextpnr
$(TOP_ASC): $(TOP_JSON) $(PCF)
	$(NEXTPNR) --$(DEVICE) --package $(PACKAGE) \
		--json $< \
		--pcf $(PCF) \
		--asc $@ \
		--freq 40 \
		--timing-allow-fail

# Generate timing report
$(TOP_TIMING): $(TOP_ASC)
	$(NEXTPNR) --$(DEVICE) --package $(PACKAGE) \
		--json $(TOP_JSON) \
		--pcf $(PCF) \
		--asc $< \
		--freq 40 \
		--timing-allow-fail \
		--report $@

# Pack bitstream
$(TOP_BIN): $(TOP_ASC)
	$(ICEPACK) $< $@

# Generate PLL module (run once, then commit pll.v)
pll.v:
	$(ICEPLL) -i 40 -o 85 -f $@

# Clean
clean:
	rm -f $(TOP_JSON) $(TOP_ASC) $(TOP_BIN) $(TOP_TIMING)

.PHONY: all clean