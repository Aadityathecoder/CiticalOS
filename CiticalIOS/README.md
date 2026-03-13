## Citical iOS

SwiftUI prototype for the Civic Needs AI concept. The real Xcode project lives here:

- `/Users/aadithiyamitra/Documents/Citical/CiticalIOS/Citical/Citical.xcodeproj`

### Current prototype

- Dashboard with transparent civic-priority scoring
- Map view for neighborhood issue clustering
- Pilot/admin tab for adjusting weights and previewing exports
- Project tab that matches the Phase 1 / 2 / 3 plan from the concept brief
- Local sample dataset modeled after public 311, forum, and meeting-minute inputs

### Open in Xcode

1. Open `/Users/aadithiyamitra/Documents/Citical/CiticalIOS/Citical/Citical.xcodeproj`
2. Select an iPhone simulator
3. Run the `Citical` target

### Replace sample data

Update `/Users/aadithiyamitra/Documents/Citical/CiticalIOS/Citical/Citical/SampleReports.json`

Required fields:

- `source`: `311`, `Forum`, or `Minutes`
- `title`, `body`, `createdAt`, `status`
- `neighborhood`, `address`
- optional geo fields: `latitude`, `longitude`
- optional model hints: `suggestedCategory`, `suggestedUrgency`, `confidenceHint`, `vulnerabilityIndex`

### Swap in a real AI backend

The scoring handoff point is:

- `/Users/aadithiyamitra/Documents/Citical/CiticalIOS/Citical/Citical/CivicPipeline.swift`

That file currently uses a transparent heuristic pipeline so the prototype is explainable without a server. Replace it later with model inference from Python or an API when you start Phase 2.
