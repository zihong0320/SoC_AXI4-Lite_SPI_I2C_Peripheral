`ifndef SPI_AXI_MONITOR_SV
`define SPI_AXI_MONITOR_SV

`include "uvm_macros.svh"
import uvm_pkg::*;

class spi_axi_monitor extends uvm_monitor;
    `uvm_component_utils(spi_axi_monitor)

    uvm_analysis_port #(spi_axi_seq_item) ap;
    virtual spi_axi_if sif;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction
    
    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        ap = new("ap", this);
        if (!uvm_config_db #(virtual spi_axi_if)::get(this, "", "sif", sif)) begin
            `uvm_fatal(get_type_name(), "error uvm_config_db in monitor");
        end
    endfunction

    virtual task run_phase(uvm_phase phase);
        `uvm_info(get_type_name(), "start monitoring SPI AXI Top ...", UVM_MEDIUM)
        
        wait(sif.reset_n === 1'b1);
        
        fork
            monitor_axi_write();
            monitor_axi_read();
        join
    endtask

    virtual task monitor_axi_write();
        spi_axi_seq_item wr_item;
        logic [31:0] captured_addr;
        logic [31:0] captured_data;

        forever begin
            wr_item = spi_axi_seq_item::type_id::create("wr_item");
            wr_item.is_write = 1'b1;

            fork
                begin
                    do begin
                        @(sif.mon_cb);
                    end while (!(sif.mon_cb.awvalid === 1'b1 && sif.mon_cb.awready === 1'b1));
                    captured_addr = sif.mon_cb.awaddr;
                end
                begin
                    do begin
                        @(sif.mon_cb);
                    end while (!(sif.mon_cb.wvalid === 1'b1 && sif.mon_cb.wready === 1'b1));
                    captured_data = sif.mon_cb.wdata;
                end
            join

            do begin
                @(sif.mon_cb);
            end while (!(sif.mon_cb.bvalid === 1'b1 && sif.mon_cb.bready === 1'b1));
            
            wr_item.addr = captured_addr;
            wr_item.wdata = captured_data;
            wr_item.resp = sif.mon_cb.bresp;
            wr_item.s_tx_data = sif.miso_spy;
            `uvm_info(get_type_name(), $sformatf("Monitored AXI WRITE: %s", wr_item.convert2string()), UVM_HIGH)
            ap.write(wr_item);
        end
    endtask

    virtual task monitor_axi_read();
        spi_axi_seq_item rd_item;
        
        forever begin
            rd_item = spi_axi_seq_item::type_id::create("rd_item");
            rd_item.is_write = 1'b0;

            do begin
                @(sif.mon_cb);
            end while (!(sif.mon_cb.arvalid === 1'b1 && sif.mon_cb.arready === 1'b1));
            rd_item.addr = sif.mon_cb.araddr;

            do begin
                @(sif.mon_cb);
            end while (!(sif.mon_cb.rvalid === 1'b1 && sif.mon_cb.rready === 1'b1));
            rd_item.rdata = sif.mon_cb.rdata;
            rd_item.resp = sif.mon_cb.rresp;

            `uvm_info(get_type_name(), $sformatf("Monitored AXI READ: %s", rd_item.convert2string()), UVM_HIGH)
            ap.write(rd_item);
        end
    endtask

endclass
`endif
