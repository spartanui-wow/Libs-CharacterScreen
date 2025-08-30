# LibCS Refactoring Plan

## Overview

Transform the monolithic `LibCS.lua` file into a modular Core + Modules architecture, switch from custom window creation to modifying the existing Blizzard CharacterFrame, and implement features identified in `ref.lua` as optional modules.

## Current Structure Analysis

### LibCS.lua Current Components

1. **Database/Configuration** - DB defaults and settings management
2. **Frame Stripping** - `Strip()` function that hides/modifies Blizzard UI elements
3. **Character Frame Creation** - `CreateNewCharacterFrame()` - creates entirely new window
4. **Portrait System** - `CreatePortrait()` - 3D character model with headers/footers
5. **Equipment Visualization** - `CreateGearManager()`, `CreateGearButton()` - custom gear slots
6. **Dynamic Backgrounds** - `GetDynamicBackground()` - specialization-based backgrounds
7. **Addon Integration** - `CheckAdditionalAddons()` - Pawn, Narcissus, SimC integration
8. **Event Handling** - Various WoW events for updates

### ref.lua Feature Analysis

1. **Major Faction Reputation System** - Shows expansion faction progress bars
2. **Equipment Enhancement Display** - Shows gems, enchants, durability, item quality
3. **Loot Specialization Selector** - Buttons to change loot spec
4. **Model Positioning** - Functions to move character model left/right
5. **Toast Notifications** - In-game notification system
6. **Advanced Item Analysis** - Detailed item parsing with tooltip scanning
7. **Character Stats Integration** - Extended character information display

## Refactoring Strategy

### Phase 1: Core Infrastructure

Create the foundational module system and convert to existing frame modification.

#### Core Components (Always Loaded)

- **Core.lua** - Main addon class, module loader, basic event handling
- **Database.lua** - Configuration management with AceDB
- **FrameManager.lua** - Blizzard CharacterFrame modification (replaces custom window)

#### Changes to Existing Approach

- **Remove**: `CreateNewCharacterFrame()` - stop creating new window
- **Replace with**: Modify existing `CharacterFrame` directly
- **Benefit**: Better compatibility with other addons, reduced maintenance

### Phase 2: Essential Modules (Always Loaded)

Convert current features into modules that are part of core functionality.

#### modules/Portrait.lua

- Character model display with gradients and masks
- Header/footer frames (name, level, spec, class)
- Dynamic background system based on specialization

#### modules/Equipment.lua

- Custom gear slot visualization with circular masks
- Equipment tooltips and highlighting
- Basic item display functionality

### Phase 3: Optional Feature Modules (Can be Disabled)

Implement features from `ref.lua` as optional modules.

#### modules/Reputation.lua

**Features from ref.lua:**

- `module.ReputationFrame_Update()` - Updates reputation displays
- `module.updatemajorfactions()` - Manages major faction progress
- Major faction progress bars with gradients and animations
- Support for: Dream Wardens, Loamm Niffen, Maruuk Centaur, etc.

#### modules/EnhancedEquipment.lua

**Features from ref.lua:**

- `module.updateLocationInfo()` - Enhanced item slot analysis
- `module.loopitems()` - Processes all equipment slots
- Gem socket display and status (empty/filled)
- Enchantment status and warnings
- Item durability indicators
- Quality-based background colors

#### modules/LootSpec.lua

**Features from ref.lua:**

- `module.sortAndOffset()` - Loot specialization UI
- Clickable specialization buttons
- Current vs available loot spec display
- Integration with character specialization system

#### modules/ModelControls.lua

**Features from ref.lua:**

- `module.MoveModelLeft()` / `module.MoveModelRight()` - Model positioning
- `module.Clicky()` - Model interaction system
- Dynamic model positioning based on UI layout

#### modules/Notifications.lua

**Features from ref.lua:**

- `module.ShowToast()` - Toast notification system
- In-game alert system for equipment/character changes

#### modules/AddonIntegration.lua

**Current LibCS.lua features:**

- Pawn, Narcissus, Simulationcraft integration
- Dynamic button positioning for third-party addons

### Phase 4: Configuration System

Each module should have its own configuration options that can be toggled.

#### Configuration Structure

```lua
LibCS.DB.modules = {
    reputation = { enabled = true, ... },
    enhancedEquipment = { enabled = true, showGems = true, showEnchants = true, ... },
    lootSpec = { enabled = false, ... },
    modelControls = { enabled = true, ... },
    notifications = { enabled = false, ... },
    addonIntegration = { enabled = true, supportedAddons = {...}, ... }
}
```

## Implementation Steps

### Step 1: Create Core Structure

1. Create `core/` and `modules/` directories
2. Split LibCS.lua into Core.lua, Database.lua, FrameManager.lua
3. Implement module loading system
4. Convert from custom window to CharacterFrame modification

### Step 2: Convert Existing Features to Modules

1. Create Portrait.lua module
2. Create Equipment.lua module
3. Create AddonIntegration.lua module
4. Test that existing functionality works

### Step 3: Implement Optional Modules

1. Create Reputation.lua with major faction features
2. Create EnhancedEquipment.lua with gem/enchant features
3. Create LootSpec.lua with specialization selection
4. Create ModelControls.lua with positioning features
5. Create Notifications.lua with toast system

### Step 4: Configuration UI

1. Implement per-module enable/disable options
2. Add module-specific configuration options
3. Create configuration UI using AceConfig

## File Structure After Refactoring

```
LibCS/
├── LibCS.lua (entry point - loads core)
├── core/
│   ├── Core.lua
│   ├── Database.lua
│   └── FrameManager.lua
└── modules/
    ├── Portrait.lua
    ├── Equipment.lua
    ├── AddonIntegration.lua
    ├── Reputation.lua (optional)
    ├── EnhancedEquipment.lua (optional)
    ├── LootSpec.lua (optional)
    ├── ModelControls.lua (optional)
    └── Notifications.lua (optional)
```

## Benefits of This Approach

1. **Modularity** - Features can be disabled if causing issues
2. **Maintainability** - Each feature isolated in its own file
3. **Compatibility** - Using existing CharacterFrame instead of custom window
4. **Extensibility** - Easy to add new modules
5. **Performance** - Optional modules can be disabled to save resources
6. **Testing** - Individual modules can be tested in isolation

## Migration Strategy

- Keep `ref.lua` unchanged during development for reference
- Implement new structure alongside existing code
- Test each module individually before removing old code
- Provide configuration options to switch between old/new systems during transition
