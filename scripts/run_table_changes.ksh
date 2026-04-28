#!/usr/bin/ksh

################################################################################
# Script: run_table_changes.ksh

set -u   # error on unset variables

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
: ${DB_NAME:?Missing DB_NAME}
: ${DB_SCHEMA:?Missing DB_SCHEMA}
: ${RELEASE_DATE:?Missing RELEASE_DATE}
: ${RELEASE_PLAN_FILE:?Missing RELEASE_PLAN_FILE}

BASE_DIR="/apps/ingenium/${REGION}/server/dbparms/jenkins"
DDL_DIR="${BASE_DIR}/sql/ddl/${RELEASE_DATE}"
LOG_DIR="${BASE_DIR}/logs/${RELEASE_DATE}/ddl"

########################################
# Pre-flight checks
########################################
[ -f "${RELEASE_PLAN_FILE}" ] || fail "Release plan file not found: ${RELEASE_PLAN_FILE}"
[ -d "${DDL_DIR}" ] || fail "DDL SQL directory not found: ${DDL_DIR}"

mkdir -p "${LOG_DIR}" || fail "Unable to create log directory: ${LOG_DIR}"

log "Starting TABLE changes execution"
log "DB_NAME=${DB_NAME}, DB_SCHEMA=${DB_SCHEMA}, RELEASE_DATE=${RELEASE_DATE}"

########################################
# DB2 connection check
########################################
log "Connecting to database ${DB_NAME}"
db2 connect to "${DB_NAME}" || fail "DB2 connect failed"

db2 set schema "${DB_SCHEMA}" || fail "Failed to set DB2 schema"

########################################
# Process release plan file
########################################
while read LINE || [ -n "${LINE}" ]; do

  # Skip empty lines and comments
  [[ -z "${LINE}" || "${LINE}" = \#* ]] && continue

  unset action file

  for KV in ${LINE}; do
    KEY=$(print "${KV}" | cut -d= -f1)
    VAL=$(print "${KV}" | cut -d= -f2)

    case "${KEY}" in
      action) action="${VAL}" ;;
      file)   file="${VAL}" ;;
      *)      fail "Invalid key '${KEY}' found in release file" ;;
    esac
  done

  ####################################
  # Line-level validation
  ####################################
  [ "${action}" = "ddl" ] || fail "Invalid action '${action}'. Only 'ddl' allowed."
  [ -n "${file}" ] || fail "SQL filename missing in release file"

  SQL_FILE="${DDL_DIR}/${file}"
  LOG_FILE="${LOG_DIR}/${file%.sql}.log"

  [ -f "${SQL_FILE}" ] || fail "SQL file not found: ${SQL_FILE}"

  ####################################
  # Execute SQL
  ####################################
  log "Executing DDL file: ${file}"
  db2 -tvsf "${SQL_FILE}" -z "${LOG_FILE}"
  RC=$?

  if [ ${RC} -ne 0 ]; then
    fail "DB2 command failed for ${file} (RC=${RC})"
  fi

  ####################################
  # Explicit log scan for DB2 errors
  ####################################
  if grep -E "SQLCODE[[:space:]]*=[[:space:]]*-[0-9]+|SQLSTATE=|DB21034E|SQL[0-9]+N" "${LOG_FILE}" >/dev/null
  then
    fail "DB2 error detected in log file: ${LOG_FILE}"
  fi

  log "Successfully executed: ${file}"

done < "${RELEASE_PLAN_FILE}"

########################################
# Completion
########################################
log "All table-level changes executed successfully"
exit 0
# Purpose: Execute table-level (DDL) SQL changes in strict order.
#          Stops immediately on any failure.
