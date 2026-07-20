import json, os, re, sys

sys.stdout.reconfigure(encoding='utf-8', errors='replace')

BASE = r"c:\Users\ADMIN\Desktop\Aarogya Sathi Capstone\research_materials\raw\pillar3_4"

def load_json_multi(filepath):
    """Load file that may have multiple JSON objects; return the last one (most complete)."""
    try:
        with open(filepath, "r", encoding="utf-8") as f:
            content = f.read()
    except UnicodeDecodeError:
        with open(filepath, "r", encoding="utf-16") as f:
            content = f.read()

    # Try single JSON first
    try:
        return json.loads(content)
    except json.JSONDecodeError:
        pass

    # Parse multiple JSON objects, return the last one
    decoder = json.JSONDecoder()
    idx = 0
    last_obj = None
    while idx < len(content):
        content_stripped = content[idx:].lstrip()
        if not content_stripped:
            break
        idx = len(content) - len(content_stripped)
        try:
            obj, end = decoder.raw_decode(content, idx)
            last_obj = obj
            idx += end
        except json.JSONDecodeError:
            idx += 1
    return last_obj

def safe(text):
    if not text: return "N/A"
    if not isinstance(text, str): return str(text)
    return text.encode('ascii', errors='replace').decode('ascii')

def print_arxiv(filepath, label):
    data = load_json_multi(filepath)
    if data is None:
        print(f"\n{label}: FAILED TO PARSE")
        return
    papers = data.get("papers", [])
    print(f"\n{'='*60}")
    print(f"  {label}")
    print(f"{'='*60}")
    print(f"Results count: {data.get('results_count', len(papers))}")
    for i, r in enumerate(papers[:5]):
        print(f"\n--- Paper {i+1} ---")
        print(f"Title: {safe(r.get('title', 'N/A'))}")
        print(f"arXiv ID: {r.get('id', 'N/A')}")
        print(f"Published: {r.get('published', 'N/A')}")
        print(f"Category: {r.get('primary_category', 'N/A')}")
        print(f"Journal: {safe(r.get('journal_ref', 'N/A'))}")
        authors = r.get("authors", [])
        if authors:
            print(f"Authors: {safe(', '.join(authors[:4]))}")
        summary = r.get("summary", "")
        if summary:
            clean = re.sub(r"\s+", " ", summary).strip()
            print(f"Abstract snippet: {safe(clean[:400])}")

print_arxiv(os.path.join(BASE, "arxiv_rag_medical.json"), "QUERY 4.1: RAG in Medical/Healthcare (arXiv)")
print_arxiv(os.path.join(BASE, "arxiv_hallucination.json"), "QUERY 4.2: Hallucination Safety Healthcare (arXiv)")
print_arxiv(os.path.join(BASE, "arxiv_medical_chatbot.json"), "QUERY 4.3: Medical Chatbot LLM (arXiv)")
