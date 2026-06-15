//------------------------------------------------------//
//- Digital IC Design 2024                              //
//-                                                     //
//- Final Project: FP_MUL                               //
//------------------------------------------------------//
`timescale 1ns/1ps

module FP_MUL(CLK, RESET, ENABLE, DATA_IN, DATA_OUT, READY);


// I/O Ports
input         CLK;          //clock signal
input         RESET;        //sync. RESET=1
input         ENABLE;       //input data sequence when ENABLE =1
input   [7:0] DATA_IN;      //input data sequence
output  reg [7:0] DATA_OUT; //ouput data sequence
output  reg       READY;    //output data is READY when READY=1

// announcement for cylce counter
reg [6:0]  cnt;

// announcement for original data
reg [63:0] data_a;
reg [63:0] data_b;
reg [63:0] data_z;

// announcement for input data
reg [7:0]  in_data [0:7];
reg [2:0]  index;
reg [3:0]  i;
reg        read;

// announcement for sign data & exponent data 
reg [10:0] exp;
reg        sign_bit;

// announcement for fraction data 
reg [105:0] temp_fp;
reg [104:0] temp_1;
reg [104:0] temp_2;
reg [104:0] temp_3;
reg [104:0] temp_4;

// announcement for special case 
reg [2:0]   special; 

// normal = 0, +0 = 1, -0 = 2, +infinity = 3, -infinity = 4, +NaN = 5, -Nan = 6
parameter   NORMAL = 3'b0, ZERO = 3'b001, MZERO = 3'b010, INFINITY = 3'b011, MINFINITY = 3'b100, NAN_A = 3'b101, NAN_B = 3'b110, MNAN = 3'b111; 

// cnt
always @ (posedge CLK) begin 
        if (RESET) cnt <= 7'd0;
        else if (ENABLE && !read) cnt <= 7'd0; // when input a new pattern, reset the cnt
        else cnt <= cnt + 7'd1;
end

// read
always @ (posedge CLK) begin 
        if (RESET) read <= 1'b0;
        else if (ENABLE) read <= 1'b1; // get high when the read input data
        else read <= 1'b0;
end

// read input data 
always @ (posedge CLK) begin 
        if (RESET) begin 
                for (i=0;i < 8;i=i+1) begin
                        in_data[i] <= 8'b0;
                end 
        end
        else if (ENABLE) in_data[index] <= DATA_IN;
        else begin end
end

// index
always @ (posedge CLK) begin 
        if (RESET) index <= 3'd0;
        else if (!ENABLE) index <= 3'd0;
        else index <= index + 3'd1; 
end

// data_a 
always @ (posedge CLK) begin 
        if (RESET) data_a <= 64'b0;
        else if (cnt == 7'd7) data_a <= {in_data[7], in_data[6], in_data[5], in_data[4], in_data[3], in_data[2], in_data[1], in_data[0]};
        else if (cnt == 7'd45) data_a <= 64'b0;
        else begin end
end

// data_b
always @ (posedge CLK) begin 
        if (RESET) data_b <= 64'b0;
        else if (cnt == 7'd15) data_b <= {in_data[7], in_data[6], in_data[5], in_data[4], in_data[3], in_data[2], in_data[1], in_data[0]};
        else if (cnt == 7'd45) data_b <= 64'b0;
        else begin end
end

// sign_bit
always @ (posedge CLK) begin 
        if (RESET) sign_bit <= 1'b0;
        else if (data_a[63] == data_b[63]) sign_bit <= 1'b0; // data_a[63] xor data_b[63]
        else sign_bit <= 1'b1;
end


// exp 
always @ (posedge CLK) begin 
        if (RESET) exp <= 11'b0;
        else if (cnt == 7'd16) exp <= data_a[62:52] + data_b[62:52] + 11'b10000000001; // Ez = Ea + Eb - 1023
        else if (cnt == 7'd33 && temp_fp[105] == 1'b1) exp <= exp + 11'b00000000001;   // Ez + 1
        else if (cnt == 7'd45) exp <= 11'b0;
        else begin end
end

// pipeline mult for fraction data 

// temp_1
always @ (posedge CLK) begin 
        if (RESET) temp_1 <= 105'b0;
        else begin 
                case (cnt) 
                        16: begin
                                if (data_b[0] == 1'b1) temp_1 <= {1'b1,data_a[51:0]};
                                else temp_1 <= temp_1;
                        end
                        17: begin
                                if (data_b[4] == 1'b1) temp_1 <= temp_1 + {1'b1,data_a[51:0],4'b0};
                                else temp_1 <= temp_1;
                        end
                        18: begin
                                if (data_b[8] == 1'b1) temp_1 <= temp_1 + {1'b1,data_a[51:0],8'b0};
                                else temp_1 <= temp_1;
                        end
                        19: begin
                                if (data_b[12] == 1'b1) temp_1 <= temp_1 + {1'b1,data_a[51:0],12'b0};
                                else temp_1 <= temp_1;
                        end
                        20: begin
                                if (data_b[16] == 1'b1) temp_1 <= temp_1 + {1'b1,data_a[51:0],16'b0};
                                else temp_1 <= temp_1;
                        end
                        21: begin
                                if (data_b[20] == 1'b1) temp_1 <= temp_1 + {1'b1,data_a[51:0],20'b0};
                                else temp_1 <= temp_1;
                        end
                        22: begin
                                if (data_b[24] == 1'b1) temp_1 <= temp_1 + {1'b1,data_a[51:0],24'b0};
                                else temp_1 <= temp_1;
                        end
                        23: begin
                                if (data_b[28] == 1'b1) temp_1 <= temp_1 + {1'b1,data_a[51:0],28'b0};
                                else temp_1 <= temp_1;
                        end
                        24: begin
                                if (data_b[32] == 1'b1) temp_1 <= temp_1 + {1'b1,data_a[51:0],32'b0};
                                else temp_1 <= temp_1;
                        end
                        25: begin
                                if (data_b[36] == 1'b1) temp_1 <= temp_1 + {1'b1,data_a[51:0],36'b0};
                                else temp_1 <= temp_1;
                        end
                        26: begin
                                if (data_b[40] == 1'b1) temp_1 <= temp_1 + {1'b1,data_a[51:0],40'b0};
                                else temp_1 <= temp_1;
                        end
                        27: begin
                                if (data_b[44] == 1'b1) temp_1 <= temp_1 + {1'b1,data_a[51:0],44'b0};
                                else temp_1 <= temp_1;
                        end
                        28: begin
                                if (data_b[48] == 1'b1) temp_1 <= temp_1 + {1'b1,data_a[51:0],48'b0};
                                else temp_1 <= temp_1;
                        end
                        45: temp_1 <= 105'b0;
                        default temp_1 <= temp_1;
                endcase
        end
end 

// temp_2
always @ (posedge CLK) begin 
        if (RESET) temp_2 <= 105'b0;
        else begin 
                case (cnt) 
                        16: begin
                                if (data_b[1] == 1'b1) temp_2 <= {1'b1,data_a[51:0],1'b0};
                                else temp_2 <= temp_2;
                        end
                        17: begin
                                if (data_b[5] == 1'b1) temp_2 <= temp_2 + {1'b1,data_a[51:0],5'b0};
                                else temp_2 <= temp_2;
                        end
                        18: begin
                                if (data_b[9] == 1'b1) temp_2 <= temp_2 + {1'b1,data_a[51:0],9'b0};
                                else temp_2 <= temp_2;
                        end
                        19: begin
                                if (data_b[13] == 1'b1) temp_2 <= temp_2 + {1'b1,data_a[51:0],13'b0};
                                else temp_2 <= temp_2;
                        end
                        20: begin
                                if (data_b[17] == 1'b1) temp_2 <= temp_2 + {1'b1,data_a[51:0],17'b0};
                                else temp_2 <= temp_2;
                        end
                        21: begin
                                if (data_b[21] == 1'b1) temp_2 <= temp_2 + {1'b1,data_a[51:0],21'b0};
                                else temp_2 <= temp_2;
                        end
                        22: begin
                                if (data_b[25] == 1'b1) temp_2 <= temp_2 + {1'b1,data_a[51:0],25'b0};
                                else temp_2 <= temp_2;
                        end
                        23: begin
                                if (data_b[29] == 1'b1) temp_2 <= temp_2 + {1'b1,data_a[51:0],29'b0};
                                else temp_2 <= temp_2;
                        end
                        24: begin
                                if (data_b[33] == 1'b1) temp_2 <= temp_2 + {1'b1,data_a[51:0],33'b0};
                                else temp_2 <= temp_2;
                        end
                        25: begin
                                if (data_b[37] == 1'b1) temp_2 <= temp_2 + {1'b1,data_a[51:0],37'b0};
                                else temp_2 <= temp_2;
                        end
                        26: begin
                                if (data_b[41] == 1'b1) temp_2 <= temp_2 + {1'b1,data_a[51:0],41'b0};
                                else temp_2 <= temp_2;
                        end
                        27: begin
                                if (data_b[45] == 1'b1) temp_2 <= temp_2 + {1'b1,data_a[51:0],45'b0};
                                else temp_2 <= temp_2;
                        end
                        28: begin
                                if (data_b[49] == 1'b1) temp_2 <= temp_2 + {1'b1,data_a[51:0],49'b0};
                                else temp_2 <= temp_2;
                        end
                        45: temp_2 <= 105'b0;
                        default temp_2 <= temp_2;
                endcase
        end
end 

// temp_3
always @ (posedge CLK) begin 
        if (RESET) temp_3 <= 105'b0;
        else begin 
                case (cnt) 
                        16: begin
                                if (data_b[2] == 1'b1) temp_3 <= {1'b1,data_a[51:0],2'b0};
                                else temp_3 <= temp_3;
                        end
                        17: begin
                                if (data_b[6] == 1'b1) temp_3 <= temp_3 + {1'b1,data_a[51:0],6'b0};
                                else temp_3 <= temp_3;
                        end
                        18: begin
                                if (data_b[10] == 1'b1) temp_3 <= temp_3 + {1'b1,data_a[51:0],10'b0};
                                else temp_3 <= temp_3;
                        end
                        19: begin
                                if (data_b[14] == 1'b1) temp_3 <= temp_3 + {1'b1,data_a[51:0],14'b0};
                                else temp_3 <= temp_3;
                        end
                        20: begin
                                if (data_b[18] == 1'b1) temp_3 <= temp_3 + {1'b1,data_a[51:0],18'b0};
                                else temp_3 <= temp_3;
                        end
                        21: begin
                                if (data_b[22] == 1'b1) temp_3 <= temp_3 + {1'b1,data_a[51:0],22'b0};
                                else temp_3 <= temp_3;
                        end
                        22: begin
                                if (data_b[26] == 1'b1) temp_3 <= temp_3 + {1'b1,data_a[51:0],26'b0};
                                else temp_3 <= temp_3;
                        end
                        23: begin
                                if (data_b[30] == 1'b1) temp_3 <= temp_3 + {1'b1,data_a[51:0],30'b0};
                                else temp_3 <= temp_3;
                        end
                        24: begin
                                if (data_b[34] == 1'b1) temp_3 <= temp_3 + {1'b1,data_a[51:0],34'b0};
                                else temp_3 <= temp_3;
                        end
                        25: begin
                                if (data_b[38] == 1'b1) temp_3 <= temp_3 + {1'b1,data_a[51:0],38'b0};
                                else temp_3 <= temp_3;
                        end
                        26: begin
                                if (data_b[42] == 1'b1) temp_3 <= temp_3 + {1'b1,data_a[51:0],42'b0};
                                else temp_3 <= temp_3;
                        end
                        27: begin
                                if (data_b[46] == 1'b1) temp_3 <= temp_3 + {1'b1,data_a[51:0],46'b0};
                                else temp_3 <= temp_3;
                        end
                        28: begin
                                if (data_b[50] == 1'b1) temp_3 <= temp_3 + {1'b1,data_a[51:0],50'b0};
                                else temp_3 <= temp_3;
                        end
                        45: temp_3 <= 105'b0;
                        default temp_3 <= temp_3;
                endcase
        end
end 

// temp_4
always @ (posedge CLK) begin 
        if (RESET) temp_4 <= 105'b0;
        else begin 
                case (cnt) 
                        16: begin
                                if (data_b[3] == 1'b1) temp_4 <= {1'b1,data_a[51:0],3'b0};
                                else temp_4 <= temp_4;
                        end
                        17: begin
                                if (data_b[7] == 1'b1) temp_4 <= temp_4 + {1'b1,data_a[51:0],7'b0};
                                else temp_4 <= temp_4;
                        end
                        18: begin
                                if (data_b[11] == 1'b1) temp_4 <= temp_4 + {1'b1,data_a[51:0],11'b0};
                                else temp_4 <= temp_4;
                        end
                        19: begin
                                if (data_b[15] == 1'b1) temp_4 <= temp_4 + {1'b1,data_a[51:0],15'b0};
                                else temp_4 <= temp_4;
                        end
                        20: begin
                                if (data_b[19] == 1'b1) temp_4 <= temp_4 + {1'b1,data_a[51:0],19'b0};
                                else temp_4 <= temp_4;
                        end
                        21: begin
                                if (data_b[23] == 1'b1) temp_4 <= temp_4 + {1'b1,data_a[51:0],23'b0};
                                else temp_4 <= temp_4;
                        end
                        22: begin
                                if (data_b[27] == 1'b1) temp_4 <= temp_4 + {1'b1,data_a[51:0],27'b0};
                                else temp_4 <= temp_4;
                        end
                        23: begin
                                if (data_b[31] == 1'b1) temp_4 <= temp_4 + {1'b1,data_a[51:0],31'b0};
                                else temp_4 <= temp_4;
                        end
                        24: begin
                                if (data_b[35] == 1'b1) temp_4 <= temp_4 + {1'b1,data_a[51:0],35'b0};
                                else temp_4 <= temp_4;
                        end
                        25: begin
                                if (data_b[39] == 1'b1) temp_4 <= temp_4 + {1'b1,data_a[51:0],39'b0};
                                else temp_4 <= temp_4;
                        end
                        26: begin
                                if (data_b[43] == 1'b1) temp_4 <= temp_4 + {1'b1,data_a[51:0],43'b0};
                                else temp_4 <= temp_4;
                        end
                        27: begin
                                if (data_b[47] == 1'b1) temp_4 <= temp_4 + {1'b1,data_a[51:0],47'b0};
                                else temp_4 <= temp_4;
                        end
                        28: begin
                                if (data_b[51] == 1'b1) temp_4 <= temp_4 + {1'b1,data_a[51:0],51'b0};
                                else temp_4 <= temp_4;
                        end
                        45: temp_4 <= 105'b0;
                        default temp_4 <= temp_4;
                endcase
        end
end 

// temp_fp
always @ (posedge CLK) begin 
        if (RESET) temp_fp <= 106'b0;
        else begin 
                case (cnt) 
                        29: temp_fp <= temp_1 + temp_2;
                        30: temp_fp <= temp_fp + temp_3;
                        31: temp_fp <= temp_fp + temp_4;
                        32: temp_fp <= temp_fp + {1'b1,data_a[51:0],52'b0}; // plus the last row
                        33: begin
                                if (temp_fp[105] == 1'b0) temp_fp <= temp_fp << 1; // shift right when the last bit of temp_fp is zero
                                else temp_fp <= temp_fp; 
                        end
                        34: temp_fp[104:53] <= temp_fp[104:53] + temp_fp[52]; // round to nearest
                        45: temp_fp <= 106'b0;
                        default temp_fp <= temp_fp;
                endcase 
        end
end

// special
always @ (posedge CLK) begin 
        if (RESET) special <= NORMAL;
        else if ((data_a[63:52] == {1'b0,11'b11111111111} && data_a[51:0] != 52'b0) || (data_a[63:52] == {1'b1,11'b11111111111} && data_a[51:0] != 52'b0)) special <= NAN_A; // special case for NaN_A
        else if ((data_b[63:52] == {1'b0,11'b11111111111} && data_b[51:0] != 52'b0) || (data_b[63:52] == {1'b1,11'b11111111111} && data_b[51:0] != 52'b0)) special <= NAN_B; // special case for NaN_B
        else if (data_a == 64'b0 || data_b == 64'b0) begin 
                if (data_a == {1'b0,11'b11111111111,52'b0} || data_b == {1'b0,11'b11111111111,52'b0}) special <= MNAN;       // special case for +0 * +infinity is MNaN
                else if (data_a == {1'b1,11'b11111111111,52'b0} || data_b == {1'b1,11'b11111111111,52'b0}) special <= MNAN;  // special case for +0 * -infinity is MNaN
                else special <= ZERO;                                                                                        // special case for +0
        end
        else if (data_a == {1'b1,63'b0} || data_b == {1'b1,63'b0}) begin 
                if (data_a == {1'b0,11'b11111111111,52'b0} || data_b == {1'b0,11'b11111111111,52'b0}) special <= MNAN;       // special case for -0 * +infinity is MNaN
                else if (data_a == {1'b1,11'b11111111111,52'b0} || data_b == {1'b1,11'b11111111111,52'b0}) special <= MNAN;  // special case for -0 * -infinity is MNaN
                else special <= MZERO;                                                                                       // special case for -0
        end
        else if (data_a == {1'b0,11'b11111111111,52'b0} || data_b == {1'b0,11'b11111111111,52'b0}) special <= INFINITY;      // special case for +infinity
        else if (data_a == {1'b1,11'b11111111111,52'b0} || data_b == {1'b1,11'b11111111111,52'b0}) special <= MINFINITY;     // special case for -infinity
        else if (cnt == 7'd45) special <= NORMAL;
        else special <= NORMAL;                                                                                              // normal  case
end

// data_z 
always @ (posedge CLK) begin 
        if (RESET) data_z <= 64'b0;
        else if (cnt == 7'd36 && special == NAN_A) data_z <= {data_a[63],11'b11111111111,1'b1,data_a[50:0]};                 // special case for NaN_A
        else if (cnt == 7'd36 && special == NAN_B) data_z <= {data_b[63],11'b11111111111,1'b1,data_b[50:0]};                 // special case for NaN_B
        else if (cnt == 7'd36 && special == MNAN) data_z <= {1'b1,11'b11111111111,1'b1,51'b0};                               // special case for MNaN
        else if (cnt == 7'd36 && (special == ZERO || special == MZERO)) data_z <= {sign_bit,63'b0};                          // special case for +0 or -0
        else if (cnt == 7'd36 && (special == INFINITY || special == MINFINITY)) data_z <= {sign_bit,11'b11111111111,52'b0}; // special case for +infinity or -infinity
        else if (cnt == 7'd36 && special == NORMAL) data_z <= {sign_bit,exp,temp_fp[104:53]};                                // normal  case 
        else if (cnt == 7'd45) data_z <= 64'b0;                                                                             
        else begin end
end

// READY
always @ (posedge CLK) begin 
        if (RESET) READY <= 1'b0;
        else if (cnt > 7'd36 && cnt < 7'd45) READY <= 1'b1;
        else READY <= 1'b0; 
end

// DATA_OUT
always @ (posedge CLK) begin 
        if (RESET) DATA_OUT <= 8'b0;
        else begin 
                case (cnt)
                        37: DATA_OUT <= data_z[7:0];
                        38: DATA_OUT <= data_z[15:8];
                        39: DATA_OUT <= data_z[23:16];
                        40: DATA_OUT <= data_z[31:24];
                        41: DATA_OUT <= data_z[39:32];
                        42: DATA_OUT <= data_z[47:40];
                        43: DATA_OUT <= data_z[55:48];
                        44: DATA_OUT <= data_z[63:56];
                        default DATA_OUT <= 8'b0;
                endcase 
        end
end

endmodule
