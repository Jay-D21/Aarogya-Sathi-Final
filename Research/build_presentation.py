import re

with open('C:/Users/ADMIN/Desktop/Experiments/open-design/design-templates/html-ppt-zhangzara-blue-professional/example.html', 'r', encoding='utf-8') as f:
    lines = f.readlines()

css_content = ''.join(lines[10:920])
js_content = ''.join(lines[1349:1420])
nav_content = ''.join(lines[1336:1348])

html_output = f'''<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Aarogya Sathi Presentation</title>
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
  <link href="https://fonts.googleapis.com/css2?family=Space+Grotesk:wght@300;400;500;600;700&family=Inter:wght@300;400;500;600&display=swap" rel="stylesheet">

  <style>
{css_content}
    /* ============================================================
       LAYOUT 14: Gantt Chart
       ============================================================ */
    .layout-gantt .slide-content {{
      justify-content: flex-start;
    }}

    .layout-gantt .gantt-container {{
      display: flex;
      flex-direction: column;
      flex: 1;
      margin-top: 1rem;
      background: var(--card-bg);
      border: 1px solid var(--border);
      border-radius: 12px;
      padding: 1.5rem;
      overflow: hidden;
    }}

    .gantt-header {{
      display: grid;
      grid-template-columns: 200px repeat(12, 1fr);
      gap: 0.5rem;
      border-bottom: 2px solid var(--border);
      padding-bottom: 0.8rem;
      margin-bottom: 0.8rem;
    }}

    .gantt-col-title {{
      font-family: 'Space Grotesk', sans-serif;
      font-weight: 600;
      font-size: 0.85rem;
      color: var(--text);
      text-align: center;
    }}
    .gantt-col-title.left {{
      text-align: left;
    }}

    .gantt-row {{
      display: grid;
      grid-template-columns: 200px repeat(12, 1fr);
      gap: 0.5rem;
      align-items: center;
      margin-bottom: 0.6rem;
    }}

    .gantt-task-name {{
      font-size: 0.85rem;
      color: var(--text);
      font-weight: 500;
    }}

    .gantt-bar {{
      background: var(--primary);
      height: 24px;
      border-radius: 6px;
      opacity: 0.9;
    }}
  </style>
</head>
<body>

  <div class="deck">

    <!-- SLIDE 1: Cover -->
    <div class="slide layout-cover active">
      <div class="cover-decoration"></div>
      <div class="cover-dots">
        <div class="dot"></div><div class="dot"></div><div class="dot"></div>
        <div class="dot"></div><div class="dot"></div><div class="dot"></div>
        <div class="dot"></div><div class="dot"></div><div class="dot"></div>
      </div>
      <h1>Aarogya Sathi</h1>
      <p class="subtitle">A Sovereign, Agentic Digital Health Assistant for Preventive NCD Management in Urban India</p>
      <div class="meta">Jayesh Patil (C233) &middot; Abhijit Patil (C263) &middot; Ritesh Pawar (C276)<br>Capstone Project &middot; 1st Review &middot; 2026</div>
    </div>

    <!-- SLIDE 2: Agenda -->
    <div class="slide layout-agenda">
      <div class="slide-header">
        <h4>Table of Contents</h4>
      </div>
      <h2>Agenda</h2>
      <div class="agenda-grid">
        <div class="agenda-item">
          <div class="agenda-num">01</div>
          <div>
            <h3>Problem Statement</h3>
            <p>The crises of NCDs, air pollution, and linguistic exclusion facing urban India</p>
          </div>
        </div>
        <div class="agenda-item">
          <div class="agenda-num">02</div>
          <div>
            <h3>Motivation & Need</h3>
            <p>From personal experience to macroeconomic imperative</p>
          </div>
        </div>
        <div class="agenda-item">
          <div class="agenda-num">03</div>
          <div>
            <h3>Objectives</h3>
            <p>What we aim to build and prove</p>
          </div>
        </div>
        <div class="agenda-item">
          <div class="agenda-num">04</div>
          <div>
            <h3>Scope</h3>
            <p>Boundaries and deliverables of the MVP</p>
          </div>
        </div>
        <div class="agenda-item">
          <div class="agenda-num">05</div>
          <div>
            <h3>Literature Review</h3>
            <p>Evidence base from peer-reviewed research</p>
          </div>
        </div>
        <div class="agenda-item">
          <div class="agenda-num">06</div>
          <div>
            <h3>Methodology, Tools & Timeline</h3>
            <p>Architecture, technology stack, and Gantt chart</p>
          </div>
        </div>
      </div>
    </div>

    <!-- SLIDE 3: Key Metrics -->
    <div class="slide layout-metrics">
      <div class="slide-header">
        <h4>Problem Statement</h4>
        <span class="tag">The Crisis</span>
      </div>
      <div class="slide-content">
        <h2>India's preventive healthcare is broken at three levels</h2>
        <div class="metrics-row">
          <div class="metric-card">
            <div class="metric-value">63%</div>
            <div class="metric-label">Deaths from NCDs</div>
            <div class="metric-desc">Non-Communicable Diseases like diabetes, CVDs, and COPD cause 63% of all deaths in India — yet preventive infrastructure is near-zero.</div>
            <ul class="metric-supports">
              <li>ICMR-INDIAB: 26.4% urban diabetes prevalence</li>
              <li>GBD 2019 (The Lancet): NCDs dominate India's mortality</li>
              <li>WEF: $4.58 Trillion projected economic loss by 2030</li>
            </ul>
            <div class="metric-change negative">↑ Rising year over year</div>
          </div>
          <div class="metric-card">
            <div class="metric-value">4.2M</div>
            <div class="metric-label">Premature deaths from PM2.5</div>
            <div class="metric-desc">Air pollution causes 4.2 million premature deaths globally. Indian cities consistently breach WHO safe limits by 10-15x.</div>
            <ul class="metric-supports">
              <li>AQLI 2024: Delhi residents lose 11.9 years of life expectancy</li>
              <li>Lelieveld et al. (Nature 2015): South Asia bears highest burden</li>
              <li>200K+ emergency respiratory admissions linked to AQI events</li>
            </ul>
            <div class="metric-change negative">↑ Worsening annually</div>
          </div>
          <div class="metric-card">
            <div class="metric-value">90%</div>
            <div class="metric-label">Excluded from AI health tools</div>
            <div class="metric-desc">Over 90% of Indians don't speak English as a primary language. Virtually all AI health tools are English-only.</div>
            <ul class="metric-supports">
              <li>Census of India: 22 official languages</li>
              <li>Existing apps (Practo, Ada Health) English-only</li>
              <li>Health literacy gaps compound chronic disease outcomes</li>
            </ul>
            <div class="metric-change negative">Not improving</div>
          </div>
        </div>
      </div>
    </div>

    <!-- SLIDE 4: Quote -->
    <div class="slide layout-quote">
      <div class="quote-decoration"></div>
      <div class="quote-decoration-2"></div>
      <div class="quote-mark">"</div>
      <blockquote>My father has high cholesterol and he constantly has small, everyday questions about his diet and routine. We realized someone needs to build a simple, vernacular health companion that can answer daily queries — without needing a doctor's visit for every small doubt.</blockquote>
      <div class="quote-source"><strong>Jayesh Patil, Co-founder</strong> — Personal Motivation for Aarogya Sathi</div>
    </div>

    <!-- SLIDE 5: Dashboard -->
    <div class="slide layout-dashboard">
      <div class="slide-header">
        <h4>Motivation & Need</h4>
        <span class="tag">Evidence</span>
      </div>
      <div class="slide-content">
        <h2>Macroeconomic & clinical evidence demanding a digital health assistant</h2>
        <div class="stats-grid">
          <div class="stat-cell">
            <div class="stat-top">
              <span class="stat-num">14.3:1</span>
            </div>
            <div class="stat-name">ROI of preventive health</div>
            <div class="stat-context">Masters et al. (JECH 2017) — median return on investment for public health interventions</div>
          </div>
          <div class="stat-cell">
            <div class="stat-top">
              <span class="stat-num">100M+</span>
            </div>
            <div class="stat-name">eSanjeevani consultations</div>
            <div class="stat-context">Govt of India digital health milestone — proving demand for remote health</div>
          </div>
          <div class="stat-cell">
            <div class="stat-top">
              <span class="stat-num">$4.58T</span>
            </div>
            <div class="stat-name">Projected NCD economic loss</div>
            <div class="stat-context">World Economic Forum — India's NCD burden projected to 2030</div>
          </div>
          <div class="stat-cell">
            <div class="stat-top">
              <span class="stat-num">26.4%</span>
            </div>
            <div class="stat-name">Urban diabetes prevalence</div>
            <div class="stat-context">ICMR-INDIAB 2023 — metabolic NCD survey across Indian cities</div>
          </div>
          <div class="stat-cell">
            <div class="stat-top">
              <span class="stat-num">11.9yr</span>
            </div>
            <div class="stat-name">Life expectancy lost in Delhi</div>
            <div class="stat-context">AQLI 2024 — years lost due to particulate matter exposure</div>
          </div>
          <div class="stat-cell">
            <div class="stat-top">
              <span class="stat-num">22</span>
            </div>
            <div class="stat-name">Official Indian languages</div>
            <div class="stat-context">Census of India — languages that health AI must support for true access</div>
          </div>
        </div>
      </div>
    </div>

    <!-- SLIDE 6: Split -->
    <div class="slide layout-split">
      <div class="slide-header">
        <h4>Objectives</h4>
        <span class="tag">Goals</span>
      </div>
      <div class="slide-content">
        <h2>Agentic triage, localized intelligence, and data sovereignty</h2>
        <div class="split-body">
          <div class="split-left">
            <ol class="insight-list">
              <li>Build an AI-driven Digital Health Assistant that assesses symptoms using strictly ICMR-grounded clinical guidelines via RAG.</li>
              <li>Integrate real-time environmental APIs (WAQI, OpenWeather) to dynamically alter health advice based on localized air quality.</li>
              <li>Deliver health intelligence in 22 Indian languages using Bhashini and IndicTrans2 translation pipelines.</li>
              <li>Architect a 100% Indian-hosted, DPDP Act (2023) compliant sovereign data ecosystem.</li>
              <li>Validate the system's accuracy through established benchmarks (MMed-RAG, CLINIC) before deployment.</li>
            </ol>
          </div>
          <div class="split-right">
            <div class="split-highlight">
              "The shift from reactive symptom-checking to proactive, environment-aware health management is the defining gap in India's digital health landscape."
              <cite>Project Research Analysis</cite>
            </div>
            <div class="mini-stat-row">
              <div class="mini-stat">
                <div class="mini-val">43.8%</div>
                <div class="mini-label">RAG accuracy improvement (MMed-RAG, ICLR 2025)</div>
              </div>
              <div class="mini-stat">
                <div class="mini-val">+6.2</div>
                <div class="mini-label">chrF gain with IndicTrans2 for medical domain</div>
              </div>
              <div class="mini-stat">
                <div class="mini-val">₹250Cr</div>
                <div class="mini-label">Max DPDP Act non-compliance penalty</div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- SLIDE 7: Detail -->
    <div class="slide layout-detail">
      <div class="slide-header">
        <h4>Project Scope</h4>
        <span class="tag">Boundaries</span>
      </div>
      <div class="slide-content">
        <h2>Defining the MVP's boundaries and deliverables</h2>
        <div class="detail-body">
          <div class="detail-col">
            <div class="detail-block">
              <h3>In-Scope (Technical Deliverables)</h3>
              <ul>
                <li>Cross-platform app (Flutter) with offline SQLite caching</li>
                <li>FastAPI async microservices backend with PostgreSQL</li>
                <li>ICMR-grounded RAG pipeline using BioMistral/Llama 3</li>
                <li>Real-time WAQI pollution API integration for contextual alerts</li>
                <li>OCR parsing for physical lab report extraction</li>
              </ul>
            </div>
            <div class="detail-block">
              <h3>Functional Scope</h3>
              <ul>
                <li>NCD-focused triage: Diabetes, CVDs, Respiratory conditions</li>
                <li>Target users: Urban Indian adults (25-60) with chronic conditions</li>
                <li>Geo-focus: High-AQI metropolitan areas (Delhi, Mumbai, Pune)</li>
              </ul>
            </div>
          </div>
          <div class="detail-col">
            <div class="detail-block">
              <h3>Out-of-Scope</h3>
              <ul>
                <li>Medical diagnoses or prescriptions (regulatory constraint)</li>
                <li>Hardware wearable integration (Apple Watch, Fitbit)</li>
                <li>Live ABDM production deployment (sandbox testing only)</li>
                <li>Acute emergency triage or real-time teleconsultation</li>
              </ul>
            </div>
            <div class="detail-block">
              <h3>Constraints & Assumptions</h3>
              <ul>
                <li>All LLM inference runs on Indian GPU cloud (E2E Networks)</li>
                <li>User explicitly consents to data processing per DPDP Act</li>
                <li>API dependencies (WAQI, Bhashini) assumed stable for MVP duration</li>
                <li>Testing limited to Android platform for initial release</li>
              </ul>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- SLIDE 8: Metrics -->
    <div class="slide layout-metrics">
      <div class="slide-header">
        <h4>Literature Review</h4>
        <span class="tag">Evidence Base</span>
      </div>
      <div class="slide-content">
        <h2>Peer-reviewed foundation across all project pillars</h2>
        <div class="metrics-row">
          <div class="metric-card">
            <div class="metric-value">42</div>
            <div class="metric-label">IEEE-formatted references</div>
            <div class="metric-desc">Comprehensive literature review spanning 7 research pillars — NCDs, pollution, digital health ROI, RAG safety, vernacular AI, agentic AI, and data sovereignty.</div>
            <ul class="metric-supports">
              <li>Sources from The Lancet, Nature, NEJM, JACC, BMJ, JAMIA, ICLR</li>
              <li>Every claim traceable to a DOI or arXiv ID</li>
              <li>No vague citations or unsourced assumptions</li>
            </ul>
          </div>
          <div class="metric-card">
            <div class="metric-value">43.8%</div>
            <div class="metric-label">RAG accuracy gain (MMed-RAG)</div>
            <div class="metric-desc">Xia et al. (ICLR 2025) demonstrated that domain-specific RAG systems improve factual accuracy by 43.8% over vanilla LLMs in medical applications.</div>
            <ul class="metric-supports">
              <li>Scope-matched KG-RAG outperforms generic RAG (Anuyah 2026)</li>
              <li>RAG-end2end shows significant QA improvement (TACL 2022)</li>
              <li>Clinical safety gaps documented in systematic reviews (JAMIA 2018)</li>
            </ul>
          </div>
          <div class="metric-card">
            <div class="metric-value">14.3:1</div>
            <div class="metric-label">Preventive health ROI</div>
            <div class="metric-desc">Masters et al. (JECH 2017) demonstrated a 14.3:1 median return on investment for public health preventive interventions.</div>
            <ul class="metric-supports">
              <li>MRC Framework (BMJ 2021) provides evaluation gold standard</li>
              <li>eSanjeevani proves 100M+ teleconsultation demand</li>
              <li>CONSORT-EHEALTH (JMIR 2011) sets digital health trial standards</li>
            </ul>
          </div>
        </div>
      </div>
    </div>

    <!-- SLIDE 9: Bars -->
    <div class="slide layout-bars">
      <div class="slide-header">
        <h4>Competitive Analysis</h4>
        <span class="tag">Gap Analysis</span>
      </div>
      <div class="slide-content">
        <h2>No existing solution combines all six capabilities</h2>
        <div class="bars-container">
          <div class="bar-item">
            <div class="bar-label">Preventive NCD Management</div>
            <div class="bar-track"><div class="bar-fill" style="width: 15%;"></div></div>
            <div class="bar-pct">Aarogya Sathi ✓</div>
          </div>
          <div class="bar-item">
            <div class="bar-label">Real-time AQI Integration</div>
            <div class="bar-track"><div class="bar-fill" style="width: 5%;"></div></div>
            <div class="bar-pct">Aarogya Sathi ✓</div>
          </div>
          <div class="bar-item">
            <div class="bar-label">Vernacular-first (22 languages)</div>
            <div class="bar-track"><div class="bar-fill" style="width: 10%;"></div></div>
            <div class="bar-pct">Aarogya Sathi ✓</div>
          </div>
          <div class="bar-item">
            <div class="bar-label">ICMR-Grounded RAG</div>
            <div class="bar-track"><div class="bar-fill" style="width: 5%;"></div></div>
            <div class="bar-pct">Aarogya Sathi ✓</div>
          </div>
          <div class="bar-item">
            <div class="bar-label">Agentic AI Architecture</div>
            <div class="bar-track"><div class="bar-fill" style="width: 5%;"></div></div>
            <div class="bar-pct">Aarogya Sathi ✓</div>
          </div>
          <div class="bar-item">
            <div class="bar-label">DPDP Act Compliance</div>
            <div class="bar-track"><div class="bar-fill" style="width: 40%;"></div></div>
            <div class="bar-pct">Aarogya Sathi ✓</div>
          </div>
        </div>
      </div>
    </div>

    <!-- SLIDE 10: Timeline -->
    <div class="slide layout-timeline">
      <div class="slide-header">
        <h4>System Architecture</h4>
        <span class="tag">Methodology</span>
      </div>
      <div class="slide-content">
        <h2>Agentic RAG pipeline with sovereign data processing</h2>
        <div class="timeline-track">
          <div class="timeline-step">
            <div class="step-circle">1</div>
            <div class="step-title">Intercept</div>
            <div class="step-desc">Flutter app captures user input (voice/text in vernacular) + fetches live GPS and WAQI environmental data.</div>
          </div>
          <div class="timeline-step">
            <div class="step-circle">2</div>
            <div class="step-title">Retrieve</div>
            <div class="step-desc">LangChain queries Pinecone vector DB containing ICMR guideline embeddings for medically grounded context.</div>
          </div>
          <div class="timeline-step">
            <div class="step-circle">3</div>
            <div class="step-title">Reason</div>
            <div class="step-desc">BioMistral/Llama 3 correlates symptoms with retrieved ICMR context and environmental alerts.</div>
          </div>
          <div class="timeline-step">
            <div class="step-circle">4</div>
            <div class="step-title">Filter</div>
            <div class="step-desc">Heuristic safety block scans output to remove diagnostic language before delivering advice to user.</div>
          </div>
        </div>
      </div>
    </div>

    <!-- SLIDE 11: Detail -->
    <div class="slide layout-detail">
      <div class="slide-header">
        <h4>Tools & Technologies</h4>
        <span class="tag">Stack</span>
      </div>
      <div class="slide-content">
        <h2>Full-stack ecosystem for the MVP</h2>
        <div class="detail-body">
          <div class="detail-col">
            <div class="detail-block">
              <h3>Client & Backend</h3>
              <ul>
                <li>Flutter + SQLite: Offline-first UI with local caching</li>
                <li>FastAPI + PostgreSQL: High-performance async backend</li>
                <li>Docker: Containerized microservices deployment</li>
              </ul>
            </div>
            <div class="detail-block">
              <h3>AI & ML Stack</h3>
              <ul>
                <li>BioMistral / Llama 3: Open-source, medically capable LLMs</li>
                <li>LangChain + Pinecone: RAG orchestration and vector storage</li>
                <li>Bhashini + IndicTrans2: Vernacular NLP translation pipeline</li>
              </ul>
            </div>
          </div>
          <div class="detail-col">
            <div class="detail-block">
              <h3>Sovereign Cloud & Data</h3>
              <ul>
                <li>E2E Networks: Indian-hosted GPU cloud (DPDP compliant)</li>
                <li>GitHub Actions: CI/CD pipelines</li>
                <li>PostgreSQL on E2E: Health data never leaves Indian borders</li>
              </ul>
            </div>
            <div class="detail-block">
              <h3>External APIs</h3>
              <ul>
                <li>WAQI API: Real-time global air quality index data</li>
                <li>OpenWeatherMap: Weather context for health alerts</li>
                <li>Bhashini API: Govt of India NLP translation service</li>
              </ul>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- SLIDE 12: Split -->
    <div class="slide layout-split">
      <div class="slide-header">
        <h4>Feasibility</h4>
        <span class="tag">Viability</span>
      </div>
      <div class="slide-content">
        <h2>Scaling sovereign AI within practical constraints</h2>
        <div class="split-body">
          <div class="split-left">
            <ol class="insight-list">
              <li>Compute Cost: 4-bit model quantization on E2E Networks reduces GPU inference costs by ~70% vs AWS/GCP, ensuring financial viability.</li>
              <li>Translation APIs: Bhashini and WAQI APIs are public, mature, and well-documented — no need to train from scratch.</li>
              <li>Legal Compliance: Zero-knowledge local inference ensures 100% data residency. Architecture inherently meets DPDP Act consent requirements.</li>
              <li>Platform: Flutter provides a single-codebase solution for iOS/Android, drastically reducing UI development overhead.</li>
              <li>Testing: Established benchmarks (MMed-RAG, CLINIC) provide validated evaluation frameworks for clinical AI safety.</li>
            </ol>
          </div>
          <div class="split-right">
            <div class="split-highlight">
              "By using domestic cloud providers and open-source LLMs, we bypass the cost and sovereignty issues of relying on OpenAI/Google APIs entirely."
              <cite>Technical Feasibility Analysis</cite>
            </div>
            <div class="mini-stat-row">
              <div class="mini-stat">
                <div class="mini-val">70%</div>
                <div class="mini-label">GPU cost reduction via E2E vs AWS</div>
              </div>
              <div class="mini-stat">
                <div class="mini-val">1</div>
                <div class="mini-label">Codebase for iOS + Android (Flutter)</div>
              </div>
              <div class="mini-stat">
                <div class="mini-val">100%</div>
                <div class="mini-label">Data residency within India</div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- SLIDE 13: Dashboard -->
    <div class="slide layout-dashboard">
      <div class="slide-header">
        <h4>Expected Outcomes</h4>
        <span class="tag">Impact</span>
      </div>
      <div class="slide-content">
        <h2>Measurable deliverables and anticipated impact</h2>
        <div class="stats-grid">
          <div class="stat-cell">
            <div class="stat-top">
              <span class="stat-num">MVP</span>
            </div>
            <div class="stat-name">Functional Android App</div>
            <div class="stat-context">Vernacular voice onboarding with offline caching capability</div>
          </div>
          <div class="stat-cell">
            <div class="stat-top">
              <span class="stat-num">AQI&gt;300</span>
            </div>
            <div class="stat-name">Context-Aware Triage</div>
            <div class="stat-context">Backend correlating symptoms with live pollution alerts dynamically</div>
          </div>
          <div class="stat-cell">
            <div class="stat-top">
              <span class="stat-num">100%</span>
            </div>
            <div class="stat-name">Sovereign Architecture PoC</div>
            <div class="stat-context">Local inference validated without external API dependency</div>
          </div>
          <div class="stat-cell">
            <div class="stat-top">
              <span class="stat-num">Report</span>
            </div>
            <div class="stat-name">Research Output</div>
            <div class="stat-context">Architecture documentation + RAG accuracy benchmarking paper</div>
          </div>
          <div class="stat-cell">
            <div class="stat-top">
              <span class="stat-num">↓</span>
            </div>
            <div class="stat-name">Reduced False Alarms</div>
            <div class="stat-context">Attributing symptoms to pollution instead of infection, lowering unnecessary visits</div>
          </div>
          <div class="stat-cell">
            <div class="stat-top">
              <span class="stat-num">22+</span>
            </div>
            <div class="stat-name">Language Coverage</div>
            <div class="stat-context">Bridging health literacy gap for non-English speakers</div>
          </div>
        </div>
      </div>
    </div>

    <!-- SLIDE 14: Gantt Chart -->
    <div class="slide layout-gantt">
      <div class="slide-header">
        <h4>Timeline</h4>
        <span class="tag">12 Weeks</span>
      </div>
      <div class="slide-content">
        <h2>Execution Gantt Chart (3-Month Sprint)</h2>
        <div class="gantt-container">
          <div class="gantt-header">
            <div class="gantt-col-title left">Task</div>
            <div class="gantt-col-title">W1</div>
            <div class="gantt-col-title">W2</div>
            <div class="gantt-col-title">W3</div>
            <div class="gantt-col-title">W4</div>
            <div class="gantt-col-title">W5</div>
            <div class="gantt-col-title">W6</div>
            <div class="gantt-col-title">W7</div>
            <div class="gantt-col-title">W8</div>
            <div class="gantt-col-title">W9</div>
            <div class="gantt-col-title">W10</div>
            <div class="gantt-col-title">W11</div>
            <div class="gantt-col-title">W12</div>
          </div>
          
          <div class="gantt-row">
            <div class="gantt-task-name">1. DB & API Architecture</div>
            <div class="gantt-bar" style="grid-column: 2 / 6;"></div>
          </div>
          <div class="gantt-row">
            <div class="gantt-task-name">2. Flutter UI & Offline</div>
            <div class="gantt-bar" style="grid-column: 3 / 9;"></div>
          </div>
          <div class="gantt-row">
            <div class="gantt-task-name">3. Backend APIs (FastAPI, WAQI)</div>
            <div class="gantt-bar" style="grid-column: 5 / 10;"></div>
          </div>
          <div class="gantt-row">
            <div class="gantt-task-name">4. LLM & RAG Pipeline</div>
            <div class="gantt-bar" style="grid-column: 7 / 12;"></div>
          </div>
          <div class="gantt-row">
            <div class="gantt-task-name">5. Vernacular (Bhashini)</div>
            <div class="gantt-bar" style="grid-column: 8 / 12;"></div>
          </div>
          <div class="gantt-row">
            <div class="gantt-task-name">6. Testing & Validation</div>
            <div class="gantt-bar" style="grid-column: 10 / 14;"></div>
          </div>
          <div class="gantt-row">
            <div class="gantt-task-name">7. Documentation & Report</div>
            <div class="gantt-bar" style="grid-column: 11 / 14;"></div>
          </div>
        </div>
      </div>
    </div>

    <!-- SLIDE 15: Closing -->
    <div class="slide layout-closing">
      <div class="closing-decoration"></div>
      <div class="closing-decoration-2"></div>
      <h1>Thank You</h1>
      <p class="closing-sub">For further discussion, please reach out to the team.</p>
      <p class="closing-contact">Jayesh Patil (C233) &middot; Abhijit Patil (C263) &middot; Ritesh Pawar (C276) &nbsp;&middot;&nbsp; Capstone 1st Review &middot; July 2026</p>
    </div>

  </div>

{nav_content}
{js_content}

</body>
</html>
'''

with open('C:/Users/ADMIN/Desktop/Aarogya Sathi Capstone/Aarogya_Sathi_Presentation.html', 'w', encoding='utf-8') as f:
    f.write(html_output)

print('Done writing HTML.')
