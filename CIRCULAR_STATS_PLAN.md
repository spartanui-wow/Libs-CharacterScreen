# Circular Stats Module Implementation Plan

## Overview
The CircularStats module will replace the traditional character stats display with modern circular progress indicators, positioned in the CharacterFrameInsetRight panel.

## Visual Design

### Circular Progress Rings
Each stat will be displayed as:
- **Center Circle**: Shows the stat name/icon and current value
- **Progress Ring**: Surrounds the circle showing 0-100% progress
- **Color Coding**: Changes color based on stat percentage thresholds

### Color Progression System
Progress ring colors change based on percentage:
- **Gray (0-10%)**: Base/low values - `{0.5, 0.5, 0.5}`
- **Green (10-20%)**: Good values - `{0, 1, 0}`
- **Blue (20-30%)**: Very good values - `{0, 0.5, 1}`
- **Purple (30-40%)**: Excellent values - `{0.7, 0, 1}`
- **Orange (40%+)**: Exceptional values - `{1, 0.5, 0}`

*Note: 40%+ is rare even for specialized builds, making orange a prestigious indicator*

## Stat Categories

### Primary Stats (Always Displayed)
- **Strength/Agility/Intellect**: Main attribute
- **Stamina**: Health pool
- **Armor**: Physical damage reduction

### Secondary Stats (Configurable)
- **Critical Strike**: Crit chance %
- **Haste**: Attack/cast speed %
- **Mastery**: Class-specific bonus %
- **Versatility**: Damage/healing done & damage taken %

### Optional Stats
- **Leech**: Self-healing %
- **Speed**: Movement speed %
- **Avoidance**: AoE damage reduction %

## Layout Configuration

### Grid System
- **Default Layout**: 2 columns, 4 rows
- **Circle Size**: 40px diameter (configurable)
- **Spacing**: 5px between circles (configurable)
- **Position**: Right panel (CharacterFrameInsetRight)

### Responsive Design
- Auto-adjust based on available space
- Configurable columns (1-3)
- Configurable circle sizes (30-60px)

## Technical Implementation

### Core Components

#### 1. Circular Frame Creation
```lua
function CircularStats:CreateStatCircle(statName, size)
    local circle = CreateFrame("Frame", "LibCS_Stat_" .. statName, parent)
    circle:SetSize(size, size)
    
    -- Background circle
    circle.bg = circle:CreateTexture(nil, "BACKGROUND")
    circle.bg:SetTexture("Interface\\AddOns\\Libs-CharacterScreen\\media\\masks\\Circle.tga")
    
    -- Progress ring (cooldown frame for circular progress)
    circle.progress = CreateFrame("Cooldown", nil, circle, "CooldownFrameTemplate")
    circle.progress:SetAllPoints()
    circle.progress:SetReverse(false)
    
    -- Center text
    circle.text = circle:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    circle.text:SetPoint("CENTER")
    
    return circle
end
```

#### 2. Progress Ring Updates
```lua
function CircularStats:UpdateProgress(circle, percentage)
    local normalizedProgress = percentage / 100
    circle.progress:SetCooldown(GetTime() - normalizedProgress * 360, 360)
    
    -- Update color based on percentage
    local color = self:GetProgressColor(percentage)
    circle.progress:SetSwipeColor(color[1], color[2], color[3])
end
```

#### 3. Data Sources

**Primary Stats**: `UnitStat("player", statIndex)`
**Secondary Stats**: `GetCombatRating(CR_CRIT_TAKEN)`, `GetCombatRatingBonus()`
**Percentages**: Custom calculation based on item level and stat weights

### Event Handling
- `COMBAT_RATING_UPDATE`: Secondary stats changed
- `PLAYER_DAMAGE_DONE_MODS`: Damage modifiers changed  
- `UNIT_STATS`: Primary stats changed
- `PLAYER_EQUIPMENT_CHANGED`: Gear affecting stats changed

## Configuration Options

### Module Settings
```lua
{
    enabled = false,  -- Module disabled by default
    columns = 2,      -- Grid columns
    circleSize = 40,  -- Circle diameter
    circleSpacing = 5, -- Space between circles
    showTooltips = true, -- Enhanced stat tooltips
    statOrder = {...}, -- Custom stat display order
}
```

### Per-Stat Configuration
```lua
{
    visible = true,     -- Show this stat
    priority = 1,       -- Display order
    color = {1,0,0},   -- Custom base color
    softCap = 30,      -- Percentage for color transitions
}
```

## Future Enhancements

### Phase 1: Basic Implementation
- Create circular frames with progress rings
- Implement color progression system
- Add basic stat calculations
- Position in right panel

### Phase 2: Advanced Features
- Custom stat tooltips with breakdowns
- Stat comparison with equipped vs unequipped gear
- Export stat summary for external tools
- Integration with stat weight addons

### Phase 3: Customization
- Drag-and-drop stat reordering
- Custom color themes
- Per-class/spec optimal stat highlighting
- Historical stat tracking

## Implementation Notes

### Performance Considerations
- Update stats only when changed (event-driven)
- Cache calculated percentages
- Efficient color table lookups
- Minimal frame creation/destruction

### Compatibility
- Works with existing character frame modifications
- Respects other addon stat modifications
- Graceful degradation if stats unavailable
- Clean disable/restore functionality

## Activation

The module is created but disabled by default. To enable:
1. Set `circularstats.enabled = true` in database
2. Reload UI or restart addon
3. Module will initialize and replace default stats display

Current status: **Framework created, implementation pending user activation**