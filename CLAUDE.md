# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a World of Warcraft addon called "Libs-CharacterScreen" that enhances the default character screen interface. It's written in Lua using the Ace3 addon framework and replaces the standard character frame with a custom UI featuring improved equipment visualization, dynamic backgrounds, and better layout.

## Development Environment

This is a WoW addon project with no traditional build system. Development is done by:

1. Directly editing Lua files
2. Testing in-game by reloading the UI (`/reload`) or restarting WoW
3. Using the `/libcs` chat command to show the custom character frame

## Architecture

### Main Files

- **LibCS.lua**: Core addon file containing the main LibCS addon class with AceAddon framework
- **Libs-CharacterScreen.toc**: WoW addon table of contents file defining addon metadata and load order
- **config.lua**: Configuration module (minimal implementation)

### Core Components

1. **Character Frame Management** (`LibCS:CreateNewCharacterFrame()`)

   - Creates custom character frame to replace Blizzard's default
   - Handles frame positioning, sizing, and visual styling
   - Manages frame show/hide based on original character frame state

2. **Equipment Visualization** (`CreateGearManager()`, `CreateGearButton()`)

   - Custom gear slot buttons with circular masks and highlighting
   - Positioned around character portrait using slot arrangement arrays
   - Handles tooltips, item icons, and visual feedback

3. **Portrait System** (`CreatePortrait()`)

   - 3D character model display with background gradients
   - Header/footer frames showing character name, level, spec, and class
   - Mask textures for visual effects

4. **Dynamic Backgrounds** (`LibCS:GetDynamicBackground()`)

   - Background textures that change based on character specialization
   - Atlas-based texture system using WoW's texture kit constants
   - Fallback system for unsupported specializations

5. **Addon Integration** (`CheckAddionalAddons()`)
   - Automatic detection and integration with popular addons (Pawn, Narcissus, Simulationcraft)
   - Dynamic button positioning and UI adjustments

### Key Data Structures

- **DBDefaults**: Configuration defaults including background settings, padding, scaling
- **SpecializationVisuals**: Maps specialization IDs to background texture names
- **slotArrangement**: Defines positioning of equipment slots (left side, right side, bottom)

### Event System

- Uses Ace3 event system for responding to character changes
- Key events: `UNIT_MODEL_CHANGED`, `ACTIVE_PLAYER_SPECIALIZATION_CHANGED`, `UNIT_LEVEL`, `UNIT_NAME_UPDATE`

## Dependencies

- **Ace3**: Core addon framework (included in libs/ directory)
- **LibSharedMedia-3.0**: Media resource management
- **LibCompress**: Data compression utilities
- **LibBase64-1.0**: Base64 encoding/decoding

## Reference Files

The World of Warcraft interface files can be found in `C:\code\WOWUICode`. This repository contains branches for each game version (Retail, Classic, TBC, Wrath, Cata, Mists, etc.) with the official Blizzard UI source code. Use `git checkout <branch>` to switch between versions.

**Important**: This is a reference repository only - **do not edit files in this directory**. Use these files to understand Blizzard's UI patterns, frame structures, and API usage.

## Testing

Use `/libcs` command in-game to display the custom character frame for testing changes.

## Asset Organization

- **media/**: Contains textures, masks, and UI elements
  - **masks/**: Various mask textures for visual effects
  - **frame/**: Frame border and background textures
  - **DressingRoom/**: UI elements for character customization
