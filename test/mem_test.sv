`include "../verilog/memory.v"
`timescale 1ns / 1ps

`define ID_WIDTH 1
`define ADDRESS_WIDTH 32
`define DATA_WIDTH 64


module mem_test;

reg random;

reg                            clk;
reg                            rst;
wire  [`ID_WIDTH-1:0]           aw_id;
wire  [`ADDRESS_WIDTH-1:0]      aw_addr;
wire  [7:0]                     aw_len;
wire  [2:0]                     aw_size;
wire  [1:0]                     aw_burst;
wire  [3:0]                     aw_cache;
wire  [2:0]                     aw_prot;
wire  [3:0]                     aw_qos;
wire  [3:0]                     aw_region;
//wire         aw_user;
wire                            aw_ready;
wire                            aw_valid;
wire  [`DATA_WIDTH-1:0]         w_data;
wire  [7:0]                     w_strb;
wire                            w_last;
//wire         w_user;
wire                            w_ready;
wire                            w_valid;
wire  [1:0]                     b_resp;
wire  [`ID_WIDTH-1:0]           b_id;
//wire         b_user;
wire                            b_ready;
wire                            b_valid;
wire  [`ID_WIDTH-1:0]           ar_id;
wire  [`ADDRESS_WIDTH-1:0]      ar_addr;
wire  [7:0]                     ar_len;
wire  [2:0]                     ar_size;
wire  [1:0]                     ar_burst;
wire  [3:0]                     ar_cache;
wire  [2:0]                     ar_prot;
wire  [3:0]                     ar_qos;
wire  [3:0]                     ar_region;
//wire                            ar_user;
wire                            ar_ready;
wire                            ar_valid;
wire  [`ID_WIDTH:0]             r_id;
wire  [`DATA_WIDTH:0]           r_data;
wire  [1:0]                     r_resp;
wire                            r_ready;
wire                            r_valid;

//main
initial begin
  rst = 1;
  clk = 0;
  #10;
  rst = 0;
  #10;
  rst = 1;
  #1000;
  random = 0;
  #10 random =1;
  #10 $finish;
end

//clock

always #5 clk = !clk;

//report
initial begin
    $dumpfile("sim.vcd");
    $dumpvars(0,mem_test);
    $monitor("%t\tState: %0d",$time, m1.state);
    $monitor("At time %t, rst = %h (%0d)",$time, rst, rst);
end
 memory #(
   .DATA_WIDTH(`DATA_WIDTH),
   .ADDRESS_WIDTH(`ADDRESS_WIDTH),
   .ID_WIDTH(`ID_WIDTH))
        m1 (  .clk(clk),
              .rst(rst),
              .aw_id(aw_id),
              .aw_addr(aw_addr),
              .aw_len(aw_len),
              .aw_size(aw_size),
              .aw_burst(aw_burst),
              .aw_cache(aw_cache),
              .aw_prot(aw_prot),
              .aw_qos(aw_qos),
              .aw_region(aw_region),
            //.aw_user,
              .aw_ready(aw_ready),
              .aw_valid(aw_valid),
              .w_data(w_data),
              .w_strb(w_strb),
              .w_last(w_last),
            //.w_user,
              .w_ready(w_ready),
              .w_valid(w_valid),
              .b_resp(b_resp),
              .b_id(b_id),
            //.b_user,
              .b_ready(b_ready),
              .b_valid(b_valid),
              .ar_id(ar_id),
              .ar_addr(ar_addr),
              .ar_len(ar_len),
              .ar_size(ar_size),
              .ar_burst(ar_burst),
              .ar_cache(ar_cache),
              .ar_prot(ar_prot),
              .ar_qos(ar_qos),
              .ar_region(ar_region),
            //.ar_user,
              .ar_ready(ar_ready),
              .ar_valid(ar_valid),
              .r_id(r_id),
              .r_data(r_data),
              .r_resp(r_resp),
            //.r_user,
              .r_ready(r_ready),
              .r_valid(r_valid)
              );
endmodule //mem_test
