//���X�g5.5:  a09_bintobcd3.v - �A�b�v�J�E���^�o�͂� BIN8toBCD3 ���W���[���ɓ��͂��ă_�C�i�~�b�N�\��
// 8bit bin counter - display to 3x7seg display

module a09_bintobcd3(CLK,RSTn,PUSH0,PUSH1,SEG7OUT,SEG7COM,led);
input CLK;
input RSTn;
input PUSH0;
input PUSH1;
output [6:0] SEG7OUT;
output [3:0] SEG7COM;
output [9:0] led;

//reg [1:0] regpush; 
reg [7:0] counter;
reg [21:0] prescaler;
wire carryout;
reg	flag;
reg [2:0] change;
reg [7:0] nbr0;
reg [7:0] nbr1;
reg [2:0] x;
reg [7:0] x0;
reg [7:0] x1;
reg [3:0] y;
reg [7:0] y0;
reg [7:0] y1;
reg [2:0] color;
reg[3:0] status, status_next;
parameter  IDLE = 4'b0000;
parameter  SEG7 = 4'b0001;
parameter  ADD0 = 4'b0010;
parameter  ADD1 = 4'b0011;
parameter  INIT = 4'b0100;
parameter  WIN0 = 4'b0101;
parameter  WIN1 = 4'b0110;



    // 25bit up counter with carry out at 'd3e+5
    always @ (posedge CLK or negedge RSTn) 
	 begin
        if(RSTn == 1'b0)
            prescaler <= 22'b0;
        else if(prescaler == 22'd30000)
            prescaler <= 22'b0;
        else
            prescaler <= prescaler + 22'b1;
    end
    assign    carryout = (prescaler == 22'd30000) ? 1'b1 : 1'b0;

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
			nbr0 <= 0;
			nbr1 <= 0;
			status_next <= IDLE;
			end
		IDLE: 
			begin
			if (carryout == 1'b1) 
				begin
					if (PUSH0 == 1'b1)
						status_next <= SEG7;
					else if (counter == 8'b00000100) 
						begin
						counter <= 1;
						status_next <= IDLE;
						end
					else 
						begin
						counter <= counter + 1;
						status_next <= IDLE; 
						end
			end
		end
		SEG7: 
		begin
			if (carryout == 1'b1) 
				begin
				if ((PUSH1 == 1) && (flag == 0))
				status_next = ADD0;
				else if ((PUSH1 == 1) && (	flag == 1))
				status_next = ADD1;
				end
		end
		ADD0: 
		begin
		   if (carryout) 
			begin 
				if ( nbr0 + counter >= 7'b1111111) 
					begin
					status_next = WIN0;
					end
				else 
					begin
					if (((nbr0+counter) == 7'b1011001) || ((nbr0+counter) == 7'b1001010))
						nbr0 <= nbr0 + counter - 3'b111;
					else if((nbr0 + counter) == 7'b0110000 || (nbr0+counter) == 7'b0100011)
						nbr0 <= nbr0 + counter - 3'b111;
					else
						begin
							nbr0 <= nbr0 + counter;
							flag <= 1;
							status_next = IDLE;
						end
					end
			end
		end
		ADD1: 
		begin
		   if(carryout) 
				begin
				if ( nbr1 + counter >= 7'b1111111) 
					status_next = WIN1;
				else 
					begin
					if ((nbr1+counter) == 7'b1011001 || (nbr1+counter) == 7'b1001010)
						nbr1 <= nbr1 + counter - 3'b111;
					else if((nbr1 + counter) == 7'b0110000 || (nbr1+counter) == 7'b0100011)
						nbr1 <= nbr1 + counter - 3'b111;
					else
						begin
							nbr1 <= nbr1 + counter;
							flag<= 0;
							status_next = IDLE;
						end
					end
				end
		end
		WIN0:
		begin
			nbr0 <= nbr0+1;
			status_next = WIN0;
		end
		WIN1:
		begin	
			nbr1 <= nbr1+1;
			status_next = WIN1;
		end
		default:
			status_next <= IDLE;
		endcase

		always @ (posedge CLK) 
		begin
			if(carryout) 
				begin
				if (nbr0[4] == 0)
					begin 
					x0 = nbr0[6:4];
					y0 = nbr0[3:0];
					end
				else 
					begin
					x0 = nbr0[6:4];
					y0 = 8'b00001111 - nbr0[3:0];
					end
				if (nbr1[4] == 0) 
					begin 
					x1 = nbr1[6:4];
					y1 = nbr1[3:0];
					end
				else 
					begin
					x1 = nbr1[6:4];
					y1 = 8'b0001111 - nbr1[3:0];
					end
			
			
			if (	change == 3'b000) 
				begin
				x <= x0[2:0];
				y <= y0[3:0];
				change <= 1;
				color <= 3'b001;
				end
			else if (change == 3'b001)
				begin
				x <= x1[2:0];
				y <= y1[3:0];
				change <= 2;
				color <= 3'b010;
				end
			else if (change == 3'b010)
				begin
				x <= 3'b010;
				y <= 4'b0011;
				change <= 3;
				color <= 3'b100;
				end
			else if (change == 3'b011)
				begin
				x <= 3'b011;
				y <= 4'b1111;
				change <= 4;
				color <= 3'b100;
				end
			else if (change == 3'b100)
				begin
				x <= 3'b100;
				y <= 4'b1010;
				change <= 5;
				color <= 3'b100;
				end
			else if (change == 3'b101)
				begin
				x <= 3'b101;
				y <= 4'b0110;
				change <= 0;
				color <= 3'b100;
				end
			end
		end
		
		assign led = {color, y,x};

BIN8to7SEG3 binto7seg3 (CLK, RSTn, counter, SEG7OUT, SEG7COM);

endmodule