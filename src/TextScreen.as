package {

import flash.geom.Point;
import flash.geom.Rectangle;
import flash.geom.ColorTransform;
import flash.display.Bitmap;
import flash.display.BitmapData;

//  TextScreen
//
public class TextScreen extends Bitmap
{
  public const BLANK:int = 32;
  public const COLOR:Array = [ 0x000000, 0x0000ff, 0xff0000, 0xff00ff, 
			       0x00ff00, 0x00ffff, 0xffff00, 0xffffff ];
  
  private var _fontimage:BitmapData;
  private var _textwidth:int;
  private var _textheight:int;
  private var _charwidth:int;
  private var _charheight:int;
  private var _char:Array;
  private var _attr:Array;
  
  public function TextScreen(textwidth:int, textheight:int, 
			     charwidth:int, charheight:int, 
			     fontimage:BitmapData)
  {
    _textwidth = textwidth;
    _textheight = textheight;
    _charwidth = charwidth;
    _charheight = charheight;
    _fontimage = fontimage;
    _char = new Array(textheight);
    _attr = new Array(textheight);
    for (var y:int = 0; y < textheight; y++) {
      _char[y] = new Array(textwidth);
      _attr[y] = new Array(textwidth);
    }
    bitmapData = new BitmapData(textwidth*charwidth, 
				textheight*charheight,
				false);
  }

  public function get textwidth():int
  {
    return _textwidth;
  }
  public function get textheight():int
  {
    return _textheight;
  }

  public function putchar(x:int, y:int, char:int, attr:int=0):void
  {
    if (x < 0 || y < 0 || _textwidth <= x || _textheight <= y) return;
    var src:Rectangle = new Rectangle(char*_charwidth, 0, _charwidth, _charheight);
    var dst:Rectangle = new Rectangle(x*_charwidth, y*_charheight, _charwidth, _charheight);
    var ct:ColorTransform = new ColorTransform();
    ct.color = COLOR[attr & 7];
    _fontimage.colorTransform(src, ct);
    bitmapData.fillRect(dst, COLOR[attr >> 3]);
    bitmapData.copyPixels(_fontimage, src, dst.topLeft);
    _char[y][x] = char;
    _attr[y][x] = attr;
  }

  public function getchar(x:int, y:int):int
  {
    if (x < 0 || y < 0 || _textwidth <= x || _textheight <= y) return -1;
    return _char[y][x];
  }

  public function print(x:int, y:int, s:String, attr:int=0):void
  {
    for (var i:int = 0; i < s.length; i++) {
      putchar(x+i, y, s.charCodeAt(i), attr);
    }
  }

  public function fill(x:int=0, y:int=0, w:int=-1, h:int=-1, 
		       char:int=BLANK, attr:int=0):void
  {
    if (w < 0) { w = _textwidth; }
    if (h < 0) { h = _textheight; }
    for (var dy:int = 0; dy < h; dy++) {
      for (var dx:int = 0; dx < w; dx++) {
	putchar(x+dx, y+dy, char, attr);
      }
    }
  }

  public function refresh(x:int=0, y:int=0, w:int=-1, h:int=-1):void
  {
    if (w < 0) { w = _textwidth; }
    if (h < 0) { h = _textheight; }
    for (var dy:int = 0; dy < h; dy++) {
      var c:Array = _char[y+dy];
      var a:Array = _attr[y+dy];
      for (var dx:int = 0; dx < w; dx++) {
	putchar(x+dx, y+dy, c[x+dx], a[x+dx]);
      }
    }
  }

  public function scroll(dx:int, dy:int, 
			 char:int=BLANK, attr:int=0):void
  {
    //bitmapData.scroll(dx*_charwidth, dy*_charheight);

    var x0:int = (dx < 0)? 0 : (_textwidth-1);
    var x1:int = (dx < 0)? _textwidth : -1;
    var vx:int = (dx < 0)? +1 : -1;
    var y0:int = (dy < 0)? 0 : (_textheight-1);
    var y1:int = (dy < 0)? _textheight : -1;
    var vy:int = (dy < 0)? +1 : -1;

    for (var y:int = y0; y != y1; y += vy) {
      var c1:Array = _char[y];
      var a1:Array = _attr[y];
      var c0:Array = _char[y-dy];
      var a0:Array = _attr[y-dy];
      for (var x:int = x0; x != x1; x += vx) {
	if ((y-dy) < 0 || _textheight <= (y-dy) ||
	    (x-dx) < 0 || _textwidth <= (x-dx)) {
	  c1[x] = char;
	  a1[x] = attr;
	} else {
	  c1[x] = c0[x-dx];
	  a1[x] = a0[x-dx];
	}
      }
    }
    refresh();
  }

}

}
