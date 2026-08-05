`ifndef SPI_AXI_COVERAGE_SV
`define SPI_AXI_COVERAGE_SV

`include "uvm_macros.svh"
import uvm_pkg::*;
`include "spi_axi_seq_item.sv"

    class spi_axi_coverage extends uvm_subscriber#(spi_axi_seq_item);
        `uvm_component_utils(spi_axi_coverage)
        spi_axi_seq_item tx; 

        covergroup spi_cg;
            cp_m_tx_data: coverpoint tx.wdata[7:0] {
                bins low_m = {[8'h00:8'h3f]};
                bins mid_m = {[8'h40:8'hbf]};
                bins high_m = {[8'hc0:8'hff]};
            }
            cp_s_tx_data: coverpoint tx.s_tx_data {
                bins low_s = {[8'h00:8'h3f]};
                bins mid_s = {[8'h40:8'hbf]};
                bins high_s = {[8'hc0:8'hff]};
            }
        endgroup

        function new(string name, uvm_component parent);
            super.new(name, parent);
            spi_cg = new();
        endfunction

        function void write(spi_axi_seq_item t); 
            tx = t;
            if (tx.is_write && (tx.addr == spi_axi_seq_item::ADDR_TX)) begin
                spi_cg.sample();
            end
        endfunction

        virtual function void report_phase(uvm_phase phase);
            `uvm_info(get_type_name(), "==== AXI Coverage Summary ====", UVM_LOW);
            `uvm_info(get_type_name(), $sformatf(" Overall: %.1f%%",
                spi_cg.get_coverage()), UVM_LOW);
            `uvm_info(get_type_name(), $sformatf(" tx_data_m : %.1f%%",
                spi_cg.cp_m_tx_data.get_coverage()), UVM_LOW);
            `uvm_info(get_type_name(), $sformatf(" tx_data_s : %.1f%%",
                spi_cg.cp_s_tx_data.get_coverage()), UVM_LOW);
            `uvm_info(get_type_name(), "==== AXI Coverage Summary ====\n\n", UVM_LOW);
        endfunction
    endclass

`endif
