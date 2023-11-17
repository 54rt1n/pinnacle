// src/DataOverlay.hx
package;

import h2d.Object;
import h2d.Tile;
import h2d.Font;
import h2d.Flow;
import Config;
import Party;

class DataOverlay extends Object {
    private var party : Party;
    private var font : Font;
    private var windowConfig : WindowConfig;
    private var uiPanel : Flow;
    private var topPanel : Flow;
    private var bottomPanel : Flow;
    public var history : History;

    public function new(windowConfig : WindowConfig, party : Party, ?parent : Object) {
        super(parent);
        this.party = party;
        this.windowConfig = windowConfig;
        font = hxd.res.DefaultFont.get();

        uiPanel = new Flow(this);
        uiPanel.debug = true;
        uiPanel.verticalAlign = FlowAlign.Middle;
        uiPanel.horizontalAlign = FlowAlign.Middle;
        uiPanel.horizontalSpacing = 16;
        uiPanel.verticalSpacing = 16;
        uiPanel.padding = 8;
		uiPanel.backgroundTile = Tile.fromColor(0x333333);
        uiPanel.layout = FlowLayout.Vertical;
        uiPanel.verticalAlign = FlowAlign.Top;

        var uiWidth = uiPanel.outerWidth;

        topPanel = new h2d.Flow(uiPanel);
        topPanel.layout = FlowLayout.Vertical;
        topPanel.verticalAlign = FlowAlign.Top;
        topPanel.verticalSpacing = 8;
        topPanel.minHeight = 64;
        topPanel.minWidth = uiWidth - 16;

        var statusRow = new h2d.Flow();
        statusRow.fillWidth = true;
        statusRow.layout = FlowLayout.Horizontal;
        statusRow.horizontalAlign = FlowAlign.Left;

        var statusGold = new h2d.Text(font, statusRow);
        statusGold.textColor = 0xff0000;
        statusGold.textAlign = Left;
        statusGold.text = 'Gold: ${party.gold}';

        var statusFood = new h2d.Text(font, statusRow);
        statusFood.textColor = 0xff0000;
        statusFood.textAlign = Right;
        statusFood.text = 'Food: ${party.food}';

        statusRow.horizontalSpacing = Math.ceil(uiPanel.innerWidth - (statusGold.textWidth + statusFood.textWidth));

        uiPanel.addChild(statusRow);

        bottomPanel = new h2d.Flow(uiPanel);
        bottomPanel.layout = FlowLayout.Vertical;
        bottomPanel.verticalAlign = FlowAlign.Top;
        bottomPanel.horizontalAlign = FlowAlign.Left;
        bottomPanel.minWidth = uiWidth - 16;
        bottomPanel.verticalSpacing = 8;

        history = new History(bottomPanel, 25);

        var tx = new h2d.Text(font, bottomPanel);
        tx.textColor = 0xff0000;
		tx.textAlign = Left;
        tx.text = 'History';

        resizeTo();

        trace('minWidth ${uiPanel.minWidth} minHeight ${uiPanel.minHeight}');
    }

    function updateCharacters() {
        topPanel.removeChildren();

        for (charConfig in party.members) {
            var charRow = new h2d.Flow();
            charRow.fillWidth = true;
            charRow.layout = FlowLayout.Horizontal;

            var charName = new h2d.Text(font, charRow);
            charName.textColor = 0xff0000;
            charName.textAlign = Left;
            charName.text = '${charConfig.name}';

            var charHealth = new h2d.Text(font, charRow);
            charHealth.textColor = 0xff0000;
            charHealth.textAlign = Right;
            charHealth.text = '${charConfig.health}';

            charRow.horizontalSpacing = Math.ceil(uiPanel.innerWidth - (charHealth.textWidth + charName.textWidth));

            topPanel.addChild(charRow);
        }
    }
    
    public function refresh() {
        updateCharacters();
    }

    function resizeTo() {
        var stage = hxd.Window.getInstance();
        var screenWidth = stage.width;
        var screenHeight = stage.height;
        var width : Int;
        var height = screenHeight;

        if (screenWidth >= 1024) {
            width = 384;
        } else if (screenWidth >= 768) {
            width = 256;
        } else if (screenWidth >= 512) {
            width = 192;
        } else {
            width = 96;
        }
        
        var scale = windowConfig.scale;
        uiPanel.minWidth = width;
        uiPanel.minHeight = height;
        var dialogX = (screenWidth - uiPanel.outerWidth);
        var dialogY = 0;
        uiPanel.x = Math.ceil(dialogX);
        uiPanel.y = Math.ceil(dialogY);
        topPanel.minWidth = uiPanel.innerWidth;
        bottomPanel.minWidth = uiPanel.innerWidth;
        history.fixLength(bottomPanel.innerHeight);
        trace('DataOverlay $width x $height, $screenWidth x $screenHeight, $dialogX x $dialogY');
        updateCharacters();
    }

    public function onResize () {
        resizeTo();
    }
}