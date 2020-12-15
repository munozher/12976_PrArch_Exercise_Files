-- VHDL Entity work.riscv_core.symbol
--
-- Created:
--          by - bmarc.UNKNOWN (LAPTOP-TS0CSSEU)
--          at - 12:08:37 10/14/2020
--
-- Generated by Mentor Graphics' HDL Designer(TM) 2020.1 Built on 20 Jan 2020 at 19:35:24
--
LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY riscv_core IS
   PORT( 
      clk_i        : IN     std_logic;
      i_data_data  : IN     std_logic_vector (31 DOWNTO 0);
      i_instr_data : IN     std_logic_vector (31 DOWNTO 0);
      rst_i        : IN     std_logic;
      o_data_addr  : OUT    std_logic_vector (31 DOWNTO 0);
      o_data_data  : OUT    std_logic_vector (31 DOWNTO 0);
      o_data_rd    : OUT    std_logic;
      o_data_wr    : OUT    std_logic;
      o_instr_addr : OUT    std_logic_vector (31 DOWNTO 0)
   );

-- Declarations

END riscv_core ;

--
-- VHDL Architecture work.riscv_core.structural
--
-- Created:
--          by - brandmar.extern (paulchen.Informatik.tu-cottbus.de)
--          at - 09:43:14 12/15/20
--
-- Generated by Mentor Graphics' HDL Designer(TM) 2020.1 Built on 20 Jan 2020 at 19:35:24
--
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;
LIBRARY work;
USE work.pkg_alu.all;
USE work.pkg_util.all;
USE work.pkg_riscv_insts.all;


ARCHITECTURE structural OF riscv_core IS

   -- Architecture declarations

   -- Internal signal declarations
   SIGNAL cmp_eq          : std_logic;
   SIGNAL cmp_gtu         : std_logic;
   SIGNAL cmp_ltu         : std_logic;
   SIGNAL din1            : std_logic_vector(31 DOWNTO 0);
   SIGNAL din2            : std_logic_vector(31 DOWNTO 0);
   SIGNAL dout            : std_logic_vector(31 DOWNTO 0);
   SIGNAL dout2           : std_logic_vector(31 DOWNTO 0);
   SIGNAL dout3           : std_logic_vector(31 DOWNTO 0);
   SIGNAL dout5           : std_logic_vector(31 DOWNTO 0);
   SIGNAL i_alu_gt        : std_logic;
   SIGNAL i_alu_ltu       : std_logic;
   SIGNAL i_pc_ctrl       : std_logic_vector(3 DOWNTO 0);
   SIGNAL o_aluop         : aluop;
   SIGNAL o_alusrc        : std_logic;
   SIGNAL o_branch        : std_logic;
   SIGNAL o_decoded_instr : t_riscv_inst;
   SIGNAL o_mem2reg       : std_logic;
   SIGNAL o_pc2reg        : std_logic;
   SIGNAL o_pc_ctrl       : std_logic_vector(1 DOWNTO 0);
   SIGNAL o_regwr         : std_logic;
   SIGNAL reg_data1_o     : std_logic_vector(31 DOWNTO 0);
   SIGNAL s_aluin2        : std_logic_vector(31 DOWNTO 0);
   SIGNAL s_pc_nxt        : std_logic_vector(31 DOWNTO 0);

   -- Implicit buffer signal declarations
   SIGNAL o_data_addr_internal  : std_logic_vector (31 DOWNTO 0);
   SIGNAL o_data_data_internal  : std_logic_vector (31 DOWNTO 0);
   SIGNAL o_instr_addr_internal : std_logic_vector (31 DOWNTO 0);


   -- ModuleWare signal declarations(v1.12) for instance 'u_PC' of 'dff'
   SIGNAL mw_u_PCreg_cval : std_logic_vector(31 DOWNTO 0);

   -- Component Declarations
   COMPONENT alu
   PORT (
      alu_ctrl : IN     aluop;
      i_A      : IN     std_logic_vector (31 DOWNTO 0);
      i_B      : IN     std_logic_vector (31 DOWNTO 0);
      cmp_eq   : OUT    std_logic;
      cmp_gt   : OUT    std_logic;
      cmp_gtu  : OUT    std_logic;
      cmp_lt   : OUT    std_logic;
      cmp_ltu  : OUT    std_logic;
      output   : OUT    std_logic_vector (31 DOWNTO 0)
   );
   END COMPONENT;
   COMPONENT imm_generator
   PORT (
      i_decoded_instr : IN     t_riscv_inst;
      i_encoded_instr : IN     std_logic_vector (31 DOWNTO 0);
      o_immediate     : OUT    std_logic_vector (31 DOWNTO 0)
   );
   END COMPONENT;
   COMPONENT instr_decoder
   PORT (
      i_encoded_instr : IN     std_logic_vector (31 DOWNTO 0);
      o_aluop         : OUT    aluop;
      o_alusrc        : OUT    std_logic;
      o_branch        : OUT    std_logic;
      o_decoded_instr : OUT    t_riscv_inst;
      o_mem2reg       : OUT    std_logic;
      o_memrd         : OUT    std_logic;
      o_memwr         : OUT    std_logic;
      o_pc2reg        : OUT    std_logic;
      o_pc_ctrl       : OUT    std_logic_vector (3 DOWNTO 0);
      o_regwr         : OUT    std_logic
   );
   END COMPONENT;
   COMPONENT pc_controller
   PORT (
      i_alu_eq  : IN     std_logic;
      i_alu_gt  : IN     std_logic;
      i_alu_gtu : IN     std_logic;
      i_alu_lt  : IN     std_logic;
      i_alu_ltu : IN     std_logic;
      i_pc_ctrl : IN     std_logic_vector (3 DOWNTO 0);
      o_pc_ctrl : OUT    std_logic_vector (1 DOWNTO 0)
   );
   END COMPONENT;
   COMPONENT regfile
   PORT (
      clk_i       : IN     std_logic;
      rd_addr1_i  : IN     std_logic_vector (4 DOWNTO 0);
      rd_addr2_i  : IN     std_logic_vector (4 DOWNTO 0);
      rst_i       : IN     std_logic;
      wr_addr_i   : IN     std_logic_vector (4 DOWNTO 0);
      wr_data_i   : IN     std_logic_vector (31 DOWNTO 0);
      wr_en_i     : IN     std_logic;
      reg_data1_o : OUT    std_logic_vector (31 DOWNTO 0);
      reg_data2_o : OUT    std_logic_vector (31 DOWNTO 0)
   );
   END COMPONENT;

   -- Optional embedded configurations
   -- pragma synthesis_off
   FOR ALL : alu USE ENTITY work.alu;
   FOR ALL : imm_generator USE ENTITY work.imm_generator;
   FOR ALL : instr_decoder USE ENTITY work.instr_decoder;
   FOR ALL : pc_controller USE ENTITY work.pc_controller;
   FOR ALL : regfile USE ENTITY work.regfile;
   -- pragma synthesis_on


BEGIN

   -- ModuleWare code(v1.12) for instance 'U_5' of 'add'
   u_5combo_proc: PROCESS (o_instr_addr_internal, dout2)
   VARIABLE temp_din0 : std_logic_vector(32 DOWNTO 0);
   VARIABLE temp_din1 : std_logic_vector(32 DOWNTO 0);
   VARIABLE temp_sum : signed(32 DOWNTO 0);
   VARIABLE temp_carry : signed(0 DOWNTO 0);
   BEGIN
      temp_din0 := o_instr_addr_internal(31) & o_instr_addr_internal;
      temp_din1 := dout2(31) & dout2;
      temp_carry(0) := '0';
      temp_sum := signed(temp_din0) + signed(temp_din1) + temp_carry;
      dout3 <= std_logic_vector(temp_sum(31 DOWNTO 0));
   END PROCESS u_5combo_proc;

   -- ModuleWare code(v1.12) for instance 'U_10' of 'add'
   u_10combo_proc: PROCESS (o_instr_addr_internal, din1)
   VARIABLE temp_din0 : std_logic_vector(32 DOWNTO 0);
   VARIABLE temp_din1 : std_logic_vector(32 DOWNTO 0);
   VARIABLE temp_sum : signed(32 DOWNTO 0);
   VARIABLE temp_carry : signed(0 DOWNTO 0);
   BEGIN
      temp_din0 := o_instr_addr_internal(31) & o_instr_addr_internal;
      temp_din1 := din1(31) & din1;
      temp_carry(0) := '0';
      temp_sum := signed(temp_din0) + signed(temp_din1) + temp_carry;
      din2 <= std_logic_vector(temp_sum(31 DOWNTO 0));
   END PROCESS u_10combo_proc;

   -- ModuleWare code(v1.12) for instance 'U_8' of 'constval'
   dout2 <= "00000000000000000000000000000100";

   -- ModuleWare code(v1.12) for instance 'u_PC' of 'dff'
   o_instr_addr_internal <= mw_u_PCreg_cval;
   u_pcseq_proc: PROCESS (clk_i)
   BEGIN
      IF (clk_i'EVENT AND clk_i='1') THEN
         IF (rst_i = '1') THEN
            mw_u_PCreg_cval <= "00000000000000000000000000000000";
         ELSE
            mw_u_PCreg_cval <= s_pc_nxt;
         END IF;
      END IF;
   END PROCESS u_pcseq_proc;

   -- ModuleWare code(v1.12) for instance 'U_0' of 'mux'
   u_0combo_proc: PROCESS(dout, o_instr_addr_internal, o_pc2reg)
   BEGIN
      CASE o_pc2reg IS
      WHEN '0' => dout5 <= dout;
      WHEN '1' => dout5 <= o_instr_addr_internal;
      WHEN OTHERS => dout5 <= (OTHERS => 'X');
      END CASE;
   END PROCESS u_0combo_proc;

   -- ModuleWare code(v1.12) for instance 'U_3' of 'mux'
   u_3combo_proc: PROCESS(o_data_addr_internal, i_data_data, o_mem2reg)
   BEGIN
      CASE o_mem2reg IS
      WHEN '0' => dout <= o_data_addr_internal;
      WHEN '1' => dout <= i_data_data;
      WHEN OTHERS => dout <= (OTHERS => 'X');
      END CASE;
   END PROCESS u_3combo_proc;

   -- ModuleWare code(v1.12) for instance 'U_4' of 'mux'
   u_4combo_proc: PROCESS(o_data_data_internal, din1, o_alusrc)
   BEGIN
      CASE o_alusrc IS
      WHEN '0' => s_aluin2 <= o_data_data_internal;
      WHEN '1' => s_aluin2 <= din1;
      WHEN OTHERS => s_aluin2 <= (OTHERS => 'X');
      END CASE;
   END PROCESS u_4combo_proc;

   -- ModuleWare code(v1.12) for instance 'U_6' of 'mux'
   u_6combo_proc: PROCESS(dout3, din2, o_data_addr_internal, o_pc_ctrl)
   BEGIN
      CASE o_pc_ctrl IS
      WHEN "00" => s_pc_nxt <= dout3;
      WHEN "01" => s_pc_nxt <= din2;
      WHEN "10" => s_pc_nxt <= o_data_addr_internal;
      WHEN OTHERS => s_pc_nxt <= (OTHERS => 'X');
      END CASE;
   END PROCESS u_6combo_proc;

   -- Instance port mappings.
   u_alu : alu
      PORT MAP (
         i_A      => reg_data1_o,
         i_B      => s_aluin2,
         alu_ctrl => o_aluop,
         output   => o_data_addr_internal,
         cmp_ltu  => cmp_ltu,
         cmp_lt   => i_alu_ltu,
         cmp_eq   => cmp_eq,
         cmp_gt   => i_alu_gt,
         cmp_gtu  => cmp_gtu
      );
   U_9 : imm_generator
      PORT MAP (
         i_encoded_instr => i_instr_data,
         i_decoded_instr => o_decoded_instr,
         o_immediate     => din1
      );
   u_inst_dec : instr_decoder
      PORT MAP (
         i_encoded_instr => i_instr_data,
         o_decoded_instr => o_decoded_instr,
         o_branch        => o_branch,
         o_memrd         => o_data_rd,
         o_memwr         => o_data_wr,
         o_mem2reg       => o_mem2reg,
         o_regwr         => o_regwr,
         o_alusrc        => o_alusrc,
         o_pc_ctrl       => i_pc_ctrl,
         o_pc2reg        => o_pc2reg,
         o_aluop         => o_aluop
      );
   U_1 : pc_controller
      PORT MAP (
         i_pc_ctrl => i_pc_ctrl,
         i_alu_ltu => i_alu_ltu,
         i_alu_lt  => cmp_ltu,
         i_alu_eq  => cmp_eq,
         i_alu_gt  => i_alu_gt,
         i_alu_gtu => cmp_gtu,
         o_pc_ctrl => o_pc_ctrl
      );
   u_reg_file : regfile
      PORT MAP (
         clk_i       => clk_i,
         rst_i       => rst_i,
         rd_addr1_i  => i_instr_data(19 downto 15),
         rd_addr2_i  => i_instr_data(24 downto 20),
         wr_data_i   => dout5,
         wr_addr_i   => i_instr_data(11 downto 7),
         wr_en_i     => o_regwr,
         reg_data1_o => reg_data1_o,
         reg_data2_o => o_data_data_internal
      );

   -- Implicit buffered output assignments
   o_data_addr  <= o_data_addr_internal;
   o_data_data  <= o_data_data_internal;
   o_instr_addr <= o_instr_addr_internal;

END structural;
