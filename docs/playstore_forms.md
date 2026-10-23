# Aarogya Sathi — Play Console Form Answers

## Content Rating Questionnaire (IARC)
- Does your app contain violence? **No**
- Does your app contain sexual content? **No**
- Does your app contain gambling? **No**
- Does your app contain controlled substance references? **No** (medication info is educational)
- Does your app contain user-generated content? **No**
- Does your app allow users to communicate? **No**
- Does your app share user location? **No** (used locally for AQI only)
- Expected rating: **Everyone**

## Data Safety Form

### Data Collection
| Data Type | Collected | Shared | Purpose | Optional |
|-----------|-----------|--------|---------|----------|
| Name (first, last) | Yes | No | App functionality - personalized greeting & profile | Yes |
| Approximate location | Yes | No | App functionality - AQI for user's area | No (core feature) |
| Health info (vitals, conditions, medications) | Yes | No | App functionality - personalized health guidance | Yes |
| Photos (medical vault) | Yes | No | App functionality - store prescriptions/reports | Yes |
| App interactions | Yes | No | Analytics - chat usage patterns | No |

### Data Handling
| Question | Answer |
|----------|--------|
| Is data encrypted in transit? | Yes (HTTPS/TLS) |
| Is data encrypted at rest? | Yes (SharedPreferences, on-device only) |
| Can users request data deletion? | Yes (in-app "Delete Account & Local Data" button) |
| Is this app directed at children? | No |
| Does the app follow Google's Families Policy? | Not applicable (not a children's app) |

### Data NOT Collected
- Financial info
- Messages/emails
- Audio/music/voice
- Files and docs (except medical vault photos stored locally)
- Calendar
- Contacts
- Browsing history
- Search history
- Device identifiers

## Health Connect Permission Declarations

### For each permission, the declaration needs:
1. **What data you access** — exact Health Connect data type
2. **Why you access it** — user-facing justification
3. **How it benefits the user** — clear value statement

| Permission | Data Accessed | Justification | User Benefit |
|------------|--------------|---------------|--------------|
| READ_STEPS | Daily step count from wearables | Display activity metrics and weekly trends on health dashboard | Users can track their daily physical activity without manual logging |
| READ_HEART_RATE | Heart rate readings from wearables | Monitor heart rate trends and trigger proactive alerts for tachycardia (>120 bpm) or bradycardia (<50 bpm) | Early warning for abnormal heart rhythms |
| READ_RESTING_HEART_RATE | Resting heart rate from wearables | Track resting heart rate as cardiovascular fitness indicator | Long-term cardiovascular health monitoring |
| READ_BLOOD_PRESSURE | Blood pressure readings | Classify readings using ICMR thresholds and alert on hypertensive crisis (>180/120) | Timely warnings for dangerously high blood pressure |
| READ_BLOOD_GLUCOSE | Blood glucose readings | Classify readings using ICMR diabetes thresholds and alert on critical values (>300 mg/dL or <70 mg/dL) | Diabetes management and hypoglycemia detection |
| READ_OXYGEN_SATURATION | SpO2 readings from wearables | Monitor blood oxygen levels and alert when SpO2 drops below 94% | Early warning for respiratory distress |
| READ_SLEEP | Sleep session data | Display sleep duration, patterns, and weekly trends | Help users understand and improve sleep habits |
| READ_WEIGHT | Weight measurements | Calculate BMI using Asian ICMR cutoffs (Normal: 18.5-22.9, Overweight: 23-27.4) | Weight and BMI tracking with India-specific standards |
| READ_BODY_TEMPERATURE | Body temperature readings | Health monitoring during illness episodes | Track fever patterns during illness |
| READ_ACTIVE_CALORIES_BURNED | Active energy expenditure | Display daily activity energy on health dashboard | Track exercise effectiveness |
| READ_TOTAL_CALORIES_BURNED | Total daily energy expenditure | Display total daily energy including BMR on health dashboard | Complete daily energy picture |
| READ_DISTANCE | Walking/running distance | Display daily distance on health dashboard | Track movement and activity levels |

## App Access
- **All functionality is available without special access**
- No login required (Guest mode available)
- No subscription or in-app purchases
- No ads

## Target Audience
- **Target age group**: 18 and above
- **Not directed at children under 13**

## Financial Features
- App is **free**
- **No in-app purchases**
- **No ads**
- **No subscriptions**
