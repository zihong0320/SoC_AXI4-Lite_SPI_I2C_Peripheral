`ifndef SPI_AXI_INTERFACE_SV
`define SPI_AXI_INTERFACE_SV

interface spi_axi_if #(
    parameter int DATA_WIDTH = 32,
    parameter int ADDR_WIDTH = 4
) (
    input logic clk, 
    input logic reset_n
);

    logic [ADDR_WIDTH-1:0] awaddr;
    logic [2:0]            awprot;
    logic                  awvalid;
    logic                  awready;
    logic [DATA_WIDTH-1:0] wdata;
    logic [(DATA_WIDTH/8)-1:0] wstrb;
    logic                  wvalid;
    logic                  wready;
    logic [1:0]            bresp;
    logic                  bvalid;
    logic                  bready;
    logic [ADDR_WIDTH-1:0] araddr;
    logic [2:0]            arprot;
    logic                  arvalid;
    logic                  arready;
    logic [DATA_WIDTH-1:0] rdata;
    logic [1:0]            rresp;
    logic                  rvalid;
    logic                  rready;

    logic                  sclk;
    logic                  mosi;
    logic                  miso;
    logic                  cs_n;
    logic [7:0]            miso_spy;

    clocking drv_cb @(posedge clk);
        default input #1step output #0;
        
        output awaddr, awprot, awvalid;
        output wdata, wstrb, wvalid;
        output bready;
        output araddr, arprot, arvalid;
        output rready;
        
        input  awready;
        input  wready;
        input  bresp, bvalid;
        input  arready;
        input  rdata, rresp, rvalid;

        output miso;
        input  sclk, mosi, cs_n;
    endclocking

    clocking mon_cb @(posedge clk);
        default input #1step;
        
        input awaddr, awprot, awvalid, awready;
        input wdata, wstrb, wvalid, wready;
        input bresp, bvalid, bready;
        input araddr, arprot, arvalid, arready;
        input rdata, rresp, rvalid, rready;
        
        input sclk, mosi, miso, cs_n;
    endclocking

    modport mp_drv(clocking drv_cb, input clk, input reset_n);
    modport mp_mon(clocking mon_cb, input clk, input reset_n);

endinterface

`endif
