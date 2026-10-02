# Abhijit Patil — Contributor Context

## Current Assignment
- **Modules**: Frontend Core, Medical File Vault, Settings & Personalization, API Sync
- **Branch**: main
- **Task**: Medical File Vault, Language Persistence, and Profile Management
- **Status**: Active

## Key Responsibilities
1. **Medical File Vault**: Build `file_vault_screen.dart` with local encrypted/private file storage for prescriptions and lab reports via `image_picker` and `file_picker`.
2. **Language Selector**: Fix language sheet in `home_screen.dart` to save and read `'user_language'` via `SharedPreferences`.
3. **Profile Updates**: Build "Edit Profile" screen so registered and guest users can update vitals and chronic conditions after onboarding.
4. **Dependency Cleanup**: Remove dead packages (`dio`, `fl_chart`, `shimmer`) from `frontend/pubspec.yaml`.

## What's Done ✅
- Built and fully tested **Language Persistence & End-to-End Wiring**:
  - `AuthProvider`: Added reactive `_language` state, `languageLabel`, and `setLanguage(lang)` syncing with `SharedPreferences` (`user_language`) and user profiles.
  - `HomeScreen`: Made settings tile subtitle dynamic (`context.watch<AuthProvider>().languageLabel`) and wired `_showLangSheet` to `auth.setLanguage(...)`.
  - `ChatScreen`: Added language chip switcher in AppBar (`EN`/`HI`/`MR`) and updated `sendMessage` to pass `auth.language`.
  - `ChatProvider`: Fixed variable scoping for `effectiveLang`, passed language to `_callGroqDirectly` with specialized Indian language prompts.
  - Automated Tests: Created `frontend/test/language_persistence_test.dart` (4/4 tests passed) and verified backend context instructions and greetings via `scratch/test_language_wiring.py`.
- Read and analyzed the newly added `Research/` directory (including `literature_review.md` and `project_validation.md`).
- Authored a comprehensive research analysis artifact covering Agentic RAG safety, 14.3:1 ROI, AQI impact, and DPDP compliance for capstone presentation.
- Added 5 ICMR-based demo fallback responses in `chat_provider.dart` with synonym matching.
- Verified backend routes and models handling `profile`, `wearable`, `lat`, `lon`, and `chat_history`.
- Set up local/emulator/production environment toggle in `api_config.dart`.
- Audited frontend screens and providers for missing feature gaps.

## Next Action Items
1. Create `file_vault_screen.dart` and `medical_file_model.dart` for local prescription and report storage (Medical File Vault).
2. Add Edit Profile screen for updating age, height, weight, and health conditions post-onboarding.
3. Clean up unused pubspec dependencies (`dio`, `fl_chart`, `shimmer`).

## Files I Own
- `frontend/lib/screens/health/file_vault_screen.dart` (new)
- `frontend/lib/screens/home/home_screen.dart` (Preferences, Language, Profile)
- `frontend/lib/providers/auth_provider.dart` (profile persistence)
- `frontend/pubspec.yaml`
