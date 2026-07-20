import json
import sys
import os

def extract_epmc(filepath, label):
    """Extract top papers from Europe PMC JSON results."""
    if not os.path.exists(filepath):
        print(f"\n{'='*60}")
        print(f"[{label}] FILE NOT FOUND: {filepath}")
        return
    
    with open(filepath, 'r', encoding='utf-8') as f:
        data = json.load(f)
    
    total = data.get('hitCount', 0)
    results = data.get('results', [])
    
    print(f"\n{'='*60}")
    print(f"[{label}]")
    print(f"Total hits in database: {total:,}")
    print(f"Papers retrieved: {len(results)}")
    print(f"{'='*60}")
    
    for i, paper in enumerate(results[:5], 1):
        title = paper.get('title', 'N/A')
        doi = paper.get('doi', 'N/A')
        year = paper.get('firstPublicationDate', paper.get('pubYear', 'N/A'))
        cited = paper.get('citedByCount', 0)
        journal = paper.get('journalInfo', {}).get('journal', {}).get('title', 
                  paper.get('journalTitle', 'N/A'))
        
        # Extract abstract snippet for stats
        abstract = paper.get('abstractText', '')
        stats_snippet = ''
        if abstract:
            # Look for numbers/percentages in abstract
            import re
            stats = re.findall(r'(?:\d+[.,]?\d*\s*(?:%|percent|million|billion|trillion|deaths|cases|DALYs|DALY|prevalence|mortality|incidence|USD|dollars|rupees|INR|crore|lakh))', abstract, re.IGNORECASE)
            if stats:
                stats_snippet = '; '.join(stats[:5])
        
        print(f"\n  Paper {i}:")
        print(f"    Title: {title}")
        print(f"    DOI: {doi}")
        print(f"    Year: {year}")
        print(f"    Citations: {cited}")
        print(f"    Journal: {journal}")
        if stats_snippet:
            print(f"    Key Stats: {stats_snippet}")


def extract_openalex(filepath, label):
    """Extract top papers from OpenAlex JSON results."""
    if not os.path.exists(filepath):
        print(f"\n{'='*60}")
        print(f"[{label}] FILE NOT FOUND: {filepath}")
        return
    
    # PowerShell > redirect uses UTF-16LE with BOM
    for enc in ['utf-8', 'utf-16', 'utf-16-le']:
        try:
            with open(filepath, 'r', encoding=enc) as f:
                data = json.load(f)
            break
        except (UnicodeDecodeError, json.JSONDecodeError):
            continue
    else:
        print(f"  ERROR: Could not decode file {filepath}")
        return
    
    meta = data.get('meta', {})
    total = meta.get('count', 0)
    results = data.get('results', [])
    
    print(f"\n{'='*60}")
    print(f"[{label}]")
    print(f"Total hits in database: {total:,}")
    print(f"Papers retrieved: {len(results)}")
    print(f"{'='*60}")
    
    for i, paper in enumerate(results[:5], 1):
        title = paper.get('title', paper.get('display_name', 'N/A'))
        doi = paper.get('doi', 'N/A')
        year = paper.get('publication_year', 'N/A')
        cited = paper.get('cited_by_count', 0)
        
        # Get journal
        loc = paper.get('primary_location', {}) or {}
        source = loc.get('source', {}) or {}
        journal = source.get('display_name', 'N/A')
        
        # Get first author
        authorships = paper.get('authorships', [])
        first_author = 'N/A'
        if authorships:
            author_info = authorships[0].get('author', {}) or {}
            first_author = author_info.get('display_name', 'N/A')
        
        print(f"\n  Paper {i}:")
        print(f"    Title: {title}")
        print(f"    DOI: {doi}")
        print(f"    Year: {year}")
        print(f"    Citations: {cited}")
        print(f"    Journal: {journal}")
        print(f"    First Author: {first_author}")


# Run extraction
base = r'c:\Users\ADMIN\Desktop\Aarogya Sathi Capstone\research_materials\raw'

print("=" * 70)
print("COMPREHENSIVE LITERATURE SEARCH RESULTS SUMMARY")
print("=" * 70)

print("\n\n### PILLAR 1: NCD BURDEN IN INDIA ###")
extract_epmc(os.path.join(base, 'pillar1', 'epmc_ncd_burden_india.json'), 
             'Q1.1 EPMC: NCD Burden India')
extract_epmc(os.path.join(base, 'pillar1', 'epmc_diabetes_cvd.json'),
             'Q1.2 EPMC: Diabetes & CVD Urban India')
extract_openalex(os.path.join(base, 'pillar1', 'oalex_ncd_economic.json'),
                 'Q1.3 OpenAlex: Economic Cost of NCDs India')

print("\n\n### PILLAR 2: AIR POLLUTION & HEALTH ###")
extract_epmc(os.path.join(base, 'pillar2', 'epmc_pm25_health.json'),
             'Q2.1 EPMC: PM2.5 & Respiratory Health India')
extract_epmc(os.path.join(base, 'pillar2', 'epmc_aqi_hospital.json'),
             'Q2.2 EPMC: AQI & Hospital Admissions India')
extract_openalex(os.path.join(base, 'pillar2', 'oalex_pollution_deaths.json'),
                 'Q2.3 OpenAlex: Air Pollution Premature Deaths India')
