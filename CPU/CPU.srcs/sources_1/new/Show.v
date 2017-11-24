module Show(
    input Reset,
    input CLK,
    input [7:0] in1, [7:0] in2,
    output reg [3:0] place,
    output [7:0] code
    );
    
reg [3:0] BCD;

initial place = 4'b1110;


always @(posedge CLK) begin
    case(place)
    4'b1110:begin
        place = 4'b1101;
        BCD = in2[7:4];
    end
    4'b1101:begin
        place = 4'b1011;
        BCD = in1[3:0];
    end
    4'b1011:begin
        place = 4'b0111;
        BCD = in1[7:4];
    end
    4'b0111:begin
        place = 4'b1110;
        BCD = in2[3:0];
    end
    default: begin
        place = 4'b1110;
        BCD = 4'b1111;
    end
    endcase
end 

_7_seg_display _7_seg(
    .Reset(Reset),
    .BCD(BCD),
    .code(code)
);

    
endmodule
