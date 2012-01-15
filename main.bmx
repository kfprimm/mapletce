
Strict

Framework MaxB3D.GUI
Import MaxGUI.XPManifest
Import "engine.bmx"

SetGraphicsDriver GLMaxB3DDriver(), GRAPHICS_BACKBUFFER|GRAPHICS_DEPTHBUFFER
AppTitle = "Maplet CE v1.02"

Const MENU_FILE_NEW			= 1
Const MENU_FILE_OPEN		= 2
Const MENU_FILE_SAVE		= 3
Const MENU_FILE_SAVEAS		= 4
Const MENU_FILE_CLOSE		= 5
Const MENU_FILE_EXIT		= 6

Const MENU_EDIT_UNDO		= 7
Const MENU_EDIT_RESET		= 8
Const MENU_EDIT_ZOOMIN		= 9
Const MENU_EDIT_ZOOMOUT		= 10
Const MENU_EDIT_ROTATEPRIM	= 11

Const MENU_VIEW_TEXTURED		= 12
Const MENU_VIEW_OUTLINES		= 13
Const MENU_VIEW_TRANSPARENT	= 14

Const MENU_TEXTURE_OPEN		= 15
Const MENU_TEXTURE_REPLACE	= 16

Const MENU_TOOLS_LIGHTMAPPER	= 17

Const CURSOR_NONE		= 0
Const CURSOR_SELECT		= 1
Const CURSOR_RAISE		= 2
Const CURSOR_MOVE		= 3
Const CURSOR_MOVEPLANE	= 4
Const CURSOR_MOVECAMERA	= 5

Global GridSize$[]=["1","0.5","0.25","0.125"]

Type TMaplet
	Field window:TGadget,tabber:TGadget,canvas:TGadget
	Field panel:TGadget,primitivebox:TGadget,texturebox:TGadget,modebox:TGadget
	Field primitivecanvas:TGadget,gridsizelabel:TGadget,cursorlabel:TGadget
	
	Field engine:TMapletEngine = New TMapletEngine

	Method New()
		window=CreateWindow(AppTitle+" - Untitled",32,32,640,480,Null,WINDOW_TITLEBAR|WINDOW_MENU|WINDOW_RESIZABLE|WINDOW_STATUS|WINDOW_HIDDEN)
		SetMinWindowSize window,640,480
		Local filemenu:TGadget=CreateMenu("File",0,WindowMenu(window))
			CreateMenu "New",MENU_FILE_NEW,filemenu,KEY_N,MODIFIER_COMMAND
			CreateMenu "Open...",MENU_FILE_OPEN,filemenu,KEY_O,MODIFIER_COMMAND
			CreateMenu "Save",MENU_FILE_SAVE,filemenu,KEY_S,MODIFIER_COMMAND
			CreateMenu "Save As...",MENU_FILE_SAVEAS,filemenu,KEY_S,MODIFIER_COMMAND|MODIFIER_SHIFT
			CreateMenu "Close",MENU_FILE_CLOSE,filemenu
			CreateMenu "",0,filemenu
			Local exportmenu:TGadget=CreateMenu("Export",0,filemenu)
				DisableMenu exportmenu
				CreateMenu "DirectX (.x) file...",0,exportmenu
				CreateMenu "Blitz3D (.b3d) file...",0,exportmenu
			CreateMenu "",0,filemenu
			CreateMenu "Exit",MENU_FILE_EXIT,filemenu,KEY_F4,MODIFIER_OPTION
		Local editmenu:TGadget=CreateMenu("Edit",0,WindowMenu(window))
			CreateMenu "Undo",MENU_EDIT_UNDO,editmenu,KEY_Z,MODIFIER_COMMAND
			CreateMenu "",0,editmenu
			CreateMenu "Reset View",MENU_EDIT_RESET,editmenu,KEY_R,MODIFIER_COMMAND
			CreateMenu "",0,editmenu
			CreateMenu "Zoom grid in",MENU_EDIT_ZOOMIN,editmenu,KEY_A
			CreateMenu "Zoom grid out",MENU_EDIT_ZOOMOUT,editmenu,KEY_Z
			CreateMenu "",0,editmenu
			CreateMenu "Rotate primitive",0,editmenu,KEY_Q
		Local viewmenu:TGadget=CreateMenu("View",0,WindowMenu(window))
			CheckMenu CreateMenu("Textured",MENU_VIEW_TEXTURED,viewmenu,KEY_F9)
			CheckMenu CreateMenu("Outline backfacing",MENU_VIEW_OUTLINES,viewmenu,KEY_F10)
			CreateMenu "Transparent",MENU_VIEW_TRANSPARENT,viewmenu,KEY_F11
		Local texturemenu:TGadget=CreateMenu("Texture",0,WindowMenu(window))
			CreateMenu "Open...",MENU_TEXTURE_OPEN,texturemenu
			CreateMenu "Replace...",MENU_TEXTURE_REPLACE,texturemenu
		Local toolsmenu:TGadget=CreateMenu("Tools",0,WindowMenu(window))
			CreateMenu "Lightmapper...",MENU_TOOLS_LIGHTMAPPER,toolsmenu
		UpdateWindowMenu window
		
		tabber=CreateTabber(4,4,ClientWidth(window)-8,ClientHeight(window)-8,window)
		SetGadgetLayout tabber,EDGE_ALIGNED,EDGE_ALIGNED,EDGE_ALIGNED,EDGE_ALIGNED
		
		canvas=CreateCanvas(0,0,486,ClientHeight(tabber)-2,tabber)
		SetGadgetLayout canvas,EDGE_ALIGNED,EDGE_ALIGNED,EDGE_ALIGNED,EDGE_ALIGNED
			
		panel=CreatePanel(488,0,ClientWidth(tabber)-492,ClientHeight(tabber),tabber)
		SetGadgetLayout panel,EDGE_CENTERED,EDGE_ALIGNED,EDGE_ALIGNED,EDGE_CENTERED
		CreateLabel "Primitive:",0,0,ClientWidth(panel),13,panel
		primitivebox=CreateComboBox(0,15,ClientWidth(panel),15,panel)
		AddGadgetItem primitivebox,"Box"
		AddGadgetItem primitivebox,"Ramp"
		AddGadgetItem primitivebox,"Column"
		AddGadgetItem primitivebox,"Tube"
		AddGadgetItem primitivebox,"Wedge"
		AddGadgetItem primitivebox,"<custom>"
		SelectGadgetItem primitivebox,0
		
		CreateLabel "Texture:",0,48,ClientWidth(panel),15,panel
		texturebox=CreateComboBox(0,48+15,ClientWidth(panel),20,panel)
		AddGadgetItem texturebox,"<invisible>"
		SelectGadgetItem texturebox,0
		
		CreateLabel "Mode:",0,96,ClientWidth(panel),13,panel
		modebox=CreateComboBox(0,96+15,ClientWidth(panel),20,panel)
		AddGadgetItem modebox,"Carve"
		AddGadgetItem modebox,"Fill"
		AddGadgetItem modebox,"Copy"
		SelectGadgetItem modebox,0
		
		primitivecanvas=CreateCanvas(0,96+48,ClientWidth(panel),ClientWidth(panel),panel)
		
		Rem
		primitive[0]=CreateBSPCube(Null)
		primitive[1]=CreateBSPRamp(Null)
		primitive[2]=CreateBSPCylinder(12,Null)
		Local mat:TMatrix=New TMatrix
		mat.Rotate(90,0,0)
		primitive[3]=CreateBSPCylinder(12,mat)
		primitive[4]=CreateBSPWedge(Null)
		End Rem
		gridsizelabel=CreateLabel("Grid size: ",0,144+8+ClientWidth(panel),ClientWidth(panel),15,panel)
		cursorlabel=CreateLabel("Cursor: ",0,144+8+ClientWidth(panel)+17,ClientWidth(panel),15,panel)
		
		SetGraphics CanvasGraphics(canvas)
'		currentmap=TMapletMap.Add(tabber)		
	
		AddHook EmitEventHook,Hook,Self
		ShowGadget window
				
		Repeat
			WaitSystem
		Forever
	End Method	
	
	Method OnEvent(event:TEvent)
		Select event.id
		Case EVENT_WINDOWCLOSE
			End
		Case EVENT_WINDOWMOVE
			RedrawGadget canvas
		Case EVENT_GADGETPAINT
			SetGraphics CanvasGraphics(TGadget(event.source))
			Select event.source
			Case primitivecanvas
				Cls
				Flip
			Case canvas
				engine.Resize(ClientWidth(canvas),ClientHeight(canvas))
				RenderWorld
				Flip
			End Select
		End Select
	End Method
	
	Function Hook:Object(id,data:Object,context:Object=Null)
		TMaplet(context).OnEvent(TEvent(data))
	End Function
End Type
New TMaplet