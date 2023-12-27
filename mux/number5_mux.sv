module axi_stream_mux_n #(parameter DATA_WIDTH = 16, ADDR_WIDTH = 4, ADDR_NUM = 1 << ADDR_WIDTH) (
    //system inputs
    input                       aclk_i,
    input                       aresetn_i,
    //In chanels
    input      [DATA_WIDTH-1:0] tdata_i [0:ADDR_NUM-1],
    input      [ADDR_NUM-1:0]   tvalid_i,
    output     [ADDR_NUM-1:0]   tready_o,
    //Out chanels
    output reg [DATA_WIDTH-1:0] tdata_o,
    output reg [ADDR_WIDTH-1:0] taddr_o,
    output reg                  tvalid_o,
    input                       tready_i
);
   
    wire [ADDR_NUM-1:0]   mask_w [ADDR_WIDTH-1:0];
    wire [ADDR_WIDTH-1:0] addr_w;

    assign tready_o = {ADDR_NUM{~tvalid_o}};

    always @(posedge aclk_i or negedge aresetn_i)
    if     ( !aresetn_i )              tdata_o <= {ADDR_NUM{1'b0}};
    else if ( |(tvalid_i & tready_o) ) tdata_o <= tdata_i[addr_w];
    else                               tdata_o <= tdata_o;
        
    always @(posedge aclk_i or negedge aresetn_i)
    if     ( !aresetn_i )              taddr_o <= {ADDR_NUM{1'b0}};
    else if ( |(tvalid_i & tready_o) ) taddr_o <= addr_w;
    else                               taddr_o <= taddr_o;   

    always @(posedge aclk_i or negedge aresetn_i)
    if     ( !aresetn_i )               tvalid_o <= 1'b0;
    else if ( |(tvalid_i & tready_o) )  tvalid_o <= 1'b1;
    else if (   tvalid_o & tready_i  )  tvalid_o <= 1'b0;
    else                                tvalid_o <= tvalid_o;


    genvar i, j;
    generate
        for (j = 0; j < ADDR_WIDTH; j = j + 1) begin
            for (i = 0; i < ADDR_NUM; i = i + 1) 
                assign mask_w[j][i] = (i >> j) & 1;
            assign addr_w[j] = |(tvalid_i & mask_w[j]);
        end
    endgenerate


endmodule
