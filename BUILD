Connect IQ (Monkey C) watch app — Turnos Web

Prerequisites
- Garmin Connect IQ SDK installed (monkeyc on PATH or set SDK in Makefile).
- A developer signing key in PKCS#8 DER form (private_key.der). Generate with OpenSSL:
    openssl genrsa -out private_key.pem 4096
    openssl pkcs8 -topk8 -inform PEM -outform DER -in private_key.pem -out private_key.der -nocrypt
  Keep this key private; do not commit it to public repos.

Build
  cd /path/to/adrogue-running
  make build

Simulator
1) make simulator
2) make run

Physical watch
Configure domain, username and password via Garmin Connect IQ app settings, then sync.

See README.md for full documentation in Spanish.
