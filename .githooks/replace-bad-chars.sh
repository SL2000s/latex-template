#!/bin/bash
# Replace en dashes (–) with double hyphens (--)
# Replace non-breaking spaces ( ) with normal spaces ( )
# Replace (−) with (-)
# in .tex and .bib files. Fails (exit 1) if any replacements were needed.

set -e  # stop if any command fails
changed=0

# Get staged .tex and .bib files
files=$(git diff --cached --name-only --diff-filter=ACM | grep -E '\.(tex|bib)$' || true)

if [ -z "$files" ]; then
  exit 0
fi

for file in $files; do
  if [ -f "$file" ]; then
    # Check if file contains en dash or non-breaking space
    if grep -q -e "–" -e " " -e "−" "$file"; then  # note: the second space here is actually a non-breaking space
      changed=1
      # echo "Fixing bad characters in: $file"
      if [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS BSD sed requires the '' after -i
        sed -i '' -e 's/–/--/g' -e 's/ / /g' -e 's/−/-/g' "$file"
      else
        # GNU sed
        sed -i -e 's/–/--/g' -e 's/ / /g' -e 's/−/-/g' "$file"
      fi
    fi
  fi
done

if [ "$changed" -eq 1 ]; then
  echo "Found and replaced bad characters. Please review and re-commit."
  exit 1
else
  # echo "No en dashes found."
  exit 0
fi
