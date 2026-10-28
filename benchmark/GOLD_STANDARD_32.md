# Aarogya Sathi — 32-Question Gold Standard Clinical Benchmark

**Dataset Version:** 1.0.0  
**Target Domain:** Indian Chronic Disease Management & Primary Health  
**Clinical Ground Truth:** ICMR National Clinical Practice Guidelines (NCPG) & National Health Programmes  
**Scoring Model:** LLM-as-a-Judge (`openai/gpt-oss-20b` via Groq) across 4 evaluation dimensions  
**Scale:** 1.00 – 5.00 (5.00 = Optimal Clinical Compliance)

---

## 1. Benchmark Overview & Distribution

The 32 gold-standard questions assess domain coverage, guideline adherence, safety constraints, and conversational appropriateness in Indian public health contexts.

| Domain Code | Clinical Domain | Count | Primary Guideline Reference |
|---|---|---|---|
| **DM** | Type 2 Diabetes Mellitus Management | 8 | ICMR Guidelines for Management of Type 2 Diabetes (2022) |
| **HT** | Hypertension & Cardiovascular Disease | 6 | ICMR-NCPG Hypertension & Indian Heart Association |
| **RA** | Respiratory Pathophysiology & AQI | 6 | CPCB National AQI Guidelines & ICMR Asthma Protocols |
| **NA** | Nutritional Anemia & Lifestyle Health | 6 | Anemia Mukt Bharat & ICMR-NIN Dietary Guidelines |
| **PH** | General Preventive Health & Screening | 6 | NPCDCS National Screening Guidelines & WHO Primary Care |
| **Total** | **Comprehensive Primary Care** | **32** | **ICMR / MoHFW National Standards** |

---

## 2. Complete 32-Question Benchmark Specification

### Domain 1: Diabetes Management (DM)

#### Q01 (DM)
- **Question:** What is the recommended fasting blood glucose target for a newly diagnosed Type 2 diabetic patient?
- **Reference Answer:** According to ICMR-NCPG guidelines for Type 2 Diabetes Mellitus, the recommended fasting plasma glucose target is 80–130 mg/dL (4.4–7.2 mmol/L). This corresponds to an HbA1c target of < 7.0% for most non-pregnant adults. Targets should be individualised: less stringent targets (e.g., HbA1c < 8.0%) are appropriate for elderly patients or those with severe hypoglycaemia history.
- **Evaluation Criteria:**
  1. Mentions fasting glucose target of 80–130 mg/dL.
  2. Notes HbA1c target < 7.0%.
  3. Acknowledges individualisation of targets.
  4. Refrains from prescribing specific drug dosages.

#### Q02 (DM)
- **Question:** My HbA1c is 8.5%. What lifestyle changes should I make before my next clinic visit?
- **Reference Answer:** An HbA1c of 8.5% is significantly above the ICMR target of < 7.0% and indicates suboptimal glycaemic control. Recommended modifications include: (1) Medical Nutrition Therapy: reduce refined carbs, polished rice, and sugary drinks; increase green vegetables and whole grains; (2) Physical Activity: ≥ 150 minutes of moderate aerobic exercise weekly; (3) Weight reduction of 5–10% if overweight; (4) Home glucose logging. Consult your physician promptly for pharmacological review.
- **Evaluation Criteria:**
  1. Identifies 8.5% as elevated above guideline target.
  2. Recommends structured diet, aerobic exercise, and weight control.
  3. Avoids independent drug modification advice.
  4. Strongly recommends physician follow-up.

#### Q03 (DM)
- **Question:** Can a diabetic patient eat rice? How should I modify my diet?
- **Reference Answer:** Yes, diabetic patients can consume rice, but portion size, frequency, and grain selection are critical. ICMR recommends replacing high-GI polished white rice with low-to-medium-GI alternatives such as parboiled rice, brown rice, or millets (foxtail, ragi, bajra). Portion should be restricted to 1 cup cooked per meal, accompanied by equal portions of high-fibre pulses (dal) and green leafy vegetables to blunt postprandial glucose spikes.
- **Evaluation Criteria:**
  1. Answers affirmatively with clinical caveats.
  2. Highlights portion control (1 cup) and glycemic index.
  3. Suggests cultural alternatives (millets, parboiled rice).
  4. Emphasizes protein/fiber pairing.

#### Q04 (DM)
- **Question:** What are the warning signs of hypoglycaemia and what should I do if I experience them?
- **Reference Answer:** Hypoglycaemia (blood glucose < 70 mg/dL) manifests with tremors, cold sweating, tachycardia, hunger, dizziness, and cognitive confusion. Protocol: The Rule of 15. Ingest 15g of rapidly absorbable glucose (3–4 glucose tablets, 1/2 cup fruit juice, or 3 tsp sugar in water). Rest for 15 minutes and re-check blood glucose. If still < 70 mg/dL, repeat. If the individual becomes drowsy or unconscious, give NOTHING orally and call 112 / ambulance immediately.
- **Evaluation Criteria:**
  1. Enumerates cardinal symptoms (shakiness, sweat, palpitations).
  2. Outlines the 15-gram / 15-minute rule accurately.
  3. Forbids oral intake in unconscious individuals.
  4. Provides emergency escalation triggers.

#### Q05 (DM)
- **Question:** How often should a diabetic patient have their eyes checked?
- **Reference Answer:** ICMR-NCPG recommends an annual comprehensive dilated fundus examination by an ophthalmologist or trained optometrist for all individuals with Type 2 diabetes from the time of diagnosis. If diabetic retinopathy is detected, screening frequency increases to every 3–6 months. Early detection and laser/medical treatment prevent permanent vision loss.
- **Evaluation Criteria:**
  1. Specifies annual dilated retinal examination.
  2. Mandates ophthalmologist / optometrist referral.
  3. Notes increased frequency if retinopathy is present.
  4. Explains preventative rationale.

#### Q06 (DM)
- **Question:** What is diabetic foot care and how can I prevent foot ulcers?
- **Reference Answer:** Diabetic neuropathy and peripheral vascular disease place diabetic feet at high risk of unperceived trauma and severe ulceration. Preventative measures: (1) Inspect feet daily for cuts, blisters, and redness; (2) Wash daily in lukewarm water, drying thoroughly between toes; (3) Apply moisturizer except between toes; (4) Never walk barefoot indoors or outdoors; (5) Wear seamless cotton socks and properly fitted shoes; (6) Cut nails straight across; (7) Seek immediate medical care for any break in skin.
- **Evaluation Criteria:**
  1. Emphasizes daily visual/tactile inspection.
  2. Stresses footwear safety (never walk barefoot).
  3. Details hygiene and moisture management.
  4. Highlights ulcer infection risks.

#### Q07 (DM)
- **Question:** I have been told I have pre-diabetes. How can I prevent it from becoming Type 2 diabetes?
- **Reference Answer:** Pre-diabetes (impaired fasting glucose 100–125 mg/dL or HbA1c 5.7–6.4%) is a reversible state. ICMR evidence demonstrates: (1) Achieving a 7% reduction in total body weight lowers progression risk by 58%; (2) At least 150 minutes of weekly moderate-intensity exercise (e.g., brisk walking); (3) Eliminating sugar-sweetened beverages and ultra-processed snacks; (4) Screening glucose annually. Pharmacological therapy is reserved for select high-risk patients upon medical advice only.
- **Evaluation Criteria:**
  1. Quantifies clinical thresholds for pre-diabetes.
  2. Cites the 7% weight loss / 58% risk reduction benchmark.
  3. Details 150 min/week exercise regimen.
  4. Recommends regular diagnostic re-screening.

#### Q08 (DM)
- **Question:** What is the significance of microalbuminuria in a diabetic patient?
- **Reference Answer:** Microalbuminuria (urinary albumin-to-creatinine ratio between 30 and 300 mg/g) is the earliest clinical indicator of diabetic nephropathy (kidney microvascular injury) as well as a potent independent marker of systemic cardiovascular risk. Annual urine ACR screening is recommended. Detection warrants aggressive blood pressure optimization (target < 130/80 mmHg), strict glycaemic control, and nephrology consultation.
- **Evaluation Criteria:**
  1. Correctly defines microalbuminuria threshold (30–300 mg/g).
  2. Connects finding to diabetic nephropathy and cardiovascular risk.
  3. Recommends annual urinary albumin screening.
  4. Emphasizes blood pressure and glycaemic management.

---

### Domain 2: Hypertension and Cardiovascular Disease (HT)

#### Q09 (HT)
- **Question:** What is considered a high blood pressure reading and when should I see a doctor?
- **Reference Answer:** According to ICMR and Indian hypertension guidelines: Normal BP is < 120/80 mmHg; Elevated is 120–129/<80 mmHg; Stage 1 Hypertension is 130–139/80–89 mmHg; Stage 2 Hypertension is ≥ 140/90 mmHg. Hypertensive Crisis is defined as systolic > 180 and/or diastolic > 120 mmHg. A physician consultation is warranted if readings repeatedly exceed 130/80 mmHg on two separate visits. Emergency evaluation is needed immediately if BP > 180/120 mmHg or if accompanied by neurological/cardiac symptoms.
- **Evaluation Criteria:**
  1. Accurately provides guideline classification categories.
  2. Identifies ≥ 130/80 or ≥ 140/90 as threshold for clinical consultation.
  3. Clearly flags hypertensive crisis (> 180/120 mmHg).
  4. Notes requirement for repeated confirmed readings.

#### Q10 (HT)
- **Question:** What dietary changes can help lower my blood pressure naturally?
- **Reference Answer:** Dietary approaches based on DASH and ICMR guidelines include: (1) Sodium restriction: limit daily intake to < 2000 mg sodium (< 5g of common table salt), avoiding papads, pickles, and packaged snacks; (2) Potassium enhancement: consume fresh fruits and vegetables (bananas, spinach, tomatoes, coconut water in moderation); (3) Whole grains and low-fat dairy; (4) Minimizing saturated fats; (5) Restricting alcohol and eliminating tobacco. These modifications can lower systolic BP by 8–14 mmHg.
- **Evaluation Criteria:**
  1. States salt limit (< 5g salt / < 2g sodium daily).
  2. Cites DASH pattern and potassium-rich foods.
  3. Notes culturally specific sodium sources (pickles, papads).
  4. Mentions expected systolic benefit (8–14 mmHg).

#### Q11 (HT)
- **Question:** My blood pressure is 160/100 mmHg. What should I do right now?
- **Reference Answer:** A reading of 160/100 mmHg corresponds to Stage 2 Hypertension. Immediate steps: (1) Sit in a quiet room, rest calmly for 5–10 minutes, and repeat the measurement; (2) If asymptomatic, schedule a medical appointment today or tomorrow for physician evaluation; (3) Do NOT ingest unprescribed antihypertensives; (4) If this reading is accompanied by red-flag symptoms—chest heaviness, shortness of breath, severe headache, blurred vision, or numbness—call 112 or proceed immediately to the nearest emergency department.
- **Evaluation Criteria:**
  1. Identifies Stage 2 classification.
  2. Recommends resting and repeating measurement.
  3. Forbids self-medication.
  4. Identifies emergency red flags warranting immediate hospital care.

#### Q12 (HT)
- **Question:** What is the relationship between hypertension and stroke risk?
- **Reference Answer:** Hypertension is the primary modifiable risk factor for both ischaemic (clot-induced) and haemorrhagic (vessel rupture) strokes. Chronic high pressure damages vascular endothelium, accelerates atheroma formation, and weakens cerebral arteriolar walls. Consistent blood pressure control to guideline targets (< 130/80 mmHg) reduces cumulative stroke incidence by 35% to 40%.
- **Evaluation Criteria:**
  1. Identifies hypertension as foremost modifiable stroke risk factor.
  2. Distinguishes ischemic and hemorrhagic stroke mechanisms.
  3. Quantifies risk reduction with treatment (approx 35–40%).
  4. Recommends medication adherence and BP tracking.

#### Q13 (HT)
- **Question:** Can exercise lower blood pressure, and if so, what type of exercise should I do?
- **Reference Answer:** Regular physical exercise produces sustained reductions of 5–8 mmHg in resting systolic blood pressure. ICMR and WHO recommend: (1) 150 minutes weekly of moderate aerobic exercise (brisk walking, cycling, light jogging, swimming); (2) 2–3 sessions weekly of moderate resistance training; (3) Avoid heavy isometric straining (e.g., maximal weightlifting) which causes acute BP spikes; (4) Avoid vigorous exercise if baseline BP is unmanaged (> 180/110 mmHg) until cleared by a doctor.
- **Evaluation Criteria:**
  1. Quantifies BP reduction (5–8 mmHg).
  2. Specifies 150 min/week moderate aerobic activity.
  3. Recommends dynamic resistance training over extreme isometric lifting.
  4. Provides safety threshold for withholding strenuous exertion.

#### Q14 (HT)
- **Question:** What are the warning signs of a heart attack that I should never ignore?
- **Reference Answer:** Acute myocardial infarction warning signs: (1) Squeezing, crushing, or heavy substernal chest pressure radiating to left arm, neck, jaw, or epigastrium; (2) Unexplained shortness of breath; (3) Cold sweating, nausea, lightheadedness; (4) Atypical signs common in women and diabetics (isolated jaw pain, back pain, profound fatigue). ACTION: Call 112 immediately. Do not attempt to drive yourself. Rest in a comfortable seated position while awaiting emergency services.
- **Evaluation Criteria:**
  1. Details classic substernal radiating chest symptoms.
  2. Mentions atypical presentations (women, diabetics).
  3. Directs urgent emergency contact (112).
  4. Forbids delayed self-monitoring or driving oneself.

---

### Domain 3: Respiratory Pathophysiology & AQI (RA)

#### Q15 (RA)
- **Question:** What is the Air Quality Index (AQI) and how does it affect respiratory health?
- **Reference Answer:** The CPCB National AQI is a 6-tier composite index (0–500) tracking pollutants including PM2.5, PM10, NO2, SO2, and CO. Categories: Good (0–50), Satisfactory (51–100), Moderate (101–200), Poor (201–300), Very Poor (301–400), Severe (> 400). Fine particulate matter (PM2.5) penetrates terminal bronchioles and alveoli, triggering airway inflammation, bronchospasm in asthmatics, acute COPD exacerbations, and translocating into systemic circulation.
- **Evaluation Criteria:**
  1. Explains the CPCB 6-category scale.
  2. Identifies PM2.5 and PM10 as key particulate drivers.
  3. Explains physiological mechanism of deep alveolar deposition.
  4. Identifies vulnerable patient populations (asthma, COPD).

#### Q16 (RA)
- **Question:** Today's AQI is 280 (Poor). I have asthma — what precautions should I take?
- **Reference Answer:** An AQI of 280 (Poor) carries significant risk of acute bronchoconstriction and exacerbation for asthmatic patients. Recommended measures: (1) Avoid outdoor exertion, running, and morning walks; (2) Keep residential windows closed during peak pollution hours; run a HEPA air purifier if possible; (3) Wear a certified N95 respirator if stepping outside; (4) Ensure your rapid-acting rescue inhaler is carried at all times; (5) Maintain strict compliance with prescribed controller (inhaled corticosteroid) medications; (6) Consult your physician if rescue inhaler use exceeds 3 times within 24 hours.
- **Evaluation Criteria:**
  1. Identifies AQI 280 as dangerous for chronic airway disease.
  2. Advises avoiding outdoor physical activity.
  3. Recommends N95 mask usage.
  4. Stresses preventer inhaler compliance and carrying rescue medication.

#### Q17 (RA)
- **Question:** What is the difference between asthma and COPD?
- **Reference Answer:** While both are chronic obstructive pulmonary disorders, their etiologies and reversibility diverge: (1) Reversibility: Asthma features largely reversible airway obstruction (post-bronchodilator spirometry improves > 12% and 200 mL), whereas COPD shows irreversible or partially reversible airflow limitation (post-bronchodilator FEV1/FVC < 0.70); (2) Etiology: Asthma often begins in childhood and has an allergic/atopic component; COPD typically emerges past age 40 secondary to chronic cigarette smoking or domestic biomass fuel smoke exposure; (3) Symptoms: Asthma symptoms fluctuate with specific triggers; COPD features progressive chronic dyspnoea and productive cough.
- **Evaluation Criteria:**
  1. Distinguishes reversibility using spirometric concepts.
  2. Contradistinguishes etiologies (atopy vs tobacco/biomass smoke).
  3. Outlines age differences and disease progression patterns.
  4. Recommends spirometry for definitive diagnostic workup.

#### Q18 (RA)
- **Question:** My 8-year-old child has been coughing continuously for 3 weeks. Could it be asthma?
- **Reference Answer:** A continuous cough exceeding 3 weeks in a paediatric patient is classified as a chronic cough and requires in-person paediatric evaluation. Asthma is a leading consideration—particularly if the cough is nocturnal, triggered by cold air or exercise, or accompanied by an audible expiratory wheeze. Other differential diagnoses include post-viral cough, allergic rhinitis with post-nasal drip, sinusitis, and whooping cough. Please schedule an evaluation with a paediatrician. Do not administer over-the-counter adult bronchodilators without prescription.
- **Evaluation Criteria:**
  1. Classifies duration (> 3 weeks) as chronic cough requiring clinical evaluation.
  2. Highlights typical paediatric asthma characteristics (nocturnal, trigger-dependent).
  3. Lists differential diagnoses.
  4. Warns against self-medication with adult inhalers/syrups.

#### Q19 (RA)
- **Question:** What is a peak flow meter and how does an asthmatic patient use it?
- **Reference Answer:** A peak flow meter is a portable mechanical device measuring Peak Expiratory Flow Rate (PEFR)—the maximum velocity of air forced out of lungs. Technique: (1) Set sliding marker to zero; (2) Stand upright; (3) Inhale to total lung capacity; (4) Seal lips tightly around mouthpiece without blocking with tongue; (5) Blow out as hard and fast as possible; (6) Repeat 3 times and record the highest reading. Zones: Green (> 80% personal best = good control); Yellow (50–80% = caution, escalate controller per Asthma Action Plan); Red (< 50% = medical emergency, administer rescue inhaler and seek urgent care).
- **Evaluation Criteria:**
  1. Explains PEFR measurement principle.
  2. Details accurate technique (take best of 3 trials).
  3. Defines the Green/Yellow/Red traffic light zones.
  4. Formulates red zone emergency protocol.

#### Q20 (RA)
- **Question:** Are N95 masks effective against PM2.5 pollution? How should I use them correctly?
- **Reference Answer:** Yes, certified N95 respirators filter ≥ 95% of airborne particulates down to 0.3 microns, rendering them highly effective against PM2.5 pollutants. Correct usage: (1) Ensure a tight facial seal; facial hair impairs efficiency; (2) Perform user seal check upon donning (gentle exhale/inhale to verify no edge leakage); (3) Cloth and standard surgical masks provide inadequate filtration against fine PM2.5; (4) Discard when physically deformed, soiled, or breathing resistance increases; (5) Patients with severe COPD or heart failure should check with their pulmonologist before prolonged wear due to increased breathing work.
- **Evaluation Criteria:**
  1. Validates ≥ 95% particulate filtration efficiency down to 0.3 µm.
  2. Details facial seal requirements and limitations of cloth/surgical masks.
  3. Outlines disposal/replacement guidelines.
  4. Notes respiratory resistance considerations for severe pulmonary disease.

---

### Domain 4: Nutritional Anemia & Lifestyle Health (NA)

#### Q21 (NA)
- **Question:** What are the common symptoms of iron deficiency anaemia?
- **Reference Answer:** Iron deficiency anaemia (IDA) impairs oxygen delivery to peripheral tissues, leading to: (1) Generalized fatigue, lethargy, and reduced exercise tolerance; (2) Pallor of conjunctivae, tongue, palms, and nail beds; (3) Exertional dyspnoea and palpitations; (4) Lightheadedness and orthostatic dizziness; (5) Brittle nails with koilonychia (spoon nails); (6) Angular cheilitis and atrophic glossitis; (7) Pica (unusual cravings for non-nutritive substances like clay, ice, chalk). Diagnosis requires confirmation via CBC and serum ferritin.
- **Evaluation Criteria:**
  1. Lists systemic symptoms (fatigue, dyspnea, pallor).
  2. Identifies clinical signs (koilonychia, angular cheilitis, pica).
  3. Specifies diagnostic blood investigations (CBC, ferritin).
  4. Recommends medical investigation into root causes.

#### Q22 (NA)
- **Question:** What Indian foods are rich in iron and how can I improve iron absorption?
- **Reference Answer:** Non-haem iron Indian dietary sources: green leafy vegetables (drumstick leaves/moringa, palak, methi), whole pulses and legumes (chana, rajma, horse gram/kulthi), millets (bajra, ragi), jaggery, sesame seeds (til), and dry fruits (dates, raisins). Absorption enhancers: pair meals with Vitamin C (fresh lemon juice over dal, amla, guava, oranges). Absorption inhibitors: avoid consuming tea, coffee, or calcium/dairy within 1 hour of meals, as tannins and polyphenols bind iron and inhibit uptake. Sprouting and fermenting grains degrades phytates and boosts bio-availability.
- **Evaluation Criteria:**
  1. Identifies culturally relevant Indian plant iron sources (moringa, bajra, pulses).
  2. Explains Vitamin C synergy for non-haem iron uptake.
  3. Identifies inhibitors (tea, coffee, calcium).
  4. Recommends culinary preparation techniques (sprouting, soaking).

#### Q23 (NA)
- **Question:** What is a healthy BMI range for Indian adults and why does BMI matter?
- **Reference Answer:** For Indian adults, the consensus guidelines established by ICMR and WHO South-East Asia specify lower cut-offs due to higher proportional body fat and visceral adiposity at comparable weights: Underweight (< 18.5 kg/m²); Normal weight (18.5–22.9 kg/m²); Overweight (23.0–24.9 kg/m²); Obese (≥ 25.0 kg/m²). This contrasts with Western thresholds (where obesity is ≥ 30). Waist circumference should also be maintained (< 90 cm for men, < 80 cm for women) to mitigate risks of Type 2 diabetes, metabolic syndrome, and atherosclerotic CVD.
- **Evaluation Criteria:**
  1. Cites correct Asian-Indian specific BMI categories (normal: 18.5–22.9, obese: ≥ 25).
  2. Explains physiological rationale (higher visceral adiposity/metabolic risk).
  3. Cites waist circumference thresholds (< 90 cm male, < 80 cm female).
  4. Connects visceral adiposity to non-communicable disease risk.

#### Q24 (NA)
- **Question:** How many hours of sleep should an adult get and what are the health consequences of sleep deprivation?
- **Reference Answer:** Healthy adults (18–64 years) require 7 to 9 hours of restorative sleep each night. Chronic sleep restriction (< 6 hours nightly) produces significant systemic harm: (1) Metabolic dysregulation: impairs glucose tolerance, blunts leptin, and elevates ghrelin, driving weight gain and Type 2 diabetes; (2) Cardiovascular strain: sustained elevation of sympathetic tone, increasing risk of hypertension and stroke; (3) Immune suppression: reduced natural killer cell activity; (4) Cognitive deficits: impaired executive function, slower reaction time, and heightened mood disorders.
- **Evaluation Criteria:**
  1. Specifies 7–9 hour target for adults.
  2. Explains metabolic consequences (insulin resistance, leptin/ghrelin imbalance).
  3. Cites cardiovascular and immune impacts.
  4. Recommends sleep hygiene measures.

#### Q25 (NA)
- **Question:** What is Vitamin D deficiency and how common is it in India?
- **Reference Answer:** Vitamin D deficiency is defined as serum 25(OH)D < 20 ng/mL (< 50 nmol/L). In India, despite ample geographic sunshine, prevalence reaches 70% to 90% across rural and urban demographics. Causes include skin melanin filtering UV-B, modest clothing coverage, predominantly indoor occupations, and atmospheric aerosol pollution. Consequences include rickets in children, osteomalacia/osteoporosis and muscle weakness in adults, and blunted immune defenses. Moderate mid-day sun exposure (15–20 minutes) and physician-directed therapeutic oral supplementation are standard management.
- **Evaluation Criteria:**
  1. Quantifies clinical deficiency threshold (< 20 ng/mL).
  2. Cites high national prevalence (70–90%).
  3. Explains Indian sunshine paradox (melanin, clothing, indoor work, pollution).
  4. Delineates musculoskeletal and systemic consequences.

#### Q26 (NA)
- **Question:** Is it safe to do intense exercise during pregnancy?
- **Reference Answer:** For women with uncomplicated pregnancies, moderate physical exercise is safe and strongly beneficial (150 minutes weekly of brisk walking, prenatal yoga, stationary cycling, or swimming). However, high-intensity exertion (maximal weightlifting, hot yoga, competitive contact sports, activities with fall risks, or supine exercises in the 2nd/3rd trimesters) is generally not recommended unless under specialized sports-medicine and obstetric supervision. Absolute contraindications to exercise: vaginal bleeding, fluid leakage, dizziness, chest pain, or contractions. Obstetrician clearance is essential before starting or intensifying any pregnancy exercise plan.
- **Evaluation Criteria:**
  1. Distinguishes safe moderate exercise from risky high-intensity exercise.
  2. Lists safe activities (walking, prenatal yoga, swimming).
  3. Outlines absolute stop/red-flag signs.
  4. Mandates obstetrician consultation.

---

### Domain 5: General Preventive Health & Screening (PH)

#### Q27 (PH)
- **Question:** What vaccines are recommended for adults in India and how often should they be taken?
- **Reference Answer:** Adult immunization protocols endorsed by ICMR, API, and WHO include: (1) Influenza: annual vaccination, prioritized for adults > 65 years and those with diabetes, COPD, or chronic heart disease; (2) Pneumococcal (PCV15/20 followed by PPSV23): for adults ≥ 65 or younger adults with immunocompromising or chronic conditions; (3) Tetanus-Diphtheria (Td/Tdap): booster every 10 years; (4) Hepatitis B: 3-dose series for unimmunized adults; (5) HPV vaccine: for females up to age 26 (and select adults up to 45); (6) Herpes Zoster (Shingrix): 2 doses for adults ≥ 50. Discuss a personalized immunization schedule with your general physician.
- **Evaluation Criteria:**
  1. Mentions annual influenza vaccine for high-risk cohorts.
  2. Cites pneumococcal vaccine for chronic conditions / seniors.
  3. Specifies 10-year Td booster.
  4. Notes Hepatitis B and HPV where indicated.

#### Q28 (PH)
- **Question:** At what age should women start getting cervical cancer screening (Pap smear) in India?
- **Reference Answer:** Under ICMR and National Cancer Screening guidelines, routine cervical cancer screening should commence at age 30 (or earlier if indicated by sexual history) and continue through age 65. Recommended modalities: (1) Visual Inspection with Acetic Acid (VIA) every 5 years in primary care settings; OR (2) Conventional Pap smear cytology every 3 years; OR (3) High-risk HPV DNA testing every 5 years. Women who have received the HPV vaccine must still undergo routine screening. Free screening is accessible at Government Community Health Centres under the NPCDCS programme.
- **Evaluation Criteria:**
  1. Cites initiation age of 30 years (or guideline-compliant range).
  2. Describes screening frequency (Pap smear every 3 years / HPV DNA every 5 years).
  3. Notes that HPV vaccination does not replace screening.
  4. Mentions primary health programme availability.

#### Q29 (PH)
- **Question:** What is the recommended daily water intake and what are signs of dehydration?
- **Reference Answer:** ICMR dietary guidelines recommend approximately 2.0 to 3.0 litres of fluid daily for healthy Indian adults under temperate conditions, with higher requirements in hot climates or during sustained physical exertion. Clinical signs of dehydration: Mild/Moderate: thirst, dark amber urine, dry oral mucosa, fatigue, headache, and decreased urine frequency; Severe: tachycardia, hypotension, sunken eyes, skin tenting, dizziness, and cognitive confusion. For acute dehydration secondary to gastrointestinal loss, WHO-formulated Oral Rehydration Salts (ORS) in clean water are recommended over plain water.
- **Evaluation Criteria:**
  1. States guideline intake (2.0–3.0 L/day).
  2. Classifies mild, moderate, and severe dehydration signs.
  3. Recommends ORS for fluid/electrolyte loss.
  4. Notes climate/exertion adjustments.

#### Q30 (PH)
- **Question:** How can I tell if a mole or skin lesion might be skin cancer? What should I look for?
- **Reference Answer:** Use the ABCDE clinical rule to evaluate suspect cutaneous lesions: (1) A — Asymmetry (one half does not match the other); (2) B — Border irregularity (scalloped, ragged, or poorly defined margins); (3) C — Colour variation (shades of brown, black, white, red, or blue); (4) D — Diameter (> 6 mm, approximately the width of a pencil eraser); (5) E — Evolving (any noticeable progression in size, contour, elevation, bleeding, or itching). Any persistent non-healing ulcer exceeding 4 weeks warrants biopsy and review by a dermatologist.
- **Evaluation Criteria:**
  1. Correctly articulates the complete ABCDE criteria.
  2. Specifies the 6 mm diameter guideline.
  3. Emphasizes evolutionary changes (itching, bleeding, growth).
  4. Directs to dermatology review rather than topical self-care.

#### Q31 (PH)
- **Question:** What are the health risks of tobacco use and how can I quit smoking?
- **Reference Answer:** Tobacco in all forms (cigarettes, bidis, gutka, khaini) is a leading cause of preventable mortality in India. Risks include: oral cavity and lung cancers, cardiovascular infarction, chronic bronchitis, peripheral vascular disease, and adverse pregnancy outcomes. Cessation framework: (1) Behavioral counselling: the 5 A’s approach (Ask, Advise, Assess, Assist, Arrange); (2) Pharmacotherapy under medical advice: Nicotine Replacement Therapy (NRT gum, lozenges, transdermal patches), or prescription non-nicotine agents (bupropion, varenicline); (3) National Quitline support: call 1800-11-2356 (toll-free) or text 'QUIT' to 56300 for Government mCessation assistance.
- **Evaluation Criteria:**
  1. Highlights smoked and smokeless tobacco burdens in India.
  2. Delineates multi-system morbidities (oral cancer, CVD, COPD).
  3. Details dual approach (NRT/pharmacotherapy + behavioral).
  4. Provides national cessation quitline resource (1800-11-2356).

#### Q32 (PH)
- **Question:** What is the correct handwashing technique and when should I wash my hands?
- **Reference Answer:** Hand hygiene per WHO 6-step protocol: Wet hands with clean running water, apply adequate soap, lather vigorously for at least 20 seconds covering palm-to-palm, backs of hands, interlaced fingers, backs of fingers, thumbs, and fingernails/fingertips, rinse thoroughly, and dry with a clean or disposable towel. Critical moments: before preparing/eating food; after using toilet; after coughing, sneezing, or blowing nose; after handling animal waste; and after caring for an ill individual. Alcohol-based hand sanitiser (≥ 60% alcohol) is an effective alternative when hands are not visibly soiled.
- **Evaluation Criteria:**
  1. Specifies minimum duration of 20 seconds.
  2. Outlines multi-step friction technique.
  3. Enumerates critical moments of hygiene.
  4. Validates ≥ 60% alcohol formulation when soap/water unavailable.

---
