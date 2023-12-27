module axi_stream_demux_n #(parameter DATA_WIDTH = 16, ADDR_WIDTH = 4, ADDR_NUM = 1 << ADDR_WIDTH) (
    //system inputs
    input                       aclk_i,
    input                       aresetn_i,
    //In chanels
    input      [DATA_WIDTH-1:0] tdata_i,
    input      [ADDR_WIDTH-1:0] taddr_i,
    input                       tvalid_i,
    output                      tready_o,
    //Out chanels
    output     [DATA_WIDTH-1:0] tdata_o [0:ADDR_NUM-1],
    output reg   [ADDR_NUM-1:0] tvalid_o,
    input        [ADDR_NUM-1:0] tready_i
);

    wire valid_o;
    assign valid_o = |tvalid_o;

    assign tready_o = ~ valid_o;

    reg [DATA_WIDTH-1:0] data_r;

    always @(posedge aclk_i or negedge aresetn_i)
    if     ( !aresetn_i )          data_r <= {ADDR_NUM{1'b0}};
    else if ( tvalid_i & tready_o) data_r <= tdata_i;
    else                           data_r <= data_r; 

    always @(posedge aclk_i or negedge aresetn_i)
    if      ( !aresetn_i )             tvalid_o          <= {ADDR_NUM{1'b0}};
    else if (   tvalid_i & tready_o  ) tvalid_o[taddr_i] <= 1'b1;
    else if ( |(tvalid_o & tready_i) ) tvalid_o          <= {ADDR_NUM{1'b0}};
    else                               tvalid_o          <= tvalid_o;
        
    genvar i;

    generate
        for (i = 0; i < ADDR_NUM; i = i + 1) begin 
            assign tdata_o[i] = (tvalid_o[i]) ? data_r : {DATA_WIDTH {1'bX}};
        end
    endgenerate


endmodule
