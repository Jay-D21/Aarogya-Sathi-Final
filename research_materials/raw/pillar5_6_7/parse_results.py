import json, os, glob

base = r'c:\Users\ADMIN\Desktop\Aarogya Sathi Capstone\research_materials\raw\pillar5_6_7'
files = sorted(glob.glob(os.path.join(base, '*.json')))

for f in files:
    fname = os.path.basename(f)
    print(f'=== {fname} ===')
    # Try multiple encodings (PowerShell redirect creates UTF-16)
    for enc in ['utf-8-sig', 'utf-16', 'utf-16-le', 'utf-8', 'latin-1']:
        try:
            with open(f, 'r', encoding=enc) as fh:
                content = fh.read()
            break
        except (UnicodeDecodeError, UnicodeError):
            continue
    else:
        print('  Could not decode file')
        print()
        continue
    
    # Find all JSON objects (arXiv outputs progressive JSON)
    objects = []
    decoder = json.JSONDecoder()
    pos = 0
    while pos < len(content):
        content_stripped = content[pos:].lstrip()
        if not content_stripped:
            break
        try:
            obj, idx = decoder.raw_decode(content_stripped)
            objects.append(obj)
            pos = pos + (len(content[pos:]) - len(content_stripped)) + idx
        except json.JSONDecodeError:
            break
    
    if not objects:
        print('  No valid JSON objects found')
        print()
        continue
    
    # Take the last (most complete) object
    data = objects[-1]
    
    papers = data.get('papers', data.get('results', []))
    print(f'  Total papers: {len(papers)}')
    
    for i, p in enumerate(papers[:5]):
        title = p.get('title', p.get('display_name', 'N/A'))
        pid = p.get('id', p.get('doi', p.get('pmid', 'N/A')))
        year_raw = p.get('published', p.get('firstPublicationDate', p.get('publication_year', 'N/A')))
        year = str(year_raw)[:10]
        cited = p.get('cited_by_count', p.get('citedByCount', 'N/A'))
        journal = p.get('journal_ref', p.get('journalTitle', p.get('primary_category', 'N/A')))
        
        # For OpenAlex format
        if 'primary_location' in p:
            loc = p.get('primary_location', {})
            if loc and 'source' in loc and loc['source']:
                journal = loc['source'].get('display_name', journal)
        
        abstract_text = p.get('summary', p.get('abstractText', ''))
        snippet = abstract_text[:250] if abstract_text else 'N/A'
        
        print(f'  [{i+1}] {title}')
        print(f'      ID: {pid} | Year: {year} | Cited: {cited} | Venue: {journal}')
        print(f'      Abstract: {snippet}...')
    print()
