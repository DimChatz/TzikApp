#!/usr/bin/env bash
# Stops commits and pushes that would publish personal data or secrets:
# real email addresses (in files or commit details), passwords, keys, tokens,
# Formspree form IDs, and files like .env or signing keys.
#
#   tool/check_for_leaks.sh --staged           what is about to be committed
#   tool/check_for_leaks.sh <git log range>    commits, e.g. origin/main..HEAD
#
# Run automatically by the hooks in .githooks once enabled with
#   git config core.hooksPath .githooks
# For a false positive, add the harmless text to ALLOWED below.
set -u

# Text that looks sensitive but is fine to publish.
ALLOWED='@users\.noreply\.github\.com|noreply@(github|anthropic)\.com|@example\.(com|org)|xyzabcde'
ALLOWED+='|@[0-9.]+x\.(png|jpe?g|gif|webp|pdf)' # iOS image names like Icon@2x.png

# Emails that may appear in commit details: GitHub's private noreply addresses.
ALLOWED_IDENTITY='(@users\.noreply\.github\.com|^noreply@github\.com)$'

EMAIL='[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}'

SECRETS='-----BEGIN [A-Z ]*PRIVATE KEY-----'
SECRETS+='|gh[pousr]_[A-Za-z0-9]{36}|github_pat_[A-Za-z0-9_]{20,}'
SECRETS+='|AKIA[0-9A-Z]{16}|AIza[0-9A-Za-z_-]{35}|xox[abprs]-[A-Za-z0-9-]{10,}'
SECRETS+='|sk_live_[0-9A-Za-z]{20,}|sk-(ant|proj)-[A-Za-z0-9_-]{20,}'
SECRETS+='|formspree\.io/f/[A-Za-z0-9]{6,}'
SECRETS+='|FORMSPREE_FORM_ID["'\'']?[[:space:]]*[:=][[:space:]]*["'\'']?[A-Za-z0-9]{6,}["'\'']?([[:space:],}]|$)'
SECRETS+='|(password|passwd|secret|api_?key|access_?token|auth_?token|client_?secret)["'\'']?[[:space:]]*[:=][[:space:]]*["'\''][^"'\'' ]{4,}'
SECRETS+='|(store|key)Password[[:space:]]*='

SENSITIVE_FILES='(^|/)(\.env(\.[^/]*)?|key\.properties|id_(rsa|ed25519|ecdsa)[^/]*|credentials[^/]*\.json|service[-_]account[^/]*\.json)$'
SENSITIVE_FILES+='|^config\.json$|\.(jks|keystore|p12|pfx|pem|key|p8|mobileprovision)$'

problems=''
flag() { problems+="  $1"$'\n'; }

check_identity() { # <where> <email>
  if ! grep -qE "$ALLOWED_IDENTITY" <<<"$2"; then
    flag "$1 uses your real email address ($2)"
  fi
}

check_lines() { # lines as "<where>: <text>" on stdin
  local cleaned
  cleaned=$(sed -E "s/[A-Za-z0-9._%+-]*($ALLOWED)//g")
  while IFS= read -r line; do
    [ -n "$line" ] && flag "email address: $line"
  done < <(grep -E -e "$EMAIL" <<<"$cleaned")
  while IFS= read -r line; do
    [ -n "$line" ] && flag "possible secret: $line"
  done < <(grep -iE -e "$SECRETS" <<<"$cleaned")
}

check_files() { # file paths on stdin
  while IFS= read -r file; do
    if [ -n "$file" ] && grep -qE "$SENSITIVE_FILES" <<<"$file" \
        && ! grep -qE '\.example$' <<<"$file"; then
      flag "sensitive file: $file"
    fi
  done
}

# Prints added lines of a diff as "<file>: <text>".
added_lines() {
  awk '/^\+\+\+ / { file = substr($0, 7); next }
       /^\+/      { print file ": " substr($0, 2) }'
}

if [ "${1:-}" = "--staged" ]; then
  for who in AUTHOR COMMITTER; do
    check_identity "Your git $(tr 'A-Z' 'a-z' <<<"$who")" \
      "$(git var "GIT_${who}_IDENT" | sed -E 's/.*<(.*)>.*/\1/')"
  done
  # Process substitution, not pipes, so flag() runs in this shell.
  check_lines < <(git diff --cached -U0 --no-color --diff-filter=ACMR | added_lines)
  check_files < <(git diff --cached --name-only --diff-filter=ACMR)
else
  while read -r sha author committer; do
    check_identity "Commit $sha (author)" "$author"
    check_identity "Commit $sha (committer)" "$committer"
  done < <(git log --format='%h %ae %ce' "$@")
  check_lines < <(git log -p -U0 --no-color --diff-filter=ACMR --format= "$@" | added_lines)
  check_lines < <(git log --format='%B' "$@" | sed 's/^/commit message: /')
  check_files < <(git log --name-only --diff-filter=ACMR --format= "$@" | sort -u)
fi

if [ -n "$problems" ]; then
  {
    echo "Blocked: this would publish personal data or secrets."
    printf '%s' "$problems"
    echo
    echo "Remove them and try again. Use a GitHub noreply address for git:"
    echo "  git config user.email ID+USERNAME@users.noreply.github.com"
    echo "  (yours is listed at https://github.com/settings/emails)"
    echo "False positive? Add the harmless text to ALLOWED in $0,"
    echo "or skip the check once with --no-verify."
  } >&2
  exit 1
fi
