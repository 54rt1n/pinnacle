# PINNACLE - 08 - Settlements

## Overview

A `Location` does not always start at it's maximum capacity. It can be built up over time. This is done by
the `Settlement` process.

## Settlement

A `Settlement` is a blueprint for the buildings that are in a `Location`. It is a list of `Building`s, their
`Interactable`s, required materials, along with any Jobs that are provided by the building.  A Building should have
enough beds for the number of people that will be living there.

### Blueprint

When a settlement is conceived, it has a theme (which may contain it's own tile set), a certain set of buildings,
and the footprint for each Building and House on the grid.

As a Building levels up, the tiles in the Location will change to reflect the Building's new footprint, and the new
House's footprint.

### Construction

A `Settlement` starts out with their set of Buildings, some of which are at Level 0.  If there is a `Governor` working,
and a `Builder's Yard` of the new level of the building being upgraded, then the building can be upgraded.  The Location
will have a `Builder` quest added to the `Location Bag` that will upgrade the Building when completed.

### Growth

Over time the buildings in the settlement can expand.  Each time a building expands, a new Character is added to the
building, and the settlement population is increased by 1, which raises the number of houses by 1.

### Prosperity

The prosperity of a settlement is a measure of how well the settlement is doing.  It is calculated through several
metrics: `safety`, `economy`, `order`, `health`, `hunger`.  A `Settlement` also has an `alignment`, which reflects
the mean `affinity` of the `Character`s who live there.

Each Building, and when a Job Quest is performed, impacts the `order` of the settlement.  Some will impact `safety` or
`economy` as well.

Each Character who lives in the settlement impacts the `health` and `hunger` of the settlement.

When `gold` is spent at the Location, it impacts the `economy`.

## Housing

The `Home`s in the `Settlement` can each accommodate a `Family`.  

### Homelessness

If a Character loses their Job, they and their Family become homeless and must live in the Rookery, where they will
be Beggars until a Job can be found or the Characters die.  If the `Character` is `Solo` and they can move back home,
they will return to their parents `Family`.

## Buildings

### Buildings

#### Types

##### Government

Government buildings are buildings that are used to govern the settlement.  They are used to increase the `Order` of
a Location, and are often at the center.

##### Nobility

The lords and ladies of the land live in the `Nobility` buildings.  They are often found in the edges of large cities,
but may even be found in their own `Place`.

##### Military

The `Military` buildings are used to increase the `safety` of a Location.  They are often found in perimeter areas
of a walled city, or in the center of a fort.

##### Temple

A `Temple` exists at a place in the world where `Order` is increased, and is centered around a `Radiant Pool`.  The
radiant pool is a pool of energy.  The `Radiant Poolhouse` is a special `Building` for the `Player`, where the game is
saved, the `Player` has events with the `Simulation`, and the `Party` is completely healed.

There are 7 `Temple`s in the game world.  Temples are either dedicated to `Order`, `Chaos`, or one of the 5 schools of
`Magic`.  These will often be centers of learning, have `Trainer`s, libraries, and characters that know the secrets of
about `Dungeon` `word`s and `sigil`s.

##### Resources

Often found in `Place`s in the wilderness, `Resource` buildings are used to gather resources from the land.

* Resources
* Shops
* Services

#### Building List

| Building          | Level 1            | Level 2             | Level 3           | Level 4          | Level 5             |
|-------------------|--------------------|---------------------|-------------------|------------------|---------------------|
| -+ Government +-- | ------------------ | ------------------- | ----------------- | ---------------- | ------------------- |
| Courthouse        | Clerk              | Bailiff             | Judge             | Lawyer           | Executioner         |
| Graveyard         | Grave Digger       | Tombstone Carver    | Crypt Keeper      | Mortician        | Anatomist           |
| Hall              | Administrator      | Advisor             | General           | Diplomat         | Seer                |
| Jail              | Deputy             | Sheriff             | Bounty Hunter     | Marshal          | Clairvoyant         |
| Lighthouse        | Assistant          | Lightkeeper         | Navigator         | Harbormaster     | Stormwarden         |
| Square            | Town Crier         | Grocer              | Fountain Keeper   | Trader           | Entertainer         |
| Waterworks        | Laborer            | Mechanic            | Foreman           | Engineer         | Architect           |
|                   |                    |                     |                   |                  |                     |
| -+ Nobility +---- | ------------------ | ------------------- | ----------------- | ---------------- | ------------------- |
| Aviary            | Bird Keeper        | Falconer            | Trainer           | Cryptologist     | Ornithologist       |
| Conservatory      | Instructor         | Accompanist         | Composer          | Conductor        | Prodigy             |
| Gallery           | Art Handler        | Guide               | Artist            | Curator          | Great Master        |
| Garden            | Groundskeeper      | Gardener            | Landscaper        | Orchardist       | Botanist            |
| Library           | Assistant          | Scribe              | Librarian         | Scholar          | Curator             |
| Manor             | Lord               | Butler              | Steward           | Jester           | Chamberlain         |
| Stable            | Stablehand         | Groom               | Trainer           | Riding Master    | Horse Breeder       |
|                   |                    |                     |                   |                  |                     |
| -+ Military +---- | ------------------ | ------------------- | ----------------- | ---------------- | ------------------- |
| Armory            | Quartermaster      | Armorer             | Siege Engineer    | Master Armorer   | Master-at-Arms      |
| Barracks          | Soldier            | Archer              | Axeman            | Man-at-Arms      | Commander           |
| Bridge            | Guard              | Watchman            | Patrolman         | Toll Collector   | Bridge Captain      |
| Guardhouse        | Guard              | Watchman            | Sergeant          | Sentry           | Guard Captain       |
| Prison            | Guard              | Jailer              | Interrogator      | Executioner      | Torturer            |
| Treasury          | Guard              | Treasurer           | Appraiser         | Accountant       | Master of Coin      |
| Watchtower        | Watchman           | Archer              | Scout             | Marksman         | Ranger              |
|                   |                    |                     |                   |                  |                     |
| -+ Temple +------ | ------------------ | ------------------- | ----------------- | ---------------- | ------------------- |
| Academy           | Assistant          | Instructor          | Advisor           | Dean             | Headmaster          |
| Commandery        | Acolyte            | Chaplain            | Knight            | Paladin          | Archon              |
| Monastery         | Acolyte            | Monk                | Friar             | Prior            | Abbot               |
| Observatory       | Assistant          | Astronomer          | Timekeeper        | Astrologer       | Oracle              |
| Orphanage         | Assistant          | Caretaker           | Nurse             | Teacher          | Counselor           |
| Radiant Poolhouse | Acolyte            | Priest              | Guardian          | High Priest      | Keeper              |
| Hospital          | Assistant          | Nurse               | Physician         | Surgeon          | Chief of Medicine   |
|                   |                    |                     |                   |                  |                     |
| -+ Resources +--- | ------------------ | ------------------- | ----------------- | ---------------- | ------------------- |
| Farm              | Farmhand           | Farmer              | Farm Manager      | Beekeeper        | Agronomist          |
| Fishery           | Fisherman          | Netmaker            | Fishmonger        | Whaler           | Aquaculturist       |
| Herbalist's Grove | Herbalist          | Cultivator          | Botanist          | Healer           | Druid               |
| Mine              | Miner              | Blaster             | Hauler            | Geologist        | Foreman             |
| Ranch             | Herder             | Rancher             | Ranch Hand        | Breeder          | Veterinarian        |
| Sawmill           | Sawyer             | Lumberjack          | Engineer          | Logger           | Woodsman            |
| Vineyard          | Grower             | Vintner             | Wine Merchant     | Vine Tender      | Wine Taster         |
|                   |                    |                     |                   |                  |                     |
| -+ Shops +------- | ------------------ | ------------------- | ----------------- | ---------------- | ------------------- |
| Alchemist         | Apprentice         | Potion Crater       | Potion Maker      | Alchemist        | Transmuter          |
| Antiques          | Apprentice         | Mechanic            | Clockmaker        | Engineer         | Inventor            |
| Apothecary        | Apprentice         | Forager             | Herbalist         | Pharmacist       | Poisoner            |
| Bakery            | Apprentice         | Baker               | Tackmaker         | Patissier        | Confectioner        |
| Bookstore         | Apprentice         | Bookbinder          | Scribe            | Librarian        | Publisher           |
| Brewery           | Apprentice         | Barrel Maker        | Brewer            | Distiller        | Mixologist          |
| Butcher           | Apprentice         | Skinner             | Smoker            | Sausage Maker    | Preserver           |
| Clothier          | Apprentice         | Weaver              | Cobbler           | Dressmaker       | Designer            |
| Foundry           | Apprentice         | Armorsmith          | Weaponsmith       | Bladesmith       | Artificer           |
| Jeweler           | Apprentice         | Gemcutter           | Goldsmith         | Enchanter        | Imputer             |
| Joinery           | Apprentice         | Fletcher            | Bowyer            | Furniture Maker  | Woodspeaker         |
| Outfitter         | Apprentice         | Leatherworker       | Tanner            | Furrier          | Explorer            |
| Stoneworks        | Apprentice         | Brickmaker          | Stonecutter       | Sculptor         | Stoneshaper         |
|                   |                    |                     |                   |                  |                     |
| -+ Services +---- | ------------------ | ------------------- | ----------------- | ---------------- | ---------------     |
| Bank              | Banker             | Clerk               | Advisor           | Moneylender      | Bank President      |
| Bathhouse         | Bath Attendant     | Towel Keeper        | Bath Steward      | Masseuse         | Bathhouse Manager   |
| Builder's Yard    | Builder            | Contractor          | Surveyor          | Architect        | Master Mason        |
| Casino            | Dealer             | Pit Boss            | Gambler           | Gangster         | Boss                |
| Den               | Smuggler           | Swashbuckler        | Pirate            | Cannoneer        | Captain             |
| Merchants Guild   | Representative     | Broker              | Mediator          | Fixer            | Merchant Prince     |
| Inn               | Clerk              | Cook                | Housekeeper       | Proprietor       | Concierge           |
| Shipwright        | Ropemaker          | Shipwright          | Sailmaker         | Gunfounder       | Master Rigger       |
| Tavern            | Bartender          | Server              | Bouncer           | Entertainer      | Host                |
| Thieves Guild     | Thief              | Fence               | Thug              | Assassin         | Guildmaster         |
| Theater           | Stagehand          | Actor               | Lead              | Director         | Producer            |
| Trade Company     | Hauler             | Trader              | Caravan Master    | Importer         | Magnate             |
| Windmill          | Assistant          | Miller              | Packer            | Mill Engineer    | Master Miller       |
|                   |                    |                     |                   |                  |                     |
