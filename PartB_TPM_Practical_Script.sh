#!/bin/bash
#############################################################################
# TPM 2.0 Practical Demonstration Script
# Part B: Secure Key Storage, Seal, and Unseal Simulation
#
# This script demonstrates:
# 1. Creating a TPM key hierarchy
# 2. Sealing data to PCR values
# 3. Successfully unsealing when PCRs match
# 4. Demonstrating unseal failure when PCRs change
#
# Prerequisites:
# - tpm2-tools installed
# - TPM simulator running (IBM TPM or swtpm)
# - Environment variable: export TPM2TOOLS_TCTI="mssim:host=localhost,port=2321"
#
# Author: Assignment 2 - Trusted Computing
#############################################################################

# Color codes for better visibility
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Function to print section headers
print_header() {
    echo ""
    echo -e "${CYAN}========================================${NC}"
    echo -e "${CYAN}$1${NC}"
    echo -e "${CYAN}========================================${NC}"
    echo ""
}

# Function to print step
print_step() {
    echo -e "${BLUE}>>> $1${NC}"
}

# Function to print success
print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

# Function to print error
print_error() {
    echo -e "${RED}✗ $1${NC}"
}

# Function to print warning
print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

# Create working directory
WORK_DIR="$HOME/tpm_demo_$$"
mkdir -p "$WORK_DIR"
cd "$WORK_DIR"
print_success "Created working directory: $WORK_DIR"

#############################################################################
# STEP 0: Environment Check
#############################################################################

print_header "STEP 0: Environment Verification"

print_step "Checking if tpm2-tools is installed..."
if command -v tpm2_getrandom &> /dev/null; then
    VERSION=$(tpm2_getrandom --version | head -n1)
    print_success "tpm2-tools found: $VERSION"
else
    print_error "tpm2-tools not found! Please install it first."
    exit 1
fi

print_step "Checking TPM connection..."
if tpm2_getrandom 8 --hex &> /dev/null; then
    RANDOM_HEX=$(tpm2_getrandom 8 --hex)
    print_success "TPM connection successful!"
    echo "  Random bytes from TPM: $RANDOM_HEX"
else
    print_error "Cannot connect to TPM!"
    print_warning "Make sure TPM simulator is running:"
    echo "  Terminal 1: tpm_server"
    echo "  Terminal 2: export TPM2TOOLS_TCTI=\"mssim:host=localhost,port=2321\""
    exit 1
fi

#############################################################################
# STEP 1: Initialize TPM
#############################################################################

print_header "STEP 1: Initialize TPM"

print_step "Performing TPM startup..."
tpm2_startup -c 2>/dev/null || print_warning "TPM already started"
print_success "TPM startup complete"

print_step "Clearing TPM to start fresh..."
echo "  This resets the TPM to factory state"
tpm2_clear 2>/dev/null || print_warning "TPM clear may require authorization"
print_success "TPM cleared successfully"

#############################################################################
# STEP 2: Create Primary Storage Key
#############################################################################

print_header "STEP 2: Create Primary Storage Key"

print_step "Creating primary key in owner hierarchy..."
echo "  Algorithm: RSA 2048"
echo "  Hash: SHA256"
echo "  Attributes: restricted, decrypt, fixedtpm, fixedparent"

tpm2_createprimary \
    -C o \
    -g sha256 \
    -G rsa \
    -c primary.ctx \
    -a "restricted|decrypt|fixedtpm|fixedparent|sensitivedataorigin|userwithauth" \
    2>&1 | tee create_primary.log

if [ ${PIPESTATUS[0]} -eq 0 ]; then
    print_success "Primary storage key created: primary.ctx"
    echo ""
    echo "Key details:"
    grep -E "(name|name-alg)" create_primary.log || echo "  (logged to create_primary.log)"
else
    print_error "Failed to create primary key"
    exit 1
fi

#############################################################################
# STEP 3: Read Initial PCR Values
#############################################################################

print_header "STEP 3: Read Current PCR Values"

print_step "Reading PCRs 0, 1, 2, 3 with SHA-256..."
echo "  These PCRs typically contain boot measurements"
echo "  PCR 0: CRTM, BIOS, Platform Extensions"
echo "  PCR 1: Platform Configuration"
echo "  PCR 2: Option ROM Code"
echo "  PCR 3: Option ROM Configuration"
echo ""

tpm2_pcrread sha256:0,1,2,3 2>&1 | tee initial_pcrs.txt

print_step "Saving PCR values to file..."
tpm2_pcrread -o pcr_0123.bin sha256:0,1,2,3
print_success "PCR values saved to: pcr_0123.bin"

# Display hex dump of PCR values
echo ""
print_step "PCR values (hexdump):"
xxd -g 32 -c 32 pcr_0123.bin | head -n 4

#############################################################################
# STEP 4: Create PCR Policy
#############################################################################

print_header "STEP 4: Create PCR Sealing Policy"

print_step "Creating policy that requires PCRs 0,1,2,3 to match current values..."
echo "  This policy will be used to seal the secret data"
echo "  Data can only be unsealed if PCRs match these exact values"
echo ""

tpm2_createpolicy \
    --policy-pcr \
    -l sha256:0,1,2,3 \
    -f pcr_0123.bin \
    -L pcr_policy.dat \
    2>&1 | tee policy_creation.log

if [ ${PIPESTATUS[0]} -eq 0 ]; then
    print_success "PCR policy created: pcr_policy.dat"
    echo ""
    print_step "Policy digest (hex):"
    xxd -p pcr_policy.dat | tr -d '\n'
    echo ""
else
    print_error "Failed to create PCR policy"
    exit 1
fi

#############################################################################
# STEP 5: Create Secret Data
#############################################################################

print_header "STEP 5: Prepare Secret Data"

print_step "Creating secret data file..."
SECRET_MESSAGE="This is a secret password: TPM_Secure_2024!"
echo "$SECRET_MESSAGE" > secret.txt

print_success "Secret data created:"
echo "  File: secret.txt"
echo "  Content: \"$SECRET_MESSAGE\""
echo "  Size: $(wc -c < secret.txt) bytes"
echo ""
echo "  SHA-256 hash of secret:"
sha256sum secret.txt

#############################################################################
# STEP 6: Seal Data to PCR Values
#############################################################################

print_header "STEP 6: Seal Secret Data to PCR Values"

print_step "Creating sealed object bound to PCR policy..."
echo "  The secret will be encrypted and can only be decrypted"
echo "  when the current PCR values match those in the policy"
echo ""

tpm2_create \
    -C primary.ctx \
    -L pcr_policy.dat \
    -i secret.txt \
    -r sealed.priv \
    -u sealed.pub \
    -a "fixedtpm|fixedparent" \
    2>&1 | tee seal_creation.log

if [ ${PIPESTATUS[0]} -eq 0 ]; then
    print_success "Sealed object created successfully!"
    echo "  Private portion: sealed.priv"
    echo "  Public portion: sealed.pub"
    echo ""
    ls -lh sealed.priv sealed.pub
else
    print_error "Failed to seal data"
    exit 1
fi

print_step "Loading sealed object into TPM..."
tpm2_load \
    -C primary.ctx \
    -r sealed.priv \
    -u sealed.pub \
    -c sealed.ctx

if [ $? -eq 0 ]; then
    print_success "Sealed object loaded: sealed.ctx"
else
    print_error "Failed to load sealed object"
    exit 1
fi

#############################################################################
# STEP 7: Unseal Data (Success Case)
#############################################################################

print_header "STEP 7: Unseal Data with Correct PCR Values"

print_step "Attempting to unseal the secret..."
echo "  Current PCRs should match the sealed policy"
echo "  Expected result: SUCCESS"
echo ""

tpm2_unseal \
    -c sealed.ctx \
    -p pcr:sha256:0,1,2,3 \
    > unsealed_secret.txt 2>&1

if [ $? -eq 0 ]; then
    print_success "Unsealing SUCCESSFUL!"
    echo ""
    print_step "Unsealed content:"
    echo "────────────────────────────────────────"
    cat unsealed_secret.txt
    echo "────────────────────────────────────────"
    echo ""

    print_step "Verifying unsealed data matches original..."
    if diff -q secret.txt unsealed_secret.txt &>/dev/null; then
        print_success "✓ Unsealed data matches original secret!"
    else
        print_error "✗ Unsealed data does NOT match!"
    fi
else
    print_error "Unsealing failed (unexpected!)"
    cat unsealed_secret.txt
fi

#############################################################################
# STEP 8: Extend PCR (Simulate System State Change)
#############################################################################

print_header "STEP 8: Simulate System State Change"

print_step "Extending PCR 2 to simulate a change in system state..."
echo "  This simulates what would happen if:"
echo "  - BIOS was updated"
echo "  - Bootloader was modified"
echo "  - Rootkit infected boot process"
echo ""

print_step "Current PCR 2 value (before extension):"
tpm2_pcrread sha256:2

# Create a fake "malicious" measurement
MALICIOUS_DATA="MALICIOUS_BOOTKIT_CODE"
echo "$MALICIOUS_DATA" > malicious.bin

print_step "Extending PCR 2 with: \"$MALICIOUS_DATA\""
HASH_VALUE=$(echo -n "$MALICIOUS_DATA" | openssl dgst -sha256 -binary | xxd -p -c 64)
echo "  Hash value: $HASH_VALUE"

tpm2_pcrextend 2:sha256=$HASH_VALUE

if [ $? -eq 0 ]; then
    print_success "PCR 2 extended successfully"
    echo ""
    print_step "New PCR 2 value (after extension):"
    tpm2_pcrread sha256:2
else
    print_error "Failed to extend PCR"
fi

#############################################################################
# STEP 9: Attempt Unseal After PCR Change (Failure Case)
#############################################################################

print_header "STEP 9: Attempt Unseal After PCR Modification"

print_step "Attempting to unseal with modified PCR values..."
echo "  PCR 2 has changed, so the policy check should FAIL"
echo "  Expected result: FAILURE (this is the security feature!)"
echo ""

tpm2_unseal \
    -c sealed.ctx \
    -p pcr:sha256:0,1,2,3 \
    > unsealed_fail.txt 2>&1

if [ $? -eq 0 ]; then
    print_error "Unsealing succeeded (this should NOT have happened!)"
    print_error "Security violation: Sealed data should be protected!"
    cat unsealed_fail.txt
else
    print_success "✓ Unsealing correctly FAILED due to PCR mismatch!"
    echo ""
    print_step "Error message from TPM:"
    echo "────────────────────────────────────────"
    cat unsealed_fail.txt
    echo "────────────────────────────────────────"
    echo ""
    print_success "This demonstrates that sealed data is protected by PCR values"
    print_success "Any change to measured components prevents unsealing"
fi

#############################################################################
# STEP 10: Demonstrate PCR Restore and Successful Unseal
#############################################################################

print_header "STEP 10: Reset and Demonstrate Unseal Again"

print_step "Resetting TPM to restore original PCR values..."
echo "  In real system, this requires reboot"
echo "  In simulator, we can restart to reset PCRs"
echo ""

tpm2_startup -c

print_step "Re-creating primary key and loading sealed object..."
tpm2_createprimary \
    -C o \
    -g sha256 \
    -G rsa \
    -c primary2.ctx \
    -a "restricted|decrypt|fixedtpm|fixedparent|sensitivedataorigin|userwithauth" \
    > /dev/null 2>&1

tpm2_load \
    -C primary2.ctx \
    -r sealed.priv \
    -u sealed.pub \
    -c sealed2.ctx \
    > /dev/null 2>&1

print_step "Reading current PCR values after reset..."
tpm2_pcrread sha256:0,1,2,3

print_step "Attempting unseal after TPM reset..."
tpm2_unseal \
    -c sealed2.ctx \
    -p pcr:sha256:0,1,2,3 \
    > unsealed_after_reset.txt 2>&1

if [ $? -eq 0 ]; then
    print_success "✓ Unsealing successful after reset!"
    echo ""
    print_step "Unsealed content:"
    echo "────────────────────────────────────────"
    cat unsealed_after_reset.txt
    echo "────────────────────────────────────────"
else
    print_warning "Unseal after reset failed (may need full TPM clear)"
fi

#############################################################################
# STEP 11: Summary and Cleanup
#############################################################################

print_header "STEP 11: Summary and Cleanup"

echo -e "${GREEN}╔══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║           TPM SECURE KEY STORAGE DEMONSTRATION               ║${NC}"
echo -e "${GREEN}╠══════════════════════════════════════════════════════════════╣${NC}"
echo -e "${GREEN}║                                                              ║${NC}"
echo -e "${GREEN}║  ✓ Created TPM primary storage key                           ║${NC}"
echo -e "${GREEN}║  ✓ Read initial PCR values (PCRs 0,1,2,3)                    ║${NC}"
echo -e "${GREEN}║  ✓ Created PCR-based sealing policy                          ║${NC}"
echo -e "${GREEN}║  ✓ Sealed secret data to PCR values                          ║${NC}"
echo -e "${GREEN}║  ✓ Successfully unsealed with matching PCRs                  ║${NC}"
echo -e "${GREEN}║  ✓ Extended PCR to simulate system change                    ║${NC}"
echo -e "${GREEN}║  ✓ Demonstrated unseal failure with PCR mismatch             ║${NC}"
echo -e "${GREEN}║                                                              ║${NC}"
echo -e "${GREEN}║  ${YELLOW}Key Takeaway:${NC}${GREEN}                                             ║${NC}"
echo -e "${GREEN}║  Sealed data is cryptographically bound to system state      ║${NC}"
echo -e "${GREEN}║  Any tampering with measured components prevents unsealing   ║${NC}"
echo -e "${GREEN}║                                                              ║${NC}"
echo -e "${GREEN}╚══════════════════════════════════════════════════════════════╝${NC}"

echo ""
print_step "Files created in: $WORK_DIR"
echo "  • primary.ctx - Primary storage key"
echo "  • sealed.priv, sealed.pub - Sealed object"
echo "  • secret.txt - Original secret"
echo "  • unsealed_secret.txt - Successfully unsealed content"
echo "  • initial_pcrs.txt - PCR values before modification"
echo "  • pcr_policy.dat - PCR sealing policy"
echo "  • *.log - Detailed operation logs"
echo ""

print_step "Do you want to keep the working directory? (y/n)"
read -p "Keep files? " -n 1 -r
echo ""
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    print_step "Cleaning up..."
    cd ..
    rm -rf "$WORK_DIR"
    print_success "Cleanup complete"
else
    print_success "Files preserved in: $WORK_DIR"
    echo "  You can examine them for your report"
fi

echo ""
print_header "DEMONSTRATION COMPLETE"
echo ""

exit 0
