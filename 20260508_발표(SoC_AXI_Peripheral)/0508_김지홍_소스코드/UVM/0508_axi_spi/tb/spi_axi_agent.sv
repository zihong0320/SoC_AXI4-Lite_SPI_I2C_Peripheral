`ifndef SPI_AXI_AGENT_SV
`define SPI_AXI_AGENT_SV

`include "uvm_macros.svh"
import uvm_pkg::*;

`include "spi_axi_seq_item.sv"
`include "spi_axi_driver.sv"
`include "spi_axi_monitor.sv"

    typedef uvm_sequencer#(spi_axi_seq_item) spi_axi_sequencer;

    class spi_axi_agent extends uvm_agent;
        `uvm_component_utils(spi_axi_agent)

        spi_axi_driver    drv;
        spi_axi_monitor   mon;
        spi_axi_sequencer sqr;

        function new(string name, uvm_component parent);
            super.new(name, parent);
        endfunction
        
        virtual function void build_phase(uvm_phase phase);
            super.build_phase(phase);
            
            mon = spi_axi_monitor::type_id::create("mon", this);

            if (get_is_active() == UVM_ACTIVE) begin
                drv = spi_axi_driver::type_id::create("drv", this);
                sqr = spi_axi_sequencer::type_id::create("sqr", this);
            end
        endfunction

        virtual function void connect_phase(uvm_phase phase);
            super.connect_phase(phase);
            
            if (get_is_active() == UVM_ACTIVE) begin
                drv.seq_item_port.connect(sqr.seq_item_export);
            end
        endfunction
        
    endclass
`endif
