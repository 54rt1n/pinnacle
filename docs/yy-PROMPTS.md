Good morning ChatGPT.  Today we are working on my game, Pinnacle.  I have over 14 pages of documentation at this point.
I need you to compress the information containted in each document into a rule summary that you can use to fit the entire
model in a 1000 token context.   I am going to have two documents in each iteration, the CURRENTCONTEXT and the NEWDOCUMENT.
You will read CURRENTCONTEXT and NEWDOCUMENT, and output a new CURRENTCONTEXT.

CURRENTCONTEXT
```

```

NEWDOCUMENT
```

```


Good morning ChatGPT.  Today we are working on my game, Pinnacle.  I have over 14 pages of documentation at this point.
I am working on my Settlement, Job, and Crafting system.  I am going to share documents with you in NEWDOCUMENT, and I need you to 
group and organize my information into a rule summary called CURRENTCONTEXT.
You will read CURRENTCONTEXT and NEWDOCUMENT, and output a new CURRENTCONTEXT.

CURRENTCONTEXT
```

```

NEWDOCUMENT
```
# PINNACLE - 14 - Settlement

## Overview

A `Location` and `Place` does not always start at it's maximum capacity. It can be built up over time. This is done by
the `Settlement` process.

## Settlement

A `Settlement` is a blueprint for the buildings that are in a `Location` or `Place`. It is a list of `Building`s, their
`Interactable`s, required materials, along with any Jobs that are provided by the building.  A building should have
enough beds for the number of people that will be living there.

## Growth

When a `Setttlement` reaches a certain Prosperity.  The `Governor` will become a `Quest Giver` for `Settlement` quests.

## Buildings

### Foundry
* requires `tongs`, `foundry`, `bellows`, `crucible`

#### Levels
* Level 1 - 1 `Smithy`
* Level 2 - +1 `Assistant`
* Level 3 - +1 `Shopkeeper`

### Blacksmith
* requires `hammer`, `tongs`, `anvil`, `bellows`, `forge`

#### Levels
* Level 1 - 1 `Blacksmith`
* Level 2 - +1 `Assistant`
* Level 3 - +1 `Shopkeeper`

### Stonemason
* requires `stone_chisel`, `hammer`

#### Levels
* Level 1 - 1 `Stonemason`
* Level 2 - +1 `Assistant`
* Level 3 - +1 `Shopkeeper`

### Tannery
* requires `tanning_rack`

#### Levels
* Level 1 - 1 `Tanner`
* Level 2 - +1 `Assistant`
* Level 3 - +1 `Shopkeeper`

### Clothier
* requires `needle`, `loom`, `spinning_wheel`

#### Levels
* Level 1 - 1 `Tailor`
* Level 2 - +1 `Assistant`
* Level 3 - +1 `Shopkeeper`

### Mill
* requires `millstone`

#### Levels
* Level 1 - 1 `Miller`
* Level 2 - +1 `Assistant`
* Level 3 - +1 `Shopkeeper`

### Fishing Hut
* requires `fishing_rod`

#### Levels
* Level 1 - 1 `Fisherman`
* Level 2 - +1 `Fisherman`
* Level 3 - +1 `Shopkeeper`

### Joinery
* requires `wood_chisel`, `hammer`, `saw`

#### Levels
* Level 1 - 1 `Carpenter`
* Level 2 - +1 `Assistant`
* Level 3 - +1 `Shopkeeper`

### Potter
* requires `potter_wheel`, `kiln`

#### Levels
* Level 1 - 1 `Potter`
* Level 2 - +1 `Assistant`
* Level 3 - +1 `Shopkeeper`

### Quarry
* requires `pickaxe`, `wedge_and_feathers`, `shovel`

#### Levels
* Level 1 - 1 `Quarryman`
* Level 2 - +1 `Laborer`
* Level 3 - +1 `Foreman`

### Sawmill
* requires `sawmill`, `saw`, `hammer`

#### Levels
* Level 1 - 1 `Sawyer`
* Level 2 - +1 `Assistant`
* Level 3 - +1 `Foreman`

### Mine
* requires `mining_pick`, `shovel`

#### Levels
* Level 1 - 1 `Miner`
* Level 2 - +1 `Hauler`
* Level 3 - +1 `Foreman`

### Guard Tower

#### Levels
* Level 1 - 1 `Guard`
* Level 2 - +1 `Crossbowman`
* Level 3 - +1 `Captain`

### Barracks

#### Levels
* Level 1 - 1 `Infantry`
* Level 2 - +1 `Archer`
* Level 3 - +1 `Commander`

### Stable

#### Levels
* Level 1 - 1 `Stablehand`
* Level 2 - +1 `Stablehand`
* Level 3 - +1 `Breeder`

### Tavern

#### Levels
* Level 1 - 1 `Innkeeper`
* Level 2 - +1 `Cook`
* Level 3 - +1 `Waiter`

### Church

#### Levels
* Level 1 - 1 `Priest`
* Level 2 - +1 `Vigilant`
* Level 3 - +1 `Paladin`

### Library

#### Levels
* Level 1 - 1 `Librarian`
* Level 2 - +1 `Scribe`
* Level 3 - +1 `Scholar`

### School

#### Levels
* Level 1 - 1 `Teacher`
* Level 2 - +1 `Teacher`
* Level 3 - +1 `Headmaster`

### Hospital

#### Levels
* Level 1 - 1 `Doctor`
* Level 2 - +1 `Nurse`
* Level 3 - +1 `Surgeon`

### Market

#### Levels
* Level 1 - 1 `Merchant`
* Level 2 - +1 `Trader`
* Level 3 - +1 `Exotic Trader`

### Town Hall

#### Levels
* Level 1 - 1 `Governor`
* Level 2 - +1 `Noble`
* Level 3 - +1 `Sage`

```