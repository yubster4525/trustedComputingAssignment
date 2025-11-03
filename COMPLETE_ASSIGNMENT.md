# Assignment 2: Trusted Computing
## TPM Architecture and TEE - Theory and Practical

**Student Name**: [Your Full Name]
**Roll Number**: [Your Roll Number]
**Course**: Trusted Computing
**Date**: November 3, 2025

---

\newpage

# Table of Contents

## Part A - Theory Questions (10 marks)

1. TPM Architecture and Functions
2. TPM Based Attestation
3. TEE Components
4. TPM vs TEE Comparison

## Part B - Practical Tasks (10 marks)

1. Environment Setup
2. Create TPM Key
3. Seal Data to PCR Values
4. Unseal Data Successfully
5. Demonstrate PCR-Based Access Control
6. Conclusion

---

\newpage

# Part A: Theory Questions

---

# Question 1: TPM Architecture and Functions

## Explain the internal architecture of a Trusted Platform Module. How do PCRs (Platform Configuration Registers) contribute to measured boot?

---

## Introduction

A Trusted Platform Module (TPM) is a specialized cryptographic co-processor designed to provide hardware-based security functions. Defined by the Trusted Computing Group (TCG), TPM serves as a hardware root of trust for platform integrity, secure key storage, and cryptographic operations. This answer explores the internal architecture of TPM 2.0 and explains how Platform Configuration Registers (PCRs) enable measured boot.

---

## Internal Architecture of TPM

The TPM architecture consists of several key components organized into functional layers:

### 1. Root of Trust Components

#### Core Root of Trust for Measurement (CRTM)
- The first code to execute after system power-on or reset
- Typically resides in immutable firmware (Boot Block in BIOS/UEFI)
- Cannot be measured by any other component (it IS the root of trust)
- Responsible for:
  - Performing self-integrity checks
  - Measuring the next stage of boot code (BIOS/UEFI)
  - Storing the first measurement in PCR-0

#### Root of Trust for Storage (RTS)
- Provides secure key hierarchy and protected storage
- Based on the **Storage Root Key (SRK)**:
  - 2048-bit RSA or ECC key generated inside TPM
  - Never exported from the TPM
  - Acts as the root of the key hierarchy
  - Used to wrap (encrypt) all other storage keys
- Ensures that keys stored outside TPM are protected
- Maintains key hierarchy: SRK → Primary Keys → Child Keys → Leaf Keys

#### Root of Trust for Reporting (RTR)
- Enables trustworthy reporting of platform state
- Uses **Attestation Identity Key (AIK)**:
  - Special-purpose signing key for creating quotes
  - Certified by TPM's Endorsement Key (EK)
  - Used in remote attestation protocols
- Provides signed reports of PCR values to remote verifiers
- Guarantees authenticity of platform measurements

### 2. Cryptographic Engine

The TPM contains a dedicated hardware cryptographic processor with:

#### Key Generation Engine
- Hardware-based random number generator (RNG) meeting NIST SP 800-90A standards
- Generates cryptographic keys internally (never exposed during generation)
- Supports RSA (1024, 2048 bits) and ECC (NIST P-256, P-384) algorithms

#### Asymmetric Crypto Accelerators
- **RSA Engine**: Performs RSA operations (sign, verify, encrypt, decrypt)
- **ECC Engine**: Handles elliptic curve operations (ECDSA, ECDH)
- Hardware acceleration provides tamper-resistant computation
- Typical performance: 1-2 seconds for 2048-bit RSA signature

#### Hash Engine
- Computes cryptographic hashes for measurements
- Supports multiple algorithms simultaneously:
  - SHA-1 (for legacy compatibility)
  - SHA-256 (most common)
  - SHA-384, SHA-512
- Performs PCR extend operations: `PCR_new = HASH(PCR_old || data)`

#### Symmetric Crypto Engine
- AES engine for symmetric encryption/decryption
- Supports key sizes: 128, 192, 256 bits
- Modes: CFB, CTR, OFB, CBC
- Used for encrypting sensitive parameters in transit

### 3. Memory Components

#### Non-Volatile Memory (NV RAM)
Persistent storage (typically 2-8 KB) containing:

**Persistent Keys:**
- **Endorsement Key (EK)**: Unique TPM identifier, installed during manufacturing
- **Storage Root Key (SRK)**: Master wrapping key for key hierarchy
- **Platform Hierarchy Seed**: Generates platform-controlled keys
- **Owner Hierarchy Seed**: Generates owner-controlled keys

**Platform Configuration:**
- Owner authorization credentials
- Dictionary attack protection parameters
- Lockout authorization
- Platform policy settings

**User-Defined NV Indices:**
- Can store custom data (certificates, policies, counters)
- Access controlled by authorization policies
- May be bound to PCR states

#### Volatile Memory (RAM)
Temporary storage (typically 4-16 KB) for:
- Active PCR values (reset on each boot)
- Loaded key contexts during operations
- Session data (authorization sessions, encryption sessions)
- Command execution scratch space

### 4. Platform Configuration Registers (PCRs)

#### PCR Architecture

PCRs are special-purpose registers with unique properties:

**Physical Characteristics:**
- 24 or more registers (TPM 2.0 allows implementation-specific numbers)
- Each PCR is 160 bits (SHA-1), 256 bits (SHA-256), or 384 bits (SHA-384)
- Organized into **PCR banks** - one bank per hash algorithm
- Example: A TPM might have both SHA-1 and SHA-256 banks, each with 24 PCRs

**Usage Convention (TCG PC Client Specification):**
```
PCR 0:  CRTM, BIOS, Host Platform Extensions
PCR 1:  Host Platform Configuration
PCR 2:  Option ROM Code
PCR 3:  Option ROM Configuration and Data
PCR 4:  IPL Code (Initial Program Loader - like GRUB)
PCR 5:  IPL Configuration and Data
PCR 6:  State Transitions and Wake Events
PCR 7:  Host Platform Manufacturer Specific
PCR 8-15: Static OS usage (kernel, drivers, configuration)
PCR 16-23: Dynamic OS usage (applications, user data)
```

**Key Properties:**
1. **Write-Once per Boot**: Cannot be directly written, only extended
2. **Reset on Boot**: PCRs cleared to known values (0x00...00 or 0xFF...FF) at startup
3. **Atomic Operations**: Extend is an atomic hardware operation
4. **Tamper-Evident**: Any change in boot sequence produces different final values

### 5. I/O Interface

#### Communication Bus
- **LPC (Low Pin Count) Bus**: Traditional interface for discrete TPM chips
- **SPI (Serial Peripheral Interface)**: Modern interface, faster than LPC
- **I²C**: Used in embedded systems
- **Virtual Interface**: For firmware TPMs (fTPM) or hypervisor integration

#### Command Processing
- Implements TPM 2.0 command set (defined in TCG TPM 2.0 Part 3)
- Command structure:
  ```
  [Command Header] [Authorization] [Parameters]
  ```
- Response structure:
  ```
  [Response Header] [Authorization] [Return Data]
  ```
- Supports sessions for authorization and parameter encryption

### 6. Execution Engine

#### Command Processor
- Parses and validates incoming commands
- Enforces authorization policies
- Manages concurrent operations (though most operations are serialized)
- Implements dictionary attack protection (rate limiting)

#### Authorization Logic
- **Password-based**: Simple HMAC authorization
- **Policy-based**: Complex conditions (PCR state, time, locality, etc.)
- **Session-based**: Enables encrypted parameters and rolling nonces

---

## How PCRs Contribute to Measured Boot

### Concept of Measured Boot

**Measured Boot** is a boot process where each component measures (cryptographically hashes) the next component before executing it, storing measurements in PCRs. Unlike Secure Boot (which enforces signatures), Measured Boot creates an audit trail without blocking execution.

### The Extend Operation

The core of measured boot is the **PCR Extend** operation:

```
PCR_new = HASH(PCR_old || data_to_measure)
```

**Mathematical Properties:**
1. **One-way Function**: Cannot reverse to find original inputs
2. **Collision Resistant**: Practically impossible to find two inputs producing same output
3. **Avalanche Effect**: Tiny change in input causes completely different output
4. **Deterministic**: Same boot sequence always produces same final PCR values

**Example:**
```
Initial State:
  PCR[0] = 0x000...000 (20 bytes of zeros for SHA-1)

First Measurement (BIOS):
  BIOS_hash = SHA1(BIOS_binary) = 0xABCD...1234
  PCR[0] = SHA1(0x000...000 || 0xABCD...1234) = 0x9876...FEDC

Second Measurement (Boot Loader):
  BOOTLOADER_hash = SHA1(grub.efi) = 0x5678...ABCD
  PCR[0] = SHA1(0x9876...FEDC || 0x5678...ABCD) = 0x1111...2222
```

**Critical Property**: The final PCR[0] value uniquely represents the entire chain:
- Different BIOS → Different final PCR value
- Different boot loader → Different final PCR value
- Different execution order → Different final PCR value

### Measured Boot Process

#### Stage 1: Power-On Reset
```
Event: System powers on
Action: PCRs initialized to 0x00...00 or 0xFF...FF
PCR State: Known initial state
```

#### Stage 2: CRTM Execution
```
Component: Core Root of Trust for Measurement
Action:
  - Executes from ROM (immutable)
  - Measures BIOS/UEFI firmware
  - Extends PCR-0 with BIOS measurement
  - Transfers control to BIOS

PCR Update: PCR[0] ← EXTEND(BIOS_hash)
Trust: CRTM cannot be measured (it's the root), assumed trusted
```

#### Stage 3: BIOS/UEFI Execution
```
Component: BIOS/UEFI Firmware
Action:
  - Initializes hardware
  - Measures configuration (PCR-1)
  - Measures Option ROMs (PCR-2, PCR-3)
  - Measures Boot Loader (PCR-4)
  - Extends respective PCRs
  - Transfers control to Boot Loader

PCR Updates:
  PCR[1] ← EXTEND(Platform_Configuration)
  PCR[2] ← EXTEND(Option_ROM_Code)
  PCR[4] ← EXTEND(Boot_Loader_Binary)
```

#### Stage 4: Boot Loader (GRUB/systemd-boot)
```
Component: OS Boot Loader
Action:
  - Measures boot configuration (PCR-5)
  - Measures kernel image (PCR-8 or PCR-9)
  - Measures initramfs (PCR-9)
  - Extends PCRs
  - Loads and executes kernel

PCR Updates:
  PCR[5] ← EXTEND(grub.cfg)
  PCR[8] ← EXTEND(vmlinuz)
  PCR[9] ← EXTEND(initramfs)
```

#### Stage 5: OS Kernel
```
Component: Operating System Kernel
Action:
  - Measures loaded drivers
  - Measures system configuration
  - IMA (Integrity Measurement Architecture) continues measurement
  - Runtime measurements in PCR 10-23

PCR Updates:
  PCR[10-15] ← EXTEND(drivers, system_services)
```

### Chain of Trust

The measured boot creates an **unbroken chain of trust**:

```
CRTM (trusted by assumption)
  ↓ measures
BIOS (measurement in PCR-0)
  ↓ measures
Boot Loader (measurement in PCR-4)
  ↓ measures
Kernel (measurement in PCR-8/9)
  ↓ measures
Drivers & Services (measurements in PCR 10+)
```

**Key Principle**: Each stage measures the next stage BEFORE executing it.

### Security Guarantees

#### 1. Tamper Detection
If any component is modified (by malware, attacker, or corruption):
```
Original Boot:  PCR[0] = 0xAAAA...1111
After Tamper:   PCR[0] = 0xBBBB...2222  (completely different)
```

The different PCR value proves tampering occurred.

#### 2. Replay Protection
Historical measurements cannot be reused:
- Each boot starts with fresh PCR values (reset on power-on)
- Extend operations are atomic and irreversible
- Cannot "undo" an extend operation

#### 3. Forensic Evidence
PCR values provide cryptographic proof of:
- Exact boot sequence executed
- Order of component loading
- Configuration state at boot time

Can be used for:
- Security audits
- Compliance verification
- Incident response

### Use Cases Enabled by Measured Boot

#### 1. Sealed Storage
Encrypt data such that it can only be decrypted when specific PCR values match:

```
Seal Operation:
  - Read current PCR values [0,1,2,4,7,8,9]
  - Create encryption key sealed to these values
  - Encrypt data with sealed key
  - Store encrypted data

Unseal Operation:
  - TPM checks current PCR values
  - If PCRs match sealed values → Release decryption key
  - If PCRs differ → Refuse to release key
```

**Example**: BitLocker encrypts disk with key sealed to PCRs 0,1,2,3,4,5,6,7,11
- If BIOS is modified → PCR-0 changes → Disk cannot be decrypted
- If kernel is modified → PCR-8 changes → Disk cannot be decrypted

#### 2. Remote Attestation
Prove to remote party that system booted in expected state:

```
Local System:
  - Boot completes with measured PCR values
  - Remote verifier sends challenge
  - TPM generates quote: Sign(PCR_values || nonce, AIK_private)
  - Send quote to verifier

Remote Verifier:
  - Receives quote and signature
  - Verifies signature using AIK_public
  - Compares PCR values to "known good" reference values
  - Makes trust decision: Grant/Deny access
```

**Example**: Corporate VPN requires attestation
- User attempts VPN connection
- VPN server challenges user's TPM
- TPM quotes PCR values proving secure boot
- If PCRs match policy → Allow VPN access
- If compromised → Deny access, trigger security alert

#### 3. Integrity Measurement Architecture (IMA)
Linux kernel extension that continues measurement into OS runtime:
- Extends PCR-10 with hashes of every executed file
- Creates audit log of all executed code
- Enables detection of runtime compromises
- Proves which applications ran on the system

---

## Advantages of TPM-based Measured Boot

1. **Hardware Root of Trust**: CRTM in ROM cannot be modified by malware
2. **Tamper-Evident**: Any boot chain modification detectable via PCR mismatch
3. **Platform-Independent**: Works across diverse hardware (x86, ARM, RISC-V)
4. **Standards-Based**: TCG specifications ensure interoperability
5. **Passive Security**: Doesn't prevent boot (unlike Secure Boot), only measures
6. **Comprehensive Audit Trail**: Complete record of boot sequence

---

## Limitations and Considerations

1. **No Active Prevention**: Measured boot detects but doesn't block compromised components
2. **Reference Values Required**: Need "golden" PCR values to compare against
3. **Brittleness**: Minor updates (e.g., kernel patch) change PCR values
4. **Platform Reset Attack**: Physical attacker can reset TPM, starting fresh
5. **Complexity**: Requires sophisticated key management and policy infrastructure

---

## Conclusion

The TPM's internal architecture, centered around hardware-isolated cryptographic functions and tamper-evident PCRs, provides a robust foundation for trusted computing. PCRs enable measured boot by creating an irreversible hash chain representing the entire boot sequence. This mechanism allows systems to prove their integrity to both local applications (via sealed storage) and remote verifiers (via attestation), forming the cornerstone of hardware-based platform security. The combination of immutable root of trust, cryptographic measurements, and hardware-backed reporting makes TPM an essential component in modern secure computing architectures.

---

## References

1. Trusted Computing Group, "TPM 2.0 Library Specification", Part 1: Architecture, Rev. 1.59, November 2019
2. Arthur, W., & Challener, D. (2015). *A Practical Guide to TPM 2.0*. Apress
3. TCG PC Client Platform Firmware Profile Specification, Family 2.0, Level 00 Revision 1.05
4. Sailer, R., et al. (2004). "Design and Implementation of a TCG-based Integrity Measurement Architecture". *USENIX Security Symposium*

---

\newpage

