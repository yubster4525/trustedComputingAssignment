# Screenshot Instructions for Part B

## Overview
You need to capture screenshots showing the execution of the TPM practical demonstration. These screenshots will be included in your final PDF submission.

---

## Prerequisites

1. **On your Linux machine**, ensure you have:
   - TPM simulator running
   - tpm2-tools installed
   - The script file: `PartB_TPM_Practical_Script.sh`

2. **Make the script executable**:
   ```bash
   chmod +x PartB_TPM_Practical_Script.sh
   ```

---

## Screenshot Checklist

You need to capture at least **8 key screenshots** covering all major steps:

### Screenshot 1: Environment Setup ✓
**What to capture**: Terminal showing TPM simulator running and environment check

**Steps**:
```bash
# Terminal 1: Start TPM simulator
tpm_server
# (Leave this running)

# Terminal 2: Set environment and verify
export TPM2TOOLS_TCTI="mssim:host=localhost,port=2321"
tpm2_getrandom 16 --hex
```

**Screenshot should show**:
- TPM simulator running in one terminal
- Environment variable set
- Random hex output from TPM

**File name**: `01_environment_setup.png`

---

### Screenshot 2: Script Start and TPM Initialization ✓
**What to capture**: Beginning of script execution showing TPM startup and clear

**Steps**:
```bash
./PartB_TPM_Practical_Script.sh
```

**Screenshot should show**:
- Script header
- STEP 0: Environment verification
- STEP 1: TPM initialization
- TPM startup and clear messages

**File name**: `02_tpm_initialization.png`

---

### Screenshot 3: Primary Key Creation ✓
**What to capture**: Primary storage key creation output

**Screenshot should show**:
- STEP 2: Create Primary Storage Key
- Key creation command
- Key attributes (RSA 2048, SHA256)
- Success message with key details

**File name**: `03_primary_key_creation.png`

---

### Screenshot 4: Initial PCR Values ✓
**What to capture**: Reading PCR values before sealing

**Screenshot should show**:
- STEP 3: Read Current PCR Values
- PCR 0, 1, 2, 3 values with SHA-256
- Hexdump of PCR values
- All PCR values (should show as zeros or initial values)

**File name**: `04_initial_pcr_values.png`

---

### Screenshot 5: Sealing Data ✓
**What to capture**: Creating sealed object with PCR policy

**Screenshot should show**:
- STEP 4: Create PCR Sealing Policy
- STEP 5: Prepare Secret Data
- STEP 6: Seal Secret Data to PCR Values
- Secret message content
- Sealed object creation success
- Files created: sealed.priv, sealed.pub

**File name**: `05_sealing_data.png`

---

### Screenshot 6: Successful Unseal ✓
**What to capture**: Unsealing with correct PCR values

**Screenshot should show**:
- STEP 7: Unseal Data with Correct PCR Values
- Unseal command execution
- Successfully unsealed secret message
- Verification that unsealed data matches original

**File name**: `06_successful_unseal.png`

---

### Screenshot 7: PCR Extension ✓
**What to capture**: Modifying PCR to simulate system change

**Screenshot should show**:
- STEP 8: Simulate System State Change
- PCR 2 value BEFORE extension
- Extension command with "MALICIOUS" data
- PCR 2 value AFTER extension (should be different)

**File name**: `07_pcr_extension.png`

---

### Screenshot 8: Failed Unseal ✓
**What to capture**: Unseal failure due to PCR mismatch

**Screenshot should show**:
- STEP 9: Attempt Unseal After PCR Modification
- Unseal command execution
- Error message showing TPM policy check failure
- Success message indicating security is working correctly

**File name**: `08_failed_unseal.png`

---

### Screenshot 9 (Optional): Summary ✓
**What to capture**: Final summary and demonstration complete

**Screenshot should show**:
- STEP 11: Summary
- Summary box with all checkmarks
- Key takeaway message
- Files created list

**File name**: `09_summary.png`

---

## How to Take Screenshots on Linux

### Using gnome-screenshot (Ubuntu/GNOME)
```bash
# Take screenshot of entire screen
gnome-screenshot

# Take screenshot of selected area
gnome-screenshot -a

# Take screenshot after 5 second delay
gnome-screenshot -d 5
```

### Using scrot (Command line)
```bash
# Install if needed
sudo apt install scrot

# Take screenshot
scrot screenshot.png

# Select area
scrot -s screenshot.png
```

### Using Spectacle (KDE)
```bash
# Install if needed
sudo apt install spectacle

# Launch
spectacle
```

### Using flameshot (Recommended - works on most distros)
```bash
# Install
sudo apt install flameshot

# Take screenshot
flameshot gui
```

---

## Tips for Good Screenshots

1. **Terminal Size**:
   - Make terminal window large enough to show full output
   - Use at least 100 columns × 30 rows
   - Check with: `echo $COLUMNS x $LINES`

2. **Font Size**:
   - Increase terminal font for readability
   - Ctrl+Shift++ to increase
   - Ensure text is readable in screenshot

3. **Clear Output**:
   - Clear terminal before each major step if needed: `clear`
   - Ensure important output is visible

4. **Timing**:
   - Take screenshot AFTER command completes
   - Capture the full output including success/error messages

5. **Naming**:
   - Use the suggested naming convention
   - Add your roll number if required: `01_environment_setup_<RollNo>.png`

---

## Running the Script in Sections (Alternative)

If you want more control for screenshots, you can run commands manually:

### Section 1: Setup
```bash
# Initialize TPM
tpm2_startup -c
tpm2_clear

# Create primary key
tpm2_createprimary -C o -g sha256 -G rsa -c primary.ctx \
  -a "restricted|decrypt|fixedtpm|fixedparent|sensitivedataorigin|userwithauth"
```

### Section 2: Read PCRs
```bash
# Read and save PCRs
tpm2_pcrread sha256:0,1,2,3
tpm2_pcrread -o pcr_0123.bin sha256:0,1,2,3
```

### Section 3: Seal Data
```bash
# Create policy
tpm2_createpolicy --policy-pcr -l sha256:0,1,2,3 \
  -f pcr_0123.bin -L pcr_policy.dat

# Create secret
echo "This is a secret password: TPM_Secure_2024!" > secret.txt

# Seal data
tpm2_create -C primary.ctx -L pcr_policy.dat -i secret.txt \
  -r sealed.priv -u sealed.pub -a "fixedtpm|fixedparent"

# Load sealed object
tpm2_load -C primary.ctx -r sealed.priv -u sealed.pub -c sealed.ctx
```

### Section 4: Unseal (Success)
```bash
# Unseal with correct PCRs
tpm2_unseal -c sealed.ctx -p pcr:sha256:0,1,2,3
```

### Section 5: Extend PCR
```bash
# Extend PCR 2
echo "MALICIOUS_BOOTKIT_CODE" | openssl dgst -sha256 -binary | xxd -p -c 64 > hash.txt
tpm2_pcrextend 2:sha256=$(cat hash.txt)

# Read modified PCR
tpm2_pcrread sha256:2
```

### Section 6: Unseal (Failure)
```bash
# Try to unseal with modified PCR
tpm2_unseal -c sealed.ctx -p pcr:sha256:0,1,2,3
# Should fail!
```

---

## After Taking Screenshots

1. **Verify Screenshots**:
   - Open each screenshot and ensure text is readable
   - Check that important output is visible
   - Retake if blurry or cut off

2. **Organize Files**:
   ```bash
   mkdir ~/tpm_assignment_screenshots
   mv *.png ~/tpm_assignment_screenshots/
   ```

3. **Prepare for PDF**:
   - You'll insert these screenshots into your final document
   - Keep original high-resolution versions
   - Can compress slightly if needed for PDF size

---

## Troubleshooting

**Problem**: Terminal text too small in screenshot
- **Solution**: Increase font size before running script
- Settings → Profile → Font size → Larger

**Problem**: Output scrolled off screen
- **Solution**: Increase terminal buffer size
- Settings → Profile → Scrollback → Increase limit
- Or run script in sections

**Problem**: Colors not showing in screenshot
- **Solution**: Use terminal with color support
- Try: gnome-terminal, konsole, or tilix

**Problem**: Screenshot tool not working
- **Solution**: Try alternative:
  - Press Print Screen key
  - Use system screenshot tool
  - Or: `import screenshot.png` (ImageMagick)

---

## What to Include in PDF

For each screenshot in your PDF, add:

1. **Caption**: Describe what the screenshot shows
   ```
   Figure 1: TPM environment setup showing simulator running and
   successful connection test with random byte generation
   ```

2. **Brief Explanation**: 1-2 sentences explaining the step
   ```
   This demonstrates the TPM 2.0 simulator is running correctly
   and responding to commands. The tpm2_getrandom command proves
   the TPM is accessible and functioning.
   ```

3. **Code Snippet**: Include the commands executed (optional)
   ```bash
   $ export TPM2TOOLS_TCTI="mssim:host=localhost,port=2321"
   $ tpm2_getrandom 16 --hex
   ```

---

## Next Steps

After you have all screenshots:
1. ✓ Review all screenshots for quality
2. ✓ Organize in numbered order
3. ✓ Prepare to insert into PDF document
4. ✓ Add captions and explanations
5. ✓ Combine with Part A theory answers

Good luck with your demonstration! 📸
