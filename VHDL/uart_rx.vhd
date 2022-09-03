library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity uart_rx is
generic(
		clkfreq  : integer := 100_000_000;
		baudrate : integer := 115_200
);
port ( 
		clk 	: in  std_logic;
		rx_i	: in  std_logic;
		data	: out std_logic_vector(7 downto 0);
		rx_done	: out std_logic
);
end uart_rx;

architecture Behavioral of uart_rx is

type states is (S_IDLE,S_START,S_BIT0,S_BIT1,S_BIT2,S_BIT3,S_BIT4,S_BIT5,S_BIT6,S_BIT7,S_STOP);
signal state : states := S_IDLE;

constant bittimerlim : integer := clkfreq/baudrate;
signal 	 bittimer  	 : integer range 0 to bittimerlim := 0;
signal shreg 		: std_logic_vector(7 downto 0) := (others => '0');


begin


MAIN : process(clk) begin 
if(rising_edge(clk)) then

	case state is
		
		when S_IDLE  =>
				
				rx_done <= '0';
				bittimer <= 0;
				if(rx_i = '0') then 
					state <= S_START;
				else
					state <= S_IDLE;
				end if;
				
		when S_START =>
				
				if(bittimer = bittimerlim/2-1) then 
					shreg <= rx_i & shreg(7 downto 1 );
					state <= S_BIT0;
					bittimer <= 0;
				else 
					bittimer <= bittimer + 1 ;
				end if;
			
		when S_BIT0  =>
		
				if(bittimer = bittimerlim-1) then 
					shreg <= rx_i & shreg(7 downto 1 );
					state <= S_BIT1;
					bittimer <= 0;
				else 
					bittimer <= bittimer + 1 ;
				end if;
				
		when S_BIT1  =>
		
				if(bittimer = bittimerlim-1) then 
					shreg <= rx_i & shreg(7 downto 1 );					
					state <= S_BIT2;
					bittimer <= 0;
				else 
					bittimer <= bittimer + 1 ;
				end if;
		when S_BIT2  =>
		
				if(bittimer = bittimerlim-1) then 
					shreg <= rx_i & shreg(7 downto 1 );
					state <= S_BIT3;
					bittimer <= 0;
				else 
					bittimer <= bittimer + 1 ;
				end if;
		
		when S_BIT3  =>
		
				if(bittimer = bittimerlim-1) then 
					shreg <= rx_i & shreg(7 downto 1 );

					state <= S_BIT4;
					bittimer <= 0;
				else 
					bittimer <= bittimer + 1 ;
				end if;
		
		when S_BIT4  =>
		
				if(bittimer = bittimerlim-1) then 
					shreg <= rx_i & shreg(7 downto 1 );
					state <= S_BIT5;
					bittimer <= 0;
				else 
					bittimer <= bittimer + 1 ;
				end if;
		
		
		when S_BIT5  =>
		
				if(bittimer = bittimerlim-1) then 
					shreg <= rx_i & shreg(7 downto 1 );
					state <= S_BIT6;
					bittimer <= 0;
				else 
					bittimer <= bittimer + 1 ;
				end if;
		
		
		when S_BIT6  =>
		
				if(bittimer = bittimerlim-1) then 
					shreg <= rx_i & shreg(7 downto 1 );
					state <= S_BIT7;
					bittimer <= 0;
				else 
					bittimer <= bittimer + 1 ;
				end if;
		
		
		when S_BIT7  =>
			
				if(bittimer = bittimerlim-1) then 
					shreg <= rx_i & shreg(7 downto 1 );
					state <= S_STOP;
					bittimer <= 0;
				else 
					bittimer <= bittimer + 1 ;
				end if;
		
		
		when S_STOP  =>
		
				if(bittimer = bittimerlim-1) then 
					rx_done <= '1';
					state <= S_IDLE;
					bittimer <= 0;
				else 
					bittimer <= bittimer + 1 ;
				end if;
	
			end case;


end if;
end process MAIN ;

data <= shreg;


end Behavioral;
