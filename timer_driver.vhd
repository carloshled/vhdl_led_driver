library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity timer_driver is
  generic( cycles_cnt : integer);
  port   ( clk, reset  : in std_logic;
           ticks_flag  : out std_logic
      );
end timer_driver;

architecture dsgn_timer_driver of timer_driver is

begin

-- process for clk
process (clk, reset)
  variable ticks : integer := 0;
begin
    
if rising_edge(clk) then
  -- ticks
  ticks_flag <= '0';
  ticks := ticks + 1;
        
  if (ticks = cycles_cnt)then      
    report "1/10 of a second has passed";
    ticks_flag <= '1';
    ticks := 0;
  end if;

  if(reset = '1') then
    ticks_flag <= '0';
    ticks := 0;
  end if;

end if;    
end process;
