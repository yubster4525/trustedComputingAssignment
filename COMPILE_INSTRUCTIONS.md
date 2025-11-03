# How to Compile the Assignment PDF

Your assignment is ready in LaTeX format! Here are several ways to generate the final PDF.

## 📁 Files Created

```
assignment.tex          - Main LaTeX document (includes all parts)
parta_q1.tex           - Part A Question 1 (TPM Architecture)
parta_q2.tex           - Part A Question 2 (Remote Attestation)
parta_q3.tex           - Part A Question 3 (TEE Components)
parta_q4.tex           - Part A Question 4 (TPM vs TEE)
partb_practical.tex    - Part B (Practical with screenshot placeholders)
compile.sh             - Compilation script
attachments/           - Your screenshots folder
```

## ✅ **Option 1: Online LaTeX Editor (EASIEST - NO INSTALL)**

### Overleaf (Recommended)

1. Go to https://www.overleaf.com/
2. Create free account (or login)
3. Click "New Project" → "Upload Project"
4. Create a ZIP file with all .tex files:
   ```bash
   zip -r assignment.zip *.tex attachments/
   ```
5. Upload the ZIP file
6. Overleaf will automatically compile
7. Download the PDF!

**Advantages**: No installation needed, automatic compilation, collaborative editing

---

## 🖥️ **Option 2: Install LaTeX on macOS (LOCAL)**

### Install MacTeX (Full - Recommended)

```bash
# Install MacTeX (large ~4GB but complete)
brew install --cask mactex

# After installation, refresh PATH
eval "$(/usr/libexec/path_helper)"

# Compile the document
./compile.sh
```

### Install BasicTeX (Minimal - Faster)

```bash
# Install BasicTeX (smaller ~100MB)
brew install --cask basictex

# Refresh PATH
eval "$(/usr/libexec/path_helper)"

# Install required packages
sudo tlmgr update --self
sudo tlmgr install latexmk
sudo tlmgr install collection-fontsrecommended

# Compile
./compile.sh
```

---

## 🐧 **Option 3: On Linux Machine**

```bash
# Install LaTeX
sudo apt update
sudo apt install texlive-latex-extra texlive-fonts-recommended

# Compile
chmod +x compile.sh
./compile.sh
```

---

## 🔧 **Option 4: Manual Compilation**

If you have pdflatex installed:

```bash
# Run pdflatex 3 times (for TOC and references)
pdflatex assignment.tex
pdflatex assignment.tex
pdflatex assignment.tex

# View the PDF
open assignment.pdf
```

---

## 📝 **Option 5: Convert to Word (Then to PDF)**

If you prefer working in Word:

### Using Pandoc

```bash
# Install pandoc
brew install pandoc

# Convert each part to Word
for file in parta_q*.tex partb_practical.tex; do
    pandoc "$file" -o "${file%.tex}.docx"
done

# Then manually:
# 1. Open each .docx file in Word
# 2. Copy content into one master document
# 3. Insert screenshots manually
# 4. Export as PDF
```

---

## 🌐 **Option 6: Use Online LaTeX to PDF Converter**

1. **LaTeX Base**: https://latexbase.com/
   - Paste content of assignment.tex
   - Upload .tex files as dependencies
   - Click "Generate PDF"

2. **LaTeX Online**: https://latexonline.cc/
   - Upload your files
   - Auto-compiles and gives PDF

---

## ⚙️ **Before Compiling: Update Your Details**

Edit `assignment.tex` and replace:

```latex
\textbf{Student Name:} & [Your Full Name] \\
\textbf{Roll Number:} & [Your Roll Number] \\
\textbf{Department:} & [Your Department] \\
```

With your actual information!

---

## 🖼️ **Screenshot Paths**

The LaTeX document references your screenshots from the `attachments/` folder:

```latex
\includegraphics[width=0.9\textwidth]{attachments/step01_pcrread.png}
\includegraphics[width=0.9\textwidth]{attachments/step02_createprimary.png}
...
```

**Make sure**:
- The `attachments/` folder is in the same directory as `assignment.tex`
- All 10 screenshot files are present
- Filenames match exactly (case-sensitive!)

---

## 🔍 **Troubleshooting**

### Error: "File not found: parta_q1.tex"

**Solution**: All .tex files must be in the same directory as assignment.tex

```bash
# Check files exist
ls -la *.tex
```

### Error: "Cannot find image: attachments/step01_pcrread.png"

**Solution**: Ensure attachments folder is present

```bash
# Check screenshots exist
ls -la attachments/*.png
```

### Error: "Undefined control sequence"

**Solution**: Missing LaTeX package. Install full MacTeX or use Overleaf.

### Error: "! LaTeX Error: Unknown graphics extension"

**Solution**: Your images might be in wrong format. Convert to PNG if needed:

```bash
# Convert JPEG to PNG
convert image.jpg image.png
```

---

## 📊 **Expected Output**

Your final PDF should be:
- **Total Pages**: ~80-90 pages
- **File Size**: 2-4 MB (with screenshots)
- **Structure**:
  - Title page
  - Table of contents
  - Part A: 4 theory questions (~70 pages)
  - Part B: Practical with 10 screenshots (~15 pages)
  - References

---

## ⚡ **Quick Start (Recommended for macOS)**

### Fastest Method - Use Overleaf

1. Create ZIP file:
   ```bash
   zip -r my_assignment.zip *.tex attachments/
   ```

2. Go to https://www.overleaf.com/

3. Upload ZIP → Auto-compiles → Download PDF ✅

**Time required**: 5 minutes

---

## 💡 **Tips for Success**

1. **Edit assignment.tex first** - Add your name and roll number
2. **Check screenshot paths** - Make sure all images are in attachments/
3. **Use Overleaf** - If you don't want to install LaTeX locally
4. **Compile 3 times** - For proper table of contents and references
5. **Check PDF carefully** - Ensure all sections and images appear

---

## 🆘 **Still Having Issues?**

If compilation fails:

1. **Try Overleaf** - It handles everything automatically
2. **Check the log** - Look at `assignment.log` for specific errors
3. **Verify files** - Ensure all .tex files and screenshots are present
4. **Ask for help** - Share the error message

---

## ✅ **Final Checklist**

Before submitting:

- [ ] Compiled PDF successfully
- [ ] Your name and roll number on title page
- [ ] All 4 Part A questions present
- [ ] All 10 screenshots visible in Part B
- [ ] Table of contents generated
- [ ] Page numbers showing
- [ ] References section included
- [ ] File named: `Assignment2_<YourRollNo>.pdf`
- [ ] File size reasonable (<10MB)
- [ ] All pages readable

---

**Good luck with your submission!** 🎓
