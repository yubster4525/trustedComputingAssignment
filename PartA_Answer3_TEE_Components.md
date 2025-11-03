# Part A - Question 3: TEE Components

## Explain the core components and operational flow of a Trusted Execution Environment (TEE), using ARM TrustZone or Intel SGX as examples.

---

## Introduction

A Trusted Execution Environment (TEE) is an isolated execution environment that provides security features such as isolated execution, integrity of applications running in the TEE, and confidentiality of data. TEE enables secure execution of code alongside a rich operating system while providing strong isolation guarantees. This answer explores two prominent TEE implementations: ARM TrustZone and Intel SGX, examining their architecture, core components, and operational flows.

---

## Part 1: ARM TrustZone Architecture

### Overview

ARM TrustZone technology creates two parallel execution environments on a single physical processor core:
- **Normal World**: Runs rich OS (Linux, Android) and untrusted applications
- **Secure World**: Runs Trusted OS and trusted applications (TAs)

This is achieved through hardware-enforced isolation at the processor level.

### Core Components

#### 1. Processor Security Extensions

**Secure Monitor Mode (EL3/Exception Level 3)**
- Highest privilege level in ARMv8-A architecture
- Acts as gatekeeper between Normal and Secure Worlds
- Runs Secure Monitor firmware
- **Responsibilities**:
  - Handle world context switches
  - Save/restore processor state during transitions
  - Route exceptions and interrupts to appropriate world
  - Enforce security policies

**Secure and Non-Secure States**
- CPU has additional security state bit (NS bit) in system control register
- NS=0: Secure World (Secure state)
- NS=1: Normal World (Non-secure state)
- All processor states (registers, cache, TLB) tagged with NS bit

**Exception Levels in Each World**:
```
┌────────────────────────────────┬────────────────────────────────┐
│         Normal World           │         Secure World           │
├────────────────────────────────┼────────────────────────────────┤
│ EL2: Hypervisor (Optional)     │ EL2: Secure Hypervisor (Rare)  │
│ EL1: Rich OS Kernel (Linux)    │ EL1: Trusted OS Kernel         │
│ EL0: Applications              │ EL0: Trusted Applications      │
├────────────────────────────────┴────────────────────────────────┤
│           EL3: Secure Monitor (World Switch)                   │
└──────────────────────────────────────────────────────────────────┘
```

#### 2. Memory Protection Components

**TrustZone Address Space Controller (TZASC)**
- Hardware component filtering memory transactions
- Marks memory regions as Secure or Non-Secure
- Configuration:
  ```c
  TZASC_Region_Config {
      base_address: 0x8000_0000,
      size: 64MB,
      security: SECURE,
      permissions: READ_WRITE,
      accessible_from: SECURE_WORLD_ONLY
  }
  ```
- **Enforcement**:
  - Normal World transactions to Secure memory → Blocked (bus error)
  - Secure World can access both Secure and Non-Secure memory

**TrustZone Protection Controller (TZPC)**
- Controls peripheral access (UART, SPI, crypto engines)
- Each peripheral tagged as Secure or Non-Secure
- Example configuration:
  ```
  Crypto Engine: SECURE (only Secure World can access)
  UART0: NON-SECURE (Normal World can use)
  Secure Storage Controller: SECURE
  ```

**Memory Management Unit (MMU) Extensions**
- Separate page tables for Secure and Normal Worlds
- NS bit in page table entries
- Prevents Normal World from mapping Secure memory

#### 3. Secure Boot ROM

**BootROM Responsibilities**:
- First code executed after reset (immutable)
- Establishes Secure World environment
- Verifies signature of next boot stage (Trusted Firmware)
- Loads and initializes Secure Monitor

**Boot Sequence**:
```
Power-On Reset
    ↓
BootROM (Secure World, EL3)
    ↓ [Verify signature]
ARM Trusted Firmware (ATF)
    ↓ [Initialize Secure World]
Trusted OS (e.g., OP-TEE)
    ↓ [World switch]
Normal World Bootloader (U-Boot/UEFI)
    ↓
Rich OS (Linux/Android)
```

#### 4. Secure Monitor

**ARM Trusted Firmware (ATF)** - Reference Implementation:

**Functions**:
1. **World Context Switch**:
   ```c
   // Simplified Secure Monitor Call handler
   void handle_smc(uint32_t smc_id, context_t *ns_context) {
       // 1. Save Normal World context
       save_context(ns_context);

       // 2. Change NS bit (world switch)
       set_secure_state();

       // 3. Restore Secure World context
       context_t *s_context = get_secure_context();
       restore_context(s_context);

       // 4. Jump to Trusted OS
       jump_to_secure_world(smc_id);
   }
   ```

2. **Interrupt Routing**:
   - FIQ (Fast Interrupt) → Routed to Secure World
   - IRQ (Regular Interrupt) → Routed to Normal World
   - Secure Monitor configures GIC (Generic Interrupt Controller)

3. **Power State Coordination**:
   - Manages CPU sleep/wake states
   - Ensures Secure World state preserved during suspend

**Secure Monitor Call (SMC) Instruction**:
- Privileged instruction triggering world switch
- Format: `SMC #imm`
- Causes exception to EL3 Secure Monitor
- Used by Normal World to invoke Secure World services

#### 5. Trusted Operating System

Popular implementations:
- **OP-TEE** (Open Portable TEE) - Open source
- **Trusty** (Google) - Used in Android
- **QSEE** (Qualcomm Secure Execution Environment)

**OP-TEE Architecture**:
```
┌─────────────────────────────────────────┐
│         Secure World (OP-TEE)           │
├─────────────────────────────────────────┤
│  ┌────────┐  ┌────────┐  ┌────────┐    │
│  │   TA   │  │   TA   │  │   TA   │    │ EL0: Trusted Apps
│  │ (DRM)  │  │ (Auth) │  │ (Pay)  │    │
│  └────────┘  └────────┘  └────────┘    │
├─────────────────────────────────────────┤
│     TEE Internal API (GP Standard)      │
├─────────────────────────────────────────┤
│       OP-TEE Kernel Services            │ EL1: Trusted OS
│   - Memory Management                   │
│   - Scheduling                          │
│   - Crypto Library                      │
│   - Secure Storage                      │
└─────────────────────────────────────────┘
```

**Responsibilities**:
- Load and verify Trusted Applications (TAs)
- Manage TA lifecycle (load, execute, unload)
- Provide TEE Internal API (GlobalPlatform standard)
- Secure Storage: Encrypt data at rest
- Cryptographic services: AES, RSA, ECC, HMAC
- Shared memory management with Normal World

#### 6. Trusted Applications (TAs)

**Structure**:
```c
// Example TA for PIN verification
#include <tee_internal_api.h>

TEE_Result TA_CreateEntryPoint(void) {
    // Initialize TA
    return TEE_SUCCESS;
}

TEE_Result TA_InvokeCommandEntryPoint(
    void *session_context,
    uint32_t cmd_id,
    uint32_t param_types,
    TEE_Param params[4])
{
    switch (cmd_id) {
        case CMD_VERIFY_PIN:
            return verify_pin(params[0].value.a);
        case CMD_SIGN_TRANSACTION:
            return sign_transaction(
                params[0].memref.buffer,
                params[0].memref.size
            );
        default:
            return TEE_ERROR_BAD_PARAMETERS;
    }
}
```

**Isolation**:
- Each TA runs in separate memory space
- MMU-based isolation between TAs
- TAs cannot directly communicate (must use TEE OS services)

#### 7. Normal World Components

**Client Application (CA)**:
- Runs in Rich OS (Linux/Android)
- Initiates communication with TAs
- Uses TEE Client API (GlobalPlatform)

**TEE Driver**:
- Kernel driver in Linux (`/dev/tee0`, `/dev/teepriv0`)
- Manages communication channel
- Allocates shared memory

**libteec (TEE Client Library)**:
- Userspace library providing TEE Client API
- Functions:
  - `TEEC_InitializeContext()`: Connect to TEE
  - `TEEC_OpenSession()`: Open session with TA
  - `TEEC_InvokeCommand()`: Call TA function
  - `TEEC_CloseSession()`: End session

### Operational Flow: Secure Payment Example

#### Scenario
Mobile banking app needs to sign a payment transaction using a cryptographic key that must never be exposed to the Normal World OS (even if compromised).

#### Flow Diagram
```
┌──────────────────┐                          ┌──────────────────┐
│  Normal World    │                          │  Secure World    │
├──────────────────┤                          ├──────────────────┤
│                  │                          │                  │
│ 1. Banking App   │                          │                  │
│    User clicks   │                          │                  │
│    "Pay $100"    │                          │                  │
│        │         │                          │                  │
│        ▼         │                          │                  │
│ 2. Prepare       │                          │                  │
│    transaction   │                          │                  │
│    data          │                          │                  │
│        │         │                          │                  │
│        ▼         │                          │                  │
│ 3. TEEC_Invoke   │                          │                  │
│    Command()     │─────────────┐            │                  │
│                  │             │            │                  │
│                  │         4. SMC           │                  │
│                  │             │            │                  │
│                  │             ▼            │                  │
│                  │      ┌──────────────┐    │                  │
│                  │      │EL3: Secure   │    │                  │
│                  │      │   Monitor    │    │                  │
│                  │      │              │    │                  │
│                  │      │5. Context    │    │                  │
│                  │      │   Switch     │    │                  │
│                  │      └──────┬───────┘    │                  │
│                  │             │            │                  │
│                  │             └───────────►│ 6. OP-TEE Kernel │
│                  │                          │    Dispatch      │
│                  │                          │        │         │
│                  │                          │        ▼         │
│                  │                          │ 7. Payment TA    │
│                  │                          │    - Validate    │
│                  │                          │    - Load key    │
│                  │                          │    - Sign data   │
│                  │                          │        │         │
│                  │                          │        ▼         │
│                  │             ┌────────────│ 8. Return result │
│                  │             │            │                  │
│                  │         9. SMC           │                  │
│                  │             │            │                  │
│                  │      ┌──────▼───────┐    │                  │
│                  │      │EL3: Secure   │    │                  │
│                  │      │   Monitor    │    │                  │
│                  │      │              │    │                  │
│                  │      │10. Context   │    │                  │
│                  │      │    Switch    │    │                  │
│                  │      └──────┬───────┘    │                  │
│                  │             │            │                  │
│ 11. Return to    │◄────────────┘            │                  │
│     Banking App  │                          │                  │
│        │         │                          │                  │
│        ▼         │                          │                  │
│ 12. Send signed  │                          │                  │
│     transaction  │                          │                  │
│     to bank      │                          │                  │
└──────────────────┘                          └──────────────────┘
```

#### Detailed Steps

**Step 1-2: Transaction Initiation (Normal World)**
```c
// Banking app code (C/Java/Kotlin)
Transaction tx = {
    from: "Alice",
    to: "Bob",
    amount: 100.00,
    currency: "USD"
};
```

**Step 3: TEE Client API Call (Normal World)**
```c
#include <tee_client_api.h>

// Initialize connection to TEE
TEEC_Context ctx;
TEEC_Session session;
TEEC_Result res;

res = TEEC_InitializeContext(NULL, &ctx);

// Open session with Payment TA
TEEC_UUID payment_ta_uuid = PAYMENT_TA_UUID;
res = TEEC_OpenSession(&ctx, &session, &payment_ta_uuid,
                       TEEC_LOGIN_PUBLIC, NULL, NULL, NULL);

// Prepare parameters
TEEC_Operation op;
op.paramTypes = TEEC_PARAM_TYPES(
    TEEC_MEMREF_TEMP_INPUT,   // Transaction data
    TEEC_MEMREF_TEMP_OUTPUT,  // Signature output
    TEEC_NONE, TEEC_NONE
);
op.params[0].tmpref.buffer = &tx;
op.params[0].tmpref.size = sizeof(tx);

// Invoke command
res = TEEC_InvokeCommand(&session, CMD_SIGN_TRANSACTION,
                         &op, NULL);
```

**Step 4: Secure Monitor Call (World Switch)**
```assembly
; ARM assembly - SMC instruction
; Executed by TEE driver in Linux kernel

STP     x29, x30, [sp, #-16]!   ; Save registers
LDR     x0, =SMC_CALL_TEE       ; SMC function ID
LDR     x1, =session_id         ; Session ID
LDR     x2, =command_id         ; Command ID
SMC     #0                      ; Trigger world switch
LDP     x29, x30, [sp], #16     ; Restore registers
```

**Step 5: Secure Monitor Context Switch (EL3)**
```c
// ARM Trusted Firmware - Secure Monitor handler
void sm_handler(uint64_t smc_id, uint64_t x1, uint64_t x2) {
    // 1. Validate SMC is from authorized source
    if (!is_valid_smc_caller()) {
        return ERROR_ACCESS_DENIED;
    }

    // 2. Save Normal World CPU context
    save_gp_regs(&normal_world_ctx);   // x0-x30, SP, PC
    save_sys_regs(&normal_world_ctx);  // SCTLR, TCR, MAIR, etc.
    save_fpu_regs(&normal_world_ctx);  // v0-v31 (NEON/FP)

    // 3. Set Secure state
    write_scr_el3(SCR_EL3_SECURE_STATE);

    // 4. Restore Secure World CPU context
    restore_sys_regs(&secure_world_ctx);
    restore_gp_regs(&secure_world_ctx);
    restore_fpu_regs(&secure_world_ctx);

    // 5. Jump to OP-TEE entry point
    eret();  // Exception return to Secure World EL1
}
```

**Step 6: OP-TEE Dispatcher (Secure World)**
```c
// OP-TEE kernel - Command dispatcher
void tee_entry_std_handler(struct thread_smc_args *args) {
    uint32_t session_id = args->a1;
    uint32_t cmd_id = args->a2;

    // 1. Look up session
    struct tee_session *sess = tee_session_find(session_id);
    if (!sess) {
        args->a0 = TEE_ERROR_BAD_PARAMETERS;
        return;
    }

    // 2. Verify TA is loaded
    struct tee_ta *ta = sess->ta;
    if (!ta->loaded) {
        load_and_verify_ta(ta);
    }

    // 3. Dispatch to TA
    args->a0 = ta->invoke_command(sess, cmd_id, args->params);
}
```

**Step 7: Trusted Application Execution (Secure World)**
```c
// Payment TA - Sign transaction
TEE_Result sign_transaction(void *tx_data, size_t tx_size,
                           void *sig_out, size_t *sig_size) {
    TEE_Result res;
    TEE_ObjectHandle key_handle;
    TEE_OperationHandle op_handle;

    // 1. Load signing key from secure storage
    res = TEE_OpenPersistentObject(
        TEE_STORAGE_PRIVATE,
        "payment_signing_key", 18,
        TEE_DATA_FLAG_ACCESS_READ,
        &key_handle
    );
    if (res != TEE_SUCCESS) {
        return res;
    }

    // 2. Validate transaction data
    if (!validate_transaction(tx_data, tx_size)) {
        TEE_CloseObject(key_handle);
        return TEE_ERROR_BAD_PARAMETERS;
    }

    // 3. Create signature operation
    res = TEE_AllocateOperation(&op_handle,
                                TEE_ALG_RSASSA_PKCS1_V1_5_SHA256,
                                TEE_MODE_SIGN, 2048);

    // 4. Set key
    res = TEE_SetOperationKey(op_handle, key_handle);

    // 5. Sign the transaction
    res = TEE_AsymmetricSignDigest(
        op_handle,
        NULL, 0,
        tx_data, tx_size,
        sig_out, sig_size
    );

    // 6. Cleanup
    TEE_FreeOperation(op_handle);
    TEE_CloseObject(key_handle);

    return TEE_SUCCESS;
}
```

**Security Guarantees**:
- Private signing key never leaves Secure World
- Key stored encrypted in Secure Storage
- Normal World (including Linux kernel) cannot access key
- Even if Android OS compromised, key remains safe

**Step 8-10: Return Path (World Switch back)**
- TA returns result to OP-TEE kernel
- OP-TEE prepares return values in shared memory
- Executes SMC to return to Normal World
- Secure Monitor switches context back

**Step 11-12: Use Signed Transaction (Normal World)**
```c
// Banking app receives signature
if (res == TEEC_SUCCESS) {
    signature = op.params[1].tmpref.buffer;
    sig_len = op.params[1].tmpref.size;

    // Send signed transaction to bank server
    send_to_bank(tx, signature, sig_len);
}

// Cleanup
TEEC_CloseSession(&session);
TEEC_FinalizeContext(&ctx);
```

---

## Part 2: Intel SGX Architecture

### Overview

Intel Software Guard Extensions (SGX) provides a different TEE approach:
- Creates **enclaves**: isolated memory regions within a process
- Protects enclave memory from OS, hypervisor, BIOS, and even hardware attacks (except CPU)
- Memory encryption engine ensures DRAM contains only ciphertext

### Core Components

#### 1. Processor Reserved Memory (PRM)

**Encrypted Page Cache (EPC)**:
- Special DRAM region (typically 128MB-256MB)
- Stores enclave code and data
- Managed exclusively by CPU
- **Key Properties**:
  - OS cannot directly access (causes #GP exception)
  - Encrypted in DRAM using Memory Encryption Engine (MEE)
  - Plaintext exists only inside CPU package
  - Protected from:
    - Malicious OS/hypervisor
    - DMA attacks
    - Cold boot attacks
    - Physical memory probing

**EPC Page Types**:
```
PT_SECS: SGX Enclave Control Structure (metadata)
PT_TCS: Thread Control Structure (enclave entry points)
PT_REG: Regular pages (code and data)
PT_VA: Version Array (for paging support)
PT_TRIM: Trimmed pages (being removed)
```

**EPC Map (EPCM)**:
- Metadata structure tracking EPC pages
- One entry per 4KB page
- Fields:
  ```c
  struct epcm_entry {
      uint64_t valid: 1;
      uint64_t read: 1;
      uint64_t write: 1;
      uint64_t execute: 1;
      uint64_t page_type: 8;
      uint64_t enclave_secs: 48;  // Which enclave owns this
      uint64_t address: 48;       // Linear address
  };
  ```
- Enforced by hardware on every memory access

#### 2. Memory Encryption Engine (MEE)

**Encryption Architecture**:
```
┌──────────────────────────────────────────────────────────┐
│                      CPU Package                         │
│  ┌────────────┐         ┌──────────────┐                 │
│  │   Core     │◄────────┤  Last Level  │                 │
│  │            │         │    Cache     │                 │
│  └────────────┘         └──────┬───────┘                 │
│                                │ Plaintext               │
│                         ┌──────▼───────┐                 │
│                         │   Memory     │                 │
│                         │  Encryption  │                 │
│                         │   Engine     │                 │
│                         │   (MEE)      │                 │
│                         └──────┬───────┘                 │
└────────────────────────────────┼──────────────────────────┘
                                 │ Ciphertext
                         ┌───────▼────────┐
                         │  System DRAM   │
                         │  (Encrypted)   │
                         └────────────────┘
```

**Encryption Method**:
- AES-128 in counter mode (CTR)
- Per-page encryption keys derived from master key
- 56-bit MAC for integrity verification
- Merkle tree for replay protection

**Performance Impact**:
- Memory bandwidth reduction (~10-15%)
- Latency increase for memory access
- CPU package power increase

#### 3. SGX Instructions

**Enclave Management Instructions** (Ring 0 only):
- `ECREATE`: Create new enclave (allocate SECS)
- `EADD`: Add page to enclave
- `EEXTEND`: Extend enclave measurement (builds MRENCLAVE)
- `EINIT`: Initialize enclave after loading complete
- `EREMOVE`: Remove page from enclave
- `EWB`: Write back EPC page (paging out)
- `ELDB/ELDU`: Load blocked/unblocked page (paging in)

**Enclave Execution Instructions** (Ring 3):
- `EENTER`: Enter enclave from normal execution
- `EEXIT`: Exit enclave to normal execution
- `ERESUME`: Resume after asynchronous exit (AEX)
- `EGETKEY`: Derive cryptographic keys inside enclave
- `EREPORT`: Generate enclave report for local attestation
- `EACCEPT/EACCEPTCOPY`: Accept page addition inside enclave

#### 4. Enclave Measurement (MRENCLAVE)

**Measurement Process**:
```c
// During enclave build
Initial_Hash = SHA256("");

For each page added (EADD instruction):
    page_info = {
        page_content: page_data,  // 4096 bytes
        offset: page_offset,      // Position in enclave
        security_info: page_permissions (RWX)
    };

    For each 256-byte chunk in page (16 chunks):
        EEXTEND:
            Current_Hash = SHA256(
                Current_Hash ||
                chunk_data
            );

Final_MRENCLAVE = Current_Hash;
```

**MRENCLAVE Properties**:
- 256-bit SHA-256 hash
- Uniquely identifies enclave contents and layout
- Changes if any code/data/layout changes
- Used for:
  - Attestation (proving enclave identity)
  - Sealing keys (binding data to specific enclave)

#### 5. Architectural Enclaves

**Launch Enclave (LE)**:
- Controls which enclaves can launch
- Originally managed by Intel (controversial)
- Flexible Launch Control (FLC): Now controlled by OS/platform owner
- Generates `EINITTOKEN` authorizing enclave launch

**Provisioning Enclave (PE)**:
- Communicates with Intel Attestation Service (IAS)
- Provisions platform with attestation keys
- Generates platform-unique keys

**Quoting Enclave (QE)**:
- Generates attestation quotes
- Signs reports with Intel-backed key
- Enables remote attestation

#### 6. Enclave Entry and Exit

**Enclave Control Structure (SECS)**:
```c
struct secs {
    uint64_t size;              // Enclave size
    uint64_t base_address;      // Start address
    uint32_t ssa_frame_size;    // State save area size
    uint8_t mrenclave[32];      // Enclave measurement
    uint8_t mrsigner[32];       // Signer's key hash
    uint64_t attributes;        // DEBUG, MODE64BIT, etc.
    uint64_t xfrm;              // Extended features mask
};
```

**Thread Control Structure (TCS)**:
```c
struct tcs {
    uint64_t state;             // AVAILABLE, EXECUTING
    uint64_t flags;             // DBGOPTIN
    uint64_t ossa;              // Offset of SSA
    uint32_t cssa;              // Current SSA index
    uint32_t nssa;              // Number of SSAs
    uint64_t oentry;            // Entry point offset
    uint64_t ofsbasgx;          // FS base for enclave
    uint64_t ogsbasgx;          // GS base for enclave
    uint32_t fslimit;           // FS segment limit
    uint32_t gslimit;           // GS segment limit
};
```

**State Save Area (SSA)**:
- Saves CPU state during Asynchronous Enclave Exit (AEX)
- Caused by interrupts, exceptions, or external events
- Allows enclave to resume after handling event outside

### Operational Flow: Confidential Machine Learning Inference

#### Scenario
Cloud service provides ML inference API. Client has sensitive medical images and wants predictions without revealing images to cloud provider.

#### Setup Phase

```
┌──────────────────────────────────────────────────────────┐
│               ML Service Provider                        │
│                                                          │
│ 1. Develop enclave code                                  │
│    - Loads ML model                                      │
│    - Accepts encrypted input                             │
│    - Performs inference                                  │
│    - Returns encrypted result                            │
│                                                          │
│ 2. Build and measure enclave                             │
│    $ sgx_sign sign -enclave ml_enclave.so \              │
│              -key provider_key.pem \                     │
│              -out ml_enclave.signed.so                   │
│    MRENCLAVE: a3f8c2...b4d6 (enclave measurement)        │
│                                                          │
│ 3. Publish MRENCLAVE                                     │
│    - Post on website                                     │
│    - Sign with company certificate                       │
│    - Clients will verify this value                      │
└──────────────────────────────────────────────────────────┘
```

#### Runtime Flow

```
┌─────────────────────┐                    ┌─────────────────────┐
│      Client         │                    │   Cloud Server      │
│ (Untrusted App)     │                    │  (Untrusted App)    │
└──────────┬──────────┘                    └──────────┬──────────┘
           │                                          │
           │                                          │
    ┌──────▼──────┐                          ┌───────▼────────┐
    │ 1. Medical  │                          │ 2. Create SGX  │
    │    Image    │                          │    Enclave     │
    │             │                          │   ECREATE      │
    │    DICOM    │                          │   EADD pages   │
    │             │                          │   EEXTEND      │
    └─────────────┘                          │   EINIT        │
                                             └────────────────┘
           │                                          │
           │ 3. Request attestation                   │
           │────────────────────────────────────────►│
           │                                          │
           │                                  ┌───────▼────────┐
           │                                  │ 4. ENCLAVE     │
           │                                  │  EREPORT →     │
           │                                  │   Report       │
           │                                  └───────┬────────┘
           │                                          │
           │                                  ┌───────▼────────┐
           │                                  │ 5. Quoting     │
           │                                  │    Enclave     │
           │                                  │  Sign report   │
           │                                  └───────┬────────┘
           │                                          │
           │ 6. Attestation quote (MRENCLAVE)         │
           │◄─────────────────────────────────────────┤
           │                                          │
    ┌──────▼──────┐                                  │
    │ 7. Verify   │                                  │
    │  - Check    │                                  │
    │    MRENCLAVE│                                  │
    │    matches  │                                  │
    │  - Verify   │                                  │
    │    Intel    │                                  │
    │    signature│                                  │
    └─────────────┘                                  │
           │                                          │
    ┌──────▼──────┐                                  │
    │ 8. Establish│                                  │
    │   Secure    │◄────────────────────────────────►│
    │   Channel   │    Diffie-Hellman key exchange   │
    │   (TLS to   │    Enclave public key in quote   │
    │   enclave)  │                                  │
    └─────────────┘                                  │
           │                                          │
    ┌──────▼──────┐                          ┌───────▼────────┐
    │ 9. Encrypt  │        Encrypted          │ 10. EENTER     │
    │    medical  │       medical image       │                │
    │    image    ├──────────────────────────►│    Decrypt     │
    │    with     │                           │    inside      │
    │    session  │                           │    enclave     │
    │    key      │                           │                │
    └─────────────┘                           │    Load model  │
                                              │                │
                                              │    Run         │
                                              │    inference   │
                                              │                │
                                              │    Encrypt     │
                                              │    result      │
                                              │                │
                                              │    EEXIT       │
                                              └───────┬────────┘
           │                                          │
           │    11. Encrypted result                  │
           │◄─────────────────────────────────────────┤
           │                                          │
    ┌──────▼──────┐                                  │
    │ 12. Decrypt │                                  │
    │    result   │                                  │
    │             │                                  │
    │  "Diagnosis:│                                  │
    │   Benign"   │                                  │
    └─────────────┘                                  │
```

#### Detailed Code Flow

**Step 2-5: Enclave Creation and Attestation**

```c
// Server untrusted code
#include <sgx_urts.h>
#include <sgx_quote.h>

sgx_enclave_id_t eid;
sgx_status_t ret;

// 2. Create enclave
ret = sgx_create_enclave(
    "ml_enclave.signed.so",
    SGX_DEBUG_FLAG,
    NULL,
    NULL,
    &eid,
    NULL
);

// 3-4. Generate report (inside enclave)
sgx_report_t report;
ecall_generate_report(eid, &report, NULL);

// 5. Get quote from Quoting Enclave
sgx_quote_t *quote;
uint32_t quote_size;

sgx_calc_quote_size(NULL, 0, &quote_size);
quote = (sgx_quote_t*)malloc(quote_size);

ret = sgx_get_quote(
    &report,
    SGX_UNLINKABLE_SIGNATURE,
    &spid,           // Service Provider ID
    NULL,
    NULL, 0,
    NULL,
    quote,
    quote_size
);

// 6. Send quote to client
send_to_client(quote, quote_size);
```

**Inside Enclave - Report Generation**:
```c
// ml_enclave.c - Enclave trusted code
#include <sgx_trts.h>
#include <sgx_utils.h>

sgx_status_t ecall_generate_report(
    sgx_report_t *report,
    sgx_target_info_t *qe_target)
{
    // Prepare report data (include enclave public key)
    sgx_report_data_t report_data = {0};
    generate_keypair();  // Generate enclave DH key pair
    memcpy(report_data.d, public_key, sizeof(public_key));

    // Generate report
    return sgx_create_report(
        qe_target,      // Target: Quoting Enclave
        &report_data,   // Custom data (public key)
        report
    );
}
```

**Step 7: Client Verification**
```python
# Client code (Python)
import requests
import cryptography
from sgx_verify import verify_quote

# Receive quote from server
quote = server.get_attestation_quote()

# Verify quote with Intel Attestation Service (IAS)
ias_response = requests.post(
    'https://api.trustedservices.intel.com/sgx/dev/attestation/v4/report',
    headers={'Content-Type': 'application/json'},
    json={'isvEnclaveQuote': quote}
)

report = ias_response.json()

# Verify IAS signature
verify_ias_signature(report, ias_cert)

# Check MRENCLAVE matches expected value
expected_mrenclave = "a3f8c2...b4d6"  # Published by provider
actual_mrenclave = report['isvEnclaveQuoteBody']['mrEnclave']

if actual_mrenclave != expected_mrenclave:
    raise SecurityError("Enclave measurement mismatch!")

# Extract enclave public key from report
enclave_public_key = report['isvEnclaveQuoteBody']['reportData'][:64]
```

**Step 8-10: Secure Communication and Inference**
```c
// Enclave code - Decrypt and process
sgx_status_t ecall_process_image(
    const uint8_t *encrypted_image,
    size_t encrypted_size,
    uint8_t *encrypted_result,
    size_t *result_size)
{
    // 1. Decrypt image using session key
    uint8_t *image_data = (uint8_t*)malloc(MAX_IMAGE_SIZE);
    decrypt_aes_gcm(
        encrypted_image,
        encrypted_size,
        session_key,  // Established via DH
        image_data
    );

    // 2. Load ML model (stored encrypted in enclave)
    load_ml_model();

    // 3. Run inference
    float *prediction = run_inference(image_data, model);

    // 4. Encrypt result
    encrypt_aes_gcm(
        prediction,
        sizeof(float) * num_classes,
        session_key,
        encrypted_result,
        result_size
    );

    // 5. Clear sensitive data from enclave memory
    memset_s(image_data, MAX_IMAGE_SIZE, 0, MAX_IMAGE_SIZE);

    return SGX_SUCCESS;
}
```

**Security Guarantees**:
1. **Confidentiality**: Medical image encrypted in transit and at rest
   - Plaintext exists only inside enclave (CPU package)
   - Cloud provider cannot see image or model

2. **Integrity**: Client verifies enclave via attestation
   - MRENCLAVE proves exact code running
   - Cannot be tampered with by provider

3. **Attestation**: Cryptographic proof of enclave identity
   - Intel signature on quote
   - Binds enclave measurement to public key

---

## Comparison: TrustZone vs SGX

| Aspect | ARM TrustZone | Intel SGX |
|--------|---------------|-----------|
| **Isolation Granularity** | System-wide (two worlds) | Per-application (enclaves) |
| **TCB Size** | Larger (Trusted OS) | Smaller (enclave code only) |
| **Memory Protection** | TZASC/TZPC (MB-GB scale) | MEE encryption (limited EPC) |
| **OS Trust** | Trusted OS required | No OS trust needed |
| **Attestation** | Limited (depends on impl.) | Built-in remote attestation |
| **Performance** | Minimal overhead | 10-15% memory overhead |
| **Deployment** | Mobile (ARM devices) | Servers/desktops (Intel CPUs) |
| **Secure UI** | Yes (secure display path) | No (no I/O in enclave) |
| **Use Cases** | Payments, DRM, biometrics | Confidential computing, privacy |

---

## Conclusion

ARM TrustZone and Intel SGX represent two distinct approaches to Trusted Execution Environments. TrustZone provides system-wide isolation with two parallel execution worlds, suitable for mobile scenarios requiring secure UI and peripheral access. SGX offers fine-grained, per-application isolation with strong cryptographic guarantees, ideal for cloud confidential computing where data must be protected from privileged software. Both enable secure computation in untrusted environments, though with different trust models, performance characteristics, and use case optimizations.

---

## References

1. ARM, "ARM Security Technology - Building a Secure System using TrustZone Technology", 2022
2. Ngabonziza, B., et al. (2016). "TrustZone Explained: Architectural Features and Use Cases". *IEEE Cybersecurity Development Conference*
3. Costan, V., & Devadas, S. (2016). "Intel SGX Explained". *IACR Cryptology ePrint Archive*
4. McKeen, F., et al. (2013). "Innovative Instructions and Software Model for Isolated Execution". *HASP Workshop*
5. GlobalPlatform, "TEE Internal Core API Specification", Version 1.3.1, 2022
6. Intel Corporation, "Intel SGX Developer Reference", 2024
