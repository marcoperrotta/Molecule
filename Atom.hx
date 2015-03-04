package;

import openfl.display.*;
import openfl.events.*;
import openfl.geom.*;
import openfl.utils.*;
import openfl.text.*;

import away3d.containers.*;
import away3d.core.base.*;
import away3d.entities.*;
import away3d.events.*;
import away3d.materials.*;
import away3d.primitives.*;
import away3d.tools.helpers.*;
import away3d.utils.*;


class Atom extends Mesh
{
	//var sphereMaterial:ColorMaterial;
	//var sphere:Mesh;
	//var sphereMaterial:TextureMultiPassMaterial;
	var color:UInt;
	var nameAtom:String;
	var messageField:TextField = new TextField();
	public override function new(raggio:Float, typeAtom:String) {
		switch (typeAtom) {
			case "O":
					color = 0xFF0000;
					nameAtom = "OXYGEN";
			case "H":
					color = 0x00FF00;
					nameAtom = "HYDROGEN";
			case "C":
					color = 0x0000FF;
					nameAtom = "CARBON";
			case "N":
					color = 0xFFF000;
					nameAtom = "NITROGEN";
			case "B":
					color = 0x123456;
					nameAtom = "BORON";
		}
			
		this.addEventListener(MouseEvent3D.MOUSE_OVER, overAtom);
		
		//sphereMaterial = new ColorMaterial(0xaa0000);
		/*
		sphereMaterial = new TextureMultiPassMaterial(Cast.bitmapTexture("embeds/rock.png"));
		sphereMaterial.repeat = true;
		sphereMaterial.mipmap = false;
		sphereMaterial.specular = 10;
		*/
		
		super(new SphereGeometry(raggio), new ColorMaterial(color));
	}
	
	private function overAtom(event:Event) {
		
	}

	
	/*
	public override function initObjects(){
		
	//sphere2 = new Mesh(new SphereGeometry(), sphereMaterial);
	
	
	public function Mesh(new SphereGeometry(), material:sphereMaterial) {
		super();
		
		sphereMaterial = new TextureMultiPassMaterial(Cast.bitmapTexture("embeds/rock.png"));
		sphereMaterial.repeat = true;
		sphereMaterial.mipmap = false;
		sphereMaterial.specular = 10;
		
		//sphere = new Mesh(new SphereGeometry(), sphereMaterial);
		//addChild(sphere2);
		
	}
	*/
}
