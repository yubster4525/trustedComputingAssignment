# TPM Setup Guide for Linux

## Step 1: Install TPM Simulator and Tools

Open your terminal on Linux and run:

```bash
# Update package list
sudo apt update

# Install TPM2 tools
sudo apt install -y tpm2-tools

# Install IBM TPM 2.0 Simulator
sudo apt install -y ibmtpm1637

# Alternative: Install software TPM
sudo apt install -y swtpm swtpm-tools libtpms-dev
```

## Step 2: Verify Installation

```bash
# Check tpm2-tools version
tpm2_getrandom --version

# Should show version 5.x or higher
```

## Step 3: Start TPM Simulator

### Option A: Using IBM TPM Simulator (Recommended)

```bash
# Create directory for simulator
mkdir -p ~/tpm_simulator
cd ~/tpm_simulator

# Download IBM TPM Simulator if not installed via apt
wget https://sourceforge.net/projects/ibmswtpm2/files/ibmtpm1661.tar.gz
tar -xvf ibmtpm1661.tar.gz
cd src
make

# Start the simulator (keep this terminal open)
./tpm_server
```

### Option B: Using swtpm (Alternative)

```bash
# Create state directory
mkdir -p /tmp/myvtpm

# Start TPM 2.0 socket (keep this terminal open)
swtpm socket --tpmstate dir=/tmp/myvtpm \
  --tpm2 \
  --ctrl type=tcp,port=2322 \
  --server type=tcp,port=2321 \
  --flags not-need-init
```

## Step 4: Configure Environment

Open a **NEW terminal** and set the TPM connection:

```bash
# Set environment variable (add to ~/.bashrc for persistence)
export TPM2TOOLS_TCTI="mssim:host=localhost,port=2321"

# Test connection
tpm2_startup -c
tpm2_getrandom 16 --hex
```

If you see random hex output, you're ready to go!

## Troubleshooting

**Error: "Could not connect to TPM"**
- Make sure the TPM simulator is running in another terminal
- Check the port is correct (2321)

**Error: "TPM not initialized"**
- Run: `tpm2_startup -c`
- Then try again

**Permission denied errors**
- May need to run simulator with sudo on some systems

## Ready for Part B

Once you see the random hex output, you're all set!
Proceed to run the Part B practical script.
