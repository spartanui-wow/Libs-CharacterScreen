# CharacterFrame Reference Guide

This document serves as a reference for the Blizzard CharacterFrame structure and components that LibCS can reuse and enhance.

## Frame Hierarchy

### Main CharacterFrame
- **CharacterFrame** - Main frame container (ButtonFrameTemplate)
  - **CharacterFrameInset** - Main content area
  - **CharacterFrameInsetRight** - Right panel area
  - **CharacterFramePortrait** - Character portrait (we hide this)
  - **CharacterFrameTitleText** - Title text (player name)
  - **CharacterLevelText** - Level text
  - **CharacterFrameCloseButton** - Close button
  - **CharacterFrameTab1-3** - Bottom tabs (Character, Reputation, Currency)

### PaperDollFrame (Main Equipment View)
- **PaperDollFrame** - Equipment layout container
  - **PaperDollItemsFrame** - Container for all equipment slots
  - **CharacterModelScene** - 3D character model
  - **CharacterStatsPane** - Stats panel on the right

### Equipment Slots Structure

#### Left Side Slots (PaperDollItemSlotButtonLeftTemplate)
```
CharacterHeadSlot          (Slot ID: 1)  - HEADSLOT
CharacterNeckSlot          (Slot ID: 2)  - NECKSLOT
CharacterShoulderSlot      (Slot ID: 3)  - SHOULDERSLOT
CharacterBackSlot          (Slot ID: 15) - BACKSLOT
CharacterChestSlot         (Slot ID: 5)  - CHESTSLOT
CharacterShirtSlot         (Slot ID: 4)  - SHIRTSLOT
CharacterTabardSlot        (Slot ID: 19) - TABARDSLOT
CharacterWristSlot         (Slot ID: 9)  - WRISTSLOT
```

#### Right Side Slots (PaperDollItemSlotButtonRightTemplate)  
```
CharacterHandsSlot         (Slot ID: 10) - HANDSSLOT
CharacterWaistSlot         (Slot ID: 6)  - WAISTSLOT
CharacterLegsSlot          (Slot ID: 7)  - LEGSSLOT
CharacterFeetSlot          (Slot ID: 8)  - FEETSLOT
CharacterFinger0Slot       (Slot ID: 11) - FINGER0SLOT
CharacterFinger1Slot       (Slot ID: 12) - FINGER1SLOT
CharacterTrinket0Slot      (Slot ID: 13) - TRINKET0SLOT
CharacterTrinket1Slot      (Slot ID: 14) - TRINKET1SLOT
```

#### Bottom Slots (PaperDollItemSlotButtonTemplate)
```
CharacterMainHandSlot      (Slot ID: 16) - MAINHANDSLOT
CharacterSecondaryHandSlot (Slot ID: 17) - SECONDARYHANDSLOT
CharacterRangedSlot        (Slot ID: 18) - RANGEDSLOT
```

### Equipment Slot Button Components
Each equipment slot inherits from `PaperDollItemSlotButtonTemplate` and includes:
- **icon** - Item icon texture
- **IconBorder** - Quality border
- **Count** - Stack count (if applicable)
- **Stock** - Stock overlay
- **ignoreTexture** - Ignore item overlay
- **Cooldown** - Cooldown spiral
- **popoutButton** - Equipment flyout button
- **SocketDisplay** - Gem socket display frame
  - **Slot1-3** - Individual socket slots with Gem textures

### Character Model Scene
- **CharacterModelScene** - 3D model container
  - Uses ModelSceneMixin
  - Can be refreshed with `:RefreshUnit()`
  - Supports camera controls and animations

### Stats Panel (CharacterStatsPane)
- **CharacterStatsPane** - Right-side stats container
- **ClassBackground** - Background texture for class
- Various stat frames and labels

## Key Events and Hooks

### CharacterFrame Events
- `UNIT_NAME_UPDATE` - Player name changed
- `PLAYER_PVP_RANK_CHANGED` - PvP rank changed
- `PLAYER_TALENT_UPDATE` - Talents changed
- `ACTIVE_TALENT_GROUP_CHANGED` - Spec changed
- `UNIT_PORTRAIT_UPDATE` - Portrait needs update
- `PORTRAITS_UPDATED` - All portraits updated

### Equipment Events
- `PLAYER_EQUIPMENT_CHANGED` - Equipment slot changed
- `BAG_UPDATE` - Bag contents changed (affects equipment)
- `UNIT_INVENTORY_CHANGED` - Unit inventory changed
- `ITEM_LOCKED` / `ITEM_UNLOCKED` - Item lock state
- `SOCKET_INFO_UPDATE` - Socket information changed

## Existing Functions We Can Hook/Override

### Frame Management
- `CharacterFrame_OnLoad()` - Frame initialization
- `CharacterFrame_OnShow()` - Frame shown
- `CharacterFrame_OnHide()` - Frame hidden
- `CharacterFrame_Expand()` - Expand frame width
- `CharacterFrame_Collapse()` - Collapse frame width

### Equipment Slot Functions
- `PaperDollItemSlotButton_OnLoad()` - Slot initialization
- `PaperDollItemSlotButton_OnEvent()` - Slot events
- `PaperDollItemSlotButton_OnShow()` - Slot shown
- `PaperDollItemSlotButton_OnEnter()` - Tooltip display
- `PaperDollItemSlotButton_OnLeave()` - Hide tooltip
- `PaperDollItemSlotButton_OnClick()` - Slot clicked

### Model Functions
- `Model_OnLoad()` - Model initialization
- `Model_OnShow()` - Model shown
- `Model_RefreshUnit()` - Refresh character model

## Reusable Components for LibCS

### What We Should Reuse:
1. **Equipment Slot Frames** - Enhance existing slots instead of creating new ones
2. **CharacterModelScene** - Modify existing model instead of creating custom
3. **Tooltip System** - Hook into existing tooltip functions
4. **Event System** - Use existing equipment/character events
5. **Layout Framework** - Work with existing positioning

### What We Can Safely Hide/Modify:
1. **CharacterFramePortrait** - Hidden, replaced with enhanced model
2. **CharacterFrameInset borders** - Can be hidden for custom styling
3. **Slot frame backgrounds** - Can be hidden for custom circular masks
4. **Stats panel positioning** - Can be repositioned
5. **Background textures** - Can be replaced with dynamic backgrounds

### What We Should Avoid:
1. **Core frame structure** - Don't recreate CharacterFrame itself
2. **Tab system** - Reuse existing tab framework
3. **Close/minimize buttons** - Keep existing functionality
4. **Core equipment logic** - Hook into rather than replace

## LibCS Integration Points

### FrameManager Module
- Modifies `CharacterFrame` positioning and sizing
- Hides unwanted border elements
- Repositions equipment slots
- Applies background textures

### Equipment Module  
- Enhances existing `Character*Slot` frames
- Adds circular masks to existing icon textures
- Hooks tooltip functions for additional info
- Applies highlight effects to existing slots

### Portrait Module
- Enhances `CharacterModelScene` rather than replacing
- Updates existing title/level text elements
- Applies dynamic backgrounds to frame
- Uses existing model refresh functions

## File Locations (Reference Only)
- CharacterFrame.lua - Main frame logic
- CharacterFrame.xml - Frame structure
- PaperDollFrame.lua - Equipment and stats logic  
- PaperDollFrame.xml - Equipment slot definitions
- Model.lua - 3D model handling