# Final PDF Compilation Guide

## Document Structure

Your final submission should be a single PDF file with the following structure:

```
Assignment2_<RollNo>.pdf
├── Title Page
├── Table of Contents (optional)
├── Part A: Theory Questions (10 marks)
│   ├── Question 1: TPM Architecture and PCRs
│   ├── Question 2: TPM Based Attestation
│   ├── Question 3: TEE Components
│   └── Question 4: TPM vs TEE
└── Part B: Practical Tasks (10 marks)
    ├── Introduction
    ├── Setup and Environment
    ├── Task 1: Create TPM Key
    ├── Task 2: Seal Data
    ├── Task 3: Unseal Data (Success)
    ├── Task 4: Demonstrate Unseal Failure
    └── Conclusion
```

---

## Title Page Template

```
┌─────────────────────────────────────────────────────────┐
│                                                         │
│                   [Your College Logo]                   │
│                                                         │
│              Assignment 2: Trusted Computing            │
│           TPM Architecture and Practical Tasks          │
│                                                         │
│                                                         │
│                      Submitted by:                      │
│                    [Your Full Name]                     │
│                   Roll No: [Your Roll]                  │
│                                                         │
│                                                         │
│                    Submitted to:                        │
│                 [Instructor's Name]                     │
│                [Department Name]                        │
│                                                         │
│                                                         │
│                   Date: [DD/MM/YYYY]                    │
│                                                         │
└─────────────────────────────────────────────────────────┘
```

---

## Part A: Theory Answers

### Structure for Each Question:

```
Question X: [Question Text]
─────────────────────────────────────────────────────

[Your comprehensive answer from the provided markdown files]

• Use proper headings and subheadings
• Include diagrams where mentioned
• Use tables for comparisons
• Add references at the end of each answer
```

### Content Files to Use:

1. **Question 1**: Use `PartA_Answer1_TPM_Architecture.md`
   - Copy the entire content
   - Consider adding simple diagrams for:
     - TPM block diagram
     - PCR extend operation
     - Measured boot flow

2. **Question 2**: Use `PartA_Answer2_Remote_Attestation.md`
   - Copy the entire content
   - Diagrams already included in text format
   - Consider converting ASCII diagrams to proper flowcharts

3. **Question 3**: Use `PartA_Answer3_TEE_Components.md`
   - Copy the entire content
   - Multiple architecture diagrams included
   - Consider enhancing with actual architecture images

4. **Question 4**: Use `PartA_Answer4_TPM_vs_TEE.md`
   - Copy the entire content
   - Tables already formatted
   - Clear comparison structure

---

## Part B: Practical Tasks

### Section Structure:

#### 1. Introduction (½ page)

```markdown
# Part B: TPM-Based Secure Key Storage Simulation

## Objective
This practical demonstration showcases the capabilities of TPM 2.0 for
secure key storage and data sealing using Platform Configuration Registers
(PCRs). The experiment demonstrates how data can be cryptographically
bound to system state, preventing access when the platform configuration
changes.

## Tools Used
- **TPM Simulator**: IBM TPM 2.0 Simulator / swtpm
- **Software**: tpm2-tools suite (version X.X)
- **Platform**: Linux Ubuntu XX.XX
- **Environment**: TPM Software Simulator over TCP/IP

## Experimental Setup
[Brief description of your setup]
```

#### 2. Setup and Environment (~1 page)

```markdown
## Environment Setup

### Starting the TPM Simulator
[Explanation of how you set up the TPM simulator]

### Verification
[Include Screenshot 1: Environment Setup]

Figure 1: TPM simulator initialization and connection verification

[2-3 sentences explaining what the screenshot shows]
```

#### 3. Task 1: Create TPM Key (~2 pages)

```markdown
## Task 1: Creating TPM Primary Storage Key

### Procedure
1. Initialize TPM with startup command
2. Clear TPM to factory state
3. Create primary key in owner hierarchy

### Commands Executed
```bash
# Initialize TPM
tpm2_startup -c

# Clear TPM
tpm2_clear

# Create primary storage key
tpm2_createprimary -C o -g sha256 -G rsa -c primary.ctx \
  -a "restricted|decrypt|fixedtpm|fixedparent|sensitivedataorigin|userwithauth"
```

### Output
[Include Screenshot 2: TPM Initialization]
[Include Screenshot 3: Primary Key Creation]

Figure 2: TPM initialization showing startup and clear operations
Figure 3: Primary storage key creation with RSA 2048 algorithm

### Explanation
[Explain what happened in 3-4 sentences]

The primary storage key serves as the root of the TPM key hierarchy...
[Continue explanation]
```

#### 4. Task 2: Seal Data (~3 pages)

```markdown
## Task 2: Sealing Data to PCR Values

### Reading Initial PCR Values

#### Commands
```bash
# Read PCRs 0, 1, 2, 3
tpm2_pcrread sha256:0,1,2,3

# Save to file
tpm2_pcrread -o pcr_0123.bin sha256:0,1,2,3
```

#### Output
[Include Screenshot 4: Initial PCR Values]

Figure 4: Initial PCR values (0, 1, 2, 3) before any extensions

### Creating PCR Policy

The PCR policy defines the conditions under which sealed data can be accessed...

#### Commands
```bash
# Create policy bound to PCR values
tpm2_createpolicy --policy-pcr -l sha256:0,1,2,3 \
  -f pcr_0123.bin -L pcr_policy.dat
```

### Sealing the Secret

#### Secret Data
For this demonstration, the following secret message was used:
```
"This is a secret password: TPM_Secure_2024!"
```

#### Commands
```bash
# Create secret file
echo "This is a secret password: TPM_Secure_2024!" > secret.txt

# Seal data to PCR policy
tpm2_create -C primary.ctx -L pcr_policy.dat -i secret.txt \
  -r sealed.priv -u sealed.pub -a "fixedtpm|fixedparent"

# Load sealed object
tpm2_load -C primary.ctx -r sealed.priv -u sealed.pub -c sealed.ctx
```

#### Output
[Include Screenshot 5: Sealing Data]

Figure 5: Sealing secret data to PCR policy

### Explanation
[Detailed explanation of the sealing process]

The sealing operation encrypts the secret data such that it can only be
decrypted when the current PCR values match those specified in the policy...
```

#### 5. Task 3: Unseal Data (Success) (~2 pages)

```markdown
## Task 3: Unsealing Data with Correct PCR Values

### Procedure
With the PCR values unchanged from when the data was sealed, we attempt to
unseal the secret.

### Commands
```bash
# Unseal data
tpm2_unseal -c sealed.ctx -p pcr:sha256:0,1,2,3
```

### Output
[Include Screenshot 6: Successful Unseal]

Figure 6: Successful unsealing showing the original secret recovered

### Verification
The unsealed content was verified to match the original secret:
```
Original:  "This is a secret password: TPM_Secure_2024!"
Unsealed:  "This is a secret password: TPM_Secure_2024!"
Match: ✓
```

### Explanation
[Explain why unsealing succeeded]

The unsealing operation succeeded because the current PCR values exactly
match the values stored in the sealing policy...
```

#### 6. Task 4: Demonstrate Unseal Failure (~2 pages)

```markdown
## Task 4: Demonstrating PCR-Based Access Control

### Simulating System State Change

To demonstrate the security feature, we simulate a change in system state
by extending PCR 2 with new data. This represents what would occur if:
- BIOS firmware was updated
- Bootloader was modified
- Malware infected the boot process

### Commands
```bash
# Read PCR 2 before modification
tpm2_pcrread sha256:2

# Extend PCR 2 with "malicious" data
echo "MALICIOUS_BOOTKIT_CODE" | openssl dgst -sha256 -binary | xxd -p -c 64 > hash.txt
tpm2_pcrextend 2:sha256=$(cat hash.txt)

# Read PCR 2 after modification
tpm2_pcrread sha256:2
```

### Output
[Include Screenshot 7: PCR Extension]

Figure 7: PCR 2 value before and after extension showing state change

### Attempting Unseal After PCR Change

```bash
# Attempt to unseal with modified PCRs
tpm2_unseal -c sealed.ctx -p pcr:sha256:0,1,2,3
```

### Output
[Include Screenshot 8: Failed Unseal]

Figure 8: Unseal operation failing due to PCR policy mismatch

### Expected Result: FAILURE ✓

The unsealing operation correctly failed with an error message indicating
PCR policy check failure.

### Explanation
[Detailed explanation of why it failed]

This demonstrates the core security property of TPM sealed storage: data
is cryptographically bound to platform state. Any modification to the
measured components (represented by PCR changes) prevents access to the
sealed secrets...

### Security Implications
1. **Tamper Detection**: System changes are detectable
2. **Data Protection**: Secrets inaccessible if system compromised
3. **Measured Boot**: Complete boot chain integrity verified
4. **Attack Prevention**: Bootkits and rootkits cannot access sealed data
```

#### 7. Conclusion (~1 page)

```markdown
## Conclusion

### Summary of Results

This practical demonstration successfully showed:

✓ **Task 1**: Created TPM primary storage key (RSA 2048) in the owner hierarchy

✓ **Task 2**: Sealed confidential data to specific PCR values (PCRs 0, 1, 2, 3)

✓ **Task 3**: Successfully unsealed data when PCR values matched the sealing policy

✓ **Task 4**: Demonstrated unseal failure when PCR values changed, proving the security mechanism

### Key Learnings

1. **TPM Key Hierarchy**: Understanding how TPM manages cryptographic keys
   with a root-of-trust architecture

2. **PCR-Based Sealing**: Data can be cryptographically bound to system
   state, enabling measured boot security

3. **Extend Operation**: The irreversible nature of PCR extends creates a
   tamper-evident hash chain

4. **Security Model**: TPM provides hardware-backed protection that cannot
   be bypassed by software-only attacks

### Real-World Applications

The techniques demonstrated have direct applications in:
- **Full-Disk Encryption** (BitLocker, LUKS): Boot keys sealed to PCRs
- **Secure Boot**: Ensuring only authorized code executes
- **Enterprise Security**: Remote attestation for compliance
- **IoT Devices**: Hardware-backed device identity and credentials

### Challenges Encountered
[If any - be honest about problems and how you solved them]

[Include Screenshot 9: Summary (optional)]

Figure 9: Complete demonstration summary
```

---

## Creating the PDF

### Method 1: Using LibreOffice Writer (Easiest)

1. **Create a new document**
2. **Copy content** from markdown files
3. **Insert screenshots**:
   - Insert → Image → Select screenshot
   - Right-click image → Properties → Set size
   - Add caption: Insert → Caption
4. **Format document**:
   - Set margins: 1 inch all around
   - Font: Times New Roman or Arial, 11-12pt
   - Line spacing: 1.5
   - Add page numbers
5. **Export to PDF**:
   - File → Export as PDF
   - Name: `Assignment2_<RollNo>.pdf`

### Method 2: Using LaTeX (Professional)

Create a file `assignment.tex`:

```latex
\documentclass[12pt,a4paper]{article}
\usepackage{graphicx}
\usepackage{listings}
\usepackage{hyperref}
\usepackage{geometry}
\geometry{margin=1in}

\title{Assignment 2: Trusted Computing\\TPM Architecture and Practical Tasks}
\author{Your Name\\Roll No: <Your Roll>}
\date{\today}

\begin{document}

\maketitle
\tableofcontents
\newpage

\section{Part A: Theory Questions}

\subsection{Question 1: TPM Architecture and Functions}
[Copy content from markdown files here]

\begin{figure}[h]
\centering
\includegraphics[width=0.8\textwidth]{01_environment_setup.png}
\caption{TPM environment setup}
\end{figure}

% Continue with rest of content...

\end{document}
```

Compile with:
```bash
pdflatex assignment.tex
```

### Method 3: Using Markdown to PDF (Quick)

Install pandoc:
```bash
sudo apt install pandoc texlive-latex-base texlive-fonts-recommended
```

Create master markdown file and convert:
```bash
# Combine all markdown files
cat Title.md \
    PartA_Answer1_TPM_Architecture.md \
    PartA_Answer2_Remote_Attestation.md \
    PartA_Answer3_TEE_Components.md \
    PartA_Answer4_TPM_vs_TEE.md \
    PartB_Content.md \
    > Assignment_Complete.md

# Convert to PDF
pandoc Assignment_Complete.md -o Assignment2_<RollNo>.pdf \
    --pdf-engine=xelatex \
    --toc \
    --number-sections \
    -V geometry:margin=1in \
    -V fontsize=12pt
```

### Method 4: Using Google Docs (Simple)

1. Create new Google Doc
2. Copy content from markdown files
3. Insert screenshots: Insert → Image → Upload
4. Format as needed
5. Download as PDF: File → Download → PDF

---

## Quality Checklist

Before submitting, ensure:

### Content
- [ ] All 4 theory questions answered comprehensively
- [ ] All practical tasks documented with screenshots
- [ ] Explanations clear and technically accurate
- [ ] Code snippets properly formatted
- [ ] References included

### Formatting
- [ ] Title page with your details
- [ ] Table of contents (optional but recommended)
- [ ] Consistent font and spacing
- [ ] Page numbers on all pages (except title)
- [ ] Screenshots clear and readable
- [ ] Captions for all figures
- [ ] Proper headings hierarchy

### Screenshots
- [ ] Minimum 8 screenshots included
- [ ] Each screenshot has caption
- [ ] Text in screenshots is readable
- [ ] Screenshots show relevant output
- [ ] Properly sized (not too large or small)

### Technical Accuracy
- [ ] Commands shown are correct
- [ ] Explanations match output
- [ ] Technical terms used properly
- [ ] No factual errors

### File
- [ ] Named correctly: `Assignment2_<RollNo>.pdf`
- [ ] File size reasonable (<20MB preferred)
- [ ] PDF opens correctly
- [ ] All pages present and in order

---

## Submission

### Final File Details
```
Filename: Assignment2_<RollNo>.pdf
Expected Size: 5-15 MB
Expected Pages: 40-60 pages
Format: PDF (not Word/ODT)
```

### Before Submitting
1. Open the PDF and review every page
2. Check that all screenshots are visible
3. Verify your roll number is correct
4. Ensure the file is not corrupted
5. Test opening on different device

### Submission Method
[Follow your instructor's submission method]
- Upload to learning management system
- Email to instructor
- Submit physical printout
- Or as specified in assignment instructions

---

## Troubleshooting

### Problem: PDF too large (>20MB)

**Solution**:
```bash
# Compress PDF (Linux)
gs -sDEVICE=pdfwrite -dCompatibilityLevel=1.4 -dPDFSETTINGS=/ebook \
   -dNOPAUSE -dQUIET -dBATCH \
   -sOutputFile=Assignment2_<RollNo>_compressed.pdf \
   Assignment2_<RollNo>.pdf
```

Or use online tools:
- ilovepdf.com
- smallpdf.com

### Problem: Screenshots not clear

**Solution**:
- Retake with higher resolution
- Increase terminal font size before capturing
- Use PNG format (not JPG) for screenshots
- Don't scale down too much in document

### Problem: Markdown formatting lost

**Solution**:
- Copy section by section
- Manually apply formatting in word processor
- Or use pandoc for direct conversion

---

## Time Estimate

Task allocation:
- Part A (Theory): 8-10 hours
  - Reading and understanding: 2-3 hours
  - Writing answers: 4-5 hours
  - Review and formatting: 2 hours

- Part B (Practical): 4-6 hours
  - Setup and testing: 1-2 hours
  - Running experiments: 1 hour
  - Screenshots: 1 hour
  - Documentation: 2-3 hours

- PDF Compilation: 2-3 hours
  - Formatting: 1 hour
  - Adding screenshots: 30 minutes
  - Review and quality check: 1 hour
  - Final adjustments: 30 minutes

**Total: 14-19 hours**

---

## Tips for High Grades

1. **Depth over Breadth**: Provide detailed explanations
2. **Technical Accuracy**: Double-check all technical details
3. **Professional Presentation**: Clean formatting, good layout
4. **Practical Evidence**: Clear, well-annotated screenshots
5. **Critical Thinking**: Show understanding, not just copying
6. **References**: Cite sources properly
7. **Proofread**: No spelling/grammar errors

---

Good luck with your submission! 🎓
