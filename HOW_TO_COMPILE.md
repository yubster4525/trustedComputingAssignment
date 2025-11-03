# 📄 How to Create Your Final PDF

## ✅ **READY TO SUBMIT**

Your assignment is complete and concise:
- **Your Name**: Yuvan Raj Krishna
- **Register Number**: 22011102127
- **Expected Length**: ~25-30 pages (2-4 pages per question)
- **Content**: 4 theory questions + 1 practical with 10 screenshots

---

## 🚀 **FASTEST WAY: Use Overleaf (5 minutes)**

### Step 1: Create ZIP
```bash
cd /Users/yuvan/Documents/College/sem7/trustedComputing/Assignments
zip -r assignment.zip assignment.tex parta_q*_concise.tex partb_concise.tex attachments/
```

### Step 2: Upload to Overleaf
1. Go to https://www.overleaf.com/
2. Create free account (if needed)
3. Click "New Project" → "Upload Project"
4. Upload `assignment.zip`
5. Overleaf compiles automatically

### Step 3: Download PDF
1. Click "Download PDF" button
2. Rename to: `Assignment2_22011102127.pdf`
3. Submit!

**Done!** ✅

---

## 💻 **Alternative: Install LaTeX Locally (macOS)**

### One-Time Setup
```bash
# Install MacTeX (takes ~10 minutes)
brew install --cask mactex

# Restart terminal, then verify
pdflatex --version
```

### Compile Every Time
```bash
cd /Users/yuvan/Documents/College/sem7/trustedComputing/Assignments
./compile.sh
```

Your PDF will be created as `assignment.pdf`

Rename it:
```bash
mv assignment.pdf Assignment2_22011102127.pdf
```

---

## 📋 **What's Inside**

Your PDF will contain:

### Title Page
- Assignment 2 - Trusted Computing
- Your name: Yuvan Raj Krishna
- Register Number: 22011102127

### Table of Contents
- Auto-generated

### Part A - Theory Questions (~15-18 pages)
- Question 1: TPM Architecture & PCRs (2-3 pages)
- Question 2: Remote Attestation (3-4 pages)
- Question 3: TEE Components (3-4 pages)
- Question 4: TPM vs TEE (3-4 pages)

### Part B - Practical (~10-12 pages)
- All 10 screenshots with explanations
- Commands and analysis
- Security implications

### References
- Academic sources

**Total: ~25-30 pages**

---

## ✅ **Checklist Before Submission**

Open the PDF and verify:
- [ ] Your name shows: Yuvan Raj Krishna
- [ ] Register number shows: 22011102127
- [ ] All 4 theory questions are present
- [ ] All 10 screenshots are visible
- [ ] No "image not found" errors
- [ ] Page numbers showing
- [ ] File size: 2-5 MB (reasonable)
- [ ] File named: `Assignment2_22011102127.pdf`

---

## 🆘 **Troubleshooting**

### Can't install LaTeX?
→ **Use Overleaf** (no installation needed!)

### Images not showing?
→ Make sure `attachments/` folder is in the ZIP

### Compilation errors?
→ Use Overleaf (handles everything automatically)

---

## ⏱️ **Time to Submit**

- **Using Overleaf**: 5 minutes
- **Using local LaTeX**: 15 minutes (first time), 2 minutes (after installed)

**You're ready to submit!** 🎉
