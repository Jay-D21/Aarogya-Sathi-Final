import sys, re
sys.stdout.reconfigure(encoding='utf-8')

with open('backend/rag/okf_navigator.py', encoding='utf-8') as f:
    lines = f.readlines()

print('=== OKF Navigator lines 110-130 (model call) ===')
for i, l in enumerate(lines[109:130], start=110):
    print(f'{i}: {l}', end='')

print()
with open('backend/safety/routes.py', encoding='utf-8') as f:
    rc = f.read()

# Count utterances - look for list entries
lines_r = rc.split('\n')
utterance_lines = [l.strip() for l in lines_r if l.strip().startswith('"') or l.strip().startswith("'")]
print(f'Total utterance lines in routes.py: {len(utterance_lines)}')
print('First 10:')
for u in utterance_lines[:10]:
    print(' ', u[:80])

# Also check how many ROUTES_AVAILABLE routes exist
print()
print('Route categories found:')
for line in lines_r:
    if 'Route(' in line or 'name=' in line:
        print(' ', line.strip()[:80])
