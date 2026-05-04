#!/usr/bin/ksh
###############################################################################
# Script: run_data_changes.ksh
# Purpose: Execute DB2 utility SQLs (import/export/zap) using dynamic paths
###############################################################################

set -u

############################################
# Helper functions
############################################
log() {
  print "[`date '+%Y-%m-%d %H:%M:%S'`] $1"
}

fail() {
  print "[ERROR] $1"
  exit 1
}

############################################
# Validate inputs
############################################
: ${REGION:?Missing REGION}
: ${DB_NAME:?Missing DB_NAME}
: ${DB_SCHEMA:?Missing DB_SCHEMA}
: ${RELEASE_DATE:?Missing RELEASE_DATE}
: ${RELEASE_PLAN_FILE:?Missing RELEASE_PLAN_FILE}

BASE_DIR="/apps/ingenium/${REGION}/server/dbparms/jenkins"
LOG_BASE="${BASE_DIR}/logs/${RELEASE_DATE}"

[ -f "${RELEASE_PLAN_FILE}" ] || fail "Release plan file not found"

############################################
# DB2 setup
############################################
log "Connecting to DB ${DB_NAME}"
db2 connect to "${DB_NAME}" || fail "DB2 connect failed"
db2 set schema "${DB_SCHEMA}" || fail "Failed to set schema"

############################################
# Process release plan
############################################
while read LINE || [ -n "${LINE}" ]; do

  [[ -z "${LINE}" || "${LINE}" = \#* ]] && continue

  unset action file allow_reject
  allow_reject="false"

  for KV in ${LINE}; do
    KEY="${KV%%=*}"
    VAL="${KV#*=}"

    case "${KEY}" in
      action) action="${VAL}" ;;
      file) file="${VAL}" ;;
      allow_reject) allow_reject="${VAL}" ;;
      *) fail "Invalid key '${KEY}' in release file" ;;
    esac
  done

  ##########################################
  # Validation
  ##########################################
  case "${action}" in
    import|export|zap) ;;
    *) fail "Invalid action '${action}'" ;;
  esac

  [ -n "${file}" ] || fail "Missing SQL file name"

  SQL_FILE="${BASE_DIR}/sql/${action}/${RELEASE_DATE}/${file}"
  LOG_DIR="${LOG_BASE}/${action}"
  LOG_FILE="${LOG_DIR}/${file%.sql}_${DB_SCHEMA}.log"

  [ -f "${SQL_FILE}" ] || fail "SQL file not found: ${SQL_FILE}"
  mkdir -p "${LOG_DIR}" || fail "Unable to create log directory"

  ##########################################
  # Execute SQL
  ##########################################
  log "Executing ${action}: ${file}"
  db2 -tvf "${SQL_FILE}" -z "${LOG_FILE}"
  RC=$?

  if [ ${RC} -ne 0 ]; then
    fail "DB2 execution failed for ${file} (RC=${RC})"
  fi

  ##########################################
  # Detect DB2 errors
  ##########################################
  if grep -E "SQLCODE[[:space:]]*=[[:space:]]*-[0-9]+|SQLSTATE=|DB21034E|SQL[0-9]+N" \
     "${LOG_FILE}" >/dev/null
  then
    fail "DB2 error detected in ${LOG_FILE}"
  fi

  ##########################################
  # Import rejected rows check
  ##########################################
  if [ "${action}" = "import" ] && [ "${allow_reject}" != "true" ]; then
    if grep -i "rows rejected" "${LOG_FILE}" | grep -E "[1-9][0-9]*" >/dev/null
    then
      fail "Rejected rows detected in import (allow_reject=false)"
    fi
  fi

  log "Successfully executed: ${file}"

done < "${RELEASE_PLAN_FILE}"

############################################
# Completion
############################################
log "All data-level changes executed successfully"
exit 0