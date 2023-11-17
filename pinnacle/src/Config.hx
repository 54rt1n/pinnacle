// src/Config.hx
package;

import LdtkProject;

/*

  We have a set of modes and actions

  The different states we can switch between is:
    Active Mode; this is the default mode, where the character can move
     around and interact with the world.
      
    Combat Mode; this is when a character's weapons are drawn.
      The character can still use objects and climb, but cannot talk 

*/

enum PinnacleScreens {
    OverworldScreen;
    LocationScreen;
    BattleScreen;
    JournalScreen;
    InventoryScreen;
    CharacterScreen;
}

enum PinnacleAction {
    // Stationary 
    Wait;
    Sleep;
    Go;       // Enter, exit, stairs, ladder, portal...
    
    // Directional
    Move;
    Ford;     // Climb, swim, jump...
    Use;      // Open a door, craft, cook, read, play music...
    Talk;     // Talk to a character
    Search;   // Search a container, or a wall
    Get;      // Pick up an item
    Drop;     // Drop an item
    // Combat
    Attack;
    // Roguery
    Rob;
}

enum PinnacleDirection {
    North;
    NorthWest;
    NorthEast;
    South;
    SouthWest;
    SouthEast;
    East;
    West;
    Up;
    Down;
    None;
}

enum ActionResult {
    Move;
    Stay;
    Blocked;
    Hit;
    Missed;
}

enum DoorType {
    Open;
    Closed;
    Locked;
    Sealed;
    Hidden;
}

typedef WindowConfig = { 
    windowSize : Int,
    gridSize : Float, 
    scale : Int, 
    animTick : Float, 
    offsetX : Int, 
    offsetY : Int 
}

enum Stance {
    Standing;
    Crouched;
    Kneeling;
    Crawling;
    Sitting;
    Laying;
}

typedef CharConfig = { 
    ?charId : String,
    ?name : String,
    ?faction : Int,
    ?role : Int,
    ?settlement : String,
    ?assignment : Int,
    ?home : Int,
    ?bed : Int,
    ?family : Int,
    ?portrait : String,

    // Metadata
    ?action : PinnacleAction,
    ?direction : PinnacleDirection,

    // State
    ?x : Int,
    ?y : Int,
    ?z : Int,
    ?health: Int,
    ?food: Int,
    ?down: Bool,
    ?dead : Bool,
    ?viewRadius : Int,
    ?selfLight: Int,
    ?trueSight: Int,
    ?burning : Int,
    ?poisoned : Int,
    ?stun : Int,

    // Stances
    ?stance : Stance,
    ?combat : Bool,
    ?roguery : Bool,
    ?caster : Bool,
    ?phase : Bool,
    ?chaos : Bool,
    ?fly : Bool,
    ?sleeping : Bool,

    ?debug: Bool,
}

typedef LocationCoord = {
    x : Int,
    y : Int,
    z : Int,
}

@:keep function hashCoord(x : Int, y : Int, z : Int) : String {
    var xa = '$x';
    var ya = '$y';
    var za = '$z';
    return '$xa,$ya,$za';
}

typedef LevelLayer = { levelId: String, settlement: String,
     xOff: Int, yOff: Int, z: Int,
    level: LdtkProject_Level, ?dark: Bool, ?ground: Bool }

enum StatusEffect {
    BURNING;
    POISON;
    LAYING;
}

enum SpecialTile {
    IN_BED;
    SITTING_NORTH;
    SITTING_SOUTH;
    SITTING_EAST;
    SITTING_WEST;
    EATING_NORTH;
    EATING_SOUTH;
}

var Role = {
    Player: 1,
    Neutral: 2,
    Inn: 3,
    Watch: 4,
    Farm: 5,
    Musician: 6,
    GuestA: 7,
    GuestB: 8,
}

var Zone = {
    Work: 1,
    Home: 2,
    Meal: 3,
    Other: 4,
    Workable: 5,
}

enum MoveResult {
    Self;
    Character;
    Impassable;
    Door;
    Water;
    Climbable;
    Ok;
}