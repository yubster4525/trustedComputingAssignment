#!/bin/bash

# This script creates the remaining LaTeX files for the assignment

# Part A Question 2 - Remote Attestation
cat > parta_q2.tex << 'EOF'
\section{Question 2: TPM Based Attestation}

\subsection*{Question}
\textit{Describe how remote attestation works in TPM. Provide a use-case scenario where attestation ensures platform integrity.}

\subsection{Introduction}

Remote Attestation is a security mechanism that enables a computing platform to prove its trustworthiness to a remote party. Using TPM as a hardware root of trust, attestation provides cryptographic evidence of the platform's configuration and integrity state.

\subsection{Remote Attestation Protocol}

\subsubsection{Key Components}

\paragraph{Endorsement Key (EK)}
\begin{itemize}[leftmargin=*]
    \item 2048-bit RSA or ECC P-256 key pair
    \item Generated during TPM manufacturing, embedded in chip
    \item Never leaves the TPM
    \item Unique identifier for each TPM
    \item Certified by TPM manufacturer
\end{itemize}

\paragraph{Attestation Identity Key (AIK)}
\begin{itemize}[leftmargin=*]
    \item Privacy-preserving attestation credential
    \item Generated on-demand by TPM
    \item Acts as pseudonym for EK
    \item Private key never exported
    \item Signs attestation quotes
\end{itemize}

\paragraph{Quote Structure}
\begin{lstlisting}[language=C, caption=TPM Quote Structure]
Quote = {
    Magic: TPM_GENERATED_VALUE
    QualifiedSigner: AIK_name
    ExtraData: Nonce from verifier
    ClockInfo: TPM clock, reset counter
    FirmwareVersion: TPM firmware version
    PCRSelect: Which PCRs included
    PCRDigest: Hash of selected PCR values
}
Signature = Sign(Quote, AIK_private_key)
\end{lstlisting}

\subsubsection{Step-by-Step Attestation Flow}

\paragraph{Phase 1: AIK Provisioning (One-Time Setup)}
\begin{enumerate}[leftmargin=*]
    \item Attester generates AIK: \texttt{TPM2\_Create(AIK)}
    \item Request AIK certification from Privacy CA
    \item CA verifies EK certificate chain to manufacturer
    \item CA issues AIK certificate
    \item Attester stores AIK certificate for future use
\end{enumerate}

\paragraph{Phase 2: Remote Attestation (Repeated as Needed)}
\begin{enumerate}[leftmargin=*]
    \item Platform boots with measured boot enabled
    \item Verifier sends challenge: \texttt{\{Nonce, PCR\_selection\}}
    \item Attester reads PCR values from TPM
    \item TPM generates quote: \texttt{TPM2\_Quote(AIK, Nonce, PCRs)}
    \item Attester sends: \texttt{\{Quote, Signature, AIK\_cert, PCR\_log\}}
    \item Verifier:
    \begin{itemize}
        \item Verifies AIK certificate
        \item Verifies quote signature
        \item Validates nonce (freshness check)
        \item Compares PCR values to expected "golden" values
    \end{itemize}
    \item Access decision: GRANT or DENY
\end{enumerate}

\subsection{Security Properties}

\begin{itemize}[leftmargin=*]
    \item \textbf{Authenticity}: Evidence comes from genuine TPM hardware
    \item \textbf{Integrity}: Platform state hasn't been tampered with
    \item \textbf{Freshness}: Random nonce prevents replay attacks
    \item \textbf{Privacy}: AIK protects user identity across contexts
\end{itemize}

\subsection{Use Case: Enterprise Cloud VM Attestation}

\subsubsection{Scenario}

\textbf{TechCorp} is a financial services company using Microsoft Azure for critical workloads. They must ensure VMs are running verified, unmodified software and comply with financial regulations (PCI-DSS, SOX).

\subsubsection{Problem}

Traditional security cannot detect:
\begin{itemize}[leftmargin=*]
    \item Hypervisor-level malware
    \item Modified bootloaders (bootkits)
    \item Unauthorized kernel modules
    \item Firmware-level persistence
\end{itemize}

\textbf{Risk}: Attacker with hypervisor access could modify VM boot sequence, install rootkit, and steal financial data.

\subsubsection{Solution: TPM-Based Attestation}

\paragraph{Implementation Flow}

\begin{enumerate}[leftmargin=*]
    \item \textbf{VM Provisioning}: Azure provisions VM with virtual TPM (vTPM)

    \item \textbf{Measured Boot}: During boot, Azure measures:
    \begin{itemize}
        \item UEFI Firmware $\rightarrow$ PCR 0,7
        \item GRUB Bootloader $\rightarrow$ PCR 4
        \item Linux Kernel $\rightarrow$ PCR 8,9
        \item System Services $\rightarrow$ PCR 10-15
    \end{itemize}

    \item \textbf{Application Requests Secrets}: Finance app requests database credentials from Key Vault

    \item \textbf{Attestation Challenge}: Azure Key Vault initiates attestation:
    \begin{lstlisting}[caption=Key Vault Attestation Logic (simplified)]
if secret_name in CRITICAL_SECRETS:
    nonce = generate_nonce()
    quote = request_quote(vm_identity, nonce, PCRs)
    result = attestation_service.verify(quote, nonce)

    if result.trusted:
        return get_secret(secret_name)
    else:
        log_security_alert(vm_identity)
        raise AccessDeniedException()
    \end{lstlisting}

    \item \textbf{Quote Generation}: VM's vTPM generates quote with PCR values

    \item \textbf{Verification}: Azure Attestation Service:
    \begin{itemize}
        \item Verifies AIK certificate
        \item Verifies quote signature
        \item Validates nonce
        \item Compares PCR values to attestation policy
    \end{itemize}

    \item \textbf{Access Decision}:
    \begin{itemize}
        \item \textbf{Scenario A - Compliant VM}: PCRs match policy $\rightarrow$ Token issued $\rightarrow$ Secret released
        \item \textbf{Scenario B - Compromised VM}: PCR mismatch $\rightarrow$ Access denied $\rightarrow$ Security alert
    \end{itemize}
\end{enumerate}

\subsubsection{Attack Scenario Prevented}

\begin{enumerate}[leftmargin=*]
    \item Day 1: Attacker compromises Azure account credentials
    \item Day 2: Attacker modifies VM boot disk with malicious bootloader
    \item Day 3: VM reboots, bootloader measures differently: PCR[4] changes
    \item Day 4: Finance app requests database password
    \begin{itemize}
        \item Triggers attestation
        \item PCR[4] mismatch detected
        \item \textbf{ACCESS DENIED}
        \item Security Operations Center alerted
        \item VM automatically isolated
    \end{itemize}
\end{enumerate}

\textbf{Without attestation}: Attacker gains database access, exfiltrates customer data

\textbf{With attestation}: Attack detected immediately, zero data loss

\subsubsection{Benefits Demonstrated}

\begin{itemize}[leftmargin=*]
    \item \textbf{Boot-Level Security}: Detects firmware/bootloader malware
    \item \textbf{Compliance}: Cryptographic proof of approved configuration
    \item \textbf{Zero-Trust Architecture}: Never trust, always verify
    \item \textbf{Automated Response}: Real-time detection and denial
    \item \textbf{Cryptographic Assurance}: Cannot be bypassed by software
\end{itemize}

\subsection{Conclusion}

TPM-based remote attestation provides cryptographic proof of platform integrity, enabling trustworthy computing in distributed environments. By combining hardware roots of trust (EK), privacy-preserving credentials (AIK), and tamper-evident measurements (PCRs), attestation allows remote verifiers to make informed trust decisions. The enterprise cloud VM use case demonstrates how attestation prevents sophisticated boot-level attacks that evade traditional security tools.

\newpage
EOF

# Part A Question 3 - TEE Components
cat > parta_q3.tex << 'EOF'
\section{Question 3: TEE Components}

\subsection*{Question}
\textit{Explain the core components and operational flow of a Trusted Execution Environment (TEE), using ARM TrustZone or Intel SGX as examples.}

\subsection{Introduction}

A Trusted Execution Environment (TEE) is an isolated execution environment that provides security features such as isolated execution, integrity of applications, and confidentiality of data. TEE enables secure execution alongside a rich OS while providing strong isolation guarantees.

\subsection{ARM TrustZone Architecture}

\subsubsection{Core Components}

\paragraph{Processor Security Extensions}

\textbf{Secure Monitor Mode (EL3)}
\begin{itemize}[leftmargin=*]
    \item Highest privilege level in ARMv8-A architecture
    \item Acts as gatekeeper between Normal and Secure Worlds
    \item Handles world context switches
    \item Routes exceptions and interrupts to appropriate world
\end{itemize}

\textbf{Security State Bit (NS bit)}
\begin{itemize}[leftmargin=*]
    \item NS=0: Secure World
    \item NS=1: Normal World
    \item All processor states tagged with NS bit
\end{itemize}

\paragraph{Memory Protection}

\textbf{TrustZone Address Space Controller (TZASC)}
\begin{itemize}[leftmargin=*]
    \item Filters memory transactions
    \item Marks regions as Secure or Non-Secure
    \item Normal World access to Secure memory $\rightarrow$ Blocked (bus error)
    \item Secure World can access both regions
\end{itemize}

\textbf{TrustZone Protection Controller (TZPC)}
\begin{itemize}[leftmargin=*]
    \item Controls peripheral access
    \item Tags peripherals as Secure or Non-Secure
    \item Example: Crypto engine = SECURE, UART = NON-SECURE
\end{itemize}

\paragraph{Software Stack}

\begin{itemize}[leftmargin=*]
    \item \textbf{Normal World}: Rich OS (Linux, Android), untrusted applications
    \item \textbf{Secure World}: Trusted OS (OP-TEE, Trusty), Trusted Applications
    \item \textbf{Secure Monitor}: ARM Trusted Firmware (ATF)
\end{itemize}

\subsubsection{Operational Flow: Secure Mobile Payment}

\textbf{Scenario}: Mobile banking app needs to sign payment using key never exposed to Normal World.

\begin{enumerate}[leftmargin=*]
    \item User clicks "Pay \$100" in Normal World banking app
    \item App prepares transaction data
    \item \texttt{TEEC\_InvokeCommand()} triggers SMC instruction
    \item \textbf{World Switch}: Secure Monitor saves Normal World context
    \item Switch to Secure World, restore Secure World context
    \item OP-TEE Kernel dispatches to Payment Trusted Application (TA)
    \item TA:
    \begin{itemize}
        \item Validates transaction
        \item Loads signing key from secure storage
        \item Signs transaction with secure crypto engine
        \item Returns signed result
    \end{itemize}
    \item \textbf{World Switch Back}: Secure Monitor context switch
    \item Normal World receives signed transaction
    \item App sends to bank server
\end{enumerate}

\textbf{Security Guarantee}: Private key never exposed to Normal World, even if Android OS compromised.

\subsection{Intel SGX Architecture}

\subsubsection{Core Components}

\paragraph{Processor Reserved Memory (PRM)}

\textbf{Encrypted Page Cache (EPC)}
\begin{itemize}[leftmargin=*]
    \item Special DRAM region (typically 128-256MB)
    \item Stores enclave code and data
    \item Managed exclusively by CPU
    \item Encrypted in DRAM using Memory Encryption Engine (MEE)
    \item Plaintext exists only inside CPU package
\end{itemize}

\textbf{EPC Map (EPCM)}
\begin{itemize}[leftmargin=*]
    \item Metadata table tracking EPC pages
    \item One entry per 4KB page
    \item Fields: valid, read, write, execute, page type, enclave owner
    \item Enforced by hardware on every memory access
\end{itemize}

\paragraph{Memory Encryption Engine (MEE)}

\begin{itemize}[leftmargin=*]
    \item Encrypts/decrypts EPC pages in real-time
    \item AES-128 in counter mode
    \item 56-bit MAC for integrity
    \item Merkle tree for replay protection
    \item Plaintext only in CPU cache
    \item DRAM contains only ciphertext
\end{itemize}

\paragraph{SGX Instructions}

\textbf{Enclave Management (Ring 0)}:
\begin{itemize}[leftmargin=*]
    \item \texttt{ECREATE}: Create new enclave
    \item \texttt{EADD}: Add page to enclave
    \item \texttt{EEXTEND}: Measure enclave page (builds MRENCLAVE)
    \item \texttt{EINIT}: Initialize enclave
\end{itemize}

\textbf{Enclave Execution (Ring 3)}:
\begin{itemize}[leftmargin=*]
    \item \texttt{EENTER}: Enter enclave
    \item \texttt{EEXIT}: Exit enclave
    \item \texttt{ERESUME}: Resume after interrupt
    \item \texttt{EREPORT}: Generate enclave report
\end{itemize}

\paragraph{Enclave Measurement (MRENCLAVE)}

\begin{lstlisting}[caption=MRENCLAVE Calculation]
Initial_Hash = SHA256("")

For each page added (EADD):
    For each 256-byte chunk (EEXTEND):
        Current_Hash = SHA256(
            Current_Hash ||
            chunk_data ||
            page_offset ||
            security_info
        )

Final_MRENCLAVE = Current_Hash
\end{lstlisting}

\textbf{Properties}:
\begin{itemize}[leftmargin=*]
    \item 256-bit SHA-256 hash
    \item Uniquely identifies enclave contents and layout
    \item Used for attestation and sealing keys
\end{itemize}

\subsubsection{Operational Flow: Confidential ML Inference}

\textbf{Scenario}: Cloud provides ML inference. Client has sensitive medical images.

\textbf{Setup Phase}:
\begin{enumerate}[leftmargin=*]
    \item ML provider develops enclave code
    \item Builds and measures: MRENCLAVE = a3f8c2...b4d6
    \item Publishes MRENCLAVE (clients will verify this)
\end{enumerate}

\textbf{Runtime Flow}:
\begin{enumerate}[leftmargin=*]
    \item Server creates SGX enclave (\texttt{ECREATE, EADD, EEXTEND, EINIT})
    \item Client requests attestation
    \item Enclave generates report with MRENCLAVE
    \item Quoting Enclave signs report $\rightarrow$ Quote
    \item Client verifies:
    \begin{itemize}
        \item Intel signature on quote
        \item MRENCLAVE matches expected value
    \end{itemize}
    \item Client establishes secure channel (TLS to enclave)
    \item Client encrypts medical image with session key
    \item Server: \texttt{EENTER} $\rightarrow$ Enclave decrypts image inside CPU
    \item ML inference performed in enclave
    \item Result encrypted, \texttt{EEXIT} returns to untrusted code
    \item Client receives and decrypts result
\end{enumerate}

\textbf{Security Guarantee}: Data encrypted in DRAM, protected from malicious OS/hypervisor, physical memory attacks.

\subsection{Comparison: TrustZone vs SGX}

\begin{table}[h]
\centering
\begin{tabular}{|p{3cm}|p{5.5cm}|p{5.5cm}|}
\hline
\textbf{Aspect} & \textbf{ARM TrustZone} & \textbf{Intel SGX} \\
\hline
Isolation & System-wide (two worlds) & Per-application (enclaves) \\
\hline
TCB Size & Larger (Trusted OS) & Smaller (enclave only) \\
\hline
Memory & TZASC/TZPC (MB-GB) & MEE encryption (limited EPC) \\
\hline
Attestation & Limited & Built-in remote attestation \\
\hline
Secure UI & Yes (secure display) & No (no I/O in enclave) \\
\hline
Use Cases & Mobile payments, DRM & Cloud confidential computing \\
\hline
\end{tabular}
\caption{TrustZone vs SGX Comparison}
\end{table}

\subsection{Conclusion}

ARM TrustZone and Intel SGX represent two distinct TEE approaches. TrustZone provides system-wide isolation with two parallel worlds, suitable for mobile scenarios requiring secure UI. SGX offers fine-grained, per-application isolation with strong cryptographic guarantees, ideal for cloud confidential computing. Both enable secure computation in untrusted environments with different trust models and performance characteristics.

\newpage
EOF

echo "LaTeX part files created successfully!"
EOF

chmod +x create_latex_parts.sh
