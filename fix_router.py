with open('backend/safety/router.py', encoding='utf-8') as f:
    content = f.read()

old = '    "📞 Emergency: 112\\n"\n    "🏥 Ambulance: 102\\n"\n    "☠️ Poison Control: 1800-11-6117"\n)'
new = '    "📞 National Emergency: 112\\n"\n    "🚑 Ambulance: 108 (EMRI) / 102 (NHM)\\n"\n    "☠️ Poison Control: 1800-11-6117"\n)'

if old in content:
    content = content.replace(old, new)
    with open('backend/safety/router.py', 'w', encoding='utf-8') as f:
        f.write(content)
    print('Done — 108 added to router')
else:
    # Try with \r\n line endings
    old2 = '    "📞 Emergency: 112\\n"\r\n    "🏥 Ambulance: 102\\n"\r\n    "☠️ Poison Control: 1800-11-6117"\r\n)'
    new2 = '    "📞 National Emergency: 112\\n"\r\n    "🚑 Ambulance: 108 (EMRI) / 102 (NHM)\\n"\r\n    "☠️ Poison Control: 1800-11-6117"\r\n)'
    if old2 in content:
        content = content.replace(old2, new2)
        with open('backend/safety/router.py', 'w', encoding='utf-8') as f:
            f.write(content)
        print('Done (CRLF) — 108 added to router')
    else:
        print('Pattern not found. Showing relevant lines:')
        for i, l in enumerate(content.split('\n')[10:22], start=11):
            print(f'{i}: {repr(l)}')
