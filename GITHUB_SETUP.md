# GitHub Setup Instructions

## Quick Steps to Push to GitHub

### Step 1: Create a New Repository on GitHub

1. Go to https://github.com/new
2. **Repository name**: `tpm-tee-assignment`
3. **Description**: "TPM and TEE Assignment - Trusted Computing"
4. **Visibility**: Choose:
   - ✅ **Private** (recommended for assignment work)
   - ⚠️ **Public** (only if allowed by your instructor)
5. ❌ **DO NOT** initialize with README, .gitignore, or license (we already have these)
6. Click **"Create repository"**

### Step 2: Link Your Local Repository

After creating the repo, GitHub will show you commands. Use these:

```bash
# Add the remote (replace USERNAME with your GitHub username)
git remote add origin https://github.com/USERNAME/tpm-tee-assignment.git

# Or if you use SSH:
git remote add origin git@github.com:USERNAME/tpm-tee-assignment.git

# Rename branch to main (optional, modern convention)
git branch -M main

# Push to GitHub
git push -u origin main
```

### Step 3: Verify

Visit your repository URL:
```
https://github.com/USERNAME/tpm-tee-assignment
```

You should see all 10 files!

---

## Alternative: Use GitHub CLI (if installed)

```bash
# Login to GitHub
gh auth login

# Create repo and push (all in one)
gh repo create tpm-tee-assignment --private --source=. --push
```

---

## Clone on Linux Machine

Once pushed, on your Linux machine:

```bash
# Clone the repository
git clone https://github.com/USERNAME/tpm-tee-assignment.git
cd tpm-tee-assignment

# Make script executable
chmod +x PartB_TPM_Practical_Script.sh

# Start working!
cat README.md
```

---

## Important Notes

1. **Private vs Public**:
   - Use **Private** if this is graded work (avoid plagiarism issues)
   - Check with your instructor about sharing assignment code

2. **Authentication**:
   - GitHub requires Personal Access Token (PAT) or SSH for HTTPS push
   - Or use GitHub CLI for easier authentication

3. **Keep Updated**:
   - If you make changes on macOS, commit and push
   - On Linux, do `git pull` to get latest changes

---

## Troubleshooting

### Problem: "Authentication failed"

**Solution**: Create a Personal Access Token
1. Go to https://github.com/settings/tokens
2. Click "Generate new token (classic)"
3. Select scopes: `repo` (full control)
4. Generate and copy the token
5. Use token as password when pushing

### Problem: "Remote already exists"

**Solution**:
```bash
git remote remove origin
git remote add origin https://github.com/USERNAME/tpm-tee-assignment.git
```

### Problem: "Permission denied (publickey)"

**Solution**: Use HTTPS instead of SSH, or set up SSH keys
```bash
git remote set-url origin https://github.com/USERNAME/tpm-tee-assignment.git
```
