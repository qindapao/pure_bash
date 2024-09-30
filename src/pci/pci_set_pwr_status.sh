. ./meta/meta.sh
((DEFENSE_VARIABLES[pci_set_pwr_status]++)) && return 0
#                          │3│3│2│2│2│2│2│2│2│2│2│2│1│1│1│1│1│1│1│1│1│1│ │ │ │ │ │ │ │ │ │ │           
#                          │1│0│9│8│7│6│5│4│3│2│1│0│9│8│7│6│5│4│3│2│1│0│9│8│7│6│5│4│3│2│1│0│Byte Offset
#                          ├─┴─┴─┴─┴─┴─┴─┴─┴─┴─┴─┴─┴─┴─┴─┴─┼─┴─┴─┴─┴─┴─┴─┴─┼─┴─┴─┴─┴─┴─┴─┴─┤           
#                          │Power Management Capabilities  │Next Capability│     Capability│           
#                          │(PMC)                          │Pointer        │     ID        │ +000h     
#                          │ │ │ │ │ │ │ │ │ │ │ │ │ │ │ │ │ │ │ │ │ │ │ │ │ │ │ │ │ │ │ │ │           
#                          ├─┴─┴─┴─┴─┴─┴─┴─┼─┴─┴─┴─┴─┴─┴─┴─┼─┴─┴─┴─┴─┴─┴─┴─┴─┴─┴─┴─┴─┴─┴─┴─┤           
#                          │   Data        │  Reserved     │Power management Control/Status│           
#                          │               │               │(PMCSR)                        │ +004h     
#                          │ │ │ │ │ │ │ │ │ │ │ │ │ │ │ │ │ │ │ │ │ │ │ │ │ │ │ │ │ │ │ │ │           
#                          ╰─┴─┴─┴─┴─┴─┴─┴─┴─┴─┴─┴─┴─┴─┴─┴─┴─┴─┴─┴─┴─┴─┴─┴─┴─┴─┴─┴─┴─┴─┴─┴─╯           
#                                   Figure 7-7 Power management Capability Structure                   
#      
#      
#      
#                          232221        1615141312     9 8 7     4 3 2 1 0
#                          ╭───────────────────────────────────────────────╮
#                          │ │ │ │ │ │ │ │ │ │ │ │ │ │ │ │ │ │ │ │ │ │ │ │ │
#                          ╰┬┴┬┴─┴─┴─┴─┴─┴─┼─┼─┴─┼─┴─┴─┴─┼─┼─┴─┴─┴─┴─┼─┼─┴─┤
#       Bus Power/Clock     │ │  RsvdP     │ │   │       │ │         │ │   │                 ╭──────────────╮
#       Control Enable  ────╯ │            ╰┬┴─┬─┴──┬────┴┬╯         ╰┬┴─┬─╯                 │ 00:D0        │
#                             │             │  │    │     │           │  ╰────PowerState─────│              │
#                             │             │  │    │    PME_EN       │                      │              │
#                       B2/B3 Support       │  │   Data_Select        RsvdP                  ╰──────────────╯
#                                           │  Data_Scale
#                                           PME_Status
#                          PCIE4.0 Figure 7-8 Power Management Control/Status Register
#
#
#       Capabilities: [b0] Power Management version 3                                     
#               Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA PME(D0+,D1+,D2+,D3hot+,D3cold+)
#               Status: D3 NoSoftRst+ PME-Enable- DSel=0 DScale=0 PME-
#  
#  
#       root# lspci -vv -s 00:00.0 | grep -i "Power Management"
#               Capabilities: [b0] Power Management version 3
#       root# lspci -xxx -s 00:00.0
#       00:00.0 PCI bridge: Huawei Technologies Co., Ltd. HiSilicon PCIe Root Port with Gen4 (rev 21)
#       00: e5 19 20 a1 47 01 10 00 21 00 04 06 08 00 01 00
#       10: 00 00 00 00 00 00 00 00 00 01 0c 00 f1 01 00 20
#       20: 00 f2 f0 f3 01 40 f1 7f 00 08 00 00 00 08 00 00
#       30: ff ff 00 00 40 00 00 00 00 00 00 00 ff 01 03 00
#       40: 10 80 42 01 21 80 00 00 37 29 0f 00 84 f0 7b 00
#       50: 08 00 44 30 00 00 50 00 c8 01 48 01 10 00 01 00
#       60: 00 00 00 00 ef 13 73 00 09 00 00 00 1e 1e 8f 01
#       70: 04 00 01 00 00 00 00 00 00 00 00 00 00 00 00 00
#       80: 05 b0 8a 03 00 00 00 00 00 00 00 00 00 01 00 00
#       90: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
#       a0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
#       b0: 01 d0 03 f8(0a)00 00 00 00 00 00 00 00 00 00 00
#       c0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
#       d0: 0d 00 00 00 e5 19 1e 37 00 00 00 00 00 00 00 00
#       e0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
#       f0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
#       
#       root# setpci -s 00:00.0 b4.w=8
#       root#
pci_set_pwr_status ()
{
    local set_value=$1
    shift
    local pci_bdfs=("${@}")
    local bdf

    for bdf in "${pci_bdfs[@]}" ; do
        setpci -s "$bdf" b4.w="$set_value"
    done
}

alias pci_set_pwr_status_d0='pci_set_pwr_status 0x8'

return 0

