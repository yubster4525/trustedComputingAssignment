# Part A - Question 4: TPM vs TEE

## Compare TPM and TEE based on trust boundary, execution context, and use cases.

---

## Introduction

Trusted Platform Module (TPM) and Trusted Execution Environment (TEE) are complementary trusted computing technologies that address different aspects of platform security. While both establish hardware-based roots of trust, they differ fundamentally in their architecture, capabilities, and intended use cases. This answer provides a comprehensive comparison focusing on trust boundaries, execution contexts, and practical applications.

---

## 1. Trust Boundary Analysis

### TPM Trust Boundary

**Physical Boundary**:
- TPM is a **discrete hardware component** (or firmware implementation)
- Physically separate from main processor (discrete TPM chip)
- Connected via LPC, SPI, or I²C bus

**Trust Boundary Characteristics**:
```
┌──────────────────────────────────────────────────┐
│                  Platform                        │
│                                                  │
│  ┌─────────────┐     Bus      ┌──────────────┐  │
│  │     CPU     │◄────────────►│     TPM      │  │
│  │  (Untrusted)│              │  (Trusted)   │  │
│  │             │              │              │  │
│  │  - OS       │              │ - Crypto     │  │
│  │  - Apps     │              │ - Keys       │  │
│  │  - Kernel   │              │ - PCRs       │  │
│  └─────────────┘              └──────────────┘  │
│                                     ▲            │
│                         Trust Boundary (HW)     │
└─────────────────────────────────────┼────────────┘
                                      │
                              Physical isolation
```

**Scope of Trust**:
- **Trusted**: TPM chip internals, non-volatile memory, crypto engine
- **Untrusted**: Everything outside TPM (CPU, DRAM, OS, applications, peripherals)

**Properties**:
1. **Complete Isolation**: TPM operates independently of main processor
2. **Limited Attack Surface**: Simple, well-defined interface (TPM 2.0 command set)
3. **Passive Security**: Measures and reports but doesn't execute arbitrary code
4. **Bus Vulnerability**: Communication over system bus can be monitored (but encrypted/authenticated)

**Trust Assumptions**:
- TPM manufacturer is trustworthy
- TPM firmware has no vulnerabilities
- Physical tampering is prevented or detected
- Bus communication is properly authenticated

### TEE Trust Boundary

**Logical Boundary**:
- TEE is an **isolated execution environment within the main processor**
- Uses hardware features (CPU modes, memory protection) for isolation
- No physical separation from untrusted code

**Trust Boundary Characteristics (ARM TrustZone)**:
```
┌──────────────────────────────────────────────────┐
│                CPU Package                       │
│  ┌────────────────────┬──────────────────────┐   │
│  │   Normal World     │   Secure World       │   │
│  │   (Untrusted)      │   (Trusted)          │   │
│  ├────────────────────┼──────────────────────┤   │
│  │ EL0: Apps          │ EL0: Trusted Apps    │   │
│  │ EL1: Linux Kernel  │ EL1: Trusted OS      │   │
│  │ EL2: Hypervisor    │                      │   │
│  └────────────────────┴──────────────────────┘   │
│             ▲         Trust Boundary (CPU)       │
│             └──────────────┼──────────────────────┤
│                    EL3: Secure Monitor           │
└──────────────────────────────────────────────────┘
```

**Trust Boundary Characteristics (Intel SGX)**:
```
┌──────────────────────────────────────────────────┐
│                CPU Package                       │
│  ┌─────────────────────────────────────────┐     │
│  │         Untrusted Application           │     │
│  │  ┌──────────────────────────────────┐   │     │
│  │  │      Enclave (Trusted)           │   │     │
│  │  │  - Isolated code & data          │   │     │
│  │  │  - Encrypted in DRAM (MEE)       │   │     │
│  │  └──────────────────────────────────┘   │     │
│  │         Untrusted code                  │     │
│  └─────────────────────────────────────────┘     │
│             ▲         Trust Boundary (CPU)       │
└─────────────┴──────────────────────────────────┘
```

**Scope of Trust**:

**TrustZone**:
- **Trusted**: Secure World (Trusted OS, Trusted Applications, Secure Monitor)
- **Untrusted**: Normal World (Rich OS, applications, hypervisor)
- **Conditionally Trusted**: Certain peripherals marked as secure

**SGX**:
- **Trusted**: Enclave code and data (while in CPU)
- **Untrusted**: Everything outside enclave (OS, hypervisor, BIOS, other processes, even other enclaves)

**Properties**:
1. **Software-Hardware Co-design**: Requires both hardware support and software stack
2. **Larger TCB**: Includes Trusted OS (TrustZone) or enclave runtime (SGX)
3. **Active Security**: Executes code, performs computations in isolated environment
4. **Shared Resources**: Same CPU, cache, memory controller as untrusted code (side-channel risks)

**Trust Assumptions**:
- CPU manufacturer is trustworthy
- Hardware isolation mechanisms work correctly
- Secure Monitor/Enclave entry code is correct
- Side-channel attacks are mitigated
- Trusted OS (TrustZone) is vulnerability-free

### Comparative Analysis

| Aspect | TPM | TEE |
|--------|-----|-----|
| **Boundary Type** | Physical (hardware chip) | Logical (CPU isolation) |
| **Isolation Mechanism** | Separate processor | CPU security states/modes |
| **TCB Size** | Very small (~100KB firmware) | Larger (MB-scale Trusted OS or enclave) |
| **Attack Surface** | Minimal (command interface only) | Moderate (execution environment) |
| **Trust in Main CPU** | Not required | Required (TEE runs on main CPU) |
| **Side-Channel Risk** | Low (separate chip) | Higher (shared CPU resources) |
| **Physical Attacks** | Chip extraction possible | CPU compromise affects both worlds |

---

## 2. Execution Context Comparison

### TPM Execution Context

**Processing Capabilities**:
```
┌──────────────────────────────────────┐
│       TPM Internal Processing        │
├──────────────────────────────────────┤
│ ✓ Cryptographic Operations           │
│   - RSA sign/verify/encrypt/decrypt  │
│   - ECC operations                   │
│   - HMAC computation                 │
│   - Hash calculations                │
│                                      │
│ ✓ Key Management                     │
│   - Key generation                   │
│   - Key wrapping/unwrapping          │
│   - Key hierarchy management         │
│                                      │
│ ✓ PCR Operations                     │
│   - Read PCR values                  │
│   - Extend PCRs                      │
│   - Quote generation                 │
│                                      │
│ ✓ Sealed Storage                     │
│   - Seal data to PCR values          │
│   - Unseal with policy check         │
│                                      │
│ ✗ General Computation                │
│ ✗ Arbitrary Code Execution           │
│ ✗ File I/O                           │
│ ✗ Network Communication              │
└──────────────────────────────────────┘
```

**Execution Model**:
- **Command-Response Architecture**: Stateless request processing
- **No Operating System**: Bare-metal firmware only
- **Limited Resources**:
  - ~8-16 MHz processor
  - Few KB of volatile memory
  - 1-2 KB non-volatile memory
- **Sequential Processing**: One command at a time

**Performance Characteristics**:
```
Operation                    Typical Time
─────────────────────────────────────────
RSA 2048-bit Sign           500-1000 ms
ECC P-256 Sign              100-300 ms
SHA-256 Hash (1KB)          10-50 ms
PCR Extend                  20-100 ms
Create Key                  1-3 seconds
```

**Use Pattern**:
```c
// TPM usage pattern - Single operation at a time
tpm2_command(...);          // Send command
wait_for_completion();      // Wait (slow)
result = tpm2_response();   // Receive result
```

### TEE Execution Context

**Processing Capabilities (TrustZone)**:
```
┌──────────────────────────────────────┐
│    TEE Processing (Secure World)     │
├──────────────────────────────────────┤
│ ✓ Full CPU Capabilities               │
│   - ARM instruction set              │
│   - NEON/SIMD operations             │
│   - Floating point                   │
│   - Multiple cores (if available)    │
│                                      │
│ ✓ Rich Execution Environment         │
│   - Trusted OS (OP-TEE, Trusty)      │
│   - Memory management                │
│   - Thread scheduling                │
│   - IPC between TAs                  │
│                                      │
│ ✓ Secure Peripherals                 │
│   - Crypto accelerators              │
│   - Secure storage controller        │
│   - Secure timer                     │
│   - Secure UI (touchscreen, display) │
│                                      │
│ ✓ Arbitrary Code Execution           │
│   - Trusted Applications (TAs)       │
│   - Complex algorithms               │
│   - Real-time processing             │
└──────────────────────────────────────┘
```

**Execution Model**:
- **Multi-threaded**: Multiple Trusted Apps run concurrently
- **Full Operating System**: Trusted OS with scheduler, memory manager
- **Rich Resources**:
  - Full CPU speed (GHz-range)
  - MB-scale secure RAM
  - Hardware accelerators

**Performance Characteristics (TrustZone)**:
```
Operation                    Performance
──────────────────────────────────────────
World Switch (SMC)          1-5 microseconds
AES-256 Encryption (HW)     ~500 MB/s
RSA 2048 Sign (HW)          10-50 ms
SHA-256 Hash (HW)           >1 GB/s
PIN Verification            <1 ms
```

**Processing Capabilities (SGX)**:
```
┌──────────────────────────────────────┐
│     SGX Processing (Enclave)         │
├──────────────────────────────────────┤
│ ✓ Full x86-64 Instruction Set         │
│   - SSE, AVX, AVX-512                │
│   - Floating point                   │
│   - All user-mode instructions       │
│                                      │
│ ✓ Rich Application Environment       │
│   - C/C++ standard library           │
│   - Threading (enclave threads)      │
│   - Memory allocation                │
│   - SGX SDK / Runtimes               │
│                                      │
│ ✓ Cryptographic Libraries            │
│   - Intel IPP Crypto                 │
│   - mbedTLS in enclave               │
│   - OpenSSL (SGX port)               │
│                                      │
│ ✓ Complex Computations               │
│   - Machine learning inference       │
│   - Database queries                 │
│   - Signal processing                │
│                                      │
│ ✗ System Calls (must OCALL)          │
│ ✗ Direct I/O                         │
│ ✗ Network (through untrusted)        │
└──────────────────────────────────────┘
```

**Performance Characteristics (SGX)**:
```
Operation                    Overhead
──────────────────────────────────────────
EENTER/EEXIT                ~100-300 cycles
Memory Access (EPC hit)     0-5% overhead
Memory Access (EPC miss)    10-15% overhead
ECALL/OCALL                 ~8000 cycles
Enclave Computation         Near-native speed
```

### Execution Context Comparison

| Aspect | TPM | TEE (TrustZone) | TEE (SGX) |
|--------|-----|-----------------|-----------|
| **CPU Speed** | ~8-16 MHz | Full CPU (GHz) | Full CPU (GHz) |
| **Instruction Set** | Custom firmware | ARM A/R/M profile | x86-64 user mode |
| **Memory** | KB-scale | MB-scale | MB-scale (EPC limit) |
| **OS Environment** | None (firmware) | Trusted OS | Library OS optional |
| **Threading** | Single-threaded | Multi-threaded | Multi-threaded |
| **Arbitrary Code** | No | Yes (Trusted Apps) | Yes (Enclave code) |
| **I/O Access** | None | Secure peripherals | None (via OCALL) |
| **Performance** | Very slow | Near-native | Near-native |
| **Latency** | 100ms-seconds | Microseconds | Microseconds |

---

## 3. Use Case Analysis

### TPM Primary Use Cases

#### Use Case 1: Measured Boot and Attestation

**Scenario**: Enterprise laptop with full-disk encryption

**TPM Role**:
```
Boot Flow:
1. BIOS measures bootloader → TPM PCR[4]
2. Bootloader measures kernel → TPM PCR[8]
3. Kernel measures drivers → TPM PCR[10]

Disk Unsealing:
- Disk encryption key sealed to PCRs [0,1,2,4,7,8]
- TPM checks: Current PCRs == Sealed PCRs
- If match → Release key → Disk unlocked
- If mismatch (malware) → Deny → Disk stays encrypted

Remote Attestation:
- IT admin queries: "Is device compliant?"
- TPM quotes PCR values, signs with AIK
- Admin verifies: BIOS/OS approved versions
- Decision: Grant VPN access or quarantine
```

**Why TPM?**
- ✓ Persists through reboots (non-volatile storage)
- ✓ Cannot be bypassed by malware (hardware root of trust)
- ✓ Low power (always-on for early boot)
- ✓ Platform-wide view (measures entire boot chain)

**Why Not TEE?**
- ✗ Starts after OS boot (too late for firmware measurement)
- ✗ Relies on bootloader to initialize (chicken-egg problem)

#### Use Case 2: Cryptographic Key Storage

**Scenario**: IoT device with authentication credentials

**TPM Role**:
```
Key Hierarchy:
Storage Root Key (SRK) [never exported]
    └─► Device Identity Key
            └─► TLS Certificate Private Key

Operations:
- Generate key inside TPM
- Sign TLS handshake inside TPM
- Private key never exists in RAM
- Resistant to memory dumping attacks
```

**Why TPM?**
- ✓ Hardware-bound keys (cannot be copied to another device)
- ✓ Dictionary attack protection (rate limiting)
- ✓ Long-term key storage (survives power loss)

**Why Not TEE?**
- ✗ TEE loses state on reboot (volatile)
- ✗ Larger attack surface (complex Trusted OS)

#### Use Case 3: Secure Counters

**Scenario**: Digital Rights Management (DRM) - limit playbacks

**TPM Role**:
```
Non-volatile Counter:
- Initialize counter = 5 (5 plays allowed)
- Each playback: TPM decrements counter
- Counter persists across reboots
- Cannot be reset without authorization
```

**Why TPM?**
- ✓ Persistent storage
- ✓ Tamper-resistant counting

### TEE Primary Use Cases

#### Use Case 1: Mobile Payment (TrustZone)

**Scenario**: Smartphone contactless payment (Google Pay, Apple Pay)

**TEE Role**:
```
Payment Flow:
1. User taps phone at terminal
2. Normal World app receives transaction details
3. World switch to Secure World
4. Trusted UI displays amount on secure path
5. User enters PIN via secure touchscreen
6. Payment TA verifies PIN
7. Payment TA signs transaction with payment credential
8. Return signed transaction to Normal World
9. Transmit to payment network

Secure Assets:
- Payment credentials (EMV keys)
- PIN hash
- Transaction counter
- Secure display framebuffer
```

**Why TEE?**
- ✓ Secure UI (display and touch input isolated)
- ✓ Real-time performance (instant PIN verification)
- ✓ Cryptographic operations (sign transaction)
- ✓ Protects runtime secrets (PIN in use)

**Why Not TPM?**
- ✗ No user interface capability
- ✗ Too slow (seconds vs milliseconds)
- ✗ No runtime isolation (just storage)

#### Use Case 2: Biometric Authentication (TrustZone)

**Scenario**: Fingerprint unlock on smartphone

**TEE Role**:
```
Authentication Flow:
1. Fingerprint sensor captures image
2. Image sent directly to Secure World (bypasses Normal World)
3. Trusted App extracts features
4. Compares to enrolled template in secure storage
5. If match → Unlock credential released
6. If no match → Fail (no info leaked to Normal World)

Security:
- Normal World (Android) never sees fingerprint data
- Templates encrypted in secure storage
- Feature extraction in Secure World
```

**Why TEE?**
- ✓ High-throughput processing (image processing)
- ✓ Secure I/O path (sensor to Secure World direct)
- ✓ Protects sensitive biometric data
- ✓ Fast enough for real-time (<1 second)

**Why Not TPM?**
- ✗ Cannot process image data (insufficient compute)
- ✗ No peripheral access
- ✗ Too slow

#### Use Case 3: Confidential Cloud Computing (SGX)

**Scenario**: Medical research on encrypted patient data in AWS

**TEE Role**:
```
Computation Flow:
1. Hospital encrypts patient MRI scans
2. Uploads to AWS S3 (cloud sees only ciphertext)
3. Research enclave on AWS EC2:
   - Attests identity to hospital (MRENCLAVE)
   - Receives decryption key via secure channel
   - Decrypts data inside enclave
   - Runs analysis algorithm
   - Encrypts results
   - Returns to hospital
4. Plaintext data never visible to AWS

Security Model:
- AWS (cloud provider) is untrusted
- Enclave attestation proves code identity
- Memory encryption protects data in DRAM
- OS/hypervisor cannot access enclave
```

**Why TEE (SGX)?**
- ✓ Protects data from cloud provider
- ✓ Full computational capability (complex ML algorithms)
- ✓ Remote attestation (prove enclave identity)
- ✓ Enables new business models (processing encrypted data)

**Why Not TPM?**
- ✗ TPM doesn't execute code, just stores keys
- ✗ Cloud provider would still see data during processing

### Combined Use Cases (TPM + TEE)

#### Use Case: Secure Enterprise Workstation

```
┌─────────────────────────────────────────────────────┐
│                  Boot Process                       │
│  ┌──────────────────────────────────────────┐       │
│  │ TPM: Measured Boot                       │       │
│  │ - Measures UEFI, bootloader, kernel      │       │
│  │ - Extends PCRs with hash chain           │       │
│  │ - Seals disk key to PCR values           │       │
│  └──────────────────────────────────────────┘       │
└─────────────────────────────────────────────────────┘
                        │
                        ▼
┌─────────────────────────────────────────────────────┐
│             Runtime Security (TEE)                  │
│  ┌──────────────────────────────────────────┐       │
│  │ SGX Enclave: Document Processing         │       │
│  │ - User opens classified document         │       │
│  │ - Enclave decrypts content               │       │
│  │ - Renders in protected memory            │       │
│  │ - Applies watermarks                     │       │
│  └──────────────────────────────────────────┘       │
└─────────────────────────────────────────────────────┘
                        │
                        ▼
┌─────────────────────────────────────────────────────┐
│            Combined Attestation                     │
│  ┌──────────────────────────────────────────┐       │
│  │ To Remote Server:                        │       │
│  │ 1. TPM Quote (proves boot integrity)     │       │
│  │ 2. SGX Quote (proves enclave identity)   │       │
│  │ Combined: Platform AND Application trust │       │
│  └──────────────────────────────────────────┘       │
└─────────────────────────────────────────────────────┘
```

**Synergy**:
- **TPM**: Ensures platform booted correctly (no bootkit)
- **SGX**: Protects sensitive application data at runtime (no OS access)
- **Together**: Defense-in-depth, covers full stack (boot → runtime)

---

## 4. Architectural Strengths and Weaknesses

### TPM Strengths

1. **Minimal TCB**: Small firmware, limited attack surface
2. **Platform-Wide Trust**: Measures entire system boot chain
3. **Long-Term Storage**: Keys persist indefinitely
4. **Physical Isolation**: Separate chip reduces attack vectors
5. **Standardization**: TCG specs ensure interoperability
6. **Low Cost**: Inexpensive to integrate (~$1-5 per device)

### TPM Weaknesses

1. **Limited Computation**: Cannot execute application code
2. **Slow Performance**: Cryptographic operations take seconds
3. **No Runtime Protection**: Only protects boot time, not execution
4. **No Code Isolation**: Cannot run trusted applications
5. **Static Trust**: Sealed data policy hard to update

### TEE Strengths (TrustZone)

1. **Rich Execution**: Full application environment
2. **High Performance**: GHz-speed CPU, hardware accelerators
3. **Runtime Protection**: Isolates code during execution
4. **Secure Peripherals**: Direct control of display, sensors
5. **Flexible**: Can implement various security services

### TEE Weaknesses (TrustZone)

1. **Large TCB**: Trusted OS is complex (MB of code)
2. **Vulnerability Risk**: More code → more potential bugs
3. **Limited Attestation**: Not standardized across vendors
4. **Volatile**: State lost on reboot (requires secure storage)
5. **Side Channels**: Shared CPU cache enables attacks

### TEE Strengths (SGX)

1. **Fine-Grained Isolation**: Per-application enclaves
2. **Small TCB**: Only enclave code trusted, not OS
3. **Memory Encryption**: Protects DRAM contents
4. **Strong Attestation**: Cryptographically verifiable
5. **Cloud-Friendly**: Protects from infrastructure owner

### TEE Weaknesses (SGX)

1. **EPC Limitation**: Small secure memory (128-256MB)
2. **Performance Overhead**: Memory encryption cost
3. **No Secure I/O**: Cannot protect display/keyboard
4. **Side Channels**: Spectre, cache timing attacks
5. **Intel Dependency**: Vendor lock-in, Intel controls attestation

---

## 5. Selection Criteria

### Choose TPM When:

✓ Need to verify boot integrity
✓ Require long-term key storage
✓ Platform-level attestation required
✓ Disk encryption key protection
✓ Low power budget (IoT devices)
✓ Simple command-response model sufficient

### Choose TEE When:

✓ Need to execute trusted code at runtime
✓ Require high computational throughput
✓ Secure UI needed (payments, biometrics)
✓ Processing sensitive data in real-time
✓ Application-level isolation required
✓ Cloud confidential computing

### Use Both When:

✓ Maximum security required (defense-in-depth)
✓ Both boot-time AND runtime protection needed
✓ Comprehensive attestation (platform + application)
✓ Regulatory compliance demands multiple controls
✓ High-value targets (government, finance, healthcare)

---

## Conclusion

TPM and TEE serve complementary roles in trusted computing. TPM excels at providing a hardware root of trust for platform integrity, measured boot, and secure key storage, operating as a passive measurement and storage device with minimal attack surface. TEE provides an active execution environment for trusted applications, offering runtime isolation with full computational capabilities.

The trust boundary in TPM is physical (discrete chip), while TEE's boundary is logical (CPU isolation modes). TPM's execution context is limited to cryptographic operations and state storage, while TEE supports arbitrary code execution with near-native performance. Use cases differ accordingly: TPM for boot attestation and long-term storage, TEE for runtime processing of sensitive data.

Modern secure systems increasingly deploy both technologies in tandem: TPM establishes trust from the first instruction, while TEE maintains isolation throughout runtime. This combination provides comprehensive protection across the full system lifecycle from power-on to shutdown.

---

## References

1. Trusted Computing Group, "TPM 2.0 Library Specification", Part 1: Architecture, Rev. 1.59, 2019
2. Arthur, W., & Challener, D. (2015). *A Practical Guide to TPM 2.0*. Apress
3. ARM, "ARM Security Technology - Building a Secure System using TrustZone Technology", 2022
4. Costan, V., & Devadas, S. (2016). "Intel SGX Explained". *IACR Cryptology ePrint Archive*
5. Sailer, R., et al. (2004). "Design and Implementation of a TCG-based Integrity Measurement Architecture". *USENIX Security*
6. Pinto, S., & Santos, N. (2019). "Demystifying ARM TrustZone: A Comprehensive Survey". *ACM Computing Surveys*
7. McKeen, F., et al. (2013). "Innovative Instructions and Software Model for Isolated Execution". *HASP Workshop*
