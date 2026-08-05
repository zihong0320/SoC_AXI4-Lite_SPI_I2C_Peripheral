`ifndef SPI_AXI_SEQUENCE_SV
`define SPI_AXI_SEQUENCE_SV

`include  "uvm_macros.svh"
import uvm_pkg::*;
`include "spi_axi_seq_item.sv"
    
class spi_axi_rand_seq extends uvm_sequence #(spi_axi_seq_item);
    `uvm_object_utils(spi_axi_rand_seq)
    
    int num_trans = 10; 

    function new(string name = "spi_axi_rand_seq");
        super.new(name);
    endfunction

    task body();
        spi_axi_seq_item item;
        
        logic [7:0] current_s_tx; 
        logic [31:0] read_val;

        `uvm_info(get_type_name(), $sformatf("Starting AXI Sequence for %0d transactions...", num_trans), UVM_LOW)

        repeat (num_trans) begin
            item = spi_axi_seq_item::type_id::create("item");
            start_item(item);
            
            if (!item.randomize() with { 
                is_write == 1'b1; 
                addr == spi_axi_seq_item::ADDR_TX; 
            }) begin
                `uvm_fatal(get_type_name(), "TX Write randomize() fail!")
            end
            
            current_s_tx = item.s_tx_data; 
            
            `uvm_info(get_type_name(), $sformatf("1. WRITE TX REG: %s", item.convert2string()), UVM_MEDIUM)
            finish_item(item);

            item = spi_axi_seq_item::type_id::create("item");
            start_item(item);
            if (!item.randomize() with {
                is_write == 1'b1;
                addr == spi_axi_seq_item::ADDR_CTRL;
                wdata == {21'b0, 1'b1, 1'b0, 1'b0, 8'h02}; 
                s_tx_data == current_s_tx; 
            }) begin
                `uvm_fatal(get_type_name(), "CTRL Write(1) randomize() fail!")
            end
            `uvm_info(get_type_name(), $sformatf("2-1. WRITE CTRL (START=1): %s", item.convert2string()), UVM_MEDIUM)
            finish_item(item);

            item = spi_axi_seq_item::type_id::create("item");
            start_item(item);
            if (!item.randomize() with {
                is_write == 1'b1;
                addr == spi_axi_seq_item::ADDR_CTRL;
                wdata == {21'b0, 1'b0, 1'b0, 1'b0, 8'h02}; 
                s_tx_data == current_s_tx; 
            }) begin
                `uvm_fatal(get_type_name(), "CTRL Write(0) randomize() fail!")
            end
            `uvm_info(get_type_name(), $sformatf("2-2. WRITE CTRL (START=0): %s", item.convert2string()), UVM_MEDIUM)
            finish_item(item);

            read_val = 32'h1; // 초기값을 busy=1로 가정
            
            while (read_val[0] !== 1'b0) begin 
                item = spi_axi_seq_item::type_id::create("item");
                start_item(item);
                if (!item.randomize() with {
                    is_write == 1'b0;
                    addr == spi_axi_seq_item::ADDR_STATUS;
                    s_tx_data == current_s_tx;
                }) begin
                    `uvm_fatal(get_type_name(), "STATUS Read randomize() fail!")
                end
                finish_item(item);
                read_val = item.rdata; 
            end
            `uvm_info(get_type_name(), "3. STATUS REG Polling Complete! (busy=0)", UVM_MEDIUM)  

            item = spi_axi_seq_item::type_id::create("item");
            start_item(item);
            if (!item.randomize() with {
                is_write == 1'b0;
                addr == spi_axi_seq_item::ADDR_RX;
                s_tx_data == current_s_tx;
            }) begin
                `uvm_fatal(get_type_name(), "RX Read randomize() fail!")
            end
            finish_item(item);
            `uvm_info(get_type_name(), $sformatf("4. READ RX REG: %s", item.convert2string()), UVM_MEDIUM)
            
        end
    endtask
endclass

`endif
