// src/Character.hx
package;

import h2d.Anim;
import h2d.Tile;
import h2d.Object;
import Config;
import Events;
import LdtkProject;
import Location;
import Pathfind;
import Strategy;

class Character extends Object {
    public var charId:String;
    private var anim:h2d.Anim;
    private var windowConfig:WindowConfig;
    public var config:CharConfig;
    private var frames:Array<Tile>;
    private var reAnim:Bool = false;
    private var tileSet:Tileset_Ultima_5;
    private var manager:Null<CharacterManager> = null;
    public var homeId : Int = -1;
    public var workId : Int = -1;
    public var specialTile:Null<SpecialTile> = null;
    public var currentEmergency : Null<CharacterObjective> = null;
    public var currentObjective : Null<CharacterObjective> = null;
    public var currentDecision : Null<CharacterDecision> = null;
    public var currentPath : Array<Coordinate> = new Array<Coordinate>();
    public var currentGoal : Null<Coordinate> = null;
    public var eventQueue : Array<CharacterEvent> = new Array<CharacterEvent>();

    public function new(charId : String, frames:Array<Tile>,
        windowConfig : WindowConfig, charConfig : CharConfig,
        tileSet : Tileset_Ultima_5, ?manager : CharacterManager, 
        ?parent:Object) {
        super(parent);
        this.charId = charId;
        this.frames = frames;
        this.windowConfig = windowConfig;
        this.config = charConfig;
        this.anim = new Anim(frames, windowConfig.animTick, this);
        this.tileSet = tileSet;
        this.manager = manager;
    }

    public function moveTo(x : Int, y : Int, z : Int) : Bool {
        if (manager != null) {
            var oPos = hashCoord(config.x, config.y, config.z);
            var nPos = hashCoord(x, y, z);
            manager.setLocation(charId, oPos, nPos);
        }
        config.x = x;
        config.y = y;
        config.z = z;
        var px = x * windowConfig.gridSize;
        var py = y * windowConfig.gridSize;
        setPosition(px, py);
        if (config.debug) {
            var tgt = '${config.name} moving to ($x, $y, $z) / ($px, $py)';
            if (currentPath.length > 0)
                tgt += ' destination (${currentGoal.x}, ${currentGoal.y}, ${currentGoal.z}) ${currentPath.length} steps';
            trace(tgt);

        }
        return true;
    }

    public function routeTo(destination : Coordinate, location : Location) {
        if (currentGoal?.equals(destination) != true) {
            currentGoal = destination;
            currentPath = getRoute(new Coordinate(config.x, config.y, config.z), destination, location);
        }
    }

    public function nextStep() : Null<Coordinate> {
        if (currentPath.length == 0) return null;
        var next = currentPath.shift();
        return next;
    }

    public function coord() : Coordinate {
        return new Coordinate(config.x, config.y, config.z);
    }

    public function restep(destination : Coordinate, location : Location) : Null<Coordinate> {
        var step = nextStep();
        if (step == null) {
            currentGoal = null;
            routeTo(destination, location);
            step = nextStep();
        }
        return step;
    }

    public function setEffect(effect : StatusEffect, ?history : History) : Void {
        switch (effect) {
            case StatusEffect.BURNING:
                history?.message('You are burning!');
                config.burning = 5;
                reAnim = true;
            case StatusEffect.POISON:
                history?.message('You are poisoned!');
                // Throw to resist
                config.poisoned = 30;
                reAnim = true;
            default:
        }
    }

    public function updateFromLocation(location : Location, ?history : History) {
        var effect = location.isEffect(config.x, config.y, config.z);
        if (effect != null)
            setEffect(effect, history);
        var special = location.isSpecial(config.x, config.y, config.z);
        if (special != null || specialTile != null)
            setSpecialTile(special);
    }

    public function setSpecialTile(tile : Null<SpecialTile>, ?history : History) : Void {
        if (specialTile == tile) return;
        specialTile = tile;
        reAnim = true;
    }

    public function defendVs(opponent : Character, ?history : History) {
        config.health = 0;
        if (config.health <= 0) {
            trace('${config.name} is dead!');
            if (config.down == null || config.down == false)
                history?.message('${config.name} is down!');
            config.down = true;
            reAnim = true;
        }
    }

    public function tick(time : WorldTime, ?history : History) {
        if (config.burning > 0) {
            config.burning--;
            if (config.burning == 0) {
                history?.message('You are no longer burning!');
                config.poisoned = null;
            }
            reAnim = true;
        }
        if (config.poisoned > 0) {
            config.poisoned--;
            if (config.poisoned == 0) {
                history?.message('You are no longer poisoned!');
                config.poisoned = null;
            }
            reAnim = true;
        }
        checkReanim();
    }

    private function checkReanim() {
        if (reAnim) {
            reAnim = false;
            var newFrames : Array<Tile>;
            if (config.down == true) {
                newFrames = [tileSet.getTile(286)];
            } else if (specialTile != null) {
                switch (specialTile) {
                    case SpecialTile.IN_BED:
                        newFrames = [tileSet.getTile(282)];
                    case SpecialTile.SITTING_NORTH:
                        newFrames = [tileSet.getTile(304)];
                    case SpecialTile.SITTING_SOUTH:
                        newFrames = [tileSet.getTile(306)];
                    case SpecialTile.SITTING_EAST:
                        newFrames = [tileSet.getTile(305)];
                    case SpecialTile.SITTING_WEST:
                        newFrames = [tileSet.getTile(307)];
                    default:
                        newFrames = [tileSet.getTile(282)];
                }
            } else {
                newFrames = [for (t in frames) t];
            }
            if (config.burning > 0) {
                var burningTile = tileSet.getTile(490);
                newFrames.pop();
                newFrames.unshift(burningTile);
            }
            if (config.poisoned > 0) {
                var poisonTile = tileSet.getTile(488);
                newFrames.pop();
                newFrames.unshift(poisonTile);
            }
            anim.play(newFrames);
        }
    }

    public function show() {
        visible = true;
        anim.pause = false;
        // anim.play(frames);
        // trace('showing character at (${config.x}, ${config.y}, ${config.z}): ${config.name}');
    }

    public function hide() {
        visible = false; 
        anim.pause = true;
        // trace('hiding character at $x,$y: ${anim}');
    }

    public function addEvent(event : CharacterEvent) {
        eventQueue.push(event);
    }

    public function getKeywords() : Array<String> {
        return ['NAME', 'JOB', 'BYE'];
    }
}
