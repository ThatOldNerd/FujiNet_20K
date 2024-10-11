module FujiNet_Top (
// System Wide IOs
    input   clk,
// SPI Buss IOs
    input   ESP32_SCK,
    input   ESP32_SSEL,
    input   ESP32_MOSI,
    output  ESP32_MISO,
// CPU Decoder IOs
    input   IOControl,
    input   BussAvailable,
    output  BussRequest,
    inout   [15:0] Address,
    inout   [7:0]  Memory,
    inout   MEMControl,
    inout   BussWR,
    inout   BussRd
 );

/* ESP-32 instanation
module ESP32_SPI_slave(
        input clk,
        input SCK, 
        input SSEL, 
        input MOSI,
        output [7:0] Data_in,
        output MISO,
        output reg Data_done,
        input [7:0] Data_out
); 
*/

wire [15:0] ESP32_data_in;
wire [15:0]  ESP32_data_out;

ESP32_SPI_slave ESP32_Communication (
        .clk    (clk),
        .SCK    (ESP32_SCK),
        .SSEL   (ESP32_SSEL),
        .MOSI   (ESP32_MOSI),
        .Data_in (ESP32_data_in),
        .MISO   (ESP32_MISO),
        .Data_done (ESP32_byte_done),
        .Data_out (ESP32_data_out)
);

wire [15:0] IOAddress;

Z80_Access Z80_Communication (
    .clk        (clk),
    .Z80_IOrq   (IOControl),
    .BusAck     (BussAvailable),
    .BusRQ      (BussRequest),
    .ReadAddress(IOAddress),
    .Z80_MEMrq  (MEMControl),
    .Address    (Address), 
    .Memory     (Memory),
    .Z80_WR     (BussWR),
    .Z80_RD     (BussRd)
);
  reg [15:0] R_Temp_data;

always @ (posedge clk) begin
        if (ESP32_byte_done) R_Temp_data <= IOAddress;
end

assign ESP32_data_out = R_Temp_data;
assign Memory = 8'hzz;
assign Address = 16'hzzzz;
assign BussRequest = 1'bz;
assign BussWR = 1'bz;
assign BussRd = 1'bz;

endmodule
    
    