// src/DialogOverlay.hx
package;

import h2d.Flow;
import h2d.Tile;
import h2d.Object;
import h2d.Bitmap;
import h2d.Text;
import h2d.BlendMode;
import hxd.BitmapData;
import hxd.Key;
import Config;
import Character;

enum KeywordStatus {
    Unknown;
    Known;
    Learned;
}

class DialogOverlay extends Object {
    private var dialogPanel : Flow;
    private var character : Character;
    private var mainConfig : CharConfig;
    private var portrait : h2d.Bitmap;
    private var conversation : Flow;
    private var windowConfig : WindowConfig;
    public var inDialog : Bool = false;
    private var playerInput : String = "";
    private var keywords : Map<String, KeywordStatus> = new Map<String, KeywordStatus>();
    private var turns : Array<{charId: String, dialogue : String}> = new Array<{charId: String, dialogue : String}>();
    private var input : Text;
    private var font = hxd.res.DefaultFont.get();

    public function new (windowConfig : WindowConfig, mainConfig : CharConfig, ?parent : Object) {
        super(parent);
        this.windowConfig = windowConfig;
        dialogPanel = new Flow(this);
        dialogPanel.debug = true;
        dialogPanel.backgroundTile = Tile.fromColor(0x333333);
        visible = false;
        this.mainConfig = mainConfig;
        onResize();
        // dialogPanel.background = [new Border(3, 0xFFFFFF, BorderStyle.Solid)];
        //dialogPanel.x = (screenWidth - dialogPanel.) / 2;
        //dialogPanel.y = screenHeight - dialogPanel.height;
        //hxd.System.onResize.add(updatePosition);
    }

    function resizeTo() {
        var stage = hxd.Window.getInstance();
        var screenWidth = stage.width;
        var screenHeight = stage.height;
        var width : Int;
        var height : Int;

        if (screenWidth >= 1024) {
            width = 1024;
        } else if (screenWidth >= 768) {
            width = 768;
        } else if (screenWidth >= 512) {
            width = 512;
        } else if (screenWidth >= 384) {
            width = 384;
        } else {
            width = 256;
        }
        
        if (screenHeight >= 1024) {
            height = 768;
        } else if (screenHeight >= 768) {
            height = 512;
        } else if (screenHeight >= 512) {
            height = 384;
        } else {
            height = 256;
        }

        var scale = windowConfig.scale;
        var dialogX = (screenWidth - width) / 2;
        var dialogY = (screenHeight - height) - 8;
        dialogPanel.minWidth = width;
        dialogPanel.minHeight = height;
        dialogPanel.x = Math.ceil(dialogX);
        dialogPanel.y = Math.ceil(dialogY);
        trace('DialogOverlay $width x $height, $screenWidth x $screenHeight, $dialogX x $dialogY');
    }

    public function onResize () {
        resizeTo();
    }

    public function setCharacter(target : Character) {
        character = target;
        var image = hxd.Res.loader.load('portrait/${target.config.portrait}.png');
        var data = image?.toImage();
        if (data != null) {
            var bitmapData = data.toBitmap();
            var scaledData = new hxd.BitmapData(100, 100);
            scaledData.drawScaled(0, 0, 100, 100, bitmapData, 0, 0, bitmapData.width,
                 bitmapData.height, BlendMode.None, true);
            var tile = Tile.fromBitmap(scaledData);
            tile.setSize(100, 100);
            portrait = new h2d.Bitmap(tile);
            dialogPanel.addChild(portrait);
            var chatPanel = new Flow(dialogPanel);
            chatPanel.debug = true;
            chatPanel.horizontalAlign = FlowAlign.Middle;
            chatPanel.verticalAlign = FlowAlign.Bottom;
            chatPanel.layout = FlowLayout.Vertical;
            conversation = new Flow(chatPanel);
            conversation.debug = true;
            conversation.horizontalAlign = FlowAlign.Middle;
            conversation.verticalAlign = FlowAlign.Bottom;
            conversation.layout = FlowLayout.Vertical;
            input = new Text(font, chatPanel);
            input.text = "> ";
            input.textColor = 0xCCCCCC;

            turns = new Array<{charId: String, dialogue : String}>();


            turns.push({charId: character.config.charId, dialogue: 'Hello there.'});
            inDialog = true;
            visible = true;
            keywords.clear();
            for (keyword in character.getKeywords()) {
                keywords.set(keyword, KeywordStatus.Known);
            }
            reTurn();
        } else {
            trace("Failed to load portrait");
        }
    }

    public function reTurn() {
        conversation.removeChildren();
        for (turn in turns) {
            var text = new h2d.Text(font, conversation);
            text.text = turn.dialogue;
            text.textColor = 0xFFFFFF;
        }
    }

    public function handleKeyboardInput() {
        if (character == null) {
            return;
        }
        else if (Key.isPressed(13)) {
            if (playerInput != "") {
                var keywordStatus = keywords.get(playerInput);
                turns.push({charId: mainConfig.charId, dialogue: playerInput});
                if (keywordStatus == null) {
                    turns.push({charId: character.config.charId, dialogue: 'I don\'t know anything about that...'});
                } else if (keywordStatus == KeywordStatus.Unknown) {
                    turns.push({charId: character.config.charId, dialogue: 'Huh?'});
                } else if (keywordStatus == KeywordStatus.Known) {
                    turns.push({charId: character.config.charId, dialogue: 'I know about that!'});
                    keywords.set(playerInput, KeywordStatus.Learned);
                } else if (keywordStatus == KeywordStatus.Learned) {
                    turns.push({charId: character.config.charId, dialogue: 'You know about that!'});
                }
                playerInput = "";
                input.text = "> ";
                reTurn();
            }
        } else {
            for (keyId in 65...91) {
                if (Key.isPressed(keyId)) {
                    playerInput += Key.getKeyName(keyId);
                    input.text = '> $playerInput';
                    break;
                }
            }
        }
    }

    public function closeDialog () {
        character = null;
        inDialog = false;
        visible = false;
        dialogPanel.removeChildren();
        keywords.clear();
    }
}