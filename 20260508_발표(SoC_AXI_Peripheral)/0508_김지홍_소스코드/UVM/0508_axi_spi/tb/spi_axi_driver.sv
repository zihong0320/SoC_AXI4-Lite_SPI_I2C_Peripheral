`ifndef SPI_AXI_DRIVER_SV
`define SPI_AXI_DRIVER_SV

`include "uvm_macros.svh"
import uvm_pkg::*;

class spi_axi_driver extends uvm_driver #(spi_axi_seq_item);
    `uvm_component_utils(spi_axi_driver)
    
    virtual spi_axi_if sif;

    logic [7:0] current_miso_data;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if (!uvm_config_db #(virtual spi_axi_if)::get(this, "", "sif", sif)) begin
            `uvm_fatal(get_type_name(), "error uvm_config_db in driver.");
        end
    endfunction

    virtual task run_phase(uvm_phase phase);
        sif.drv_cb.awaddr  <= 0;
        sif.drv_cb.awprot  <= 3'b000;
        sif.drv_cb.awvalid <= 1'b0;
        
        sif.drv_cb.wdata   <= 0;
        sif.drv_cb.wstrb   <= 4'b0000;
        sif.drv_cb.wvalid  <= 1'b0;
        
        sif.drv_cb.bready  <= 1'b0;

        sif.drv_cb.araddr  <= 0;
        sif.drv_cb.arprot  <= 3'b000;
        sif.drv_cb.arvalid <= 1'b0;
        
        sif.drv_cb.rready  <= 1'b0;

        sif.miso <= 1'b0;
        current_miso_data = 8'h00;

        wait(sif.reset_n === 1'b1);
        @(sif.drv_cb);

        fork
            begin
                forever begin
                    seq_item_port.get_next_item(req);
                    
                    current_miso_data = req.s_tx_data;
                    sif.miso_spy = req.s_tx_data;

                    if (req.is_write) begin
                        drive_axi_write(req);
                    end else begin
                        drive_axi_read(req);
                    end
                    
                    seq_item_port.item_done();
                end
            end
            
            begin
                drive_miso_background();
            end
        join
    endtask

    virtual task drive_axi_write(spi_axi_seq_item item);
        sif.drv_cb.awaddr  <= item.addr;
        sif.drv_cb.awvalid <= 1'b1;
        
        sif.drv_cb.wdata   <= item.wdata;
        sif.drv_cb.wstrb   <= 4'hf;
        sif.drv_cb.wvalid  <= 1'b1;

        fork
            begin
                do begin
                    @(sif.drv_cb);
                end while (sif.drv_cb.awready !== 1'b1);
                sif.drv_cb.awvalid <= 1'b0;
            end
            begin
                do begin
                    @(sif.drv_cb);
                end while (sif.drv_cb.wready !== 1'b1);
                sif.drv_cb.wvalid <= 1'b0;
            end
        join

        sif.drv_cb.bready <= 1'b1;
        do begin
            @(sif.drv_cb);
        end while (sif.drv_cb.bvalid !== 1'b1);
        
        item.resp = sif.drv_cb.bresp;
        sif.drv_cb.bready <= 1'b0;
    endtask

    virtual task drive_axi_read(spi_axi_seq_item item);
        sif.drv_cb.araddr  <= item.addr;
        sif.drv_cb.arvalid <= 1'b1;
        
        do begin
            @(sif.drv_cb);
        end while (sif.drv_cb.arready !== 1'b1);
        sif.drv_cb.arvalid <= 1'b0;

        sif.drv_cb.rready <= 1'b1;
        do begin
            @(sif.drv_cb);
        end while (sif.drv_cb.rvalid !== 1'b1);
        
        item.rdata = sif.drv_cb.rdata;
        item.resp  = sif.drv_cb.rresp;
        sif.drv_cb.rready <= 1'b0;
    endtask

    virtual task drive_miso_background();
        logic [7:0] shift_reg;
        forever begin
            wait(sif.cs_n === 1'b0);
            shift_reg = current_miso_data;
            
            for (int i = 0; i < 8; i++) begin
                sif.miso = shift_reg[7]; // MSB부터 출력
                
                @(negedge sif.sclk);
                shift_reg = {shift_reg[6:0], 1'b0};
            end
            
            wait(sif.cs_n === 1'b1);
        end
    endtask

endclass

`endif
