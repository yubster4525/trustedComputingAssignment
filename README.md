# Assignment 2: Trusted Computing - TPM and TEE
## Complete Assignment Package

---

## 📋 Overview

This package contains everything you need to complete Assignment 2 on Trusted Computing, covering both theoretical and practical aspects of TPM (Trusted Platform Module) and TEE (Trusted Execution Environment).

**Total Marks**: 20 (Part A: 10 marks, Part B: 10 marks)

---

## 📁 Files in This Package

### Setup and Instructions
1. **README.md** (this file) - Overview and quick start guide
2. **00_LINUX_SETUP.md** - Linux environment setup instructions
3. **SCREENSHOT_INSTRUCTIONS.md** - Detailed guide for taking screenshots
4. **FINAL_PDF_GUIDE.md** - Instructions for compiling the final PDF

### Part A: Theory Answers (10 marks)
5. **PartA_Answer1_TPM_Architecture.md** - Question 1: TPM Architecture and PCRs
6. **PartA_Answer2_Remote_Attestation.md** - Question 2: TPM Remote Attestation
7. **PartA_Answer3_TEE_Components.md** - Question 3: TEE Components (TrustZone & SGX)
8. **PartA_Answer4_TPM_vs_TEE.md** - Question 4: TPM vs TEE Comparison

### Part B: Practical Tasks (10 marks)
9. **PartB_TPM_Practical_Script.sh** - Complete bash script for all practical tasks

---

## 🚀 Quick Start Guide

### Step 1: Switch to Linux Machine
```bash
# You mentioned you have a Linux machine - switch to it now
# All practical work must be done on Linux
```

### Step 2: Setup TPM Environment
```bash
# Follow the setup guide
cat 00_LINUX_SETUP.md

# Key commands:
sudo apt update
sudo apt install -y tpm2-tools ibmtpm1637

# Start TPM simulator in one terminal:
tpm_server

# In another terminal:
export TPM2TOOLS_TCTI="mssim:host=localhost,port=2321"
```

### Step 3: Run Practical Demonstration
```bash
# Make script executable
chmod +x PartB_TPM_Practical_Script.sh

# Run the script
./PartB_TPM_Practical_Script.sh

# Follow SCREENSHOT_INSTRUCTIONS.md to capture screenshots as the script runs
```

### Step 4: Compile Final PDF
```bash
# Use the theory answers and your screenshots
# Follow FINAL_PDF_GUIDE.md for detailed instructions

# Quick method using LibreOffice:
# 1. Open LibreOffice Writer
# 2. Copy content from PartA_Answer*.md files
# 3. Add your screenshots from Part B
# 4. Export as PDF: Assignment2_<YourRollNo>.pdf
```

---

## 📚 Part A: Theory Questions

### Question 1: TPM Architecture and PCRs
**File**: `PartA_Answer1_TPM_Architecture.md`

**Coverage**:
- Internal architecture of TPM 2.0
- Root of Trust components (CRTM, RTS, RTR)
- Cryptographic engine and memory architecture
- Platform Configuration Registers (PCRs)
- Measured boot process with detailed examples
- PCR extend operation and hash chains
- Use cases: sealed storage, remote attestation

**Length**: ~15 pages
**Key Concepts**: TPM architecture, PCR extend, measured boot, hash chains

---

### Question 2: TPM Remote Attestation
**File**: `PartA_Answer2_Remote_Attestation.md`

**Coverage**:
- Complete remote attestation protocol
- Endorsement Key (EK) and Attestation Identity Key (AIK)
- Quote generation and verification
- Step-by-step attestation flow with code examples
- Real-world use case: Azure Cloud VM attestation
- Security properties: authenticity, integrity, freshness, privacy
- Practical implementation details

**Length**: ~18 pages
**Key Concepts**: Remote attestation, AIK, quote, nonce, Azure attestation

---

### Question 3: TEE Components
**File**: `PartA_Answer3_TEE_Components.md`

**Coverage**:
- ARM TrustZone architecture in detail
  - Secure World vs Normal World
  - Secure Monitor and world switching
  - TrustZone Address Space Controller (TZASC)
  - Trusted OS and Trusted Applications
  - Operational flow: secure payment example
- Intel SGX architecture in detail
  - Enclave architecture and EPC
  - Memory Encryption Engine (MEE)
  - SGX instructions (EENTER, EEXIT, etc.)
  - MRENCLAVE measurement
  - Operational flow: confidential ML inference
- Comparison between TrustZone and SGX

**Length**: ~22 pages
**Key Concepts**: TrustZone, SGX, Secure World, Enclave, MEE, Secure Monitor

---

### Question 4: TPM vs TEE Comparison
**File**: `PartA_Answer4_TPM_vs_TEE.md`

**Coverage**:
- Trust boundary analysis (physical vs logical)
- Execution context comparison (processing power, capabilities)
- Use case analysis with specific scenarios
- When to use TPM vs TEE vs both
- Strengths and weaknesses of each technology
- Selection criteria and decision matrix
- Real-world applications

**Length**: ~16 pages
**Key Concepts**: Trust boundaries, execution context, use case selection

---

## 🔧 Part B: Practical Tasks

### Overview
The practical script demonstrates all required tasks:

1. ✅ **Create TPM Key**: Primary storage key creation in owner hierarchy
2. ✅ **Seal Data**: Seal secret data to PCR values with policy
3. ✅ **Unseal Successfully**: Unseal when PCRs match
4. ✅ **Demonstrate Failure**: Show unseal failure after PCR modification

### Script Features
- **Color-coded output** for easy reading
- **Step-by-step progress** with clear headers
- **Automatic verification** of results
- **Detailed logging** of all operations
- **Educational comments** explaining each step

### Running the Script

```bash
# Make executable
chmod +x PartB_TPM_Practical_Script.sh

# Run with TPM simulator already started
./PartB_TPM_Practical_Script.sh
```

### Expected Output Sections
1. Environment verification
2. TPM initialization
3. Primary key creation
4. PCR reading
5. PCR policy creation
6. Data sealing
7. Successful unsealing
8. PCR extension (system state change)
9. Failed unsealing
10. Summary

### Screenshot Requirements
You need **at least 8 screenshots** showing:
1. Environment setup
2. TPM initialization
3. Primary key creation
4. Initial PCR values
5. Sealing data
6. Successful unseal
7. PCR extension
8. Failed unseal

**Detailed instructions**: See `SCREENSHOT_INSTRUCTIONS.md`

---

## 📖 Creating Your Final PDF

### Required Document Structure

```
Assignment2_<RollNo>.pdf
│
├── Title Page (your details)
│
├── Part A: Theory (40-45 pages)
│   ├── Question 1: TPM Architecture (~15 pages)
│   ├── Question 2: Remote Attestation (~18 pages)
│   ├── Question 3: TEE Components (~22 pages)
│   └── Question 4: TPM vs TEE (~16 pages)
│
└── Part B: Practical (15-20 pages)
    ├── Introduction & Setup (~2 pages)
    ├── Task 1: Create Key (~2 pages with screenshots)
    ├── Task 2: Seal Data (~4 pages with screenshots)
    ├── Task 3: Unseal Success (~3 pages with screenshots)
    ├── Task 4: Unseal Failure (~3 pages with screenshots)
    └── Conclusion (~1-2 pages)

Total: 55-65 pages
```

### Recommended Approach

**Option 1: LibreOffice Writer** (Easiest)
1. Open LibreOffice Writer
2. Create title page
3. Copy-paste content from `PartA_Answer*.md` files
4. Insert screenshots where indicated
5. Format nicely
6. Export as PDF

**Option 2: LaTeX** (Most Professional)
- See `FINAL_PDF_GUIDE.md` for LaTeX template
- Professional formatting
- Better for technical documents

**Option 3: Pandoc** (Automated)
- Combine markdown files
- Convert directly to PDF
- Fast but less control

**Detailed instructions**: See `FINAL_PDF_GUIDE.md`

---

## ✅ Submission Checklist

### Before Submitting
- [ ] All 4 theory questions answered completely
- [ ] All practical tasks completed with screenshots
- [ ] Screenshots are clear and readable
- [ ] All screenshots have captions
- [ ] Code snippets are properly formatted
- [ ] Document is well-organized with proper headings
- [ ] Page numbers added (except title page)
- [ ] Your name and roll number on title page
- [ ] References included where appropriate
- [ ] File named correctly: `Assignment2_<RollNo>.pdf`
- [ ] PDF opens correctly and all pages visible
- [ ] File size reasonable (<20MB)
- [ ] Proofread for spelling/grammar errors

### Quality Check
- [ ] Technical accuracy verified
- [ ] All commands shown are correct
- [ ] Explanations match the screenshots
- [ ] No factual errors
- [ ] Professional presentation

---

## 📊 Grading Rubric (Estimated)

### Part A: Theory (10 marks)
- **Question 1** (2.5 marks): TPM architecture, PCRs, measured boot
- **Question 2** (2.5 marks): Remote attestation protocol, use case
- **Question 3** (2.5 marks): TEE components, TrustZone, SGX
- **Question 4** (2.5 marks): Comparison, use cases, analysis

**Criteria**:
- Completeness (40%): All aspects covered
- Technical accuracy (30%): Correct information
- Depth of understanding (20%): Beyond surface level
- Presentation (10%): Clear, well-organized

### Part B: Practical (10 marks)
- **Setup & Key Creation** (2 marks): Environment, primary key
- **Sealing Data** (3 marks): PCR policy, sealed object
- **Successful Unseal** (2 marks): Demonstration, verification
- **Failed Unseal** (2 marks): PCR change, failure demonstration
- **Documentation** (1 mark): Screenshots, explanations

**Criteria**:
- Correctness (40%): Tasks completed successfully
- Screenshots (25%): Clear, well-annotated
- Explanation (25%): Understanding demonstrated
- Presentation (10%): Professional documentation

---

## 🎯 Tips for Success

### Part A (Theory)
1. **Don't just copy-paste**: Understand the content
2. **Add diagrams**: Visual aids improve scores
3. **Use examples**: Concrete scenarios demonstrate understanding
4. **Cite sources**: Shows research and credibility
5. **Proofread**: Eliminate errors

### Part B (Practical)
1. **Test thoroughly**: Run the script multiple times
2. **Clear screenshots**: Readable text is crucial
3. **Annotate well**: Explain what each screenshot shows
4. **Show understanding**: Don't just show commands, explain why
5. **Professional formatting**: Clean, organized presentation

### General
1. **Start early**: Don't wait until the last minute
2. **Ask questions**: If confused, clarify with instructor
3. **Backup frequently**: Save multiple versions
4. **Test PDF**: Open on different devices to verify

---

## ⏱️ Time Management

### Suggested Schedule

**Day 1-2: Theory (8-10 hours)**
- Read and understand all four answers
- Make any needed additions or modifications
- Create any additional diagrams

**Day 3: Practical Setup (2-3 hours)**
- Set up Linux environment
- Install TPM simulator and tools
- Test the practical script
- Practice taking screenshots

**Day 4: Practical Execution (3-4 hours)**
- Run the script carefully
- Take all required screenshots
- Verify all outputs
- Organize screenshots

**Day 5: Documentation (4-5 hours)**
- Create the PDF document
- Add all content and screenshots
- Format professionally
- Proofread thoroughly

**Day 6: Review & Submit (2-3 hours)**
- Final quality check
- Test PDF on different device
- Get feedback if possible
- Submit

**Total: 19-25 hours over 6 days**

---

## ❓ Troubleshooting

### Problem: Can't connect to TPM

**Solution**:
```bash
# Check if simulator is running
ps aux | grep tpm_server

# Verify environment variable
echo $TPM2TOOLS_TCTI

# Should output: mssim:host=localhost,port=2321
```

### Problem: Commands not found

**Solution**:
```bash
# Install tpm2-tools
sudo apt install tpm2-tools

# Verify installation
which tpm2_getrandom
tpm2_getrandom --version
```

### Problem: Permission denied on script

**Solution**:
```bash
# Make executable
chmod +x PartB_TPM_Practical_Script.sh

# Verify
ls -l PartB_TPM_Practical_Script.sh
# Should show: -rwxr-xr-x
```

### Problem: Screenshots not clear

**Solution**:
- Increase terminal font size: Ctrl+Shift++
- Use higher resolution
- Don't scale down too much in document
- Retake if necessary

### Problem: PDF too large

**Solution**:
```bash
# Compress PDF
gs -sDEVICE=pdfwrite -dCompatibilityLevel=1.4 \
   -dPDFSETTINGS=/ebook -dNOPAUSE -dQUIET -dBATCH \
   -sOutputFile=compressed.pdf original.pdf
```

---

## 📞 Support

If you encounter issues:

1. **Check the specific guide**:
   - Setup issues → `00_LINUX_SETUP.md`
   - Screenshot help → `SCREENSHOT_INSTRUCTIONS.md`
   - PDF creation → `FINAL_PDF_GUIDE.md`

2. **Review the script**:
   - The bash script has detailed comments
   - Each step is explained

3. **Verify your environment**:
   - TPM simulator running?
   - Environment variable set?
   - tpm2-tools installed?

---

## 🎓 Learning Outcomes

After completing this assignment, you will understand:

✅ TPM internal architecture and components
✅ How PCRs enable measured boot
✅ Remote attestation protocols and applications
✅ TEE architectures (ARM TrustZone and Intel SGX)
✅ Differences between TPM and TEE
✅ Practical TPM operations (key creation, sealing, unsealing)
✅ PCR-based access control mechanisms
✅ Real-world security applications

---

## 📄 License & Attribution

This assignment package was created to help students understand and complete their Trusted Computing assignment. The content is based on:

- TCG TPM 2.0 specifications
- ARM TrustZone documentation
- Intel SGX technical papers
- Academic research papers
- Industry best practices

All code examples are provided for educational purposes.

---

## 🎉 Good Luck!

You have everything you need to complete an excellent assignment. Follow the guides, take your time, and demonstrate your understanding of these important security technologies.

**Remember**: This is about learning, not just completing. Take time to understand the concepts, not just copy the content.

---

**Last Updated**: November 2025
**Assignment**: Trusted Computing - TPM and TEE
**Course**: [Your Course Name]
**Institution**: [Your Institution]
