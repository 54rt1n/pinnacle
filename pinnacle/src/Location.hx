// src/Location.hx
package;

import Config;
import LdtkProject;
import Strategy;

enum LocationObject {
    Character;
    Corpse;
    Wall;
    Door;
    LockedDoor;
    MagicLockedDoor;
    Interactable;
    InteractableWall;
    Traversable;
    Transit;
    Special;
    Trigger;
    Void;
    Nothing;
}

class Coordinate {
    public var x : Int;
    public var y : Int;
    public var z : Int;

    public function new(x : Int, y : Int, z : Int) {
        this.x = x;
        this.y = y;
        this.z = z;
    }

    public function hash() : String {
        return hashCoord(this.x, this.y, this.z);
    }

    public function equals(other : Coordinate) : Bool {
        return this.x == other.x && this.y == other.y && this.z == other.z;
    }

    public function equalsPos(x : Int, y : Int, z : Int) : Bool {
        return this.x == x && this.y == y && this.z == z;
    }

    // Heuristic function (Manhattan distance)
    public function distance(goal : Coordinate) : Float {
        return Math.abs(this.x - goal.x) + Math.abs(this.y - goal.y) + Math.abs(this.z - goal.z);
    }

    // Generate a list of navigable neighbors for a given node
    public function getNeighbors(location : Location) : Array<Coordinate> {
        var neighbors : Array<Coordinate> = [];

        for (dx in -1...2) {
            for (dy in -1...2) {
                if (dx == 0 && dy == 0) continue;  // Skip the current node
                var x = this.x + dx;
                var y = this.y + dy;
                var z = this.z;  // Assume flat movement for simplicity

                // Check if this point is navigable
                var move = location.canMoveTo(x, y, z, true);
                if (move == MoveResult.Ok) {
                    neighbors.push(new Coordinate(x, y, z));
                }
            }
        }

        return neighbors;
    }
}

class Settlement {
    public var id : String;
    public var level : LevelLayer;
    public var ax : Int;
    public var ay : Int;
    public var bx : Int;
    public var by : Int;
    public var home : Map<Int, Coordinate>;
    public var work : Map<Int, Coordinate>;
    public var beds : Map<Int, Coordinate>;

    public function new(id : String, ax : Int, ay : Int, bx : Int, by : Int, level : LevelLayer) {
        this.level = level;
        this.id = id;
        this.ax = ax;
        this.ay = ay;
        this.bx = bx;
        this.by = by;
        this.home = new Map<Int, Coordinate>();
        this.work = new Map<Int, Coordinate>();
        this.beds = new Map<Int, Coordinate>();
    }

    public function addHome(v : Int, x : Int, y : Int, z : Int) {
        if (!this.home.exists(v)) {
            this.home.set(v, new Coordinate(x, y, z));
        }
    }

    public function addWork(v : Int, x : Int, y : Int, z : Int) {
        if (!this.work.exists(v)) {
            this.work.set(v, new Coordinate(x, y, z));
        }
    }

    public function addBed(v : Int, x : Int, y : Int, z : Int) {
        if (!this.beds.exists(v)) {
            this.beds.set(v, new Coordinate(x, y, z));
        }
    }

    public function isDark() : Bool {
        return this.level.dark == true;
    }
}

class Point {
    public var x : Int;  // Coord X
    public var y : Int;  // Coord Y
    public var d : Int;  // Direction
    public var e : Int;  // Energy
    public var l : Int;  // Light

    public function new(x : Int, y : Int, d: Int, e : Int, l : Int = 0) {
        this.x = x;
        this.y = y;
        this.d = d;
        this.e = e;
        this.l = l;
    }

    public function hash() : Int {
        return x * 10000 + y;
    }

    public function diagonalRule(dx : Int, dy : Int) : Array<Point> {
        var center = new Point(x + dx, y + dy, 0, e - 1);
        var spin = new Point(x, y + dy, dx - dy, e - 1);
        var counter = new Point(x + dx, y, dy - dx, e - 1);
        if (d == 0) {
            return [center, spin, counter];
        } else if (d > 0) {
            center.d = 1;
            return [center, spin];
        } else {
            center.d = -1;
            return [center, counter];
        }
    }

    public function horizontalRule(dx : Int) : Array<Point> {
        var center = new Point(x + dx, y, 0, e - 1);
        var spin = new Point(x + dx, y + 1, 1, e - 1);
        var counter = new Point(x + dx, y - 1, -1, e - 1);
        if (d == 0) {
            return [center, spin, counter];
        } else if (d > 0) {
            center.d = 1;
            return [center, spin];
        } else {
            center.d = -1;
            return [center, counter];
        }
    }

    public function verticalRule(dy : Int) : Array<Point> {
        var center = new Point(x, y + dy, 0, e - 1);
        var spin = new Point(x + 1, y + dy, 1, e - 1);
        var counter = new Point(x - 1, y + dy, -1, e - 1);
        if (d == 0) {
            return [center, spin, counter];
        } else if (d > 0) {
            center.d = 1;
            return [center, spin];
        } else {
            center.d = -1;
            return [center, counter];
        }
    }
}

var LightLevel = {
    Pitch : 0,
    Dark : 1,
    Dusk : 2,
    Shady : 3,
    Bright : 4,
}

class Location {
    private var levels : Array<LevelLayer>;
    private var opaqueCoords : Map<String, Bool>;
    private var impassableCoords : Map<String, Bool>;
    private var transitionCoords : Map<String, Int>;
    private var roleCoords : Map<String, Int>;
    private var waterCoords : Map<String, Bool>;
    private var doorCoords : Map<String, DoorType>;
    private var climbCoords : Map<String, Bool>;
    private var tileCoords : Map<String, Int>;
    private var lightCoords : Map<String, Int>;
    private var litCoords : Map<String, Int>;
    private var manager : CharacterManager;
    private var effectCoords : Map<String, StatusEffect>;
    private var specialCoords : Map<String, SpecialTile>;
    private var homeCoords : Map<String, Int>;
    private var assignmentCoords : Map<String, Int>;
    private var settlementCoords : Map<String, String>;
    private var settlements : Map<String, Settlement>;
    private var baseLightLevel : Null<Int>;
    public var lightLevel : Int = LightLevel.Shady;

    var FLOOR_TILE = 68;

    public function new(levels : Array<LevelLayer>,
            tileCoords : Map<String, Int>, opaqueCoords : Map<String, Bool>,
            impassableCoords : Map<String, Bool>, waterCoords : Map<String, Bool>,
            doorCoords : Map<String, DoorType>, climbCoords : Map<String, Bool>,
            roleCoords : Map<String, Int>, transitionCoords : Map<String, Int>,
            lightCoords : Map<String, Int>, effectCoords : Map<String, StatusEffect>,
            specialCoords : Map<String, SpecialTile>, homeCoords : Map<String, Int>,
            assignmentCoords : Map<String, Int>, settlementCoords : Map<String, String>,
            settlements : Map<String, Settlement>, manager : CharacterManager) {
        this.levels = levels;
        this.tileCoords = tileCoords;
        this.opaqueCoords = opaqueCoords;
        this.impassableCoords = impassableCoords;
        this.waterCoords = waterCoords;
        this.doorCoords = doorCoords;
        this.climbCoords = climbCoords;
        this.roleCoords = roleCoords;
        this.transitionCoords = transitionCoords;
        this.lightCoords = lightCoords;
        this.effectCoords = effectCoords;
        this.specialCoords = specialCoords;
        this.homeCoords = homeCoords;
        this.assignmentCoords = assignmentCoords;
        this.settlementCoords = settlementCoords;
        this.settlements = settlements;
        this.manager = manager;
    }

    public function setLightLevel(level : Int) : Bool {
        if (lightLevel == level) {
            return false;
        }
        lightLevel = level;
        return true;
    }

    function doorTileId(pos : String) : Null<Int> {
        var doorType = doorCoords.get(pos);
        var opaque = opaqueCoords.get(pos);
        switch (doorType) {
            case DoorType.Open:
                return FLOOR_TILE;
            case DoorType.Locked:
                return (opaque ? 185 : 187);
            case DoorType.Closed:
                return (opaque ? 184 : 186);
            case DoorType.Sealed:
                return (opaque ? 151 : 152);
            default:
                return null;
        }
    }

    public function getTileId(x : Int, y : Int, z : Int) : Int {
        var pos = hashCoord(x, y, z);
        var doorTileId = doorTileId(pos);
        if (doorTileId != null) {
            return doorTileId;
        }
        var tileId = tileCoords.get(pos);
        // If we don't have a tile at our level, check below us
        if (tileId == null) {
            var mz = z - 1;
            while (tileId == null && mz >= 0) {
                tileId = tileCoords.get(hashCoord(x, y, mz));
                if (tileId != null) break;
                mz--;
            }
        }
        if (tileId == null) {
            tileId = 492;
        }
        return tileId;
    }

    public function hideAllInteractives() {
        if (manager == null) {
            return;
        }
        for(character in manager.characters) {
            character.hide();
        }
    }

    public function getCharacterAt(x : Int, y : Int, z : Int) : Character {
        if (manager == null) {
            return null;
        }
        return manager.getCharacterAt(x, y, z);
    }

    public function showInteractiveAt(x : Int, y : Int, z : Int, alpha : Float = 1.0) {
        if (manager == null) {
            trace('no character manager to show interactive at $x, $y, $z');
            return;
        }
        var character = manager.getCharacterAt(x, y, z);
        if (character != null) {
            character.alpha = alpha;
            character.show();
        }
    }

    public function obscuredView(x : Int, y : Int, z : Int) : Bool  {
        var pos = hashCoord(x, y, z);

        var tileId = tileCoords.get(pos);
        if (tileId == null) {
            return false;
        }

        // If our door is false, it is open.
        if (doorCoords.get(pos) == DoorType.Open) {
            return false;
        }

        if (opaqueCoords.exists(pos)) {
            return true;
        }

        return false;
    }

    public function canMoveTo(x : Int, y : Int, z : Int,
         passDoor : Bool = false, passWater : Bool = false, phased : Bool = false) : MoveResult {
        var pos = hashCoord(x, y, z);

        if (x == manager.main.config.x && y == manager.main.config.y && z == manager.main.config.z) {
            return MoveResult.Self;
        }
        
        if (manager.getCharacterAt(x, y, z) != null) {
            return MoveResult.Character;
        }
        if (impassableCoords.exists(pos) && !phased) {
            return MoveResult.Impassable;
        }
        if (doorCoords.exists(pos) && !passDoor && !phased) {
            if (doorCoords.get(pos) != DoorType.Open)
                return MoveResult.Door;
        }
        if (waterCoords.exists(pos) && !passWater && !phased) {
            return MoveResult.Water;
        }
        if (climbCoords.exists(pos) && !phased) {
            return MoveResult.Climbable;
        }
        return MoveResult.Ok;
    }

    public function canClimbTo(x : Int, y : Int, z : Int) : Bool {
        var pos = hashCoord(x, y, z);
        return climbCoords.exists(pos);
    }

    public function isWater(x : Int, y : Int, z : Int) : Bool {
        var pos = hashCoord(x, y, z);
        return waterCoords.exists(pos);
    }

    public function isStairs(x : Int, y : Int, z : Int) : Null<Int> {
        var pos = hashCoord(x, y, z);
        if (transitionCoords.exists(pos)) {
            var nz = transitionCoords.get(pos);
            trace('level transition to $nz');
            return nz;
        }
        return null;
    }

    public function getHomeFor(settlementId : String, homeId : Int) : Null<Coordinate> {
          var s = settlements.get(settlementId);
        if (s == null) {
            return null;
        }
        return s.home.get(homeId);
    }

    public function getWorkFor(settlementId : String, workId : Int) : Null<Coordinate> {
        var s = settlements.get(settlementId);
        if (s == null) {
            return null;
        }
        return s.work.get(workId);
    }

    public function getBedFor(settlementId : String, homeId : Int) : Null<Coordinate> {
        var s = settlements.get(settlementId);
        if (s == null) {
            return null;
        }
        var bed = s.beds.get(homeId);
        if (homeId == 6) {
            trace('beds for $settlementId $homeId ${bed.x} ${bed.y} ${bed.z}');
        }
        // trace('beds for $settlementId $homeId ${s.beds}');
        return bed;
    }

    public function isHome(coord : Coordinate, homeId : Int) : Bool {
        var pos = coord.hash();
        if (homeCoords.exists(pos)) {
            var home = homeCoords.get(pos);
            return home == homeId;
        }
        return false;
    }

    public function isWork(coord : Coordinate, workId : Int) : Bool {
        var pos = coord.hash();
        if (assignmentCoords.exists(pos)) {
            var work = assignmentCoords.get(pos);
            return work == workId;
        }
        return false;
    }

    public function isLit(x : Int, y : Int, z : Int) : Int {
        var pos = hashCoord(x, y, z);
        var ambient = lightLevel;
        /*
        var settlementId = settlementCoords.get(pos);
        if (settlementId != null) {
            var s = settlements.get(settlementId);
            if (s != null) {
                if (s.isDark())
                    ambient = LightLevel.Pitch; 
            }
        }
        */
        if (z < 0) {
            ambient = LightLevel.Pitch;
        }
        return Math.floor(Math.max(litCoords.get(pos) ?? 0, ambient));
    }

    public function isEffect(x : Int, y : Int, z : Int) : Null<StatusEffect> {
        var pos = hashCoord(x, y, z);
        if (effectCoords.exists(pos)) {
            return effectCoords.get(pos);
        }
        return null;
    }

    public function isSpecial(x : Int, y : Int, z : Int) : Null<SpecialTile> {
        var pos = hashCoord(x, y, z);
        if (specialCoords.exists(pos)) {
            return specialCoords.get(pos);
        }
        return null;
    }

    public function isDoor(x : Int, y : Int, z : Int) : Null<DoorType> {
        var pos = hashCoord(x, y, z);
        if (doorCoords.exists(pos)) {
            return doorCoords.get(pos);
        }
        return null;
    }

    public function useDoor(x : Int, y : Int, z : Int) : Null<DoorType> {
        var pos = hashCoord(x, y, z);
        if (!doorCoords.exists(pos)) return null;
        var doorType = doorCoords.get(pos);
        if (doorType == DoorType.Closed) {
            doorCoords.set(pos, DoorType.Open);
            return DoorType.Open;
        } else {
            return doorType;
        }
    }

    public function unlockDoor(x : Int, y : Int, z : Int) : Null<DoorType> {
        var pos = hashCoord(x, y, z);
        if (!doorCoords.exists(pos)) return null;
        var doorType = doorCoords.get(pos);
        if (doorType == DoorType.Locked) {
            doorCoords.set(pos, DoorType.Closed);
            return DoorType.Closed;
        } else {
            return doorType;
        }
    }

    public function objectAt(x : Int, y : Int, z : Int) : LocationObject {
        var pos = hashCoord(x, y, z);
        if (manager.getCharacterAt(x, y, z) != null) {
            return LocationObject.Character;
        }
        if (impassableCoords.exists(pos)) {
            return LocationObject.Wall;
        }
        if (climbCoords.exists(pos)) {
            return LocationObject.Traversable;
        }
        if (doorCoords.exists(pos)) {
            return LocationObject.Door;
        }
        if (waterCoords.exists(pos)) {
            return LocationObject.Traversable;
        }
        return LocationObject.Nothing;
    }

    public function roleAt(x : Int, y : Int, z : Int) : Null<Int> {
        var pos = hashCoord(x, y, z);
        if (roleCoords.exists(pos)) {
            return roleCoords.get(pos);
        }
        return null;
    }

    public function settlementAt(x : Int, y : Int, z : Int) : Null<Settlement> {
        var pos = hashCoord(x, y, z);
        if (settlementCoords.exists(pos)) {
            var settlementId = settlementCoords.get(pos);
            return settlements.get(settlementId);
        }
        return null;
    }

    public function tickAll(time : WorldTime) {
        for (character in manager.characters) {
            var choice = manager.determineDecision(character, time, this);
            if (choice != null) {
                switch (choice) {
                    case CharacterDecision.Move(x, y, z):
                        var moveResult = canMoveTo(x, y, z, true);
                        if (moveResult == MoveResult.Ok) {
                            if (character.moveTo(x, y, z)) {
                                character.updateFromLocation(this);
                            }
                        } else {
                            if (character.config.debug)
                                trace('${character.config.name} can\'t move to $x, $y, $z: $moveResult');
                            character.currentPath = [];
                        }
                    case CharacterDecision.Wait:
                        if (character.config.debug)
                            trace('${character.config.name} waiting');
                    default:
                        trace('${character.config.name} has unknown choice ${choice}');
                }
            } else {
                if (character.config.debug)
                    trace('${character.config.name} has no choices');
            }
            character.tick(time);
        }
    }

    public function viewFrom(x : Int, y : Int, z : Int, viewRadius: Int,
         checkLight: Bool = false, selfLight: Int = 0, trueSight: Int = 0
         ) : Array<Point> {
        var show = new Map<Int, Point>();
        var vis = new Map<Int, Bool>();

        var selfLightArc = new Map<Int, Int>();
        var trueSightPoints = new Map<Int, Point>();
        // We are going to cast our light out in a circle, diameter seflLight, 
        // and encode all the x,y points as x * 10000 + y (p.hash())
        for (i in 0...32) {
            var rad = i * Math.PI / 16;
            var dx = Math.cos(rad);
            var dy = Math.sin(rad);
            for (j in 0...selfLight) {
                var px = Math.floor(x + dx * j + .5);
                var py = Math.floor(y + dy * j + .5);
                selfLightArc.set(px * 10000 + py, selfLight - j + 1);
            }
            for (j in 0...trueSight) {
                var px = Math.floor(x + dx * j + .5);
                var py = Math.floor(y + dy * j + .5);
                trueSightPoints.set(px * 10000 + py, new Point(px, py, 0, trueSight - j));
            }
        }
    
        function checkPoint(p: Point) : Bool  {
            var ph = p.hash();
            
            if (vis.exists(ph)) {
                return vis.get(ph);
            }

            if (checkLight) {
                var areaLight = isLit(p.x, p.y, z);
                var selfLight = selfLightArc.get(ph);
                var light = Math.floor(Math.max(areaLight, selfLight));
                if (light > 0) {
                    p.l = light;
                    show.set(ph, p);
                }
            } else {
                show.set(ph, p);
            }

            if (obscuredView(p.x, p.y, z)) {
                vis.set(ph, false);
                return false;
            } else {
                vis.set(ph, true);
            }

            // If the point is out of energy, exit
            if (p.e < 0)
                return false;

            return true;
        }

        var mark = new Map<Int, Bool>();
        
        var queue = new Array<Point>();
        // Diagonals
        for ( c in [[1, 1], [-1, 1], [1, -1], [-1, -1]]) {
            var i = c[0];
            var j = c[1];
            queue.push(new Point(x + i, y + j, 0, viewRadius));
            while (queue.length > 0) {
                var point = queue.shift();
                var ph = point.hash();
                if (mark.get(ph)) continue;
                mark.set(ph, true);
                var check = checkPoint(point);
                if (check) {
                    var points = point.diagonalRule(i, j);
                    for (np in points) {
                        if (np.e < 0) continue;
                        var nh = np.hash();
                        if (mark.exists(nh)) continue;
                        mark.set(nh, false);
                        queue.push(np);
                    }
                }
                if (queue.length > 10000) {
                    trace('Queue too long, breaking');
                    break;
                }
            }
        }

        // North / South
        for ( i in [-1, 1] ) {
            queue.push(new Point(x, y + i, 0, viewRadius));
            while (queue.length > 0) {
                var point = queue.shift();
                var ph = point.hash();
                if (mark.get(ph)) continue;
                mark.set(ph, true);
                var check = checkPoint(point);
                if (check) {
                    var points = point.verticalRule(i);
                    for (np in points) {
                        if (np.e < 0) continue;
                        var nh = np.hash();
                        if (mark.exists(nh)) continue;
                        mark.set(nh, false);
                        queue.push(np);
                    }
                }
                if (queue.length > 10000) {
                    trace('Queue too long, breaking');
                    break;
                }
            }
        }

        // West / East
        for ( i in [-1, 1] ) {
            queue.push(new Point(x + i, y, 0, viewRadius));
            while (queue.length > 0) {
                var point = queue.shift();
                var ph = point.hash();
                if (mark.get(ph)) continue;
                mark.set(ph, true);
                var check = checkPoint(point);
                if (check) {
                    var points = point.horizontalRule(i);
                    for (np in points) {
                        if (np.e < 0) continue;
                        var nh = np.hash();
                        if (mark.exists(nh)) continue;
                        mark.set(nh, false);
                        queue.push(np);
                    }
                }
                if (queue.length > 10000) {
                    trace('Queue too long, breaking');
                    break;
                }
            }
        }

        for (p in trueSightPoints.keyValueIterator()) {
            show.set(p.key, p.value);
        }

        show.set(x * 10000 + y, new Point(x, y, 0, viewRadius, selfLight));
    
        return [for (kv in show.keyValueIterator()) kv.value];
    }

    private function calculateLightRadius() {
        // For each light source, we need to calculate the radius of the light.

        var newLitCoords = new Map<String, Int>();

        // We are going to cast our light out in a circle, diameter seflLight, 
        // and encode all the x,y points as x * 10000 + y (p.hash())
        for (lc in lightCoords.keyValueIterator()) {
            var x_y_z = lc.key.split(',');
            var x = Std.parseInt(x_y_z[0]);
            var y = Std.parseInt(x_y_z[1]);
            var z = Std.parseInt(x_y_z[2]);
            var lightArc = new Map<Int, Int>();
            for (i in 0...32) {
                var rad = i * Math.PI / 16;
                var dx = Math.cos(rad);
                var dy = Math.sin(rad);
                for (j in 0...lc.value) {
                    var px = Math.floor(x + dx * j + .5);
                    var py = Math.floor(y + dy * j + .5);
                    var sh = hashCoord(px, py, z);
                    if (opaqueCoords.exists(sh)) 
                        break;
                    var newValue = lc.value - j + 1;
                    var oldValue = newLitCoords.get(sh) ?? 0;
                    if (newValue > oldValue) {
                        newLitCoords.set(sh, newValue);
                    }
                }
            }
        }

        return newLitCoords;
    }

    public static function create(tileSet: Tileset_Ultima_5, levels : Array<LevelLayer>, characterManager : CharacterManager) : Location {
        // For each layer, we need to build a coordinate map of the opaque tiles.
        // We also need to build a coordinate map of the impassible tiles.
        // We need to build a coordinate map of the entities.
        var LIGHT_RADIUS = 5;

        var impassibleIds = new Map<Int, Bool>();
        var waterIds = new Map<Int, Bool>();
        var opaqueIds = new Map<Int, Bool>();
        var doorIds = new Map<Int, Bool>();
        var lockedIds = new Map<Int, Bool>();
        var sealedIds = new Map<Int, Bool>();
        var climbIds = new Map<Int, Bool>();
        var lightIds = new Map<Int, Bool>();
        var burningIds = new Map<Int, Bool>();
        var toxicIds = new Map<Int, Bool>();
        var bedIds = new Map<Int, Bool>();
        var ladderIds = new Map<Int, Bool>();
        var chairIds = new Map<Int, Bool>();
        var northIds = new Map<Int, Bool>();
        var southIds = new Map<Int, Bool>();
        var eastIds = new Map<Int, Bool>();
        var westIds = new Map<Int, Bool>();
        var upIds = new Map<Int, Bool>();
        var downIds = new Map<Int, Bool>();
        for (row in tileSet.json.customData) {
            opaqueIds.set(row.tileId, row.data.indexOf('opaque') >= 0);
            impassibleIds.set(row.tileId, row.data.indexOf('impassable') >= 0);
            waterIds.set(row.tileId, row.data.indexOf('water') >= 0);
            doorIds.set(row.tileId, row.data.indexOf('door') >= 0);
            lockedIds.set(row.tileId, row.data.indexOf('locked') >= 0);
            sealedIds.set(row.tileId, row.data.indexOf('sealed') >= 0);
            climbIds.set(row.tileId, row.data.indexOf('climbable') >= 0);
            lightIds.set(row.tileId, row.data.indexOf('light') >= 0);
            burningIds.set(row.tileId, row.data.indexOf('burning') >= 0);
            toxicIds.set(row.tileId, row.data.indexOf('toxic') >= 0);
            bedIds.set(row.tileId, row.data.indexOf('bed') >= 0);
            ladderIds.set(row.tileId, row.data.indexOf('ladder') >= 0);
            chairIds.set(row.tileId, row.data.indexOf('chair') >= 0);
            northIds.set(row.tileId, row.data.indexOf('north') >= 0);
            southIds.set(row.tileId, row.data.indexOf('south') >= 0);
            eastIds.set(row.tileId, row.data.indexOf('east') >= 0);
            westIds.set(row.tileId, row.data.indexOf('west') >= 0);
            upIds.set(row.tileId, row.data.indexOf('up') >= 0);
            downIds.set(row.tileId, row.data.indexOf('down') >= 0);
        }

        var opaqueCoords = new Map<String, Bool>();
        var impassableCoords = new Map<String, Bool>();
        var waterCoords = new Map<String, Bool>();
        var doorCoords = new Map<String, DoorType>();
        var climbCoords = new Map<String, Bool>();
        var lightCoords = new Map<String, Int>();
        var tileCoords = new Map<String, Int>();
        var roleCoords = new Map<String, Int>();
        var transitionCoords = new Map<String, Int>();
        var effectCoords = new Map<String, StatusEffect>();
        var specialCoords = new Map<String, SpecialTile>();
        var homeCoords = new Map<String, Int>();
        var assignmentCoords = new Map<String, Int>();
        var settlementCoords = new Map<String, String>();
        var enemyCoords = new Map<String, Int>();
        var itemCoords = new Map<String, Int>();
        var settlements = new Map<String, Settlement>();

        for (levelLayer in levels) {
            var level = levelLayer.level;
            if (level == null) {
                trace('No level for layer ' + levelLayer);
                continue;
            }
            var layers = [
                level.l_Structures.autoTiles,
                level.l_Terrain.autoTiles,
            ];
            var ground = level.l_Ground;
            var z = levelLayer.z;
            var xOff = levelLayer.xOff;
            var yOff = levelLayer.yOff;
            var u = Math.floor(level.pxWid / 16);
            var v = Math.floor(level.pxHei / 16);
            var settlementId = levelLayer.settlement;

            var settlement = settlements.get(settlementId);
            if (settlement == null)
                settlement = new Settlement(settlementId, xOff, yOff, u, v, levelLayer);

            function fixCoordinate(cx : Int, cy : Int, cz : Int, tileId : Int, isSettlement : Bool) : Bool {
                var pos = hashCoord(cx, cy, cz);
                var update = false;
                if (opaqueIds.get(tileId)) {
                    opaqueCoords.set(pos, true);
                }
                if (impassibleIds.get(tileId)) {
                    impassableCoords.set(pos, true);
                    update = true;
                }
                if (waterIds.get(tileId)) {
                    waterCoords.set(pos, true);
                }
                if (doorIds.get(tileId)) {
                    doorCoords.set(pos, DoorType.Closed);
                    update = true;
                } else if (lockedIds.get(tileId)) {
                    doorCoords.set(pos, DoorType.Locked);
                    update = true;
                } else if (sealedIds.get(tileId)) {
                    doorCoords.set(pos, DoorType.Sealed);
                    update = true;
                }
                if (climbIds.get(tileId)) {
                    climbCoords.set(pos, true);
                    update = true;
                }
                if (lightIds.get(tileId)) {
                    lightCoords.set(pos, LIGHT_RADIUS);
                    update = true;
                }
                if (burningIds.get(tileId)) {
                    effectCoords.set(pos, StatusEffect.BURNING);
                }
                if (toxicIds.get(tileId)) {
                    effectCoords.set(pos, StatusEffect.POISON);
                }
                if (bedIds.get(tileId)) {
                    specialCoords.set(pos, SpecialTile.IN_BED);
                    update = true;
                }
                if (chairIds.get(tileId)) {
                    if (northIds.get(tileId))
                        specialCoords.set(pos, SpecialTile.SITTING_NORTH);
                    else if (southIds.get(tileId))
                        specialCoords.set(pos, SpecialTile.SITTING_SOUTH);
                    else if (eastIds.get(tileId))
                        specialCoords.set(pos, SpecialTile.SITTING_EAST);
                    else if (westIds.get(tileId))
                        specialCoords.set(pos, SpecialTile.SITTING_WEST);
                    update = true;
                }
                if (!tileCoords.exists(pos)) {
                    tileCoords.set(pos, tileId);
                    update = true;
                }
                if (update && isSettlement && settlementId != null)
                    settlementCoords.set(hashCoord(cx, cy , cz), settlementId);
                return update;
            }
            
            // settlement is our first layer
            var first = true;
            
            for (layer in layers) {
                for (tile in layer) {
                    var x = Math.floor(tile.renderX / ground.gridSize);
                    var y = Math.floor(tile.renderY / ground.gridSize);
                    //trace('tile ${x + xOff}, ${y + yOff}, ${tile.tileId}');
                    fixCoordinate(x + xOff, y + yOff, z, tile.tileId, first);
                }
                first = false;
            }

            for (x in 0...ground.cWid) {
                for (y in 0...ground.cHei) {
                    if (ground.hasAnyTileAt(x, y)) {
                        var tiles = ground.getTileStackAt(x, y);
                        if (tiles.length >= 0 && tiles[0].tileId > 0) {
                            fixCoordinate(x + xOff, y + yOff, z, tiles[0].tileId, false);
                        }
                    }
                    var pos = hashCoord(x + xOff, y + yOff, z);
                    var hv = level.l_Homes.getInt(x, y);
                    var wv = level.l_Assignments.getInt(x, y);
                    var bv = level.l_Beds.getInt(x, y);
                    if (hv > 0) {
                        homeCoords.set(hashCoord(x + xOff, y + yOff, z), hv);
                        settlement?.addHome(hv, x + xOff, y + yOff, z);
                        if (specialCoords.get(pos) == SpecialTile.IN_BED)
                            settlement?.addBed(hv, x + xOff, y + yOff, z);
                    }
                    if (wv > 0) {
                        assignmentCoords.set(hashCoord(x + xOff, y + yOff, z), wv);
                        settlement?.addWork(wv, x + xOff, y + yOff, z);
                    }
                    if (bv > 0) {
                        settlement?.addBed(bv, x + xOff, y + yOff, z);
                    }
                    var ev = level.l_Enemies.getInt(x, y);
                    if (ev > 0) {
                        enemyCoords.set(hashCoord(x + xOff, y + yOff, z), ev);
                    }
                    var iv = level.l_Loot.getInt(x, y);
                    if (iv > 0) {
                        itemCoords.set(hashCoord(x + xOff, y + yOff, z), iv);
                    }
                    /*
                    var roleId = level.l_Roles.getInt(x, y);
                    if (roleId >= 0) {
                        roleCoords.set(hashCoord(x + xOff, y + yOff, z), roleId);
                    }
                    */
                }
            }

            for (e in level.l_Entities.all_LocationUp) {
                var lx = e.cx + xOff;
                var ly = e.cy + yOff;
                var lz = z + 1;
                transitionCoords.set(hashCoord(lx, ly, z), lz);
            }

            for (e in level.l_Entities.all_LocationDown) {
                var lx = e.cx + xOff;
                var ly = e.cy + yOff;
                var lz = z - 1;
                transitionCoords.set(hashCoord(lx, ly, z), lz);
            }

            if (settlementId != null)
                settlements.set(settlementId, settlement);
            trace('settlement ${settlementId} has ${settlement.home} homes and ${settlement.work} works and ${settlement.beds} beds');

        }

        var location = new Location(levels, tileCoords, opaqueCoords, impassableCoords, waterCoords, 
            doorCoords, climbCoords, roleCoords, transitionCoords, lightCoords, effectCoords,
            specialCoords, homeCoords, assignmentCoords, settlementCoords, settlements,
            characterManager);

        location.litCoords = location.calculateLightRadius();

        return location;
    }
}