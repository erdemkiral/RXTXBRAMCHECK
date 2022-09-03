ibrary IEEE;
use IEEE.STD_LOGIC_1164.ALL;


entity uart_tx is
generic(
		c_clkfreq  		: integer := 100_000_000;
		c_baudrate 		: integer := 115_200;
		c_stopbitcount  : integer := 2
);
port( 
	  clk 	       : in std_logic;
	  tx_data      : in std_logic_vector(7 downto 0);
	  tx_start     : in std_logic;
	  tx_o	       : out std_logic; 
	  tx_done_tick : out std_logic
	  );
end uart_tx;

architecture Behavioral of uart_tx is

constant bittimerlim 	 : integer := c_clkfreq/c_baudrate;
constant stopbittimerlim : integer := (c_clkfreq/c_baudrate)*c_stopbitcount;

signal bittimer    : integer range 0 to stopbittimerlim := 0;
signal shreg	   : std_logic_vector(7 downto 0) := (others => '0');

type states is (S_IDLE,START,BIT0,BIT1,BIT2,BIT3,BIT4,BIT5,BIT6,BIT7,STOPBIT);
signal state : states;


begin


P_MAIN : process(clk) begin 
if(rising_edge(clk)) then 

	case state is
	
		when S_IDLE => 
		
				tx_o <= '1';
				tx_done_tick <= '0';
				
				if(tx_start = '1') then 
					state <= START;
					tx_o <= '0';
					shreg <= tx_data;
				end if;
		when START 	=> 
		
			if(bittimer = bittimerlim-1) then
				bittimer <= 0;
				tx_o <= shreg(0);
				shreg(7) <= shreg(0);
				shreg(6 downto 0) <= shreg(7 downto 1);
				state <= BIT0;
			else 
				bittimer <= bittimer + 1;
			end if;	
			
		when BIT0 	=> 
		
			if(bittimer = bittimerlim-1) then
				tx_o <= shreg(0);
				shreg(7) <= shreg(0);
				shreg(6 downto 0) <= shreg(7 downto 1);
				bittimer <= 0;
				state <= BIT1;
			else 
				bittimer <= bittimer + 1;
			end if;	
			
		when BIT1 	=> 
		
			if(bittimer = bittimerlim-1) then
				tx_o <= shreg(0);
				shreg(7) <= shreg(0);
				shreg(6 downto 0) <= shreg(7 downto 1);
				bittimer <= 0;
				state <= BIT2;
			else 
				bittimer <= bittimer + 1;
			end if;	
		
		when BIT2 	=> 
		
			if(bittimer = bittimerlim-1) then
				tx_o <= shreg(0);
				shreg(7) <= shreg(0);
				shreg(6 downto 0) <= shreg(7 downto 1);
				bittimer <= 0;
				state <= BIT3;
			else 
				bittimer <= bittimer + 1;
			end if;
		
		when BIT3 	=> 
		
			if(bittimer = bittimerlim-1) then
				tx_o <= shreg(0);
				shreg(7) <= shreg(0);
				shreg(6 downto 0) <= shreg(7 downto 1);
				bittimer <= 0;
				state <= BIT4;
			else 
				bittimer <= bittimer + 1;
			end if;
			
		when BIT4 	=> 
	
			if(bittimer = bittimerlim-1) then
				tx_o <= shreg(0);
				shreg(7) <= shreg(0);
				shreg(6 downto 0) <= shreg(7 downto 1);
				bittimer <= 0;
				state <= BIT5;
			else 
				bittimer <= bittimer + 1;
			end if;
			
		when BIT5 	=> 
		
			if(bittimer = bittimerlim-1) then
				tx_o <= shreg(0);
				shreg(7) <= shreg(0);
				shreg(6 downto 0) <= shreg(7 downto 1);
				bittimer <= 0;
				state <= BIT6;
			else 
				bittimer <= bittimer + 1;
			end if;
			
		when BIT6 	=> 
			
			if(bittimer = bittimerlim-1) then
				tx_o <= shreg(0);
				shreg(7) <= shreg(0);
				shreg(6 downto 0) <= shreg(7 downto 1);
				bittimer <= 0;
				state <= BIT7;
			else 
				bittimer <= bittimer + 1;
			end if;
		
		when BIT7 	=> 
		
			if(bittimer = bittimerlim-1) then
				tx_o <= shreg(0);
				shreg(7) <= shreg(0);
				shreg(6 downto 0) <= shreg(7 downto 1);
				bittimer <= 0;
				state <= STOPBIT;
				tx_o <= '1';
			else 
				bittimer <= bittimer + 1;
			end if;
		
		when STOPBIT => 
		
			if(bittimer = stopbittimerlim-1) then
				state <= S_IDLE;
				tx_done_tick <= '1';
				bittimer <= 0;
			else 
				bittimer <= bittimer + 1;
			end if;
	end case;

end if;
end process P_MAIN;


end Behavioral;
