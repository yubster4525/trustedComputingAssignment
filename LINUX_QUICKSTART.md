# 🐧 Linux Machine Quick Start Guide

## Step 1: Clone the Repository

```bash
# Navigate to your home directory
cd ~

# Clone your assignment repository
git clone https://github.com/yubster4525/trustedComputingAssignment.git

# Enter the directory
cd trustedComputingAssignment

# List files to verify
ls -la
```

**You should see:**
- ✅ README.md
- ✅ All Part A answer files (4 theory files)
- ✅ PartB_TPM_Practical_Script.sh
- ✅ Setup and instruction guides

---

## Step 2: Read the README First

```bash
# Read the comprehensive guide
less README.md
# (Press 'q' to quit)

# Or open in your preferred editor
nano README.md
# Or: gedit README.md
# Or: vim README.md
```

---

## Step 3: Setup TPM Environment

```bash
# Follow the setup guide
cat 00_LINUX_SETUP.md

# Install TPM tools
sudo apt update
sudo apt install -y tpm2-tools ibmtpm1637

# Or if that doesn't work:
sudo apt install -y tpm2-tools swtpm swtpm-tools
```

---

## Step 4: Start TPM Simulator

**Terminal 1 (keep running):**
```bash
# Option A: If ibmtpm installed
tpm_server

# Option B: If using swtpm
mkdir -p /tmp/myvtpm
swtpm socket --tpmstate dir=/tmp/myvtpm \
  --tpm2 \
  --ctrl type=tcp,port=2322 \
  --server type=tcp,port=2321 \
  --flags not-need-init
```

**Terminal 2 (your working terminal):**
```bash
# Set environment variable
export TPM2TOOLS_TCTI="mssim:host=localhost,port=2321"

# Add to bashrc to make permanent (optional)
echo 'export TPM2TOOLS_TCTI="mssim:host=localhost,port=2321"' >> ~/.bashrc

# Test connection
tpm2_getrandom 16 --hex
```

If you see random hex output → ✅ **TPM is working!**

---

## Step 5: Run the Practical Script

```bash
# Make script executable
chmod +x PartB_TPM_Practical_Script.sh

# Run the script
./PartB_TPM_Practical_Script.sh
```

---

## Step 6: Take Screenshots

**Open the screenshot guide:**
```bash
cat SCREENSHOT_INSTRUCTIONS.md
```

**You need 8 screenshots:**
1. Environment setup (TPM running + random test)
2. TPM initialization
3. Primary key creation
4. Initial PCR values
5. Sealing data
6. Successful unseal
7. PCR extension
8. Failed unseal

**Screenshot tools on Linux:**
```bash
# Install if needed
sudo apt install flameshot
# Or: sudo apt install gnome-screenshot
# Or: sudo apt install spectacle  # For KDE

# Take screenshot
flameshot gui
# Or: gnome-screenshot -a
# Or: Press PrtScn key
```

---

## Step 7: Verify All Files

After running the script, you should have:

```bash
# Check all theory answers are present
ls -lh PartA_Answer*.md

# Check script exists and is executable
ls -lh PartB_TPM_Practical_Script.sh

# Check guides
ls -lh *INSTRUCTIONS* *GUIDE*
```

---

## Step 8: Create Your PDF

```bash
# Option 1: LibreOffice (recommended)
libreoffice --writer

# Option 2: Install pandoc for markdown → PDF
sudo apt install pandoc texlive-latex-base
# Then follow FINAL_PDF_GUIDE.md

# Option 3: Google Docs
# Copy content from markdown files to Google Docs
# Insert screenshots
# Download as PDF
```

---

## 🆘 Troubleshooting

### Can't connect to TPM
```bash
# Check if simulator is running
ps aux | grep tpm

# Check environment variable
echo $TPM2TOOLS_TCTI

# Should show: mssim:host=localhost,port=2321
```

### Commands not found
```bash
# Install tpm2-tools
sudo apt update
sudo apt install tpm2-tools

# Verify
which tpm2_getrandom
tpm2_getrandom --version
```

### Permission issues
```bash
# Make script executable
chmod +x PartB_TPM_Practical_Script.sh

# Check permissions
ls -l PartB_TPM_Practical_Script.sh
# Should show: -rwxr-xr-x
```

### Git issues
```bash
# Pull latest changes
git pull origin main

# Check status
git status

# See commit history
git log --oneline
```

---

## 📋 Quick Reference

**Essential Commands:**
```bash
# Start TPM simulator (Terminal 1)
tpm_server

# Set environment (Terminal 2)
export TPM2TOOLS_TCTI="mssim:host=localhost,port=2321"

# Test TPM
tpm2_getrandom 16 --hex

# Run practical script
./PartB_TPM_Practical_Script.sh

# Take screenshot
flameshot gui
```

**File Structure:**
```
trustedComputingAssignment/
├── README.md                      ← Start here!
├── 00_LINUX_SETUP.md              ← Setup guide
├── PartA_Answer1_TPM_Architecture.md
├── PartA_Answer2_Remote_Attestation.md
├── PartA_Answer3_TEE_Components.md
├── PartA_Answer4_TPM_vs_TEE.md
├── PartB_TPM_Practical_Script.sh  ← Run this!
├── SCREENSHOT_INSTRUCTIONS.md     ← Screenshot guide
└── FINAL_PDF_GUIDE.md             ← PDF creation
```

---

## ✅ Completion Checklist

- [ ] Cloned repository successfully
- [ ] Read README.md
- [ ] Installed tpm2-tools
- [ ] Started TPM simulator
- [ ] Tested TPM connection (tpm2_getrandom works)
- [ ] Made script executable
- [ ] Ran PartB_TPM_Practical_Script.sh
- [ ] Took all 8 required screenshots
- [ ] Screenshots are clear and readable
- [ ] Reviewed all Part A theory answers
- [ ] Started creating final PDF
- [ ] Added screenshots to PDF with captions
- [ ] Added all theory content to PDF
- [ ] Proofread final document
- [ ] Named file: Assignment2_<RollNo>.pdf
- [ ] Ready to submit!

---

## 🎯 Priority Order

1. **First**: Setup (TPM simulator + tools) → 30 minutes
2. **Then**: Run script + screenshots → 30 minutes
3. **Finally**: Create PDF with all content → 2-3 hours

**Total time needed: 3-4 hours**

---

## 📞 Need Help?

All detailed information is in:
- **README.md** - Complete overview
- **00_LINUX_SETUP.md** - Setup help
- **SCREENSHOT_INSTRUCTIONS.md** - Screenshot help
- **FINAL_PDF_GUIDE.md** - PDF creation help

**Repository**: https://github.com/yubster4525/trustedComputingAssignment

---

Good luck! You've got this! 🚀
