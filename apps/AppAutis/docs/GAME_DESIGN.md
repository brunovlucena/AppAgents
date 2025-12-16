# 🎮 AppAutis - Game Design Document

> **Version**: 0.1.0  
> **Status**: Design Phase  
> **Last Updated**: January 2025

## 📋 Table of Contents

1. [Game Overview](#game-overview)
2. [Core Game Mechanics](#core-game-mechanics)
3. [Game Types & Activities](#game-types--activities)
4. [User Flows](#user-flows)
5. [Scoring & Progression](#scoring--progression)
6. [Multiplayer Design](#multiplayer-design)
7. [Tutor Agent Integration](#tutor-agent-integration)
8. [UI/UX Design Principles](#uiux-design-principles)
9. [Learning Progression Path](#learning-progression-path)
10. [Accessibility & Customization](#accessibility--customization)

---

## 🎯 Game Overview

### Vision Statement
AppAutis creates a safe, engaging, and adaptive learning environment where autistic children can develop reading and speaking skills at their own pace, with personalized AI tutor support and positive peer interactions.

### Core Learning Objectives
1. **Letter Recognition**: Identify and match letters to sounds
2. **Phonics**: Understand letter-sound relationships
3. **Word Building**: Construct words from letters
4. **Vocabulary**: Learn and remember new words
5. **Sentence Formation**: Build grammatically correct sentences
6. **Reading Comprehension**: Understand and answer questions about text
7. **Pronunciation**: Produce clear, accurate speech sounds
8. **Verbal Communication**: Express ideas verbally

### Target Audience
- **Primary**: Autistic children aged 4-12
- **Secondary**: Parents, educators, therapists
- **Learning Levels**: Pre-readers to early readers (various skill levels)

---

## 🎲 Core Game Mechanics

### 1. Drag-and-Drop Interaction
- **Purpose**: Match letters, words, or images
- **Implementation**: Visual drag from source to target areas
- **Feedback**: 
  - Correct: Visual celebration (gentle animation, positive sound)
  - Incorrect: Gentle shake animation, opportunity to try again
- **Accessibility**: Can also use tap-to-select and tap-to-place for motor difficulties

### 2. Voice Recognition
- **Purpose**: Practice pronunciation and speaking
- **Implementation**: Child speaks into device, system recognizes and validates
- **Feedback**: 
  - Clear pronunciation: Green checkmark, positive sound
  - Needs improvement: Friendly visual hint showing correct pronunciation
- **Difficulty Levels**: 
  - Level 1: Accepts approximate pronunciation
  - Level 2: Requires clearer articulation
  - Level 3: Accurate pronunciation required

### 3. Progressive Disclosure
- **Purpose**: Reduce cognitive overload
- **Implementation**: Show one task at a time, unlock next task upon completion
- **Visual**: Clear completion indicator, smooth transitions

### 4. Immediate Feedback
- **Purpose**: Reinforce learning, build confidence
- **Implementation**: Instant visual and audio feedback for every action
- **Positive Reinforcement**: Always encouraging, never punitive

### 5. Repetition with Variation
- **Purpose**: Master skills through varied practice
- **Implementation**: Same concept presented in different formats and contexts
- **Spacing**: Activities spaced to reinforce memory retention

---

## 🎮 Game Types & Activities

### Level 1: Letter Recognition

#### Game 1.1: "Letter Match"
- **Objective**: Match uppercase and lowercase letters
- **Mechanics**: Drag lowercase letter to matching uppercase letter
- **Visual**: Large, colorful letters with friendly characters associated (A for Apple, B for Bear)
- **Feedback**: Character animation when matched correctly
- **Adaptation**: Can work with just uppercase or just lowercase if preferred

#### Game 1.2: "Sound Match"
- **Objective**: Match letters to their sounds
- **Mechanics**: Listen to sound, tap the correct letter
- **Visual**: Letter cards with associated images
- **Audio**: Clear pronunciation of letter sound
- **Adaptation**: Can show image hints for visual learners

#### Game 1.3: "Letter Hunt"
- **Objective**: Find specific letters in a visual scene
- **Mechanics**: Tap all instances of a target letter in an image
- **Visual**: Engaging scenes (zoo, farm, space) with letters hidden in objects
- **Feedback**: Items light up when correct letter is found

### Level 2: Phonics & Word Building

#### Game 2.1: "Build a Word"
- **Objective**: Construct words from letters
- **Mechanics**: Drag letters into slots to form words
- **Visual**: Picture of the word at top, letter slots below
- **Audio**: Word pronounced when completed correctly
- **Progression**: 3-letter words → 4-letter words → 5+ letter words

#### Game 2.2: "Rhyme Time"
- **Objective**: Identify rhyming words
- **Mechanics**: Match words that rhyme by tapping pairs
- **Visual**: Word cards with images, gentle animation on matches
- **Audio**: Words read aloud to emphasize rhyme pattern

#### Game 2.3: "Word Family Builder"
- **Objective**: Learn word families (-at, -an, -og, etc.)
- **Mechanics**: Change initial letter to create new words in same family
- **Visual**: Interactive word family tree
- **Example**: cat → bat → hat → mat (all -at family)

### Level 3: Sentence Formation

#### Game 3.1: "Sentence Builder"
- **Objective**: Arrange words to form sentences
- **Mechanics**: Drag word cards into correct order
- **Visual**: Picture showing the sentence meaning
- **Grammar Hints**: Color-coding (noun=blue, verb=green, etc.)
- **Audio**: Sentence read aloud when completed

#### Game 3.2: "Fill the Blank"
- **Objective**: Complete sentences with missing words
- **Mechanics**: Select correct word from options to fill blank
- **Visual**: Multiple choice with word cards and images
- **Audio**: Sentence read with blank, then completed version

#### Game 3.3: "Sentence Stories"
- **Objective**: Build a short story from sentence pieces
- **Mechanics**: Arrange sentences to create logical story sequence
- **Visual**: Story scenes appear as sentences are arranged
- **Reward**: Complete story plays as animation when finished

### Level 4: Reading Comprehension

#### Game 4.1: "Read & Answer"
- **Objective**: Read short sentences and answer questions
- **Mechanics**: Read sentence, tap correct answer from multiple choice
- **Visual**: Simple, clear text with picture support
- **Audio**: Option to hear sentence read aloud
- **Adaptation**: Can adjust text size and spacing

#### Game 4.2: "Story Sequence"
- **Objective**: Understand story order and sequence
- **Mechanics**: Arrange story panels in correct order
- **Visual**: Picture story panels
- **Audio**: Each panel can be read aloud

#### Game 4.3: "Reading Detective"
- **Objective**: Find specific information in text
- **Mechanics**: Read short passage, answer "who/what/where/when" questions
- **Visual**: Highlighted text clues
- **Support**: Tutor agent provides hints if needed

### Level 5: Pronunciation & Speaking

#### Game 5.1: "Speak the Word"
- **Objective**: Pronounce words correctly
- **Mechanics**: Child sees word with picture, speaks it into device
- **Feedback**: 
  - Accurate: Celebration animation
  - Needs work: Visual guide showing mouth shape
- **Difficulty**: Accepts approximations initially, becomes more precise

#### Game 5.2: "Sentence Speaker"
- **Objective**: Read and speak complete sentences
- **Mechanics**: Child reads sentence aloud, system validates
- **Support**: Can hear sentence first, then practice
- **Feedback**: Encouraging, non-judgmental responses

#### Game 5.3: "Story Narrator"
- **Objective**: Read a short story aloud
- **Mechanics**: Child narrates story page by page
- **Reward**: Story animation plays as reward
- **Flexibility**: Can skip difficult words, focus on overall flow

### Bonus Activities

#### "Daily Challenge"
- **Objective**: Special daily activity combining multiple skills
- **Reward**: Bonus points, special badge
- **Variety**: Different challenge each day

#### "Free Play"
- **Objective**: Explore letters, words, and sounds without pressure
- **Mechanics**: Interactive letter/word exploration
- **Support**: Tutor agent available for questions

---

## 🔄 User Flows

### Flow 1: First-Time User Onboarding

```
1. Welcome Screen
   ├─ Friendly character introduction
   ├─ Simple "Welcome to AppAutis!" message
   └─ Large "Start" button

2. Avatar Creation
   ├─ Choose character (predefined options)
   ├─ Choose colors/clothing
   └─ Name the avatar

3. Meet Your Tutor
   ├─ Introduction to personal AI tutor
   ├─ Tutor explains they're here to help
   └─ Test communication (tutor says hello)

4. Assessment (Optional)
   ├─ Quick assessment to determine starting level
   ├─ Parent/Educator can skip and set manually
   └─ Very simple: "Do you know these letters?"

5. First Game
   ├─ Tutor guides child through first game
   ├─ Gentle tutorial with clear instructions
   └─ Celebration after first success

6. Dashboard Overview
   ├─ Show available games
   ├─ Show progress indicators
   └─ Large, clear navigation
```

### Flow 2: Daily Game Session

```
1. Login/Dashboard
   ├─ Avatar welcome animation
   ├─ Daily goal reminder (gentle, not pressuring)
   └─ Show available games

2. Game Selection
   ├─ Browse games by level
   ├─ See which games are locked/unlocked
   ├─ See favorite games (quick access)
   └─ Select game

3. Game Play
   ├─ Game instructions (visual + audio)
   ├─ Play through activities
   ├─ Receive feedback for each action
   ├─ Can pause anytime
   └─ Can ask tutor for help

4. Game Completion
   ├─ Score celebration
   ├─ Points earned
   ├─ Progress update
   └─ Option to play again or choose new game

5. Progress Check
   ├─ Tutor summarizes what was learned
   ├─ Encourages child
   └─ Suggests next activity
```

### Flow 3: Multiplayer Session

```
1. Join Multiplayer
   ├─ Tutor explains multiplayer concept
   ├─ Child chooses: "Play with Friends" or "Find New Friends"
   └─ Age-appropriate matchmaking

2. Lobby/Waiting
   ├─ See other players' avatars
   ├─ Friendly waiting animations
   ├─ Can chat via pre-set messages (for safety)
   └─ Game starts when all ready

3. Cooperative Gameplay
   ├─ Team-based challenges
   ├─ Clear individual and team goals
   ├─ Support teammates through game actions
   └─ No competition, only cooperation

4. Completion
   ├─ Team celebration
   ├─ Individual contributions recognized
   └─ Option to play again together
```

### Flow 4: Tutor Interaction

```
1. Child Needs Help (In-Game)
   ├─ Tap "Help" button or tutor icon
   ├─ Tutor appears with friendly message
   ├─ Provides visual/verbal hint
   └─ Encourages child to try again

2. Child Asks Question (WhatsApp)
   ├─ Child messages tutor via WhatsApp
   ├─ Tutor responds with appropriate guidance
   ├─ May suggest specific games
   └─ Provides encouragement

3. Tutor Initiates (Proactive Support)
   ├─ Tutor notices child struggling
   ├─ Offers help: "Need a hint?"
   ├─ Respects if child says no
   └─ Celebrates when child succeeds independently
```

---

## 🏆 Scoring & Progression

### Scoring System

#### Points Structure
- **Correct Answer**: 10 points
- **Correct on First Try**: 5 bonus points
- **Perfect Game (100% correct)**: 50 bonus points
- **Daily Goal Achievement**: 100 bonus points
- **Multiplayer Participation**: 25 bonus points
- **Streak Bonus**: +1 point per consecutive day (max +30)

#### Scoring Philosophy
- **Always Positive**: No points deducted for wrong answers
- **Effort Rewarded**: Points for attempts, not just correctness
- **Progress Celebrated**: Milestone rewards are meaningful
- **Individual Focus**: Compares to own progress, not others

### Achievement System

#### Badges
- **Letter Master**: Complete all letter recognition games
- **Word Builder**: Construct 100 words correctly
- **Story Teller**: Complete 10 story activities
- **Daily Champion**: Play 7 days in a row
- **Team Player**: Complete 5 multiplayer games
- **Pronunciation Pro**: Achieve 90%+ accuracy on speaking games

#### Progress Indicators
- **Visual Progress Bars**: Clear visual representation
- **Level Stars**: Stars earned per level (1-3 stars)
- **Unlock System**: New games unlock as skills develop
- **Skill Trees**: Visual representation of learning paths

### Leveling System

#### Levels (1-10)
- **Level 1**: Letter Recognition Beginner
- **Level 2**: Letter Recognition Advanced
- **Level 3**: Phonics Beginner
- **Level 4**: Phonics Advanced
- **Level 5**: Word Building Beginner
- **Level 6**: Word Building Advanced
- **Level 7**: Sentence Formation
- **Level 8**: Reading Comprehension
- **Level 9**: Pronunciation Practice
- **Level 10**: Master Reader

#### Level Requirements
- Complete 80% of activities in current level
- Achieve minimum score threshold
- Complete assessment (optional but recommended)

---

## 👥 Multiplayer Design

### Design Principles
1. **Cooperative, Not Competitive**: Focus on working together
2. **Safe Environment**: All interactions moderated and safe
3. **Age-Appropriate Matching**: Children matched by age and skill level
4. **Clear Communication**: Pre-set messages, emoji reactions
5. **Respectful Play**: Built-in reminders about being kind

### Multiplayer Game Types

#### 1. "Word Relay"
- **Objective**: Team builds words together
- **Mechanics**: Each child adds a letter to build a word
- **Cooperation**: Must work together to complete word
- **Reward**: Team celebration when word is complete

#### 2. "Story Builder"
- **Objective**: Team creates a story together
- **Mechanics**: Each child adds a sentence to the story
- **Creativity**: Encourages creative expression
- **Visual**: Story appears as team builds it

#### 3. "Letter Hunt Race"
- **Objective**: Teams find letters in scenes
- **Mechanics**: Cooperative race (both teams can win)
- **Focus**: Finding letters together, not beating others
- **Celebration**: All participants celebrated

#### 4. "Pronunciation Circle"
- **Objective**: Practice speaking together
- **Mechanics**: Children take turns pronouncing words
- **Support**: Team encourages each speaker
- **Learning**: Children learn from each other

### Communication Features

#### Pre-Set Messages (Safety First)
- "Great job!"
- "You're doing well!"
- "Let's work together!"
- "Need help?"
- "Well done, team!"
- Emoji reactions: 👍, ❤️, 🎉

#### Parent/Educator Controls
- Can disable multiplayer if desired
- Can approve friends list
- Receive notifications about multiplayer participation
- Can review multiplayer session history

---

## 🤖 Tutor Agent Integration

### Tutor Personality
- **Friendly and Encouraging**: Always positive, never critical
- **Patient**: Understands that learning takes time
- **Supportive**: Offers help without pressure
- **Celebratory**: Enthusiastic about achievements
- **Adaptive**: Adjusts communication style to child's preferences

### Tutor Interactions

#### In-Game Interactions
1. **Greeting**: Tutor greets child when game starts
2. **Progress Acknowledgment**: "You're doing great!"
3. **Hint Offering**: "Would you like a hint?" (non-intrusive)
4. **Encouragement**: "You're getting closer!"
5. **Celebration**: "Amazing work! You did it!"

#### WhatsApp Interactions
1. **Daily Check-in**: Friendly morning message
2. **Progress Updates**: "You learned 3 new words today!"
3. **Answering Questions**: Child can ask anytime
4. **Activity Suggestions**: "Want to try a new game?"
5. **Encouragement Messages**: Support during difficult moments

### Tutor Capabilities

#### Personalization
- Learns child's preferred communication style
- Adapts difficulty recommendations
- Remembers favorite games and topics
- Recognizes when child is frustrated vs. engaged

#### Learning Support
- Provides hints without giving answers
- Breaks down complex tasks into steps
- Offers alternative explanations if child doesn't understand
- Celebrates small victories

#### Progress Tracking
- Monitors skill development
- Identifies areas needing more practice
- Suggests appropriate next steps
- Communicates progress to parents/educators (with permission)

### Tutor Communication Patterns

#### Proactive (Low Frequency)
- Daily welcome message
- Weekly progress summary
- Achievement celebrations

#### Reactive (On-Demand)
- Responds to child's questions immediately
- Provides hints when requested
- Offers help when child is struggling (detected through game metrics)

#### Respectful Boundaries
- Never interrupts active gameplay
- Waits for child to ask before providing extensive help
- Respects "not now" signals from child

---

## 🎨 UI/UX Design Principles

### Visual Design

#### Color Palette
- **Primary Colors**: Calm blues and greens (reduce overstimulation)
- **Accent Colors**: Warm yellows and oranges for celebrations
- **High Contrast**: Clear contrast for readability
- **Customizable**: Parent/child can adjust color intensity

#### Typography
- **Font Size**: Large, readable fonts (minimum 18pt)
- **Font Style**: Clear, simple sans-serif fonts
- **Line Spacing**: Generous spacing (1.5x minimum)
- **Letter Spacing**: Comfortable spacing between letters
- **Customizable**: Can adjust all text settings

#### Layout
- **Minimal Clutter**: Clean, uncluttered interfaces
- **Clear Hierarchy**: Most important information is most prominent
- **Consistent Navigation**: Same navigation in same place always
- **Predictable Patterns**: Similar actions look and behave similarly

#### Icons & Images
- **Clear Icons**: Simple, recognizable icons
- **Consistent Style**: All icons follow same visual style
- **Picture Support**: Images accompany text whenever possible
- **Friendly Characters**: Appealing but not overstimulating characters

### Interaction Design

#### Touch Targets
- **Large Touch Areas**: Minimum 44x44pt for easy tapping
- **Spacing**: Adequate space between interactive elements
- **Visual Feedback**: Clear indication when element is tapped
- **No Accidental Clicks**: Confirmation for important actions

#### Animations
- **Purposeful**: Animations serve a purpose (feedback, transitions)
- **Gentle**: Smooth, not jarring
- **Optional**: Can be reduced or disabled
- **Predictable**: Consistent animation patterns

#### Feedback
- **Immediate**: Every action has immediate feedback
- **Clear**: Obvious what happened (success/failure)
- **Positive**: Focus on what went right
- **Encouraging**: Never punitive or negative

### Navigation

#### Main Navigation
- **Simple Structure**: Clear, flat navigation structure
- **Visual Breadcrumbs**: Always show where you are
- **Back Button**: Always visible and accessible
- **Home Button**: Easy return to main menu

#### Game Navigation
- **Clear Instructions**: Visual + audio instructions
- **Progress Indicator**: Show where you are in activity
- **Pause Button**: Always accessible
- **Help Button**: Easy access to tutor help

### Accessibility Features

#### Visual
- **High Contrast Mode**: High contrast for visual clarity
- **Text Size Control**: Adjustable text sizes
- **Color Blind Friendly**: Don't rely solely on color
- **Reduced Motion**: Option to minimize animations

#### Auditory
- **Volume Control**: Adjustable sound levels
- **Mute Option**: Can disable sounds
- **Visual Audio Indicators**: Visual cues for audio feedback
- **Text-to-Speech**: All text can be read aloud

#### Motor
- **Alternative Input**: Multiple ways to interact (touch, voice, switch)
- **No Time Pressure**: No timed activities (unless child opts in)
- **Large Targets**: Easy to tap/click
- **Motor Accommodations**: Settings for fine motor difficulties

#### Cognitive
- **Simplified Language**: Clear, simple instructions
- **Visual Supports**: Pictures with text
- **Consistent Patterns**: Predictable interface patterns
- **Error Prevention**: Clear warnings before important actions

---

## 📈 Learning Progression Path

### Beginner Path (Pre-Reader)

```
Start → Letter Recognition
  ├─ Match uppercase/lowercase
  ├─ Identify letter sounds
  └─ Find letters in scenes
    ↓
Simple Phonics
  ├─ Sound-letter matching
  ├─ Beginning sounds
  └─ Ending sounds
    ↓
Basic Word Building
  ├─ 3-letter words (CVC)
  ├─ Simple sight words
  └─ Word families
```

### Intermediate Path (Early Reader)

```
Continue from Beginner Path
    ↓
Advanced Word Building
  ├─ 4-5 letter words
  ├─ Blends and digraphs
  └─ Compound words
    ↓
Sentence Formation
  ├─ Word order
  ├─ Basic grammar
  └─ Simple sentences
    ↓
Early Reading Comprehension
  ├─ Answer questions about sentences
  ├─ Identify story elements
  └─ Sequence events
```

### Advanced Path (Developing Reader)

```
Continue from Intermediate Path
    ↓
Complex Sentence Building
  ├─ Longer sentences
  ├─ Different sentence types
  └─ Story sentences
    ↓
Reading Comprehension
  ├─ Read short stories
  ├─ Answer comprehension questions
  └─ Make predictions
    ↓
Pronunciation & Fluency
  ├─ Read words aloud
  ├─ Read sentences aloud
  └─ Read stories aloud
```

### Adaptive Progression
- **Skill-Based**: Child advances when skill is mastered, not just time spent
- **Flexible**: Can review previous levels anytime
- **Personalized**: Path adjusts based on child's strengths and challenges
- **No Pressure**: Child can stay at comfortable level as long as needed

---

## ⚙️ Accessibility & Customization

### Parent/Educator Settings

#### Difficulty Settings
- **Easy Mode**: More hints, accepts approximations
- **Standard Mode**: Balanced difficulty
- **Advanced Mode**: More challenging, requires accuracy
- **Custom**: Mix and match specific settings

#### Content Settings
- **Game Selection**: Enable/disable specific games
- **Topic Selection**: Choose topics of interest
- **Length Control**: Set session length limits
- **Content Filter**: Ensure all content is appropriate

#### Tutor Settings
- **Tutor Frequency**: How often tutor initiates contact
- **Hint Level**: How much help tutor provides
- **Communication Style**: Formal vs. casual tutor language
- **Notification Settings**: Control tutor notifications

#### Multiplayer Settings
- **Enable/Disable**: Turn multiplayer on/off
- **Friend Approval**: Approve friends before they can play together
- **Session Limits**: Set time limits for multiplayer
- **Communication Controls**: Control what child can send

### Child Customization

#### Avatar Customization
- **Character Selection**: Choose character appearance
- **Color Preferences**: Select favorite colors
- **Accessories**: Customize avatar accessories
- **Name**: Give avatar a name

#### Visual Preferences
- **Color Themes**: Choose preferred color scheme
- **Background Music**: Enable/disable background music
- **Sound Effects**: Adjust sound effect levels
- **Animations**: Control animation intensity

#### Learning Preferences
- **Preferred Games**: Favorite games for quick access
- **Learning Style**: Visual, auditory, or kinesthetic focus
- **Pace Preference**: Slower or faster progression
- **Reward Preferences**: Preferred types of rewards

---

## 🎯 Success Metrics

### Learning Metrics
- **Skill Mastery**: Percentage of skills mastered
- **Progress Rate**: Rate of skill acquisition
- **Retention**: Skills retained over time
- **Accuracy Improvement**: Improvement in accuracy over time

### Engagement Metrics
- **Session Frequency**: How often child plays
- **Session Duration**: Average time per session
- **Game Completion**: Percentage of games completed
- **Return Rate**: Child returns to play again

### Satisfaction Metrics
- **Enjoyment**: Child's reported enjoyment
- **Tutor Satisfaction**: Satisfaction with tutor interactions
- **Parent/Educator Satisfaction**: Satisfaction with child's progress
- **Recommendation**: Would recommend to others

---

## 🔄 Iteration & Improvement

### Regular Updates
- **New Games**: Regular addition of new game types
- **Content Updates**: Fresh content to maintain interest
- **Feature Improvements**: Based on user feedback
- **Bug Fixes**: Continuous improvement of stability

### Feedback Loops
- **In-App Feedback**: Easy way for parents/educators to provide feedback
- **User Testing**: Regular testing with autistic children
- **Expert Review**: Input from educators and therapists
- **Data Analysis**: Learn from usage patterns

### Research Integration
- **Stay Current**: Integrate latest research on autism education
- **Evidence-Based**: All features backed by research
- **Collaboration**: Work with autism education experts
- **Continuous Learning**: Regular review of best practices

---

**Next Steps**: 
1. Create detailed wireframes for key screens
2. Develop prototype for core gameplay loop
3. User testing with target audience
4. Refine based on feedback
5. Begin technical architecture documentation

---

**Status**: 🟡 Design Phase - Iterating based on feedback  
**Version**: 0.1.0  
**Last Updated**: January 2025

