

module Z80_Access(
    input clk,
    input Z80_IOrq,
    input BusAck,
    output BusRQ,
    output [15:0] ReadAddress,
    inout Z80_MEMrq,
    inout [15:0] Address,
    inout [7:0] Memory,
    inout Z80_WR,
    inout Z80_RD
);

reg [15:0] R_Address;
reg [7:0] R_Count = 0;
reg [7:0] R_BussCount = 0;
reg [7:0] R_WRCount = 8'h32;
reg R_CountFlag;
reg R_RequestActive;
reg R_IORQ;

always @ (posedge clk) begin

// Find and store mid RW cycle so that Address is pulled mid cycle
if (!Z80_IOrq & !Z80_WR) begin
    R_RequestActive = 1'b1;
    R_CountFlag = ~R_CountFlag;
    R_IORQ = 1'b1;
    if (!R_CountFlag) R_Count = R_Count + 8'h1; // increment count every other cycle to determine midpoint of WR cycle
    end else begin
    R_RequestActive = 0;
    R_WRCount <= R_Count;
    end
if (!R_RequestActive) R_Count <= 8'h0; //Clear count after count transferred to WRCount
// Read Address from Buss
if (R_RequestActive) begin
    R_BussCount = R_BussCount + 8'h1;
    end else R_BussCount = 0;
    if (R_BussCount == R_WRCount) R_Address <= Address;

end

assign ReadAddress = R_Address;
endmodule



    
    