// src/History.hx
package;

import h2d.Text.Align;

class History {
    // Haxe singleton wrapper around our console output
    // we have a queue of messages to be printed
    // returning the last n messages

    private var textQueue : Array<h2d.Text>;
    private var maxConsoleLength : Int;
    private var consoleFlow : h2d.Flow;

    public function new (flow : h2d.Flow, max : Int) {
        maxConsoleLength = max;
        consoleFlow = flow;
        textQueue = new Array<h2d.Text>();
    }

    public function fixLength(height : Int) {
        maxConsoleLength = Math.ceil(height * 2);
    }

    public function message(msg : String) {
        var tx = new h2d.Text(hxd.res.DefaultFont.get(), consoleFlow);
        tx.textColor = 0xff0000;
        tx.textAlign = Left;
        tx.text = msg;
        textQueue.push(tx);
        if (textQueue.length > maxConsoleLength) {
            var old = textQueue.shift();
            consoleFlow.removeChild(old);
        }
    }
}