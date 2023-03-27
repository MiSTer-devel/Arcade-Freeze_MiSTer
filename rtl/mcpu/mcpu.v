
module mcpu(
  input         clk_sys,
  input         reset,
  input  [7:0]  mcpu_din,
  output [7:0]  mcpu_dout,
  output [15:0] mcpu_ab,
  output        mcpu_wr,
  output        mcpu_rd,
  output        mcpu_io,
  output        mcpu_m1,
  input         vb
);

wire        mcpu_rd_n;
wire        mcpu_wr_n;
wire        mcpu_m1_n;
wire        mcpu_mreq_n;
wire        mcpu_iorq_n;
wire        mcpu_rfsh_n;
wire        mcpu_wait_n = 1'b1;
reg         mcpu_int_n = 1'b1;

assign mcpu_io = ~mcpu_iorq_n;
assign mcpu_m1 = ~mcpu_m1_n;
assign mcpu_wr = ~mcpu_wr_n;
assign mcpu_rd = ~mcpu_rd_n;

wire cen;
clk_en #(16-1) mcpu_clk_en(clk_sys, cen);

reg old_vb;
reg [7:0] data_latch;
always @(posedge clk_sys) begin
  old_vb <= vb;
  if (~old_vb & vb) mcpu_int_n <= 1'b0;
  if (~(mcpu_iorq_n|mcpu_m1_n)) mcpu_int_n <= 1'b1;
  if (~mcpu_rd_n) data_latch <= mcpu_din;
end

`define TV80_REFRESH 1
tv80s cpu(
  .reset_n ( ~reset      ),
  .clk     ( clk_sys     ),
  .cen     ( cen         ),
  .wait_n  ( mcpu_wait_n ),
  .int_n   ( mcpu_int_n  ),
  .nmi_n   ( mcpu_nmi_n  ),
  .busrq_n ( 1'b1        ),
  .m1_n    ( mcpu_m1_n   ),
  .mreq_n  ( mcpu_mreq_n ),
  .iorq_n  ( mcpu_iorq_n ),
  .rd_n    ( mcpu_rd_n   ),
  .wr_n    ( mcpu_wr_n   ),
  .rfsh_n  ( mcpu_rfsh_n ),
  .halt_n  (             ),
  .busak_n (             ),
  .A       ( mcpu_ab     ),
  .di      ( data_latch  ),
  .dout    ( mcpu_dout   )
);

endmodule
