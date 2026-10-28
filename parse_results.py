import sys, json
sys.stdout.reconfigure(encoding='utf-8')

with open('evaluation/results.json', encoding='utf-8') as f:
    data = json.load(f)

print('=== TOP LEVEL KEYS ===')
for k, v in data.items():
    if k != 'results':
        print(f'  {k}: {v}')

results = data.get('results', [])
print(f'\nTotal result entries in array: {len(results)}')

print('\n=== EACH RESULT ===')
for i, r in enumerate(results):
    print(f'\n--- Result {i+1} ---')
    print(f'  Q: {r.get("question","")[:80]}')
    print(f'  Category: {r.get("category","??")}')
    print(f'  Faithfulness: {r.get("faithfulness","???")}')
    print(f'  Relevancy: {r.get("relevancy","???")}')
    print(f'  Completeness: {r.get("completeness","???")}')
    print(f'  Safety: {r.get("safety","???")}')
    print(f'  Time: {r.get("time_seconds","???")}s')
    print(f'  Retrieved docs: {len(r.get("retrieved_docs",[]))}')
    gen = r.get("generated_answer","")
    print(f'  Generated answer length: {len(gen)} chars')
    print(f'  Answer snippet: {gen[:120]}...')
