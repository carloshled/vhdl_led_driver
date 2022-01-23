library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity PWM_driver is
  Port (
    clk            : in  std_logic;
    reset          : in  std_logic;
    red_pwm_in     : in  std_logic_vector(7 downto 0);
    green_pwm_in   : in  std_logic_vector(7 downto 0);
    blue_pwm_in    : in  std_logic_vector(7 downto 0);
    red_pwm_out    : out std_logic_vector(0 downto 0);
    green_pwm_out  : out std_logic_vector(0 downto 0);
    blue_pwm_out   : out std_logic_vector(0 downto 0)
  );
end PWM_driver;

architecture dsgn_PWM_driver of PWM_driver is

  --signal speed_pwm      : std_logic_vector(1 downto 0);
  signal loop_mode_pwm  : std_logic;
  --signal red_pwm        : std_logic_vector(7 downto 0);
  --signal green_pwm      : std_logic_vector(7 downto 0);
  --signal blue_pwm       : std_logic_vector(7 downto 0);
  
  component LED_driver is
    port  (  clk         : in std_logic;
             reset       : in std_logic;
             speed       : in std_logic_vector(1 downto 0);
             loop_mode   : in std_logic;
             red_out     : out std_logic_vector(7 downto 0);
             green_out   : out std_logic_vector(7 downto 0);
             blue_out    : out std_logic_vector(7 downto 0)
          );
  end component;

begin

 process (clk)
 begin 
   if rising_edge(clk) then 
     if red_pwm_in = "11111111" then
       red_pwm_out <= "1";
     else 
       red_pwm_out <= "0";
     end if;
     
     if green_pwm_in = "11111111" then
       green_pwm_out <= "1";
     else 
       green_pwm_out <= "0";
     end if;     
 
     if blue_pwm_in = "11111111" then
       blue_pwm_out <= "1";
     else 
       blue_pwm_out <= "0";
     end if;           
   end if;
 end process;
 
end dsgn_PWM_driver;
