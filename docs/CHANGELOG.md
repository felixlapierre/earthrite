# Changelog

## Version 0.0.9

Released Jan 15th

New Features
- Web Release allows playing the game as a Progressive Web App in the browser. This allows the game to be played on iOS, but it's still buggy and unreliable.
- Added new cards (Bleeding Heart, Fire Flower, Copper Flower, Rainbow Cactus, Sparkflower, Coneflower, Lavender)
- Added new events (Zodiac Vault, Guardian of the Fields) and a new UI for Events. Vessel Stone event reworked.
- Added new enhances (+2Strength/+1Cost, +2 Size)
- Added new structures (Telescope, Imperfect Tourmaline, Spark Shroom)
- Reworked Riverland farm and Mountain farm. Replaced Lunar Mage with Lunar Temple farm. Added Stormlands farm. Wilderness farm can now select the native seed before starting
- Display best win on a given mage, farm, or mage-farm combo in the new game screen
- New blight attacks (Cold Snap, Dark Thorn, Bloodthorn, Spell Breaker, Decay). Reworked how blight attacks scale with difficulty.
- Added more Blessings (Nature's Bounty, Tourmaline Fragment, Water Crown, Winter's Blessing)

Balance
- Pyromancer now has +1 energy per turn
- Reworked Iris. Now keeps the stored plant if replanted or spreaded. Reworked Cactus.
- Reworked Mastery mode into 5 difficulty settings
- Rooted Core and Geode are now common structures
- Game lasts 8 years instead of 10
- Pick from 3 rare cards in the explore menu instead of 5

QoL
- Keyboard shortcuts. Number keys select cards in hand, E ends the turn.
- A card's features are now highlighted in blue when they are enhanced. Fleeting cards are now semitransparent.
- Added a Debug Menu in winter when debug mode is enabled that lets you add cards/enhances/structures/blessings, trigger events, trigger blight attacks, change year.
- Fixed bugs (Fairy Hutch)


## Version 0.0.8

Released Dec 17th

- Reworked Shop system into Explore system. Removed rerolls.
- Reworked card rarity. Cards are either Common on Rare, and Rare cards can only be obtained on year 4/7 or from events
- Added new events. Added rare enhances and rare structures
- Some mage powers can now be upgraded through an event
- Added new cards (Flame Ward, Chronoweave, Cactus, Onion, Marigold). Added new structures. Puffshroom renamed to Dandelion, and fixed.
- Added new mage: Lost in Time (Chronomancer)
- Added "Blessings", that provide passive bonuses, and "Curses", that provide passive penalties, available from events only for now (includes the old Energy Fragment and Card Fragment, which only trigger on turn 1)
- Blight can now attack on week 2/3 again in later years
- Rebalanced many cards, including Ward cards, Corn, Propagation.
- Reworked Blight Druid: now starts with Blightrose instead of Corruption and can find blight cards in card rewards.
- Added sprites for Blast Row and Blast Column attacks
- Fixed Wilderness farm getting enhances that only apply to seeds
- Added debugging tool to add any card to your deck during winter

## Version 0.0.7

Released Nov 24th

- Added animations for roughly half of the action cards in the game
- Added seasonal transitions
- Added animation for completing the ritual. Added blight roots on the right side of the screen that animate whenever the player is attacked.
- Added new enhance: Echo
- Added new cards: Echo Scythe and Flamerite. Reworked Waterrite.
- Changed visuals for mana bubbles when gaining mana
- Reworked wilderness farm
- Added card borders based on rarity.
- Wild Magic and Corruption give 3 options to pick from instead of granting a random card
- Sunflower (from squirrel seed event) protects nearby tiles
- Fixed bugs, and made misc QOL improvements

## Version 0.0.6

Released Oct 19th

### Features

- Added two new difficulty options: Hard and Mastery
- On mobile, hover controls have been replaced with tap controls. Improved UX for playing cards and buying from the shop
- UI now shows a full preview of how strong the blight's attacks will be each turn
- Blight's attacks can now change from turn to turn. Added new blight attacks (Corpse flower, destroy row / column, counter)
- Added more particle effects for cards that previously had no animation
- Redid main menu
- Can no longer apply the same enhance twice to a card
- Cards that add yield will now show a green number in the preview to indicate how much yield they will give
- Added a "More Info" button under the currently selected card that shows a detailed explanation of what each icon and text on a card means
- Fixed bugs and rebalanced cards

## Version 0.0.5

Released Sept 22nd

### Features

- Added new cards (Flow, Puffshroom, Morel, Corn, Catalyze, Spellcatcher, Waterrite, Iris, Transmute, Downpour)
- Added endless mode
- Added mobile version, although many usability improvements are still needed
- Wilderness farm is no longer offered seeds in the shop and events
- Better UI for expanding the farm
- Added an animation when the blight is attacking
- Added a pause / esc menu so that players can return to the main menu without reopening the game
- Tentatively renamed game to Earthrite

## Version 0.0.4

Released Sept 17th

#### Features

- Added character selection. Each mage has their own unique ability.
- Added new cards (Water Ward, Wild Magic, Corruption, Bloodrite, Dark Visions)
- Added smart targeting to make it much easier to place seeds on the farm where you want to
- Harvester targets only 8 tiles now.
- Custom cards now work with yield preview
- Various quality of life improvements 

## Version 0.0.3

Released Sept 10th

#### Features

- Added tutorial
- Changed yellow/purple yield to yellow/blue mana
- Added animation to make it clear when card play fails due to insufficient energy
- Some balance changes and many quality of life improvements

## Version 0.0.2

Released Sept 3rd

#### Features

- Added an obelisk with a visual progress bar for the ritual completion percentage
- Cards can now be enhanced a max of 2 times
- Cards now show their effect tooltips when hovered in hand
- Can now view deck when in pick one of 3 options event dialog box

#### Minor Changes, Bugfixes, Balance

- Weeds now Burn when played
- On easy difficulty, blight will attack any tile, not only ones with plants
- Fix bug where Catastrophe negative fortune isn't loaded from save correctly. Reduced it from +100% to +50% purple yield
- Fixed a bug where kegs can carry over yield to next year
- Inky cap reduced from 50% yield to 25% yield of destroyed plants
- Removed SpreadHarvest enhancement
- Tile hover popup no longer renders behind hand cards
- Fixed grow and spread tooltips to be clearer and cleaner

#### Quality of Life

- Structures can now be moved around during the shop phase. Structure placement from the shop can now be canceled.
- Added a bunch of labels to the shop to clarify how it works
- Card background is green if seed, red if action. In shop, enhances are blue, while structures remain grey.
- Renamed Dear Future Me to Temoral Rift and added custom art
- Increased contrast on select overlay and farm tile colors
- Added a warning message when the current harvest wastes purple yield. Added a message during the end of year "ritual complete" animation
- Clearer description on X-cost card
- Made some popups opaque to improve readability


## Version 0.0.1

Initial alpha elease
