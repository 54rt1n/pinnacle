// src/Pinnacle.hx
package;

import h2d.Object;
import h2d.Text;
import h2d.Camera;
import hxd.Key;
import hxd.Res;
import hxd.System;
import CastleData;
import CharacterManager;
import Config;
import DataOverlay;
import DialogOverlay;
import Events;
import Hacks;
import LdtkProject;
import Location;
import ViewFilters;
import Weather;
import WorldTime;

enum CharMode {
    Active;
    Sit;
    Sleep;
    Stun;
    Knockout;
    Dead;
    Caster;
    Roguery;
    Battle;
    Phase;
    Fly;
}

class Pinnacle extends hxd.App {
    private var windowConfig : WindowConfig;
    private var mainConfig : CharConfig;
    private var mainCharacter : Character;
    private var manager : CharacterManager;
    private var project : LdtkProject;
    private var viewWindow : Object;
    private var viewArea: ViewArea;
    private var debug : Text;
    private var location : Location;
    private var charCamera : Camera;
    private var dialog : DialogOverlay;
    private var data : DataOverlay;
    private var viewFilters : ViewFilters;
    private var castleDb : CastleData;
    private var shouldRedraw : Bool = false;
    private var time : WorldTime;
    private var weather : Weather;
    private var fitSize = 384;
    private var defaultVision = 15;
    private var rogueVision = 5;

    private var ticks = 0;

    function initDb() {
        var stringData = sys.io.File.getContent("res/data.cdb");
        CastleData.load(stringData);
    }

    function loadLevel() {
        var levels = [];
        var allLevels = CastleData.levels.all;
        for (row in allLevels) {
            if (row.locationId.toString() != "Harrad")
                continue;
            var levelId = row.levelId.toString();
            var settlement = row.settlementId.toString();
            levels.push({ levelId: levelId, settlement: settlement,
                xOff: row.xOff, yOff: row.yOff, z: row.z, 
                level: project.all_worlds.Default.getLevel(null, levelId),
                dark: row.dark, ground: row.ground ?? false });
        }

        manager = CharacterManager.create(project.all_tilesets.Ultima_5, windowConfig, this);

        location = Location.create(project.all_tilesets.Ultima_5, levels, manager);
        
        manager.loadLocation("Harrad");

        mainCharacter = manager.main;
        mainConfig = mainCharacter.config;

        viewArea = new ViewArea(
            project.all_tilesets.Ultima_5, location, 
            windowConfig, mainConfig);
        
        viewWindow.addChild(viewArea);

        viewWindow.addChild(manager);

        viewWindow.addChild(manager.main);
        mainConfig.action = PinnacleAction.Move;
    }

    override function init() {
        super.init();
        initDb();
        project = new LdtkProject();
        var level = project.all_worlds.Default.all_levels.Harrad;
        var ground = level.l_Ground;

        windowConfig = {
            windowSize: 256,
            gridSize: ground.gridSize,
            scale: dn.heaps.Scaler.bestFit_i(fitSize, fitSize),
            animTick: 2,
            offsetX: ground.pxTotalOffsetX,
            offsetY: ground.pxTotalOffsetY,
        };
        s2d.removeChildren();
        viewWindow = new Object();
        viewFilters = new ViewFilters();
        time = new WorldTime(520);
        weather = new Weather();
        
        loadLevel();
        charCamera = new h2d.Camera(s2d);
        charCamera.layerVisible = (layer) -> layer == 2;

        var uiCamera = new h2d.Camera(s2d);
        uiCamera.layerVisible = (layer) -> layer == 3;
    
        var dialogCamera = new h2d.Camera(s2d);
        dialogCamera.layerVisible = (layer) -> layer == 4;
    
        s2d.add(viewWindow, 2);

        data = new DataOverlay(windowConfig, manager.party);
        s2d.add(data, 3);

        var font = hxd.res.DefaultFont.get();

        debug = new h2d.Text(font);
        debug.x = debug.y = 5;
        s2d.add(debug, 3);

        dialog = new DialogOverlay(windowConfig, mainConfig);
        s2d.add(dialog, 4);

        s2d.interactiveCamera.visible = false;
        viewArea.filter = viewFilters.view;
        manager.filter = viewFilters.chars;
        manager.main.filter = viewFilters.main;
        fixWindow();

        var startArea = project.all_worlds.Default.all_levels.Start_Area;
        var startPosition = startArea.l_Entities.all_GameStart[0];
        var cx = Math.floor(startArea.worldX / 16) + startPosition.cx;
        var cy = Math.floor(startArea.worldY / 16) + startPosition.cy;

        manager.addToParty(mainConfig);
        manager.addToParty({ charId: "barto", name: 'Adrian Barto', faction: 1, role: null, health: 100 });

        // Use this value to get the character start position
        // moveTo(cx, cy, 0);
        // moveTo(95, 100, 0);
        // Test if bad main camera
        // moveTo(4, 4, 0);
        // Test if view area is correct.
        moveTo(79, 102, 0);
        refreshLight();
        redrawCamera();
    }

    function fixWindow() {
        var stage = hxd.Window.getInstance();
        windowConfig.scale = dn.heaps.Scaler.bestFit_i(fitSize, fitSize);
        //viewArea.setScale(windowConfig.scale);
        //manager.main.setScale(windowConfig.scale);
        //manager.setScale(windowConfig.scale);
        //s2d.setScale(windowConfig.scale);
        viewWindow.setScale(windowConfig.scale);
        manager.onResize();
        data.onResize();
        dialog.onResize();
        trace('Resized to ${stage.width}px * ${stage.height}px : ${windowConfig.scale}');
    }

    override function onResize() {
        super.onResize();
        fixWindow();
        redrawCamera();
    }

    function moveTo(x : Int, y : Int, z : Int) {
        if (mainCharacter.moveTo(x, y, z)) {
            mainCharacter.updateFromLocation(location, data.history);
        }
    }

    public function updateData() {
        data.refresh();
    }

    function redrawCamera() {
        debug.text = 'x: ${mainConfig.x} y: ${mainConfig.y} z: ${mainConfig.z} t: ${time.ticks} l: ${location.lightLevel}';

        // Recalculate the current visible tiles.
        viewArea.viewFrom(mainConfig.x, mainConfig.y, mainConfig.z);

        // Set the camera position to be over our character.
        // The view should be centered 
        var scaledX = ((mainConfig.x - 15) * windowConfig.scale * windowConfig.gridSize);
        var scaledY = ((mainConfig.y - 15) * windowConfig.scale * windowConfig.gridSize);
        charCamera.setPosition(scaledX, scaledY);
    }

    override function update(dt:Float) {
        super.update(dt);
        handleInput();
    }

    function getDirectionCoord(direction : PinnacleDirection) : LocationCoord {
        var x : Int = mainCharacter.config.x;
        var y : Int = mainCharacter.config.y;
        var z : Int = mainCharacter.config.z;
        switch (direction) {
            case PinnacleDirection.North:
                y -= 1;
            case PinnacleDirection.NorthEast:
                y -= 1;
                x += 1;
            case PinnacleDirection.East:
                x += 1;
            case PinnacleDirection.SouthEast:
                y += 1;
                x += 1;
            case PinnacleDirection.South:
                y += 1;
            case PinnacleDirection.SouthWest:
                y += 1;
                x -= 1;
            case PinnacleDirection.West:
                x -= 1;
            case PinnacleDirection.NorthWest:
                y -= 1;
                x -= 1;
            case PinnacleDirection.Up:
                z += 1;
            case PinnacleDirection.Down:
                z -= 1;
            default:
        }

        return {x: x, y: y, z: z};
    }

    function actionMove(direction : PinnacleDirection) : ActionResult {
        if (direction == PinnacleDirection.None) {
            return ActionResult.Stay;
        }
        var coord = getDirectionCoord(direction);
        var moveResult = location.canMoveTo(coord.x, coord.y, coord.z, false, false, mainConfig.phase);
        if (moveResult == MoveResult.Ok) {
            moveTo(coord.x, coord.y, coord.z);
            addHistory('${direction}');
            return ActionResult.Move;
        }

        return ActionResult.Stay;
    }

    function actionFord(direction : PinnacleDirection) : ActionResult {
        if (direction == PinnacleDirection.None) {
            return ActionResult.Stay;
        }
        var coord = getDirectionCoord(direction);
        if (location.canClimbTo(coord.x, coord.y, coord.z)) {
            moveTo(coord.x, coord.y, coord.z);
            addHistory('Climbed');
            return ActionResult.Move;
        }
        if (location.isWater(coord.x, coord.y, coord.z)) {
            moveTo(coord.x, coord.y, coord.z);
            addHistory('Swam');
            return ActionResult.Move;
        }

        return ActionResult.Stay;
    }

    var lastTimeEvent : Null<CharacterEvent> = null;

    function updateLight(event : CharacterEvent) : Bool {
        // TODO use moon phase and weather (cloudy, raining) to determine light level.
        // If it is dark, set light level pitch

        switch (event) {
            case CharacterEvent.Midnight:
                return location.setLightLevel(LightLevel.Pitch);
            case CharacterEvent.Internacht:
                return location.setLightLevel(LightLevel.Dark);
            case CharacterEvent.Sunup:
                return location.setLightLevel(LightLevel.Shady);
            case CharacterEvent.Morning:
                return location.setLightLevel(LightLevel.Bright);
            case CharacterEvent.Noon:
                return location.setLightLevel(LightLevel.Bright);
            case CharacterEvent.Afternoon:
                return location.setLightLevel(LightLevel.Shady);
            case CharacterEvent.Sundown:
                return location.setLightLevel(LightLevel.Dusk);
            case CharacterEvent.Evening:
                return location.setLightLevel(LightLevel.Dark);
            default:
                // Non-time event.
                return false;
        }
    }

    function refreshLight() {
        var dayTick = time.dayTick;
        var timeEvent = getTimeEvent(dayTick);
        if (timeEvent != lastTimeEvent) {
            manager.dispatchEvent(timeEvent);
            updateLight(timeEvent);
        }
        lastTimeEvent = timeEvent;
        trace('Tick: ${dayTick}, ${timeEvent}');
    }

    function tickTurn() {
        time.advance();
        refreshLight();

        // Tick any effects.
        mainCharacter.tick(time, data.history);
        location.tickAll(time);
    }

    function actionUse(direction : PinnacleDirection) : ActionResult {
        var coord = getDirectionCoord(direction);

        if (mainConfig.phase) {
            addHistory('You are phased');
            return ActionResult.Stay;
        }
        // Then we have to see what is there
        var object = location.objectAt(coord.x, coord.y, coord.z);

        switch (object) {
            case LocationObject.Character:
                var character = location.getCharacterAt(coord.x, coord.y, coord.z);
                if (character != null) {
                    if (mainConfig.combat) {
                        addHistory('Attacking ${character.config.name}');
                        character.defendVs(mainCharacter, data.history);
                        return ActionResult.Move;
                    } else if (mainConfig.roguery) {
                        addHistory('Pickpocketing ${character.config.name}');
                        return ActionResult.Move;
                    } else {
                        addHistory('Talking to ${character.config.name}');
                        character.addEvent(CharacterEvent.Conversation);
                        dialog.setCharacter(character);
                        return ActionResult.Move;
                    }
                } else {
                    addHistory('No one there');
                    return ActionResult.Stay;
                }
            case LocationObject.Corpse:
                addHistory('Searching corpse');
            case LocationObject.Wall:
                addHistory('You see a wall');
            case LocationObject.Door:
                var doorType = location.isDoor(coord.x, coord.y, coord.z);
                switch (doorType) {
                    case DoorType.Open:
                        var used = location.useDoor(coord.x, coord.y, coord.z);
                        if (used == DoorType.Closed) {
                            addHistory('Closed door');
                            return ActionResult.Move;
                        } 
                        trace("This door should be open");
                        return ActionResult.Stay;
                    case DoorType.Closed:
                        var used = location.useDoor(coord.x, coord.y, coord.z);
                        if (used == DoorType.Open) {
                            addHistory('Opened door');
                            return ActionResult.Move;
                        } 
                        trace("This door should be open");
                        return ActionResult.Stay;
                    case DoorType.Locked:
                        if (mainConfig.roguery) {
                            addHistory('Picking lock');
                            var unlocked = location.unlockDoor(coord.x, coord.y, coord.z);
                            return ActionResult.Move;
                        }
                        addHistory('Door is locked');
                        return ActionResult.Stay;
                    case DoorType.Sealed:
                        addHistory('Door is sealed');
                        return ActionResult.Stay;
                    default:
                        addHistory('No door there');
                        return ActionResult.Stay;
                }
            case LocationObject.Interactable:
                addHistory('Used');
            case LocationObject.InteractableWall:
                addHistory('Used');
            case LocationObject.Traversable:
                addHistory('Try (F)ording it');
            case LocationObject.Transit:
                addHistory('You can (G)o there');
            case LocationObject.Special:
                addHistory('Used');
            case LocationObject.Trigger:
                if (mainConfig.roguery)
                    addHistory('Disarming trap');
                else
                    addHistory('You see a trap');
            case LocationObject.Void:
                addHistory('The void is unresponsive');
            case LocationObject.Nothing:
                addHistory('Nothing to use');
            default:
                trace('Unknown object ${object}');
                return ActionResult.Stay;
        }

        return ActionResult.Stay;
    }

    function handleAction(direction : PinnacleDirection) : ActionResult {
        var action = mainConfig.action;
        switch (action) {
            case PinnacleAction.Move:
                return actionMove(direction);
            case PinnacleAction.Use:
                return actionUse(direction);
            case PinnacleAction.Ford:
                return actionFord(direction);
            default:
                trace('No handler for $action, $direction');
                return ActionResult.Stay;
        }
    }

    function setMode(mode : CharMode) {
        switch (mode) {
            case CharMode.Active:
                mainConfig.stance = Stance.Standing;
                mainConfig.sleeping = false;
            case CharMode.Sit:
                mainConfig.stance = Stance.Sitting;
            case CharMode.Sleep:
                mainConfig.sleeping = true;
                mainConfig.stance = Stance.Laying;
            case CharMode.Stun:
                mainConfig.stun = 1;
            case CharMode.Knockout:
                mainConfig.down = true;
            case CharMode.Dead:
                mainConfig.down = true;
                mainConfig.dead = true;
            case CharMode.Roguery:
                if (!mainConfig.roguery) {
                    mainConfig.roguery = true;
                    mainConfig.stance = Stance.Crouched;
                    mainConfig.viewRadius = rogueVision;
                    addHistory("Sneaking");
                } else {
                    mainConfig.roguery = false;
                    mainConfig.stance = Stance.Standing;
                    mainConfig.viewRadius = defaultVision;
                    addHistory("Playing it cool");
                }
                viewFilters.rogue.enable = mainConfig.roguery;
            case CharMode.Battle:
                if (mainConfig.combat) {
                    mainConfig.combat = false;
                    addHistory("Leaving combat");
                } else {
                    mainConfig.combat = true;
                    addHistory("Drawing weapons");
                }
                viewFilters.battle.enable = mainConfig.combat;
            case CharMode.Caster:
                if (mainConfig.caster) {
                    mainConfig.caster = false;
                    addHistory("Source linked");
                } else {
                    mainConfig.caster = true;
                    addHistory("Unlinked source");
                }
                viewFilters.magic.enable = mainConfig.caster;
            case CharMode.Phase:
                if (mainConfig.phase) {
                    mainConfig.phase = false;
                    mainConfig.trueSight = null;
                    addHistory("Realigned");
                } else {
                    mainConfig.phase = true;
                    mainConfig.trueSight = 15;
                    addHistory("Desynchronized");
                }
                viewFilters.phased.enable = mainConfig.phase;
            case CharMode.Fly:
                mainConfig.fly = true;
            default:
                trace('No handler for $mode');
        }
    }

    function setAction(action : PinnacleAction) {
        mainConfig.action = action;
    }

    function addHistory(message : String) {
        data.history.message(message);
    }

    private function handleInput() {
        var moved = false;
        if (dialog.inDialog) {
            if (Key.isPressed(FixKey.SPACE)) {
                dialog.closeDialog();
            } else {
                dialog.handleKeyboardInput();
            }
            return;
        } else if (Key.isPressed(FixKey.SPACE)) {
            setAction(PinnacleAction.Move);
            addHistory('Waiting');
            moved = true;
        } else if (Key.isPressed(FixKey.LEFT) || Key.isPressed(FixKey.A)) {
            var result = handleAction(PinnacleDirection.West);
            if (result == ActionResult.Move) moved = true;
            setAction(PinnacleAction.Move);
        } else if (Key.isPressed(FixKey.RIGHT) || Key.isPressed(FixKey.D)) {
            var result = handleAction(PinnacleDirection.East);
            if (result == ActionResult.Move) moved = true;
            setAction(PinnacleAction.Move);
        } else if (Key.isPressed(FixKey.UP) || Key.isPressed(FixKey.W)) {
            var result = handleAction(PinnacleDirection.North);
            if (result == ActionResult.Move) moved = true;
            setAction(PinnacleAction.Move);
        } else if (Key.isPressed(FixKey.DOWN) || Key.isPressed(FixKey.X)) {
            var result = handleAction(PinnacleDirection.South);
            if (result == ActionResult.Move) moved = true;
            setAction(PinnacleAction.Move);
        } else if (Key.isPressed(FixKey.Q)) {
            var result = handleAction(PinnacleDirection.NorthWest);
            if (result == ActionResult.Move) moved = true;
            setAction(PinnacleAction.Move);
        } else if (Key.isPressed(FixKey.E)) {
            var result = handleAction(PinnacleDirection.NorthEast);
            if (result == ActionResult.Move) moved = true;
            setAction(PinnacleAction.Move);
        } else if (Key.isPressed(FixKey.Z)) {
            var result = handleAction(PinnacleDirection.SouthWest);
            if (result == ActionResult.Move) moved = true;
            setAction(PinnacleAction.Move);
        } else if (Key.isPressed(FixKey.C)) {
            var result = handleAction(PinnacleDirection.SouthEast);
            if (result == ActionResult.Move) moved = true;
            setAction(PinnacleAction.Move);
        } else if (Key.isPressed(FixKey.G)) {
            // This is where we Go (Transit)
            var result = location.isStairs(mainConfig.x, mainConfig.y, mainConfig.z);
            if (result != null) {
                moveTo(mainConfig.x, mainConfig.y, result);
                moved = true;
            } else {
                // TODO location.isPortal, which accounts for portals, entrances, exits, etc.
                setAction(PinnacleAction.Wait);
            }
        } else if (Key.isPressed(FixKey.F)) {
            // We will Ford (Swim) if we can
            setAction(PinnacleAction.Ford);
        } else if (Key.isPressed(FixKey.S) || Key.isPressed(FixKey.U)) {
            // This is where we handle directional use actions
            // Use, Talk, Search, Attack, Rob
            setAction(PinnacleAction.Use);
            addHistory("Direction?");
        } else if (Key.isPressed(FixKey.N)) {
            setMode(CharMode.Roguery);
            moved = true;
        } else if (Key.isPressed(FixKey.B)) {
            setMode(CharMode.Battle);
            moved = true;
        } else if (Key.isPressed(FixKey.M)) {
            setMode(CharMode.Caster);
            moved = true;
        } else if (Key.isPressed(FixKey.V)) {
            setMode(CharMode.Phase);
            moved = true;
        } else if (Key.isPressed(FixKey.F1)) {
            System.exit();
        } 
        if (moved) {
            tickTurn();
            redrawCamera();
        }
    }

    static function main() {
        Res.initEmbed();
        new Pinnacle();
    }
}
