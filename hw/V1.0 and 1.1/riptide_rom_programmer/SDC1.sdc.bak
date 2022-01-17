create_clock -period 20.0 [get_ports clk]
derive_pll_clocks
derive_clock_uncertainty
#set_input_delay -clock PLL_inst|altpll_component|auto_generated|pll1|clk[0] -max 0.2 [all_inputs]	
#set_input_delay -clock PLL_inst|altpll_component|auto_generated|pll1|clk[0] -min 0.1 [all_inputs]	
#set_output_delay -clock PLL_inst|altpll_component|auto_generated|pll1|clk[0] -max 0.2 [all_outputs]	
#set_output_delay -clock PLL_inst|altpll_component|auto_generated|pll1|clk[0] -min 0.1 [all_outputs]

create_generated_clock -source PLL_inst|altpll_component|auto_generated|pll1|clk[2] -name mem_clk [get_ports sdram_clk]

set_false_path -from * -to [get_ports {LED* TXD ps2_clk_q ps2_data_q R G B HSYNC VSYNC seg_sel* hex_out*}]
set_false_path -from [get_ports {reset button* RXD ps2_clk_d ps2_data_d}] -to *

# board delay + Tco(max) of external devices (memory)
#set_input_delay -clock PLL_inst|altpll_component|auto_generated|pll1|clk[2] -max 6.0 [get_ports {sdram_dq[*]}]
set_input_delay -clock mem_clk -max 6.0 [get_ports {sdram_dq[*]}]

# board delay + Tco(min) of external devices
#set_input_delay -clock PLL_inst|altpll_component|auto_generated|pll1|clk[2] -min 2.5 [get_ports {sdram_dq[*]}]
set_input_delay -clock mem_clk -min 2.5 [get_ports {sdram_dq[*]}]

# board delay + Tsu of external devices
#set_output_delay -clock PLL_inst|altpll_component|auto_generated|pll1|clk[2] -max 1.5 [get_ports {sdram_cke sdram_cs_n sdram_wre_n sdram_cas_n sdram_ras_n sdram_a* sdram_ba* sdram_dqm* sdram_dq*}]
set_output_delay -clock mem_clk -max 1.5 [get_ports {sdram_cke sdram_cs_n sdram_wre_n sdram_cas_n sdram_ras_n sdram_a* sdram_ba* sdram_dqm* sdram_dq*}]

# board delay - Th of external devices
#set_output_delay -clock PLL_inst|altpll_component|auto_generated|pll1|clk[2] -min -0.8 [get_ports {sdram_cke sdram_cs_n sdram_wre_n sdram_cas_n sdram_ras_n sdram_a* sdram_ba* sdram_dqm* sdram_dq*}]
set_output_delay -clock mem_clk -min -0.8 [get_ports {sdram_cke sdram_cs_n sdram_wre_n sdram_cas_n sdram_ras_n sdram_a* sdram_ba* sdram_dqm* sdram_dq*}]
