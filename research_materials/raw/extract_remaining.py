import json
import os
import re

base = r'c:\Users\ADMIN\Desktop\Aarogya Sathi Capstone\research_materials\raw'

def load_json(filepath):
    for enc in ['utf-8', 'utf-16', 'utf-16-le']:
        try:
            with open(filepath, 'r', encoding=enc) as f:
                return json.load(f)
        except:
            continue
    return None

# Check EPMC files for India-specific papers (papers 6-15)
print("=== INDIA-SPECIFIC PAPERS (Papers 6-15 from each EPMC query) ===\n")

for fname, label in [
    ('pillar1/epmc_ncd_burden_india.json', 'Q1.1 NCD Burden'),
    ('pillar1/epmc_diabetes_cvd.json', 'Q1.2 Diabetes/CVD'),
    ('pillar2/epmc_pm25_health.json', 'Q2.1 PM2.5 Health'),
    ('pillar2/epmc_aqi_hospital.json', 'Q2.2 AQI Hospital'),
]:
    data = load_json(os.path.join(base, fname))
    if not data: continue
    results = data.get('results', [])
    
    print(f"\n--- {label} (Papers 6-15) ---")
    for i, paper in enumerate(results[5:], 6):
        title = paper.get('title', 'N/A')
        doi = paper.get('doi', 'N/A')
        year = paper.get('firstPublicationDate', paper.get('pubYear', 'N/A'))
        cited = paper.get('citedByCount', 0)
        journal = paper.get('journalInfo', {}).get('journal', {}).get('title', 
                  paper.get('journalTitle', 'N/A'))
        abstract = paper.get('abstractText', '')[:300]
        
        print(f"  {i}. [{cited} cites] ({year}) {title}")
        print(f"     DOI: {doi} | Journal: {journal}")
        if abstract:
            print(f"     Abstract: {abstract}...")
        print()

# Also check OpenAlex papers 6-10
for fname, label in [
    ('pillar1/oalex_ncd_economic.json', 'Q1.3 NCD Economic'),
    ('pillar2/oalex_pollution_deaths.json', 'Q2.3 Pollution Deaths'),
]:
    data = load_json(os.path.join(base, fname))
    if not data: continue
    results = data.get('results', [])
    
    print(f"\n--- {label} (Papers 6-10) ---")
    for i, paper in enumerate(results[5:], 6):
        title = paper.get('title', paper.get('display_name', 'N/A'))
        doi = paper.get('doi', 'N/A')
        year = paper.get('publication_year', 'N/A')
        cited = paper.get('cited_by_count', 0)
        loc = paper.get('primary_location', {}) or {}
        source = loc.get('source', {}) or {}
        journal = source.get('display_name', 'N/A')
        
        print(f"  {i}. [{cited} cites] ({year}) {title}")
        print(f"     DOI: {doi} | Journal: {journal}")
        print()
