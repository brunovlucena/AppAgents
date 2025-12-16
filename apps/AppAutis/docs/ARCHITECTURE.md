# 🏗️ AppAutis - Technical Architecture

> **Version**: 0.1.0  
> **Status**: Design Phase  
> **Last Updated**: January 2025

## 📋 Table of Contents

1. [System Overview](#system-overview)
2. [Architecture Principles](#architecture-principles)
3. [Platform Components](#platform-components)
4. [Lambda Agents](#lambda-agents)
5. [Lambda Functions](#lambda-functions)
6. [Data Flow](#data-flow)
7. [CloudEvents Specification](#cloudevents-specification)
8. [Data Storage](#data-storage)
9. [Integration Points](#integration-points)
10. [Deployment Architecture](#deployment-architecture)
11. [Observability](#observability)
12. [Security](#security)

---

## 🎯 System Overview

AppAutis is built on Kubernetes using the **Knative Lambda Operator** for serverless functions and agents, integrated with **agents-whatsapp-rust** for real-time messaging. The platform follows event-driven architecture principles using CloudEvents for all inter-service communication.

### High-Level Architecture

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                           APP AUTIS PLATFORM                                 │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  📱 CLIENTS                                                                   │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐                                   │
│  │ iOS App  │  │AndroidApp│  │ Web PWA  │                                   │
│  └─────┬────┘  └─────┬────┘  └─────┬────┘                                   │
│        │             │             │                                        │
│        └─────────────┼─────────────┘                                        │
│                      │ WebSocket / HTTP                                      │
│        ┌─────────────▼─────────────┐                                        │
│        │  Game API Gateway         │                                        │
│        │  (Knative Service)        │                                        │
│        └─────────────┬─────────────┘                                        │
│                      │                                                       │
│        ┌─────────────▼───────────────────────────────────────────┐          │
│        │         CloudEvents Broker (RabbitMQ)                   │          │
│        └─────┬──────┬──────┬──────┬──────┬──────┬──────────────┘          │
│              │      │      │      │      │      │                         │
│  ┌───────────▼──┐ ┌─▼─────┐ ┌───▼────┐ ┌─▼──────┐ ┌─────────▼─────────┐  │
│  │ Tutor Agent  │ │Game   │ │Multi-  │ │Progress│ │Scoring │           │  │
│  │{child-id}    │ │Logic  │ │player  │ │Tracker │ │Agent   │           │  │
│  │(LambdaAgent) │ │Func   │ │Coord   │ │(Lambda)│ │(Lambda)│           │  │
│  └──────────┬───┘ └───────┘ └────────┘ └────────┘ └─────────┘           │  │
│             │                                                               │  │
│  ┌──────────▼─────────────────────────────────────────────────┐           │  │
│  │        agents-whatsapp-rust (WhatsApp Gateway)            │           │  │
│  │  - Messaging Service (WebSocket)                          │           │  │
│  │  - Agent Gateway (Message Routing)                        │           │  │
│  │  - Message Storage Service                                │           │  │
│  └───────────────────────────────────────────────────────────┘           │  │
│                                                                              │
│  💾 DATA STORES                                                              │
│  ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────┐                        │
│  │ MongoDB  │ │  Redis   │ │PostgreSQL│ │  MinIO   │                        │
│  │(Game Data│ │(Sessions)│ │(Progress)│ │(Media)   │                        │
│  └──────────┘ └──────────┘ └──────────┘ └──────────┘                        │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## 🎨 Architecture Principles

### 1. Event-Driven Architecture
- All inter-service communication via CloudEvents
- Loose coupling between components
- Scalable and resilient

### 2. Serverless & Auto-Scaling
- LambdaAgents for stateful, AI-powered services
- LambdaFunctions for stateless game logic
- Scale-to-zero for cost efficiency
- Rapid scale-up for responsiveness

### 3. Per-Child Personalization
- One tutor agent per child (LambdaAgent per child)
- Personalized learning paths
- Adaptive difficulty adjustment
- Individual progress tracking

### 4. Real-Time Communication
- WebSocket for game interactions
- WhatsApp for tutor communication
- Event streaming for multiplayer coordination

### 5. Observability First
- Distributed tracing (OpenTelemetry)
- Comprehensive metrics (Prometheus)
- Structured logging (Loki)
- Real-time monitoring (Grafana)

---

## 🧩 Platform Components

### Client Applications

#### Web Application (PWA)
- **Technology**: React/Next.js with TypeScript
- **Communication**: WebSocket + HTTP REST
- **Offline Support**: Service Workers, IndexedDB
- **Deployment**: Static hosting (CDN) or Knative Service

#### iOS Application
- **Technology**: SwiftUI with Swift
- **Communication**: WebSocket + HTTP REST
- **Offline Support**: Core Data for local caching
- **Deployment**: App Store

#### Android Application
- **Technology**: Kotlin with Jetpack Compose
- **Communication**: WebSocket + HTTP REST
- **Offline Support**: Room Database for local caching
- **Deployment**: Google Play Store

### Backend Services

#### Game API Gateway
- **Type**: Knative Service
- **Purpose**: Unified API entry point for clients
- **Responsibilities**:
  - Authentication & authorization
  - Request routing
  - Rate limiting
  - Request/response transformation
- **Technology**: Go or Python (FastAPI)

#### agents-whatsapp-rust Integration
- **Messaging Service**: WebSocket server for real-time game communication
- **Agent Gateway**: Routes messages to tutor agents
- **Message Storage**: Persists conversation history
- **Integration**: CloudEvents for tutor-tutor communication

---

## 🤖 Lambda Agents

LambdaAgents are stateful, AI-powered services deployed using the Knative Lambda Operator. Each agent has:
- Pre-built Docker image
- AI/LLM configuration
- Memory (short-term Redis, long-term PostgreSQL)
- CloudEvents integration
- Observability built-in

### 1. Tutor Agent (Per-Child)

**Name Pattern**: `tutor-agent-{child-id}`  
**Namespace**: `app-autis`  
**Type**: LambdaAgent

Each child has a dedicated tutor agent that provides personalized learning support.

#### Configuration

```yaml
apiVersion: lambda.knative.io/v1alpha1
kind: LambdaAgent
metadata:
  name: tutor-agent-{child-id}
  namespace: app-autis
  labels:
    app.kubernetes.io/name: tutor-agent
    app.kubernetes.io/component: tutor
    app.kubernetes.io/part-of: app-autis
    appautis.child-id: "{child-id}"
spec:
  serviceAccountName: tutor-agent-sa
  
  image:
    repository: ghcr.io/brunovlucena/appautis-tutor-agent
    tag: "v1.0.0"
    port: 8080

  ai:
    provider: ollama
    endpoint: "http://ollama-native.ollama.svc.cluster.local:11434"
    model: "llama3.2:3b"  # Can be upgraded per child's needs
    maxTokens: 2048
    temperature: "0.7"

  behavior:
    maxContextMessages: 50
    emitEvents: true
    systemPrompt: |
      You are a friendly and patient tutor for {child-name}, a {age}-year-old child learning to read and speak.
      
      YOUR ROLE:
      - Provide encouragement and positive reinforcement
      - Offer hints without giving direct answers
      - Adapt to {child-name}'s learning style and pace
      - Celebrate small victories
      - Be patient and understanding
      
      COMMUNICATION STYLE:
      - Use simple, clear language
      - Be warm and encouraging
      - Use visual descriptions when helpful
      - Avoid overwhelming with too much information
      
      CAPABILITIES:
      - Answer questions about games
      - Provide learning tips
      - Suggest appropriate activities
      - Track and celebrate progress

  memory:
    enabled: true
    schema: learning
    shortTerm:
      enabled: true
      backend: redis
      redisSecretRef:
        name: appautis-redis
        key: url
      ttlSeconds: 86400  # 24 hours
    longTerm:
      enabled: true
      backend: postgres
      postgresSecretRef:
        name: appautis-postgres
        key: url
    userMemory:
      enabled: true
      storePreferences: true
      storeFacts: true
      storeProgress: true
    workingMemory:
      enabled: true
      trackDecisions: true
      trackProgress: true

  scaling:
    minReplicas: 0
    maxReplicas: 1
    targetConcurrency: 10
    scaleToZeroGracePeriod: 300s

  resources:
    requests:
      cpu: "100m"
      memory: "256Mi"
    limits:
      cpu: "500m"
      memory: "512Mi"

  env:
    - name: CHILD_ID
      value: "{child-id}"
    - name: CHILD_NAME
      value: "{child-name}"

  eventing:
    enabled: true
    eventSource: "/app-autis/tutor/{child-id}"
    
    intents:
      - appautis.tutor.message.response
      - appautis.tutor.hint.provided
      - appautis.tutor.encouragement.sent
      - appautis.tutor.activity.suggested
    
    subscriptions:
      - eventType: appautis.game.help.requested
        description: "Child requested help in game"
      - eventType: appautis.game.question.asked
        description: "Child asked a question via WhatsApp"
      - eventType: appautis.progress.updated
        description: "Child's progress was updated"
      - eventType: appautis.game.struggling
        description: "Child is struggling with current activity"
    
    dlq:
      enabled: true
      retryMaxAttempts: 3

    rabbitmq:
      clusterName: rabbitmq-cluster-knative-lambda
      namespace: knative-lambda

  observability:
    tracing:
      enabled: true
      endpoint: alloy.observability.svc:4317
    metrics:
      enabled: true
      exemplars: true
    logging:
      level: info
      format: json
      traceContext: true
```

#### Responsibilities
- Provide hints and guidance during gameplay
- Answer questions via WhatsApp
- Track child's learning progress
- Suggest appropriate activities
- Adapt difficulty based on performance
- Celebrate achievements

---

### 2. Multiplayer Coordination Agent

**Name**: `multiplayer-coordinator`  
**Namespace**: `app-autis`  
**Type**: LambdaAgent

Manages multiplayer game sessions, matchmaking, and coordination.

#### Responsibilities
- Match children for multiplayer games (age and skill level)
- Create and manage game sessions
- Synchronize game state between players
- Handle player joins/leaves
- Manage turn-based activities
- Coordinate cooperative challenges

#### CloudEvents
- **Emits**: 
  - `appautis.multiplayer.session.created`
  - `appautis.multiplayer.session.ended`
  - `appautis.multiplayer.player.joined`
  - `appautis.multiplayer.game.state.updated`
- **Subscribes**:
  - `appautis.multiplayer.match.requested`
  - `appautis.multiplayer.game.action`
  - `appautis.multiplayer.player.left`

---

### 3. Progress Tracker Agent

**Name**: `progress-tracker`  
**Namespace**: `app-autis`  
**Type**: LambdaAgent

Tracks and analyzes learning progress for each child.

#### Responsibilities
- Record game completions and scores
- Calculate skill mastery levels
- Generate progress reports
- Identify areas needing practice
- Update learning paths
- Store progress in PostgreSQL

#### CloudEvents
- **Emits**:
  - `appautis.progress.updated`
  - `appautis.progress.milestone.reached`
  - `appautis.progress.report.generated`
- **Subscribes**:
  - `appautis.game.completed`
  - `appautis.game.score.calculated`
  - `appautis.activity.finished`

---

### 4. Scoring Agent

**Name**: `scoring-agent`  
**Namespace**: `app-autis`  
**Type**: LambdaAgent

Calculates scores, awards points, and manages achievements.

#### Responsibilities
- Calculate game scores based on performance
- Award bonus points for first-try successes
- Track streaks and multipliers
- Award achievement badges
- Update leaderboards
- Generate score celebrations

#### CloudEvents
- **Emits**:
  - `appautis.score.calculated`
  - `appautis.achievement.unlocked`
  - `appautis.points.awarded`
  - `appautis.leaderboard.updated`
- **Subscribes**:
  - `appautis.game.completed`
  - `appautis.game.answer.submitted`
  - `appautis.daily.goal.completed`

---

## ⚡ Lambda Functions

LambdaFunctions are stateless, event-driven functions for game logic processing. They use the Knative Lambda Operator's build pipeline from source code.

### 1. Letter Recognition Function

**Purpose**: Process letter matching and recognition games

**Event Flow**:
```
appautis.game.letter.match.requested → Letter Recognition Function
                                              ↓
                                   appautis.game.answer.validated
```

**Logic**:
- Validate letter matches (uppercase/lowercase)
- Check sound-letter associations
- Return validation result with feedback

---

### 2. Word Building Function

**Purpose**: Process word construction activities

**Event Flow**:
```
appautis.game.word.build.requested → Word Building Function
                                            ↓
                                 appautis.game.word.validated
```

**Logic**:
- Validate word construction
- Check spelling correctness
- Verify word exists in vocabulary
- Return validation with hints if incorrect

---

### 3. Sentence Formation Function

**Purpose**: Process sentence building activities

**Event Flow**:
```
appautis.game.sentence.build.requested → Sentence Formation Function
                                                 ↓
                                      appautis.game.sentence.validated
```

**Logic**:
- Validate sentence structure
- Check grammar
- Verify semantic correctness
- Return feedback and suggestions

---

### 4. Pronunciation Validation Function

**Purpose**: Validate voice pronunciation

**Event Flow**:
```
appautis.game.pronunciation.submitted → Pronunciation Validation Function
                                               ↓
                                    appautis.game.pronunciation.validated
```

**Logic**:
- Receive audio recording
- Process with speech recognition (Whisper)
- Compare with target pronunciation
- Return accuracy score and feedback

---

## 🔄 Data Flow

### Flow 1: Child Plays Letter Recognition Game

```
1. Child selects "Letter Match" game in app
   ↓
2. App sends WebSocket message to Game API Gateway
   ↓
3. Gateway emits: appautis.game.letter.match.requested
   ↓
4. Letter Recognition Function processes request
   ↓
5. Function emits: appautis.game.answer.validated
   ↓
6. Scoring Agent calculates score
   ↓
7. Progress Tracker updates child's progress
   ↓
8. Tutor Agent (optional) receives progress update
   ↓
9. Gateway sends result to child via WebSocket
   ↓
10. App displays result with celebration animation
```

### Flow 2: Child Requests Help via WhatsApp

```
1. Child messages tutor on WhatsApp
   ↓
2. agents-whatsapp-rust receives message
   ↓
3. Agent Gateway routes to child's tutor agent
   ↓
4. Tutor Agent receives: appautis.game.question.asked
   ↓
5. Tutor Agent processes with LLM, retrieves child's context
   ↓
6. Tutor Agent emits: appautis.tutor.message.response
   ↓
7. Agent Gateway receives response
   ↓
8. agents-whatsapp-rust sends message to child via WhatsApp
   ↓
9. Child receives helpful response from tutor
```

### Flow 3: Multiplayer Word Relay Game

```
1. Child 1 requests multiplayer game
   ↓
2. Multiplayer Coordinator receives match request
   ↓
3. Coordinator matches children (age + skill level)
   ↓
4. Coordinator creates game session
   ↓
5. Coordinator emits: appautis.multiplayer.session.created
   ↓
6. Both children receive session info via WebSocket
   ↓
7. Children play cooperatively
   ↓
8. Each action emits: appautis.multiplayer.game.action
   ↓
9. Coordinator synchronizes state
   ↓
10. Coordinator emits: appautis.multiplayer.game.state.updated
    ↓
11. Both children receive updated game state
    ↓
12. Game completes, Scoring Agent calculates team score
    ↓
13. Progress Tracker updates both children's progress
```

### Flow 4: Tutor Provides In-Game Hint

```
1. Child struggling with activity (multiple wrong attempts)
   ↓
2. Game logic detects struggle
   ↓
3. Game emits: appautis.game.struggling
   ↓
4. Child's Tutor Agent receives event
   ↓
5. Tutor Agent analyzes child's performance history
   ↓
6. Tutor Agent generates helpful hint
   ↓
7. Tutor Agent emits: appautis.tutor.hint.provided
   ↓
8. Game API Gateway receives hint
   ↓
9. Gateway sends hint to child via WebSocket
   ↓
10. App displays hint in friendly, non-intrusive way
```

---

## 📡 CloudEvents Specification

All events follow CloudEvents 1.0 specification:

```json
{
  "specversion": "1.0",
  "type": "appautis.game.completed",
  "source": "/app-autis/game-logic/letter-match",
  "id": "event-uuid-here",
  "time": "2025-01-27T10:00:00Z",
  "datacontenttype": "application/json",
  "data": {
    "childId": "child-123",
    "gameId": "letter-match-001",
    "score": 85,
    "correctAnswers": 8,
    "totalQuestions": 10,
    "durationSeconds": 120
  }
}
```

### Event Types

#### Game Events

| Event Type | Description | Producer | Consumer |
|------------|-------------|----------|----------|
| `appautis.game.started` | Game session started | Game API Gateway | Progress Tracker, Tutor Agent |
| `appautis.game.completed` | Game session completed | Game Logic Functions | Scoring Agent, Progress Tracker |
| `appautis.game.answer.submitted` | Answer submitted | Game API Gateway | Game Logic Functions |
| `appautis.game.answer.validated` | Answer validated | Game Logic Functions | Scoring Agent |
| `appautis.game.help.requested` | Help button clicked | Game API Gateway | Tutor Agent |
| `appautis.game.struggling` | Child struggling detected | Game Logic Functions | Tutor Agent |
| `appautis.game.question.asked` | Question via WhatsApp | agents-whatsapp-rust | Tutor Agent |

#### Tutor Events

| Event Type | Description | Producer | Consumer |
|------------|-------------|----------|----------|
| `appautis.tutor.message.response` | Tutor response message | Tutor Agent | agents-whatsapp-rust |
| `appautis.tutor.hint.provided` | In-game hint provided | Tutor Agent | Game API Gateway |
| `appautis.tutor.encouragement.sent` | Encouragement message | Tutor Agent | agents-whatsapp-rust |
| `appautis.tutor.activity.suggested` | Activity suggestion | Tutor Agent | Game API Gateway |

#### Progress Events

| Event Type | Description | Producer | Consumer |
|------------|-------------|----------|----------|
| `appautis.progress.updated` | Progress updated | Progress Tracker | Tutor Agent, Parent Dashboard |
| `appautis.progress.milestone.reached` | Milestone achieved | Progress Tracker | Scoring Agent, Tutor Agent |
| `appautis.progress.report.generated` | Progress report ready | Progress Tracker | Parent Dashboard |

#### Scoring Events

| Event Type | Description | Producer | Consumer |
|------------|-------------|----------|----------|
| `appautis.score.calculated` | Score calculated | Scoring Agent | Progress Tracker |
| `appautis.achievement.unlocked` | Achievement unlocked | Scoring Agent | Tutor Agent, Parent Dashboard |
| `appautis.points.awarded` | Points awarded | Scoring Agent | Progress Tracker |
| `appautis.leaderboard.updated` | Leaderboard updated | Scoring Agent | Game API Gateway |

#### Multiplayer Events

| Event Type | Description | Producer | Consumer |
|------------|-------------|----------|----------|
| `appautis.multiplayer.match.requested` | Matchmaking request | Game API Gateway | Multiplayer Coordinator |
| `appautis.multiplayer.session.created` | Game session created | Multiplayer Coordinator | Game API Gateway |
| `appautis.multiplayer.game.action` | Player action | Game API Gateway | Multiplayer Coordinator |
| `appautis.multiplayer.game.state.updated` | Game state updated | Multiplayer Coordinator | Game API Gateway |
| `appautis.multiplayer.player.joined` | Player joined session | Multiplayer Coordinator | Game API Gateway |
| `appautis.multiplayer.player.left` | Player left session | Game API Gateway | Multiplayer Coordinator |

---

## 💾 Data Storage

### MongoDB

**Purpose**: Game data, user profiles, game sessions

**Collections**:
- `children`: Child profiles, preferences, settings
- `parents`: Parent/educator accounts
- `games`: Game definitions, levels, activities
- `sessions`: Active game sessions
- `conversations`: Tutor conversation history

**Indexes**:
- `children.childId` (unique)
- `sessions.childId`, `sessions.gameId`
- `conversations.childId`, `conversations.timestamp`

---

### PostgreSQL

**Purpose**: Learning progress, analytics, long-term data

**Tables**:
- `progress`: Child progress records
- `scores`: Game scores and achievements
- `learning_paths`: Personalized learning paths
- `tutor_memory`: Long-term tutor agent memory
- `analytics`: Aggregated analytics data

**Indexes**:
- `progress.child_id`, `progress.skill_id`, `progress.date`
- `scores.child_id`, `scores.game_id`, `scores.date`
- `tutor_memory.child_id`, `tutor_memory.timestamp`

---

### Redis

**Purpose**: Caching, sessions, real-time data

**Keys**:
- `session:{child-id}`: Active game session data
- `leaderboard:{game-id}`: Leaderboard cache
- `matchmaking:queue`: Multiplayer matchmaking queue
- `tutor:context:{child-id}`: Tutor agent short-term context

**TTL**: Most keys expire after 24 hours

---

### MinIO (S3-Compatible)

**Purpose**: Media storage

**Buckets**:
- `appautis-voice`: Voice recordings for pronunciation validation
- `appautis-media`: Images, videos, audio for games
- `appautis-avatars`: Child avatar images

---

## 🔗 Integration Points

### agents-whatsapp-rust Integration

#### Messaging Service
- **Endpoint**: WebSocket at `wss://messaging.appautis.svc.cluster.local`
- **Purpose**: Real-time game communication
- **Protocol**: Custom message protocol over WebSocket
- **Authentication**: JWT tokens

#### Agent Gateway
- **CloudEvents Integration**: Routes WhatsApp messages to tutor agents
- **Event Mapping**:
  - WhatsApp message received → `appautis.game.question.asked`
  - Tutor response → Send via WhatsApp API

#### Message Storage Service
- **Purpose**: Persist tutor conversations
- **Database**: MongoDB (shared with AppAutis)
- **Collection**: `conversations`

### Knative Lambda Operator

#### LambdaAgent Deployment
- **CRD**: `lambda.knative.io/v1alpha1/LambdaAgent`
- **Auto-scaling**: Knative Serving handles scaling
- **Eventing**: Automatic Broker and Trigger creation
- **Observability**: Automatic metrics and tracing injection

#### LambdaFunction Deployment
- **CRD**: `lambda.knative.io/v1alpha1/LambdaFunction`
- **Build Pipeline**: Kaniko builds from source code (stored in MinIO)
- **Source Storage**: MinIO bucket for function code
- **Runtime**: Python, Node.js, Go supported

---

## 🚀 Deployment Architecture

### Namespace Structure

```
app-autis/
├── tutor-agents/              # Per-child tutor agents
│   ├── tutor-agent-child-001/
│   ├── tutor-agent-child-002/
│   └── ...
├── game-logic/                # Game logic functions
│   ├── letter-recognition/
│   ├── word-building/
│   ├── sentence-formation/
│   └── pronunciation-validation/
├── coordination/              # Coordination agents
│   ├── multiplayer-coordinator/
│   ├── progress-tracker/
│   └── scoring-agent/
└── gateway/                   # API gateway
    └── game-api-gateway/
```

### GitOps Structure

```
app-autis/
├── k8s/
│   ├── kustomize/
│   │   ├── base/
│   │   │   ├── namespace.yaml
│   │   │   ├── rbac.yaml
│   │   │   ├── secrets.yaml
│   │   │   ├── configmap-system.yaml
│   │   │   ├── lambdaagent-multiplayer-coordinator.yaml
│   │   │   ├── lambdaagent-progress-tracker.yaml
│   │   │   ├── lambdaagent-scoring-agent.yaml
│   │   │   ├── lambdafunction-letter-recognition.yaml
│   │   │   ├── lambdafunction-word-building.yaml
│   │   │   ├── lambdafunction-sentence-formation.yaml
│   │   │   ├── lambdafunction-pronunciation-validation.yaml
│   │   │   ├── ksvc-game-api-gateway.yaml
│   │   │   └── kustomization.yaml
│   │   ├── pro/               # Development overlay
│   │   └── studio/            # Production overlay
│   └── tutor-agents/          # Per-child agents (managed dynamically)
│       └── templates/
│           └── tutor-agent-template.yaml
```

### Dynamic Agent Deployment

Tutor agents are deployed dynamically when a child is registered:

1. Parent/Educator registers child via API
2. API Gateway emits: `appautis.child.registered`
3. Agent Provisioner (LambdaFunction) receives event
4. Provisioner creates LambdaAgent CR from template
5. Knative Lambda Operator deploys agent
6. Agent becomes available for child

---

## 📊 Observability

### Metrics

#### Prometheus Metrics

**Game Metrics**:
- `appautis_games_started_total`: Total games started
- `appautis_games_completed_total`: Total games completed
- `appautis_game_duration_seconds`: Game duration histogram
- `appautis_answers_submitted_total`: Answers submitted
- `appautis_answers_correct_ratio`: Correct answer ratio

**Tutor Metrics**:
- `appautis_tutor_messages_sent_total`: Tutor messages sent
- `appautis_tutor_hints_provided_total`: Hints provided
- `appautis_tutor_response_time_seconds`: Response time histogram

**Progress Metrics**:
- `appautis_progress_updates_total`: Progress updates
- `appautis_milestones_reached_total`: Milestones reached
- `appautis_skills_mastered_total`: Skills mastered

**Multiplayer Metrics**:
- `appautis_multiplayer_sessions_active`: Active sessions
- `appautis_multiplayer_matches_created_total`: Matches created
- `appautis_multiplayer_latency_seconds`: Multiplayer latency

### Tracing

**OpenTelemetry Integration**:
- All LambdaAgents and LambdaFunctions emit traces
- Trace context propagated via CloudEvents
- End-to-end trace from client request to tutor response
- Stored in Tempo, visualized in Grafana

### Logging

**Structured Logging**:
- JSON format for all logs
- Trace context included in log entries
- Log levels: DEBUG, INFO, WARN, ERROR
- Stored in Loki, queried via LogQL

### Dashboards

**Grafana Dashboards**:
- Game activity dashboard
- Tutor agent performance
- Child progress overview
- Multiplayer session monitoring
- System health dashboard

---

## 🔒 Security

### Authentication & Authorization

#### Client Authentication
- **JWT Tokens**: Issued after parent/educator login
- **Child Sessions**: Child uses parent's token or separate child token
- **Token Refresh**: Automatic refresh before expiration

#### Service-to-Service
- **mTLS**: Linkerd service mesh provides automatic mTLS
- **RBAC**: Kubernetes RBAC for LambdaAgent permissions
- **Service Accounts**: Each agent has dedicated service account

### Data Privacy

#### Children's Data (COPPA Compliance)
- **Minimal Data Collection**: Only necessary data collected
- **Parental Consent**: Explicit consent required
- **Data Encryption**: Encryption at rest and in transit
- **Data Retention**: Configurable retention policies
- **Right to Delete**: Parents can request data deletion

#### Tutor Conversations
- **End-to-End Encryption**: WhatsApp provides E2EE
- **Storage**: Conversation history encrypted in MongoDB
- **Access Control**: Only child's tutor agent and authorized parents can access

### Network Security

#### Ingress
- **TLS Termination**: TLS 1.3 at ingress
- **Rate Limiting**: Per-IP and per-user rate limiting
- **DDoS Protection**: Cloud provider DDoS protection

#### Internal Communication
- **Service Mesh**: Linkerd for secure inter-service communication
- **Network Policies**: Kubernetes NetworkPolicies restrict traffic
- **Private Networking**: Services communicate via private cluster network

---

## 🔄 Future Enhancements

### Planned Features

1. **Voice Cloning for Tutors**: Personalized tutor voice using child's preferred voice
2. **AR Integration**: Augmented Reality activities for immersive learning
3. **Advanced Analytics**: ML-based learning path optimization
4. **Parent Dashboard**: Comprehensive web dashboard for parents/educators
5. **Educator Tools**: Tools for educators to create custom activities
6. **Offline Mode**: Enhanced offline gameplay support
7. **Multi-language Support**: Support for multiple languages

### Scalability Considerations

- **Horizontal Scaling**: All components scale horizontally
- **Caching Strategy**: Aggressive caching for frequently accessed data
- **CDN Integration**: Static assets served via CDN
- **Database Sharding**: MongoDB sharding for large-scale deployments
- **Regional Deployment**: Multi-region deployment for global scale

---

**Next Steps**:
1. Implement core LambdaAgents (Tutor, Multiplayer Coordinator, Progress Tracker, Scoring)
2. Implement game logic LambdaFunctions
3. Integrate with agents-whatsapp-rust
4. Build Game API Gateway
5. Set up data stores and observability
6. Deploy to development environment
7. Test end-to-end flows
8. Iterate based on testing

---

**Status**: 🟡 Architecture Design Phase  
**Version**: 0.1.0  
**Last Updated**: January 2025

