# CLAUDE.md - Lib's Character Screen

This file covers Libs-CharacterScreen-specific guidance. It **inherits** all shared rules from the root `C:\code\CLAUDE.md` and `C:\code\.context\` files - do not duplicate content that lives there.

## Project Overview

**Lib's Character Screen** is a WoW addon that enhances the default character screen interface. It replaces the standard character frame with a custom UI featuring improved equipment visualization, dynamic backgrounds, and better layout.

## Architecture

This addon uses the **correct Ace3 sub-module pattern** (14 modules with proper lifecycle hooks). See `ace3-guide.md` for the pattern details.

```
Libs-CharacterScreen/
├── Libs-CharacterScreen.toc   # Interface metadata, load order
├── core/
│   ├── Framework.lua          # Main addon: NewAddon + SetDefaultModuleLibraries
│   ├── Database.lua           # Database module (AceDB setup)
│   ├── FrameManager.lua       # Character frame creation/management
│   ├── Core.lua               # Core logic module
│   ├── Equipment.lua          # Gear slot buttons, tooltips, icons
│   ├── Portrait.lua           # 3D model display, header/footer
│   ├── Stats.lua              # Character stats display
│   ├── CircularStats.lua      # Circular stat visualization
│   ├── MythicPlus.lua         # M+ score/rating display
│   ├── RaidProgress.lua       # Raid progress tracking
│   ├── Notifications.lua      # Update notifications
│   ├── LootSpec.lua           # Loot specialization display
│   ├── Reputation.lua         # Reputation display
│   ├── AddonIntegration.lua   # Integration with Pawn, Narcissus, Simulationcraft
│   └── Settings.lua           # Configuration module
├── media/                     # Textures, masks, UI elements
│   ├── masks/                 # Mask textures for visual effects
│   ├── frame/                 # Frame border and background textures
│   └── DressingRoom/          # Character customization UI elements
└── libs/                      # Ace3, LibSharedMedia, LibCompress
```

### Key Data Structures

- **DBDefaults**: Configuration defaults (background, padding, scaling)
- **SpecializationVisuals**: Maps spec IDs to background texture names
- **slotArrangement**: Equipment slot positioning (left, right, bottom)

### Events

- `UNIT_MODEL_CHANGED`, `ACTIVE_PLAYER_SPECIALIZATION_CHANGED`, `UNIT_LEVEL`, `UNIT_NAME_UPDATE`

## Dependencies

- **Ace3**: Core addon framework
- **LibSharedMedia-3.0**: Media resource management
- **LibCompress**: Data compression

## Testing

Use `/libcs` command in-game to display the custom character frame.
