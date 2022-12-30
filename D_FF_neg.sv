// Provided module from lab 1. 
module D_FF_neg (q, d, reset, clk);   output reg q; 
  input d, reset, clk; 
 
  always_ff @(negedge clk) 
  if (reset) 
    q <= 0;  // On reset, set to 0 
  else 
    q <= d; // Otherwise out = d 
endmodule 