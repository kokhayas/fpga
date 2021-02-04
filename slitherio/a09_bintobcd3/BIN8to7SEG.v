//リスト5.4: BIN8to7SEG.v - 8ビットバイナリ(0～255)を，3桁BCDに変換しダイナミック表示

module add3(in,out);
input [3:0] in;
output [3:0] out;
reg [3:0] out;

always @ (in)
    case (in)
    4'b0000: out <= 4'b0000;
    4'b0001: out <= 4'b0001;
    4'b0010: out <= 4'b0010;
    4'b0011: out <= 4'b0011;
    4'b0100: out <= 4'b0100;
    4'b0101: out <= 4'b1000;
    4'b0110: out <= 4'b1001;
    4'b0111: out <= 4'b1010;
    4'b1000: out <= 4'b1011;
    4'b1001: out <= 4'b1100;
    default: out <= 4'b0000;
    endcase
endmodule

module BIN8toBCD3(BIN,ONES,TENS,HUNDREDS);
input [7:0] BIN;
output [3:0] ONES, TENS;
output [3:0] HUNDREDS;
wire [3:0] c1,c2,c3,c4,c5,c6,c7;
wire [3:0] d1,d2,d3,d4,d5,d6,d7;

    assign d1 = {1'b0,BIN[7:5]};
    assign d2 = {c1[2:0],BIN[4]};
    assign d3 = {c2[2:0],BIN[3]};
    assign d4 = {c3[2:0],BIN[2]};
    assign d5 = {c4[2:0],BIN[1]};
    assign d6 = {1'b0,c1[3],c2[3],c3[3]};
    assign d7 = {c6[2:0],c4[3]};
    add3 m1(d1,c1);
    add3 m2(d2,c2);
    add3 m3(d3,c3);
    add3 m4(d4,c4);
    add3 m5(d5,c5);
    add3 m6(d6,c6);
    add3 m7(d7,c7);
    assign ONES = {c5[2:0],BIN[0]};
    assign TENS = {c7[2:0],c5[3]};
    assign HUNDREDS = {2'b0,c6[3],c7[3]};
endmodule

module BIN8to7SEG3(CLK, RSTn, BIN, SEG7OUT, SEG7COM);
input CLK;
input RSTn;
input [7:0] BIN;
output [6:0] SEG7OUT;
output [3:0] SEG7COM;

wire [3:0] ONES, TENS, HUNDREDS;
reg [17:0] prescaler_7seg; // 7seg display prescaler
wire carryout_7seg; // switch display
reg [1:0] counter_7seg;

    // convert BIN to BCD
    BIN8toBCD3 bintobcd3 (BIN,ONES,TENS,HUNDREDS);

// 7segment display part
    // prescaler that countsup x12 times as counter
    always @ (posedge CLK or negedge RSTn) begin
        if(RSTn == 1'b0)
            prescaler_7seg <= 0;
        else if(prescaler_7seg == 'd250000)
            prescaler_7seg <= 18'b0;
        else
            prescaler_7seg <= prescaler_7seg + 18'b1;
    end
    assign carryout_7seg = (prescaler_7seg == 'd250000)? 1'b1 : 1'b0;

    // Display output selector
    always @(posedge CLK or negedge RSTn) begin
        if(RSTn == 1'b0)
            counter_7seg <= 2'b0;
        else if (carryout_7seg == 1'b1)
            if (counter_7seg == 2'b10)
                counter_7seg <= 2'b0;
            else
                counter_7seg <= counter_7seg + 2'b1;
        else
                counter_7seg <= counter_7seg;
    end
    
function [3:0] select7seg;
    input [1:0] counter_7seg;
    input [3:0] ONES;
    input [3:0] TENS;
    input [3:0] HUNDREDS;
        
    case (counter_7seg)
        default:    select7seg = 4'b1111;
        2'b00:    select7seg = ONES;
        2'b01:    select7seg = TENS;
        2'b10:  select7seg = HUNDREDS;
    endcase
endfunction

BIN4to7SEG out7seg (select7seg(counter_7seg,ONES,TENS,HUNDREDS),SEG7OUT);

function [3:0] select7segcom;
    input [1:0] counter_7seg;
    case (counter_7seg)
        default:    select7segcom = 4'b1111;
        2'b00:    select7segcom = 4'b1110;
        2'b01:    select7segcom = 4'b1101;
        2'b10:    select7segcom = 4'b1011;
    endcase
endfunction
    assign SEG7COM = select7segcom(counter_7seg);
endmodule
