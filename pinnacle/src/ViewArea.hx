package;

import h2d.TileGroup;
import h2d.Tile;
import h2d.Object;
import Config;
import Location;
import LdtkProject;


class ViewArea extends Object {
    private var visibleTiles : TileGroup;
    private var location : Location;
    private var windowConfig : WindowConfig;
    private var mainCharConfig : CharConfig;
    private var tileSet : Tileset_Ultima_5;

    var FLOOR_TILE = 68;

    public function new(
        tileSet: Tileset_Ultima_5, location: Location,
        windowConfig: WindowConfig, mainCharConfig: CharConfig, ?parent: Object) {
        super(parent);
        this.tileSet = tileSet;
        this.location = location;
        this.windowConfig = windowConfig;
        this.mainCharConfig = mainCharConfig;
        visibleTiles = new TileGroup(tileSet.getAtlasTile(), this);
    }

    function collectVisibleTile(x : Int, y : Int, z : Int, e : Int) {
        var alpha = ((e + 1) / 5);
        if (alpha > 1) alpha = 1.0;

        var tileId = location.getTileId(x, y, z);
        var myTile = tileSet.getTile(tileId);
        if (myTile != null) {
            visibleTiles.addAlpha(
                x * windowConfig.gridSize + windowConfig.offsetX,
                y * windowConfig.gridSize + windowConfig.offsetY,
                alpha,
                myTile
            );
        }

        // TODO Interactives can provide their own light!
        location.showInteractiveAt(x, y, z, alpha);
    }

    public function viewFrom(x : Int, y : Int, z : Int) : Bool  {
        visibleTiles.clear(); 
        location.hideAllInteractives();

        var points = location.viewFrom(x, y, z, mainCharConfig.viewRadius, true, mainCharConfig.selfLight, mainCharConfig.trueSight);

        // Now we collect the visible tiles
        var tileCount = 0;
        for (p in points) {
            collectVisibleTile(p.x, p.y, z, p.l);
            tileCount++;
        }
    
        return true;
    }

}