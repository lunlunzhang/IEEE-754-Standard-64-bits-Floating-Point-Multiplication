//------------------------------------------------------//
//- Digital IC Design 2024                              //
//-                                                     //
//- Final Project: FP_MUL                               //
//------------------------------------------------------//
`timescale 1ns/1ps

`include "FP_MUL_syn.v"

module TEST;

parameter CYCLE=0.4;
parameter SIM_CYCLE=200;
parameter SIM_CYCLE_SP= 49;

reg         CLK, RESET;
reg         ENABLE;
reg   [7:0] DATA_IN;
wire  [7:0] DATA_OUT;
wire        READY;

reg  [63:0] A, B; //FP input
reg  [63:0] Z; //FP_MUL output
reg  [63:0] C; //Expect FP_MUL output
reg  [31:0] err_count;
reg  [31:0] sim_count;
reg  [63:0] special_case [0:6];
reg  [7:0]  pattern;
integer     i,sp_cnt;


FP_MUL FP_MUL(.CLK(CLK), .RESET(RESET), .ENABLE(ENABLE), 
              .DATA_IN(DATA_IN), 
              .DATA_OUT(DATA_OUT), .READY(READY)); 

always #(CYCLE/2.0) CLK=~CLK;

initial begin 
        special_case[0] = {1'b0,11'b10000000000,52'b1100_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000}; // normal case
        special_case[1] = {64'b0};                                                                                     // +0
        special_case[2] = {1'b1,63'b0};                                                                                // -0
        special_case[3] = {1'b0,11'b11111111111,52'b0};                                                                // +infinity
        special_case[4] = {1'b1,11'b11111111111,52'b0};                                                                // -infinity
        special_case[5] = {1'b0,11'b11111111111,52'b0000_1010_1010_1010_1010_1010_1010_1010_1010_1010_1010_1010_0000}; // +NaN
        special_case[6] = {1'b1,11'b11111111111,52'b0000_1010_1010_1010_1010_1010_1010_1010_1010_1010_1010_1010_1111}; // -NaN
end


initial begin 
   $sdf_annotate("FP_MUL.sdf", FP_MUL);
end


initial begin
$fsdbDumpfile("FP_MUL.fsdb");
$fsdbDumpvars;

CLK=0; RESET=0; 
ENABLE=0;
DATA_IN=0;
A=0; B=0; Z=0; C=0;
err_count=0;
pattern = 0;

@(negedge CLK) RESET=1;
@(negedge CLK) RESET=0;


for(i=0; i <= SIM_CYCLE; i=i+1) begin     
  //Give Pattern
  fp_patten;
  //Check Result 
  fp_check;
  pattern = pattern + 1;
  repeat (2) @(negedge CLK); //wait 2 clock cycles
end


for(sp_cnt=0; sp_cnt < SIM_CYCLE_SP; sp_cnt=sp_cnt+1) begin     
  //Give Pattern
  fp_patten_sp;
  //Check Result 
  fp_check;
  pattern = pattern + 1;
  repeat (2) @(negedge CLK); //wait 2 clock cycles
end


/*
// display special case
if (1)
begin
$display("a = %b",                                                            special_case[5]); 
$display("real_a = %f",                                           $bitstoreal(special_case[5])); 
$display("b = %b",                                                            special_case[6]);
$display("real_b = %f",                                           $bitstoreal(special_case[6])); 
$display("real_a * real_b = %f",   $bitstoreal(special_case[5]) * $bitstoreal(special_case[6])); 
$display("a * b = %b", $realtobits($bitstoreal(special_case[5]) * $bitstoreal(special_case[6]))); 
end
*/

if(err_count !=0) 
begin
  $display("\n\n**********************");
  $display("Simulation Fail       ");
  $display("**********************\n\n"); 
end else begin
  $display("\n\n**********************");
  $display("Simulation OK         ");
  $display("**********************\n\n"); 
end
#10 $finish;
end



//--TASK: FP Patern Generation ---------------------------------------------//
task fp_patten;

   real        A_real, B_real, C_real, D_real, E_real, F_real; 
    reg  [7:0] IN_A [0:7];
    reg  [7:0] IN_B [0:7];
integer        sim_time;
integer        i;

begin 

  ENABLE=1'b0;
  DATA_IN=0;
  
  //Generate Random Input
  sim_time=$time;
  C_real=$random(sim_time);
  D_real=$random(sim_time);
  E_real=$random(sim_time);
  F_real=$random(sim_time);

  A_real=C_real/D_real;
  B_real=E_real/F_real;

  A=$realtobits(A_real);
  B=$realtobits(B_real);
  
  {IN_A[7],IN_A[6],IN_A[5],IN_A[4],IN_A[3],IN_A[2],IN_A[1],IN_A[0]}=A;
  {IN_B[7],IN_B[6],IN_B[5],IN_B[4],IN_B[3],IN_B[2],IN_B[1],IN_B[0]}=B;

  //Input Data to FP_MUL
  for(i=0; i <= 7; i=i+1) begin
    @(negedge CLK) begin
        ENABLE=1'b1;
        DATA_IN = IN_A[i];
    end
  end

  for(i=0; i <= 7; i=i+1) begin
    @(negedge CLK) begin
        ENABLE=1'b1;
        DATA_IN = IN_B[i];
    end    
  end

  @(negedge CLK) ENABLE=1'b0;

end 
endtask 
//----------------------------------------------------------------//


//--TASK: FP Patern Special case Generation ---------------------------------------------//
task fp_patten_sp;

   real        A_real, B_real, C_real, D_real, E_real, F_real; 
    reg  [7:0] IN_A [0:7];
    reg  [7:0] IN_B [0:7];
integer        sim_time;
integer        i;

begin 

  ENABLE=1'b0;
  DATA_IN=0;
  
  //Generate Random Input
  sim_time=$time;
  C_real=$random(sim_time);
  D_real=$random(sim_time);
  E_real=$random(sim_time);
  F_real=$random(sim_time);

  A_real=C_real/D_real;
  B_real=E_real/F_real;

  A=special_case[sp_cnt/7];
  B=special_case[sp_cnt%7];
  
  case (sp_cnt/7)
        0: A = $realtobits(A_real);
        5: A[51:0] = $random(sim_time);
        6: A[51:0] = $random(sim_time);
  endcase
  
  case (sp_cnt%7)
        0: B = $realtobits(B_real);
        5: B[51:0] = $random(sim_time);
        6: B[51:0] = $random(sim_time);
  endcase
  
  {IN_A[7],IN_A[6],IN_A[5],IN_A[4],IN_A[3],IN_A[2],IN_A[1],IN_A[0]}=A;
  {IN_B[7],IN_B[6],IN_B[5],IN_B[4],IN_B[3],IN_B[2],IN_B[1],IN_B[0]}=B;

  //Input Data to FP_MUL
  for(i=0; i <= 7; i=i+1) begin
    @(negedge CLK) begin
        ENABLE=1'b1;
        DATA_IN = IN_A[i];
    end
  end

  for(i=0; i <= 7; i=i+1) begin
    @(negedge CLK) begin
        ENABLE=1'b1;
        DATA_IN = IN_B[i];
    end    
  end

  @(negedge CLK) ENABLE=1'b0;

end 
endtask 
//----------------------------------------------------------------//


//--TASK----------------------------------------------------------//
task fp_check;

   real        checkA, checkB, checkZ;
    reg  [7:0] IN_Z [0:7];
integer        i;

begin
  //Get Data from FP_MUL
  @(posedge READY) begin
     for(i=0; i <= 7; i=i+1) begin
        @(negedge CLK) IN_Z[i] = DATA_OUT;
     end
  end 

  //Check Results
  checkA = $bitstoreal(A);
  checkB = $bitstoreal(B);
  checkZ = checkA * checkB; //FP MUL
  C = $realtobits(checkZ);
  Z = {IN_Z[7],IN_Z[6],IN_Z[5],IN_Z[4],IN_Z[3],IN_Z[2],IN_Z[1],IN_Z[0]};

  //Display Debug Information
  fp_show; 

  if( C != Z) begin //If answer is wrong
      err_count = err_count + 1'b1;
      $display("Error at %t", $time);
  end

end
endtask
//----------------------------------------------------------------//

//--TASK----------------------------------------------------------//
task fp_show;
begin 
  $display("\n");
  $display("********************************************************************");
  $display("------------------- Pattern %d ------------------------------------", pattern);
  $display("(%+f) * (%+f) = %+f", $bitstoreal(A), $bitstoreal(B), $bitstoreal(Z));
  $display("A=%b_%b_%b", A[63], A[62:52], A[51:0]);
  $display("B=%b_%b_%b", B[63], B[62:52], B[51:0]);
  $display("------------------- Your Result ------------------------------------");
  $display("Z=%b_%b_%b", Z[63], Z[62:52], Z[51:0]);
  $display("------------------- Correct Result ---------------------------------");
  $display("C=%b_%b_%b", C[63], C[62:52], C[51:0]);
  $display("------------------- Error count %3d ---------------------------------", err_count);
  $display("********************************************************************");
end 
endtask 
//----------------------------------------------------------------//

endmodule
