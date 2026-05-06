# AMD XDNA NPU Enabler (Strix Point / Krackan) for Ubuntu 26.04

![Status](https://img.shields.io/badge/Status-Validated-brightgreen)
![OS](https://img.shields.io/badge/OS-Ubuntu%2026.04%20LTS-orange)

This is the first public repository providing validated drivers and runtime for **AMD NPU (NPU 4, aie2p)** on Ubuntu 26.04 LTS.

## 🇺🇦 Support Ukraine
This project was developed in Ukraine. If this helps you, please consider supporting:
* [Come Back Alive Foundation](https://savelife.in.ua/en/donate-en/)
* [Direct Monobank Jar](https://send.monobank.ua/XXXXX)

## 🚀 Current Milestones
- Driver: amdxdna v0.11.0
- XRT: v2.23.0 (GLIBC 2.43)
- Performance: 4.3 TOPS GEMM

## 📦 Installation
Download `.deb` packages from the Releases section.
```bash
sudo dpkg -i amdxdna-driver-strix.deb
sudo dpkg -i xrt-runtime-2.23.deb
