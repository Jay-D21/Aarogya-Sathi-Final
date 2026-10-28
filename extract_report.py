import sys, zipfile, xml.etree.ElementTree as ET
sys.stdout.reconfigure(encoding='utf-8')

docx = 'report_interim.docx'

W = 'http://schemas.openxmlformats.org/wordprocessingml/2006/main'

with zipfile.ZipFile(docx) as z:
    # Extract main body text
    with z.open('word/document.xml') as f:
        tree = ET.parse(f)
    root = tree.getroot()

    texts = []
    for para in root.iter(f'{{{W}}}p'):
        parts = []
        for t in para.iter(f'{{{W}}}t'):
            if t.text:
                parts.append(t.text)
        line = ''.join(parts).strip()
        if line:
            texts.append(line)

    full_text = '\n'.join(texts)

    # Extract comments
    comments = []
    if 'word/comments.xml' in z.namelist():
        with z.open('word/comments.xml') as f:
            ctree = ET.parse(f)
        croot = ctree.getroot()
        for comment in croot.iter(f'{{{W}}}comment'):
            cid = comment.get(f'{{{W}}}id', '')
            author = comment.get(f'{{{W}}}author', 'Unknown')
            date = comment.get(f'{{{W}}}date', '')
            cparts = []
            for t in comment.iter(f'{{{W}}}t'):
                if t.text:
                    cparts.append(t.text)
            ctext = ''.join(cparts).strip()
            comments.append(f'[Comment #{cid} by {author} on {date}]: {ctext}')

with open('report_text.txt', 'w', encoding='utf-8') as out:
    out.write('=== DOCUMENT BODY ===\n\n')
    out.write(full_text)
    out.write('\n\n=== COMMENTS ===\n\n')
    out.write('\n\n'.join(comments))

print(f'Done: {len(full_text)} chars body, {len(comments)} comments')
print(f'First 10 comments:')
for c in comments[:10]:
    print(c[:200])
