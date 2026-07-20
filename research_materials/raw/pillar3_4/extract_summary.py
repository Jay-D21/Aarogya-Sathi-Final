import json, os

BASE = r"c:\Users\ADMIN\Desktop\Aarogya Sathi Capstone\research_materials\raw\pillar3_4"

def load_json(filepath):
    """Try utf-8, then utf-16"""
    try:
        with open(filepath, "r", encoding="utf-8") as f:
            return json.load(f)
    except (UnicodeDecodeError, json.JSONDecodeError):
        with open(filepath, "r", encoding="utf-16") as f:
            return json.load(f)

def print_epmc(filepath, label):
    data = load_json(filepath)
    print(f"\n{'='*60}")
    print(f"  {label}")
    print(f"{'='*60}")
    print(f"Total hits: {data.get('hitCount', '?')}")
    print(f"Results saved: {len(data.get('results', []))}")
    for i, r in enumerate(data.get("results", [])[:5]):
        print(f"\n--- Paper {i+1} ---")
        print(f"Title: {r.get('title', 'N/A')}")
        print(f"DOI: {r.get('doi', 'N/A')}")
        print(f"PMID: {r.get('pmid', 'N/A')}")
        print(f"Year: {r.get('pubYear', 'N/A')}")
        print(f"Cited: {r.get('citedByCount', 'N/A')}")
        journal = r.get("journalTitle", None) or r.get("journalInfo", {}).get("journal", {}).get("title", "N/A") if isinstance(r.get("journalInfo"), dict) else "N/A"
        print(f"Journal: {journal}")
        abstract = r.get("abstractText", "")
        if abstract:
            # strip HTML tags roughly
            import re
            clean = re.sub(r"<[^>]+>", "", abstract)
            print(f"Abstract snippet: {clean[:350]}")

def print_openalex(filepath, label):
    data = load_json(filepath)
    results = data.get("results", [])
    meta = data.get("meta", {})
    print(f"\n{'='*60}")
    print(f"  {label}")
    print(f"{'='*60}")
    print(f"Total hits: {meta.get('count', '?')}")
    print(f"Results saved: {len(results)}")
    for i, r in enumerate(results[:5]):
        print(f"\n--- Paper {i+1} ---")
        print(f"Title: {r.get('title', r.get('display_name', 'N/A'))}")
        print(f"DOI: {r.get('doi', 'N/A')}")
        print(f"Year: {r.get('publication_year', 'N/A')}")
        print(f"Cited: {r.get('cited_by_count', 'N/A')}")
        loc = r.get("primary_location", {}) or {}
        src = loc.get("source", {}) or {}
        print(f"Journal: {src.get('display_name', 'N/A')}")
        # Authors
        auths = r.get("authorships", [])[:3]
        names = [a.get("author", {}).get("display_name", "") for a in auths]
        if names:
            print(f"Authors: {', '.join(names)}...")

def print_arxiv(filepath, label):
    data = load_json(filepath)
    results = data if isinstance(data, list) else data.get("results", data.get("entries", []))
    print(f"\n{'='*60}")
    print(f"  {label}")
    print(f"{'='*60}")
    print(f"Results saved: {len(results)}")
    for i, r in enumerate(results[:5]):
        print(f"\n--- Paper {i+1} ---")
        title = r.get("title", "N/A")
        if isinstance(title, str):
            title = " ".join(title.split())
        print(f"Title: {title}")
        arxiv_id = r.get("id", r.get("arxiv_id", r.get("entry_id", "N/A")))
        print(f"arXiv ID: {arxiv_id}")
        print(f"Published: {r.get('published', r.get('pub_date', 'N/A'))}")
        cats = r.get("categories", r.get("primary_category", "N/A"))
        if isinstance(cats, dict):
            cats = cats.get("term", cats.get("@term", str(cats)))
        print(f"Categories: {cats}")
        summary = r.get("summary", r.get("abstract", ""))
        if isinstance(summary, str):
            import re
            clean = re.sub(r"\s+", " ", summary).strip()
            print(f"Abstract snippet: {clean[:400]}")

# EPMC queries
print_epmc(os.path.join(BASE, "epmc_digital_health.json"), "QUERY 3.1: Digital Health Interventions (Europe PMC)")
print_epmc(os.path.join(BASE, "epmc_telemedicine.json"), "QUERY 3.2: Telemedicine India (Europe PMC)")

# OpenAlex
print_openalex(os.path.join(BASE, "oalex_roi_preventive.json"), "QUERY 3.3: ROI Preventive Health (OpenAlex)")

# arXiv queries
print_arxiv(os.path.join(BASE, "arxiv_rag_medical.json"), "QUERY 4.1: RAG in Medical/Healthcare (arXiv)")
print_arxiv(os.path.join(BASE, "arxiv_hallucination.json"), "QUERY 4.2: Hallucination Safety Healthcare (arXiv)")
print_arxiv(os.path.join(BASE, "arxiv_medical_chatbot.json"), "QUERY 4.3: Medical Chatbot LLM (arXiv)")
