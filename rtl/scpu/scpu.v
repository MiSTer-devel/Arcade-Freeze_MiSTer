
module scpu(
  input         clk_sys,
  input         reset,
  input  [7:0]  scpu_din,
  output [7:0]  scpu_dout,
  output [15:0] scpu_ab,
  output        scpu_wr,
  output        scpu_rd,
  output        scpu_io,
  output        scpu_m1,
  input         scpu_int
);

wire        scpu_rd_n;
wire        scpu_wr_n;
wire        scpu_m1_n;
wire        scpu_mreq_n;
wire        scpu_iorq_n;
wire        scpu_rfsh_n;
wire        scpu_wait_n = 1'b1;
reg         scpu_int_n = 1'b1;

assign scpu_io = ~scpu_iorq_n;
assign scpu_m1 = ~scpu_m1_n;
assign scpu_wr = ~scpu_wr_n;
assign scpu_rd = ~scpu_rd_n;

wire cen;
clk_en #(16-1) scpu_clk_en(clk_sys, cen);

reg old_int;
reg [7:0] data_latch;
always @(posedge clk_sys) begin
  old_int <= scpu_int;
  if (~old_int & scpu_int) scpu_int_n <= 1'b0;
  if (~(scpu_iorq_n|scpu_m1_n)) scpu_int_n <= 1'b1;
  if (~scpu_rd_n) data_latch <= scpu_din;
end

`define TV80_REFRESH 1
tv80s cpu(
  .reset_n ( ~reset      ),
  .clk     ( clk_sys     ),
  .cen     ( cen         ),
  .wait_n  ( scpu_wait_n ),
  .int_n   ( scpu_int_n  ),
  .nmi_n   ( scpu_nmi_n  ),
  .busrq_n ( 1'b1        ),
  .m1_n    ( scpu_m1_n   ),
  .mreq_n  ( scpu_mreq_n ),
  .iorq_n  ( scpu_iorq_n ),
  .rd_n    ( scpu_rd_n   ),
  .wr_n    ( scpu_wr_n   ),
  .rfsh_n  ( scpu_rfsh_n ),
  .halt_n  (             ),
  .busak_n (             ),
  .A       ( scpu_ab     ),
  .di      ( data_latch  ),
  .dout    ( scpu_dout   )
);

endmodule
