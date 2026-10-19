import os
import io
import docx
from docx.shared import Inches, Pt, RGBColor
from docx.enum.text import WD_ALIGN_PARAGRAPH
from docx.enum.table import WD_TABLE_ALIGNMENT
from docx.oxml import parse_xml, OxmlElement
from docx.oxml.ns import nsdecls, qn
from PIL import Image

def set_cell_background(cell, hex_color):
    """Set background color of a table cell."""
    tcPr = cell._tc.get_or_add_tcPr()
    shd = parse_xml(f'<w:shd {nsdecls("w")} w:fill="{hex_color}"/>')
    tcPr.append(shd)

def set_cell_margins(cell, top=100, bottom=100, left=150, right=150):
    """Set padding inside a table cell."""
    tcPr = cell._tc.get_or_add_tcPr()
    tcMar = parse_xml(
        f'<w:tcMar {nsdecls("w")}>'
        f'<w:top w:w="{top}" w:type="dxa"/>'
        f'<w:bottom w:w="{bottom}" w:type="dxa"/>'
        f'<w:left w:w="{left}" w:type="dxa"/>'
        f'<w:right w:w="{right}" w:type="dxa"/>'
        f'</w:tcMar>'
    )
    tcPr.append(tcMar)

def add_table_caption(doc, table, caption_text):
    """Insert a standard academic caption paragraph immediately above a table."""
    p = doc.add_paragraph()
    p.alignment = WD_ALIGN_PARAGRAPH.CENTER
    p.paragraph_format.space_before = Pt(12)
    p.paragraph_format.space_after = Pt(4)
    p.paragraph_format.keep_with_next = True
    
    run = p.add_run(caption_text)
    run.font.name = 'Times New Roman'
    run.font.size = Pt(11)
    run.font.bold = True
    run.font.color.rgb = RGBColor(0, 51, 102) # Academic navy blue
    
    table._tbl.addprevious(p._p)
    return p

def main():
    doc_path = r"c:\Users\ritpa\OneDrive\Desktop\AarogyaSathi Final\Aarogya_Sathi_Interim_Report_Review_Final.docx"
    doc = docx.Document(doc_path)
    
    print(f"Loaded document: {len(doc.paragraphs)} paragraphs, {len(doc.tables)} tables.")
    
    # =========================================================================
    # STEP 1: Add Captions to All Existing Tables
    # =========================================================================
    print("Step 1: Adding formal captions to all tables...")
    
    # Table 2 (Gap Analysis in Section 2.8)
    add_table_caption(
        doc, doc.tables[1],
        "Table 2.1: Comparative Gap Analysis of Existing Digital Health Platforms vs. Aarogya Sathi"
    )
    
    # Table 3 (Tech Stack in Section 3.3)
    add_table_caption(
        doc, doc.tables[2],
        "Table 3.1: Aarogya Sathi Architectural Technology Stack and Implementation Rationale"
    )
    
    # Table 4 (Code block for AgentState in Section 4.1.1)
    add_table_caption(
        doc, doc.tables[3],
        "Table 4.1: AgentState Data Structure and Intent-Based Tool Dispatch Execution Schema"
    )
    
    # Table 5 (Evaluation results in Section 5.2)
    add_table_caption(
        doc, doc.tables[4],
        "Table 5.1: Gold-Standard Benchmark Test Cases and Multi-Metric Clinical Evaluation"
    )
    print("  [OK] Added captions to Tables 2.1, 3.1, 4.1, 5.1.")

    # =========================================================================
    # STEP 2: Add Section 6.2 with Table 6.1 and Section 6.3 in Chapter 6
    # =========================================================================
    print("Step 2: Inserting Section 6.2 (with Table 6.1) and Section 6.3 into Chapter 6...")
    
    # Find paragraph 226 ("Implemented the Sarvam AI translation module to add Hindi support.")
    # which is the last item under Phase 3 of Chapter 6.
    target_p_idx = None
    for idx, p in enumerate(doc.paragraphs):
        if "Sarvam AI translation module" in p.text:
            target_p_idx = idx
            break
            
    if target_p_idx is None:
        print("  [WARNING] Could not find Sarvam translation paragraph, searching for Chapter 6...")
        for idx, p in enumerate(doc.paragraphs):
            if "CHAPTER 6" in p.text:
                target_p_idx = idx + 10
                break

    ref_p = doc.paragraphs[target_p_idx]
    
    # Helper to insert after a paragraph or table
    def insert_p_after(ref, text="", style='Normal', space_before=0, space_after=6, bold=False, italic=False, size=12, color=RGBColor(20, 20, 20), align=WD_ALIGN_PARAGRAPH.JUSTIFY):
        new_p = doc.add_paragraph()
        new_p.paragraph_format.space_before = Pt(space_before)
        new_p.paragraph_format.space_after = Pt(space_after)
        new_p.paragraph_format.alignment = align
        if text:
            r = new_p.add_run(text)
            r.font.name = 'Times New Roman'
            r.font.size = Pt(size)
            r.font.bold = bold
            r.font.italic = italic
            r.font.color.rgb = color
        element = ref._tbl if hasattr(ref, '_tbl') else ref._p
        element.addnext(new_p._p)
        return new_p

    # We insert in reverse or sequential order by chaining addnext:
    # 1. Heading 6.2: Team Contributions
    p_h62 = insert_p_after(ref_p, "6.2 Team Contributions", space_before=14, space_after=6, bold=True, size=13, color=RGBColor(30, 30, 30), align=WD_ALIGN_PARAGRAPH.LEFT)
    p_h62.paragraph_format.keep_with_next = True
    
    p_desc62 = insert_p_after(
        p_h62,
        "The implementation of Aarogya Sathi was partitioned into three specialized engineering domains aligned with team member proficiencies: Backend System Architecture & Agentic AI Orchestration, Clinical Knowledge Base Engineering & Evaluation Frameworks, and Mobile Client Application & Wearable Ecosystem Integration. Table 6.1 outlines the division of responsibilities, assigned work packages, and concrete deliverables contributed by each team member for Review 2.",
        space_before=2, space_after=8
    )
    
    # 2. Caption for Table 6.1
    p_cap61 = insert_p_after(
        p_desc62,
        "Table 6.1: Project Team Member Roles, Assigned Work Packages, and Key Contributions",
        space_before=10, space_after=4, bold=True, size=11, color=RGBColor(0, 51, 102), align=WD_ALIGN_PARAGRAPH.CENTER
    )
    p_cap61.paragraph_format.keep_with_next = True
    
    # 3. Create Table 6.1
    t61 = doc.add_table(rows=4, cols=4)
    t61.style = 'Table Grid'
    t61.alignment = WD_TABLE_ALIGNMENT.CENTER
    
    headers = [
        "Sr. No.",
        "Team Member & Roll No.",
        "Assigned Module & Domain",
        "Key Technical Contributions & Implemented Deliverables"
    ]
    
    col_widths = [Inches(0.6), Inches(1.6), Inches(1.8), Inches(2.2)]
    
    rows_data = [
        headers,
        [
            "1",
            "Jayesh Patil\n(70532300036)",
            "Backend Architecture & Agentic AI Orchestration",
            "• Engineered the core Agentic CRAG Pipeline in FastAPI/Python 3.11 with asynchronous Server-Sent Events (SSE) streaming.\n• Implemented sub-100ms semantic safety router utilizing sentence-transformers/all-MiniLM-L6-v2 embeddings (0.82 cosine cutoff).\n• Built the 4-tier multi-key LLM failover waterfall across Groq LPU, SambaNova, and Cerebras cloud providers.\n• Developed deterministic OKF Navigator traversal graph with link-crawling depth control (<=2)."
        ],
        [
            "2",
            "Abhijit Patil\n(70532100054)",
            "Knowledge Base Engineering & Clinical Evaluation",
            "• Curated and standardized the 34-document ICMR knowledge bundle across 5 distinct clinical categories (conditions, drugs, lifestyle, emergency, environmental).\n• Developed the CPCB National Air Quality Index (NAQI) linear sub-index calculation engine for 6 criteria pollutants.\n• Designed the 32-case gold-standard clinical evaluation benchmark covering conditions, pharmacology, and lifestyle.\n• Implemented automated LLM-as-a-Judge scoring pipeline across Faithfulness, Relevance, Completeness, and Safety metrics."
        ],
        [
            "3",
            "Ritesh Pawar\n(70532200035)",
            "Mobile Client Frontend & Wearable Ecosystem",
            "• Engineered cross-platform mobile client application in Flutter 3.24 with Material 3 responsive design and Provider state management.\n• Integrated Android Health Connect Client SDK v1.1.0 for seamless synchronization of 16 biometric and wearable health parameters.\n• Implemented StepFilterService hysteresis filter to reject stationary sensor artifacts and hardware pedometer daily rollover.\n• Integrated Sarvam AI (Mayura v1) translation service for real-time Hindi and Marathi vernacular chat support.\n• Enforced on-device DPDP Act 2023 data sovereignty with local encrypted storage (FlutterSecureStorage)."
        ]
    ]
    
    for r_idx, row in enumerate(t61.rows):
        is_hdr = (r_idx == 0)
        for c_idx, cell in enumerate(row.cells):
            cell.width = col_widths[c_idx]
            set_cell_margins(cell, top=80, bottom=80, left=100, right=100)
            if is_hdr:
                set_cell_background(cell, "003366")
            else:
                if r_idx % 2 == 1:
                    set_cell_background(cell, "F8F9FA")
                else:
                    set_cell_background(cell, "FFFFFF")
            
            p = cell.paragraphs[0]
            p.paragraph_format.space_before = Pt(2)
            p.paragraph_format.space_after = Pt(2)
            p.paragraph_format.line_spacing = 1.05
            
            run = p.add_run(rows_data[r_idx][c_idx])
            run.font.name = 'Times New Roman'
            if is_hdr:
                run.font.size = Pt(10)
                run.font.bold = True
                run.font.color.rgb = RGBColor(255, 255, 255)
            else:
                run.font.size = Pt(9.5)
                run.font.color.rgb = RGBColor(30, 30, 30)
                if c_idx == 0:
                    p.alignment = WD_ALIGN_PARAGRAPH.CENTER
                    run.font.bold = True
                elif c_idx == 1:
                    run.font.bold = True
                    
    # Move table after p_cap61
    p_cap61._p.addnext(t61._tbl)
    
    # 4. Heading 6.3: Current Implementation Progress
    p_h63 = insert_p_after(t61, "6.3 Current Implementation Progress", space_before=16, space_after=6, bold=True, size=13, color=RGBColor(30, 30, 30), align=WD_ALIGN_PARAGRAPH.LEFT)
    p_h63.paragraph_format.keep_with_next = True
    
    p_desc63 = insert_p_after(
        p_h63,
        "As of Review 2 (October 2026), the foundational architecture and primary feature pipelines of Aarogya Sathi have been fully operationalized and validated. Table 6.2 summarizes the implementation completion status across core system modules:",
        space_before=2, space_after=6
    )
    
    # 5. Add Table 6.2 Progress Summary
    p_cap62 = insert_p_after(
        p_desc63,
        "Table 6.2: Aarogya Sathi Module Implementation Status for Review 2",
        space_before=8, space_after=4, bold=True, size=11, color=RGBColor(0, 51, 102), align=WD_ALIGN_PARAGRAPH.CENTER
    )
    p_cap62.paragraph_format.keep_with_next = True
    
    t62 = doc.add_table(rows=8, cols=4)
    t62.style = 'Table Grid'
    t62.alignment = WD_TABLE_ALIGNMENT.CENTER
    
    progress_headers = ["Module Name", "Primary Technologies", "Completion (%)", "Operational Status"]
    progress_rows = [
        progress_headers,
        ["Backend REST API Gateway", "FastAPI, Uvicorn, Render", "100%", "Fully Deployed & Active"],
        ["Agentic CRAG Pipeline", "Python 3.11, Groq LPU, Qwen 27B", "100%", "Active with SSE Streaming"],
        ["Semantic Safety Router", "MiniLM-L6-v2, Cosine Sim", "100%", "Sub-100ms Triage Validated"],
        ["ICMR Knowledge Bundle", "34 Markdown Monographs (OKF)", "100%", "Fully Audited & Linked"],
        ["Health Connect Wearables", "Android SDK, Pedometer Fallback", "100%", "Validated on Physical Device"],
        ["Multilingual Translation", "Sarvam AI (Mayura v1)", "85%", "Hindi/Marathi Integrated"],
        ["Clinical Evaluation Suite", "LLM-as-Judge, 32 Benchmark Pairs", "80%", "4.86/5.00 Safety Scored"]
    ]
    
    for r_idx, row in enumerate(t62.rows):
        is_hdr = (r_idx == 0)
        for c_idx, cell in enumerate(row.cells):
            set_cell_margins(cell, top=60, bottom=60, left=80, right=80)
            if is_hdr:
                set_cell_background(cell, "003366")
            else:
                if r_idx % 2 == 1:
                    set_cell_background(cell, "F8F9FA")
                else:
                    set_cell_background(cell, "FFFFFF")
            
            p = cell.paragraphs[0]
            p.paragraph_format.space_before = Pt(2)
            p.paragraph_format.space_after = Pt(2)
            run = p.add_run(progress_rows[r_idx][c_idx])
            run.font.name = 'Times New Roman'
            if is_hdr:
                run.font.size = Pt(10)
                run.font.bold = True
                run.font.color.rgb = RGBColor(255, 255, 255)
            else:
                run.font.size = Pt(9.5)
                run.font.color.rgb = RGBColor(30, 30, 30)
                if c_idx == 2:
                    p.alignment = WD_ALIGN_PARAGRAPH.CENTER
                    run.font.bold = True
                    
    p_cap62._p.addnext(t62._tbl)
    print("  [OK] Successfully inserted Section 6.2, Table 6.1, Section 6.3, and Table 6.2.")

    # =========================================================================
    # STEP 3: Add Figure 4.5 in Section 4.3 (ICMR Knowledge Bundle Graph)
    # =========================================================================
    print("Step 3: Inserting Figure 4.5 into Section 4.3...")
    
    target_p_43 = None
    for idx, p in enumerate(doc.paragraphs):
        if "Hyperlinking was performed in a thorough way" in p.text:
            target_p_43 = idx
            break
            
    if target_p_43 is not None:
        ref_p_43 = doc.paragraphs[target_p_43]
        
        # Add Figure 4.5 image
        fig_4_5_path = r"c:\Users\ritpa\OneDrive\Desktop\AarogyaSathi Final\docs\diagrams\images\figure_4_5_icmr_knowledge_graph.png"
        if os.path.exists(fig_4_5_path):
            p_img45 = doc.add_paragraph()
            p_img45.alignment = WD_ALIGN_PARAGRAPH.CENTER
            p_img45.paragraph_format.space_before = Pt(12)
            p_img45.paragraph_format.space_after = Pt(4)
            p_img45.paragraph_format.keep_with_next = True
            
            run_img = p_img45.add_run()
            # Dimensions for fig 4.5: size=(1216, 446)
            # Display width = 4.8 in, height = 4.8 * 446 / 1216 = 1.76 in
            run_img.add_picture(fig_4_5_path, width=Inches(4.8))
            
            p_cap45 = doc.add_paragraph()
            p_cap45.alignment = WD_ALIGN_PARAGRAPH.CENTER
            p_cap45.paragraph_format.space_before = Pt(2)
            p_cap45.paragraph_format.space_after = Pt(12)
            
            run_cap = p_cap45.add_run("Figure 4.5: ICMR Knowledge Bundle Open Knowledge Format (OKF) Concept Hierarchy and Cross-Linking Graph")
            run_cap.font.name = 'Times New Roman'
            run_cap.font.size = Pt(10.5)
            run_cap.font.bold = True
            run_cap.font.italic = True
            run_cap.font.color.rgb = RGBColor(60, 60, 60)
            
            ref_p_43._p.addnext(p_img45._p)
            p_img45._p.addnext(p_cap45._p)
            print("  [OK] Successfully inserted Figure 4.5 into Section 4.3.")

    # =========================================================================
    # STEP 4: Update All Embedded Diagram Images with High-Res Versions & Scaling
    # =========================================================================
    print("Step 4: Updating embedded diagram images with 3200px high-resolution files and perfect aspect ratios...")
    
    # Map paragraph drawing indexes to their corresponding high-res image files
    img_dir = r"c:\Users\ritpa\OneDrive\Desktop\AarogyaSathi Final\docs\diagrams\images"
    diagram_replacements = {
        # P_idx in original doc -> (new_file, max_height_inches, fixed_width_inches)
        96: ("figure_3_1_overall_system_architecture.png", 5.5, None),
        99: ("figure_3_2_react_loop_state_machine.png", 5.4, None),
        108: ("figure_3_3_dpdp_privacy_boundary.png", 5.4, None),
        131: ("figure_4_2_multi_key_llm_cascade.png", 5.5, None),
        136: ("figure_4_3_safety_router_clinical_triage.png", 5.4, None),
        141: ("figure_4_4_cpcb_naqi_calculation.png", 5.4, Inches(5.8)),
        152: ("figure_4_1_wearable_health_connect_pipeline.png", 5.2, Inches(5.8)),
    }
    
    for p_idx, p in enumerate(doc.paragraphs):
        drawings = p._p.xpath('.//w:drawing')
        if not drawings:
            continue
            
        for d in drawings:
            blips = d.xpath('.//a:blip/@r:embed')
            if not blips:
                continue
            rel_id = blips[0]
            
            # Check if this drawing matches one of our diagrams
            # Check text in next paragraph to be 100% sure of the figure identity
            next_text = doc.paragraphs[p_idx+1].text if p_idx+1 < len(doc.paragraphs) else ""
            
            new_fname = None
            if "Figure 3.1" in next_text:
                new_fname = "figure_3_1_overall_system_architecture.png"
            elif "Figure 3.2" in next_text:
                new_fname = "figure_3_2_react_loop_state_machine.png"
            elif "Figure 3.3" in next_text:
                new_fname = "figure_3_3_dpdp_privacy_boundary.png"
            elif "Figure 4.1" in next_text:
                new_fname = "figure_4_2_multi_key_llm_cascade.png"
            elif "Figure 4.2" in next_text:
                new_fname = "figure_4_3_safety_router_clinical_triage.png"
            elif "Figure 4.3" in next_text:
                new_fname = "figure_4_4_cpcb_naqi_calculation.png"
            elif "Figure 4.4" in next_text:
                new_fname = "figure_4_1_wearable_health_connect_pipeline.png"
                
            if new_fname:
                new_img_path = os.path.join(img_dir, new_fname)
                if os.path.exists(new_img_path):
                    with open(new_img_path, "rb") as f_img:
                        new_bytes = f_img.read()
                        
                    # Update binary blob in docx package
                    image_part = doc.part.related_parts[rel_id]
                    image_part._blob = new_bytes
                    
                    # Compute compact, highly legible display dimensions
                    # Faculty request: compact images that are close-up and not "too far away"
                    pil_img = Image.open(io.BytesIO(new_bytes))
                    w_px, h_px = pil_img.size
                    aspect = h_px / w_px
                    
                    max_h_in = 3.5  # Compact height: fits cleanly with surrounding text
                    max_w_in = 4.8  # Compact width: neatly centered, readable labels
                    
                    # Compute width & height in inches
                    if max_w_in * aspect > max_h_in:
                        disp_h_in = max_h_in
                        disp_w_in = max_h_in / aspect
                    else:
                        disp_w_in = max_w_in
                        disp_h_in = max_w_in * aspect
                        
                    cx_emu = int(disp_w_in * 914400)
                    cy_emu = int(disp_h_in * 914400)
                    
                    # Update XML extent attributes
                    extents = d.xpath('.//wp:extent')
                    for ext in extents:
                        ext.set('cx', str(cx_emu))
                        ext.set('cy', str(cy_emu))
                        
                    a_exts = d.xpath('.//a:xfrm/a:ext')
                    for a_ext in a_exts:
                        a_ext.set('cx', str(cx_emu))
                        a_ext.set('cy', str(cy_emu))
                        
                    print(f"  [OK] Replaced {new_fname} for '{next_text[:30]}...' -> Display size: {disp_w_in:.2f}\" x {disp_h_in:.2f}\" (Native: {w_px}x{h_px})")

    # =========================================================================
    # STEP 5: Add LIST OF TABLES and LIST OF FIGURES in Front Matter
    # =========================================================================
    print("Step 5: Adding LIST OF TABLES and LIST OF FIGURES to Front Matter...")
    
    # Locate Table 1 (Table of Contents)
    t1 = doc.tables[0]
    
    # We want to insert LIST OF TABLES right after Table 1
    p_lot_h = doc.add_paragraph()
    p_lot_h.paragraph_format.space_before = Pt(24)
    p_lot_h.paragraph_format.space_after = Pt(8)
    p_lot_h.paragraph_format.keep_with_next = True
    r = p_lot_h.add_run("LIST OF TABLES")
    r.font.name = 'Times New Roman'
    r.font.size = Pt(14)
    r.font.bold = True
    r.font.color.rgb = RGBColor(0, 51, 102)
    
    # Create List of Tables Table
    lot_tbl = doc.add_table(rows=6, cols=2)
    lot_tbl.style = 'Table Grid'
    lot_tbl.alignment = WD_TABLE_ALIGNMENT.CENTER
    
    lot_data = [
        ["Table No. & Title", "Page No."],
        ["Table 2.1: Comparative Gap Analysis of Existing Digital Health Platforms vs. Aarogya Sathi", "7"],
        ["Table 3.1: Aarogya Sathi Architectural Technology Stack and Implementation Rationale", "12"],
        ["Table 4.1: AgentState Data Structure and Intent-Based Tool Dispatch Execution Schema", "17"],
        ["Table 5.1: Gold-Standard Benchmark Test Cases and Multi-Metric Clinical Evaluation", "29"],
        ["Table 6.1: Project Team Member Roles, Assigned Work Packages, and Key Contributions", "34"]
    ]
    
    for r_idx, row in enumerate(lot_tbl.rows):
        is_hdr = (r_idx == 0)
        for c_idx, cell in enumerate(row.cells):
            set_cell_margins(cell, top=60, bottom=60, left=100, right=100)
            if is_hdr:
                set_cell_background(cell, "003366")
            else:
                set_cell_background(cell, "F8F9FA" if r_idx % 2 == 1 else "FFFFFF")
                
            p = cell.paragraphs[0]
            p.paragraph_format.space_before = Pt(2)
            p.paragraph_format.space_after = Pt(2)
            run = p.add_run(lot_data[r_idx][c_idx])
            run.font.name = 'Times New Roman'
            if is_hdr:
                run.font.size = Pt(10)
                run.font.bold = True
                run.font.color.rgb = RGBColor(255, 255, 255)
            else:
                run.font.size = Pt(9.5)
                run.font.color.rgb = RGBColor(30, 30, 30)
                if c_idx == 1:
                    p.alignment = WD_ALIGN_PARAGRAPH.RIGHT
                    run.font.bold = True
                    
    # List of Figures Heading
    p_lof_h = doc.add_paragraph()
    p_lof_h.paragraph_format.space_before = Pt(24)
    p_lof_h.paragraph_format.space_after = Pt(8)
    p_lof_h.paragraph_format.keep_with_next = True
    r = p_lof_h.add_run("LIST OF FIGURES")
    r.font.name = 'Times New Roman'
    r.font.size = Pt(14)
    r.font.bold = True
    r.font.color.rgb = RGBColor(0, 51, 102)
    
    # Create List of Figures Table
    lof_tbl = doc.add_table(rows=9, cols=2)
    lof_tbl.style = 'Table Grid'
    lof_tbl.alignment = WD_TABLE_ALIGNMENT.CENTER
    
    lof_data = [
        ["Figure No. & Caption", "Page No."],
        ["Figure 3.1: Overall System Architecture of Aarogya Sathi (Flutter ↔ FastAPI ↔ Agentic ReAct ↔ Inference Cascade)", "10"],
        ["Figure 3.2: Agentic ReAct Loop State Machine and Intent-Driven Execution Pipeline", "11"],
        ["Figure 3.3: Data Sovereignty and Zero-Storage Session Boundary under India's DPDP Act 2023", "13"],
        ["Figure 4.1: Multi-Key Pooling and Multi-Provider Failover Waterfall (Groq ↔ SambaNova ↔ Cerebras ↔ Local Fallbacks)", "19"],
        ["Figure 4.2: Safety Router & Sub-100ms Clinical Triage Pipeline with MiniLM Dense Embeddings", "20"],
        ["Figure 4.3: Environmental NAQI Calculation and Clinical Alerting Pipeline", "21"],
        ["Figure 4.4: Wearable Health Connect Synchronization Pipeline with Smart Deduplication", "24"],
        ["Figure 4.5: ICMR Knowledge Bundle Open Knowledge Format (OKF) Concept Hierarchy and Cross-Linking Graph", "27"]
    ]
    
    for r_idx, row in enumerate(lof_tbl.rows):
        is_hdr = (r_idx == 0)
        for c_idx, cell in enumerate(row.cells):
            set_cell_margins(cell, top=60, bottom=60, left=100, right=100)
            if is_hdr:
                set_cell_background(cell, "003366")
            else:
                set_cell_background(cell, "F8F9FA" if r_idx % 2 == 1 else "FFFFFF")
                
            p = cell.paragraphs[0]
            p.paragraph_format.space_before = Pt(2)
            p.paragraph_format.space_after = Pt(2)
            run = p.add_run(lof_data[r_idx][c_idx])
            run.font.name = 'Times New Roman'
            if is_hdr:
                run.font.size = Pt(10)
                run.font.bold = True
                run.font.color.rgb = RGBColor(255, 255, 255)
            else:
                run.font.size = Pt(9.5)
                run.font.color.rgb = RGBColor(30, 30, 30)
                if c_idx == 1:
                    p.alignment = WD_ALIGN_PARAGRAPH.RIGHT
                    run.font.bold = True
                    
    # Insert LOT and LOF after Table 1
    t1._tbl.addnext(p_lot_h._p)
    p_lot_h._p.addnext(lot_tbl._tbl)
    lot_tbl._tbl.addnext(p_lof_h._p)
    p_lof_h._p.addnext(lof_tbl._tbl)
    
    # Save the updated document
    doc.save(doc_path)
    print(f"\nSUCCESS! Fully updated document saved at:\n{doc_path}")

if __name__ == "__main__":
    main()
