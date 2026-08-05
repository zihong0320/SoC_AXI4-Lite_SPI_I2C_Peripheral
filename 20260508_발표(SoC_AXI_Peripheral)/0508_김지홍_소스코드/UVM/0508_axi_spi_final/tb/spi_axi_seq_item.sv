`ifndef SPI_AXI_SEQ_ITEM_SV
`define SPI_AXI_SEQ_ITEM_SV

`include "uvm_macros.svh"
import uvm_pkg::*;

class spi_axi_seq_item extends uvm_sequence_item;

    rand bit [31:0] addr; 
    rand bit [31:0] wdata;
    rand bit        is_write;
    
    bit [31:0]      rdata;
    bit [1:0]       resp;

    rand logic [7:0] s_tx_data; 

    static const bit [31:0] ADDR_CTRL   = 32'h00;
    static const bit [31:0] ADDR_TX     = 32'h04;
    static const bit [31:0] ADDR_STATUS = 32'h08;
    static const bit [31:0] ADDR_RX     = 32'h0C;

    constraint c_addr_align {
        addr[1:0] == 2'b00;
        addr inside {ADDR_CTRL, ADDR_TX, ADDR_STATUS, ADDR_RX};
    }

    constraint c_m_tx_data_corner {
        if (is_write && (addr == ADDR_TX)) {
            wdata[7:0] dist {
                8'h00 := 1,
                8'hFF := 1,
                8'haa := 1,
                8'h55 := 1,
                [8'h01:8'hFE] :/ 6
            };
            wdata[31:8] == 24'h0;
        }
    }   

    constraint c_s_tx_data_corner {
        s_tx_data dist {
            8'h00 := 1,
            8'hFF := 1,
            8'haa := 1,
            8'h55 := 1,
            [8'h01:8'hFE] :/ 6
        };
    }   

    `uvm_object_utils_begin(spi_axi_seq_item)
        `uvm_field_int(addr, UVM_ALL_ON)
        `uvm_field_int(wdata, UVM_ALL_ON)
        `uvm_field_int(is_write, UVM_ALL_ON)
        `uvm_field_int(rdata, UVM_ALL_ON)
        `uvm_field_int(resp, UVM_ALL_ON)
        `uvm_field_int(s_tx_data, UVM_ALL_ON)
    `uvm_object_utils_end
    
    function new(string name = "spi_axi_seq_item");
        super.new(name);
    endfunction

    function string convert2string();
        string rw_str = is_write ? "WRITE" : "READ ";
        if (is_write)
            return $sformatf("[AXI %s] ADDR: 0x%02h | WDATA: 0x%08h | SLV_MISO: 0x%02h", 
                rw_str, addr, wdata, s_tx_data);
        else
            return $sformatf("[AXI %s] ADDR: 0x%02h | RDATA: 0x%08h | SLV_MISO: 0x%02h", 
                rw_str, addr, rdata, s_tx_data);
    endfunction

endclass

`endif
