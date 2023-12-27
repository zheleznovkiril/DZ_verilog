module axi_stream_demux_tb ();
    parameter DATA_WIDTH = 16;
    parameter ADDR_WIDTH = 4;
    localparam ADDR_NUM = 1 << ADDR_WIDTH;

    //system reg s
    reg                   aclk_i = 1'b0;
    reg                   aresetn_i = 1'b0;
    //In chanels
    reg  [DATA_WIDTH-1:0] tdata_i;
    reg  [ADDR_WIDTH-1:0] taddr_i;
    reg                   tvalid_i = 1'b0;
    wire                  tready_o;
    //Out chanels
    wire [DATA_WIDTH-1:0] tdata_o [0:ADDR_NUM-1];
    wire [ADDR_NUM-1:0]   tvalid_o;
    reg  [ADDR_NUM-1:0]   tready_i = 'b0;


    axi_stream_demux_n #(
        .DATA_WIDTH ( DATA_WIDTH ), 
        .ADDR_WIDTH ( ADDR_WIDTH )
    ) uut (
        .aclk_i     ( aclk_i     ),
        .aresetn_i  ( aresetn_i  ),
        .tdata_i    ( tdata_i    ),
        .taddr_i    ( taddr_i    ),
        .tvalid_i   ( tvalid_i   ),
        .tready_o   ( tready_o   ),
        .tdata_o    ( tdata_o    ),
        .tvalid_o   ( tvalid_o   ),
        .tready_i   ( tready_i   )
    );
    
    reg error = 1'b0;

    always #5 aclk_i = ~aclk_i;

    integer i;

    initial begin 
        #10 aresetn_i = 1'b1;
        forever begin 
            for (i = 0; i < 10; i = i + 1) begin
                tdata_i  <= $random;
                taddr_i  <= $random;
                tvalid_i <= 1'b1;
                #10;
                tvalid_i <= 1'b0;
                #(10 * ($random & 7));
                error = !tvalid_o[taddr_i];
                error = tdata_i != tdata_o[taddr_i];
                tready_i[taddr_i] <= 1'b1;
                #10;
                tready_i <= 'b0;
                #10;
            end
            $stop;
            //$finish;
        end
    end
endmodule