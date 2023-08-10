`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/06/21 14:55:49
// Design Name: 
// Module Name: top
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module top(
    input rstn,
    input [4:0] btn_i,
    input [15:0] sw_i,
    input clk,

    output [7:0] disp_an_o,
    output [7:0] disp_seg_o,

    output [15:0] led_o
    );


    wire Clk_CPU;
    wire CPU_MIO;
    wire [31:0] Data_read;
    wire mem_w;
    wire [31:0] PC_out;
    wire [31:0] spo;
    wire [31:0] Addr_out;
    wire [31:0] Data_out;
    wire [2:0] dm_ctrl;
    wire counter0_OUT;
    wire counter1_OUT;
    wire counter2_OUT;

    wire rst_i;
    wire IO_clk_i;
    wire clka0_i;

    wire [31:0] ram_data_in;
    wire [31:0] Cpu_data4bus;
    wire [31:0] Data_write_to_dm;
    wire [3:0] wea_mem;

    wire [4:0] BTN_out;
    wire [15:0] SW_out;
    wire [31:0] douta;
    wire [15:0] LED_out;
    wire [9:0] ram_addr;
    wire data_ram_we;
    wire GPIOf0000000_we;
    wire GPIOe0000000_we;
    wire counter_we;
    wire [31:0] Peripheral_in;
    wire [31:0] counter_out;

    wire [31:0] clkdiv;
    wire [7:0] point_out;
    wire [7:0] LE_out;
    wire [31:0] Disp_num;

    wire [1:0] counter_set;
    wire [15:0] led;
    wire [13:0] GPIOf0;
    wire [31:0] P_Data;

    assign rst_i = ~rstn;
    assign IO_clk_i = ~Clk_CPU;
    assign clka0_i = ~clk;

    SCPU U1_SCPU(
        .reset(rst_i),
        .clk(Clk_CPU),
        .INT(counter0_OUT),
        .MIO_ready(CPU_MIO),
        .inst_in(spo),
        .Data_in(Data_read),
        .Addr_out(Addr_out),
        .CPU_MIO(CPU_MIO),
        .Data_out(Data_out),
        .PC_out(PC_out),
        .dm_ctrl(dm_ctrl),
        .mem_w(mem_w)
    );

    ROM_D U2_ROMD(
        .a(PC_out[11:2]),
        .spo(spo)
    );

    dm_controller U3_dm_controller(
        .mem_w(mem_w),
        .dm_ctrl(dm_ctrl),
        .Data_write(ram_data_in),
        .Data_read_from_dm(Cpu_data4bus),
        .Addr_in(Addr_out),
        .Data_read(Data_read),
        .Data_write_to_dm(Data_write_to_dm),
        .wea_mem(wea_mem)
    );

    RAM_B U4_RAM_B(
        .clka(clka0_i),
        .addra(ram_addr),
        .dina(Data_write_to_dm),
        .wea(wea_mem),
        .douta(douta)
    );

    MIO_BUS U4_MIO_BUS(
        .rst(rst_i),
        .clk(clk),
        .mem_w(mem_w),
        .counter0_out(counter0_OUT),
        .counter1_out(counter1_OUT),
        .counter2_out(counter2_OUT),
        .BTN(BTN_out),
        .Cpu_data2bus(Data_out),
        .SW(SW_out),
        .addr_bus(Addr_out),
        .counter_out(counter_out),
        .led_out(LED_out),
        .ram_data_out(douta),
        .Cpu_data4bus(Cpu_data4bus),
        .GPIOe0000000_we(GPIOe0000000_we),
        .GPIOf0000000_we(GPIOf0000000_we),
        .Peripheral_in(Peripheral_in),
        .counter_we(counter_we),
        .ram_addr(ram_addr),
        .ram_data_in(ram_data_in)
    );

    Multi_8CH32 U5_Multi_8CH32(
        .rst(rst_i),
        .clk(IO_clk_i),
        .EN(GPIOe0000000_we),
        .LES({64'hffffffffffffffff}),
        .Switch(SW_out[7:5]),
        .point_in({clkdiv[31:0],clkdiv[31:0]}), // 两个 32 �?? clockdiv 拼成 64 �??
        .data0(Peripheral_in),
        .data1({2'b0,PC_out[31:2]}), //PC 的高 30 �??
        .data2(spo),
        .data3(counter_out),
        .data4(Addr_out),
        .data5(Data_out),
        .data6(Cpu_data4bus),
        .data7(PC_out),
        .Disp_num(Disp_num),
        .LE_out(LE_out),
        .point_out(point_out)
    );

    SSeg7 U6_SSeg7(
        .rst(rst_i),
        .clk(clk),
        .Hexs(Disp_num),
        .LES(LE_out),
        .SW0(SW_out),
        .flash(clkdiv[10:10]),
        .point(point_out),
        .seg_an(disp_an_o),
        .seg_sout(disp_seg_o)
    );

    SPIO U7_SPIO(
        .rst(rst_i),
        .clk(IO_clk_i),
        .EN(GPIOf0000000_we),
        .P_Data(Peripheral_in),
        .led(led_o),
        .counter_set(counter_set),
        .LED_out(LED_out)
    );

    clk_div U8_clk_div(
        .rst(rst_i),
        .clk(clk),
        .SW2(SW_out[2:2]),
        .Clk_CPU(Clk_CPU),
        .clkdiv(clkdiv)
    );

    Counter_x U9_Counter_x(
        .rst(rst_i),
        .clk(IO_clk_i),
        .clk0(clkdiv[6:6]),
        .clk1(clkdiv[9:9]),
        .clk2(clkdiv[11:11]),
        .counter_ch(counter_set),
        .counter_val(Peripheral_in),
        .counter_we(counter_we),
        .counter0_OUT(counter0_OUT),
        .counter1_OUT(counter1_OUT),
        .counter2_OUT(counter2_OUT),
        .counter_out(counter_out)
    );

    Enter U10_Enter(
        .clk(clk),
        .BTN(btn_i),
        .SW(sw_i),
        .BTN_out(BTN_out),
        .SW_out(SW_out)
    );
endmodule
