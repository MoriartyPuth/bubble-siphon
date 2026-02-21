# 🌪️ Bubble-Siphon 

**Tactical Post-Exploitation Scavenging & Privilege Escalation Auditing Framework**

---

## 📖 Overview
**Bubble-Siphon** is a lightweight, dependency-free Bash framework engineered for the post-exploitation phase of security engagements. Designed for speed, stealth, and reliability, it automates the discovery of sensitive data and maps potential local privilege escalation (LPE) paths on Linux-based systems.

Developed with a "native-first" philosophy, Bubble-Siphon utilizes built-in system binaries to ensure execution on hardened or minimal environments (e.g., Docker containers, IoT devices, and cloud instances) without triggering common dependency alerts.

**Bubble-Siphon solves this by:**
1. **Using POSIX-Compliant Bash:** Guaranteed execution on any *NIX system.
2. **Native Binary Chaining:** Utilizing `find`, `awk`, `sed`, and `grep` with optimized regex to perform complex data analysis without installing dependencies.
3. **In-Memory Operations:** Where possible, data is processed in streams to minimize forensic artifacts on the disk.

---

## 🛠️ Labs & Testing
This tool was used as a real-world benchmark for the:
* **[Pickle Rick Lab](https://github.com/MoriartyPuth/Pickle-Rick-Lab)**.
* **[N7 Lab](https://github.com/MoriartyPuth/N7-Lab)**.

---

## 🚀 Key Capabilities

### 🔍 Automated Data Scavenging
* **Secret Hunting:** Heuristic identification of API keys, SSH private keys, and hardcoded credentials using high-entropy regex patterns.
* **Environment Analysis:** Deep-scanning of `.env`, `.bash_history`, and config files for sensitive environment variables.
* **Database Discovery:** Identification of local database instances and connection strings (MySQL, PostgreSQL, SQLite).

### 👑 Privilege Escalation Auditing
* **Sudo Analysis:** Automated mapping of `NOPASSWD` entries and misconfigured sudoers files.
* **Artifact Discovery:** Identification of SUID/GUID binaries and world-writable files in critical system paths.
* **Task Introspection:** Auditing of user-owned and system-wide Cron jobs for insecure execution paths.

### 🛡️ Tactical Design
* **Zero Dependencies:** Requires only a standard Bourne-again shell (Bash).
* **Stealth Optimized:** Operates without installing new packages; minimizes disk I/O to reduce the EDR behavioral footprint.
* **Modular Architecture:** Easily extensible for custom engagement requirements.

## 🛡️ NIST & MITRE ATT&CK Mapping
This tool is designed to automate and validate controls within the following frameworks:

| Tactic | Technique ID | Description |
| :--- | :--- | :--- |
| **Discovery** | T1083 | File and Directory Discovery |
| **Discovery** | T1082 | System Information Discovery |
| **Credential Access** | T1552 | Unsecured Credentials (Secrets Scavenging) |
| **Privilege Escalation** | T1548.003 | Sudo and Sudo Caching |
| **Exfiltration** | T1041 | Exfiltration Over C# Command and Control Channel |

## ⚙️ Core Modules & Logic

### 1. The Scavenger Engine (Credential Siphoning)
The scavenger module uses **Entropy-Based Discovery** to find secrets that standard string matches miss:
* **Pattern Matching:** Searches for AWS keys, SSH private keys, JWT tokens, and database connection strings.
* **History Inspection:** Deep-dives into `.bash_history`, `.zsh_history`, and `.viminfo` for accidentally typed passwords.
* **Config Harvesting:** Parses `/etc/` and `/opt/` for non-standard configuration files containing plaintext credentials.

### 2. The Auditor (PrivEsc Mapping)
The auditor doesn't just list files; it identifies **Exploitation Paths**:
* **Sudo Audit:** Analyzes `/etc/sudoers` for `NOPASSWD` vulnerabilities and shell escapes.
* **SUID/GUID Tracker:** Cross-references found SUID binaries against known **GTFOBins** patterns.
* **Capability Leakage:** Checks for extended file capabilities (e.g., `cap_setuid`) that allow for privilege jumps.

## 📊 Operational Logic

Bubble-Siphon follows a multi-stage execution flow:

- Reconnaissance: Identifies current user context and environmental constraints.

- Siphoning: Extracts high-value artifacts (Keys, Configs, Logs).

- Escalation Mapping: Checks for sudo misconfigurations and kernel vulnerabilities.

- Reporting: Consolidates findings into a tactical report for rapid analysis.

## 🛠️ Deployment

### **Quick Execution**
```bash
git clone https://github.com/MoriartyPuth/bubble-siphon
chmod +x bubble_siphon.sh
./bubble_siphon.sh --full-audit
```
## 🚀 Advanced Deployment Examples

### **Silent Operation (Government/Tactical Use)**
Run the siphoner in a "Quiet" mode, suppressing all non-critical output and logging directly to a hidden directory:
```bash
./bubble_siphon.sh --silent --scavenge --output ./.hidden_report
```

## ⚖️ Security & Responsible Use

Bubble-Siphon includes an Integrated Kill-Switch. If the script detects it is running in a prohibited environment (based on hostname or IP ranges defined in config.cfg), it will self-terminate to prevent accidental disruption of critical systems.
