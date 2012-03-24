require 'rubygems'
require "getoptlong"

has_erubis=false
begin
  require "erubis"
  has_erubis=true
rescue Exception=>e 
  puts "*** WARNING *** Erubis not found. Saving in non-binary formats disabled."
end
#puts has_erubis


default_context=
{
  :line_nb=>0,
  :line=>"",
  :section=>nil,
  :arg=>nil,

  :header=>
  {
    :board_name=>nil,
    :version=>nil,
    :manufacturer=>nil,
    :part_nb=>nil,
    :serial_nb=>nil
  },

  :current=>
  {
    :vdd_3v3=>0,
    :vdd_5v=>0,
    :sys_5v=>0,
    :supplied=>0
  },

  :user_content=>[],

  :pins_used=>0,

  :pin_info =>
  [
    { :name=>["p9-22","uart2_rxd"],
      :modes=>{"spi0_sclk"=>0, "uart2_rxd"=>1, "i2c2_sda"=>2, "ehrpwm0a"=>3, "emu2"=>6, "gpio0_2"=>7},
      :used=>0,
      :dir=>1,         #safe default: input
      :slew_rate=>1,   #slow
      :rx=>0,
      :pull=>1,        #pull-up
      :pen=>0,         #pull disabled
      :mux_mode=>1
    },
    { :name=>["p9-21","uart2_txd"],
      :modes=>{"spi0_d0"=>0, "uart2_txd"=>1, "i2c2_scl"=>2, "ehrpwm0b"=>3,"emu3"=>6, "gpio0_3"=>7},
      :used=>0,
      :dir=>2,
      :slew_rate=>1,   #slow
      :rx=>0,
      :pull=>1,        #pull-up
      :pen=>0,         #pull disabled
      :mux_mode=>1
    },
    { :name=>["p9-18","i2c1_sda"],
      :modes=>{"spi0_d1"=>0, "mmc1_sdwp"=>1, "i2c1_sda"=>2, "ehrpwm0_tripzone"=>3,"gpio0_4"=>7},
      :used=>0,
      :dir=>3,
      :slew_rate=>1,   #slow
      :rx=>0,
      :pull=>1,        #pull-up
      :pen=>0,         #pull disabled
      :mux_mode=>2
    },
    { :name=>["p9-17","i2c1_scl"],
      :modes=>{"spi0_cs0"=>0, "mmc2_sdwp"=>1, "i2c1_scl"=>2, "ehrpwm0_synci"=>3,"gpio0_5"=>7},
      :used=>0,
      :dir=>2,
      :slew_rate=>1,   #slow
      :rx=>0,
      :pull=>1,        #pull-up
      :pen=>0,         #pull disabled
      :mux_mode=>2
    },
    { :name=>["p9-42","gpio0_7"],
      :modes=>{"ecap0_in_pwm0_out"=>0, "uart3_txd"=>1, "spi1_cs1"=>2, "pr1_ecap0_ecap_capin_apwm_o"=>3,"spi1_sclk"=>4, "mmc0_sdwp"=>5, "xdma_event_intr2"=>6, "gpio0_7"=>7},
      :used=>0,
      :dir=>1,         #safe default: input
      :slew_rate=>1,   #slow
      :rx=>0,
      :pull=>1,        #pull-up
      :pen=>0,         #pull disabled
      :mux_mode=>7
    },
    { :name=>["p8-35","uart4_ctsn"],
      :modes=>{"lcd_data12"=>0, "gpmc_a16"=>1, "eqep1a_in"=>2, "mcasp0_aclkr"=>3,"mcasp0_axr2"=>4, "uart4_ctsn"=>6, "gpio0_8"=>7},
      :used=>0,
      :dir=>1,         #safe default: input
      :slew_rate=>1,   #slow
      :rx=>0,
      :pull=>1,        #pull-up
      :pen=>0,         #pull disabled
      :mux_mode=>6
    },
    { :name=>["p8-33","uart4_rtsn"],
      :modes=>{"lcd_data13"=>0, "gpmc_a17"=>1, "eqep1b_in"=>2, "mcasp0_fsr"=>3,"mcasp0_axr3"=>4, "uart4_rtsn"=>6, "gpio0_9"=>7},
      :used=>0,
      :dir=>2,
      :slew_rate=>1,   #slow
      :rx=>0,
      :pull=>1,        #pull-up
      :pen=>0,         #pull disabled
      :mux_mode=>6
    },
    { :name=>["p8-31","uart5_ctsn"],
      :modes=>{"lcd_data14"=>0, "gpmc_a18"=>1, "eqep1_index"=>2, "mcasp0_axr1"=>3,"uart5_rxd"=>4, "uart5_ctsn"=>6, "gpio0_10"=>7},
      :used=>0,
      :dir=>1,         #safe default: input
      :slew_rate=>1,   #slow
      :rx=>0,
      :pull=>1,        #pull-up
      :pen=>0,         #pull disabled
      :mux_mode=>6
    },
    { :name=>["p8-32","uart5_rtsn"],
      :modes=>{"lcd_data15"=>0, "gpmc_a19"=>1, "eqep1_strobe"=>2, "mcasp0_ahclkx"=>3,"mcasp0_axr3"=>4, "uart5_rtsn"=>6, "gpio0_11"=>7},
      :used=>0,
      :dir=>2,
      :slew_rate=>1,   #slow
      :rx=>0,
      :pull=>1,        #pull-up
      :pen=>0,         #pull disabled
      :mux_mode=>6
    },
    { :name=>["p9-19","i2c2_scl"],
      :modes=>{"uart1_rtsn"=>0, "timer5"=>1, "dcan0_rx"=>2, "i2c2_scl"=>3,"spi1_cs1"=>4, "gpio0_13"=>7},
      :used=>0,
      :dir=>2,
      :slew_rate=>1,   #slow
      :rx=>0,
      :pull=>1,        #pull-up
      :pen=>0,         #pull disabled
      :mux_mode=>3
    },
    { :name=>["p9-20", "i2c2_sda"],
      :modes=>{"uart1_ctsn"=>0, "timer6"=>1, "dcan0_tx"=>2, "i2c2_sda"=>3,"spi1_cs0"=>4, "gpio0_12"=>7},
      :used=>0,
      :dir=>3,
      :slew_rate=>1,   #slow
      :rx=>0,
      :pull=>1,        #pull-up
      :pen=>0,         #pull disabled
      :mux_mode=>3
    },
    { :name=>["p9-26","uart1_rxd"],
      :modes=>{"uart1_rxd"=>0, "mmc1_sdwp"=>1, "dcan1_tx"=>2, "i2c1_sda"=>3,"gpio0_14"=>7},
      :used=>0,
      :dir=>1,         #safe default: input
      :slew_rate=>1,   #slow
      :rx=>0,
      :pull=>1,        #pull-up
      :pen=>0,         #pull disabled
      :mux_mode=>0
    },
    { :name=>["p9-24","uart1_txd"],
      :modes=>{"uart1_txd"=>0, "mmc2_sdwp"=>1, "dcan1_rx"=>2, "i2c1_scl"=>3,"gpio0_15"=>7},
      :used=>0,
      :dir=>2,
      :slew_rate=>1,   #slow
      :rx=>0,
      :pull=>1,        #pull-up
      :pen=>0,         #pull disabled
      :mux_mode=>0
    },
    { :name=>["p9-41","clkout2"],
      :modes=>{"xdma_event_intr1"=>0, "tclkin"=>2, "clkout2"=>3,"timer7"=>4, "emu3"=>6, "gpio0_20"=>7},
      :used=>0,
      :dir=>2,
      :slew_rate=>1,   #slow
      :rx=>0,
      :pull=>1,        #pull-up
      :pen=>0,         #pull disabled
      :mux_mode=>3
    },
    { :name=>["p8-19","ehrpwm2a"],
      :modes=>{"gpmc_ad8"=>0, "lcd_data23"=>1, "mmc1_dat0"=>2, "mmc2_dat4"=>3,"ehrpwm2a"=>4, "gpio0_22"=>7},
      :used=>0,
      :dir=>1,         #safe default: input
      :slew_rate=>1,   #slow
      :rx=>0,
      :pull=>1,        #pull-up
      :pen=>0,         #pull disabled
      :mux_mode=>4
    },
    { :name=>["p8-13","ehrpwm2b"],
      :modes=>{"gpmc_ad9"=>0, "lcd_data22"=>1, "mmc1_dat1"=>2, "mmc2_dat5"=>3,"ehrpwm2b"=>4, "gpio0_23"=>7},
      :used=>0,
      :dir=>1,         #safe default: input
      :slew_rate=>1,   #slow
      :rx=>0,
      :pull=>1,        #pull-up
      :pen=>0,         #pull disabled
      :mux_mode=>4
    },
    { :name=>["p8-14","gpio0_26"],
      :modes=>{"gpmc_ad10"=>0, "lcd_data21"=>1, "mmc1_dat2"=>2, "mmc2_dat6"=>3,"ehrpwm2_tripzone_in"=>4, "gpio0_26"=>7},
      :used=>0,
      :dir=>1,         #safe default: input
      :slew_rate=>1,   #slow
      :rx=>0,
      :pull=>1,        #pull-up
      :pen=>0,         #pull disabled
      :mux_mode=>7
    },
    { :name=>["p8-17","gpio0_27"],
      :modes=>{"gpmc_ad11"=>0, "lcd_data20"=>1, "mmc1_dat3"=>2, "mmc2_dat7"=>3,"ehrpwm0_synco"=>4, "gpio0_27"=>7},
      :used=>0,
      :dir=>1,         #safe default: input
      :slew_rate=>1,   #slow
      :rx=>0,
      :pull=>1,        #pull-up
      :pen=>0,         #pull disabled
      :mux_mode=>7
    },
    { :name=>["p9-11","uart4_rxd"],
      :modes=>{"gpmc_wait0"=>0, "mii2_crs"=>1, "gpmc_csn4"=>2, "rmii2_crs_dv"=>3,"mmc1_sdcd"=>4, "uart4_rxd"=>6, "gpio0_30"=>7},
      :used=>0,
      :dir=>1,         #safe default: input
      :slew_rate=>1,   #slow
      :rx=>0,
      :pull=>1,        #pull-up
      :pen=>0,         #pull disabled
      :mux_mode=>6
    },
    { :name=>["p9-13","uart4_txd"],
      :modes=>{"gpmc_wpn"=>0, "mii2_rxerr"=>1, "gpmc_csn5"=>2, "rmii2_rxerr"=>3,"mmc2_sdcd"=>4, "uart4_txd"=>6, "gpio0_31"=>7},
      :used=>0,
      :dir=>2,
      :slew_rate=>1,   #slow
      :rx=>0,
      :pull=>1,        #pull-up
      :pen=>0,         #pull disabled
      :mux_mode=>6
    },
    { :name=>["p8-25","gpio1_0"],
      :modes=>{"gpmc_ad0"=>0, "mmc1_dat0"=>1,"gpio1_0"=>7},
      :used=>0,
      :dir=>1,         #safe default: input
      :slew_rate=>1,   #slow
      :rx=>0,
      :pull=>1,        #pull-up
      :pen=>0,         #pull disabled
      :mux_mode=>7
    },
    { :name=>["p8-24","gpio1_1"],
      :modes=>{"gpmc_ad1"=>0, "mmc1_dat1"=>1,"gpio1_1"=>7},
      :used=>0,
      :dir=>1,         #safe default: input
      :slew_rate=>1,   #slow
      :rx=>0,
      :pull=>1,        #pull-up
      :pen=>0,         #pull disabled
      :mux_mode=>7
    },
    { :name=>["p8-5","gpio1_2"],
      :modes=>{"gpmc_ad2"=>0, "mmc1_dat2"=>1,"gpio1_2"=>7},
      :used=>0,
      :dir=>1,         #safe default: input
      :slew_rate=>1,   #slow
      :rx=>0,
      :pull=>1,        #pull-up
      :pen=>0,         #pull disabled
      :mux_mode=>7
    },
    { :name=>["p8-6","gpio1_3"],
      :modes=>{"gpmc_ad3"=>0, "mmc1_dat6"=>1,"gpio1_3"=>7},
      :used=>0,
      :dir=>1,         #safe default: input
      :slew_rate=>1,   #slow
      :rx=>0,
      :pull=>1,        #pull-up
      :pen=>0,         #pull disabled
      :mux_mode=>7
    },
    { :name=>["p8-23","gpio1_4"],
      :modes=>{"gpmc_ad4"=>0, "mmc1_dat3"=>2,"gpio1_4"=>7},
      :used=>0,
      :dir=>1,         #safe default: input
      :slew_rate=>1,   #slow
      :rx=>0,
      :pull=>1,        #pull-up
      :pen=>0,         #pull disabled
      :mux_mode=>7
    },
    { :name=>["p8-22","gpio1_5"],
      :modes=>{"gpmc_ad5"=>0, "mmc1_dat5"=>2,"gpio1_5"=>7},
      :used=>0,
      :dir=>1,         #safe default: input
      :slew_rate=>1,   #slow
      :rx=>0,
      :pull=>1,        #pull-up
      :pen=>0,         #pull disabled
      :mux_mode=>7
    },
    { :name=>["p8-3","gpio1_6"],
      :modes=>{"gpmc_ad6"=>0, "mmc1_dat6"=>1,"gpio1_6"=>7},
      :used=>0,
      :dir=>1,         #safe default: input
      :slew_rate=>1,   #slow
      :rx=>0,
      :pull=>1,        #pull-up
      :pen=>0,         #pull disabled
      :mux_mode=>7
    },
    { :name=>["p8-4","gpio1_7"],
      :modes=>{"gpmc_ad7"=>0, "mmc1_dat7"=>1,"gpio1_7"=>7},
      :used=>0,
      :dir=>1,         #safe default: input
      :slew_rate=>1,   #slow
      :rx=>0,
      :pull=>1,        #pull-up
      :pen=>0,         #pull disabled
      :mux_mode=>7
    },
    { :name=>["p8-12","gpio1_12"],
      :modes=>{"gpmc_ad12"=>0, "lcd_data19"=>1, "mmc1_dat4"=>2, "mmc2_dat0"=>3,"eqep2a_in"=>4, "gpio1_12"=>7},
      :used=>0,
      :dir=>1,         #safe default: input
      :slew_rate=>1,   #slow
      :rx=>0,
      :pull=>1,        #pull-up
      :pen=>0,         #pull disabled
      :mux_mode=>7
    },
    { :name=>["p8-11","gpio1_13"],
      :modes=>{"gpmc_ad13"=>0, "lcd_data18"=>1, "mmc1_dat5"=>2, "mmc2_dat1"=>3,"eqep2b_in"=>4, "gpio1_13"=>7},
      :used=>0,
      :dir=>1,         #safe default: input
      :slew_rate=>1,   #slow
      :rx=>0,
      :pull=>1,        #pull-up
      :pen=>0,         #pull disabled
      :mux_mode=>7
    },
    { :name=>["p8-16","gpio1_14"],
      :modes=>{"gpmc_ad14"=>0, "lcd_data17"=>1, "mmc1_dat6"=>2, "mmc2_dat2"=>3,"eqep2_index"=>4, "gpio1_14"=>7},
      :used=>0,
      :dir=>1,         #safe default: input
      :slew_rate=>1,   #slow
      :rx=>0,
      :pull=>1,        #pull-up
      :pen=>0,         #pull disabled
      :mux_mode=>7
    },
    { :name=>["p8-15","gpio1_15"],
      :modes=>{"gpmc_ad15"=>0, "lcd_data16"=>1, "mmc1_dat7"=>2, "mmc2_dat3"=>3,"eqep2_strobe"=>4, "gpio1_15"=>7},
      :used=>0,
      :dir=>1,         #safe default: input
      :slew_rate=>1,   #slow
      :rx=>0,
      :pull=>1,        #pull-up
      :pen=>0,         #pull disabled
      :mux_mode=>7
    },
    { :name=>["p9-15","gpio1_16"],
      :modes=>{"gpmc_a0"=>0, "gmii2_txen"=>1, "rmii2_tctl"=>2, "mii2_txen"=>3,"gpmc_a16"=>4, "ehrpwm1_tripzone_input"=>6, "gpio1_16"=>7},
      :used=>0,
      :dir=>1,         #safe default: input
      :slew_rate=>1,   #slow
      :rx=>0,
      :pull=>1,        #pull-up
      :pen=>0,         #pull disabled
      :mux_mode=>7
    },
    { :name=>["p9-23","gpio1_17"],
      :modes=>{"gpmc_a1"=>0, "gmii2_rxdv"=>1, "rgmii2_rxdv"=>2, "mmc2_dat0"=>3,"gpmc_a17"=>4, "ehrpwm0_synco"=>6, "gpio1_17"=>7},
      :used=>0,
      :dir=>1,         #safe default: input
      :slew_rate=>1,   #slow
      :rx=>0,
      :pull=>1,        #pull-up
      :pen=>0,         #pull disabled
      :mux_mode=>7
    },
    { :name=>["p9-14","ehrpwm1a"],
      :modes=>{"gpmc_a2"=>0, "mii2_txd3"=>1, "rgmii2_td3"=>2, "mmc2_dat1"=>3,"gpmc_a18"=>4, "ehrpwm1a"=>6, "gpio1_18"=>7},
      :used=>0,
      :dir=>1,         #safe default: input
      :slew_rate=>1,   #slow
      :rx=>0,
      :pull=>1,        #pull-up
      :pen=>0,         #pull disabled
      :mux_mode=>6
    },
    { :name=>["p9-16","ehrpwm1b"],
      :modes=>{"gpmc_a3"=>0, "mii2_txd2"=>1, "rgmii2_td2"=>2, "mmc2_dat2"=>3,"gpmc_a19"=>4, "ehrpwm1b"=>6, "gpio1_19"=>7},
      :used=>0,
      :dir=>1,         #safe default: input
      :slew_rate=>1,   #slow
      :rx=>0,
      :pull=>1,        #pull-up
      :pen=>0,         #pull disabled
      :mux_mode=>6
    },
    { :name=>["p9-12","gpio1_28"],
      :modes=>{"gpmc_be1n"=>0, "mii2_col"=>1, "gpmc_csn6"=>2, "mmc2_dat3"=>3,"gpmc_dir"=>4, "mcasp0_aclkr"=>6, "gpio1_28"=>7},
      :used=>0,
      :dir=>1,         #safe default: input
      :slew_rate=>1,   #slow
      :rx=>0,
      :pull=>1,        #pull-up
      :pen=>0,         #pull disabled
      :mux_mode=>7
    },
    { :name=>["p8-26","gpio1_29"],
      :modes=>{"gpmc_csn0"=>0,"gpio1_29"=>7},
      :used=>0,
      :dir=>1,         #safe default: input
      :slew_rate=>1,   #slow
      :rx=>0,
      :pull=>1,        #pull-up
      :pen=>0,         #pull disabled
      :mux_mode=>7
    },
    { :name=>["p8-21","gpio1_30"],
      :modes=>{"gpmc_csn1"=>0, "gpmc_clk"=>1, "mmc1_clk"=>2,"gpio1_30"=>7},
      :used=>0,
      :dir=>1,         #safe default: input
      :slew_rate=>1,   #slow
      :rx=>0,
      :pull=>1,        #pull-up
      :pen=>0,         #pull disabled
      :mux_mode=>7
    },
    { :name=>["p8-20","gpio1_31"],
      :modes=>{"gpmc_csn2"=>0, "gpmc_be1n"=>1, "mmc1_cmd"=>2,"gpio1_31"=>7},
      :used=>0,
      :dir=>1,         #safe default: input
      :slew_rate=>1,   #slow
      :rx=>0,
      :pull=>1,        #pull-up
      :pen=>0,         #pull disabled
      :mux_mode=>7
    },
    { :name=>["p8-18","gpio2_1"],
      :modes=>{"gpmc_clk"=>0, "lcd_memory_clk"=>1, "gpmc_wait1"=>2, "mmc2_clk"=>3,"mcasp0_fsr"=>6, "gpio2_1"=>7},
      :used=>0,
      :dir=>1,         #safe default: input
      :slew_rate=>1,   #slow
      :rx=>0,
      :pull=>1,        #pull-up
      :pen=>0,         #pull disabled
      :mux_mode=>7
    },
    { :name=>["p8-7","timer4"],
      :modes=>{"gpmc_advn_ale"=>0, "timer4"=>2,"gpio2_2"=>7},
      :used=>0,
      :dir=>1,         #safe default: input
      :slew_rate=>1,   #slow
      :rx=>0,
      :pull=>1,        #pull-up
      :pen=>0,         #pull disabled
      :mux_mode=>2
    },
    { :name=>["p8-9","timer5"],
      :modes=>{"gpmc_be0n_cle"=>0, "timer5"=>2,"gpio2_5"=>7},
      :used=>0,
      :dir=>1,         #safe default: input
      :slew_rate=>1,   #slow
      :rx=>0,
      :pull=>1,        #pull-up
      :pen=>0,         #pull disabled
      :mux_mode=>2
    },
    { :name=>["p8-10","timer6"],
      :modes=>{"gpmc_wen"=>0, "timer6"=>2,"gpio2_4"=>7},
      :used=>0,
      :dir=>1,         #safe default: input
      :slew_rate=>1,   #slow
      :rx=>0,
      :pull=>1,        #pull-up
      :pen=>0,         #pull disabled
      :mux_mode=>2
    },
    { :name=>["p8-8","timer7"],
      :modes=>{"gpmc_oen_ren"=>0, "timer7"=>2,"gpio2_3"=>7},
      :used=>0,
      :dir=>1,         #safe default: input
      :slew_rate=>1,   #slow
      :rx=>0,
      :pull=>1,        #pull-up
      :pen=>0,         #pull disabled
      :mux_mode=>2
    },
    { :name=>["p8-45","gpio2_6"],
      :modes=>{"lcd_data0"=>0, "gpmc_a0"=>1, "ehrpwm2a"=>3,"gpio2_6"=>7},
      :used=>0,
      :dir=>1,         #safe default: input
      :slew_rate=>1,   #slow
      :rx=>0,
      :pull=>1,        #pull-up
      :pen=>0,         #pull disabled
      :mux_mode=>7
    },
    { :name=>["p8-46","gpio2_7"],
      :modes=>{"lcd_data1"=>0, "gpmc_a1"=>1, "ehrpwm2b"=>3,"gpio2_7"=>7},
      :used=>0,
      :dir=>1,         #safe default: input
      :slew_rate=>1,   #slow
      :rx=>0,
      :pull=>1,        #pull-up
      :pen=>0,         #pull disabled
      :mux_mode=>7
    },
    { :name=>["p8-43","gpio2_8"],
      :modes=>{"lcd_data2"=>0, "gpmc_a2"=>1, "ehrpwm2_tripzone_in"=>3,"gpio2_8"=>7},
      :used=>0,
      :dir=>1,         #safe default: input
      :slew_rate=>1,   #slow
      :rx=>0,
      :pull=>1,        #pull-up
      :pen=>0,         #pull disabled
      :mux_mode=>7
    },
    { :name=>["p8-44","gpio2_9"],
      :modes=>{"lcd_data3"=>0, "gpmc_a3"=>1, "ehrpwm0_synco"=>3,"gpio2_9"=>7},
      :used=>0,
      :dir=>1,         #safe default: input
      :slew_rate=>1,   #slow
      :rx=>0,
      :pull=>1,        #pull-up
      :pen=>0,         #pull disabled
      :mux_mode=>7
    },
    { :name=>["p8-41","gpio2_10"],
      :modes=>{"lcd_data4"=>0, "gpmc_a4"=>1, "eqep2a_in"=>3,"gpio2_10"=>7},
      :used=>0,
      :dir=>1,         #safe default: input
      :slew_rate=>1,   #slow
      :rx=>0,
      :pull=>1,        #pull-up
      :pen=>0,         #pull disabled
      :mux_mode=>7
    },
    { :name=>["p8-42","gpio2_11"],
      :modes=>{"lcd_data5"=>0, "gpmc_a5"=>1, "eqep2b_in"=>3,"gpio2_11"=>7},
      :used=>0,
      :dir=>1,         #safe default: input
      :slew_rate=>1,   #slow
      :rx=>0,
      :pull=>1,        #pull-up
      :pen=>0,         #pull disabled
      :mux_mode=>7
    },
    { :name=>["p8-39","gpio2_12"],
      :modes=>{"lcd_data6"=>0, "gpmc_a6"=>1, "eqep2_index"=>3,"gpio2_12"=>7},
      :used=>0,
      :dir=>1,         #safe default: input
      :slew_rate=>1,   #slow
      :rx=>0,
      :pull=>1,        #pull-up
      :pen=>0,         #pull disabled
      :mux_mode=>7
    },
    { :name=>["p8-40","gpio2_13"],
      :modes=>{"lcd_data7"=>0, "gpmc_a7"=>1, "eqep2_strobe"=>3,"pr1_edio_data_out7"=>4, "gpio2_13"=>7},
      :used=>0,
      :dir=>1,         #safe default: input
      :slew_rate=>1,   #slow
      :rx=>0,
      :pull=>1,        #pull-up
      :pen=>0,         #pull disabled
      :mux_mode=>7
    },
    { :name=>["p8-37","uart5_txd"],
      :modes=>{"lcd_data8"=>0, "gpmc_a12"=>1, "ehrpwm1_tripzone_in"=>2, "mcasp0_aclkx"=>3,"uart5_txd"=>4, "uart2_ctsn"=>6, "gpio2_14"=>7},
      :used=>0,
      :dir=>2,
      :slew_rate=>1,   #slow
      :rx=>0,
      :pull=>1,        #pull-up
      :pen=>0,         #pull disabled
      :mux_mode=>4
    },
    { :name=>["p8-38","uart5_rxd"],
      :modes=>{"lcd_data9"=>0, "gpmc_a13"=>1, "ehrpwm0_synco"=>2, "mcasp0_fsx"=>3,"uart5_rxd"=>4, "uart2_rtsn"=>6, "gpio2_15"=>7},
      :used=>0,
      :dir=>1,         #safe default: input
      :slew_rate=>1,   #slow
      :rx=>0,
      :pull=>1,        #pull-up
      :pen=>0,         #pull disabled
      :mux_mode=>4
    },
    { :name=>["p8-36","uart3_ctsn"],
      :modes=>{"lcd_data10"=>0, "gpmc_a14"=>1, "ehrpwm1a"=>2, "mcasp0_axr0"=>3,"uart3_ctsn"=>6, "gpio2_16"=>7},
      :used=>0,
      :dir=>1,         #safe default: input
      :slew_rate=>1,   #slow
      :rx=>0,
      :pull=>1,        #pull-up
      :pen=>0,         #pull disabled
      :mux_mode=>6
    },
    { :name=>["p8-34","uart3_rtsn"],
      :modes=>{"lcd_data11"=>0, "gpmc_a15"=>1, "ehrpwm1b"=>2, "mcasp0_ahclkr"=>3,"mcasp0_axr2"=>4, "uart3_rtsn"=>6, "gpio2_17"=>7},
      :used=>0,
      :dir=>2,
      :slew_rate=>1,   #slow
      :rx=>0,
      :pull=>1,        #pull-up
      :pen=>0,         #pull disabled
      :mux_mode=>6
    },
    { :name=>["p8-27","gpio2_22"],
      :modes=>{"lcd_vsync"=>0, "gpmc_a8"=>1,"gpio2_22"=>7},
      :used=>0,
      :dir=>1,         #safe default: input
      :slew_rate=>1,   #slow
      :rx=>0,
      :pull=>1,        #pull-up
      :pen=>0,         #pull disabled
      :mux_mode=>7
    },
    { :name=>["p8-29","gpio2_23"],
      :modes=>{"lcd_hsync"=>0, "gpmc_a9"=>1,"gpio2_23"=>7},
      :used=>0,
      :dir=>1,         #safe default: input
      :slew_rate=>1,   #slow
      :rx=>0,
      :pull=>1,        #pull-up
      :pen=>0,         #pull disabled
      :mux_mode=>7
    },
    { :name=>["p8-28","gpio2_24"],
      :modes=>{"lcd_pclk"=>0, "gpmc_a10"=>1,"gpio2_24"=>7},
      :used=>0,
      :dir=>1,         #safe default: input
      :slew_rate=>1,   #slow
      :rx=>0,
      :pull=>1,        #pull-up
      :pen=>0,         #pull disabled
      :mux_mode=>7
    },
    { :name=>["p8-30","gpio2_25"],
      :modes=>{"lcd_ac_bias_en"=>0, "gpmc_a11"=>1,"gpio2_25"=>7},
      :used=>0,
      :dir=>1,         #safe default: input
      :slew_rate=>1,   #slow
      :rx=>0,
      :pull=>1,        #pull-up
      :pen=>0,         #pull disabled
      :mux_mode=>7
    },
    { :name=>["p9-29","spi1_d0"],
      :modes=>{"mcasp0_fsx"=>0, "ehrpwm0b"=>1, "spi1_d0"=>3,"mmc1_sdcd"=>4, "gpio3_15"=>7},
      :used=>0,
      :dir=>2,
      :slew_rate=>1,   #slow
      :rx=>0,
      :pull=>1,        #pull-up
      :pen=>0,         #pull disabled
      :mux_mode=>3
    },
    { :name=>["p9-30","spi1_d1"],
      :modes=>{"mcasp0_axr0"=>0, "ehrpwm0_tripzone"=>1, "spi1_d1"=>3,"mmc2_sdcd"=>4, "gpio3_16"=>7},
      :used=>0,
      :dir=>1,         #safe default: input
      :slew_rate=>1,   #slow
      :rx=>0,
      :pull=>1,        #pull-up
      :pen=>0,         #pull disabled
      :mux_mode=>3
    },
    { :name=>["p9-28","spi1_cs0"],
      :modes=>{"mcasp0_ahclkr"=>0, "ehrpwm0_synci"=>1, "mcasp0_axr2"=>2, "spi1_cs0"=>3,"ecap2_in_pwm2_out"=>4, "gpio3_17"=>7},
      :used=>0,
      :dir=>2,
      :slew_rate=>1,   #slow
      :rx=>0,
      :pull=>1,        #pull-up
      :pen=>0,         #pull disabled
      :mux_mode=>3
    },
    { :name=>["p9-27","gpio3_19"],
      :modes=>{"mcasp0_fsr"=>0, "eqep0b_in"=>1, "mcasp0_axr3"=>2, "mcasp1_fsx"=>3,"emu2"=>4, "gpio3_19"=>7},
      :used=>0,
      :dir=>1,         #safe default: input
      :slew_rate=>1,   #slow
      :rx=>0,
      :pull=>1,        #pull-up
      :pen=>0,         #pull disabled
      :mux_mode=>7
    },
    { :name=>["p9-31","spi1_sclk"],
      :modes=>{"mcasp0_aclkx"=>0, "ehrpwm0a"=>1, "spi1_sclk"=>3,"mmc0_sdcd"=>4, "gpio3_14"=>7},
      :used=>0,
      :dir=>2,
      :slew_rate=>1,   #slow
      :rx=>0,
      :pull=>1,        #pull-up
      :pen=>0,         #pull disabled
      :mux_mode=>3
    },
    { :name=>["p9-25","gpio3_21"],
      :modes=>{"mcasp0_ahclkx"=>0, "eqep0_strobe"=>1, "mcasp0_axr3"=>2, "mcasp1_axr1"=>3,"emu4"=>4, "gpio3_21"=>7},
      :used=>0,
      :dir=>1,         #safe default: input
      :slew_rate=>1,   #slow
      :rx=>0,
      :pull=>1,        #pull-up
      :pen=>0,         #pull disabled
      :mux_mode=>7
    },
    { :name=>["p8-39","ain0"],
      :modes=>{"ain0"=>0},
      :used=>0,
      :dir=>1,         #safe default: input
      :slew_rate=>1,   #slow
      :rx=>0,
      :pull=>1,        #pull-up
      :pen=>0,         #pull disabled
      :mux_mode=>0
    },
    { :name=>["p8-40","ain1"],
      :modes=>{"ain1"=>0},
      :used=>0,
      :dir=>1,         #safe default: input
      :slew_rate=>1,   #slow
      :rx=>0,
      :pull=>1,        #pull-up
      :pen=>0,         #pull disabled
      :mux_mode=>0
    },
    { :name=>["p8-37","ain2"],
      :modes=>{"ain2"=>0},
      :used=>0,
      :dir=>1,         #safe default: input
      :slew_rate=>1,   #slow
      :rx=>0,
      :pull=>1,        #pull-up
      :pen=>0,         #pull disabled
      :mux_mode=>0
    },
    { :name=>["p8-38","ain3"],
      :modes=>{"ain3"=>0},
      :used=>0,
      :dir=>1,         #safe default: input
      :slew_rate=>1,   #slow
      :rx=>0,
      :pull=>1,        #pull-up
      :pen=>0,         #pull disabled
      :mux_mode=>0
    },
    { :name=>["p9-33","ain4"],
      :modes=>{"ain4"=>0},
      :used=>0,
      :dir=>1,         #safe default: input
      :slew_rate=>1,   #slow
      :rx=>0,
      :pull=>1,        #pull-up
      :pen=>0,         #pull disabled
      :mux_mode=>0
    },
    { :name=>["p8-36","ain5"],
      :modes=>{"ain5"=>0},
      :used=>0,
      :dir=>1,         #safe default: input
      :slew_rate=>1,   #slow
      :rx=>0,
      :pull=>1,        #pull-up
      :pen=>0,         #pull disabled
      :mux_mode=>0
    },
    { :name=>["p9-35","ain6"],
      :modes=>{"ain6"=>0},
      :used=>0,
      :dir=>1,         #safe default: input
      :slew_rate=>1,   #slow
      :rx=>0,
      :pull=>1,        #pull-up
      :pen=>0,         #pull disabled
      :mux_mode=>0
    }
  ]
}

def find_pin(context)
  pin_name=context[:arg].downcase
  context[:pin]=nil
  context[:pin_info].each do |pi|
    if(pi[:name][0]==pin_name || pi[:name][1]==pin_name)
      context[:pin]=pi
    break
    end
  end

  return context[:pin]
end

def rjustn(str,n)
  if(str.length>n)
    return str[0,n].split(//)
  end
  return str.rjust(n).split('')
end

def process_header(context)
  #puts "header line: #{context[:line]}"
  if((context[:line]=~/^(\S+)(\s+(\S.*))?$/).nil?)
    puts "*** WARNING *** Can't parse line \"#{context[:line].downcase}\""
    return
  end
  cmd=$1.downcase
  arg=$3
  #puts "Command: \"#{cmd}\""
  #puts "  Arg: \"#{arg}\"" if !arg.nil?
  
  arglen=arg.length
  if(cmd=="name")
    context[:header][:name]=rjustn(arg,32)
  elsif(cmd=="version")
    context[:header][:version]=rjustn(arg,4)
  elsif(cmd=="manufacturer")
    context[:header][:manufacturer]=rjustn(arg,16)
  elsif(cmd=="part")
    #TODO: check length
    context[:header][:part_nb]=rjustn(arg,14)
  elsif(cmd=="serial")
    context[:header][:serial_nb]=rjustn(arg,12)
  end
end

def process_current(context)
  #puts "current line: #{context[:line]}"
  if((context[:line]=~/^(\S+)(\s+(\S.*))?$/).nil?)
    puts "*** WARNING *** Can't parse line \"#{context[:line].downcase}\". Ignored."
    return
  end
  cmd=$1.downcase
  arg=$3.downcase
  #puts "Command: \"#{cmd}\""
  #puts "  Arg: \"#{arg}\"" if !arg.nil?
  
  current=0
  if(arg=~/^(\d+)ma$/)
    current=$1.to_i
  elsif(arg=~/^(\d*\.?\d+)a$/)
    current=($1.to_f*1000).to_i
  else
    puts "*** WARNING *** Can't parse current value \"#{arg}\" in line #{context[:line_nb]}. Ignored."
    return
  end
  #puts "Current: #{current}mA"
  if(current<0 || current > 0xffff)
    puts "*** WARNING *** Current value out of range in line #{context[:line_nb]}. Ignored."
    return
  end
  
  if(cmd=="3.3vdd")
    context[:current][:vdd_3v3]=current
  elsif(cmd=="5vdd")
    context[:current][:vdd_5v]=current
  elsif(cmd=="5sys")
    context[:current][:sys_5v]=current
  elsif(cmd=="supplied")
    context[:current][:supplied]=current
  else
    puts "*** WARNING *** Unknown command \"#{cmd}\" in current section in line #{context[:line_nb]}. Ignored."
  end
end

def get_mux_mode(arg,pin_info)
  mode=-1
  if(arg=~/^0*\d$/ || arg.class==Fixnum)
    pin_info[:modes].each do |k,v|
      if(v==arg.to_i)
      mode=v
      break
      end
    end
  else
    pin_info[:modes].each do |k,v|
      if(k==arg.downcase)
      mode=v
      break
      end
    end
  end
  return mode
end

def get_mux_name(arg,pin_info)
  mode=nil
  if(arg=~/^0*\d$/ || arg.class==Fixnum)
    pin_info[:modes].each do |k,v|
      if(v==arg.to_i)
        mode=k
        break
      end
    end
  else
    pin_info[:modes].each do |k,v|
      if(k==arg.downcase)
        mode=k
        break
      end
    end
  end
  return mode
end

def process_pin(context)
  #puts "pin \"#{context[:arg]}\" line: #{context[:line]}"
  pin_name=context[:arg].downcase
  pin_info=context[:pin]

  if(pin_info.nil?)
    puts "*** WARNING *** pin \"#{pin_name}\" not found. Ignored."
    return
  end

  if((context[:line].downcase=~/^(\S+)(\s+(\S.*))?$/).nil?)
    puts "*** WARNING *** Can't parse line \"#{context[:line].downcase}\". Ignored."
    return
  end
  cmd=$1
  arg=$3
  #puts "Command: #{cmd}"
  #puts "  Arg: #{arg}" if !arg.nil?

  if(cmd=="in" || cmd=="out" || cmd=="bidir" || cmd=="bdir")
    pin_info[:dir]=1 if(cmd=="in")
    pin_info[:dir]=2 if(cmd=="out")
    pin_info[:dir]=3 if(cmd=="bidir" || cmd=="bdir")
  elsif(cmd=="fast" || cmd=="slow")
    pin_info[:slew_rate]=0 if cmd=="fast"
    pin_info[:slew_rate]=1 if cmd=="slow"
  elsif(cmd=="rx")
    pin_info[:rx]=1
  elsif(cmd=="pull")
    if (arg=="up")
      pin_info[:pull]=1
    elsif (arg=="down")
      pin_info[:pull]=0 
    elsif (arg=="enable")
      pin_info[:pen]=1 
    elsif (arg=="disable" || arg=="disabled")
      pin_info[:pen]=0
    else
      puts "*** WARNING *** Unknown pull command \"#{arg}\" in line #{context[:line_nb]}."
    end
  elsif(cmd=="mux")
    mode=get_mux_mode(arg,pin_info)   
    if(mode<0)
      puts "*** WARNING *** Mode \"#{arg}\" not valid for pin \"#{context[:arg]}\" in line #{context[:line_nb]}. Ignored."
      return
    end
    #puts "pin mode #{mode}"
    pin_info[:mux_mode]=mode
  else
    puts "*** WARNING *** Unknown pin config command #{cmd}. Ignored."
  end
  
end

def process_user(context)
  #TODO implement
  puts "*** WARNING *** Processing of user content not implemented"
  #puts "user \"#{context[:arg]}\" line: #{context[:line]}"
end

def read_text_file(input_file,context)
  in_fd=nil
  begin
    in_fd=File.new(input_file,"r")
  rescue Exception=>e
    puts "*** ERROR *** Can't open \"#{input_file}\" for reading."
    exit
  end

  while(l=in_fd.gets)
    context[:line_nb]+=1
    l.chomp!
    l.sub!(/#.*$/,'')
    #  l.sub!(/^[\s]*(\S?.*\S?)[\s]*$/,'\1')
    l.sub!(/^\s*/,'')
    l.sub!(/\s*$/,'')
    #l.sub!(/^\s*(\S.*\S)?\s*$/,'\1')
    next if l.empty?
    #puts "l: \"#{l}\""

    if(l=~/^\[(.*)\]/)
      #section name
      $1.downcase.sub(/^\s*(\S.*\S)\s*$/,'\1')=~/^(\S+)(\s+(\S.*))?$/
      context[:section]=$1
      context[:arg]=$3
      #puts("section #{context[:section]} in line #{context[:line_nb]}")

      if(context[:section]!="pin" && context[:section]!="header" && context[:section] != "user" && context[:section] !="current")
        puts("*** WARNING *** Unknown section \"#{context[:section]}\" in line #{context[:line_nb]}. Skipping.")
        context[:section]="skip"
      next
      end

      if(context[:section]=='pin')
        pi=find_pin(context)
        if(pi.nil?)
          puts("*** WARNING *** Unknown pin name \"#{context[:arg]}\". Ignored.")
          context[:section]="skip"
          next
        end
        if(!pi[:defined].nil?)
          puts("*** WARNING *** Pin \"#{context[:arg]}\" redefined in line #{context[:line_nb]}. Previous definition in line #{pi[:defined]}")
        end
        #puts "processing pin #{pi[:name][0]}" 
        pi[:defined]=context[:line_nb]
        pi[:used]=1
        #puts pi[:name]
      end
    next
    end

    next if(context[:section]=="skip")
    
    #process assignment lines
    context[:line]=l
    if(context[:section].nil?)
      puts("*** WARNING *** Assignment line without section in line #{context[:line_nb]}. Skipping ")
      context[:section]="skip"
    elsif(context[:section]=="header")
      process_header(context)
    elsif(context[:section]=="current")
      process_current(context)
    elsif(context[:section]=="pin")
      process_pin(context)
    elsif(context[:section]=="user")
      process_user(context)
    else
      puts "Surprising apperance of section \"#{context[:section]}\" in line #{context[:line]}"
    end
  end
end

def count_used_pins(context)
  i=0
  j=0
  context[:pin_info].each {|pi| i+=1 if pi[:used]>0;j+=1}
  context[:pins_used]=i
  #puts "pins used: #{i} (#{j})"
  return i
end

def int16_2bytes_lsb_first(x)
  [x&0xff,(x&0xff00)>>8]
end

def int16_2bytes_msb_first(x)
  [(x&0xff00)>>8,x&0xff]
end

def bytes_lsb_first2int16(x)
  return x[0] | x[1]<<8
end

def bytes_msb_first2int16(x)
  return x[1] | x[0]<<8
end


def encode_pin_info(pi)
  pi_x=0
  if(pi[:used]>0)
    pi_x|=0x8000
    pi_x|=(pi[:dir]&0x3)<<13
    pi_x|=0x40 if pi[:slew_rate]>0
    pi_x|=0x20 if pi[:rx]>0
    pi_x|=0x10 if pi[:pull]>0
    pi_x|=0x08 if pi[:pen] ==0
    pi_x|=pi[:mux_mode] & 0x7
  end
  return int16_2bytes_msb_first(pi_x)
end

def build_binary(context)
  eeprom=[0] *  32787
  #puts eeprom.length
  eeprom[0,4]=[0xAA, 0x55, 0x33, 0xEE] # signature
  eeprom[4,2]=['A','0'] #format revision
  eeprom[6,32]=context[:header][:name][0,32]
  eeprom[38,4]=context[:header][:version][0,4]
  eeprom[42,16]=context[:header][:manufacturer][0,16]
  #TODO: Check length of part number.
  eeprom[60,14]=context[:header][:part_nb][0,14]
  count_used_pins(context)
  eeprom[74,2]=int16_2bytes_msb_first(context[:pins_used])
  eeprom[76,12]=context[:header][:serial_nb][0,12]
  
  i=88
  context[:pin_info].each do |pi|
    eeprom[i,2]=encode_pin_info(pi)
    i+=2
  end
  
  eeprom[236,2]=int16_2bytes_msb_first(context[:current][:vdd_3v3])
  eeprom[238,2]=int16_2bytes_msb_first(context[:current][:vdd_5v])
  eeprom[240,2]=int16_2bytes_msb_first(context[:current][:sys_5v])
  eeprom[242,2]=int16_2bytes_msb_first(context[:current][:supplied])
  
  (0..32543).each do |i|
    break if(i>=context[:user_content].length)
    eeprom[244+i]=context[:user_content][i]
  end
  context[:eeprom]=eeprom
  return eeprom
end

def parse_pin_binary(d,pi)
  x=bytes_msb_first2int16(d)
  pi[:used]=0
  pi[:used]=1 if x&0x8000>0
  
  if(pi[:used]>0)
    pi[:dir]=(x&0x6000)>>13
    pi[:slew_rate]=(x&0x0040) >> 6
    pi[:rx]=(x&0x0020) >> 5
    pi[:pull]=(x&0x0010) >> 4
    pi[:pen]=(x&0x0008==0)?1:0
    pi[:mux_mode]=x&0x0007
    
    if(get_mux_mode(x&0x0007,pi)<0)
      puts("*** Invalid mux mode for pin #{pi[:name][1]}")
    end
    
  end
  
end

def parse_binary(eeprom,context)
  if(eeprom[0,4]!=[0xAA, 0x55, 0x33, 0xEE].pack('C*'))
    puts "No valid eeprom image found"
    return
  end
  if(eeprom[4,2]!='A0')
    puts "Don't know how to parse eeprom format revision #{eeprom[4,2]}"
    return
  end
  
  context[:header][:name]=eeprom[6,32].split('')
  context[:header][:version]=eeprom[38,4].split('')
  context[:header][:manufacturer]=eeprom[42,16].split('')
  context[:header][:part_nb]=eeprom[60,14].split('')
  context[:header][:serial_nb]=eeprom[76,12].split('')
  
  context[:current][:vdd_3v3]=bytes_msb_first2int16(eeprom[236,2])
  context[:current][:vdd_5v]=bytes_msb_first2int16(eeprom[238,2])
  context[:current][:sys_5v]=bytes_msb_first2int16(eeprom[240,2])
  context[:current][:supplied]=bytes_msb_first2int16(eeprom[242,2])
  
  i=88
  context[:pin_info].each do |pi|
    parse_pin_binary(eeprom[i,2],pi)
    i+=2
  end
end


def save_text_file(template,output_file_name,context)
 # if(!has_erubis)
 #   puts "Erubis not supported"
 #   return
 # end

  template_fd=nil
  begin
  #  template = ERB.new(IO.readlines(template_file_name).to_s, 0, "%<>")
    template_fd = Erubis::Eruby.new(IO.readlines(template).to_s, :trim=>true)
  rescue Exception => e
    warn("Can't read template #{template}: #{e.to_s}")
    return
  end
  
  out_file=STDOUT
  if(!output_file_name.nil?)
    begin
      out_file=File.new(output_file_name,"w")
    rescue Exception=> e
      warn("Can't open file #{output_file_name} for writing: #{e.to_s}")
      exit;
    end
  end
  
  out_file.write(template_fd.result(binding))
end

def find_by_pin_name(name,context)
  pins={}
  (1..(context[:pin_info].length-1)).each do |i|
    pi=context[:pin_info][i]
    pi[:name].each do |n|
      if(n=~/#{name}/)
        pins[n]=[] if(pins[n].nil?)
        pins[n].push pi
      end
    end
  end
  return pins
end

def find_by_pin_function(function,context)
  pins={}
  (1..(context[:pin_info].length-1)).each do |i|
    pi=context[:pin_info][i]
    pi[:modes].keys.each do |m|
      if(m=~/#{function}/)
        pins[m]=[] if(pins[m].nil?)
        pins[m].push pi
      end
    end
  end
  return pins
end

opts=GetoptLong.new(
['--verbose','-v',GetoptLong::OPTIONAL_ARGUMENT],
['--input-format',GetoptLong::REQUIRED_ARGUMENT],
['--output-format',GetoptLong::REQUIRED_ARGUMENT],
['--input-file','-i',GetoptLong::REQUIRED_ARGUMENT],
['--output-file','-o',GetoptLong::REQUIRED_ARGUMENT],
['--function','-f',GetoptLong::REQUIRED_ARGUMENT],
['--name','-n',GetoptLong::REQUIRED_ARGUMENT]
)

verbose=0;
input_file_name=nil
output_file_name=nil
input_format="config"
output_format="binary"
list_name=nil
list_function=nil

opts.each do |opt,arg|
  case opt
    when '--verbose'
      verbose=arg.to_i
    when '--input-format'
      input_format=arg.downcase
    when '--output-format'
      output_format=arg.downcase.gsub(/[^a-zA-Z0-9_-]/,'')
    when '--input-file'
      input_file_name=arg
    when '--output-file'
      output_file_name=arg
    when '--function'
      list_function=arg.downcase
    when '--name'
      list_name=arg.downcase
  end
end

current_context=Marshal.load(Marshal.dump(default_context))


if(!list_name.nil?)
  x=find_by_pin_name(list_name,current_context)
  x.keys.sort.each do |n|
    printf("%s: ",n)
    x[n].each {|pi| printf("%s(%s) ",pi[:name][0],pi[:name][1])}
    printf("\n")
  end
  exit
end

if(!list_function.nil?)
  x=find_by_pin_function(list_function,current_context)
  x.keys.sort.each do |n|
    printf("%s: ",n)
    x[n].each {|pi| printf("%s(%s) ",pi[:name][0],pi[:name][1])}
    printf("\n")
  end
  exit
end

eeprom=nil
case input_format
  when 'config'
    read_text_file(input_file_name,current_context)
  when 'binary'
    eeprom=[]
    begin
      eeprom_f=File.new(input_file_name,"rb")
      eeprom=eeprom_f.read
      #while(!(b=eeprom_f.getc).nil?)
      #  eeprom.push(b)
      #end
      eeprom_f.close
    rescue Exception => e
      puts "Can't read input file \"#{input_file_name}\": #{e.to_s}."
      exit
    end
    parse_binary(eeprom,current_context)
end

eeprom_f=STDOUT
if(output_format=='binary')
  eeprom=build_binary(current_context)
  begin
    eeprom_f=File.open(output_file_name,"wb") if !output_file_name.nil?
  rescue Exception => e
    puts "Can't open output file \"#{output_file_name}\" for writing: #{e.to_s}."
    exit
  end
  begin
    (0..(eeprom.length-1)).each{|i|  eeprom_f.putc eeprom[i]}
  rescue Exception => e
    puts "Can't write to output file \"#{output_file_name}\": #{e.to_s}."
    exit
  end
  eeprom_f.close
  exit
else
  save_text_file("template/#{output_format}.tmpl",output_file_name,current_context)
end
  
  
