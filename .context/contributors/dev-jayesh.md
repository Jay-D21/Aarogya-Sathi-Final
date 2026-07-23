# Jayesh Patil — Contributor Context

## Current Assignment
- **Modules**: OKF Knowledge Bundle, Agentic RAG Pipeline, Session Memory, Evaluation
- **Branch**: main
- **Status**: Active Lead

## Key Responsibilities
1. **Agentic Pipeline**: Maintain `backend/rag/intent.py`, `tools.py`, `pipeline.py` — intent-first routing with ReAct tool-use.
2. **Per-User Session Memory**: Maintain `backend/memory/session.py` — local JSON disk persistence.
3. **Multi-Key LLM Pool**: Maintain 3-key Groq + 7-key Sarvam round-robin rotation in `llm.py` and `bhashini.py`.
4. **Evaluation**: Run full 32-query gold benchmark against the agentic pipeline and expand to 50+ questions.
5. **OKF Bundle Expansion**: Grow from 34 → 50+ concept files covering more conditions, drugs, and lifestyle topics.

## What's Done ✅
- Play Store closed testing preparation (applicationId `com.aarogyasathi.app`, release signing, manifest cleanup, privacy policy)
- Google Health & Fit UI redesign (reusable widget library: sparklines, status badges, summary banner, weekly bars, metric cards)
- Redesigned Home Dashboard, Health Dashboard, and Google Drive-style Medical File Vault
- Agentic CRAG pipeline: Intent Classification → Selective Tool Use → Proactive Insights → Generation
- Intent classifier with heuristic fast-path (regex) + 70B LLM fallback for nuanced queries
- Proactive insights engine: vital thresholds (HR, SpO2, BP, glucose), AQI alerts, longitudinal BP/HR trends
- Per-user session memory: in-memory cache + JSON disk persistence, vital history, conversation summaries
- Multi-provider LLM cascade: Groq → SambaNova → Cerebras with multi-key round-robin per provider
- Native multilingual: Hindi/Marathi/Hinglish/Minglish understood directly by Qwen 27B (no translation overhead)
- Response brevity: max 400 tokens, warm conversational tone, bullet points, no essays
- Live deployment on Render (`https://aarogya-sathi-final.onrender.com`)
- First LLM-as-judge benchmark: 4.60/5.00 overall score
- Team sprint roadmap and gap analysis documents

## Still Pending
1. **Evaluation re-run**: Execute full 32-query benchmark through the new agentic pipeline (post-Session 12 upgrade)
2. **OKF expansion**: Add 16+ more concept files (malaria, pneumonia, PCOD, losartan, mental-health)
3. **Proactive notification endpoint testing**: Verify `/api/session/{user_id}/insights` against real wearable data
4. **Final report architecture diagrams**: Update with agentic flow (Ritesh to create, Jayesh to review)

## Session Log
- **2026-10-24 (Session 30)**: ASLogo.svg Full-System Brand Identity, Play Store Assets & Signed Release AAB:
  - Rendered vector ASLogo.svg across all platform launcher icons (Android adaptive & mipmaps, iOS, Web, Windows).
  - Generated Google Play Store 512x512 icon and 1024x500 feature graphic banner.
  - Integrated in-app brand identity into splash screen, login screen, dynamic logo widget, and privacy policy.
  - Verified 0 flutter analyze issues, 23/23 tests passing, compiled fresh release APKs.
  - Compiled and signed final release Android App Bundle (app-release.aab ~45.5 MB) via Gradle bundleRelease using upload keystore; verified signature integrity via jarsigner -verify.
- **2026-10-22 (Session 29)**: Proactive Health Notification System + Analyze Fixes:
  - Built `HealthAlertService` (~315 lines) with ICMR vital alerts (BP crisis ≥180/120, hypoglycemia <70, tachycardia ≥120, low SpO2 <94), CPCB AQI alerts (unhealthy ≥150, hazardous ≥300), backend insight polling (30min cooldown), and 60min same-type cooldowns via SharedPreferences. Three Android notification channels with ID range 200001-200030.
  - Wired alerts into `health_provider.dart` (BP/sugar after logging), `fitness_provider.dart` (HR/SpO2 after sync), `home_screen.dart` (AQI on banner load + insight polling on app open).
  - Fixed `app_theme.dart` directive_after_declaration error and `expressive_motion.dart` invalid_constant errors.
  - Verification: `flutter analyze` 0 issues, `flutter test` 23/23 passed.
- **2026-10-21 (Session 28)**: Material 3 Expressive System & Gemini AI Assistant Polish:
  - Theme Tokens & Expressive Motion: Defined True-Black Pixel Dark Mode (`#0A0E0D` scaffold, `#141B19` cards, `#1C2523` inner containers, `#66F7E2` luminous mint primary) and Light Mode (`#EDF3F1` scaffold, `#FFFFFF` cards, `#E3ECE9` inner containers). Built `expressive_motion.dart` featuring `SpringPressable` (tactile spring physics on tap) and `StaggeredFadeSlide` (staggered entrance animations).
  - AI Health Assistant Empty State & Stuck Spinner Resolution: Resolved root cause of the endless loading spinner on opening the chat tab by removing blocking load conditions. Implemented Google Gemini Expressive empty state with ShaderMask gradient greeting (`"Hello, $userName"` in `#006A60`→`#3F5F90` light / `#66F7E2`→`#A8C8FF` dark, 32sp w800), 20sp subtitle, tonal trust pill (`"ICMR-Guided • Private On-Device"` with `Icons.verified_user_outlined`), and 2x2 Bento Starter Cards (`"Fever & headache"`, `"Daily hydration"`, `"Diabetes diet"`, `"High AQI care"`) wrapped in `SpringPressable`.
  - Home Screen & Metric Cards Polish: Animated Daily Score Ring via `TweenAnimationBuilder<double>` (1100ms, `Curves.easeOutCubic`) for smooth arc sweep and counter animation. Applied semantic M3 accent colors across submetrics and 2x2 Key Metrics Bento Grid (Steps: primary teal/mint, Active Kcal & BP: Warm Amber `#E66000`/`#FFB77C`, BPM & Blood Glucose: Coral Rose `#D9385A`/`#FF859D`, Sleep & Symptoms: Indigo/Lavender `#4F46E5`/`#A5B4FC`). Replaced inconsistent add icon on BP with uniform 18px `Icons.arrow_outward_rounded`, placed metric icons in `36x36` 12% opacity tonal circular containers, and wrapped in `SpringPressable`. Styled Weekly Day Bar inactive circles with `1.5px` `outlineVariant` border and current day with `primary` border and dot. Cleaned up settings icons to uniform `colorScheme.onSurfaceVariant` inside `36x36` circular `colorScheme.surfaceContainer` containers.
  - Health Dashboard Polish: Applied semantic colors across 2x2 grid and wrapped sections in `StaggeredFadeSlide`.
  - Verification: `dart analyze lib`: **0 issues**, `flutter test`: **23/23 tests passed**.
- **2026-10-18 (Session 27)**: Google Pixel / Gemini / Material 3 Dark & Light Mode Redesign:
  - Strict M3 Dark Mode tokens (`#0E1513` Carbon-Mint bg, `#17201E` borderless `surfaceContainerLow` cards, `#212B28` `surfaceContainerHigh` tonal surfaces, and luminous `#74F8E5` Tone-80 Google Fit mint primary accents).
  - Strict M3 Light Mode tokens (`#F4F8F6` bg, `#FFFFFF` cards, `#E6EFEC` tonal surfaces, `#006A60` primary teal).
  - Global 1px border deletion: Metric cards, hero cards, action chips, dialogs, bottom sheets, file cards, and auth cards rely purely on `surfaceContainerLow` with `BorderRadius.circular(24)` and zero borders. Tight 10px spacing in 2x2 Bento Grids.
  - Gemini-style AI Assistant: Left-aligned greeting ("Hello, $userName" in 28sp w700 primary, 20sp subtitle in `onSurfaceVariant`), flat trust pill ("ICMR-Guided • Private On-Device"), 2-column bento suggestion cards in `surfaceContainerLow` radius 20 with 18px primary icons. Unified Google Gemini bottom floating pill container (`surfaceContainerHigh`, radius 32, zero border) integrating text input, mic button, and circular 36x36 upward-arrow send button. User bubble in `primaryContainer`/`onPrimaryContainer`; AI bubble in `surfaceContainerLow`.
  - Verification: `dart analyze lib` 0 issues, `flutter test` 23/23 tests passed.
- **2026-10-16 (Session 26)**: Material 3 / Google Fit Production Design Overhaul for Play Store Beta:
  - Phase 1 Theme & Design System: Enforced strict clinical color tokens (`scaffoldBackgroundColor: #F5F8F7`, cards: pure `#FFFFFF` elevation 0 without border+shadow combo, `secondaryTonal: #EAF1EF`, `primaryAccent: #006A60`, `primaryContainer: #D0EFEA`, `emergencyAlert: #FCEEEE/#B3261E`). Purged pastel squircles and raw system emojis across app.
  - Phase 2.1 Home Screen: Pinned `SliverAppBar` to prevent status bar collisions, hero daily score card with aligned 3-column stats (`Steps`, `Active Kcal`, `BPM`), horizontal `SingleChildScrollView` M3 `ActionChip` row, 2x2 grid (`Heart Rate`, `Sleep`, `Weight`, `Blood Pressure`), removed duplicate steps & vault cards.
  - Phase 2.2 Health Tracking: Removed redundant top banner and duplicate links; added single bottom-right `FloatingActionButton.extended` ('Log Vitals') and subtle add icons on cards.
  - Phase 2.3 AI Assistant: Replaced purple gradients with teal tonal container, single trust subtitle ("ICMR-Guided • AQI-Aware • Private On-Device"), replaced emoji cards with monochrome outline icon cards with north-east arrows, and added persistent 11px Play Store medical disclaimer.
  - Phase 2.4 Profile: Clean horizontal header (64px avatar, name, email/guest, city), 3-column stats bar (`BMI`, `Height`, `Weight`), full-width tonal edit button, guest sign-in tile, privacy policy external launcher, and account/local data wipe confirmation.
  - Phase 3 CI/CD & Verification: Enhanced keep-alive timeout/retry and backend test environment variables. `flutter analyze`: 0 issues, `flutter test`: 23/23 passed.
- **2026-10-14 (Session 25)**: Mock data purge & Google Health UI polish. Replaced fake vitals & fake sparklines with dynamic records, added zero-state banners, fixed infinite AQI loading timeout, refreshed Material You theme styling and empty chat state. 0 analyze issues, 23/23 tests pass.
- **2026-10-10 (Session 24)**: Sprint 1 Play Store blockers (applicationId `com.aarogyasathi.app`, signing config, DPDP privacy policy) + Sprint 2 Google Health & Drive UI redesign with 9 new reusable widgets.
- **2026-09-30 (Session 12)**: Built intent.py, tools.py, insights.py, session.py. Rewrote pipeline.py to agentic flow. Added user_id to ChatRequest. Added /api/session/{user_id}/insights. Fixed language selector persistence. Removed dead deps. Integration test passed.
- **2026-09-30 (Session 11)**: Multi-key rotation, Hinglish optimization, context styling, agentic roadmap.
- **2026-09-27 (Session 10)**: Audit, cleanup, honest README.

<!-- dev-log: 2026-05-28T16:50:01 -->

<!-- dev-log: 2026-05-29T14:30:35 -->

<!-- dev-log: 2026-05-30T13:19:16 -->

<!-- dev-log: 2026-06-01T20:11:12 -->

<!-- dev-log: 2026-06-03T13:06:53 -->

<!-- dev-log: 2026-06-04T11:17:02 -->

<!-- dev-log: 2026-06-06T10:55:00 -->

<!-- dev-log: 2026-06-07T22:30:07 -->

<!-- dev-log: 2026-06-08T11:09:51 -->

<!-- dev-log: 2026-06-09T18:50:39 -->

<!-- dev-log: 2026-06-10T18:27:19 -->

<!-- dev-log: 2026-06-11T12:16:42 -->

<!-- dev-log: 2026-06-12T16:44:38 -->

<!-- dev-log: 2026-06-13T16:04:43 -->

<!-- dev-log: 2026-06-14T12:27:07 -->

<!-- dev-log: 2026-06-14T09:10:50 -->

<!-- dev-log: 2026-06-15T16:44:19 -->

<!-- dev-log: 2026-06-16T09:56:27 -->

<!-- dev-log: 2026-06-17T22:36:37 -->

<!-- dev-log: 2026-06-18T11:30:33 -->

<!-- dev-log: 2026-06-20T16:05:30 -->

<!-- dev-log: 2026-06-22T15:44:31 -->

<!-- dev-log: 2026-06-23T14:16:20 -->

<!-- dev-log: 2026-06-24T17:29:26 -->

<!-- dev-log: 2026-06-25T21:03:13 -->

<!-- dev-log: 2026-06-26T09:40:38 -->

<!-- dev-log: 2026-06-27T10:14:53 -->

<!-- dev-log: 2026-06-29T13:32:45 -->

<!-- dev-log: 2026-06-30T15:12:58 -->

<!-- dev-log: 2026-07-01T22:26:21 -->

<!-- dev-log: 2026-07-02T18:37:42 -->

<!-- dev-log: 2026-07-04T21:34:24 -->

<!-- dev-log: 2026-07-06T12:54:49 -->

<!-- dev-log: 2026-07-06T19:50:52 -->

<!-- dev-log: 2026-07-07T10:55:54 -->

<!-- dev-log: 2026-07-08T19:09:04 -->

<!-- dev-log: 2026-07-09T22:21:54 -->

<!-- dev-log: 2026-07-12T16:55:34 -->

<!-- dev-log: 2026-07-12T10:27:06 -->

<!-- dev-log: 2026-07-15T09:02:20 -->

<!-- dev-log: 2026-07-16T15:36:43 -->

<!-- dev-log: 2026-07-17T19:15:31 -->

<!-- dev-log: 2026-07-18T09:57:51 -->

<!-- dev-log: 2026-07-19T18:19:40 -->

<!-- dev-log: 2026-07-21T16:06:15 -->

<!-- dev-log: 2026-07-21T19:25:17 -->

<!-- dev-log: 2026-07-23T20:31:53 -->

<!-- dev-log: 2026-07-23T12:39:16 -->
