`timescale 1ns/1ps
`include "uvm_macros.svh"
import uvm_pkg::*;

`include "spi_axi_interface.sv"
`include "spi_axi_seq_item.sv"
`include "spi_axi_sequence.sv"
`include "spi_axi_driver.sv"
`include "spi_axi_monitor.sv"
`include "spi_axi_agent.sv"
`include "spi_axi_scoreboard.sv"
`include "spi_axi_coverage.sv"
`include "spi_axi_env.sv"
`include "spi_axi_test.sv"

module tb_spi_axi ();
    logic s00_axi_aclk = 0;
    logic s00_axi_aresetn;

    always #5 s00_axi_aclk = ~s00_axi_aclk;

    spi_axi_if sif(s00_axi_aclk, s00_axi_aresetn);

    SPI_v1_0 #(
        .C_S00_AXI_DATA_WIDTH(32),
        .C_S00_AXI_ADDR_WIDTH(4)
    ) dut (
        .sclk(sif.sclk),
        .mosi(sif.mosi),
        .miso(sif.miso),
        .cs_n(sif.cs_n),
        .s00_axi_aclk(s00_axi_aclk),
        .s00_axi_aresetn(s00_axi_aresetn),
        .s00_axi_awaddr(sif.awaddr),
        .s00_axi_awprot(sif.awprot),
        .s00_axi_awvalid(sif.awvalid),
        .s00_axi_awready(sif.awready),
        .s00_axi_wdata(sif.wdata),
        .s00_axi_wstrb(sif.wstrb),
        .s00_axi_wvalid(sif.wvalid),
        .s00_axi_wready(sif.wready),
        .s00_axi_bresp(sif.bresp),
        .s00_axi_bvalid(sif.bvalid),
        .s00_axi_bready(sif.bready),
        .s00_axi_araddr(sif.araddr),
        .s00_axi_arprot(sif.arprot),
        .s00_axi_arvalid(sif.arvalid),
        .s00_axi_arready(sif.arready),
        .s00_axi_rdata(sif.rdata),
        .s00_axi_rresp(sif.rresp),
        .s00_axi_rvalid(sif.rvalid),
        .s00_axi_rready(sif.rready)
    );

    initial begin
        s00_axi_aclk = 0;
        s00_axi_aresetn = 0;
        
        repeat (5) @(posedge s00_axi_aclk);
        
        s00_axi_aresetn = 1;
    end

    initial begin
        uvm_config_db #(virtual spi_axi_if)::set(null, "*", "sif", sif);
        run_test();
    end
    
    initial begin
        $fsdbDumpfile("novas.fsdb");
        $fsdbDumpvars(0, tb_spi_axi, "+all");
    end
endmodule
