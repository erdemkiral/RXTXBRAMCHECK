library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;


package ram_pkg is
    function clogb2 (depth: in natural) return integer;
end ram_pkg;

package body ram_pkg is

function clogb2( depth : natural) return integer is
variable temp    : integer := depth;
variable ret_val : integer := 0;
begin
    while temp > 1 loop
        ret_val := ret_val + 1;
        temp    := temp / 2;
    end loop;
  	return ret_val;
end function;

end package body ram_pkg;

library ieee;
library work;
use ieee.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.std_logic_arith.all;
use work.ram_pkg.all;


entity top is
generic(
	RAM_DEPTH 		: integer := 256;      			 	  -- Specify RAM depth (number of entries)
    RAM_WIDTH 		: integer := 8;        			 	  -- Specify RAM data width                      
    RAM_PERFORMANCE : string  := "LOW_LATENCY";   		  -- Select "HIGH_PERFORMANCE" or "LOW_LATENCY" 
	C_RAM_TYPE 		: string  := "block" ;			  -- Select "block" or "distributed" 
 	c_clkfreq  		: integer := 100_000_000;
	c_baudrate 		: integer := 115_200;
	c_stopbitcount  : integer := 2
);
port ( 
		clk : in std_logic;
		rx  : in std_logic;
		tx  : out std_logic
);
end top;

architecture Behavioral of top is

component uart_tx is
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
end component;

component uart_rx is
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
end component;

component bram is
generic (
	RAM_DEPTH 		: integer := 256;      			 		  -- Specify RAM depth (number of entries)
    RAM_WIDTH 		: integer := 8;        			 		  -- Specify RAM data width                      
    RAM_PERFORMANCE : string := "LOW_LATENCY";   		  -- Select "HIGH_PERFORMANCE" or "LOW_LATENCY" 
--  RAM_PERFORMANCE : string 	:= "HIGH_PERFORMANCE";    -- Select "HIGH_PERFORMANCE" or "LOW_LATENCY"
	C_RAM_TYPE 		: string 	:= "block"  			  -- Select "block" or "distributed" 
--  C_RAM_TYPE 		: string 	:= "distributed"          -- Select "block" or "distributed" 
 );
port (
        addr : in std_logic_vector((clogb2(RAM_DEPTH)-1) downto 0); -- Address bus, width determined from RAM_DEPTH
        din  : in std_logic_vector(RAM_WIDTH-1 downto 0);		  	-- RAM input data
        clk	  : in std_logic;                       			  	-- Clock
        wea   : in std_logic;                       			  	-- Write enable      	
        douta : out std_logic_vector(RAM_WIDTH-1 downto 0)   	  	-- RAM output data
    );
end component;

--UART RX SIGNALS
signal 	data	:  std_logic_vector(7 downto 0) := (others => '0');
signal rx_done  :  std_logic := '0';

----UART TX SIGNALS
signal tx_data      :  std_logic_vector(7 downto 0) := (others => '0');
signal tx_start     :  std_logic := '0';
signal tx_done_tick :  std_logic := '0';

--BRAM SIGNALS
signal din   : std_logic_vector(7 downto 0) := (others => '0');
signal addr  :  std_logic_vector((clogb2(RAM_DEPTH)-1) downto 0) := (others => '0');
signal wea   :  std_logic := '0'; 
signal douta :  std_logic_vector(RAM_WIDTH-1 downto 0) ;

-- PROGRAM SIGNALS
type states is (S_RECEIVE,S_START,S_WRITE,S_READ,S_RESPONSE,S_MODULUS,S_TRANSMIT);
signal state : states;

signal databuff : std_logic_vector(6*8-1 downto 0) := (others => '0');
signal checksumreg : std_logic_vector(11 downto 0) := (others => '0');

signal cntr 	: integer range 0 to 6 := 6 ;
signal bytecntr :  integer range 0 to 6 := 0 ;


begin

U1 :  uart_rx
generic map (
		clkfreq   => c_clkfreq ,
		baudrate  => c_baudrate
)
port map ( 
		clk 	=> clk ,
		rx_i	=> rx  ,
		data	=> data ,
		rx_done	=> rx_done
);

U3 : bram 
generic map(
	RAM_DEPTH 		 =>    RAM_DEPTH	,		 		  -- Specify RAM depth (number of entries)
    RAM_WIDTH 		 =>    RAM_WIDTH   	,		 		  -- Specify RAM data width                      
    RAM_PERFORMANCE  =>   RAM_PERFORMANCE,	  -- Select "HIGH_PERFORMANCE" or "LOW_LATENCY" 
	C_RAM_TYPE 		=>    C_RAM_TYPE			  -- Select "block" or "distributed" 
 )
port map(
        addr   => addr, 		-- Address bus, width determined from RAM_DEPTH
        din    => din,		  	-- RAM input data
        clk	   => clk ,         -- Clock
        wea    => wea ,         -- Write enable      	
        douta  => douta   	  	-- RAM output data
);

U2 : uart_tx 
generic map (
	c_clkfreq  		=>  c_clkfreq ,		
	c_baudrate 		=>  c_baudrate,		
	c_stopbitcount  =>  c_stopbitcount 
)
port map ( 
	  clk 	       => clk     ,
	  tx_data      => tx_data   ,
	  tx_start     => tx_start,
	  tx_o	       => tx      , 
	  tx_done_tick => tx_done_tick
);


P_MAIN : process(clk) begin 
if(rising_edge(clk)) then


	
	case state is 
	
		when S_RECEIVE  	=> 
				
				tx_start <= '0';
				wea <= '0';
				cntr <= 6;
				
				if(rx_done = '1') then 
					databuff(8*1-1 downto 8*0) <= data;
					databuff(8*6-1 downto 8*1) <= databuff(8*5-1 downto 8*0);
					bytecntr <= bytecntr + 1;
				end if;
				
				if (bytecntr = 6) then 
					
					if (cntr = 1) then 
					
						if (checksumreg(7 downto 0) = databuff(7 downto 0)) then 
							state <= S_START;
						    bytecntr <= 0;
							cntr <= 6;
							checksumreg <= (others => '0');
						else 
							databuff <= x"abcdee000066";
							bytecntr <= 0;
							cntr <= 6;
							state <= S_TRANSMIT;
							tx_data <= databuff(6*8-1 downto 5*8);
							tx_start <= '1';
						end if;
						
					
					else
						checksumreg <= checksumreg + databuff (cntr*8-1 downto (cntr-1)*8);
						cntr <= cntr - 1;
					end if;
					
					
				else
					state <= S_RECEIVE ;
				end if;
				
		when S_START => 
			
				if(databuff(8*6-1 downto 4*8) = x"ABCD") then 
					
					if(databuff(4*8-1 downto 3*8) = x"11") then -- write 
						state <= S_WRITE;
						wea <= '1';
					elsif(databuff(4*8-1 downto 3*8) = x"22") then -- read
						state <= S_READ;
					end if;
				else 
					state <= S_START;
				end if;

		when S_WRITE 	=> 
		
				wea  <= '1';
				addr <= databuff(3*8-1 downto 2*8);
				din <= databuff(2*8-1 downto 8*1);
				state <= S_RESPONSE;
				
		when S_READ  	=> 
					
				wea <= '0';
				addr <= databuff(3*8-1 downto 2*8);
				databuff(2*8-1 downto 8*1) <= douta;
				state <= S_RESPONSE;
		
		when S_RESPONSE => 
		
				wea <= '0';
				if(databuff(8*4-1 downto 8*3) = x"11") then 
				
					databuff(8*4-1 downto 8*3) <= x"33";  -- write done
					checksumreg <= (others => '0');
					state <= S_MODULUS;
					
				elsif(databuff(8*4-1 downto 8*3) = x"22") then 
					databuff(8*4-1 downto 8*3) <= x"44"; -- read done 
					checksumreg <= (others => '0');
					state <= S_MODULUS;
				end if;
			
		when S_MODULUS => 	
		
				if (cntr = 1) then 
					cntr <= 5;
					databuff(1*8-1 downto 0) <= checksumreg(7 downto 0);
					checksumreg <= (others => '0');
					state <= S_TRANSMIT;
					tx_start <= '1';
					tx_data <= databuff(6*8-1 downto 5*8);

				else 
					checksumreg <= databuff(cntr*8-1 downto (cntr-1)*8) + checksumreg ;
					cntr <= cntr -1 ;
				end if;
		
		when S_TRANSMIT => 

			
			if (cntr = 0) then 
					tx_start <= '0';
					if(tx_done_tick = '1') then 
						checksumreg <= (others => '0');
						tx_start <= '0';
						databuff <= (others => '0');
						tx_data <= (others => '0');
						cntr <= 6;
						state <= S_RECEIVE;
					end if;	
						
			else 
				
				tx_data <= databuff(cntr*8 -1 downto (cntr-1)*8);
				if(tx_done_tick = '1') then
						cntr <= cntr -1 ;
				end if;
		
			end if;
			
			
			
			
	end case;

end if;
end process P_MAIN;

end Behavioral;
