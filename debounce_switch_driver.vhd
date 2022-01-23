-------------------------------------------------------------------------------
-- This module is used to debounce any switch or button coming into the FPGA.
-- Does not allow the output of the switch to change unless the switch is
-- steady long enough time.
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
 
entity debounce_switch_drv is
  port (
    i_Clk       : in  std_logic;
    i_reset_btn : in  std_logic;
    o_reset_btn : out std_logic
    );
end entity debounce_switch_drv;

--entity Debounce_Switch is
--  port (
--    i_Clk             : in  std_logic;
--    i_reset_btn       : in  std_logic;
--    i_speed_btn       : in  std_logic;
--    i_loop_mode_btn   : in  std_logic;
--    i_alarm_btn       : in  std_logic;
--    o_reset_btn       : out std_logic;
--    o_speed_btn       : out std_logic_vector(1 downto 0);
--    o_loop_mode_btn   : out std_logic;
--    i_alarm_btn       : out  std_logic;
--    );
--end entity Debounce_Switch;

architecture RTL of debounce_switch_drv is
 
  -- Set for 250,000 clock ticks of 25 MHz clock (10 ms)
  -- 1,000,000 ticks of 100MHz clock (10 ms) 
  constant c_DEBOUNCE_LIMIT : integer := 1000000;
 
  signal r_Count : integer range 0 to c_DEBOUNCE_LIMIT := 0;
  signal r_State : std_logic := '0';
  signal r_Switch_1 : std_logic := '0';
  signal r_LED_1    : std_logic := '0';
  signal o_Switch   : std_logic;
 
begin
 
  p_Debounce : process (i_Clk) is
  begin
    if rising_edge(i_Clk) then
 
      -- Switch input is different than internal switch value, so an input is
      -- changing.  Increase counter until it is stable for c_DEBOUNCE_LIMIT.
      if (i_reset_btn /= r_State and r_Count < c_DEBOUNCE_LIMIT) then
        r_Count <= r_Count + 1;
 
      -- End of counter reached, switch is stable, register it, reset counter
      elsif r_Count = c_DEBOUNCE_LIMIT then
        r_State <= i_reset_btn;
        r_Count <= 0;
 
      -- Switches are the same state, reset the counter
      else
        r_Count <= 0;
 
      end if;
    end if;
  end process p_Debounce;
 
  -- Assign internal register to output (debounced!)
  o_Switch <= r_State;
  
  -- Purpose: Toggle LED output when w_Switch_1 is released.
  p_Register : process (i_Clk) is
  begin
    if rising_edge(i_Clk) then
      r_Switch_1 <= o_Switch;         -- Creates a Register
 
      -- This conditional expression looks for a falling edge on i_Switch_1.
      -- Here, the current value (i_Switch_1) is low, but the previous value
      -- (r_Switch_1) is high.  This means that we found a falling edge.
      if o_Switch = '0' and r_Switch_1 = '1' then
        r_LED_1 <= not r_LED_1;         -- Toggle LED output
      end if;
    end if;
  end process p_Register;
 
  o_reset_btn <= r_LED_1;
 
end architecture RTL;
