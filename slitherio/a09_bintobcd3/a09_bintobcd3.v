//���X�g5.5:  a09_bintobcd3.v - �A�b�v�J�E���^�o�͂� BIN8toBCD3 ���W���[���ɓ��͂��ă_�C�i�~�b�N�\��
// 8bit bin counter - display to 3x7seg display

module a09_bintobcd3(CLK,RSTn,PUSH0,PUSH1, PUSH2, PUSH3, SEG7OUT,SEG7COM,led);
input CLK;
input RSTn;
input PUSH0;
input PUSH1;
input PUSH2;
input PUSH3;
output [6:0] SEG7OUT;
output [3:0] SEG7COM;
output [9:0] led;

reg [1:0] regpush; 
reg [7:0] counter;
reg [21:0] prescaler;
wire carryout;
reg [21:0] prescalerneo;
wire carryoutneo;
reg [3:0] flagwin;
reg [2:0] arrow0;
reg [2:0] arrow1;
reg [2:0] stck0_0_x;
reg [2:0] stck0_1_x;
reg [2:0] stck0_2_x;
reg [2:0] stck0_3_x;
reg [2:0] stck0_4_x;
reg [2:0] stck1_0_x;
reg [2:0] stck1_1_x;
reg [2:0] stck1_2_x;
reg [2:0] stck1_3_x;
reg [2:0] stck1_4_x;
reg [3:0] stck0_0_y;
reg [3:0] stck0_1_y;
reg [3:0] stck0_2_y;
reg [3:0] stck0_3_y;
reg [3:0] stck0_4_y;
reg [3:0] stck1_0_y;
reg [3:0] stck1_1_y;
reg [3:0] stck1_2_y;
reg [3:0] stck1_3_y;
reg [3:0] stck1_4_y;
reg [3:0] change;
reg [2:0] x;
reg [3:0] y;
reg [2:0] color;
reg[3:0] status, status_next;
parameter  IDLE = 4'b0000;
parameter  TURN0R = 4'b0001;
parameter  TURN0L = 4'b0010;
parameter  TURN1R = 4'b0011;
parameter  TURN1L = 4'b0111;
parameter  INIT = 4'b0100;
parameter  WIN0 = 4'b0101;
parameter  WIN1 = 4'b0110;



    // 25bit up counter with carry out at 'd3e+5
    always @ (posedge CLK or negedge RSTn) 
	 begin
        if(RSTn == 1'b0)
            prescaler <= 22'b0;
        else if(prescaler == 22'd3000)
            prescaler <= 22'b0;
        else
            prescaler <= prescaler + 22'b1;
    end
    assign    carryout = (prescaler == 22'd3000) ? 1'b1 : 1'b0;
	 assign    carryoutneo = (prescalerneo == 22'd15000) ? 1'b1 : 1'b0;

	 always @ (posedge CLK or negedge RSTn)
	 begin
		if (RSTn == 1'b0) 
			status <= INIT;
		else
			status <= status_next;
	 end 

	 always @ (posedge CLK)
	 case (status)
		INIT: 
			begin
			flagwin <= 0;
			stck0_4_x <= 0;
			stck0_4_y <= 0;
			stck0_3_x <= 0;
			stck0_3_y <= 1;
			stck0_2_x <= 0;
			stck0_2_y <= 2;	
			stck0_1_x <= 0;
			stck0_1_y <= 3;
			stck0_0_x <= 0;
			stck0_0_y <= 4;
			stck1_4_x <= 7;
			stck1_4_y <= 15;
			stck1_3_x <= 7;
			stck1_3_y <= 14;
			stck1_2_x <= 7;
			stck1_2_y <= 13;	
			stck1_1_x <= 7;
			stck1_1_y <= 12;
			stck1_0_x <= 7;
			stck1_0_y <= 11;
			arrow0 <= 0;
			arrow1 <= 2;
			status_next <= IDLE;
			end
		IDLE: 
			begin
			if (carryout == 1'b1) 
				begin
					if(RSTn == 1'b0)
						prescalerneo <= 22'b0;
					else if(prescalerneo == 22'd15000)
						prescalerneo <= 22'b0;
					else 
						prescalerneo <= prescalerneo + 22'b1;
						
					if ((stck0_0_x == stck1_1_x) && (stck0_0_y == stck1_1_y))
						status_next <= WIN1;
					else if ((stck0_0_x == stck1_2_x) && (stck0_0_y == stck1_2_y))
						status_next <= WIN1;
					else if ((stck0_0_x == stck1_3_x) && (stck0_0_y == stck1_3_y))
						status_next <= WIN1;
					else if ((stck0_0_x == stck1_4_x) && (stck0_0_y == stck1_4_y))
						status_next <= WIN1;
						
					else if ((stck1_0_x == stck0_1_x) && (stck1_0_y == stck0_1_y))
						status_next <= WIN0;
					else if ((stck1_0_x == stck0_2_x) && (stck1_0_y == stck0_2_y))
						status_next<= WIN0;
					else if ((stck1_0_x == stck0_3_x) && (stck1_0_y == stck0_3_y))
						status_next<= WIN0;
					else if ((stck1_0_x == stck0_4_x) && (stck1_0_y == stck0_4_y))
						status_next<= WIN0;
					else if	(PUSH0 == 1'b1)
						status_next <= TURN0R;
					else if (PUSH1 == 1'b1)
						status_next <= TURN0L;
					else if (PUSH2 == 1'b1)
						status_next <= TURN1R;
					else if (PUSH3 == 1'b1)
						status_next <= TURN1L;
				   else 
						begin
						if (carryoutneo == 1)
						begin
						if (arrow0 == 0)
							begin
								if (stck0_0_y != 15)
							stck0_0_y <= stck0_0_y + 1;
							end
						else if (arrow0 == 1) 
							begin
							if (stck0_0_x != 0)
							stck0_0_x <= stck0_0_x - 1;
							end
						else if (arrow0 == 2) 
							begin
							if (stck0_0_y != 0)
							stck0_0_y <= stck0_0_y - 1;
							end
						else if (arrow0 == 3)
							begin
							if (stck0_0_x != 15)
							stck0_0_x <= stck0_0_x + 1;
							end	
						
						if (arrow1 == 0) 
							begin
							if (stck1_0_y != 15)
							stck1_0_y <= stck1_0_y + 1;
							end
						else if (arrow1 == 1) 
							begin
							if (stck1_0_x != 0)
							stck1_0_x <= stck1_0_x - 1;
							end
						else if (arrow1 == 2) 
							begin
							if (stck1_0_y != 0)
							stck1_0_y <= stck1_0_y - 1;
							end
						else if (arrow1 == 3)
							begin
							if (stck1_0_x != 15)
							stck1_0_x <= stck1_0_x + 1;
							end
						
						stck0_1_x <= stck0_0_x;
						stck0_2_x <= stck0_1_x;
						stck0_3_x <= stck0_2_x;
						stck0_4_x <= stck0_3_x;
						stck0_1_y <= stck0_0_y;
						stck0_2_y <= stck0_1_y;
						stck0_3_y <= stck0_2_y;
						stck0_4_y <= stck0_3_y;
						
						stck1_1_x <= stck1_0_x;
						stck1_2_x <= stck1_1_x;
						stck1_3_x <= stck1_2_x;
						stck1_4_x <= stck1_3_x;
						stck1_1_y <= stck1_0_y;
						stck1_2_y <= stck1_1_y;
						stck1_3_y <= stck1_2_y;
						stck1_4_y <= stck1_3_y;
						end
						status_next <= IDLE;
						end
				end
			end
		TURN0R: 
		begin
		   if (carryout) 
			begin 
				begin 
				if (arrow0 == 3)
					arrow0 <= 0;
				else 
					arrow0 <= arrow0 + 1;
				end
				status_next <= IDLE;
			end
		end
		TURN0L: 
		begin
		   if (carryout) 
			begin 
				begin 
				if (arrow0 == 0)
					arrow0 <= 3;
				else 
					arrow0 <= arrow0 - 1;
				status_next <= IDLE;
				end
			end
		end
		TURN1R: 
		begin
		   if (carryout) 
			begin 
				begin 
				if (arrow1 == 3)
					arrow1 <= 0;
				else 
					arrow1 <= arrow1 + 1;
				end
				status_next <= IDLE;
			end
		end
		TURN1L: 
		begin
		   if (carryout) 
			begin 
				begin 
				if (arrow1 == 0)
					arrow1 <= 3;
				else 
					arrow1 <= arrow1 - 1;
				end
				status_next <= IDLE;
			end
		end
		WIN0:
		begin
			flagwin <= 10;
			status_next = WIN0;
		end
		WIN1:
		begin	
			flagwin <= 11;
			status_next = WIN1;
		end
		default:
			status_next <= IDLE;
		endcase

		always @ (posedge CLK) 
		begin
		if(carryout) 
			begin
			if (flagwin == 10)   
				begin
				x <= 0;
				y <= 0;
				color <= 3'b001;
				end
			else if (flagwin == 11)
				begin
				x <= 7;
				y <= 15;
				color <= 3'b010;
				end
			else
				begin
				if (change == 0) 
					begin
					x <= stck0_0_x;
					y <= stck0_0_y;
					change <= 1;
					color <= 3'b111;
					end
				else if (change == 1) 
					begin
					x <= stck0_1_x;
					y <= stck0_1_y;
					change <= 2;
					color <= 3'b001;
					end
				else if (change == 2) 
					begin
					x <= stck0_2_x;
					y <= stck0_2_y;
					change <= 3;
					color <= 3'b001;
					end
				else if (change == 3) 
					begin
					x <= stck0_3_x;
					y <= stck0_3_y;
					change <= 4;
					color <= 3'b001;
					end
				else if (change == 4) 
					begin
					x <= stck0_4_x;
					y <= stck0_4_y;
					change <= 5;
					color <= 3'b001;
					end
				else if (change == 5) 
					begin
					x <= stck1_0_x;
					y <= stck1_0_y;
					change <= 6;
					color <= 3'b111;
					end
				else if (change == 6) 
					begin
					x <= stck1_1_x;
					y <= stck1_1_y;
					change <= 7;
					color <= 3'b010;
					end
				else if (change == 7) 
					begin
					x <= stck1_2_x;
					y <= stck1_2_y;
					change <= 8;
					color <= 3'b010;
					end
				else if (change == 8) 
					begin
					x <= stck1_3_x;
					y <= stck1_3_y;
					change <= 9;
					color <= 3'b010;
					end
				else if (change == 9) 
					begin
					x <= stck1_4_x;
					y <= stck1_4_y;
					change <= 0;
					color <= 3'b010;
					end
				end	
			end
		end
		
		assign led = {color, y,x};

BIN8to7SEG3 binto7seg3 (CLK, RSTn, counter, SEG7OUT, SEG7COM);

endmodule