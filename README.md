# **Morpheus Installer for Linux**

This repository contains a shell script (`install.sh`) that automates the installation of Morpheus on Linux machines. It fetches the necessary files from this repository and installs them in just a simple step.

---

## **Features**
- Downloads required files directly from this repository.
- Sets up Morpheus with minimal user input.
- Supports custom configurations through two user-provided arguments.

---

## **Usage**

To install the process, follow these steps:

### **Step 1: Run the Installation Command**

Run the following one-liner command, replacing `<arg1>` and `<arg2>` with the appropriate values for your use case:

```bash
curl -sL https://raw.githubusercontent.com/Scale42/Morpheus_Software_Linux/refs/heads/main/install.sh | bash -s <arg1> <arg2>

Arguments
The install.sh script requires two arguments:
1. <arg1> is the Site id.
2. <arg2> is the client id.
