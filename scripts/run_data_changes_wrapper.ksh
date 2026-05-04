#!/usr/bin/ksh


# Script: run_data_changes.ksh
# Purpose: Wrapper around anysql.ksh for data-level DB changes.
################################################################################

set -u

########################################
# Helper functions
########################################
log() {
  print "[`date '+%Y-%m-%d %H:%M:%S'`] $1"
}

fail() {
  print "[ERROR] $1"
  exit 1
}

########################################
# Validate mandatory inputs
########################################
: ${REGION:?Missing REGION}
: ${DB_SCHEMA:?Missing DB_SCHEMA}
: ${RELEASE_DATE:?Missing RELEASE_DATE}
: ${RELEASE_PLAN_FILE:?Missing RELEASE_PLAN_FILE}
: ${ANYSQL_SCRIPT:?Missing ANYSQL_SCRIPT}

BASE_DIR="/apps/ingenium/${REGION}/server/dbparms/jenkins"
LOG_BASE="${BASE_DIR}/logs/${RELEASE_DATE}"

[ -f "${RELEASE_PLAN_FILE}" ] || fail "Release plan file not found: ${RELEASE_PLAN_FILE}"
[ -x "${ANYSQL_SCRIPT}" ] || fail "anysql.ksh not executable: ${ANYSQL_SCRIPT}"

########################################
# Start execution
########################################
log "Starting DATA changes execution"
log "Schema=${DB_SCHEMA}, Release=${RELEASE_DATE}"

########################################
# Process release plan
########################################
while read LINE || [ -n "${LINE}" ]; do

  [[ -z "${LINE}" || "${LINE}" = \#* ]] && continue

  unset action file allow_reject
  allow_reject="false"

  for KV in ${LINE}; do
    KEY=$(print "${KV}" | cut -d= -f1)
    VAL=$(print "${KV}" | cut -d= -f2)

    case "${KEY}" in
      action) action="${VAL}" ;;
      file) file="${VAL}" ;;
      allow_reject) allow_reject="${VAL}" ;;
      *) fail "Invalid key '${KEY}' in release plan" ;;
    esac
  done

  ####################################
  # Validation
  ####################################
  case "${action}" in
    import|export|zap) ;;
    *) fail "Invalid action '${action}' in data pipeline" ;;
  esac

  [ -n "${file}" ] || fail "SQL filename missing in release plan"

  SQL_DIR="${BASE_DIR}/sql/${action}/${RELEASE_DATE}"
  SQL_FILE="${SQL_DIR}/${file}"
  LOG_DIR="${LOG_BASE}/${action}"

  [ -f "${SQL_FILE}" ] || fail "SQL file not found: ${SQL_FILE}"

  mkdir -p "${LOG_DIR}" || fail "Unable to create log directory: ${LOG_DIR}"

  ####################################
  # Execute using anysql.ksh
  ####################################
  log "Executing ${action}: ${file}"
  ${ANYSQL_SCRIPT} "${file}"

  ####################################
  # Locate legacy log
  ####################################
  ANYSQL_LOG="/${DEVBASE}/dbparms/scripts/log/${file}.log"
  [ -f "${ANYSQL_LOG}" ] || fail "Expected anysql log not found: ${ANYSQL_LOG}"

  FINAL_LOG="${LOG_DIR}/${file%.sql}_${DB_SCHEMA}.log"
  mv "${ANYSQL_LOG}" "${FINAL_LOG}" || fail "Failed to move log file"

  ####################################
  # Failure detection
  ####################################
  if grep -E "SQLCODE[[:space:]]*=[[:space:]]*-[0-9]+|SQLSTATE=|DB21034E|SQL[0-9]+N" "${FINAL_LOG}" >/dev/null
  then
    fail "DB2 error detected in ${FINAL_LOG}"
  fi

  ####################################
  # Import rejected rows handling
  ####################################
  if [ "${action}" = "import" ] && [ "${allow_reject}" != "true" ]; then
    if grep -i "rows rejected" "${FINAL_LOG}" | grep -E "[1-9][0-9]*" >/dev/null; then
      fail "Import rejected rows detected (allow_reject=false)"
    fi
  fi

  log "Successfully executed: ${file}"

done < "${RELEASE_PLAN_FILE}"

########################################
# Completion
########################################
log "All data-level changes executed successfully"
exit 0