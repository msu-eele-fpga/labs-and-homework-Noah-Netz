#Lab 6: Creating a Custom Component in Platform Designer

## Overview
In this lab, we took our LED-patterns files and created a LED-patterns-avalon file that

# Lab 6 Report

## System Architecture

Our system architecture integrates the `led_patterns_avalon` component, which contains memory-mapped registers for HPS communication and FPGA logic control. The system block diagram below shows the `led_patterns_avalon` component, the HPS-to-FPGA lightweight bridge, and how the ARM CPUs access the component's registers.

![System Block Diagram](assets/Lab6_Block_Diagram.png)

---

## Register Map

### Overview

The `led_patterns_avalon` component exposes three 32-bit registers that control different aspects of the LED pattern behavior and allow communication between the HPS and FPGA. These registers are accessed through the Avalon bus using memory-mapped I/O.

### Bitfield Diagrams

Below are the bitfield diagrams for each register, showing the purpose of each bit.

#### HPS_LED_control Register (0x00)
![HPS_LED_control](assets/wavedrom.png)

#### LED_reg Register (0x01)
![LED_reg](assets/wavedrom(1).png)

#### Base_period Register (0x02)
![Base_period](assets/wavedrom(2).png)

### Address Map

| **Address** | **Register**       | **Description**                                           |
|-------------|--------------------|-----------------------------------------------------------|
| 0x00        | HPS_LED_control    | Controls whether HPS or FPGA logic controls the LEDs      |
| 0x01        | LED_reg            | Stores LED output values when in HPS control mode         |
| 0x02        | Base_period        | Sets the timing period for LED patterns                   |

---

## Platform Designer

### How did you connect these registers to the ARM CPUs in the HPS?

The registers were connected to the HPS through the Avalon Memory-Mapped interface, allowing the ARM CPUs to access the registers via the memory map. The Platform Designer generated the necessary interconnect for the HPS to communicate with the Avalon bus.

### What is the base address of your component in your Platform Designer system?

The base address of the `led_patterns_avalon` component in the Platform Designer system is `0x0000_0000` to `0x0000_000F`

