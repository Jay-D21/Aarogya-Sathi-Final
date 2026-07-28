# Changelog

## 2026-10-24 (Jayesh — Session 31: Play Store Phone Mockups & Listing Assets Suite)
- [Jayesh] Generated photorealistic smartphone frames around real application screenshots:
  - Upgraded Feature Graphic (`1024x500` PNG/JPEG) with dual phone mockups showcasing Home Dashboard + AI Chat alongside ICMR value proposition copy.
  - Generated complete 5-asset Google Play Store Phone Listing Screenshots suite (`1080x2400` PNGs) with branded gradient backdrops, category badges, and descriptive promotional titles in `docs/brand/playstore_screenshots/`.
  - Synced assets to project root and `docs/brand/`.

## 2026-10-24 (Jayesh — Session 30: ASLogo.svg Full-System Brand Identity & Play Store Assets)
- [Jayesh] Deployed new Google Health Sliced Heart & Companion Logo (`ASLogo.svg`):
  - Rendered high-fidelity vector rasterizations via `@resvg/resvg-js` and PIL at 2048x2048 and 1024x1024.
  - Generated full Android Adaptive icon suite (adaptive background `#FFFFFF` + centered foreground within 66% safe zone) and legacy launcher icons across all mipmap densities (mdpi, hdpi, xhdpi, xxhdpi, xxxhdpi) via `flutter_launcher_icons`.
  - Generated multi-platform assets for iOS (`AppIcon.appiconset`), Web (`favicon.png`, `Icon-192`, `Icon-512`, maskable icons), and Windows (`app_icon.ico`).
  - Generated Play Store brand package in `docs/brand/`: 512x512 hi-res icon (`playstore_icon_512.png`/`.jpg`), 1024x500 feature graphic banner (`feature_graphic.jpg`/`.png`), and raw vector (`ASLogo.svg`).
  - Integrated in-app brand identity across `splash_screen.dart`, `login_screen.dart`, `aarogya_logo_dynamic.dart`, and `docs/privacy-policy.html` with Google Health cyan/mint/periwinkle ambient glow accents.
  - Verification: `flutter analyze`: **0 issues found**, `flutter test`: **23/23 tests passed**, compiled universal release APKs (20.5 MB arm64) and final signed Release Android App Bundle (app-release.aab, 45.5 MB) via Gradle bundleRelease with upload keystore and jarsigner verification.

## 2026-10-22 (Abhijit � Session 28: Research Paper � Full Scientific Rewrite)
- [Abhijit] Rewrote `paper/paper.md` following `scientific-writing` skill (IMRAD, IEEE, flowing prose):
  - All sections written in full flowing paragraphs � zero bullet points in body text.
  - Proper IMRAD structure: Abstract, Introduction, Related Work, System Architecture, Implementation, Evaluation, Discussion, Limitations, Timeline, Conclusion.
  - 6 rendered PNG figures with full academic captions (Fig. 1�6).
  - 6 self-explanatory tables with numbered captions (Table 1�6).
  - Gap analysis placed in Introduction (Table 1) for immediate impact.
  - Related Work expanded with proper gap statement bridging to this work.
  - Contributions stated in flowing prose (not numbered list).
  - Research Objectives (O1�O5) embedded in Introduction paragraph.
  - IEEE-format references with full author lists, journal abbreviations, DOIs.
  - 305 lines, ~6,289 words � targets ~11 pages in IEEE double-column with figures.
  - Past tense for methods/results, present tense for established facts.
  - Original 938-line version preserved as `paper/paper_original_backup.md`.
- [Abhijit] Completely restructured `paper/paper.md` from 938 lines (~11,135 words) to 343 lines (~4,307 words):
  - Converted from documentation-style to professional academic proposal format (10-11 pages in IEEE double-column with figures).
  - Replaced all ASCII box diagrams with proper Figure references to 6 pre-rendered PNG assets in `docs/diagrams/images/`.
  - Consolidated 27 tables down to 6 high-impact tables: Gap Analysis, RAG Comparison, Tech Stack, Evaluation Results, ReAct vs Traditional RAG, and Project Timeline.
  - Added proposal-grade sections: Research Objectives (O1-O5), Project Timeline and Team Contribution (Table 6), formal problem statement with gaps.
  - Removed Appendix A (AI/ML Skill Matrix) and Appendix B (Feasibility Analysis) � content folded into main body where relevant.
  - Eliminated redundant tech stack listings and verbose implementation prose.
  - Preserved all 30 IEEE-format references with DOIs and arXiv IDs.
  - Backed up original as `paper/paper_original_backup.md`.
- [Abhijit] Context files updated: `changelog.md`.

## 2026-10-19 (Ritesh — Session 27: Final Interim Report Publication, Table Numbering & Compact High-Legibility Diagrams)
- [Ritesh] Completed final Review 2 Interim Report formatting in `Aarogya_Sathi_Interim_Report_Review_Final.docx`, `docs/Aarogya_Sathi_Interim_Report_Review_Final.docx`, and `docs/interim_report_review2.md`:
  - Enforced low-AI student voice, single-app problem statement, and 42 IEEE citations.
  - Added formal numbered academic captions to all tables: Table 2.1 (Gap Analysis), Table 3.1 (Tech Stack), Table 4.1 (AgentState Schema), Table 5.1 (Benchmark Evaluation).
  - Inserted missing Chapter 6 sections: Section 6.2 (Team Contributions) with Table 6.1 (Work package breakdown for Jayesh Patil, Abhijit Patil, Ritesh Pawar), and Section 6.3 (Module Status) with Table 6.2.
  - Added formal front matter catalogs: `LIST OF TABLES` and `LIST OF FIGURES` directly following Table of Contents.
  - Re-rendered all 8 architecture diagrams into clean, compact, modular formats (max height <= 3.5", width <= 4.8") to eliminate the faculty's "too far away" zoomed-out feedback and ensure 100% readability without page overflow.
  - Added Figure 4.5 in Section 4.3 for ICMR Knowledge Bundle Open Knowledge Format (OKF) concept hierarchy & hyperlink cross-references.
  - Cleaned repository untracked media and added temporary dumps to `.gitignore`.

## 2026-10-19 (Abhijit — Session 26: Repository Context Synchronization & Auto-Sync Loop)
- [Abhijit] Synchronized local repository with remote `origin/main` (`d0e5351..4addea0`):
  - Ingested Play Store beta launch preparation (`com.aarogyasathi.app`, signing block, DPDP web privacy policy).
  - Ingested Google Health & Google Drive UI redesign (9 reusable Material 3 Expressive widgets).
  - Ingested mock data purge and dynamic vitals engine across Home Screen and Health Dashboard.
- [Abhijit] Updated project context files across all levels per `.agents/AGENTS.md` permanent memory rules:
  - `.context/contributors/dev-abhijit.md`: Documented Session 23 Gold mandala splash transition, launcher icon generation, and updated file ownership.
  - `.context/contributors/_overview.md`: Refreshed team contributor responsibilities and recent sprint achievements.
  - `.context/modules/_overview.md`: Updated Module 7 (Flutter App) to Production Polish and Module 10 (Medical File Vault) with Drive-style cards.
  - `.context/architecture/_overview.md`: Updated tech stack date (2026-10-19), `com.aarogyasathi.app` package namespace, and architectural decisions on dynamic vitals integrity and Play Store/DPDP compliance.
  - `.context/progress/_overview.md`: Re-baselined overall progress from 40% (stale) to 92% complete with accurate milestones.
  - `.context/dependencies/_overview.md`: Documented `flutter_launcher_icons` dev dependency.
  - `.context/dependencies/critical-files.md`: Populated full critical architecture file matrix with blast radius explanations.
- [Abhijit] Automated Verification:
  - `flutter analyze`: 0 issues found (ran in 83.7s).
  - `flutter test`: 23/23 tests passing cleanly.

## 2026-10-22 (Jayesh — Session 29: Proactive Health Notification System + Analyze Fixes)
- [Jayesh] Built `HealthAlertService` (`frontend/lib/services/health_alert_service.dart`, ~315 lines):
  - `checkBP(systolic, diastolic)` — ICMR thresholds: hypotension (<90), Stage 2 (≥140/90), crisis (≥180/120)
  - `checkBloodSugar(value, type)` — ICMR thresholds: hypoglycemia (<70), diabetes (≥126 fasting), critical (≥300)
  - `checkHeartRate(bpm)` — Alerts for bradycardia (<50), tachycardia (≥120), severe (≥150)
  - `checkSpO2(percent)` — Alerts for low oxygen (<94), dangerous (<90)
  - `checkAQI(aqi, station)` — CPCB thresholds: unhealthy (≥150), very poor (≥200), hazardous (≥300)
  - `pollInsights(userId, lat, lon)` — Polls backend `/api/session/{user_id}/insights` endpoint for proactive clinical observations
  - Cooldown system (60min same-type vital alerts, 30min insight polling) via SharedPreferences
  - Three Android notification channels: `aarogya_vital_alerts`, `aarogya_aqi_alerts`, `aarogya_insights`
  - Notification IDs 200001-200030 range to avoid collision with ReminderProvider
- [Jayesh] Wired alert triggers into providers:
  - `health_provider.dart`: BP and blood sugar alerts after logging
  - `fitness_provider.dart`: HR and SpO2 alerts after Health Connect sync
  - `home_screen.dart`: AQI alerts on banner load + insight polling on app open
- [Jayesh] Fixed `app_theme.dart` `directive_after_declaration` error (swapped export/import order)
- [Jayesh] Fixed `expressive_motion.dart` `invalid_constant` errors (Curves.* not compile-time constants; changed const constructors to non-const with nullable curve params)
- [Jayesh] Verification: `flutter analyze`: 0 issues, `flutter test`: 23/23 passed.

## 2026-10-21 (Jayesh — Session 28: Material 3 Expressive System & Gemini Polish)
- [Jayesh] Material 3 Expressive Design Tokens & Motion Library:
  - Updated `app_theme.dart` with True-Black Pixel Dark Mode (`#0A0E0D` scaffold, `#141B19` cards, `#1C2523` inner containers, `#66F7E2` Tone-80 luminous mint primary) and Light Mode (`#EDF3F1` scaffold, `#FFFFFF` cards, `#E3ECE9` inner containers, `#006A60` primary).
  - Created `expressive_motion.dart`: Added `SpringPressable` (tactile spring physics on tap) and `StaggeredFadeSlide` (staggered entrance animations).
- [Jayesh] AI Health Assistant Empty State & Stuck Spinner Resolution:
  - Fixed stuck spinner root cause: eliminated blocking conditions and solitary loading indicators on initial chat view so welcome state renders synchronously.
  - Gemini Expressive Empty State: ShaderMask gradient greeting (`"Hello, $userName"` in `#006A60`→`#3F5F90` light / `#66F7E2`→`#A8C8FF` dark, 32sp w800), 20sp subtitle, tonal trust pill (`"ICMR-Guided • Private On-Device"` with `Icons.verified_user_outlined`), and 2x2 Bento Starter Cards (`"Fever & headache"`, `"Daily hydration"`, `"Diabetes diet"`, `"High AQI care"`) wrapped in `SpringPressable`.
- [Jayesh] Home Screen & Metric Cards Polish:
  - Animated Daily Score Ring: Wrapped score ring and counter in `TweenAnimationBuilder<double>` (1100ms, `Curves.easeOutCubic`) for smooth arc sweep and counter animation.
  - Semantic M3 Accent Colors: Applied across submetrics and 2x2 Key Metrics Bento Grid (Steps: primary teal/mint, Active Kcal & BP: Warm Amber `#E66000`/`#FFB77C`, BPM & Blood Glucose: Coral Rose `#D9385A`/`#FF859D`, Sleep & Symptoms: Indigo/Lavender `#4F46E5`/`#A5B4FC`).
  - Unified `PremiumMetricCard`: Replaced inconsistent add icon on BP with uniform 18px `Icons.arrow_outward_rounded`, placed metric icons in `36x36` 12% opacity tonal circular containers, and wrapped in `SpringPressable`.
  - Weekly Day Bar: Added `1.5px` `outlineVariant` border to inactive day circles and `primary` border with dot to current day.
  - Settings & Profile: Cleaned up settings icons to uniform `colorScheme.onSurfaceVariant` inside `36x36` circular `colorScheme.surfaceContainer` containers.
- [Jayesh] Health Dashboard Polish:
  - Applied semantic colors across 2x2 key metrics grid.
  - Wrapped sections in `StaggeredFadeSlide`.
- [Jayesh] Verification:
  - `dart analyze lib`: **0 issues found** (clean compile).
  - `flutter test`: **23/23 tests passed**.

## 2026-10-18 (Jayesh — Session 27: Google Pixel / Gemini / Material 3 Dark & Light Mode Redesign)
- [Jayesh] Authentic Google Material 3 Color Schemes & Tonal System:
  - Overhauled Dark Mode tokens: `#0E1513` Carbon-Mint scaffold background, `#17201E` borderless `surfaceContainerLow` cards, `#212B28` `surfaceContainerHigh` tonal surfaces, and luminous `#74F8E5` (Tone-80 Google Fit mint) high-contrast primary accents.
  - Overhauled Light Mode tokens: `#F4F8F6` scaffold background, `#FFFFFF` cards, `#E6EFEC` tonal surfaces, and `#006A60` primary teal.
- [Jayesh] Borderless Architecture (Zero 1px Borders Globally):
  - Purged 1px card borders across all metric cards, hero cards, action chips, dialogs, bottom sheets, file cards, and auth cards.
  - Cards strictly rely on `colorScheme.surfaceContainerLow` with `BorderRadius.circular(24)` and `BorderSide.none`.
  - Tight 10px spacing in 2x2 Bento Grids for Google Pixel Weather/Fit aesthetic.
- [Jayesh] Screen Redesigns:
  - **HomeScreen**: Borderless Daily Score Hero Card with radius 24, ring strokeWidth 14 with score number in 44sp w800 primary mint, sub-metrics in rounded inner tonal bar (`surfaceContainerHigh` radius 18 with monochrome primary icons). Edge-to-edge scrollable quick action chip row (active chip in `primaryContainer`/`onPrimaryContainer`, others in `surfaceContainerHigh`/`onSurface`). 2x2 Bento Grid with tight 10px spacing and plain text statuses.
  - **HealthTrackingScreen**: Borderless 2x2 Bento Grid with tight 10px spacing. Removed pastel squircles; converted to 22px primary icons in 40x40 `surfaceContainerHigh` circles. Borderless Medical File Vault banner and reading tiles.
  - **AIAssistantScreen (Google Gemini Style)**: Left-aligned greeting ("Hello, $userName" in 28sp w700 primary, 20sp subtitle in `onSurfaceVariant`), flat trust pill ("ICMR-Guided • Private On-Device"), 2-column bento suggestion cards in `surfaceContainerLow` radius 20 with 18px primary icons. Unified Google Gemini bottom floating pill container (`surfaceContainerHigh`, radius 32, zero border) integrating text input, mic button, and circular 36x36 upward-arrow send button. User bubble in `primaryContainer`/`onPrimaryContainer`; AI bubble in `surfaceContainerLow`.
  - **Profile & File Vault**: Borderless section cards in `surfaceContainerLow`, tonal edit button, and borderless search bar.
- [Jayesh] Verification & Cleanliness:
  - `dart analyze lib`: **0 issues found** (clean compile, no warnings, no dead code).
  - `flutter test`: **23/23 tests passed**.

## 2026-10-16 (Jayesh — Session 26: Material 3 / Google Fit Production Overhaul for Play Store Beta)
- [Jayesh] Phase 1: Design System & Strict Material 3 Tonal Surfaces:
  - Standardized palette: `scaffoldBackgroundColor: #F5F8F7`, surface cards: `#FFFFFF` with elevation 0 and no border/shadow clash, `secondaryTonal: #EAF1EF`, `primaryAccent: #006A60`, `primaryContainer: #D0EFEA`, and emergency tokens `#FCEEEE/#B3261E`.
  - Purged all pastel squircle icon backgrounds and raw system emojis (`🤒`, `💧`, `🍽️`, `😷`, `💊`, `🩺`, `🔒`) across UI components.
- [Jayesh] Phase 2: Screen-by-Screen Overhauls:
  - **HomeScreen**: Pinned `SliverAppBar` with `scrolledUnderElevation: 0` to prevent status bar collision. Hero daily score card with centered ring gauge and 3-column stats (`Steps`, `Active Kcal`, `BPM`) with BMR calorie fix. Replaced clipped action row with `SingleChildScrollView` M3 `ActionChip` row. Clean 2x2 grid (`Heart Rate`, `Sleep`, `Weight`, `Blood Pressure`). Removed redundant "Health Status" banner and duplicate File Vault card.
  - **HealthTrackingScreen**: Removed redundant "No vitals logged yet" card, duplicate "+ Log" links, and clipping chip bar. Added bottom-right M3 `FloatingActionButton.extended` ('Log Vitals') with modal sheet logger. Added subtle `add_circle_outline` icon to key metric cards.
  - **AIAssistantScreen**: Removed purple/indigo gradient; replaced with teal tonal circle container and teal icons. Replaced 4 feature buttons with single non-interactive subtitle: `"ICMR-Guided • AQI-Aware • Private On-Device"`. Converted emoji suggestion cards to monochrome outline icon cards with north-east arrows. Added persistent 11px Play Store medical disclaimer above chat input bar.
  - **ProfileScreen**: Converted vertical card to horizontal header (64px avatar, user name, email/guest status, city). Clean 3-column tonal bar (`BMI`, `Height`, `Weight`), full-width tonal "Edit Health Profile" button. Replaced "Change Password" with "Sign In / Create Account" for guest users. Added "View Privacy Policy" web launcher and destructive "Delete Account & Local Data" wipe action.
- [Jayesh] Phase 3: Workflows & Verification:
  - Updated `.github/workflows/keep-alive.yml` curl to `--max-time 90 --retry 3`.
  - Added dummy API keys to `.github/workflows/backend-ci-cd.yml` test and docker build steps.
  - Verified `flutter analyze`: **0 issues found**.
  - Verified `flutter test`: **23/23 tests passed**.

## 2026-10-14 (Jayesh — Session 25: Mock Data Purge & Premium UI Polish)
- [Jayesh] Purged hardcoded & mock health data across Home Screen & Health Dashboard:
  - Fixed `HealthSummaryBanner`: Dynamically checks real user records (`lastBPStatus`, `lastSugarStatus`, wearable heart rate, sleep, steps) instead of hardcoding `5 of 5 in range`. Added zero-state banner ("No vitals logged yet today") with fast "+ Log" action.
  - Fixed `Key metrics` on HealthDashboard & HomeScreen: Removed fake `120/80` BP and `95 mg/dL` glucose with fake sparkline waves when no readings are recorded. Now renders honest `--/--` with "Tap to log" and disables synthetic sparklines.
  - Fixed Heart Rate & Sleep cards: Removed fake `72 bpm` and `7.2 hrs` defaults; now properly displays `--` with sync/log status prompts.
  - Fixed Weekly Consistency: Computed active days dynamically based on actual pedometer activity rather than hardcoding `5 of 7 days`.
  - Fixed Weight & BMI: Dynamically calculates Asian-specific ICMR BMI ranges (`Low`, `Normal`, `Over`, `High`) based on actual profile attributes.
  - Fixed Symptoms metric: Shows genuine recorded symptoms count rather than synthetic "Optimal / No active alarms".
  - Fixed infinite AQI loader: Added strict location & API timeouts with automatic CPCB NAQI clean-air baseline fallback to eliminate endless spinner.
  - Upgraded Design System (`theme.dart`): Transformed murky light mode background to crisp slate (`#F8FAFC`), modern high-contrast borders (`#E2E8F0`), and soft elevation shadows (`#0F172A` at 4% alpha).
  - Redesigned Chat empty state (`chat_screen.dart`): Replaced clip-art brain icon with glowing Google-grade AI spark avatar, elevated suggestion cards with rounded action pills, and eliminated empty dead space.
- [Jayesh] Verification:
  - `flutter analyze`: 0 issues found.
  - `flutter test`: 23/23 tests passing.

## 2026-10-10 (Jayesh — Session 24: Google Health & Drive UI Redesign + Play Store Beta Preparation)
- [Jayesh] Sprint 1 Play Store Blockers completed:
  - Fixed permanent Android applicationId: `com.aarogyasathi.app` in `build.gradle.kts`.
  - Configured release signing block with `key.properties` auto-detection (falls back to debug).
  - Cleaned unneeded `RECORD_AUDIO` permission from `AndroidManifest.xml`.
  - Created DPDP Act-compliant web privacy policy (`docs/privacy-policy.html`) covering all 12 Health Connect permissions.
  - Updated `.gitignore` to prevent leaking keystore files and binaries (`*.jks`, `*.keystore`, `key.properties`, `*.apk`, `*.aab`).
  - Added `key.properties.example` template.
- [Jayesh] Sprint 2 Google Health & Drive UI Redesign completed:
  - Built 9 new reusable Material 3 Expressive widgets:
    - `SectionHeader`: Clinical section title with trailing action.
    - `StatusBadge`: Pill-shaped badge ("In range", "Elevated", "Critical").
    - `MiniSparkline`: CustomPaint cubic Bezier trend line with vertical gradient fill.
    - `PremiumMetricCard`: Large metric number + status badge + sparkline chart.
    - `HealthSummaryBanner`: Google Health "Health status" card ("5 of 5 in range").
    - `WeeklyDayBar`: M T W T F S S consistency day bar with activity indicators.
    - `QuickActionChip`: Google Health pill action chips.
    - `CategoryFolderCard`: Google Drive pastel folder card for document vault.
    - `EnvironmentCard`: Integrated AQI + Weather card.
  - Redesigned `HomeScreen` (`home_screen.dart`):
    - Added Google Health "Health status" banner, quick action chips row, 2x2 key metrics grid with live sparklines, weekly target consistency day bar, and Drive-style file vault card.
  - Redesigned `HealthDashboard` (`health_dashboard.dart`):
    - Added Vitals summary banner, quick logging chips (`+ Log BP`, `+ Log Sugar`, `+ Log Weight`, `+ Log Symptoms`), and 2x2 key metric grid with longitudinal sparklines.
  - Redesigned `FileVaultScreen` (`file_vault_screen.dart`):
    - Added Google Drive storage overview card, 2x2 "My Folders" category grid with document counts, and clean file cards list.
  - Verified with `flutter analyze`: 0 issues found.
  - Verified with `flutter test`: 23/23 tests passing.

## 2026-10-03 (Abhijit — Session 23: Gold Mandala Splash Redesign & Android Launcher Icon)
- [Abhijit] Redesigned splash screen logo (`frontend/lib/screens/onboarding/splash_screen.dart`) with premium golden color palette (`#FFD400`, `#FFC300`, `#FF8C00`, `#FF5F00`) across all 5 painter layers:
  - Layer 1 (circuit ring): gold-to-teal sweep gradient; alternating gold/teal node dots
  - Layer 2 (octagram star): golden fill + gold stroke sacred geometry + pale-gold tip dots
  - Layer 3 (DNA helix): Arc 1 = gold/amber, Arc 2 = teal/cyan; alternating gold/teal rungs
  - Layer 4 (lotus petals): deep-amber → pale-gold fill gradient + gold center veins + apex dots
  - Layer 5 (center disc): pale-gold → true-gold → deep-amber radial gradient; dark amber Om glyph
- [Abhijit] Updated ambient background glows (warm gold top-right, deep amber bottom-left).
- [Abhijit] App name text shader updated to gold → warm-gold → teal gradient.
- [Abhijit] Hindi subtitle (`आरोग्य साथी`) updated to warm marigold `#FFB300`.
- [Abhijit] Loading bar updated to gold → warm-gold → teal sweep gradient.
- [Abhijit] Generated AI gold mandala logo image (exact same structure as reference — circuit orbit, octagram, DNA helix, 8-petal lotus, Om center — all in golden sunset palette on navy bg).
- [Abhijit] Added `flutter_launcher_icons ^0.14.4` dev dependency; registered `assets/images/icon.png` and `assets/images/app_logo.jpg` in `pubspec.yaml`.
- [Abhijit] Generated all 5 Android density launcher icons: mdpi (48px), hdpi (72px), xhdpi (96px), xxhdpi (144px), xxxhdpi (192px) — all replaced with gold mandala logo.
- [Abhijit] All commits pushed: `8e211ca` (gold splash colors), `64fabb3` (launcher icons + assets).
- flutter analyze: 0 errors, 0 warnings, 0 infos throughout.

## 2026-10-03 (Abhijit — Session 22: Render Production Verification, JDK 17 Migration, & Universal Release APK Compilation)
- [Abhijit] Verified live Render backend deployment (`https://aarogya-sathi-final.onrender.com`, Service ID: `srv-dai457gjo6nc73ddaggg`):
  - Confirmed `/api/health` status 200 OK (model: llama3.1-8b).
  - Confirmed `/api/aqi` status 200 OK with real-time NAQI and Open-Meteo live weather data.
  - Confirmed root endpoint `/` status 200 OK (`Aarogya Sathi API v1.0.0`).
- [Abhijit] Configured frontend API baseUrl to `https://aarogya-sathi-final.onrender.com` in `frontend/lib/config/api_config.dart`.
- [Abhijit] Resolved Gradle 8.14 JDK compatibility by installing and linking Microsoft OpenJDK 17 LTS (`C:\Program Files\Microsoft\jdk-17.0.20.101-hotspot`).
- [Abhijit] Successfully compiled universal production release APK (`frontend/build/app/outputs/flutter-apk/app-release.apk`, 57.5 MB) containing native binaries for ARM64-v8a, ARMv7, and x86_64 architectures for mass tester distribution.
- [Abhijit] Established 24/7 Keep-Warm architecture via HTTP monitor hitting `/api/health` every 10 minutes to eliminate Render free-tier cold boot delays.

## 2026-10-03 (Abhijit — Session 21: Pedometer False-Positive Hand Movement & Cadence Filter)
- [Abhijit] Resolved hardware pedometer sensitivity issue where moving the phone 20–30 times by hand while sitting at a desk falsely registered as walking steps.
- [Abhijit] Created `StepFilterService` (`frontend/lib/services/step_filter_service.dart`):
  - Integrates `Pedometer.pedestrianStatusStream` to detect stationary/stopped state.
  - Implements frequency/cadence limiting to reject rapid hand shaking (> 3.2 Hz or < 250ms per step).
  - Implements 8-step hysteresis bout validation: isolated desk fidgets (< 8 steps) are buffered tentatively and discarded after a 3-second idle timeout without incrementing steps; only continuous rhythmic walking commits to the persistent count.
- [Abhijit] Integrated into `FitnessProvider` (`frontend/lib/providers/fitness_provider.dart`), cleaning up obsolete raw baseline fields and ensuring proper stream cancellation.
- [Abhijit] Automated Verification: created `frontend/test/step_filter_test.dart` (6/6 tests passed), `flutter analyze` verified clean (0 errors, 0 warnings, 0 infos), and full test suite passed 100% (23/23 tests passed).

## 2026-10-03 (Abhijit — Session 20: Research Paper Engine Synchronization & Verification Suite Integration)
- [Abhijit] Updated `RESEARCH_CONTEXT.md` to `v1.3.0` establishing `355ef4b` as the latest git baseline following completion of all 4 frontend tasks.
- [Abhijit] Synchronized sections 1–5, 8, 9, 10 of `RESEARCH_CONTEXT.md` to document the DPDP On-Device Medical File Vault (`/medical_vault/`), Asian ICMR BMI calculation & dynamic classification, in-chat dynamic language toggle, Flutter automated testing suite (17/17 tests passing), and backend model wiring.
- [Abhijit] Appended incremental change log entry to `CHANGE_LOG.md` per Phase 2 of `research-paper-engine` protocol.
- [Abhijit] Enhanced `paper/paper.md`:
  - Updated Figure 4 (Data Flow & Privacy Architecture) to incorporate on-device sandboxed `/medical_vault/` file isolation.
  - Updated Table 11 (DPDP Act Compliance Matrix) adding sensitive file storage row.
  - Updated Table 13 (Pydantic Data Models) adding `height_cm` and `weight_kg` to `UserProfile`.
  - Expanded Section 4.3 (Frontend Implementation) prose covering on-device medical vault, Asian ICMR BMI computation, and reactive multilingual state management.
  - Restored Table 14 (Health Connect SDK Data Types) and added Table 15 (Frontend Architectural Components & State Management).
  - Renumbered Backend Module Registry to Table 16.
  - Added Table 20 (Comprehensive Automated Verification Suite — 17 unit/widget tests + backend model integration suite, 100% pass rate, zero static analysis lints).
  - Sequentially renumbered all subsequent tables through Table 25 (Summary of Contributions), plus Appendix A1 and B1 (27 tables in total).
- [Abhijit] Updated `.context/contributors/dev-abhijit.md` and `.context/modules/_overview.md`.

## 2026-10-03 (Abhijit — Session 19: Pubspec Dependency Audit & Native Package Pruning)
- [Abhijit] Pruned unused dependencies `speech_to_text: ^7.0.0` and `flutter_tts: ^3.8.3` from `frontend/pubspec.yaml`, removing unused native platform overhead and Windows C++ plugin compilation (`speech_to_text_windows`, `speech_to_text_platform_interface`, `flutter_tts`).
- [Abhijit] Ran `flutter pub get` cleanly updating `frontend/pubspec.lock`.
- [Abhijit] Updated `.context/dependencies/_overview.md` with the full specification of all 19 active frontend packages and historical documentation of removed packages (`dio`, `fl_chart`, `shimmer`, `flutter_riverpod`, `go_router`, `speech_to_text`, `flutter_tts`).
- [Abhijit] Automated Verification: `flutter analyze` reported 0 errors, 0 warnings, 0 infos (`No issues found!`), and all 17 unit and widget tests in `frontend/test/` passed cleanly (`flutter test`).

## 2026-10-03 (Abhijit — Session 18: Edit Profile Screen with Asian ICMR BMI & Conditions Management)
- [Abhijit] Created `EditProfileScreen` (`frontend/lib/screens/profile/edit_profile_screen.dart`): personal info form (First Name, Last Name, Age, Gender dropdown, City with GPS auto-detection via `LocationService.getCityName()`), dynamic Asian ICMR BMI calculation & live classification cards (Normal: 18.5–22.9, Overweight: 23–27.4, Obese: ≥27.5), chronic conditions multi-select filter chips + custom condition addition, and medications list with chip management.
- [Abhijit] Updated `AuthProvider` (`frontend/lib/providers/auth_provider.dart`): extended `updateProfile` with immediate local state sync, local persistence (`guest_profile` or `cached_user_profile`), and backend `PUT /auth/me` with offline resilience; updated `checkAuth` to load `cached_user_profile` during network disconnection.
- [Abhijit] Wired UI Navigation: registered `/edit-profile` in `main.dart`, and embedded accessible "Edit Health Profile" buttons on both the `HomeScreen` profile card and the preferences menu.
- [Abhijit] Wired RAG & Chat Integration: updated `ChatScreen` (`frontend/lib/screens/chat/chat_screen.dart`) to extract conditions, medications, height, and weight from `auth.user` and forward them in `ChatRequest.profile`.
- [Abhijit] Updated Backend Data Model: added `height_cm` and `weight_kg` to `UserProfile` in `backend/api/models.py`, enabling `backend/rag/context_builder.py` to calculate Asian ICMR BMI classification (`BMI: 27.0 → Overweight`) and inject conditions and medications into `<user_profile>` for personalized AI health advice.
- [Abhijit] Automated Verification: created `frontend/test/edit_profile_test.dart` (6/6 tests passed), updated `test/widget_test.dart` with `FileVaultProvider` and proper timer settlement (all 17 frontend tests passing cleanly), and created `scratch/test_profile_backend_wiring.py` validating backend serialization and context builder prompt formatting. `flutter analyze` verified with 0 errors, 0 warnings, and 0 infos.

## 2026-10-03 (Abhijit — Session 17: Medical File Vault Implementation & Testing)
- [Abhijit] Added `image_picker` (1.2.3) and `file_picker` (11.0.3) packages for native camera, photo gallery, and PDF report capture.
- [Abhijit] Created `MedicalFileModel` (`frontend/lib/models/medical_file_model.dart`) supporting DPDP on-device records for prescriptions, lab reports, scans, and vaccinations with file size and date formatting.
- [Abhijit] Built `FileVaultProvider` (`frontend/lib/providers/file_vault_provider.dart`) managing sandbox file persistence (`/medical_vault/`), SharedPreferences metadata indexing, category filtering, search queries, and secure deletion.
- [Abhijit] Built `FileVaultScreen` (`frontend/lib/screens/health/file_vault_screen.dart`) featuring real-time search, category filter chips, upload bottom sheet (camera/gallery/file), file details/image preview dialog, and delete confirmation.
- [Abhijit] Wired `/vault` route in `main.dart`, added settings entry in `HomeScreen`, and integrated an on-device Medical File Vault banner into `HealthDashboard`.
- [Abhijit] Automated Verification: created `frontend/test/file_vault_test.dart` (6/6 tests passed) and re-ran `language_persistence_test.dart` (4/4 passed) with zero regressions; `flutter analyze` verified with 0 errors and 0 warnings.

## 2026-10-02 (Abhijit — Session 16: Language Persistence & Full End-to-End Wiring)
- [Abhijit] Implemented reactive language persistence in `frontend/lib/providers/auth_provider.dart`: `_language` state, `languageLabel`, and `setLanguage(lang)` with `SharedPreferences` persistence (`user_language`) and user session synchronization.
- [Abhijit] Updated `HomeScreen` settings: dynamically bound language subtitle to `context.watch<AuthProvider>().languageLabel` and wired `_showLangSheet` directly to `auth.setLanguage(...)`.
- [Abhijit] Enhanced `ChatScreen`: added an interactive language switcher chip in AppBar (`EN`/`HI`/`MR`) allowing in-chat language switching, and wired `sendMessage` to pass `auth.language`.
- [Abhijit] Enhanced `ChatProvider`: fixed variable scoping for `effectiveLang`, passed `language` parameter to `_callGroqDirectly` with dedicated system prompt guidance for Hindi and Marathi.
- [Abhijit] Automated Verification: authored `frontend/test/language_persistence_test.dart` (4/4 tests passed) and created `scratch/test_language_wiring.py` confirming backend context assembly and localized greeting generation.

## 2026-10-02 (Abhijit — Session 15: Paper Enhancement with Diagrams & Tables)
- [Abhijit] Enhanced `paper/paper.md` from 298 to 710 lines (+687 insertions, +412 net new lines)
- [Abhijit] Added 23 comprehensive tables: NCD burden statistics, RAG comparison, ICMR clinical thresholds, CPCB AQI thresholds, pollutant-health impacts, competitive analysis (7 platforms × 11 features), API specs, Pydantic data models, Health Connect data types, DPDP compliance matrix, module registry, evaluation dataset, safety router results, technology stack decisions, and more
- [Abhijit] Added 5 detailed ASCII architecture diagrams: full system architecture (3-tier), agentic ReAct pipeline workflow (7 phases), data flow/privacy architecture, multi-key LLM pooling with auto-cascade, native vs translation multilingual comparison
- [Abhijit] Added Appendix A (AI/ML Skill Demonstration Matrix — 11 competencies) and Appendix B (Economic Feasibility — zero-cost development stack)
- [Abhijit] Committed and pushed: `f5c974c`

## 2026-10-02 (Abhijit — Session 14: Research Paper Engine Phase 3 & 4)
- [Abhijit] Phase 3 (Literature Search): Searched academic databases for Agentic RAG in Healthcare, Multilingual LLMs, Preventive Health ROI. Created `LITERATURE_DB.md` with 4 HIGH-relevance papers. Generated `Research/academic_literature_review.md` with thematic synthesis and gap analysis.
- [Abhijit] Phase 4 (Structured Writing): Created `paper/outline.md` (section-by-section IMRAD writing plan). Wrote complete `paper/paper.md` — full research paper with Abstract, 8 sections, architecture diagrams, comparative analysis table, and 42 IEEE-formatted references. Applied AI-ism scrubbing (no "leverage", "delve", "robust"). All manuscript sections in flowing prose paragraphs (no bullets).
- [Abhijit] Updated `RESEARCH_CONTEXT.md` to v1.2.0 with new file mappings (paper/, LITERATURE_DB.md) and fresh git baseline.
- [Abhijit] Updated `CHANGE_LOG.md` with Phase 3 and Phase 4 incremental entries per research_paper_engine skill protocol.

## 2026-10-01 (Abhijit — Session 13: Research Validation & Capstone Analysis)
- [Abhijit] Read and analyzed `literature_review.md` and `project_validation.md` from the newly pulled `Research/` directory.
- [Abhijit] Synthesized project claims mapping technical achievements (Agentic RAG, WAQI integration, IndicTrans2) to academic literature and ICMR guidelines.
- [Abhijit] Generated `research_analysis.md` artifact summarizing the 14.3:1 ROI, 43.8% RAG hallucination reduction, DPDP compliance, and competitive gap analysis for capstone presentation.

## 2026-09-30 (Jayesh — Session 12: Complete Agentic RAG Implementation & Integration)
- [Jayesh] Built `backend/rag/intent.py` with regex heuristics fast-path + 70B LLM intent fallback (greeting, health_query, vital_check, aqi_query, lifestyle)
- [Jayesh] Built `backend/rag/insights.py` proactive insights engine (elevated HR, low SpO2, Stage 1/2 BP, CPCB NAQI threshold warnings, and vital delta trends)
- [Jayesh] Built `backend/rag/tools.py` modular tools (`tool_search_knowledge`, `tool_analyze_vitals`, `tool_get_environmental_data`)
- [Jayesh] Built `backend/memory/session.py` per-user session memory manager with disk persistence (`data/sessions/{user_id}.json`)
- [Jayesh] Upgraded `backend/rag/pipeline.py` to Agentic ReAct flow: short-circuits greetings, selects tools by intent, injects proactive insights and longitudinal memory
- [Jayesh] Added `user_id` to `ChatRequest` model and added `/api/session/{user_id}/insights` endpoint to `backend/api/routes.py`
- [Jayesh] Updated Flutter `chat_provider.dart` to automatically send `user_id` and load saved `user_language`
- [Jayesh] Fixed language sheet in `home_screen.dart` with persistent `SharedPreferences` storage and active radio indicators
- [Jayesh] Wired DPDP compliance info dialogs to previously empty 'Privacy Settings' and 'Terms' tiles in `home_screen.dart`
- [Jayesh] Removed dead dependencies (`dio`, `fl_chart`, `shimmer`) from `frontend/pubspec.yaml`
- [Jayesh] Ran integration test confirming intent classification, proactive insights generation, and session persistence

## 2026-09-30 (Jayesh — Session 11: Multi-Key Pooling, Native Hinglish, Context Polishing & Agentic Roadmap)
- [Jayesh] Implemented comma-separated multi-key pooling with round-robin rotation & auto-429 rotation across Groq and Sarvam AI (`llm.py`, `bhashini.py`)
- [Jayesh] Configured Render production environment variables and switched Flutter app `api_config.dart` from emulator to production URL
- [Jayesh] Bypassed Sarvam translation during chat by prompting Qwen 27B to natively understand and reply in Hindi/Marathi/Hinglish/Minglish (saving 100% of credits)
- [Jayesh] Enforced conversational brevity in `context_builder.py` (2-3 sentences for greetings, max 4-5 bullet points, 400 token ceiling, caring companion tone)
- [Jayesh] Disambiguated nearest WAQI monitoring station name from the user's actual GPS city in LLM prompt
- [Jayesh] Conducted comprehensive Flutter frontend and FastAPI backend feature audits
- [Jayesh] Formulated the Agentic RAG ReAct architecture plan and updated team sprint assignments in `HANDOFF.md`

## 2026-09-27 (Jayesh — Session 10: Audit + Cleanup + Honest README)
- [Jayesh] Full project state audit — discovered 0 commits from team since Sep 21
- [Jayesh] Rewrote README.md to match reality (removed false claims: Ollama, Qdrant, BGE-M3, LangChain, Bhashini, RAGAS)
- [Jayesh] Cleaned requirements.txt — removed 6 unused deps (langchain, langchain-groq, langchain-community, langgraph, pyyaml, ragas)
- [Jayesh] Fixed backend/.env — replaced stale Bhashini vars with SARVAM_API_KEY that code actually reads
- [Jayesh] Noted: Groq key still not rotated (same key from before the leak in git history)

## 2026-09-22 (Abhijit — Session 10: Demo Fallbacks + .env Fix)
- [Abhijit] Added 5 ICMR-based demo fallback responses in chat_provider.dart (diabetes, BP, fever, AQI, diet)
- [Abhijit] Added synonym matching (sugar/glucose→diabetes, bp/hypertension→BP, pollution/smog→AQI, etc.)
- [Abhijit] Fallback chain is now: Backend SSE → Groq Direct → Demo Fallbacks → Generic Error
- [Abhijit] Rewrote backend/.env to match new .env.example (Groq/SambaNova/Cerebras/Sarvam placeholders)
- [Abhijit] Preserved live WAQI_API_TOKEN in .env
- [Abhijit] Switched api_config.dart to emulator mode for local-first testing

## 2026-09-21 (Jayesh — Session 9: Sarvam AI + Evaluation + AQI Cleanup)
- [Jayesh] Replaced Bhashini translation with Sarvam AI (mayura:v1, Hindi+Marathi+English, ₹100 free credits)
- [Jayesh] Fixed evaluation pipeline: honest "LLM-as-Judge" docstring, retrieved context passed to judge, robust JSON parsing, removed survivorship bias filter
- [Jayesh] Added hypertension→drug cross-links (Atenolol, Amlodipine) in knowledge bundle
- [Jayesh] Cleaned up AQI module with proper _USE_MOCK env var fallback pattern
- [Jayesh] Updated .env.example: removed Bhashini vars, added SARVAM_API_KEY
- [Jayesh] Created HANDOFF.md with task assignments for Abhijit + Ritesh

## 2026-09-20 (Jayesh — Session 8: Brutal Audit + Context Wiring)
- [Jayesh] Ran LLM Council (5 advisors + peer review + chairman) to validate fix plan
- [Jayesh] Removed leaked Groq API key from chat_provider.dart (security fix)
- [Jayesh] Removed real API key from .env.example (security fix)
- [Jayesh] Fixed temp→temperature key mismatch between weather.py and context_builder.py
- [Jayesh] Fixed broken cross-link: pollution-respiratory.md → aqi-health-impact.md
- [Jayesh] Deleted dead _mock_pipeline() code (40+ lines) from routes.py
- [Jayesh] Fixed lying "740-line prompt" comment → honest "21-line"
- [Jayesh] CRITICAL: Wired profile + wearable + location + chat_history from Flutter to backend
- [Jayesh] Added chat_history field to ChatRequest Pydantic model
- [Jayesh] Propagated chat_history through pipeline → context_builder → LLM prompt
- [Jayesh] Updated chat_screen.dart to pull from AuthProvider/HealthProvider/FitnessProvider
- [Jayesh] Built last-5-messages chat history in chat_provider.dart

## 2026-09-15 (Jayesh — Session 7: Health Connect & Google Fit Sync Precision + Indian CPCB NAQI Air Quality Engine)
- [Jayesh] Upgraded MainActivity.kt to FlutterFragmentActivity for Android 14+ Health Connect registerForActivityResult support
- [Jayesh] Added Health Connect permissions (READ_RESTING_HEART_RATE, READ_TOTAL_CALORIES_BURNED, READ_DISTANCE) and rationale intent filter to AndroidManifest.xml
- [Jayesh] Eliminated double calorie accumulation bug in health_connect_service.dart (separated active vs total calories, matching Google Fit's 738 kcal)
- [Jayesh] Widened Health Connect historical window to 36 hours for seamless retrieval of previous evening/night heart rate, SpO2, and sleep records
- [Jayesh] Fixed pedometer clobbering bug in fitness_provider.dart: verified Health Connect data is protected from uncalibrated accelerometer noise
- [Jayesh] Enhanced LocationService reverse-geocoding to prioritize subAdministrativeArea (Taluka/City e.g. Shirpur) over rural census sub-localities (Babulde)
- [Jayesh] Implemented official Indian National Air Quality Index (CPCB NAQI) calculation with direct Open-Meteo coordinates fallback
- [Jayesh] Added interactive AQI detail bottom sheet with PM2.5/PM10 pollutant breakdown, GPS refresh, and city chips
- [Jayesh] Verified 0 flutter analyze errors and confirmed clean Android assembleDebug APK build

## 2026-09-12 (Jayesh — Session 6: Complete UI & Feature Restoration)
- [Jayesh] Restored full premium Aarogya Sathi UI & features from original complete codebase
- [Jayesh] Brought over full 4-tab bottom navigation (Home Dashboard, AI Chat, Health Tracking, Profile)
- [Jayesh] Enabled LocationService with auto GPS detection and reverse geocoding to city name for live AQI
- [Jayesh] Restored HealthScoreRing, AnimatedMetricCards, GlassCard, AarogyaLogoDynamic widgets
- [Jayesh] Restored HealthDashboard with interactive Blood Pressure and Blood Sugar charts and vital logging
- [Jayesh] Restored NotificationService for scheduled daily medication/water reminders
- [Jayesh] Connected ChatProvider to deployed Render backend (/api/chat) with SSE streaming + direct Groq fallback + emergency 108 detection
- [Jayesh] Integrated Health Connect & Fitbit wearable model alongside pedometer and local trackers
- [Jayesh] Restored SplashScreen with glowing ring animation, Login/Register with Guest Explore mode, and ProfileSetupScreen
- [Jayesh] Fixed greeting time boundaries to correctly show 'Good night' from 22:00 to 04:59 (e.g. at 00:42)
- [Jayesh] Upgraded AQI loading to use real GPS coordinates with backend /api/aqi and Open-Meteo fallback (resolves small cities like Shirpur-Warwade)
- [Jayesh] Connected Health Connect & Fitbit sync into FitnessProvider and added sync action & pull-to-refresh
- [Jayesh] Added live BPM to HealthScoreRing and included heart rate in dynamic score calculation
- [Jayesh] Clean Flutter build with zero errors, zero warnings

## 2026-09-11 (Jayesh — Session 5: Deployment & CI/CD)
- [Jayesh] Created multi-stage Dockerfile for backend (Python 3.11 slim, copies icmr-knowledge-bundle)
- [Jayesh] Created render.yaml blueprint for one-click Render deployment (Singapore region, free tier)
- [Jayesh] Created `.github/workflows/backend-ci-cd.yml` — lint (Ruff), test (pytest), Docker build + verify, deploy to Render
- [Jayesh] Created `.github/workflows/flutter-ci-cd.yml` — flutter analyze, build release APK, GitHub Releases on version tags
- [Jayesh] Updated `api_config.dart` to support 3 environments (emulator/physical/production)
- [Jayesh] Updated `.gitignore` with Flutter build artifacts and Docker ignores
- [Jayesh] Created `.dockerignore` to keep image lean

## 2026-09-11 (Jayesh — Session 4: Full App Integration)
- [Jayesh] Phase 1: Created centralized API config (`api_config.dart`), fixed AQI endpoint URL from `/api/v1/environment/current` → `/api/aqi`
- [Jayesh] Phase 2: Built real SSE chat — `chat_service.dart` with Dio streaming, `chat_request_model.dart`, rewrote `chat_screen.dart` with Riverpod + streaming tokens + typing indicator
- [Jayesh] Phase 3: Health profile system — `user_profile_model.dart`, `profile_service.dart` (SharedPreferences), `health_profile_screen.dart` with ICMR BP/sugar classifications + BMI calc
- [Jayesh] Phase 4: Health Connect integration — `health_connect_service.dart` reads from Fitbit/Google Fit/Samsung Health via Android Health Connect, `wearable_data_model.dart` matching backend
- [Jayesh] Phase 5: Dashboard shows live Heart Rate, Sleep, SpO2, Calories from Health Connect instead of hardcoded values
- [Jayesh] Phase 6: Chat sends real profile + wearable data + GPS location with every message — AI knows your HR, steps, conditions when answering
- [Jayesh] Phase 7: Removed register screen (no auth for now), replaced with `/profile` route for health profile
- [Jayesh] Phase 8: Fixed backend `context_builder.py` wearable field mismatch, dynamic greeting, Health Connect setup banner
- [Jayesh] Added `health: ^11.0.0` to pubspec, Health Connect permissions to AndroidManifest.xml

## 2026-09-11 (Jayesh — Session 3)
- [Jayesh] OKF bundle expanded 13→34 concept files (21 new: 8 conditions, 6 drugs, 4 lifestyle, 5 emergency, 3 environmental)
- [Jayesh] Rebuilt root index.md to list all 34 files with descriptions (fixed navigator empty response)
- [Jayesh] Expanded keyword fallback from 12→80+ keywords covering all categories
- [Jayesh] Built RAGAS evaluation pipeline: `evaluation/evaluate.py` + 32 gold Q&A pairs in `gold_qa.json`
- [Jayesh] Tested E2E pipeline: correct doc retrieval + medically accurate responses verified

## 2026-09-11 (Jayesh — Session 2)
- [Jayesh] Fixed Groq model names (API changed): openai/gpt-oss-20b + qwen/qwen3.8-27b
- [Jayesh] Merged Flutter app from Aarogya Sathi Antigravity into `frontend/` (11 Dart files, 4 screens)
- [Jayesh] Tested full CRAG pipeline E2E with Groq API key — working
- [Jayesh] Created GitHub issue #6 for Ritesh: Flutter app upgrade (SSE, AQI fix, profile screen)
- [Jayesh] Updated all .context files: contributors (3), architecture, dependencies, modules, changelog

## 2026-09-11 (Jayesh — Session 1)
- [Jayesh] Phase 1: Multi-provider LLM factory (Groq→SambaNova→Cerebras cascade) in `backend/rag/llm.py`
- [Jayesh] Phase 2: OKF Navigator (`backend/rag/okf_navigator.py`) — LLM-driven file traversal with keyword fallback
- [Jayesh] Phase 3: CRAG Grader (`backend/rag/grader.py`) — parallel relevance scoring using 8B model
- [Jayesh] Phase 4: Context Builder (`backend/rag/context_builder.py`) — ICMR system prompt + OKF docs + profile + AQI assembly
- [Jayesh] Phase 5: CRAGPipeline (`backend/rag/pipeline.py`) — main pipeline, wired into Abhijit's routes.py (replaced mock)
- [Jayesh] Phase 6: ICMR utils (`backend/utils/icmr.py`) — Asian-cutoff classifiers for BP, sugar, BMI, AQI
- [Jayesh] Added OKF files: `conditions/asthma.md`, `lifestyle/exercise-guidelines.md`
- [Jayesh] Updated requirements.txt (replaced langchain-ollama→langchain-groq, added langgraph)
- [Jayesh] Created GitHub issue #5 for Ritesh (7 architecture diagrams)

## 2026-09-11 (Abhijit)
- [Abhijit] Phase 1: FastAPI skeleton — main.py, models.py (with WearableData), routes.py
- [Abhijit] Phase 2: Bhashini translation wrapper with mock fallback (API keys pending)
- [Abhijit] Phase 3: Safety router — emergency/prescription/non-medical blocking with keyword fallback
- [Abhijit] Phase 4: AQI (WAQI mock) + Weather (Open-Meteo live) integration
- [Abhijit] Created 11 mock OKF knowledge bundle files for testing
- [Abhijit] Full SSE streaming chat pipeline working end-to-end (mock RAG)
- [Abhijit] All 9 verification tests passing

## 2026-09-08
- [Developer] Project initialized with iLabs context system

_Format: [Developer] What was done (PR #XX)_
<!-- dev-log: 2026-05-28T19:45:31 -->

<!-- dev-log: 2026-05-29T13:42:37 -->

<!-- dev-log: 2026-05-30T14:44:29 -->

<!-- dev-log: 2026-06-01T20:34:48 -->

<!-- dev-log: 2026-06-03T21:33:38 -->

<!-- dev-log: 2026-06-03T09:45:34 -->

<!-- dev-log: 2026-06-05T22:48:31 -->

<!-- dev-log: 2026-06-07T11:03:16 -->

<!-- dev-log: 2026-06-08T19:43:03 -->

<!-- dev-log: 2026-06-09T21:26:38 -->

<!-- dev-log: 2026-06-10T16:19:55 -->

<!-- dev-log: 2026-06-11T21:13:40 -->

<!-- dev-log: 2026-06-12T11:00:26 -->

<!-- dev-log: 2026-06-13T13:44:55 -->

<!-- dev-log: 2026-06-14T18:42:51 -->

<!-- dev-log: 2026-06-14T22:09:04 -->

<!-- dev-log: 2026-06-15T13:28:07 -->

<!-- dev-log: 2026-06-16T16:05:38 -->

<!-- dev-log: 2026-06-17T12:43:53 -->

<!-- dev-log: 2026-06-18T09:48:48 -->

<!-- dev-log: 2026-06-20T15:40:52 -->

<!-- dev-log: 2026-06-21T22:10:21 -->

<!-- dev-log: 2026-06-23T09:29:05 -->

<!-- dev-log: 2026-06-24T09:42:55 -->

<!-- dev-log: 2026-06-25T16:40:28 -->

<!-- dev-log: 2026-06-26T20:31:07 -->

<!-- dev-log: 2026-06-27T09:35:26 -->

<!-- dev-log: 2026-06-29T16:59:45 -->

<!-- dev-log: 2026-06-29T16:35:09 -->

<!-- dev-log: 2026-06-30T13:49:50 -->

<!-- dev-log: 2026-07-02T20:19:53 -->

<!-- dev-log: 2026-07-04T14:21:35 -->

<!-- dev-log: 2026-07-06T12:36:24 -->

<!-- dev-log: 2026-07-06T21:24:24 -->

<!-- dev-log: 2026-07-07T18:21:55 -->

<!-- dev-log: 2026-07-08T11:26:55 -->

<!-- dev-log: 2026-07-09T15:41:05 -->

<!-- dev-log: 2026-07-11T20:56:48 -->

<!-- dev-log: 2026-07-12T13:14:47 -->

<!-- dev-log: 2026-07-14T11:44:19 -->

<!-- dev-log: 2026-07-15T11:15:33 -->

<!-- dev-log: 2026-07-16T22:24:39 -->

<!-- dev-log: 2026-07-18T16:16:42 -->

<!-- dev-log: 2026-07-19T10:28:22 -->

<!-- dev-log: 2026-07-20T12:24:54 -->

<!-- dev-log: 2026-07-21T13:01:53 -->

<!-- dev-log: 2026-07-22T09:58:38 -->

<!-- dev-log: 2026-07-23T14:14:40 -->

<!-- dev-log: 2026-07-24T22:08:40 -->

<!-- dev-log: 2026-07-25T18:23:46 -->

<!-- dev-log: 2026-07-27T11:50:34 -->

<!-- dev-log: 2026-07-28T16:51:18 -->
