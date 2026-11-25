#!/usr/bin/env bash
# Runs supabase/schema.sql on throwaway local Postgres databases, then the database tests:
#   1. a fresh project
#   2. a project shared with Word Buddy (its tables and sign-up trigger already there)
#   3. a shared project an older Recipe App setup broke: schema.sql must stop with clear advice
# Needs Postgres installed locally (for example: brew install postgresql@17). Nothing touches Supabase.
set -euo pipefail
cd "$(dirname "$0")"
if ! command -v initdb >/dev/null || ! command -v pg_ctl >/dev/null; then
  echo "Postgres is not installed, skipping the database tests (brew install postgresql@17)."; exit 0
fi
export LC_ALL=C LANG=C
DIR="$(mktemp -d)"; SOCK="$(mktemp -d /tmp/rapg.XXXX)"; PORT=55433
cleanup() { pg_ctl -D "$DIR" stop -m immediate >/dev/null 2>&1 || true; rm -rf "$DIR" "$SOCK"; }
trap cleanup EXIT
initdb -D "$DIR" -U postgres -A trust >/dev/null
pg_ctl -D "$DIR" -o "-p $PORT -k $SOCK -c listen_addresses=''" -l "$DIR/log" start >/dev/null
PSQL=(psql -h "$SOCK" -p "$PORT" -U postgres -X -q -v ON_ERROR_STOP=1)
total=0

fresh_db() {
  "${PSQL[@]}" -d postgres -c "drop database if exists t" -c "create database t" >/dev/null
  # roles are cluster-wide: create them once
  "${PSQL[@]}" -d postgres -tAc "select 1 from pg_roles where rolname = 'anon'" | grep -q 1 || \
    "${PSQL[@]}" -d postgres -c "create role anon nologin" -c "create role authenticated nologin" >/dev/null
  sed '/^create role /d' auth-stub.sql | "${PSQL[@]}" -d t >/dev/null
}

run_tests() { # $1 = file, $2 = label
  local out
  if ! out=$("${PSQL[@]}" -d t -f "$1" 2>&1); then
    echo "$out" | sed -n 's/.*NOTICE:  //p'; echo "$out" | grep -E "ERROR|FAILED" | sed 's/^psql:[^ ]* //'
    echo "FAILED in: $2"; exit 1
  fi
  echo "$out" | sed -n "s/.*NOTICE:  ok - /ok - [$2] /p"
  total=$((total + $(echo "$out" | grep -c 'NOTICE:  ok')))
}

apply_schema_twice() { # $1 = label
  for run in 1 2; do
    if ! out=$("${PSQL[@]}" -d t -f ../schema.sql 2>&1); then echo "$out" | grep -v NOTICE; echo "schema.sql failed ($1, run $run)"; exit 1; fi
  done
  echo "ok - [$1] schema.sql runs twice without errors"; total=$((total + 1))
}

# 1. Fresh project
fresh_db; apply_schema_twice "fresh"; run_tests tests.sql "fresh"

# 2. Shared with Word Buddy
fresh_db; "${PSQL[@]}" -d t -f word-buddy-like.sql >/dev/null
apply_schema_twice "with Word Buddy"; run_tests tests.sql "with Word Buddy"; run_tests word-buddy-checks.sql "with Word Buddy"

# 3. Shared project broken by an old setup: must refuse and explain
fresh_db; "${PSQL[@]}" -d t -f word-buddy-like.sql >/dev/null; "${PSQL[@]}" -d t -f broken-by-old-setup.sql >/dev/null
if out=$("${PSQL[@]}" -d t -f ../schema.sql 2>&1); then echo "FAILED: schema.sql should refuse to run on a broken shared project"; exit 1; fi
echo "$out" | grep -q "word-buddy/supabase/schema.sql" || { echo "$out"; echo "FAILED: no clear advice"; exit 1; }
echo "ok - [broken] schema.sql stops and says to restore Word Buddy first"; total=$((total + 1))

echo "All $total database checks passed."
