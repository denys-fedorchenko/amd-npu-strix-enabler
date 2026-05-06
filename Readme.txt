# AMD Ryzen AI NPU Enabler (Ubuntu 26.04)

> [!CAUTION]
> **CRITICAL DEPENDENCY: PYTHON 3.14**
> The XRT v2.23.0 binaries are compiled specifically for the **Python 3.14** binary interface.
> Using Conda environments with Python 3.13 or older will result in a `ModuleNotFoundError` for `pyxrt`.
>
> **Solution**: Use the system `/usr/bin/python3` or create a dedicated environment: `conda create -n npu python=3.14`.

---

## 🖥️ System Requirements
* **Hardware**: AMD Ryzen processor with integrated NPU (Zen 5 / Ryzen AI 7 350 / Krackan).
* **OS**: Ubuntu 24.04 / 26.04 LTS (Kernel 6.8 - 7.0+).
* **Dependencies**: Local XRT v2.23.0 archives placed in the `src/` folder.

---

## 🚀 Core Logic & Architecture
This toolkit implements a **Zero-Conflict SRE Architecture** for environments where official XRT support is not yet upstreamed.

### 1. Compatibility Layer (Dummy Package)
To bypass library versioning locks on Ubuntu 26.04, the script generates an `xrt-base-dummy` package:
* Registers as a virtual dependency to satisfy the plugin manager.
* Allows the package manager to satisfy plugin installation requirements.
* Prevents the NPU driver stack from being purged during `apt upgrade`.

### 2. Direct Deployment (Bypass Mode)
Instead of risking a broken `libc` or `boost` state, XRT binaries are deployed via **Portable Extraction**:
* Extracted directly into `/opt/xilinx/xrt/` to isolate the NPU runtime from system libraries.

### 3. Permissions & Memory Limits
* **UDEV Rules**: Grants access to `/dev/accel/accel0` with `0666` permissions to ensure non-root operation.
* **Memory Limits**: Removes `memlock` restrictions (set to unlimited), critical for stable DMA/mmap operations during AI workloads.

---

## 📦 Installation
1. Ensure `install.sh`, `uninstall.sh`, and the `src/` folder are in the same directory.
2. Run the deployment:

```bash
chmod +x install.sh

Bash
￼￼
./install.sh
REBOOT is mandatory to apply kernel module parameters and memory limits.

🔍 Verification & FAQ
Device Check
Bash
￼￼
# View hardware status
xrt-smi examine
Python 3.14 API Test
Bash
￼￼
/usr/bin/python3 -c "import pyxrt; print(f'NPU Active: {pyxrt.device(0).get_info(pyxrt.xrt_info_device.name)}')"

FAQ
Q: Why was "Autocomplete not enabled" shown during setup?
A: This is a non-critical shell warning regarding XRT shell completions. The installer now suppresses this to ensure a clean terminal experience.

Q: Is the driver kernel-persistent?
A: Yes. The amdxdna module is registered via DKMS, meaning it will automatically recompile during Linux kernel updates.

Q: How do I access the NPU without sudo?
A: The installer automatically configures udev rules and user permissions. If access is denied, ensure your user is in the render or video group.
