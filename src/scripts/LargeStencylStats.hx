package scripts;

import com.stencyl.Extension;

import openfl.Lib;
import openfl.display.Bitmap;
import openfl.display.BitmapData;
import openfl.display.Sprite;
import openfl.events.Event;
import openfl.geom.Matrix;
import openfl.system.System;
import openfl.text.TextField;
import openfl.text.TextFieldAutoSize;
import openfl.text.TextFormat;

class LargeStencylStats extends Extension
{
    private var root:Sprite;
    private var panelBitmap:Bitmap;
    private var panelData:BitmapData;
    private var drawText:TextField;

    private var frameCount:Int = 0;
    private var currentFPS:Int = 0;
    private var lastSampleTime:Int = 0;

    private var panelW:Int;
    private var panelH:Int;
    private var padding:Int;
    private var fontSize:Int;

    public function new()
    {
        super();
    }

    override public function initialize():Void
    {
        if(Lib.current.stage != null)
        {
            startMonitor();
        }
        else
        {
            Lib.current.addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
        }
    }

    private function onAddedToStage(e:Event):Void
    {
        Lib.current.removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
        startMonitor();
    }

    private function startMonitor():Void
    {
        if(root != null) return;
		
		#if(windows || html5 || cppia)
        panelW = Std.int(Lib.current.stage.stageWidth / 5);
        panelH = Std.int(Lib.current.stage.stageHeight / 5);
		padding = Std.int(panelH / 20);
        fontSize = Std.int(panelH / 7);
		#else
		panelW = Std.int(Lib.current.stage.stageWidth / 4);
        panelH = Std.int(Lib.current.stage.stageHeight / 4);
		padding = Std.int(panelH / 20);
        fontSize = Std.int(panelH / 5);
		#end
        root = new Sprite();
        root.mouseEnabled = false;
        root.mouseChildren = false;

        panelData = new BitmapData(panelW, panelH, true, 0xCC000000);
        panelBitmap = new Bitmap(panelData);
        root.addChild(panelBitmap);

        drawText = new TextField();
var format = new TextFormat("_sans", fontSize, 0xFFFFFF, true);

#if android
format.letterSpacing = fontSize * 0.08;
#end

drawText.defaultTextFormat = format;

        drawText.autoSize = TextFieldAutoSize.LEFT;
        drawText.selectable = false;
        drawText.multiline = true;
        drawText.wordWrap = false;

        Lib.current.stage.addChild(root);
        Lib.current.stage.addEventListener(Event.ENTER_FRAME, onEnterFrame);

        lastSampleTime = Lib.getTimer();

        positionTopRight();
        redraw();
    }

    private function onEnterFrame(e:Event):Void
    {
        frameCount++;

        var now:Int = Lib.getTimer();
        var elapsed:Int = now - lastSampleTime;

        if(elapsed >= 1000)
        {
            currentFPS = Math.round(frameCount * 1000 / elapsed);

            frameCount = 0;
            lastSampleTime = now;

            redraw();
        }

        positionTopRight();
    }

    private function redraw():Void
    {
        if(panelData == null) return;

        var memMB:Float = System.totalMemory / (1024 * 1024);

        var targetFPS:Int =
            Lib.current.stage != null
            ? Std.int(Math.round(Lib.current.stage.frameRate))
            : 0;

        if(targetFPS > 60) targetFPS = 60;
        if(currentFPS > 60) currentFPS = 60;
		
		
		#if android
		drawText.text =
				"FP S: " + currentFPS + " / " + targetFPS +
				"\nMEM: " + oneDecimal(memMB) + " MB";
		#else
        drawText.text =
            "FPS: " + currentFPS + " / " + targetFPS +
            "\nMEM: " + oneDecimal(memMB) + " MB";
		#end

        panelData.fillRect(panelData.rect, 0xCC000000);

        var matrix = new Matrix();
        matrix.translate(padding, padding);

        panelData.draw(drawText, matrix);
    }

    private function positionTopRight():Void
    {
        if(root == null || Lib.current.stage == null) return;

        root.x = Lib.current.stage.stageWidth - panelW;
        root.y = 0;
    }

    private function oneDecimal(v:Float):String
    {
        return Std.string(Math.round(v * 10) / 10);
    }
}