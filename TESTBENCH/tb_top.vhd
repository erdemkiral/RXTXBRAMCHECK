library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity tb_top is
generic(
	RAM_DEPTH : integer := 256;      			 		  -- Specify RAM depth (number of entries)
    RAM_WIDTH : integer := 8;        			 		  -- Specify RAM data width                      
    RAM_PERFORMANCE : string := "LOW_LATENCY";   		  -- Select "HIGH_PERFORMANCE" or "LOW_LATENCY" 
--  RAM_PERFORMANCE : string 	:= "HIGH_PERFORMANCE";    -- Select "HIGH_PERFORMANCE" or "LOW_LATENCY"
	C_RAM_TYPE 		: string 	:= "block" ;			  -- Select "block" or "distributed" 
--  C_RAM_TYPE 		: string 	:= "distributed"          -- Select "block" or "distributed" 
 	c_clkfreq  		: integer := 100_000_000;
	c_baudrate 		: integer := 115_200;
	c_stopbitcount  : integer := 2
);
end tb_top;

architecture Behavioral of tb_top is

component top is
generic(
	RAM_DEPTH : integer := 256;      			 		  -- Specify RAM depth (number of entries)
    RAM_WIDTH : integer := 8;        			 		  -- Specify RAM data width                      
    RAM_PERFORMANCE : string := "LOW_LATENCY";   		  -- Select "HIGH_PERFORMANCE" or "LOW_LATENCY" 
--  RAM_PERFORMANCE : string 	:= "HIGH_PERFORMANCE";    -- Select "HIGH_PERFORMANCE" or "LOW_LATENCY"
	C_RAM_TYPE 		: string 	:= "block" ;			  -- Select "block" or "distributed" 
--  C_RAM_TYPE 		: string 	:= "distributed"          -- Select "block" or "distributed" 
 	c_clkfreq  		: integer := 100_000_000;
	c_baudrate 		: integer := 115_200;
	c_stopbitcount  : integer := 2
);
port ( 
		clk : in std_logic;
		rx  : in std_logic;
		tx  : out std_logic
);
end component;


signal clk : std_logic := '0';
signal rx  : std_logic := '0';
signal tx  : std_logic ;
constant clkperiod 	: time := 10 ns ;
constant baud115200 : time := 8.68 us ;

constant hex_AB : std_logic_vector (9 downto 0) := '1' & x"AB" & '0';
constant hex_CD : std_logic_vector (9 downto 0) := '1' & x"CD" & '0';
constant hex_11 : std_logic_vector (9 downto 0) := '1' & x"11" & '0';
constant hex_03 : std_logic_vector (9 downto 0) := '1' & x"03" & '0';
constant hex_67 : std_logic_vector (9 downto 0) := '1' & x"67" & '0';
constant hex_F3 : std_logic_vector (9 downto 0) := '1' & x"F3" & '0';

constant hex_22 : std_logic_vector (9 downto 0) := '1' & x"22" & '0';
constant hex_00 : std_logic_vector (9 downto 0) := '1' & x"00" & '0';
constant hex_9D : std_logic_vector (9 downto 0) := '1' & x"9D" & '0';

constant hex_99 : std_logic_vector (9 downto 0) := '1' & x"99" & '0';

begin


DUT : top 
generic map(
	RAM_DEPTH 		=>	RAM_DEPTH 		, 		  -- Specify RAM depth (number of entries)
    RAM_WIDTH 		=>	RAM_WIDTH 		, 		  -- Specify RAM data width                      
    RAM_PERFORMANCE =>  RAM_PERFORMANCE	,	  		-- Select "HIGH_PERFORMANCE" or "LOW_LATENCY" 
	C_RAM_TYPE 		=>	C_RAM_TYPE  	,			-- Select "block" or "distributed"  
 	c_clkfreq  		=> 	c_clkfreq  		,
	c_baudrate 		=> 	c_baudrate 		,
	c_stopbitcount  => 	c_stopbitcount
)	
port map ( 
		clk => clk ,
		rx  => rx  ,
		tx  => tx  
);


P_CLKGEN : process begin
clk	<= '0';
wait for clkperiod/2;
clk	<= '1';
wait for clkperiod/2;

end process P_CLKGEN;


P_STIMULI : process begin

wait for 10*clkperiod;

for i in 0 to 9 loop rx <= hex_AB(i); wait for baud115200; end loop;
for i in 0 to 9 loop rx <= hex_CD(i); wait for baud115200; end loop;
for i in 0 to 9 loop rx <= hex_11(i); wait for baud115200; end loop;
for i in 0 to 9 loop rx <= hex_03(i); wait for baud115200; end loop;
for i in 0 to 9 loop rx <= hex_67(i); wait for baud115200; end loop;
for i in 0 to 9 loop rx <= hex_F3(i); wait for baud115200; end loop;

wait for 1 ms ;

for j in 0 to 9 loop rx <= hex_AB(j); wait for baud115200; end loop;
for j in 0 to 9 loop rx <= hex_CD(j); wait for baud115200; end loop;
for j in 0 to 9 loop rx <= hex_22(j); wait for baud115200; end loop;
for j in 0 to 9 loop rx <= hex_03(j); wait for baud115200; end loop;
for j in 0 to 9 loop rx <= hex_00(j); wait for baud115200; end loop;
for j in 0 to 9 loop rx <= hex_9D(j); wait for baud115200; end loop;

wait for 1 ms ;


for k in 0 to 9 loop rx <= hex_AB(k); wait for baud115200; end loop;
for k in 0 to 9 loop rx <= hex_CD(k); wait for baud115200; end loop;
for k in 0 to 9 loop rx <= hex_22(k); wait for baud115200; end loop;
for k in 0 to 9 loop rx <= hex_03(k); wait for baud115200; end loop;
for k in 0 to 9 loop rx <= hex_00(k); wait for baud115200; end loop;
for k in 0 to 9 loop rx <= hex_99(k); wait for baud115200; end loop;

wait for 1 ms ;


assert false report "SIM DONE" severity failure;
  
end process P_STIMULI;

end Behavioral;

