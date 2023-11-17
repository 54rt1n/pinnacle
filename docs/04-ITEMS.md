# PINNACLE - 05 - Items

## Resources

### Ore

`ore` is generally harvested from a `Mine`.

* coal - harvesting: 1, requires: mining_pick; consumes: coal_deposit
* copper_ore - harvesting: 1, requires: mining_pick; consumes: copper_deposit
* tin_ore - harvesting: 1, requires: mining_pick; consumes: tin_deposit
* silver_ore - harvesting: 2, requires: mining_pick; consumes: silver_deposit
* iron_ore - harvesting: 2, requires: mining_pick; consumes: iron_deposit
* gold_ore - harvesting: 3, requires: mining_pick; consumes: gold_deposit
* mithril_ore - harvesting: 3, requires: mining_pick; consumes: mithril_deposit
* adamantium_ore - harvesting: 4, requires: mining_pick; consumes: adamantium_deposit
* radiant_shard - harvesting: 4, requires: mining_pick; consumes: shard_deposit

### Stonecutting

`stone` is generally harvested from a `Quarry`.

* clay - requires: shovel; consumes: clay_deposit
* sandstone - harvesting: 1, requires: pickaxe, wedge_and_feathers; consumes: sandstone_deposit
* limestone - harvesting: 2, requires: pickaxe, wedge_and_feathers; consumes: limestone_deposit
* marble - harvesting: 3, requires: pickaxe, wedge_and_feathers; consumes: marble_deposit

### Woodcutting

`wood` is generally harvested from a `Forest`.  `lumber` is generally harvested from a `Sawmill`.

* wood - harvesting: 1, requires: chopping_axe; consumes: tree
* hardwood - harvesting: 2, requires: chopping_axe; consumes: hardwood_tree
* lumber - harvesting: 2, requires: Sawmill; consumes: wood

## Farming

### Agriculture
Farming is it's own separate deal.  You have plow, hoe, rake, and seeds.  You plow the ground, hoe it, rake it, and then plant the seeds.  You can then water the seeds, and they will grow.  You can also fertilize the seeds, and they will grow faster.  You can also use a scarecrow to keep birds away from your crops.

* cotton - requires: ; consumes: cotton_seeds; see `Farm`
* grain - requires: plow, hoe, rake; see `Farm`
* hemp - requires: plow, hoe, rake; consumes: hemp_seeds; see `Farm`
* hops - requires: hops_vine; see `Farm`
* fruit - requires: fruit_tree; see `Farm`
* grapes - requires: grape_vine; see `Farm`
* honey - requires: beehive; see `Farm`
* carcass - requires: livestock; see `Farm`
* wool - requires: shears, see `Farm`

### Pastoral

* carcass - see `Hunting` and `Farming`

### Butchering
* hide - handling: 2, requires: knife; consumes: carcass_with_hide, byproduct: meat
* meat - handling: 1, requires: knife; consumes: carcass

## Settlement Resources
Settlement resources are used to create crafting locations

* crucible - crafting: 1; requires: kiln; consumes: clay, charcoal
* tanning_rack - crafting: 1; requires: hammer; consumes: lumber, metal_parts
* millstone - crafting: 1; requires: hammer; consumes: cut_stone, lumber
* loom - crafting: 2; requires: hammer, wood_chisel consumes: lumber, metal_parts, thread
* potter_wheel - crafting: 2; requires: hammer, wood_chisel; consumes: lumber, metal_parts, rope
* spinning_wheel - crafting: 2; requires: hammer, wood_chisel; consumes: lumber, metal_parts, rope
* anvil - crafting: 2; requires: forge, hammer; consumes: metal_parts
* bellows - crafting: 2; requires: hammer; consumes: lumber, leather, metal_parts
* forge - crafting: 2; requires: hammer, trowel; consumes: brick, lumber, metal_parts
* foundry - crafting: 3; requires: hammer, trowel; consumes: brick, lumber, metal_parts
* kiln - crafting: 2; requires: hammer, trowel; consumes: brick
* radiant_foundry - crafting: 4; requires: hammer, trowel; consumes: lumber, brick, radiant_parts

## Crafting

The `Crafting` trade allows characters to do things like make clothes, weapons, and armor.

### Foundry
* copper_ingot - crafting: 1; consumes: copper_ore
* tin_ingot - crafting: 1; consumes: tin_ore
* bronze_ingot - crafting: 1; consumes: copper_ingot, tin_ingot
* silver_ingot - crafting: 1; consumes: silver_ore
* iron_ingot - crafting: 2; consumes: iron_ore
* gold_ingot - crafting: 2; consumes: gold_ore
* steel_ingot - crafting: 3; consumes: iron_ingot, coal
* mithril_ingot - crafting: 3; consumes: steel_ingot, mithril_ore, moonstone
* adamantium_ingot - crafting: 4, requires: volcanic_foundry, crucible; consumes: adamantium_ore
* orichalcum_ingot - crafting: 4, requires: radiant_foundry, crucible; consumes: mithril_ingot, adamantium_ingot, radiant_shard

### Blacksmith
* junk_parts - crafting: 1; consumes: tin_ingot
* basic_parts - crafting: 1; consumes: copper_ingot
* decent_parts - crafting: 2; consumes: bronze_ingot, iron_ingot
* good_parts - crafting: 2; consumes: steel_ingot
* beautiful_parts - crafting: 3; consumes: silver_ingot, gold_ingot
* magic_parts - crafting: 3; consumes: mithril_ingot
* dense_parts - crafting: 4; consumes: adamantium_ingot
* radiant_parts - crafting: 4; consumes: orichalcum_ingot

### Stonemason
* cut_stone - crafting: 2, requires: stone_chisel, hammer; consumes: limestone, marble, sandstone

### Tanning
* leather - handling: 2, requires: tongs; consumes: hide, lime, bucket_of_water, byproduct: bucket
* parchment - crafting: 1, requires: knife, shears; consumes: hide

### Tailoring
* web - harvesting: 2, requires: basket; consumes: spider_web
* silk - harvesting: 2, requires: basket; consumes: silkworm
* wool_thread - crafting: 1, requires: spinning_wheel; consumes: wool
* cotton_thread - crafting: 1, requires: spinning_wheel; consumes: cotton
* silk_thread - crafting: 1, requires: spinning_wheel; consumes: silk, web
* rope - crafting: 1, consumes: hemp
* wool_cloth - crafting: 2, requires: loom; consumes: wool_thread
* cotton_cloth - crafting: 2, requires: loom; consumes: cotton_thread
* silk_cloth - crafting: 2, requires: loom; consumes: silk_thread
* magic_cloth - crafting: 2, requires: loom; consumes: magic_parts

### Milling
* flour - requires: mill; consumes: grain

### Fishing
* fish - survival: 1, requires: fishing_rod; consumes: fish_school
* ocean_fish - survival: 3, requires: exceptional_fishing_rod; consumes: ocean_fish_school

### Joining
* bucket - crafting: 1, requires: hammer; consumes: metal_parts, wood
* crate - crafting: 1, requires: hammer; consumes: metal_parts, wood
* cask - crafting: 2, requires: hammer; consumes: metal_parts, wood
* barrel - crafting: 2, requires: hammer; consumes: metal_parts, wood
* chest - crafting: 3, requires: hammer; consumes: metal_parts, wood
* wood_pulp - requires: hammer; consumes: wood
* paper - requires: knife, shears; consumes: wood_pulp

### Pottery / Brickwork
* pot - requires: kiln, potter_wheel; consumes: clay, charcoal
* brick - crafting: 1, requires: kiln; consumes: clay
* lime - crafting: 1, requires: kiln; consumes: limestone, coal
* coal - requires: kiln; consumes: wood

## Tools

Tools are created using `metal_parts`.

### Tool Level

The tool inherits the level from the metal part used, so:
[`Junk`, `Basic`, `Decent`, `Good`, `Beautiful`, `Magic`, `Unbreakable`, `Radiant`]

These modify the crafting level required to create the tool, (not over 4):
* `Junk`, `Basic`, `Decent`, `Good`, `Beautiful` - no change
* `Magic`, `Unbreakable` - +1 level required
* `Radiant` - only crafting 4 can create this

### Blacksmith
* knife - crafting: 1; consumes: metal_parts, hardwood
* needle - crafting: 1; consumes: metal_parts

### Joinery
* basket - crafting: 1; consumes: rope
* fishing_rod - crafting: 1; consumes: wood, thread
* hammer - crafting: 1; consumes: metal_parts, hardwood
* stone_chisel - crafting: 1; consumes: metal_parts
* trowel - crafting: 1; consumes: metal_parts, hardwood
* wedge_and_feathers - crafting: 1; consumes: metal_parts
* wood_chisel - crafting: 1; consumes: metal_parts
* hoe - crafting: 1; consumes: metal_parts, hardwood
* rake - crafting: 1; consumes: metal_parts, hardwood
* shovel - crafting: 1; consumes: metal_parts, hardwood
* tongs - crafting: 1; consumes: metal_parts
* pickaxe - crafting: 2; consumes: metal_parts, hardwood
* chopping_axe - crafting: 2; consumes: metal_parts, hardwood
* mining_pick - crafting: 2; consumes: metal_parts, hardwood
* saw - crafting: 2; consumes: metal_parts, hardwood
* scissors - crafting: 2; consumes: metal_parts
* shears - crafting: 2; consumes: metal_parts
* plow - crafting: 2; consumes: metal_parts, hardwood
* lockpick - crafting: 3; consumes: metal_parts

## Brewing
* beer - brewing: 2, requires: bucket; consumes: grain, hops, bucket_of_water; byproduct: bucket
* cider - brewing: 1, requires: bucket; consumes: fruit, bucket_of_water; byproduct: bucket
* wine - brewing: 1, requires: bucket; consumes: grapes, bucket_of_water; byproduct: bucket
* mead - brewing: 1, requires: bucket; consumes: honey, bucket_of_water; byproduct: bucket

## Miscellaneous
* bucket_of_water - requires: bucket, water_source
* ink - requires: pot; consumes: squid_ink
* quill - requires: knife, shears; consumes: feather

## Reagents

* ash - ash is a fine dust, giving magic a large surface area to work with
* iron_ring - iron induces magic to flow in a circle, which has several consequences
* herbs - herbs are used for a variety of magical purposes
* pearl - pearls are formed when a grain of sand gets inside an oyster
* gemstone - gemstones are prized for their ability to conduct magic
* sulfur - sulfur is a byproduct of smelting
* mindworm - mindworms are said to be the larval form of a mindflayer
* wisp_dust - wisp dust is the residue of a wisp's passing
* moonstone - chaos will sometimes leak through, and crystallize in the light of the full moon.  It disappears in sunlight.
* mandrake_root - the rare mandrake root is said to have magical properties, only grows in swamps
* singularity_gem - it is said that the singularity gem is residue from the creation of the universe.
