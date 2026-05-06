# AMD Ryzen AI NPU Enabler (Ubuntu 26.04)

> [!CAUTION]
> **CRITICAL DEPENDENCY: PYTHON 3.14**
> The XRT v2.23.0 binaries are compiled specifically for the **Python 3.14** binary interface.
> Using Conda environments with Python 3.13 or older will result in a `ModuleNotFoundError` for `pyxrt`.

## 🖥️ System Requirements
* **Hardware**: AMD Ryzen processor with integrated NPU (Zen 5 / Ryzen AI 7 350 / Krackan).
* **OS**: Ubuntu 24.04 / 26.04 LTS (Kernel 6.8 - 7.0+).
* **Dependencies**: Local XRT v2.23.0 archives placed in the src/ folder.

## 🚀 Core Logic & Architecture
This toolkit implements a **Zero-Conflict SRE Architecture**:
1. **Compatibility Layer**: Generates an xrt-base-dummy package to satisfy apt dependencies and prevent purges during upgrade.
2. **Direct Deployment**: Portable extraction into /opt/xilinx/xrt/ to isolate the NPU runtime from system libraries.
3. **Permissions**: UDEV rules set /dev/accel/accel0 to 0666 for non-root operation and removes memlock limits.

## 📦 Installation & Usage
1. Ensure install.sh, uninstall.sh, and the src/ folder are in the same directory.
2. Run the deployment:
   chmod +x install.sh
   ./install.sh

*REBOOT is mandatory to apply kernel module parameters and memory limits.*

## 🔍 Verification
View hardware status:
xrt-smi examine

Python 3.14 API Test:
/usr/bin/python3 -c "import pyxrt; print(f'NPU Active: {pyxrt.device(0).get_info(pyxrt.xrt_info_device.name)}')"

## 🇺🇦 Support & Credits
This project was developed in Ukraine 🇺🇦 — where technical freedom and innovation drive our resilience.

If this toolkit saved your time or enabled your research, please consider supporting the defenders of this freedom:

* **[Птахи Мадяра (Robert Brovdi Foundation)](https://magyarbirds.army/)** — Direct support for advanced aerial reconnaissance and drone systems.

---
*Freedom is a technical requirement.*
