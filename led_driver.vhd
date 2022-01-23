library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity LED_driver is
  port (
         clk, reset          : in std_logic;
         ticks_flag_in       : in std_logic;
         speed               : in std_logic_vector(1 downto 0);
         loop_mode           : in std_logic;
         alarm               : in std_logic;
         red_out             : out std_logic_vector(7 downto 0);
         green_out           : out std_logic_vector(7 downto 0);
         blue_out            : out std_logic_vector(7 downto 0)
  );
end LED_driver;

architecture dsgn_LED_driver of LED_driver is
  
  type color_type is (red, yellow, green, blue, purple, white, black);
  type super_state_type is (STANDBY, CONTINUOUS, BACKWARDS, ALARM_ST); --create ALARM state
  type state_type is (RED, YELLOW, GREEN, BLUE, PURPLE, WHITE, BLACK);
  type array_type is array (0 to 2) of integer;
  
  
  --signals
  signal state, next_state              : state_type;
  signal super_state, next_super_state  : super_state_type;
  signal prev_super_state               : super_state_type;
  signal ticks_flag                     : std_logic := '0';
  signal ticks_flag_proc_stmach         : std_logic := '0';
  signal ticks_cnt                      : integer := 0;
  --signal alarm_flag                     : std_logic := '0';
begin
  
-- process for managing the logic
process (clk, reset) 
  
  -- variables declaration
  --variable ticks_flag    : std_logic := '0';
  --variable ticks_cnt     : integer   := 0;
  variable TIME_IN_COLOR : integer   := 0;
  variable direction     : std_logic := '0';
    
  -- constants declaration
  constant TIME_IN_STANDBY   : integer   := 4; --(:40) 4 seconds in STANDBY state 
  constant TIME_IN_ALARM_ST  : integer   := 7; --(:70) 7 seconds in ALARM_ST
  constant LEFT_RIGHT        : std_logic := '0';
  constant RIGHT_LEFT        : std_logic := '1';
  constant SPEED_ARR         : array_type := (1,3,5);
    
begin
  
if rising_edge(clk) then
  if(reset = '1') then
    super_state <= STANDBY;
    state       <= WHITE;
    
    --next_super_state <= STANDBY;
    --next_state       <= WHITE;
      
    TIME_IN_COLOR := 0;
  else 
      
    -- ALARM_ST state evaluation
    if (alarm = '1')then
      prev_super_state  <= super_state;  -- saves current state for returning to it after ALARM_ST finishes
      super_state       <=  ALARM_ST;
      --state ? 
    end if;
    
    -- states
    super_state  <=  next_super_state;
    state        <=  next_state;
      
    ticks_flag <= ticks_flag_in;
         
    if (ticks_flag = '1')then
      ticks_cnt <= ticks_cnt + 1;
      state     <= next_state;
    elsif (next_super_state /= super_state and ticks_cnt = TIME_IN_STANDBY) then
      ticks_cnt <= 0;
    elsif (next_state /= state and ticks_cnt = TIME_IN_COLOR) then
      ticks_cnt <= 0;      
    end if;
  end if;
end if;  
  
  
  if (speed = "00") then
    TIME_IN_COLOR := 1*SPEED_ARR(0);  -- 1 second in each COLOR state (cnst 10)
  elsif (speed = "01") then
    TIME_IN_COLOR := 10*SPEED_ARR(1);  -- 3 second in each COLOR state (cnst 10)
  elsif (speed = "10") then
    TIME_IN_COLOR := 10*SPEED_ARR(2);  -- 5 second in each COLOR state (cnst 10)
  else 
    TIME_IN_COLOR := 10*SPEED_ARR(2);
  end if;
  
  --TIME_IN_COLOR := 100*(to_integer(unsigned(speed))); -- X seconds in COLOR STATES state 
  
  -- for_testing: state machine logic  
  ticks_flag_proc_stmach <= ticks_flag;
  
--  if (ticks_flag = '1') then 
--    ticks_cnt := ticks_cnt + 1;
--  end if; 

  case(super_state) is
   
    when STANDBY =>
      next_state <= WHITE;
      
      -- white color
      red_out   <= "11111111";
      green_out <= "11111111";
      blue_out  <= "11111111";
      
      if(ticks_cnt = TIME_IN_STANDBY) then
        --ticks_cnt <= 0;
        
        if(loop_mode = '0') then
          next_super_state <= CONTINUOUS;
          next_state       <= RED;
          
        elsif(loop_mode = '1') then
          next_super_state <= BACKWARDS;
          next_state       <= RED;
        end if;
      end if;
      
    when CONTINUOUS =>
      
      case(state) is 
        when RED => 
          -- red color
          red_out   <= "11111111";
          green_out <= "00000000";
          blue_out  <= "00000000";
          
          if(ticks_cnt = TIME_IN_COLOR) then
            next_state <= YELLOW;
            --ticks_cnt <= 0;
          end if;
         
        when YELLOW => 
          -- yellow color
          red_out   <= "11111111";
          green_out <= "11111111";
          blue_out  <= "00000000";
          
          if(ticks_cnt = TIME_IN_COLOR) then
            next_state <= GREEN;
            --ticks_cnt <= 0;
          end if;  
          
        when GREEN  =>
          -- yellow color
          red_out   <= "00000000";
          green_out <= "11111111";
          blue_out  <= "00000000";
         
          if(ticks_cnt = TIME_IN_COLOR) then
            next_state <= BLUE;
            --ticks_cnt <= 0;
          end if;
          
        when BLUE =>
          -- blue color
          red_out   <= "00000000";
          green_out <= "00000000";
          blue_out  <= "11111111";
                   
          if(ticks_cnt = TIME_IN_COLOR) then
            next_state <= PURPLE;
            --ticks_cnt <= 0;                               
          end if;
          
        when PURPLE =>
          -- purple color
          red_out   <= "10000000";
          green_out <= "00000000";
          blue_out  <= "10000000";
        
          if(ticks_cnt = TIME_IN_COLOR) then
            next_state <= RED;
            --ticks_cnt <= 0;    
          end if;
          
        when others =>
          next_state <= RED;
          --ticks_cnt <= 0;
        end case;
        
    when BACKWARDS =>

      case(state) is 
        when RED => 
          -- red color
          red_out   <= "11111111";
          green_out <= "00000000";
          blue_out  <= "00000000";
          
          if(ticks_cnt = TIME_IN_COLOR) then
            direction := LEFT_RIGHT;
            next_state <= YELLOW;
            --ticks_cnt <= 0;
          end if;
         
        when YELLOW => 
          -- yellow color
          red_out   <= "11111111";
          green_out <= "11111111";
          blue_out  <= "00000000";
          
          if(ticks_cnt = TIME_IN_COLOR) then
            if(direction = LEFT_RIGHT) then
              next_state <= GREEN;
              --ticks_cnt <= 0;
            elsif(direction = RIGHT_LEFT)then
              next_state <= RED;
              --ticks_cnt <= 0;
            end if;  
          end if;  
          
        when GREEN  =>
          -- yellow color
          red_out   <= "00000000";
          green_out <= "11111111";
          blue_out  <= "00000000";
         
          if(ticks_cnt = TIME_IN_COLOR) then
            if(direction = LEFT_RIGHT) then  
              next_state <= BLUE;
              --ticks_cnt <= 0;
            elsif(direction = RIGHT_LEFT)then
              next_state <= YELLOW;
              --ticks_cnt <= 0;
            end if;            
          end if;
          
        when BLUE =>
          -- blue color
          red_out   <= "00000000";
          green_out <= "00000000";
          blue_out  <= "11111111";
                   
          if(ticks_cnt = TIME_IN_COLOR) then
            if(direction = LEFT_RIGHT) then 
              next_state <= PURPLE;
              --ticks_cnt <= 0;
            elsif(direction = RIGHT_LEFT) then
              next_state <= GREEN;
              --ticks_cnt <= 0; 
            end if;                                 
          end if;
          
        when PURPLE =>
          -- purple color
          red_out   <= "10000000";
          green_out <= "00000000";
          blue_out  <= "10000000";
        
          if(ticks_cnt = TIME_IN_COLOR) then
            direction := RIGHT_LEFT;
            next_state <= BLUE;
            --ticks_cnt <= 0;    
          end if;
          
        when others =>
          next_state <= RED;
          --ticks_cnt <= 0;
        end case;
    
    when ALARM_ST => 
      -- white color
      red_out   <= "11111111";
      green_out <= "11111111";
      blue_out  <= "11111111";
      -- blinking frequency
      
      if(ticks_cnt = TIME_IN_ALARM_ST) then
        next_super_state <= prev_super_state; 
      end if;
         
    when others =>
    end case;
    
    
  end process;
  
end dsgn_LED_driver;
