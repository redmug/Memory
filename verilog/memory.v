`timescale 1ns / 1ps
//states
`define START 3'b000
`define INIT 3'b001
`define WAIT_AW 3'b010
`define WAIT_W 3'b011
`define MAX_STATE 2'b011

module memory(clk,
              rst,
              aw_id,
              aw_addr,
              aw_len,
              aw_size,
              aw_burst,
              aw_cache,
              aw_prot,
              aw_qos,
              aw_region,
              //aw_user,
              aw_ready,
              aw_valid,
              w_data,
              w_strb,
              w_last,
              //w_user,
              w_ready,
              w_valid,
              b_resp,
              b_id,
              //b_user,
              b_ready,
              b_valid,
              ar_id,
              ar_addr,
              ar_len,
              ar_size,
              ar_burst,
              ar_cache,
              ar_prot,
              ar_qos,
              ar_region,
              //ar_user,
              ar_ready,
              ar_valid,
              r_id,
              r_data,
              r_resp,
              //r_user,
              r_ready,
              r_valid
              );
  parameter   DATA_WIDTH = 64;
  parameter   ADDRESS_WIDTH = 64;
  parameter   ID_WIDTH = 1;
//  parameter

//Genreal input
  input    wire                     clk;
  input    wire                     rst;
//AW
  input    wire [ID_WIDTH-1:0]      aw_id;
  input    wire [ADDRESS_WIDTH-1:0] aw_addr;
  input    wire [7:0]               aw_len;
  input    wire [2:0]               aw_size;
  input    wire [1:0]               aw_burst;
  input    wire [3:0]               aw_cache;
  input    wire [2:0]               aw_prot;
  input    wire [3:0]               aw_qos;
  input    wire [3:0]               aw_region;
  //input    wire       aw_user,
  output   wire                      aw_ready;
  input    wire                     aw_valid;
//W
  input    wire [DATA_WIDTH-1:0]    w_data;
  input    wire [7:0]               w_strb;
  input    wire                     w_last;
  //input    wire       w_user,
  output   reg                      w_ready;
  input    wire                     w_valid;
//B
  output   reg  [1:0]               b_resp;
  output   reg  [ID_WIDTH-1:0]      b_id;
  //input    wire       b_user,
  input    wire                     b_ready;
  output   reg                      b_valid;
//AR
  input    wire [ID_WIDTH-1:0]      ar_id;
  input    wire [ADDRESS_WIDTH-1:0] ar_addr;
  input    wire [7:0]               ar_len;
  input    wire [2:0]               ar_size;
  input    wire [1:0]               ar_burst;
  input    wire [3:0]               ar_cache;
  input    wire [2:0]               ar_prot;
  input    wire [3:0]               ar_qos;
  input    wire [3:0]               ar_region;
  //input    wire       ar_user,
  output   reg                      ar_ready;
  input    wire                     ar_valid;
//R
  output   reg  [ID_WIDTH:0]        r_id;
  output   reg  [DATA_WIDTH:0]      r_data;
  output   reg  [1:0]               r_resp;
  //input    wire       r_user,
  input    wire                     r_ready;
  output   reg                     r_valid;

//  enum    {START, INIT, WAIT_AW, WAIT_W}
  reg [2:0]             state, state_next;  //states
  reg                   aw_ready_next;
  reg                   w_ready_next;
  reg [1:0]             b_resp_next;
  reg [ID_WIDTH-1:0]    b_id_next;
  reg                   b_valid_next;
  reg                   ar_ready_next;
  reg [ID_WIDTH-1:0]    r_id_next;
  reg [DATA_WIDTH-1:0]  r_data_next;
  reg [1:0]             r_resp_next;
  reg                   r_valid_next;
  reg [1:0]             outstandaing_w, outstandaing_w_next;
  wire                  up_w;
  wire                  down_w;
  wire                  stall_w;



  assign stall_w = &(outstandaing_w);
  assign up_w = (aw_ready & aw_valid);
  assign down_w = (b_ready & b_valid);

  assign aw_ready = ~stall_w;
  //assign b_valid = ;

always@(posedge clk or negedge rst) begin
  if(~rst)begin
    //AW / W / R
    state     <=  `START;
//    aw_ready  <=  1'b0;
    w_ready   <=  1'b0;
    b_resp    <=  2'b00;
    b_id      <=  'b0;
    b_valid   <=  1'b0;
    ar_ready  <=  1'b0;
    r_id      <=  'b0;
    r_data    <=  'b0;
    r_resp    <=  2'b0;
    r_valid   <=  1'b0;
    //other
    outstandaing_w <= 'b0;
  end
  else begin
    state     <=  state_next;
//    aw_ready  <=  aw_ready_next;
    w_ready   <=  w_ready_next;
    b_resp    <=  b_resp_next;
    b_id      <=  b_id_next;
    b_valid   <=  b_valid_next;
    ar_ready  <=  ar_ready_next;
    r_id      <=  r_id_next;
    r_data    <=  r_data_next;
    r_resp    <=  r_resp_next;
    r_valid   <=  r_valid_next;
    //other
    outstandaing_w <= outstandaing_w_next;
  end
end
//tracking
always@(*)begin
  outstandaing_w_next = outstandaing_w;
  case({up_w,down_w})
    2'b00:begin
    //nothing happens
    end
    2'b01:begin
    //received a B resp - decrement
    outstandaing_w_next = outstandaing_w - 1;
    end
    2'b10:begin
    //recieved a AW trans - increment
    outstandaing_w_next = outstandaing_w + 1;
    end
    2'b11:begin
    //recieved B resp and AW trans
    end
  endcase
end
//main
always@(*)begin
  state_next     =    state;
//  aw_ready_next  =    ~stall_w;
  w_ready_next   =    w_ready;
  b_resp_next    =    b_resp;
  b_id_next      =    b_id;
  b_valid_next   =    b_valid;
  ar_ready_next  =    ar_ready;
  r_id_next      =    r_id;
  r_data_next    =    r_data;
  r_resp_next    =    r_resp;
  r_valid_next   =    r_valid;



  case(state)
    `START:begin
      state_next = `INIT;
    end
    `INIT:begin
      aw_ready_next = 1'b1;   //ready to recieve a write

    end
    `WAIT_AW:begin

    end
    `WAIT_W:begin
    end
    default:begin
    end
  endcase


end

endmodule
