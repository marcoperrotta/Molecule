package;

//import flash.display.Bitmap;
import flash.display.LineScaleMode;
import flash.display.Sprite;
import flash.display3D.textures.TextureBase;
import flash.events.MouseEvent;
import flash.events.KeyboardEvent;
import flash.events.Event;
import flash.geom.Matrix;
import flash.net.URLRequest;
//import flash.media.AVSegmentedSource;
import flash.Vector;
import haxe.io.BufferInput;
import haxe.io.Path;
import haxe.zip.Reader;
import openfl.display.*;
import openfl.display.Bitmap;
import openfl.events.*;
import openfl.geom.*;
import openfl.utils.*;
import openfl.text.TextField;
import openfl.geom.Vector3D;
import Math;
import sys.FileSystem;
import sys.io.*;
import Std;

import away3d.core.math.*;
import away3d.core.base.*;
import away3d.animators.*;
import away3d.animators.data.*;
import away3d.animators.nodes.*;
import away3d.cameras.*;
import away3d.containers.*;
import away3d.controllers.*;
import away3d.entities.*;
import away3d.events.*;
import away3d.lights.*;
import away3d.loaders.*;
import away3d.materials.*;
import away3d.materials.lightpickers.*;
import away3d.primitives.*;
import away3d.tools.helpers.*;
import away3d.utils.*;


import systools.Dialogs;

import haxe.ui.toolkit.controls.Button;

import extension.nativedialog.NativeDialog;



class Molecola extends Sprite
{
	
	//engine variables
	var scene:Scene3D;
	var camera:Camera3D;
	var view:View3D;
	var cameraController:HoverController;
			
	//material objects
	var particleMaterial:TextureMaterial;
	var sphereMaterial:ColorMaterial;
	
	//light objects
	var directionalLight:DirectionalLight;
	var lightPicker:StaticLightPicker;
	
	//particle objects
	var fireAnimationSet:ParticleAnimationSet;
	var particleGeometry:ParticleGeometry;
	var timer:Timer;
	
	//navigation variables
	var move:Bool = false;
	var lastPanAngle:Float;
	var lastTiltAngle:Float;
	var lastMouseX:Float;
	var lastMouseY:Float;
	var lastDistance:Float;
	
	//sphere
	var sphere:Mesh;
	var sphere2:Atom;
	var atom = [];
	var somma_vect:Vector3D;
	var central_point:Mesh = new Mesh(new SphereGeometry(2), new ColorMaterial(0x0F0F0F));
	//var bondtest:Bond;
	var cyl:Mesh;
	var id:Array<Atom> = [];
	
	var roll:Bool;
	
	var text:TextField;
	
	var messageField:TextField = new TextField();
	var open:TextField = new TextField();
	
	var typeAtom:String;
	var nameAtom:String;

	var wall:Sprite;
	
	var openButton:Sprite = new Sprite();
	var clearButton:Sprite = new Sprite();
	
	var number_atom:Int;
	var number_bond:Int;
	//[Embed(source="/.../embeds/wall2.jpg")]
	//private var wall:Class;
	
	var bond2 = new Loader3D();


	
	
	/**
	 * Constructor
	 */
	public function new()
	{
		super();
		init();
	}
	
	/**
	 * Global initialise function
	 */
	private function init()
	{
		initEngine();
		initLights();
		initMaterials();
		initButton();
		//initObjects();
		initListeners();
		roll = false;
	}

	
	
	/**
	 * Initialise the engine
	 */
	private function initEngine()
	{
		stage.scaleMode = StageScaleMode.NO_SCALE;
		stage.align = StageAlign.TOP_LEFT;
		
		scene = new Scene3D();
		
		camera = new Camera3D();
		
		view = new View3D();
		view.antiAlias = 4;
		view.scene = scene;
		view.camera = camera;
		view.backgroundColor = 0x333333;
		
		//setup controller to be used on the camera
		
		cameraController = new HoverController(camera);
		cameraController.distance = 150; 
		cameraController.minTiltAngle = -90;
		cameraController.maxTiltAngle = 90;
		cameraController.panAngle = 45;
		cameraController.tiltAngle = 20;
		
		addChild(view);
					
        //stats
        this.addChild(new away3d.debug.AwayFPS(view, 10, 10, 0xffffff, 3));
	}
	
	/**
	 * Initialise the lights
	 */
	private function initLights()
	{
		
		directionalLight = new DirectionalLight(0, -1, 0);
		directionalLight.castsShadows = false;
		directionalLight.color = 0xeedddd;
		directionalLight.diffuse = .5;
		directionalLight.ambient = .5;
		directionalLight.specular = 0;
		directionalLight.ambientColor = 0x808090;
		view.scene.addChild(directionalLight);
		
		lightPicker = new StaticLightPicker([directionalLight]);
		
	}
	
	/**
	 * Initialise the materials
	 */
	private function initMaterials()
	{
		
		sphereMaterial = new ColorMaterial(0xaa0000);
		
		
	}
	
	
	private function initButton() {
		
		
		var bondtest = new Bond();
		scene.addChild(bondtest);
		
		
		//wall = new Sprite();
		//wall.graphics.beginBitmapFill("wall.jpg");
		//addChild(wall);
		openButton.graphics.beginFill(0xFF0000, 1);
		openButton.graphics.drawRoundRect(0, 0, 120, 40, 50, 50);
		openButton.buttonMode = true;
		clearButton.graphics.beginFill(0xFF0000, 1);
		clearButton.graphics.drawRoundRect(0, 50, 120, 40, 50, 50);
		open.x = 20;
		open.y = 10;
		open.text = "OPEN";
		open.selectable = false;
		openButton.addChild(open);
		addChild(openButton);
		addChild(clearButton);

		openButton.addEventListener(MouseEvent.MOUSE_DOWN, openPressed);
		clearButton.addEventListener(MouseEvent.MOUSE_DOWN, clearPressed);
	}
	
	function openPressed(e:MouseEvent) {
		var filters: FILEFILTERS = 
			{ count: 3
			, descriptions: ["Text files", "JPEG files", "sdf files"]
			, extensions: ["*.txt","*.jpg;*.jpeg","*.sdf"]			
			};		
		var result:Array<String> = Dialogs.openFile
			( "Select a file please!"
			, "Please select one or more files, so we can see if this method works"
			, filters 
			);
		initObjects(result);
	}
	
	function clearPressed(e:MouseEvent) {
			
	}
	

	private function initObjects(result:Array<String>)
	{
		var string:String = null;
		if (result != null && result.length > 0) {
			string = result[0];
		}else init();
		
		var cont = File.getContent(string);
		var lines = cont.split("\n");
		
		var i = 4;
		var atom:Array<Atom> = [];
		//header block
		var name_molecule:String = lines[1].substring(0, 79);
		//counts line
		number_atom = Std.parseInt(lines[3].substring(0, 3));
		number_bond = Std.parseInt(lines[3].substring(3, 6));
		//atom block
		var first_bond_line:Int = number_atom + 4;
		for (i in 4...first_bond_line) {
			typeAtom = lines[i].substring(31, 32);
			atom[i] = new Atom(10, typeAtom);
			
			/*
			atom[i].mouseEnabled = true;
			atom[i].addEventListener(MouseEvent3D.MOUSE_OVER, overAtom);
			atom[i].addEventListener(MouseEvent3D.MOUSE_OUT, outAtom);
			*/
			scene.addChild(atom[i]);
			var ox = lines[i].substring(0, 10);
			var oy = lines[i].substring(10, 20);
			var oz = lines[i].substring(20, 30);
			var ciao = Std.parseFloat(ox);
			var lol = Std.parseFloat(oy);
			var asd = Std.parseFloat(oz);
			atom[i].position = new Vector3D(ciao*40, lol*40, asd*40);
		}
		var somma_vect = new Vector3D(0, 0, 0);
		for (i in 1...number_atom+1){
			id[i] = atom[i + 3];
			somma_vect = somma_vect.add(id[i].position);
		}
		//bond block
		var segmentset:SegmentSet = new SegmentSet();
		scene.addChild(segmentset);
		for (i in first_bond_line...first_bond_line+number_bond) {
			var first_atom = Std.parseInt(lines[i].substring(0, 3));
			var second_atom = Std.parseInt(lines[i].substring(3, 6));
			var distance:Float = Math.sqrt(((id[first_atom].x - id[second_atom].x) * (id[first_atom].x - id[second_atom].x)) + ((id[first_atom].y - id[second_atom].y) * (id[first_atom].y - id[second_atom].y)) + ((id[first_atom].z - id[second_atom].z) * (id[first_atom].z - id[second_atom].z)));
			cyl = new Mesh(new CylinderGeometry(2,2,distance, true, true, true, false), new TextureMaterial(Cast.bitmapTexture("embeds/floor_diffuse.jpg")));
			view.scene.addChild(cyl);
			var vectSub = id[second_atom].position.subtract(id[first_atom].position);
			var vectSubHalf = new Vector3D(vectSub.x / 2, vectSub.y / 2, vectSub.z / 2);
			var point = id[first_atom].position.add(vectSubHalf);
			cyl.position = point;
			var z:Vector3D = new Vector3D(0, 0, 1);
			cyl.lookAt(id[first_atom].position, z);
		}
		trace(somma_vect);
		somma_vect.x = somma_vect.x / number_atom;
		somma_vect.y = somma_vect.y / number_atom;
		somma_vect.z = somma_vect.z / number_atom;
		trace("lol");
		trace(somma_vect);
		central_point.position = somma_vect;
		//id[0] = central_point;
		trace(central_point.position);
		scene.addChild(central_point);
		
		
		
		
		
		
		//bond2.load(new URLRequest("embeds/bond2.obj")); 
		//scene.addChild(bond2);
		
		
		
		/*
		var lines:SegmentSet;
		lines = new SegmentSet();
		scene.addChild(lines);
		
		//TRIDENT
		var firstVector:Vector3D = new Vector3D(-200,200,-200);
		var lastVectorX:Vector3D = new Vector3D( -100, 200, -200);
		var negativeVectorX:Vector3D = new Vector3D ( -250, 200, -200);
		var lastVectorY:Vector3D = new Vector3D( -200, 300, -200);
		var negativeVectorY:Vector3D = new Vector3D( -200, 150, -200);
		var lastVectorZ:Vector3D = new Vector3D( -200, 200, -100);
		var negativeVectorZ:Vector3D = new Vector3D( -200, 200, -250);
		var linex:LineSegment = new LineSegment(firstVector, lastVectorX, 0xFF0000, 0xFF0000, 5);		//red
		var liney:LineSegment = new LineSegment(firstVector, lastVectorY, 0x0000FF, 0x0000FF, 5);		//blue
		var linez:LineSegment = new LineSegment(firstVector, lastVectorZ, 0x00FF00, 0x00FF00, 5);		//lime
		var linexn:LineSegment = new LineSegment (firstVector, negativeVectorX, 0x000000, 0x000000, 5);
		var lineyn:LineSegment = new LineSegment (firstVector, negativeVectorY, 0x000000, 0x000000, 5);
		var linezn:LineSegment = new LineSegment (firstVector, negativeVectorZ, 0x000000, 0x000000, 5);
		lines.addSegment(linex);
		lines.addSegment(liney);
		lines.addSegment(linez);
		lines.addSegment(linexn);
		lines.addSegment(lineyn);
		lines.addSegment(linezn);
		*/
		
		//var _plane = new Mesh(new PlaneGeometry(700, 700));
		//scene.addChild(_plane);
		//var bond:Single = new Single(50);
		//scene.addChild(bond);
		
	}
	
	/*
	private function overAtom(event:Event) {
		addChild(messageField);
		messageField.x = 500;
		messageField.y = 500;
		for (i in 0...number_atom-1) {
			messageField.text = typeAtom[i];
		}
		//messageField.text = typeAtom;
	}
	
	private function outAtom(event:Event) {
		removeChild(messageField);
		
	}
	*/
	
	/**
	 * Initialise the listeners
	 */

	private function initListeners()
	{
		view.setRenderCallback(onEnterFrame);
		stage.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
		stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
		stage.addEventListener(Event.RESIZE, onResize);
		this.addEventListener(MouseEvent.MOUSE_WHEEL, rollOut);
		onResize();
	}
	
	/**
	 * Navigation and render loop
	 */
	private function onEnterFrame(event:Event)
	{
		cameraController.lookAtObject = central_point;
		if (move) {
			cameraController.lookAtObject = central_point;
			cameraController.panAngle = 0.3*(stage.mouseX - lastMouseX) + lastPanAngle;
			cameraController.tiltAngle = 0.3 * (stage.mouseY - lastMouseY) + lastTiltAngle;
		}
		
		if (cameraController.distance < 30)
			cameraController.distance = 30;
		if (cameraController.distance > 1000)
			cameraController.distance = 1000;
			
		view.render();
	}
	
	/**
	 * Mouse down listener for navigation
	 */
	private function onMouseDown(event:MouseEvent)
	{
		lastPanAngle = cameraController.panAngle;
		lastTiltAngle = cameraController.tiltAngle;
		lastMouseX = stage.mouseX;
		lastMouseY = stage.mouseY;
		move = true;
		stage.addEventListener(Event.MOUSE_LEAVE, onStageMouseLeave);
	}
	
	/**
	 * Mouse up listener for navigation
	 */
	private function onMouseUp(event:MouseEvent)
	{
		move = false;
		stage.removeEventListener(Event.MOUSE_LEAVE, onStageMouseLeave);
	}
	
	/**
	 * Mouse stage leave listener for navigation
	 */
	private function onStageMouseLeave(event:Event)
	{
		move = false;
		stage.removeEventListener(Event.MOUSE_LEAVE, onStageMouseLeave);
	}
	
	/**
	 * Zoom
	 */
	private function rollOut(event:MouseEvent)
	{
		if (event.delta > 0) 
			cameraController.distance -= 10;
		else cameraController.distance += 10;
		
		//if (event.delta <0)
			//roll = true;
		/*
			if (event.delta < 0){
				//roll = 1;
				cameraController.distance += 10;
			}
			else roll = 2;
			*/
			
		text = new TextField();
		text.text = "lolololololololololololololololololololololol";
			
	}
	
	/**
	 * stage listener for resize events
	 */
	private function onResize(event:Event = null)
	{
		view.width = stage.stageWidth;
		view.height = stage.stageHeight;
	}
	
}

