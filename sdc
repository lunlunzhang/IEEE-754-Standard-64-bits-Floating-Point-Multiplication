###################################################################
## Set Design Constraints                                         #
###################################################################
set CLK_PERIOD         0.5
set CLK_RISING_EDGE    0
set CLK_FALLING_EDGE   [expr $CLK_PERIOD/2.0]
set INPUT_DELAY        [expr $CLK_PERIOD/2.0]
set OUTPUT_DELAY       [expr $CLK_PERIOD/2.0]  
set PORT_LOADING       0.1

## Clock Constraints ##
create_clock CLK -period $CLK_PERIOD -waveform "$CLK_RISING_EDGE $CLK_FALLING_EDGE"

## Set I/O Timing ##
set_input_delay $INPUT_DELAY -clock CLK [all_inputs -no_clocks]
set_output_delay $OUTPUT_DELAY -clock CLK [all_outputs]

## Set Environment ##
set_load $PORT_LOADING [all_outputs]
