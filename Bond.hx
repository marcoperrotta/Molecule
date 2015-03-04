package;

import flash.display.DisplayObjectContainer;
import flash.events.MouseEvent;
import openfl.display.*;
import openfl.events.*;
import openfl.geom.Vector3D;
import openfl.utils.*;
import openfl.text.TextField;

import away3d.containers.*;
import away3d.core.base.*;
import away3d.entities.*;
import away3d.materials.*;
import away3d.primitives.*;
import away3d.tools.helpers.*;
import away3d.utils.*;


/**
 * ...
 * @author Marco
 */
class Bond extends ObjectContainer3D
{

	public override function new() 
	{
		super();
		
		var geometry = new CylinderGeometry(2, 2, 200, true, true, true, false);
		var color = new ColorMaterial(0xaabb00);
		
		var x = new Mesh(geometry, color);
		x.moveRight(5);
		this.addChild(x);
		
		var y = new Mesh(geometry, color);
		y.moveLeft(5);
		this.addChild(y);
	}
}