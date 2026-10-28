import sys, json
sys.stdout.reconfigure(encoding='utf-8')

with open('evaluation/gold_qa.json', encoding='utf-8') as f:
    data = json.load(f)
from collections import Counter
cats = Counter(q.get('category','unknown') for q in data)
print(f'Total Q&A pairs: {len(data)}')
print('By category:', dict(cats))

try:
    with open('evaluation/results.json', encoding='utf-8') as f:
        results = json.load(f)
    print(f'\nEvaluated: {len(results)} questions')
    scored = [r for r in results if r.get('faithfulness', 0) > 0]
    print(f'Successfully scored (non-zero faith): {len(scored)}')
    if scored:
        avg_faith = sum(r['faithfulness'] for r in scored) / len(scored)
        avg_rel = sum(r['relevancy'] for r in scored) / len(scored)
        avg_comp = sum(r.get('completeness',0) for r in scored) / len(scored)
        avg_safe = sum(r.get('safety',0) for r in scored) / len(scored)
        print(f'Avg Faithfulness: {avg_faith:.2f}')
        print(f'Avg Relevancy: {avg_rel:.2f}')
        print(f'Avg Completeness: {avg_comp:.2f}')
        print(f'Avg Safety: {avg_safe:.2f}')
        for r in scored:
            q = r.get('question','')[:60]
            print(f'  Q: {q} | F:{r["faithfulness"]} R:{r["relevancy"]} C:{r.get("completeness",0)} S:{r.get("safety",0)}')
except Exception as e:
    print(f'Error: {e}')
