#!/bin/bash

echo "========================================="
echo "TPM Assignment PDF Compilation Script"
echo "========================================="
echo ""

# Check if pdflatex is installed
if ! command -v pdflatex &> /dev/null; then
    echo "Error: pdflatex not found!"
    echo ""
    echo "Please install LaTeX:"
    echo "  macOS: brew install --cask mactex"
    echo "  or: brew install basictex"
    echo ""
    exit 1
fi

# Clean previous builds
echo "Cleaning previous build artifacts..."
rm -f *.aux *.log *.out *.toc *.pdf 2>/dev/null

# Compile the document
echo ""
echo "Compiling LaTeX document (Pass 1/3)..."
pdflatex -interaction=nonstopmode assignment.tex > /dev/null 2>&1

echo "Compiling LaTeX document (Pass 2/3 - TOC)..."
pdflatex -interaction=nonstopmode assignment.tex > /dev/null 2>&1

echo "Compiling LaTeX document (Pass 3/3 - References)..."
pdflatex -interaction=nonstopmode assignment.tex > /dev/null 2>&1

# Check if PDF was generated
if [ -f "assignment.pdf" ]; then
    echo ""
    echo "========================================="
    echo "✓ SUCCESS! PDF Generated"
    echo "========================================="
    echo ""
    echo "Output file: assignment.pdf"
    echo "Size: $(du -h assignment.pdf | cut -f1)"
    echo ""
    echo "To view:"
    echo "  open assignment.pdf"
    echo ""

    # Clean up auxiliary files
    echo "Cleaning up auxiliary files..."
    rm -f *.aux *.log *.out *.toc

    echo "Done!"
else
    echo ""
    echo "========================================="
    echo "✗ ERROR: PDF generation failed"
    echo "========================================="
    echo ""
    echo "Check assignment.log for errors"
    echo ""
    exit 1
fi
