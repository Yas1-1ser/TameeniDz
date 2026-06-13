import re
import os
import json
import subprocess

with open('analyze.txt', 'r', encoding='utf-16') as f:
    lines = f.readlines()

missing_keys = set()
tr_errors = set()

for line in lines:
    # Look for missing getters
    match = re.search(r"The getter '(.*?)' isn't defined for the type 'AppLocalizations'", line)
    if match:
        missing_keys.add(match.group(1))
    
    # Look for .tr() left behind
    if "The method 'tr' isn't defined" in line or "undefined_method" in line and "tr" in line:
        tr_errors.add(line.strip())

print(f"Found {len(missing_keys)} missing keys.")

arb_files = [
    r'd:\tameenidz\lib\l10n\app_en.arb',
    r'd:\tameenidz\lib\l10n\app_ar.arb',
    r'd:\tameenidz\lib\l10n\app_fr.arb',
    r'd:\tameenidz\lib\l10n\app_kab.arb',
]

def add_keys_to_arb(arb_path, keys):
    if not os.path.exists(arb_path):
        print(f"File not found: {arb_path}")
        return
        
    with open(arb_path, 'r', encoding='utf-8') as f:
        data = json.load(f)
        
    added = False
    for key in keys:
        if key not in data:
            # simple human readable conversion
            readable = re.sub(r'([A-Z])', r' \1', key).title()
            data[key] = readable
            added = True
            
    if added:
        with open(arb_path, 'w', encoding='utf-8') as f:
            json.dump(data, f, ensure_ascii=False, indent=2)
        print(f"Updated {arb_path}")

if missing_keys:
    for arb in arb_files:
        add_keys_to_arb(arb, missing_keys)

# Re-run l10n generation
print("Running flutter gen-l10n...")
subprocess.run(['flutter', 'gen-l10n', '--output-dir=lib/generated/l10n', '--no-synthetic-package'], shell=True)
print("Done.")

# Show other tr() errors
if tr_errors:
    print("\nFiles that still have .tr() errors (likely dynamic variables):")
    for err in tr_errors:
        print(err)
