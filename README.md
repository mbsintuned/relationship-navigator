# Relationship Navigator App

A personal relationship-insight and decision-support app that helps users understand, connect, and navigate their relationships through structured personality, behavior, and interaction data analysis.

## Core Features

- **Multi-framework Personality Assessments**: Big Five, MBTI, Enneagram, DISC, StrengthsFinder, Values
- **Relational Frameworks**: Attachment Styles, EQ, Conflict Styles, Love Languages
- **Optional Complementary Systems**: Astrology, Human Design
- **Interaction Logging**: ARR (Action-Reaction-Outcome) model
- **AI-Powered Predictions**: Real-time advice, scenario simulation, strategy suggestions
- **Privacy-First Design**: Transparent consent, local-first processing, full data ownership

## Tech Stack

- **Frontend**: Flutter (cross-platform mobile)
- **Backend**: Supabase (PostgreSQL + real-time features)
- **Authentication**: OIDC/OAuth 2.1 (Apple, Google, Email)
- **Database**: PostgreSQL with encrypted local cache
- **AI/NLP**: On-device lightweight models + optional cloud functions
- **CI/CD**: GitHub Actions + Fastlane

## Project Structure

```
relationship-navigator/
├── mobile/                 # Flutter app
├── backend/               # Supabase configuration
├── schemas/              # Database schemas
├── docs/                 # Documentation
├── scripts/              # Build and deployment scripts
└── tests/                # Test suites
```

## Privacy & Security

- Explicit consent for all data types
- Local-first processing where possible
- Full data export/deletion capabilities
- Platform-specific limitations respected (iOS share-only, Android optional SMS)

## Development Phases

1. **Foundation**: Database, auth, core models
2. **Assessments**: Personality frameworks and scoring
3. **Profiles**: Person management and scoring
4. **Interactions**: Logging and analysis
5. **AI**: Predictions and advice engine
6. **Mobile**: Cross-platform app development
7. **Deployment**: Testing, CI/CD, and release

## Getting Started

See individual directories for setup instructions.
