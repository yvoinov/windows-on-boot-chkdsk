# Schedule automatic disk checking and repair when Windows boots 
[![License](https://img.shields.io/badge/License-MIT--Clause-blue.svg)](https://github.com/yvoinov/windows-on-boot-chkdsk/blob/main/LICENSE)
## Motivation

The motivation for this development was the problem of workstations not connected to a clean power supply. Sudden power outages cause unnoticeable, hidden file system corruption, which isn't always automatically detected and checked by chkdsk during the subsequent boot, or the checking and repair process is canceled by the user. Multiple power outages result in a buildup of unnoticeable file system errors, which subsequently lead to software crashes and other problems.

To avoid such problems, a solution was developed similar to forcing fsck to run at every boot on Unix-like systems.

## How does this work

At each boot, a scheduled script (at boot) performs a one-time detection of all type 3 drives (local hard drives of any type assigned a drive letter, excluding optical drives, volumes without a drive letter, and Optane volumes) and runs chkdsk in read-only mode on them in the background. If errors requiring repair are detected, a forced chkdsk is scheduled in error-correction mode and an immediate automatic reboot is performed to perform the repairs.

## How to use

To use, place the script in %SystemRoot%. To create a scheduled task on boot, run the following in a command prompt with administrator privileges:
```sh
schtasks /Create /SC ONSTART /TN "CHKDSK-Boot" /TR "%SystemRoot%\autocheckfs.cmd" /RU SYSTEM /RL HIGHEST /F
```

That's all. To test the generated task, run the following in the command line:
```sh
schtasks /Query /TN "CHKDSK-Boot" /V /FO LIST
```

To run a task immediately (for example, for testing purposes), run the following from the command line:
```sh
schtasks /Run /TN "CHKDSK-Boot"
```

