package {

import flash.display.Shape;
import flash.display.Sprite;
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.media.Sound;
import flash.media.SoundChannel;
import flash.text.TextField;
import flash.text.TextFormat;
import flash.events.Event;
import flash.ui.Keyboard;

//  GameScreen
//
public class GameScreen extends Screen
{
  public static const NAME:String = "GameScreen";
  
  // bitmap font:
  [Embed(source="../assets/pc8001font.png")]
  private static const N80FontImageCls:Class;
  private static const n80fontimage:Bitmap = new N80FontImageCls();
  // point sound
  [Embed(source="../assets/point.mp3")]
  private static const PointSoundCls:Class;
  private static const PointSound:Sound = new PointSoundCls();
  // die sound
  [Embed(source="../assets/die.mp3")]
  private static const DieSoundCls:Class;
  private static const DieSound:Sound = new DieSoundCls();

  private var _state:int;  // 0:title, 1:game, 2:ending
  private var _score:int;
  private var _px:int, _py:int;
  private var _vx:int, _vy:int;
  private var _screen:TextScreen;
  private var _caption:TextField;
  private var _raster:Shape;
  private var _channel:SoundChannel;
  private var _count:int;

  private const TITLE1:int = 6<<3 | 1;
  private const TITLE2:int = 6<<3 | 0;
  private const PLAYER:int = 6<<3 | 1;
  private const SNOW:int = 6<<3 | 7;
  private const FLAG:int = 6<<3 | 2;
  private const FENCE:int = 5<<3 | 1;

  public function GameScreen(width:int, height:int)
  {
    var format:TextFormat = new TextFormat();
    format.font = "Arial";
    format.size = 24;
    format.align = "center";
    format.italic = true;
    _caption = new TextField();
    _caption.defaultTextFormat = format;
    _caption.width = width;
    _caption.height = 56;
    _caption.y = height-_caption.height;
    _screen = new TextScreen(40, 25, 8, 8, n80fontimage.bitmapData);
    _screen.width = width;
    _screen.height = height;

    var mask:BitmapData = new BitmapData(1, 2, true, 0x0000000);
    mask.setPixel32(0, 0, 0xff000000);
    _raster = new Shape();
    _raster.graphics.beginBitmapFill(mask);
    _raster.graphics.drawRect(0, 0, width, height);
    _raster.graphics.endFill();
  }

  // open()
  public override function open():void
  {
    addChild(_screen);
    addChild(_raster);
    addChild(_caption);
    init_state(0);
  }

  // close()
  public override function close():void
  {
    removeChild(_caption);
    removeChild(_raster);
    removeChild(_screen);
  }

  private function init_state(state:int):void
  {
    _channel = null;
    switch (state) {
    case 0:
      _screen.fill(0, 0, -1, -1, _screen.BLANK, SNOW);
      _screen.print(3, 4, 
		    [
[0xe4,0x87,0x87,0xe5,0x20,0x87,0x20,0xe4,0xe7,0x20,0x87,0x87,0x87],
[0x87,0x20,0x20,0x87,0x20,0x87,0xe4,0xe7,0x20,0x20,0x20,0x87],
[0x87,0x20,0x20,0x20,0x20,0x87,0xe7,0x20,0x20,0x20,0x20,0x87],
[0xe6,0x87,0x87,0xe5,0x20,0x87,0xe5,0x20,0x20,0x20,0x20,0x87],
[0x20,0x20,0x20,0x87,0x20,0x87,0xe6,0xe5,0x20,0x20,0x20,0x87],
[0x87,0x20,0x20,0x87,0x20,0x87,0x20,0xe6,0xe5,0x20,0x20,0x87],
[0xe6,0x87,0x87,0xe7,0x20,0x87,0x20,0x20,0x87,0x20,0x87,0x87,0x87],
		     ], TITLE1);
      _screen.print(20, 10, [[0x47,0x61,0x6e,0x65,0x21]], TITLE1);
      _screen.print(10, 16, [[0xbd,0xb7,0xb0,0x20,0xb9,0xde,0xb0,0xd1]], TITLE2);
      _screen.print(10, 18, [[0xbd,0xcd,0xdf,0xb0,0xbd,0xb7,0xb0,0x20,0xa6,0x20,
			      0xb5,0xbc,0xc3,0xb8,0xc0,0xde,0xbb,0xb2]], TITLE2);
      _screen.print(10, 24, [[0x31,0x39,0x38,0x33,0x20,0x59,0x75,0x73,0x75,0x6b,0x65,0x20,0x53,0x68,0x69,0x6e,0x79,0x61,0x6d,0x61,0x20,0x4d,0x69,0x6e,0x69,0x4c,0x44,0x20,0x34,0x37]], TITLE2);
      _caption.textColor = 0x0000ff;
      _caption.text = "Ski Game. Press Space Key.";
      break;

    case 1:
      _px = 20; _py = 5;
      _vx = 0; _vy = 0;
      _score = 0;
      _caption.textColor = 0x000000;
      _caption.text = "";
      _screen.fill(0,0,-1,-1,_screen.BLANK,SNOW);
      break;

    case 2:
      _screen.fill();
      _screen.print(10, 10, [[0xb9,0xde,0xb0,0xd1,0x20,0xb5,0xb0,0xca,0xde,0xb0]], 4);
      _screen.print(10, 12, [[0xbd,0xba,0xb1,0x3a,0x20,
			      0x30+Math.floor(_score/10),0x30+(_score%10),
			      0x20,0xc3,0xdd]], 4);
      _screen.print(0, 13, [[0x4f, 0x6b, 0x2e]], 7);
      _caption.textColor = 0x00ff00;
      _caption.text = "Game over. Score is "+_score+" pts.";
      _px = 0; _py = 14; 
      _count = 0;
      break;
    }
    _state = state;
  }

  // update()
  public override function update():void
  {
    switch (_state) {
    case 1:
      if (_channel == null) {
	update_game();
      }
      break;
      
    case 2:
      update_prompt();
      break;
    }
  }

  private function soundComplete1(e:Event):void
  {
    _channel = null;
  }
  private function soundComplete2(e:Event):void
  {
    _channel = null;
    init_state(2);
  }

  private function update_prompt():void
  {
    _count++;
    _screen.putchar(_px, _py, ((_count % 10) < 5)? 0x87 : 0x20, 7);
  }

  private function update_game():void
  {
    _screen.scroll(0, -1, _screen.BLANK, SNOW);
    
    var x:int, c:int;

    c = _screen.getchar(_px+1, _py+3);
    if (c == 0x50) {
      _channel = PointSound.play();
      _channel.addEventListener(Event.SOUND_COMPLETE, soundComplete1);
      _score++;
    } else if (c != _screen.BLANK) {
      _channel = DieSound.play();
      _channel.addEventListener(Event.SOUND_COMPLETE, soundComplete2);
      return;
    }

    _screen.print(1, 0, [[0x53,0x43,0x4f,0x52,0x45,0x3a,0x20,
			  0x30+(_score/10),0x30+(_score%10)]], SNOW);

    if (Math.random() < 0.1) {
      x = Math.floor(Math.random()*_screen.textwidth);
      _screen.print(x, _screen.textheight-1, [[0x50]], FLAG);
    }

    if (Math.random() < 0.3) {
      x = Math.floor(Math.random()*(_screen.textwidth-3));
      _screen.print(x, _screen.textheight-1, [[0xe2, 0xe2, 0xe2]], FENCE);
    }

    if (Math.random() < 0.5) {
      x = Math.floor(Math.random()*_screen.textwidth);
      c = Math.floor(Math.random()*256);
      _screen.putchar(x, _screen.textheight-1, c, SNOW);
    }

    _px += _vx; _px = Math.min(Math.max(0, _px), _screen.textwidth-3);
    _py += _vy; _py = Math.min(Math.max(0, _py), _screen.textheight-4);
    _screen.print(_px, _py, 
		  [[0x7c, 0x20, 0x7c], [0x20, 0xed, 0x20], [0xee, 0x87, 0xef], [0xee, 0x20, 0xef]],
		  PLAYER);
  }

  // keydown(keycode)
  public override function keydown(keycode:int):void
  {
    if (_state == 2 && keycode != Keyboard.ENTER) {
      _screen.putchar(_px, _py, keycode, 7);
      _px++;
      return;
    }

    switch (keycode) {
    case Keyboard.LEFT:
    case 65:			// A
    case 72:			// H
      _vx = -1; _vy = 0;
      break;

    case Keyboard.RIGHT:
    case 68:			// D
    case 76:			// L
      _vx = +1; _vy = 0;
      break;

    case Keyboard.UP:
    case 87:			// W
    case 75:			// K
      _vx = 0; _vy = -1;
      break;

    case Keyboard.DOWN:
    case 83:			// S
    case 74:			// J
      _vx = 0; _vy = +1;
      break;

    case Keyboard.SPACE:
    case Keyboard.ENTER:
    case 88:			// X
    case 90:			// Z
      switch (_state) {
      case 0:
	init_state(1);
	break;
      case 2:
	init_state(0);
	break;
      }
      break;

    }
  }

  // keyup(keycode)
  public override function keyup(keycode:int):void 
  {
    if (_state == 2) return;

    switch (keycode) {
    case Keyboard.LEFT:
    case Keyboard.RIGHT:
    case 65:			// A
    case 68:			// D
    case 72:			// H
    case 76:			// L
      _vx = 0;
      break;

    case Keyboard.UP:
    case Keyboard.DOWN:
    case 87:			// W
    case 75:			// K
    case 83:			// S
    case 74:			// J
      _vy = 0;
      break;
    }
  }
}

} // package
