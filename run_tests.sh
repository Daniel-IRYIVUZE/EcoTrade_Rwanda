#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────────────────────
#  EcoTrade Rwanda — Full Test Suite Runner
#  Sections: /frontend → /mobile → /backend  (tables + pass-rate %)
#  Usage: bash run_tests.sh [--frontend-only | --mobile-only | --backend-only | --help]
# ─────────────────────────────────────────────────────────────────────────────
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKEND_DIR="$ROOT_DIR/backend"
FRONTEND_DIR="$ROOT_DIR/frontend"

# ── Colours ───────────────────────────────────────────────────────────────────
BOLD='\033[1m';  RESET='\033[0m'
GREEN='\033[0;32m';  RED='\033[0;31m'
CYAN='\033[0;36m';   WHITE='\033[1;37m'
YELLOW='\033[0;33m'; DIM='\033[2m'
MAGENTA='\033[0;35m'

NC=64   # name-column inner width
SC=7    # status-column inner width
DIV_N="$(printf '─%.0s' $(seq 1 $((NC+2))))"
DIV_S="$(printf '─%.0s' $(seq 1 $((SC+2))))"

# ── Layout helpers ────────────────────────────────────────────────────────────
hr()  { printf "${DIM}%s${RESET}\n" "$(printf '─%.0s' $(seq 1 72))"; }

section_banner() {               # $1=title  $2=colour
  local t=$1 c=$2
  echo ""
  printf "${c}${BOLD}%s${RESET}\n" "$(printf '═%.0s' $(seq 1 72))"
  printf "${c}${BOLD}  %-68s${RESET}\n" "$t"
  printf "${c}${BOLD}%s${RESET}\n" "$(printf '═%.0s' $(seq 1 72))"
  echo ""
}

tbl_top()  { printf "  ┌%s┬%s┐\n"  "$DIV_N" "$DIV_S"; }
tbl_div()  { printf "  ├%s┼%s┤\n"  "$DIV_N" "$DIV_S"; }
tbl_bot()  { printf "  └%s┴%s┘\n"  "$DIV_N" "$DIV_S"; }

tbl_file() {                      # grey section-header row
  local f=$1
  if [ ${#f} -gt $NC ]; then f="${f:0:$((NC-1))}…"; fi
  printf "  │ ${DIM}${CYAN}%-${NC}s${RESET} │ ${DIM}%${SC}s${RESET} │\n" "  $f" ""
}

tbl_row() {                       # $1=PASS|FAIL  $2=name
  local st=$1 name=$2
  if [ ${#name} -gt $NC ]; then name="${name:0:$((NC-1))}…"; fi
  if [ "$st" = "PASS" ]; then
    printf "  │ %-${NC}s │ ${GREEN}%-${SC}s${RESET} │\n" "$name" "✔ PASS"
  else
    printf "  │ %-${NC}s │ ${RED}%-${SC}s${RESET} │\n" "$name" "✘ FAIL"
  fi
}

tbl_summary() {                   # $1=label $2=passed $3=total
  local lbl=$1 p=$2 tot=$3
  local pct=0; [ "$tot" -gt 0 ] && pct=$(( p * 100 / tot ))
  local f=$(( tot - p ))
  local full_lbl
  if [ "$f" -eq 0 ]; then
    full_lbl="${lbl}:  ${p}/${tot} passed"
    printf "  │ ${GREEN}${BOLD}%-${NC}s${RESET} │ ${GREEN}${BOLD}%${SC}s${RESET} │\n" \
           "$full_lbl" "${pct}%"
  else
    full_lbl="${lbl}:  ${p}/${tot} passed  (${f} failed)"
    printf "  │ ${RED}${BOLD}%-${NC}s${RESET} │ ${RED}${BOLD}%${SC}s${RESET} │\n" \
           "$full_lbl" "${pct}%"
  fi
}

elapsed() { echo $(( $(date +%s) - $1 ))s; }
strip_ansi() { sed 's/\x1b\[[0-9;]*[mGKHF]//g'; }

# ── Argument parsing ──────────────────────────────────────────────────────────
RUN_FRONTEND=true; RUN_MOBILE=true; RUN_BACKEND=true

for arg in "$@"; do
  case $arg in
    --frontend-only) RUN_MOBILE=false;   RUN_BACKEND=false  ;;
    --mobile-only)   RUN_FRONTEND=false; RUN_BACKEND=false  ;;
    --backend-only)  RUN_FRONTEND=false; RUN_MOBILE=false   ;;
    --help|-h)
      printf "\n  ${BOLD}EcoTrade Rwanda Test Runner${RESET}\n\n"
      echo "  Usage: bash run_tests.sh [options]"
      echo ""
      echo "  Options:"
      echo "    (none)            Run all 3 sections: /frontend /mobile /backend"
      echo "    --frontend-only   Run only /frontend vitest tests"
      echo "    --mobile-only     Run only /mobile vitest tests"
      echo "    --backend-only    Run only /backend pytest tests"
      echo "    --help            Show this help"
      echo ""
      exit 0 ;;
  esac
done

# ── File groups ───────────────────────────────────────────────────────────────
FRONTEND_FILES=(
  "src/services/api.test.ts"
  "src/utils/imageUrl.test.ts"
  "src/utils/userDisplayName.test.ts"
)
MOBILE_FILES=(
  "src/utils/geo.test.ts"
  "src/utils/offlineQueue.test.ts"
  "src/utils/markdown.test.ts"
  "src/utils/toast.test.ts"
  "src/utils/dataStore.test.ts"
)

# ── Parse vitest verbose output → arrays ──────────────────────────────────────
# Fills VT_STATUS[@] VT_FILE[@] VT_NAME[@]
parse_vitest() {
  local raw="$1"
  VT_STATUS=(); VT_FILE=(); VT_NAME=()
  while IFS= read -r line; do
    local clean
    clean=$(printf '%s' "$line" | strip_ansi)
    local st=""
    if printf '%s' "$clean" | grep -qE '^\s+✓ '; then st="PASS"
    elif printf '%s' "$clean" | grep -qE '^\s+[×✗] '; then st="FAIL"; fi
    [ -z "$st" ] && continue

    # full = "src/utils/geo.test.ts > haversineKm > returns 0 … 6ms"
    local full
    full=$(printf '%s' "$clean" | sed 's/^\s*[✓×✗]\s*//' | sed 's/\s*[0-9][0-9]*ms\s*$//')

    # file = "geo.test.ts"
    local file
    file=$(printf '%s' "$full" | grep -oE '[A-Za-z0-9_-]+\.test\.[a-z]+' | head -1 || echo "unknown")

    # name = everything after "file > " — the describe > it chain
    local name
    name=$(printf '%s' "$full" | sed "s/.*${file} > //")

    VT_STATUS+=("$st")
    VT_FILE+=("$file")
    VT_NAME+=("$name")
  done <<< "$raw"
}

# Show a table from VT_* arrays. $1=section label
show_vitest_table() {
  local label=$1
  local cur_file="" p=0 f=0

  tbl_top
  # header row
  printf "  │ ${BOLD}%-${NC}s${RESET} │ ${BOLD}%${SC}s${RESET} │\n" \
         "  Test"  "Result"
  tbl_div

  local i
  for i in "${!VT_STATUS[@]}"; do
    local st="${VT_STATUS[$i]}"
    local fl="${VT_FILE[$i]}"
    local nm="${VT_NAME[$i]}"

    if [ "$fl" != "$cur_file" ]; then
      [ -n "$cur_file" ] && tbl_div
      tbl_file "$fl"
      tbl_div
      cur_file="$fl"
    fi

    tbl_row "$st" "  $nm"
    [ "$st" = "PASS" ] && p=$((p+1)) || f=$((f+1))
  done

  tbl_div
  tbl_summary "$label" "$p" "$(( p + f ))"
  tbl_bot
  echo ""
}

# ── Parse pytest -v output → arrays ──────────────────────────────────────────
# Fills PY_STATUS[@] PY_FILE[@] PY_NAME[@]
parse_pytest() {
  local raw="$1"
  PY_STATUS=(); PY_FILE=(); PY_NAME=()
  while IFS= read -r line; do
    local clean
    clean=$(printf '%s' "$line" | strip_ansi)

    local st=""
    printf '%s' "$clean" | grep -qE '::.*PASSED' && st="PASS"
    printf '%s' "$clean" | grep -qE '::.*FAILED' && st="FAIL"
    [ -z "$st" ] && continue

    # e.g. "tests/test_auth.py::TestRegister::test_register_success PASSED [  5%]"
    # Strip the progress bracket and PASSED/FAILED suffix first for clean parsing
    local stripped
    stripped=$(printf '%s' "$clean" | sed 's/ *PASSED.*//' | sed 's/ *FAILED.*//')

    local file class testname
    file=$(printf '%s' "$stripped" | grep -oE 'test_[a-z_]+\.py' | head -1 || echo "unknown")
    # class = segment between first and second ::
    class=$(printf '%s' "$stripped" | awk -F '::' '{print $2}')
    # testname = segment after second :: (last segment)
    testname=$(printf '%s' "$stripped" | awk -F '::' '{print $NF}')

    PY_STATUS+=("$st")
    PY_FILE+=("$file")
    PY_NAME+=("${class} > ${testname}")
  done <<< "$raw"
}

# Show a table from PY_* arrays. $1=section label
show_pytest_table() {
  local label=$1
  local cur_file="" p=0 f=0

  tbl_top
  printf "  │ ${BOLD}%-${NC}s${RESET} │ ${BOLD}%${SC}s${RESET} │\n" \
         "  Test"  "Result"
  tbl_div

  local i
  for i in "${!PY_STATUS[@]}"; do
    local st="${PY_STATUS[$i]}"
    local fl="${PY_FILE[$i]}"
    local nm="${PY_NAME[$i]}"

    if [ "$fl" != "$cur_file" ]; then
      [ -n "$cur_file" ] && tbl_div
      tbl_file "$fl"
      tbl_div
      cur_file="$fl"
    fi

    tbl_row "$st" "  $nm"
    [ "$st" = "PASS" ] && p=$((p+1)) || f=$((f+1))
  done

  tbl_div
  tbl_summary "$label" "$p" "$(( p + f ))"
  tbl_bot
  echo ""
}

# ── Locate Python (for backend) ───────────────────────────────────────────────
find_python() {
  if [ -f "$BACKEND_DIR/venv/Scripts/python.exe" ]; then
    PYTHON="$BACKEND_DIR/venv/Scripts/python.exe"
  elif [ -f "$BACKEND_DIR/venv/bin/python" ]; then
    PYTHON="$BACKEND_DIR/venv/bin/python"
  elif command -v python3 &>/dev/null; then
    PYTHON="python3"
  elif command -v python &>/dev/null; then
    PYTHON="python"
  else
    return 1
  fi
  return 0
}

# ─────────────────────────────────────────────────────────────────────────────
#  MAIN HEADER BANNER
# ─────────────────────────────────────────────────────────────────────────────
echo ""
printf "${BOLD}${WHITE}"
printf '╔%s╗\n' "$(printf '═%.0s' $(seq 1 70))"
printf '║  %-68s║\n' "EcoTrade Rwanda — Test Suite"
printf '║  %-68s║\n' "$(date '+%Y-%m-%d  %H:%M:%S')"
printf '╚%s╝\n' "$(printf '═%.0s' $(seq 1 70))"
printf "${RESET}\n"

# Accumulate overall totals
GRAND_PASSED=0; GRAND_FAILED=0; GRAND_TIME=0
SECTION_RESULTS=()   # "label|passed|failed|time|status"

# ─────────────────────────────────────────────────────────────────────────────
#  SECTION 1 — /FRONTEND TESTS
# ─────────────────────────────────────────────────────────────────────────────
if $RUN_FRONTEND; then
  section_banner "SECTION 1 — /FRONTEND  (API client · Image URLs · Display names)" "${CYAN}"

  if ! command -v node &>/dev/null; then
    printf "  ${RED}Node.js not found.${RESET}\n"
    SECTION_RESULTS+=("Frontend|0|0|0s|ERROR")
  else
    printf "  ${DIM}Files: %s${RESET}\n\n" "${FRONTEND_FILES[*]}"

    START=$(date +%s)
    set +e
    FE_RAW=$(cd "$FRONTEND_DIR" && \
      npx vitest run --reporter=verbose --no-color \
        "${FRONTEND_FILES[@]}" 2>&1)
    FE_EXIT=$?
    set -e
    FE_TIME=$(elapsed $START)

    parse_vitest "$FE_RAW"
    show_vitest_table "Frontend"

    FE_P=0; FE_F=0
    for s in "${VT_STATUS[@]}"; do
      [ "$s" = "PASS" ] && FE_P=$((FE_P+1)) || FE_F=$((FE_F+1))
    done
    GRAND_PASSED=$((GRAND_PASSED+FE_P))
    GRAND_FAILED=$((GRAND_FAILED+FE_F))
    ST="PASSED"; [ $FE_EXIT -ne 0 ] && ST="FAILED"
    SECTION_RESULTS+=("Frontend|$FE_P|$FE_F|$FE_TIME|$ST")
  fi
fi

# ─────────────────────────────────────────────────────────────────────────────
#  SECTION 2 — /MOBILE TESTS
# ─────────────────────────────────────────────────────────────────────────────
if $RUN_MOBILE; then
  section_banner "SECTION 2 — /MOBILE  (Geo · Offline-queue · Markdown · Toast · DataStore)" "${MAGENTA}"

  if ! command -v node &>/dev/null; then
    printf "  ${RED}Node.js not found.${RESET}\n"
    SECTION_RESULTS+=("Mobile|0|0|0s|ERROR")
  else
    printf "  ${DIM}Files: %s${RESET}\n\n" "${MOBILE_FILES[*]}"

    START=$(date +%s)
    set +e
    MOB_RAW=$(cd "$FRONTEND_DIR" && \
      npx vitest run --reporter=verbose --no-color \
        "${MOBILE_FILES[@]}" 2>&1)
    MOB_EXIT=$?
    set -e
    MOB_TIME=$(elapsed $START)

    parse_vitest "$MOB_RAW"
    show_vitest_table "Mobile"

    MOB_P=0; MOB_F=0
    for s in "${VT_STATUS[@]}"; do
      [ "$s" = "PASS" ] && MOB_P=$((MOB_P+1)) || MOB_F=$((MOB_F+1))
    done
    GRAND_PASSED=$((GRAND_PASSED+MOB_P))
    GRAND_FAILED=$((GRAND_FAILED+MOB_F))
    ST="PASSED"; [ $MOB_EXIT -ne 0 ] && ST="FAILED"
    SECTION_RESULTS+=("Mobile|$MOB_P|$MOB_F|$MOB_TIME|$ST")
  fi
fi

# ─────────────────────────────────────────────────────────────────────────────
#  SECTION 3 — /BACKEND TESTS
# ─────────────────────────────────────────────────────────────────────────────
if $RUN_BACKEND; then
  section_banner "SECTION 3 — /BACKEND  (Auth · Users · Listings · Bids · Blog · Stats · Support)" "${YELLOW}"

  if ! find_python; then
    printf "  ${RED}Python not found.${RESET}\n"
    SECTION_RESULTS+=("Backend|0|0|0s|ERROR")
  else
    printf "  ${DIM}Python: %s${RESET}\n" "$PYTHON"
    printf "  ${DIM}Files:  tests/test_{auth,users,listings,bids,notifications,blog,stats,support}.py${RESET}\n\n"

    if ! "$PYTHON" -c "import pytest" &>/dev/null; then
      printf "  ${YELLOW}Installing pytest...${RESET}\n"
      "$PYTHON" -m pip install -q -r "$BACKEND_DIR/requirements.txt" pytest httpx
    fi

    START=$(date +%s)
    set +e
    BE_RAW=$(cd "$BACKEND_DIR" && \
      PYTHONPATH="$BACKEND_DIR" "$PYTHON" -m pytest tests/ \
        -v --tb=short --no-header --color=yes -p no:cacheprovider 2>&1)
    BE_EXIT=$?
    set -e
    BE_TIME=$(elapsed $START)

    parse_pytest "$BE_RAW"
    show_pytest_table "Backend"

    BE_P=0; BE_F=0
    for s in "${PY_STATUS[@]}"; do
      [ "$s" = "PASS" ] && BE_P=$((BE_P+1)) || BE_F=$((BE_F+1))
    done
    GRAND_PASSED=$((GRAND_PASSED+BE_P))
    GRAND_FAILED=$((GRAND_FAILED+BE_F))
    ST="PASSED"; [ $BE_EXIT -ne 0 ] && ST="FAILED"
    SECTION_RESULTS+=("Backend|$BE_P|$BE_F|$BE_TIME|$ST")
  fi
fi

# ─────────────────────────────────────────────────────────────────────────────
#  GRAND SUMMARY TABLE
# ─────────────────────────────────────────────────────────────────────────────
echo ""
printf "${BOLD}${WHITE}%s${RESET}\n" "$(printf '═%.0s' $(seq 1 72))"
printf "${BOLD}${WHITE}  %-70s${RESET}\n" "FINAL RESULTS"
printf "${BOLD}${WHITE}%s${RESET}\n\n" "$(printf '═%.0s' $(seq 1 72))"

# Header row
printf "  %-18s  %-9s  %7s  %7s  %8s  %6s\n" \
  "Section" "Status" "Passed" "Failed" "Total" "  %"
printf "  %s\n" "$(printf '─%.0s' $(seq 1 66))"

OVERALL=0
for entry in "${SECTION_RESULTS[@]}"; do
  IFS='|' read -r lbl p f time st <<< "$entry"
  local_total=$(( p + f ))
  local_pct=0; [ "$local_total" -gt 0 ] && local_pct=$(( p * 100 / local_total ))

  if [ "$st" = "PASSED" ]; then
    badge="${GREEN}${BOLD}✔ PASSED ${RESET}"
  elif [ "$st" = "SKIPPED" ]; then
    badge="${YELLOW}${BOLD}– SKIPPED${RESET}"
  else
    badge="${RED}${BOLD}✘ FAILED ${RESET}"
    OVERALL=1
  fi

  printf "  %-18s  %b  %7s  %7s  %8s  %5s%%\n" \
    "$lbl" "$badge" "$p" "$f" "$local_total" "$local_pct"
done

printf "  %s\n" "$(printf '─%.0s' $(seq 1 66))"

GRAND_TOTAL=$(( GRAND_PASSED + GRAND_FAILED ))
GRAND_PCT=0; [ "$GRAND_TOTAL" -gt 0 ] && GRAND_PCT=$(( GRAND_PASSED * 100 / GRAND_TOTAL ))

printf "  %-18s  %-9s  ${GREEN}%7s${RESET}  ${RED}%7s${RESET}  %8s  ${BOLD}%5s%%${RESET}\n" \
  "GRAND TOTAL" "" "$GRAND_PASSED" "$GRAND_FAILED" "$GRAND_TOTAL" "$GRAND_PCT"

echo ""
printf "${BOLD}${WHITE}%s${RESET}\n" "$(printf '═%.0s' $(seq 1 72))"

if [ $OVERALL -eq 0 ]; then
  printf "\n  ${BOLD}${GREEN}All test suites passed — ${GRAND_PASSED}/${GRAND_TOTAL} tests (${GRAND_PCT}%%)${RESET}\n\n"
else
  printf "\n  ${BOLD}${RED}One or more suites failed — ${GRAND_PASSED}/${GRAND_TOTAL} tests (${GRAND_PCT}%%)${RESET}\n\n"
fi

exit $OVERALL
