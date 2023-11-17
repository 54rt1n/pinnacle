# PINNACLE - 11 - Actions

## Existence

The `Character` exists in a world where they have responsibilities, and they have the ability to act to fulfill those
responsibilities.  They primarily have a `Faction` to whom they are beholden, and they have a `Family` with whom they
live, and they have `Friend`s with whom they interact.

Primarily, the `Character` is responsible for their own survival, and the survival of their `Family`, and the performing
of their `Job` if they have one.

## Party

Each `Character` is the member of a `Party`.  A party receives `Ticks` from the clock, and handles actions on behalf of
the `Character`s in the party.  Each `Party` has a `Leader`, who speaks for the `Party`.

When `Character`s are in a `Party`, they do not have to be individually simulated for `Motivation`s.

A `Party` one or more `Character`s, along with their `Mount`s.  The only way to travel on the `Overworld` or in a `Location`
is to be a member of a `Party`.  `Party`s have their own collective group stats, which include movement rate, 
line of sight radius, ability to traverse otherwise impassible `Terrain`, ability to interact with certain 
restricted `Terrain` (e.g., Mine Ore, Sail Ship).

A `Party` has a `Formation`, which determines how the `Character`s are situated on the battlefield at the beginning of combat.

We will refer to a party of one as a `Solo` party.

## Jobs

Each `Party` can have a `Job`. `Job`s are a function of the `Character`'s `Faction`.  Each `Faction` has a certain number
of `Job` slots which they have to fill to operate all the `Interactable`s.  Each `Job` has one or more `Position`s and
a `job_priority`.

### Positions

Each `Position` has a `position_priority`, which determines the order in which `Character`s are assigned to the `Position`.
Each `Position` has a `Position Type`, which determines the `Assignment` that will be assigned to the `Character` who
fills the `Position`.

The `Position` comes with an assigned `Home`, and `Interactable`s, which the`Character` will `Own` for the duration of
their `Assignment`.

### Assignments

`Assignment`s are prioritized their `Faction`'s `job_priority` and the `position_priority`.

If a `Character` has an `Assignment`, they can be reassigned to a different `Assignment` by their `Faction` at any time,
if they are the most qualified `Character` for that position.

This could cause a messy cascade of reassignments, so subsequent `Assignment` reassignments should be limited in some manner.
Perhaps only allow one new `Assignment` per `Day`.

The simulation will prioritize based on a character's `Assignment` history, attributes, and trades; with different
strategies depending on the `Faction`s government type, and `Character`'s `faction_affinity`.

#### Position Types
* (Company) Commander - Prefer `Combat`, `Warfare`, `Riding`, `Cunning`, `Might`
* (Company) Infantry - Prefer `Combat`, `Might`, `Grit`
* (Company) Archer- Prefer `Archery`, `Awareness`, `Grace`
* (Guard) Guard - Prefer `Combat`, `Might`, `Grace`
* (Crew) Captain - Prefer `Sailing`, `Law`, `Knowledge`, `Creativity`
* (Crew) Sailor - Prefer `Sailing`, `Grace`, `Endurance`
* (Farmer) Farmer - Prefer `Body`, `Grit`, `Endurance`
* (Shepherd) Shepherd - Prefer `Handling`, `Awareness`, `Willpower`
* (Shepherd) Livestock - Require `Animal`
* (Woodsman) Woodcutter - Prefer `Survival`, `Awareness`, `Might`
* (Hunter) Hunter - Prefer `Archery`, `Survival`, `Awareness`, `Grace`
* (Miner) Miner - Prefer `Metallurgy`, `Might`, `Endurance`
* (Squad) Sheriff - Prefer `Combat`, `Law`, `Riding`, `Cunning`, `Endurance`
* (Squad) Deputy - Prefer `Combat`, `Law`, `Cutting`, `Endurance`
* (Caravan) Trader - Prefer `Mercantile`, `Charm`, `Cunning`
* (Caravan) Guard - Prefer `Combat`, `Might`, `Endurance`
* (Clergy) Priest - Prefer `Herbalism`, `Connection`, `Knowledge`
* (Clergy) Vigilant - Prefer `Herbalism`, `Creativity`, `Awareness`
* (Scrivener) Scribe - Prefer `History`, `Knowledge`, `Awareness`
* (Builder) Engineer - Prefer `Crafting`, `Creativity`, `Knowledge`
* (King) King - Prefer `Negotiation`, `Warfare`, `Grace`, `Charm`
* (King) Vizier - Prefer `Alchemy`, `Grit`, `Knowledge`
* (King) Noble - Prefer `Negotiation`, `Cunning`, `Awareness`
* (King) Kings Guard - Prefer `Grace`, `Might`, `Endurance`
* (Governor) Politician - Prefer `Law`, `Negotiation`, `Beauty`, `Charm`
* (Governor) Aide - Prefer `Law`, `Negotiation`, `Cunning`, `Charm`
* (Governor) Bodyguard - Prefer `Combat`, `Might`, `Endurance`
* (Gang) Thief - Prefer `Roguery`, `Mercantile`, `Cunning`, `Charm`
* (Gang) Bandit - Prefer `Roguery`, `Negotiation`, `Awareness`, `Presence`
* (Gang) Outlaw - Prefer `Roguery`, `Combat`, `Awareness`, `Might`
* (Merchant) Merchant - Prefer `Mercantile`, `Awareness`, `Cunning`
* (Merchant) Guard - Prefer `Combat`, `Might`, `Endurance`
* (Host) Innkeeper - Prefer `Mercantile`, `Cunning`, `Charm`
* (Host) Cook - Prefer `Cooking`, `Cunning`, `Grace`
* (Host) Waiter - Prefer `Negotiation`, `Cunning`, `Grace`
* (Troupe) Musician - Prefer `Performance`, `Cunning`, `Creativity`
* (Troupe) Dancer - Prefer `Performance`, `Beauty`, `Grace`
* (Troupe) Juggler - Prefer `Performance`, `Cunning`, `Grace`
* (Troupe) Actor - Prefer `Performance`, `Charm`, `Connection`
* (Troupe) Clown - Prefer `Performance`, `Cunning`, `Grace`
* (Troupe) Acrobat - Prefer `Performance`, `Creativity`, `Endurance`
* (Troupe) Magician - Prefer `Performance`, `Knowledge`, `Charm`
* (Traveler) Wanderer - Prefer `Survival`, `Awareness`, `Endurance`
* (Traveler) Survivor - Prefer `Combat`, `Grit`, `Cunning`
* (Traveler) Refugee - Prefer `Cooking`, `Grit`, `Connection`
* (Healer) Healer - Prefer `Herbalism`, `Alchemy`, `Knowledge`, `Connection`
* (Mystic) Mystic - Prefer `Alchemy`, `Mercantile`, `Connection`, `Grit`

### Family Positions
When not operating from their `Job Party`, and not in a `Solo Party`, `Character`s will operate from their `Family Party`.
* (Family) Father - Prefer `Male`
* (Family) Mother - Prefer `Female`
* (Family) Son - Require `Male`
* (Family) Daughter - Require `Female`

### Examples

* `Faction` has a `Commander` `Position` open, and two `Character`s with equal total values for `Warfare`, `Riding`, and 
`Combat` trades are available. The `Assignment` is given to the `Character` with the higher `faction_affinity`. This
`Character` and his `Family` moves to new `Home`, and joins a `Company`.  He is the highest ranking `Commander` in the
`Company`, so he becomes the `Leader`.
* `Faction` has a `Farmer` `Position` open and a `Miner` `Position` open, and the `Farmer` has a higher `position_priority`.
There are no `Character`s in the faction to fill them.  If the simulation triggers a new `Character` to be born into that
`Faction`, they will be assigned to the `Farmer` `Position` when they reach `Teen` age.  Normally, they would not be
assigned to a `Position` and become a `Solo Party` until they reach `Young Adult` age, but the `Faction` is desperate for
a `Farmer`.  There are two other `Farmer`s in the `Job Party`, and he is the lowest, so he will not be `Leader`.

## Schedule

Each `Character` has one or more `Schedule`s which they will try to operate under, with each `Schedule` having a
`schedule_priority`.  The `Character` will try to operate under the `Schedule` with the highest `schedule_priority`.

### Schedules

* Default - In this `Schedule`, the `Character` will operate a `Solo Party`.
* Individual - In this `Schedule`, the `Character` will operate a `Solo Party`.
* Family - In this `Schedule`, the `Character` will join a `Family Party`.
* Job - In this `Schedule`, the `Character` will join a `Job Party`.

### Schedule Priorities

Different `Character`s will have different individual `schedule_priority` values, based on their `Personality` and
`faction_affinity`.  If they hate their `Faction`, they will have a low `schedule_priority` for `Job`.  If they love
their `Family`, they will have a high `schedule_priority` for `Family`.

### Affinity Shift

`party_affinity` is the average `faction_affinity` of the `Character`s in the `Party`, with the `Leader` getting
a double share.

A `Character` will have their `personal_bias` and `individual_bias` shift towards the `party_affinity` of the group they
are currently operating in.  The sign of this shift is based on the `Character`s mood:
* Happy - positive
* Content - if other `Character` is `Content` or `Happy`, positive, otherwise negative
* Unhappy - if other `Character` is `Unhappy` or `Angry`, positive, otherwise negative
* Angry - if other `Character` is `Unhappy` or `Angry`, positive, otherwise negative

## Motivation

The `Party` is an agent.  This agent has `Movitation`s, which it uses to determine a `Course of Action` required to
perform `Action`s to achieve `Motivation`s.  The `Party` has the capability to, on each `Tick` of the game, to move
through this world, performing `Action`s.

`Motivation`s are a function of `Assignment`, `affinity`, `Personality`, and current conditions 
like `Health` and `Food` levels.

## Actions

A `Party` is in one square.  It can interact with the surrounding cardinal squares, based on what is currently
occupying the square; and the square that the `Party` is occupying.  To do this, the `Party` performs an `Action`.

### Party

A `Party` may have actions which it can take at any time, or in certain situations.  These actions are:
* `Slaughter Animal`: (at a `Butcher`, this would require that the party had `Livestock`, which receives a
  `Mortal Wound`.  Provides `meat`)

### Move

A `Party` can move to an adjacent square.  This `Action` can only be performed if the square is not occupied by
another `Party` or an `Impassible`.

### Item

An `Item` is a thing that a `Party` can bring into it's `Inventory`.

When an `Item` is in a `Party`s `Inventory`, it may provide the following actions:
* `Drop Item` (If the square contains an item, the old item will be destroyed)
* `Use Item` (Not all items are usable, option will be greyed out (can't use))
* `Consume Item` (Not all items are consumable, option will be greyed out (can't use))
* `Combine Items` (TBD)

When in the same square as an `Item`, it may provide the following actions:
* `Pick Up Item` (If the item is too large or too heavy, option will be greyed out with (reason))

### Interactive

An `Interactive` is a tile that fires events on entering and exiting.  Some `Interactive`s are not `Active` unless they have
their `Job Party` in their area.

`Interactive`s are available when standing in an adjacent square.

#### Resources

##### Mine
* `Mine Ore`: requires: `mining_pick`, provides `ore`

##### Quarry
* `Extract Raw Stone`: requires: `pickaxe`, `wedge_and_feathers`, provides `raw_stone`
* `Cut Stone`: requires: `stone_chisel`, `hammer`, consumes `raw_stone`, provides `cut_stone`

##### Forest
* `Hunt Game`: requires: `bow`, consumes `arrows`, provides `meat`
* `Chop Wood`: requires: `chopping_axe`, provides `wood`

##### Farm
A `Farm` goes from `Barren` to `Tilled` to `Growing` (or `Overgrown`) to `Ready`.

* `Till Soil`: requires: `hoe`, `Barren`, changes to `Tilled`
* `Plant Food`:  requires: `Tilled`, consumes: `seeds`, changes to `Growing`
* `Weed Plants`: requires: `Overgrown`, `hoe`, changes to `Growing`
* `Harvest Food`: requires: `Ready`, `scythe`, provides: `grain`, changes to `Barren`

##### River or Well
* `Drink Water`
* `Draw Water`: consumes `bucket`, provides `bucket_of_water`

##### Wall
A `Wall` can be `Fine`, `Damaged`, or `Destroyed`.

* `Repair`: requires: `hammer`, `Damaged`, consumes: `wood`, changes to `Fine`
* `Build`: requires: `hammer`, `Destroyed`, consumes: `stone`, changes to `Fine`

#### Crafting

##### Campfire
* `Cook Food`: consumes `meat`, provides `food`

##### Oven
* `Cook Food`: consumes `meat`, provides `food`
* `Bake Bread`: consumes `bucket_of_water`, `flour`, provides `food`

##### Brewery
A `Brewery` goes from `Clean` to `Fermenting` to `Ready` to `Dirty`.

* `Brew Beer`: requires `Clean`, `Brewing`, consumes `bucket_of_water`,`grain`, changes to `Fermenting`
* `Cask Beer`: requires `Ready`, consumes `cask`, changes to `Dirty`, provides `beer`
* `Clean Brewery`: requires `Dirty`, consumes `bucket_of_water`, changes to `Clean`

##### Mill
* `Grind Flour`: consumes `grain`, provides `flour`

##### Joinery
* `Create Bucket`: requires: `Engineering`, consumes `wood`, provides `bucket`
* `Create Cask`: requires: `Engineering`, consumes `wood`, provides `cask`

#### Market
Requires a `Merchant` to be `Active.

* `Sell Ore`: consumes `ore`, provides `gold`
* `Sell Food`: consumes `food`, provides `gold`
* `Sell Wood`: consumes `wood`, provides `gold`
* `Sell Beer`: consumes `cask`, provides `gold`
* `Sell Raw Stone`: consumes `raw_stone`, provides `gold`
* `Sell Cut Stone`: consumes `cut_stone`, provides `gold`
* `Sell Wood`: consumes `wood`, provides `gold`
* `Sell Grain`: consumes `grain`, provides `gold`
* `Sell Flour`: consumes `flour`, provides `gold`
* `Sell Food`: consumes `food`, provides `gold`
* `Sell Beer`: consumes `beer`, provides `gold`
* `Buy Ore`: consumes `gold`, provides `ore`
* `Buy Raw Stone`: consumes `gold`, provides `raw_stone`
* `Buy Cut Stone`: consumes `gold`, provides `cut_stone`
* `Buy Wood`: consumes `gold`, provides `wood`
* `Buy Grain`: consumes `gold`, provides `grain`
* `Buy Flour`: consumes `gold`, provides `flour`
* `Buy Food`: consumes `gold`, provides `food`
* `Buy Beer`: consumes `gold`, provides `beer`
* `Rob`: requires `Roguery`, provides `gold`

#### Apothecary
Requires a `Healer` or `Mystic` to be `Active`.

* `Receive Healing`: improves `Health` for the `Character`
* `Buy <Potion>`: consumes `gold`, provides `<potion>`
* `Buy <Reagent>`: consumes `gold`, provides `<reagent>`

#### Theater
Requires a `Troupe` to be `Active`.

* `Watch Play`: consumes `gold`, improves `Mood`

#### Tavern
Requires a `Host` to be `Active`.

* `Drink Beer`: consumes `gold`, improves `Mood`
* `Drink Wine`: consumes `gold`, improves `Mood`
* `Eat Food`: consumes `gold`, provides `food`, improves `Mood`

#### Temple
Requires `Clergy` to be `Active`.

* `Pray`: improves `Mood`
* `Receive Healing`: improves `Health` for the `Character`
* `Buy <Potion>`: consumes `gold`, provides `<potion>`
* `Donate`: consumes `gold`, improves `Mood`

#### Add more here

### Entrances

An `Entrance` is a tile that allows entry and exit from `Location`s and `Place`s.

When standing on top of an `Entrance`, they may provide the following actions:
* `Enter Village` (at a `Place/Village`)
* `Enter Camp` (at a `Place/Camp`)
* `Enter Town` (at a `Major/Town`)

### Parties

Being next to another `Party` provides an opportunity to interact with them.  

When standing next to a `Party`, they may provide the following actions:
* `Parley`
* `Attack`
* `Inspect`

## Possibility Space

Possibility space `P` is the space where `Motivation` induces `Action`, through a `Course` of action.  We are solving for
optimal traversal of this space via Monte Carlo simulation (see SIMULATION).


