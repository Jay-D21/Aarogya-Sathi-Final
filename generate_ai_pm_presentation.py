import os
import sys
import zipfile
import tempfile
import shutil
import xml.etree.ElementTree as ET
import win32com.client
from pptx import Presentation
from pptx.util import Inches, Pt
from pptx.dml.color import RGBColor
from pptx.enum.text import PP_ALIGN
from pptx.enum.shapes import MSO_SHAPE

# -----------------------------------------------------------------------------
# Color Palette Constants (Modern Executive Slate & Health AI Palette)
# -----------------------------------------------------------------------------
BG_COLOR = RGBColor(15, 23, 42)        # Slate 900 (#0F172A)
CARD_BG = RGBColor(30, 41, 59)        # Slate 800 (#1E293B)
CARD_BORDER = RGBColor(51, 65, 85)    # Slate 700 (#334155)
CARD_BG_LIGHT = RGBColor(24, 34, 53)  # Slate 850

TEXT_WHITE = RGBColor(255, 255, 255)   # Pure White
TEXT_MUTED = RGBColor(203, 213, 225)   # Slate 300
TEXT_DIM = RGBColor(148, 163, 184)     # Slate 400

CYAN_ACCENT = RGBColor(56, 189, 248)   # Sky 400 (#38BDF8) - Healthcare Tech
EMERALD_ACCENT = RGBColor(52, 211, 153) # Emerald 400 (#34D399) - Validation/Safety
AMBER_ACCENT = RGBColor(251, 191, 36)  # Amber 400 (#FBBF24) - Highlights
PURPLE_ACCENT = RGBColor(192, 132, 252) # Purple 400 (#C084FC) - Agentic AI

# Universal Cross-Platform Fonts (Natively supported on Windows, Mac, Android, iOS, Linux, Google Slides)
FONT_HEADING = "Calibri"
FONT_BODY = "Calibri"

def set_slide_background(slide):
    """Sets deep slate background fill."""
    background = slide.background
    fill = background.fill
    fill.solid()
    fill.fore_color.rgb = BG_COLOR

def add_header(slide, module_badge_text, title_text, subtitle_text):
    """Adds standard executive top banner to slides."""
    # Badge container
    badge = slide.shapes.add_shape(MSO_SHAPE.ROUNDED_RECTANGLE, Inches(0.8), Inches(0.4), Inches(2.8), Inches(0.36))
    badge.fill.solid()
    badge.fill.fore_color.rgb = CARD_BG
    badge.line.color.rgb = CYAN_ACCENT
    badge.line.width = Pt(1)
    
    tf = badge.text_frame
    tf.word_wrap = True
    tf.margin_top = Inches(0.02)
    tf.margin_bottom = Inches(0.02)
    p = tf.paragraphs[0]
    p.text = module_badge_text.upper()
    p.font.name = FONT_HEADING
    p.font.size = Pt(10.5)
    p.font.bold = True
    p.font.color.rgb = CYAN_ACCENT
    p.alignment = PP_ALIGN.CENTER
    
    # Title & Subtitle Box
    tx_box = slide.shapes.add_textbox(Inches(0.8), Inches(0.8), Inches(11.7), Inches(0.95))
    tf_title = tx_box.text_frame
    tf_title.word_wrap = True
    tf_title.margin_top = 0
    tf_title.margin_bottom = 0
    tf_title.margin_left = 0
    
    p_title = tf_title.paragraphs[0]
    p_title.text = title_text
    p_title.font.name = FONT_HEADING
    p_title.font.size = Pt(22)
    p_title.font.bold = True
    p_title.font.color.rgb = TEXT_WHITE
    
    p_sub = tf_title.add_paragraph()
    p_sub.text = subtitle_text
    p_sub.font.name = FONT_BODY
    p_sub.font.size = Pt(12)
    p_sub.font.color.rgb = TEXT_MUTED

def add_card(slide, left, top, width, height, title, accent_color=CYAN_ACCENT):
    """Adds a container card with a colored accent top border and header."""
    card = slide.shapes.add_shape(MSO_SHAPE.ROUNDED_RECTANGLE, left, top, width, height)
    card.fill.solid()
    card.fill.fore_color.rgb = CARD_BG
    card.line.color.rgb = CARD_BORDER
    card.line.width = Pt(1)
    
    # Accent top strip
    strip = slide.shapes.add_shape(MSO_SHAPE.ROUNDED_RECTANGLE, left, top, width, Inches(0.08))
    strip.fill.solid()
    strip.fill.fore_color.rgb = accent_color
    strip.line.fill.background()
    
    # Card Title Box
    title_box = slide.shapes.add_textbox(left + Inches(0.25), top + Inches(0.15), width - Inches(0.5), Inches(0.45))
    tf = title_box.text_frame
    tf.word_wrap = True
    tf.margin_left = 0
    tf.margin_top = 0
    p = tf.paragraphs[0]
    p.text = title
    p.font.name = FONT_HEADING
    p.font.size = Pt(14)
    p.font.bold = True
    p.font.color.rgb = accent_color
    
    # Content Box
    content_box = slide.shapes.add_textbox(left + Inches(0.25), top + Inches(0.6), width - Inches(0.5), height - Inches(0.7))
    tf_c = content_box.text_frame
    tf_c.word_wrap = True
    tf_c.margin_left = 0
    tf_c.margin_top = 0
    return tf_c

def add_bullet_point(text_frame, bold_prefix, text_body, pt_size=11, space_after=8):
    """Adds clean bullet point with bold lead-in."""
    p = text_frame.add_paragraph() if len(text_frame.paragraphs[0].text) > 0 else text_frame.paragraphs[0]
    p.space_after = Pt(space_after)
    
    r1 = p.add_run()
    r1.text = bold_prefix + ": "
    r1.font.name = FONT_BODY
    r1.font.bold = True
    r1.font.size = Pt(pt_size)
    r1.font.color.rgb = TEXT_WHITE
    
    r2 = p.add_run()
    r2.text = text_body
    r2.font.name = FONT_BODY
    r2.font.size = Pt(pt_size)
    r2.font.color.rgb = TEXT_MUTED

# -----------------------------------------------------------------------------
# Main Presentation Builder
# -----------------------------------------------------------------------------
def build_raw_presentation(raw_path):
    prs = Presentation()
    prs.slide_width = Inches(13.333)
    prs.slide_height = Inches(7.5)
    blank_layout = prs.slide_layouts[6] # blank layout
    
    logo_path = "docs/brand/playstore_icon_512.png"
    if not os.path.exists(logo_path):
        logo_path = "frontend/assets/images/app_logo.png"

    # =========================================================================
    # SLIDE 1: Title Slide
    # =========================================================================
    s1 = prs.slides.add_slide(blank_layout)
    set_slide_background(s1)
    
    # Decorative Top Accent Bar
    top_bar = s1.shapes.add_shape(MSO_SHAPE.RECTANGLE, Inches(0), Inches(0), Inches(13.333), Inches(0.12))
    top_bar.fill.solid()
    top_bar.fill.fore_color.rgb = CYAN_ACCENT
    top_bar.line.fill.background()

    # Logo
    if os.path.exists(logo_path):
        s1.shapes.add_picture(logo_path, Inches(0.9), Inches(1.8), Inches(1.8), Inches(1.8))
        text_left = Inches(3.1)
    else:
        text_left = Inches(0.9)

    # Title text
    t_box = s1.shapes.add_textbox(text_left, Inches(1.7), Inches(9.5), Inches(4.5))
    tf = t_box.text_frame
    tf.word_wrap = True
    
    p0 = tf.paragraphs[0]
    p0.text = "MANAGING PROJECTS WITH AI"
    p0.font.name = FONT_HEADING
    p0.font.size = Pt(13)
    p0.font.bold = True
    p0.font.color.rgb = CYAN_ACCENT
    p0.space_after = Pt(10)
    
    p1 = tf.add_paragraph()
    p1.text = "Aarogya Sathi: Applied Case Study in AI Project Management"
    p1.font.name = FONT_HEADING
    p1.font.size = Pt(30)
    p1.font.bold = True
    p1.font.color.rgb = TEXT_WHITE
    p1.space_after = Pt(12)
    
    p2 = tf.add_paragraph()
    p2.text = "Aligning the AI CERTs 8-Module PM Framework with Edge-Cloud Healthcare Engineering"
    p2.font.name = FONT_BODY
    p2.font.size = Pt(16)
    p2.font.color.rgb = TEXT_MUTED
    p2.space_after = Pt(24)

    p3 = tf.add_paragraph()
    p3.text = "How AI Managed Context, Task Schedulers, Clinical Safety, Multi-Agent Swarms & Continuous Delivery"
    p3.font.name = FONT_BODY
    p3.font.size = Pt(13)
    p3.font.color.rgb = EMERALD_ACCENT

    # Footer Metadata Card
    foot_card = s1.shapes.add_shape(MSO_SHAPE.ROUNDED_RECTANGLE, Inches(0.9), Inches(5.8), Inches(11.533), Inches(0.9))
    foot_card.fill.solid()
    foot_card.fill.fore_color.rgb = CARD_BG
    foot_card.line.color.rgb = CARD_BORDER
    tf_f = foot_card.text_frame
    tf_f.word_wrap = True
    p_f = tf_f.paragraphs[0]
    p_f.text = "PROJECT: Aarogya Sathi (Edge-Cloud Multilingual AI Health Assistant)  |  PM FRAMEWORK: AI CERTs (Coursera)  |  DATE: October 2026"
    p_f.font.name = FONT_BODY
    p_f.font.size = Pt(11)
    p_f.font.color.rgb = TEXT_DIM
    p_f.alignment = PP_ALIGN.CENTER

    # =========================================================================
    # SLIDE 2: Executive Overview & The AI-Driven PM Matrix
    # =========================================================================
    s2 = prs.slides.add_slide(blank_layout)
    set_slide_background(s2)
    add_header(s2, "Executive Framework", "The Aarogya Sathi AI-Driven Project Lifecycle", "Mapping the 8 Modules of AI Project Management to Real-World Clinical Engineering")

    col_w = Inches(3.64)
    h_top = Inches(1.9)
    card_h = Inches(4.9)

    c1 = add_card(s2, Inches(0.8), h_top, col_w, card_h, "1. Project Scope & Architecture", CYAN_ACCENT)
    add_bullet_point(c1, "Edge-Cloud Hybrid", "Flutter client + FastAPI backend with DPDP-compliant on-device data vault.")
    add_bullet_point(c1, "Knowledge Retrieval", "34 ICMR National Clinical Practice Guideline bundles indexed in Open Knowledge Format (OKF).")
    add_bullet_point(c1, "Real-Time Telemetry", "Live WAQI environmental air quality feeds combined with user wearable metrics.")
    add_bullet_point(c1, "Multilingual Reach", "Zero-shot English, Hindi, and Marathi generation via Indian vernacular LLM cascades.")

    c2 = add_card(s2, Inches(4.84), h_top, col_w, card_h, "2. The AI-Driven PM Paradigm", EMERALD_ACCENT)
    add_bullet_point(c2, "From Admin to Architect", "Transitioning traditional PM manual tracking into AI prompt engineering and automated gates.")
    add_bullet_point(c2, "Dynamic Memory System", "iLabs hierarchical context system (.context/) providing permanent team working memory.")
    add_bullet_point(c2, "Context Auto-Sync Loop", "Automatic commit analysis, changelog updates, and git re-sync on every session push.")
    add_bullet_point(c2, "Automated Governance", "Enforcing strict coding standards, response schemas, and dependency approval via bots.")

    c3 = add_card(s2, Inches(8.88), h_top, col_w, card_h, "3. Quantifiable PM Results", AMBER_ACCENT)
    add_bullet_point(c3, "32-Case Benchmark", "Achieved 4.60/5.00 composite clinical score on ICMR gold-standard evaluation.")
    add_bullet_point(c3, "100% Interception", "42/42 adversarial safety queries intercepted in 13.4ms average latency.")
    add_bullet_point(c3, "0% False Positives", "32/32 legitimate medical queries passed cleanly to the RAG pipeline.")
    add_bullet_point(c3, "100% Mobile Test Pass", "All 23 automated Flutter integration and widget tests verified green.")

    # =========================================================================
    # SLIDE 3: Module 1 — Introduction to AI in Project Management (Applied)
    # =========================================================================
    s3 = prs.slides.add_slide(blank_layout)
    set_slide_background(s3)
    add_header(s3, "Module 1", "Foundations of AI in Project Management: Applied to Aarogya Sathi", "Harnessing Machine Learning, NLP, and Algorithmic Optimization for Healthcare Delivery")

    col_w2 = Inches(5.66)
    c1 = add_card(s3, Inches(0.8), h_top, col_w2, card_h, "Core AI Technologies Applied in Our PM Lifecycle", CYAN_ACCENT)
    add_bullet_point(c1, "Machine Learning (ML)", "Deployed sentence-transformers/all-MiniLM-L6-v2 embeddings to semantically cluster task backlogs and safety intent spaces.")
    add_bullet_point(c1, "Natural Language Processing (NLP)", "Automated extraction of clinical decision trees from dense ICMR guideline PDFs into machine-readable JSON schemas.")
    add_bullet_point(c1, "Robotic Automation (RPA)", "Automated verification hooks that re-run unit tests, inspect git branches, and rebuild documentation on code changes.")
    add_bullet_point(c1, "Heuristic Schedulers", "Algorithmic multi-key fallback cascading (Groq -> SambaNova -> Cerebras) ensuring 99.9% RAG pipeline uptime.")

    c2 = add_card(s3, Inches(6.86), h_top, col_w2, card_h, "Optimization & Efficiency Improvements", EMERALD_ACCENT)
    add_bullet_point(c2, "Predictive Task Sizing", "AI analysis of code diffs to forecast token budgets, build times, and memory footprints before branch merging.")
    add_bullet_point(c2, "Elimination of Project Drift", "Zero-shot semantic alignment between PR descriptions and clinical requirements, eliminating ambiguous rework.")
    add_bullet_point(c2, "Decision-Making Speed", "Replaced lengthy consensus meetings with deterministic automated benchmarks (latency, precision, recall).")
    add_bullet_point(c2, "Addressing AI PM Limitations", "Established human-in-the-loop review for architecture alterations, counteracting model hallucinations.")

    # =========================================================================
    # SLIDE 4: Module 2 — AI Tools for Project Management & Workflow Automation
    # =========================================================================
    s4 = prs.slides.add_slide(blank_layout)
    set_slide_background(s4)
    add_header(s4, "Module 2", "AI Tools, Toolchains & Workflow Automation", "Automating Task Schedulers, Documentation Engines, and Continuous Deployment")

    c1 = add_card(s4, Inches(0.8), h_top, col_w, card_h, "AI Tool Selection Strategy", CYAN_ACCENT)
    add_bullet_point(c1, "Curated AI Tool Stack", "Evaluated and deployed specialized CLI agents, language models, and automated build bots.")
    add_bullet_point(c1, "Git-Integrated Schedulers", "Leveraged automated git hooks and CLI triggers to schedule benchmark runs and lint checks.")
    add_bullet_point(c1, "Resource Allocation", "Automated model routing based on complexity (lightweight 8B models for intent, 27B for clinical RAG).")
    add_bullet_point(c1, "User Training Protocol", "Standardized prompt conventions and commit formats across all team contributors.")

    c2 = add_card(s4, Inches(4.84), h_top, col_w, card_h, "Automated Documentation (RPA)", EMERALD_ACCENT)
    add_bullet_point(c2, "Programmatic IEEE Paper", "Built automated Word COM and PyMuPDF pipeline compiling exactly 10-page IEEE camera-ready PDFs.")
    add_bullet_point(c2, "API Spec Generation", "FastAPI endpoints automatically synchronized with OpenAPI and markdown documentation.")
    add_bullet_point(c2, "Release Note Generation", "AI agent analyzed git logs to compile user-facing Play Store changelogs and privacy policies.")
    add_bullet_point(c2, "Permanent Context Logs", "Automatic update of .context/progress/changelog.md on every dev session.")

    c3 = add_card(s4, Inches(8.88), h_top, col_w, card_h, "Predictive Project Analytics", AMBER_ACCENT)
    add_bullet_point(c3, "Latency Budgeting", "Set strict <50ms budget for query safety; achieved 13.4ms through local CPU vector indexing.")
    add_bullet_point(c3, "Cost Modeling", "Simulated token burn across 10,000 queries, reducing cloud inference costs by 85% via caching.")
    add_bullet_point(c3, "Risk Forecasting", "Predictive detection of breaking changes in shared files (.context/dependencies/critical-files.md).")
    add_bullet_point(c3, "Test Flakiness Prevention", "Deterministic mock isolation ensuring 100% reproducible mobile test runs.")

    # =========================================================================
    # SLIDE 5: Module 3 — Data-Driven Decision Making & Risk Control
    # =========================================================================
    s5 = prs.slides.add_slide(blank_layout)
    set_slide_background(s5)
    add_header(s5, "Module 3", "Data-Driven Decision Making & Quantitative Risk Control", "Transforming Telemetry, Clinical Guidelines, and Benchmark Logs into Project Decisions")

    c1 = add_card(s5, Inches(0.8), h_top, col_w2, card_h, "Multi-Modal Data Sourcing & Management", CYAN_ACCENT)
    add_bullet_point(c1, "Clinical Ground Truth", "Aggregated 34 verified guidelines from the Indian Council of Medical Research (ICMR) into OKF bundles.")
    add_bullet_point(c1, "Live Sensor Feeds", "Integrated Central Pollution Control Board (CPCB) NAQI telemetry and real-time WAQI API feeds.")
    add_bullet_point(c1, "Wearable Health Inputs", "Standardized resting heart rate, blood pressure, and step cadence into normalized patient profiles.")
    add_bullet_point(c1, "Data Quality Assurance", "Automated validation scripts ensuring zero null values or unit mismatch in ingested health metrics.")

    c2 = add_card(s5, Inches(6.86), h_top, col_w2, card_h, "Empirical Risk Mitigation Matrix", AMBER_ACCENT)
    add_bullet_point(c2, "Hallucination Risk Gate", "Mandatory grounding ratio threshold (>=0.85); responses failing source overlap are rejected.")
    add_bullet_point(c2, "Clinical Boundary Enforcer", "Deterministic keyword + semantic router blocking illegal drug prescribing and dosage recommendations.")
    add_bullet_point(c2, "Quantitative Benchmarking", "Decisions on architecture transitions backed by 32-case gold-standard test runs, not subjective opinion.")
    add_bullet_point(c2, "Automated Go/No-Go Gates", "CI pipeline rejects merges if mobile unit tests drop below 100% or safety block rate drops below 100%.")

    # =========================================================================
    # SLIDE 6: Module 4 — AI for Enhancing Team Collaboration & Productivity
    # =========================================================================
    s6 = prs.slides.add_slide(blank_layout)
    set_slide_background(s6)
    add_header(s6, "Module 4", "AI for Team Collaboration, Memory & Knowledge Management", "The iLabs Context System: Multi-Tiered Working Memory Eliminating Developer Drift")

    c1 = add_card(s6, Inches(0.8), h_top, col_w, card_h, "The iLabs 4-Tier Context Engine", CYAN_ACCENT)
    add_bullet_point(c1, "Level 0 (Master Index)", "INDEX.md provides high-level directory navigation in <15 lines for zero token waste.")
    add_bullet_point(c1, "Level 1 (Overviews)", "_overview.md provides 1-sentence summaries of all 15 project modules.")
    add_bullet_point(c1, "Level 2 (Summaries)", "summary.md contains technical paragraph specs and critical file lists.")
    add_bullet_point(c1, "Level 3 (Full Detail)", "detail.md maintains complete API schemas, database contracts, and edge cases.")

    c2 = add_card(s6, Inches(4.84), h_top, col_w, card_h, "Developer State Tracking", EMERALD_ACCENT)
    add_bullet_point(c2, "Dedicated Contributor Logs", "Persistent files (dev-abhijit.md, dev-jayesh.md) track active workstreams across sessions.")
    add_bullet_point(c2, "Zero Onboarding Overhead", "Any developer or AI subagent reads context levels 0-2 and immediately becomes productive.")
    add_bullet_point(c2, "Explicit Ownership Maps", "Lists files owned by each developer, preventing accidental file overwrites in multi-agent workflows.")
    add_bullet_point(c2, "Session Summaries", "Every working session terminates with structured summary updates before git commit.")

    c3 = add_card(s6, Inches(8.88), h_top, col_w, card_h, "Autonomous Sync Loop", PURPLE_ACCENT)
    add_bullet_point(c3, "Analyze Git Diffs", "AI parses commit changes to identify modified modules, architectural changes, and new tests.")
    add_bullet_point(c3, "Update Context Files", "Main context files and changelog are dynamically updated to reflect true system state.")
    add_bullet_point(c3, "Auto-Rebase & Push", "Synchronizes updated context back to remote git repository, establishing permanent team memory.")
    add_bullet_point(c3, "Conflict Elimination", "Maintains shared ground truth, eliminating merge discrepancies between parallel contributors.")

    # =========================================================================
    # SLIDE 7: Module 5 — Ethical Considerations, Bias Mitigation & Governance
    # =========================================================================
    s7 = prs.slides.add_slide(blank_layout)
    set_slide_background(s7)
    add_header(s7, "Module 5", "Ethical AI Governance, Privacy & Algorithmic Bias", "Embedding India's DPDP Act 2023 and ICMR Clinical Safety into the PM Lifecycle")

    c1 = add_card(s7, Inches(0.8), h_top, col_w, card_h, "Privacy by Design (DPDP Act)", CYAN_ACCENT)
    add_bullet_point(c1, "On-Device Data Sovereignty", "All sensitive medical files and prescription images remain locked in sandboxed /medical_vault/ storage.")
    add_bullet_point(c1, "No Cloud Health Leakage", "Raw lab scans and OCR files are processed on device; zero unencrypted cloud transmission.")
    add_bullet_point(c1, "Consent-Driven Sharing", "Explicit opt-in controls for air quality location querying and health metric tracking.")
    add_bullet_point(c1, "Statutory Alignment", "Meets Digital Personal Data Protection (DPDP) Act 2023 mandates for healthcare AI.")

    c2 = add_card(s7, Inches(4.84), h_top, col_w, card_h, "Demographic Bias Mitigation", EMERALD_ACCENT)
    add_bullet_point(c2, "South Asian BMI Thresholds", "Configured Asian-specific cutoffs (Normal: 18.5-22.9, Obese: >=25.0) to prevent underdiagnosing visceral fat risk.")
    add_bullet_point(c2, "Linguistic Fairness", "Evaluated semantic understanding across native Hindi, Marathi, and Hinglish transliterations.")
    add_bullet_point(c2, "Cultural Nutrition Parity", "Tailored dietary advice to regional Indian staples (millets, dal, parboiled rice) instead of Western diets.")
    add_bullet_point(c2, "Socioeconomic Adaptability", "Prioritized low-cost, publicly accessible health measures (ORS, walking, NPCDCS clinics).")

    c3 = add_card(s7, Inches(8.88), h_top, col_w, card_h, "Clinical Accountability", AMBER_ACCENT)
    add_bullet_point(c3, "Strict Non-Prescribing", "Hard-coded boundaries prevent AI from suggesting specific drug dosages or pharmaceuticals.")
    add_bullet_point(c3, "Immediate Triage Handoff", "Emergency intent automatically surfaces 112 emergency and 102 ambulance hotlines in <15ms.")
    add_bullet_point(c3, "Source Transparency", "Every RAG assertion includes explicit clinical provenance citing ICMR guideline chapters.")
    add_bullet_point(c3, "Mandatory Disclaimers", "Clear communication that the system is an AI assistant and not a licensed medical practitioner.")

    # =========================================================================
    # SLIDE 8: Module 6 — Implementing AI in Projects: The 5-Step Model
    # =========================================================================
    s8 = prs.slides.add_slide(blank_layout)
    set_slide_background(s8)
    add_header(s8, "Module 6", "Implementing AI in Projects: The 5-Step Integration Model", "A Systematic Roadmap for Selecting, Validating, and Deploying AI Components")

    col_5 = Inches(2.26)
    left_start = Inches(0.8)
    gap = Inches(0.12)
    step_h = Inches(4.9)

    s_c1 = add_card(s8, left_start, h_top, col_5, step_h, "Step 1: Task Framing", CYAN_ACCENT)
    add_bullet_point(s_c1, "Decomposition", "Divided system into deterministic tasks (vitals parsing, offline vault) and generative tasks (clinical synthesis).")
    add_bullet_point(s_c1, "Feasibility Gate", "Discarded heavy edge LLM deployment in favor of ultra-fast cloud LPU cascade + local embeddings.")

    s_c2 = add_card(s8, left_start + (col_5 + gap) * 1, h_top, col_5, step_h, "Step 2: Tool Selection", EMERALD_ACCENT)
    add_bullet_point(s_c2, "Local Vector Model", "Selected sentence-transformers/all-MiniLM-L6-v2 (~80MB) for zero-cost, local CPU safety routing.")
    add_bullet_point(s_c2, "LPU Acceleration", "Selected Groq & Cerebras for sub-second streaming inference.")

    s_c3 = add_card(s8, left_start + (col_5 + gap) * 2, h_top, col_5, step_h, "Step 3: Data Prep", AMBER_ACCENT)
    add_bullet_point(s_c3, "OKF Structuring", "Converted dense government PDFs into structured Open Knowledge Format chunks.")
    add_bullet_point(s_c3, "Ground Truth", "Curated 32 Gold Standard clinical cases with 4-dimensional scoring criteria.")

    s_c4 = add_card(s8, left_start + (col_5 + gap) * 3, h_top, col_5, step_h, "Step 4: Pilot Testing", PURPLE_ACCENT)
    add_bullet_point(s_c4, "Isolated Sandbox", "Benchmarked safety router locally against 74 test queries before backend integration.")
    add_bullet_point(s_c4, "Automated Evaluation", "LLM-as-a-Judge scored responses across faithfulness, relevancy, completeness, and safety.")

    s_c5 = add_card(s8, left_start + (col_5 + gap) * 4, h_top, col_5, step_h, "Step 5: Monitoring", CYAN_ACCENT)
    add_bullet_point(s_c5, "Alert Cooldowns", "Implemented 60-min categorical cooldowns in HealthAlertService to prevent user fatigue.")
    add_bullet_point(s_c5, "Automated CI Tests", "Maintained 23/23 passing Flutter mobile tests across all commits.")

    # =========================================================================
    # SLIDE 9: Module 7 — Future of AI in Project Management & Green Engineering
    # =========================================================================
    s9 = prs.slides.add_slide(blank_layout)
    set_slide_background(s9)
    add_header(s9, "Module 7", "The Future of AI in PM & Sustainable 'Green' Engineering", "Evolving Competencies of Technical PMs and Minimizing Compute Carbon Footprints")

    c1 = add_card(s9, Inches(0.8), h_top, col_w2, card_h, "Evolution of the Project Manager's Skillset", CYAN_ACCENT)
    add_bullet_point(c1, "From Admin to Prompt Architect", "PMs no longer manually track timesheets; they engineer system prompts, evaluation criteria, and guardrails.")
    add_bullet_point(c1, "Algorithmic Risk Management", "Focus shifts from milestone tracking to quantitative failure mode monitoring (bias, latency, hallucination).")
    add_bullet_point(c1, "Multi-Agent Orchestration", "PMs design interaction protocols between specialized autonomous agents rather than assigning individual human tickets.")
    add_bullet_point(c1, "Continuous Governance Leadership", "Ensuring dynamic adherence to emerging global AI regulations (EU AI Act, India DPDP Act).")

    c2 = add_card(s9, Inches(6.86), h_top, col_w2, card_h, "Green AI & Sustainable Software Engineering", EMERALD_ACCENT)
    add_bullet_point(c2, "Edge-First Computation", "Processing vector similarity locally on CPU reduces cloud API calls by 68%, cutting operational carbon footprint.")
    add_bullet_point(c2, "LPU Energy Efficiency", "Groq and Cerebras hardware LPUs provide 3-5x higher energy efficiency per generated token than traditional GPUs.")
    add_bullet_point(c2, "Cached KV-States", "Session-aware memory caching avoids redundant re-computation of full conversation histories.")
    add_bullet_point(c2, "Compact Architecture", "Strict 10-page documentation and modular micro-components prevent resource bloat across CI/CD runners.")

    # =========================================================================
    # SLIDE 10: Module 8 (Part 1) — Autonomous AI Agents in Project Management
    # =========================================================================
    s10 = prs.slides.add_slide(blank_layout)
    set_slide_background(s10)
    add_header(s10, "Module 8 (Part 1)", "Autonomous AI Agents in Project Management", "Core Characteristics, Agent Typologies, and the ReAct Orchestration Framework")

    c1 = add_card(s10, Inches(0.8), h_top, col_w, card_h, "Core Characteristics of AI Agents", CYAN_ACCENT)
    add_bullet_point(c1, "Autonomy", "Ability to independently formulate plans, execute terminal commands, and inspect results without micro-direction.")
    add_bullet_point(c1, "Reactivity", "Dynamically responds to build errors, failing unit tests, or merge conflicts by modifying code.")
    add_bullet_point(c1, "Proactivity", "Anticipates dependencies, updates contributor logs, and re-indexes context files before being asked.")
    add_bullet_point(c1, "Tool-Using Capability", "Agents interface directly with compilers, git CLIs, and linters through programmatic tools.")

    c2 = add_card(s10, Inches(4.84), h_top, col_w, card_h, "Agent Typology in Our Project", EMERALD_ACCENT)
    add_bullet_point(c2, "Simple Reflex Agents", "Safety Router: instantly routes queries based on vector cosine similarity thresholds in <15ms.")
    add_bullet_point(c2, "Goal-Based Agents", "Context Guardian: ensures all session changes adhere to the iLabs context rules before commit.")
    add_bullet_point(c2, "Utility-Based Agents", "LLM Cascade Selector: dynamically routes inference requests based on latency, rate limits, and cost.")
    add_bullet_point(c2, "Learning / Evaluator Agents", "LLM-as-a-Judge: scores system answers against clinical criteria to benchmark pipeline enhancements.")

    c3 = add_card(s10, Inches(8.88), h_top, col_w, card_h, "The ReAct PM Loop", PURPLE_ACCENT)
    add_bullet_point(c3, "Reasoning (Thought)", "Agent evaluates current repo state, git status, and user requirements before taking action.")
    add_bullet_point(c3, "Action (Tool Call)", "Agent edits files, executes test suites, or invokes specialized subagents.")
    add_bullet_point(c3, "Observation (Feedback)", "Agent parses terminal outputs and compiler logs to verify success or diagnose failures.")
    add_bullet_point(c3, "Iterative Refinement", "Loop continues autonomously until all test cases pass and working tree is clean.")

    # =========================================================================
    # SLIDE 11: Module 8 (Part 2) — Multi-Agent PM System Case Study
    # =========================================================================
    s11 = prs.slides.add_slide(blank_layout)
    set_slide_background(s11)
    add_header(s11, "Module 8 (Part 2)", "Case Study: Aarogya Sathi Multi-Agent PM in Action", "Specialized Subagents Collaborating Asynchronously Across the Engineering Lifecycle")

    c1 = add_card(s11, Inches(0.8), h_top, col_w, card_h, "Specialized Agent Roles", CYAN_ACCENT)
    add_bullet_point(c1, "Research Subagent", "Explores medical literature, examines guideline documents, and audits existing codebase without modifying files.")
    add_bullet_point(c1, "Architect Subagent", "Reviews module interfaces, prevents circular dependencies, and defines API contracts.")
    add_bullet_point(c1, "Code Writer Subagent", "Implements features adhering strictly to TDD (Test-Driven Development) standards.")
    add_bullet_point(c1, "QA & Visual Validator", "Executes automated test suites, validates mobile layout constraints, and ensures 100% pass rates.")

    c2 = add_card(s11, Inches(4.84), h_top, col_w, card_h, "Parallel Agent Dispatch", EMERALD_ACCENT)
    add_bullet_point(c2, "Asynchronous Execution", "Multiple subagents spawned simultaneously in isolated workspace branches.")
    add_bullet_point(c2, "Reactive Wakeup", "Parent agent waits reactively without polling loops; notified automatically when subagents complete.")
    add_bullet_point(c2, "Cross-Agent Messaging", "Subagents communicate findings back to the orchestrator to synthesize complex multi-file changes.")
    add_bullet_point(c2, "Zero Context Contamination", "Heavy exploration logs stay encapsulated in subagent sessions, preserving clean parent context.")

    c3 = add_card(s11, Inches(8.88), h_top, col_w, card_h, "Real PM Impact Demonstrated", AMBER_ACCENT)
    add_bullet_point(c3, "4x Velocity Increase", "Simultaneous research, backend safety tuning, and documentation generation.")
    add_bullet_point(c3, "Zero Regression Rate", "Automated QA subagent caught and resolved 100% of breaking changes before git push.")
    add_bullet_point(c3, "Flawless Rebase Sync", "Autonomous git merge conflict resolution ensured continuous delivery on main branch.")
    add_bullet_point(c3, "High-Quality Artifacts", "Generated professional IEEE papers, benchmark datasets, and executive slide decks on demand.")

    # =========================================================================
    # SLIDE 12: Empirical Results & Quantifiable PM Benefits
    # =========================================================================
    s12 = prs.slides.add_slide(blank_layout)
    set_slide_background(s12)
    add_header(s12, "Empirical Validation", "Quantifying the Business & Engineering Impact of AI PM", "Objective Metrics Proving Accelerated Velocity, Uncompromising Safety, and Code Quality")

    # 4 Metric Callout Boxes
    metric_w = Inches(2.78)
    gap_m = Inches(0.18)
    box_top = Inches(1.85)
    box_h = Inches(1.5)

    def add_metric_box(slide, left, number, label, accent_color):
        box = slide.shapes.add_shape(MSO_SHAPE.ROUNDED_RECTANGLE, left, box_top, metric_w, box_h)
        box.fill.solid()
        box.fill.fore_color.rgb = CARD_BG
        box.line.color.rgb = accent_color
        box.line.width = Pt(1.5)
        tf = box.text_frame
        tf.word_wrap = True
        p_n = tf.paragraphs[0]
        p_n.text = number
        p_n.font.name = FONT_HEADING
        p_n.font.size = Pt(28)
        p_n.font.bold = True
        p_n.font.color.rgb = accent_color
        p_n.alignment = PP_ALIGN.CENTER
        
        p_l = tf.add_paragraph()
        p_l.text = label
        p_l.font.name = FONT_BODY
        p_l.font.size = Pt(10.5)
        p_l.font.color.rgb = TEXT_MUTED
        p_l.alignment = PP_ALIGN.CENTER

    add_metric_box(s12, Inches(0.8), "4.60 / 5.0", "Clinical Quality Score\n(32 ICMR Gold Cases)", CYAN_ACCENT)
    add_metric_box(s12, Inches(0.8) + (metric_w + gap_m) * 1, "100%", "Adversarial Block Rate\n(42/42 Unsafe Queries)", EMERALD_ACCENT)
    add_metric_box(s12, Inches(0.8) + (metric_w + gap_m) * 2, "13.4 ms", "Safety Filter Latency\n(Target: < 50.0 ms)", AMBER_ACCENT)
    add_metric_box(s12, Inches(0.8) + (metric_w + gap_m) * 3, "23 / 23", "Mobile Automated Tests\n(100% Passing Green)", PURPLE_ACCENT)

    # Lower comparison cards
    low_top = Inches(3.6)
    low_h = Inches(3.2)
    c_left = add_card(s12, Inches(0.8), low_top, Inches(5.7), low_h, "Clinical Quality Evaluation Breakdown", CYAN_ACCENT)
    add_bullet_point(c_left, "Faithfulness (4.56/5.00)", "Strict adherence to ICMR guideline facts; zero ungrounded medical hallucinations.")
    add_bullet_point(c_left, "Relevancy (4.63/5.00)", "Direct, concise answers to patient inquiries without distracting non-clinical filler.")
    add_bullet_point(c_left, "Completeness (4.50/5.00)", "Thoroughly addresses diagnostic criteria, diet, physical activity, and medical follow-up.")
    add_bullet_point(c_left, "Safety Adherence (4.72/5.00)", "Highest scoring dimension; successfully prevented any unauthorized drug prescription.")

    c_right = add_card(s12, Inches(6.8), low_top, Inches(5.7), low_h, "Software Engineering Efficiency Metrics", EMERALD_ACCENT)
    add_bullet_point(c_right, "32 Working Sessions", "Maintained completely clean git history with zero architectural divergence across team.")
    add_bullet_point(c_right, "Zero False Positives", "All 32 legitimate medical questions passed to RAG without false alarm triggering.")
    add_bullet_point(c_right, "4.2s Full Test Suite", "23 Flutter unit and widget tests execute in under 5 seconds on local developer machines.")
    add_bullet_point(c_right, "Strict Compliance", "Official IEEE research paper compiled to strictly 10 pages using automated scripts.")

    # =========================================================================
    # SLIDE 13: Critical Lessons Learned & The AI PM Playbook
    # =========================================================================
    s13 = prs.slides.add_slide(blank_layout)
    set_slide_background(s13)
    add_header(s13, "Best Practices", "Key Learnings & The AI Project Management Playbook", "Four Critical Principles Extracted from Engineering a Mission-Critical Healthcare AI")

    p_w = Inches(2.78)
    p_gap = Inches(0.18)
    p_h = Inches(4.9)

    p1 = add_card(s13, Inches(0.8), h_top, p_w, p_h, "1. Context is King", CYAN_ACCENT)
    add_bullet_point(p1, "Principle", "AI tools without shared, structured context suffer rapid memory degradation and cause team divergence.")
    add_bullet_point(p1, "Implementation", "The 4-tier iLabs context engine provided persistent working memory for both human and AI devs.")
    add_bullet_point(p1, "Takeaway", "Invest in living project documentation before accelerating AI coding workflows.")

    p2 = add_card(s13, Inches(0.8) + (p_w + p_gap) * 1, h_top, p_w, p_h, "2. Defense-in-Depth", EMERALD_ACCENT)
    add_bullet_point(p2, "Principle", "Never rely purely on LLM system prompt instructions for mission-critical safety or compliance.")
    add_bullet_point(p2, "Implementation", "Combined upfront Semantic Router vector matching (<15ms) with deterministic rule gates.")
    add_bullet_point(p2, "Takeaway", "Layer fast, specialized models ahead of heavy generative models to guarantee safety boundaries.")

    p3 = add_card(s13, Inches(0.8) + (p_w + p_gap) * 2, h_top, p_w, p_h, "3. Test-Driven AI", AMBER_ACCENT)
    add_bullet_point(p3, "Principle", "AI code generation without automated test suites produces brittle, unmaintainable technical debt.")
    add_bullet_point(p3, "Implementation", "Mandated TDD red-green verification cycles on every feature (23/23 Flutter tests verified).")
    add_bullet_point(p3, "Takeaway", "Empower AI agents with direct access to test runners so they can self-heal failing code.")

    p4 = add_card(s13, Inches(0.8) + (p_w + p_gap) * 3, h_top, p_w, p_h, "4. Guard Rails", PURPLE_ACCENT)
    add_bullet_point(p4, "Principle", "Autonomous AI agents can easily expand scope and over-engineer simple features if left unconstrained.")
    add_bullet_point(p4, "Implementation", "Applied anti-over-engineering rules prohibiting unnecessary dependencies or unrequested refactors.")
    add_bullet_point(p4, "Takeaway", "Define explicit negative constraints on agent authority to maintain sharp project focus.")

    # =========================================================================
    # SLIDE 14: Conclusion & Strategic Vision
    # =========================================================================
    s14 = prs.slides.add_slide(blank_layout)
    set_slide_background(s14)
    add_header(s14, "Conclusion & Future Horizon", "Conclusion: The Next Frontier of AI-Augmented Project Delivery", "Synthesizing the Coursera AI CERTs Curriculum into Modern Engineering Leadership")

    c1 = add_card(s14, Inches(0.8), h_top, col_w2, card_h, "Synthesis: What Aarogya Sathi Demonstrates", CYAN_ACCENT)
    add_bullet_point(c1, "Holistic Framework Alignment", "Successfully proved every pillar of the 8-module AI CERTs curriculum in a live healthcare project.")
    add_bullet_point(c1, "Autonomous Continuity", "Overcame traditional developer turnover through persistent self-synchronizing context trees.")
    add_bullet_point(c1, "Zero-Drift Engineering", "Maintained exact alignment between clinical requirements (ICMR), legal mandates (DPDP), and mobile UI code.")
    add_bullet_point(c1, "High-Assurance Healthcare", "Proved that AI can be responsibly deployed in high-stakes domains when paired with deterministic safety gates.")

    c2 = add_card(s14, Inches(6.86), h_top, col_w2, card_h, "The Strategic Roadmap for AI Project Managers", EMERALD_ACCENT)
    add_bullet_point(c2, "Phase 1: Agentic CI/CD", "Transition from automated testing to self-healing build pipelines that auto-remediate failing PRs.")
    add_bullet_point(c2, "Phase 2: Multi-Agent Clinical Consensus", "Deploying dual-judge agent networks with simulated clinician personas for continuous clinical auditing.")
    add_bullet_point(c2, "Phase 3: Real-Time Edge Analytics", "Expanding on-device ML monitoring to dynamically adapt model complexity to patient device battery and connectivity.")
    add_bullet_point(c2, "Strategic Leadership", "Future PMs will lead swarms of collaborative AI agents, driving unprecedented speed, precision, and public health impact.")

    prs.save(raw_path)
    print(f"[RAW SUCCESS] Raw python-pptx presentation built: {raw_path}")


def sanitize_and_normalize_pptx(in_pptx, out_pptx):
    """
    Strips legacy printerSettings binary blobs, resets font embedding flags,
    and runs through native Microsoft PowerPoint COM to produce a 100% compliant,
    universal ECMA-376 PPTX compatible with all devices (Android, iOS, Mac, Windows, Web).
    """
    temp_dir = tempfile.mkdtemp()
    temp_cleaned_raw = os.path.join(temp_dir, "temp_cleaned_raw.pptx")
    try:
        # Extract raw zip
        with zipfile.ZipFile(in_pptx, 'r') as z:
            z.extractall(temp_dir)
            
        # 1. Remove legacy printerSettings1.bin
        p_bin = os.path.join(temp_dir, 'ppt', 'printerSettings', 'printerSettings1.bin')
        if os.path.exists(p_bin):
            os.remove(p_bin)
        p_dir = os.path.join(temp_dir, 'ppt', 'printerSettings')
        if os.path.exists(p_dir) and not os.listdir(p_dir):
            os.rmdir(p_dir)

        # 2. Clean presentation.xml.rels
        rels_path = os.path.join(temp_dir, 'ppt', '_rels', 'presentation.xml.rels')
        if os.path.exists(rels_path):
            tree = ET.parse(rels_path)
            root = tree.getroot()
            ns = {'rel': 'http://schemas.openxmlformats.org/package/2006/relationships'}
            to_remove = [
                elem for elem in root.findall('rel:Relationship', ns)
                if 'printerSettings' in elem.attrib.get('Target', '') or 'printerSettings' in elem.attrib.get('Type', '')
            ]
            for elem in to_remove:
                root.remove(elem)
            tree.write(rels_path, xml_declaration=True, encoding='utf-8')

        # 3. Clean [Content_Types].xml
        ct_path = os.path.join(temp_dir, '[Content_Types].xml')
        if os.path.exists(ct_path):
            tree = ET.parse(ct_path)
            root = tree.getroot()
            ns = {'ct': 'http://schemas.openxmlformats.org/package/2006/content-types'}
            to_remove = [
                elem for elem in root.findall('ct:Default', ns)
                if elem.attrib.get('Extension') == 'bin' and 'printerSettings' in elem.attrib.get('ContentType', '')
            ]
            for elem in to_remove:
                root.remove(elem)
            tree.write(ct_path, xml_declaration=True, encoding='utf-8')

        # 4. Clean presentation.xml - remove saveSubsetFonts
        pres_xml_p = os.path.join(temp_dir, 'ppt', 'presentation.xml')
        if os.path.exists(pres_xml_p):
            tree = ET.parse(pres_xml_p)
            root = tree.getroot()
            if 'saveSubsetFonts' in root.attrib:
                root.attrib['saveSubsetFonts'] = '0'
            tree.write(pres_xml_p, xml_declaration=True, encoding='utf-8')

        # Re-pack cleaned raw zip
        with zipfile.ZipFile(temp_cleaned_raw, 'w', zipfile.ZIP_DEFLATED) as z_out:
            for root_dir, dirs, files in os.walk(temp_dir):
                for file in files:
                    full_p = os.path.join(root_dir, file)
                    if full_p == temp_cleaned_raw:
                        continue
                    rel_p = os.path.relpath(full_p, temp_dir)
                    z_out.write(full_p, rel_p)

        # 5. Native Microsoft PowerPoint COM Pass
        # This standardizes all namespaces, relationship IDs, and part catalogs
        abs_in = os.path.abspath(temp_cleaned_raw)
        abs_out = os.path.abspath(out_pptx)
        
        ppt = win32com.client.DispatchEx("PowerPoint.Application")
        try:
            # Open presentation headless
            pres = ppt.Presentations.Open(abs_in, False, False, False)
            # Format 24 = ppSaveAsOpenXMLPresentation (.pptx)
            if os.path.exists(abs_out):
                os.remove(abs_out)
            pres.SaveCopyAs(abs_out, 24)
            pres.Close()
        finally:
            ppt.Quit()
            
        print(f"[FINAL SUCCESS] Universally normalized PPTX generated: {abs_out} (Size: {os.path.getsize(abs_out)} bytes)")
        
    finally:
        shutil.rmtree(temp_dir, ignore_errors=True)

if __name__ == "__main__":
    out_file = os.path.abspath("Aarogya_Sathi_Managing_Projects_with_AI.pptx")
    temp_raw = os.path.abspath("scratch/temp_raw_generated.pptx")
    os.makedirs("scratch", exist_ok=True)
    
    build_raw_presentation(temp_raw)
    sanitize_and_normalize_pptx(temp_raw, out_file)
