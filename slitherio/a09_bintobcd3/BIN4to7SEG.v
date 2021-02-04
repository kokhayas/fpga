// 4bit binary to 7segment driver circuit
// Displays like: 0123456789AbCdEF

module BIN4to7SEG (BIN4, SEG7);

    input [3:0] BIN4;
    output [6:0] SEG7;
    
    function [6:0] segpat;
        input [3:0] BIN4;
        begin
            case (BIN4)
                4'b0000:    segpat = 7'b1000000;
                4'b0001:    segpat = 7'b1111001;
                4'b0010:    segpat = 7'b0100100;
                4'b0011:    segpat = 7'b0110000;
                4'b0100:    segpat = 7'b0011001;
                4'b0101:    segpat = 7'b0010010;
                4'b0110:    segpat = 7'b0000010;
                4'b0111:    segpat = 7'b1111000;
                4'b1000:    segpat = 7'b0000000;
                4'b1001:    segpat = 7'b0010000;
                4'b1010:    segpat = 7'b0001000;
                4'b1011:    segpat = 7'b0000011;
                4'b1100:    segpat = 7'b1000110;
                4'b1101:    segpat = 7'b0100001;
                4'b1110:    segpat = 7'b0000110;
                4'b1111:    segpat = 7'b0001110;
            endcase
        end
    endfunction
    assign SEG7 = segpat(BIN4);
endmodule
