
Strict

Framework MaxB3D.GUI
Import MaxGUI.XPManifest
Import "src/engine.bmx"

GLShareContexts
SetGraphicsDriver GLMaxB3DDriver(), GRAPHICS_BACKBUFFER|GRAPHICS_DEPTHBUFFER

Const MENU_FILE_NEW						= 1
Const MENU_FILE_OPEN					= 2
Const MENU_FILE_SAVE					= 3
Const MENU_FILE_SAVEAS				= 4
Const MENU_FILE_CLOSE					= 5
Const MENU_FILE_EXIT					= 6

Const MENU_EDIT_UNDO					= 7
Const MENU_EDIT_RESET					= 8
Const MENU_EDIT_ZOOMIN				= 9
Const MENU_EDIT_ZOOMOUT				= 10
Const MENU_EDIT_ROTATEPRIM		= 11

Const MENU_VIEW_TEXTURED			= 12
Const MENU_VIEW_OUTLINES			= 13
Const MENU_VIEW_TRANSPARENT		= 14
Const MENU_VIEW_WIREFRAME			= 15

Const MENU_TEXTURE_OPEN				= 16
Const MENU_TEXTURE_REPLACE		= 17

Const MENU_TOOLS_LIGHTMAPPER	= 18

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
	
	Field engines:TMapletEngine[]
	Field renderinfo:TRenderInfo

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
			CreateMenu "Wireframe",MENU_VIEW_WIREFRAME,viewmenu,KEY_F12
		Local texturemenu:TGadget=CreateMenu("Texture",0,WindowMenu(window))
			CreateMenu "Open...",MENU_TEXTURE_OPEN,texturemenu
			CreateMenu "Replace...",MENU_TEXTURE_REPLACE,texturemenu
		Local toolsmenu:TGadget=CreateMenu("Tools",0,WindowMenu(window))
			CreateMenu "Lightmapper...",MENU_TOOLS_LIGHTMAPPER,toolsmenu
		UpdateWindowMenu window
		
		tabber=CreateTabber(4,4,ClientWidth(window)-8,ClientHeight(window)-8,window)
		SetGadgetLayout tabber,EDGE_ALIGNED,EDGE_ALIGNED,EDGE_ALIGNED,EDGE_ALIGNED
					
		panel=CreatePanel(488,0,ClientWidth(tabber)-492,ClientHeight(tabber),tabber)
		SetGadgetLayout panel,EDGE_CENTERED,EDGE_ALIGNED,EDGE_ALIGNED,EDGE_CENTERED
		CreateLabel "Primitive:",0,0,ClientWidth(panel),13,panel
		primitivebox=CreateComboBox(0,15,ClientWidth(panel),20,panel)
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
			
		gridsizelabel=CreateLabel("Grid size: ",0,144+8+ClientWidth(panel),ClientWidth(panel),15,panel)
		cursorlabel=CreateLabel("Cursor: ",0,144+8+ClientWidth(panel)+17,ClientWidth(panel),15,panel)
		
		AddHook EmitEventHook,Hook,Self						
		ShowGadget window

		canvas=CreateCanvas(0,0,486,ClientHeight(tabber)-2,tabber)
		SetGadgetLayout canvas,EDGE_ALIGNED,EDGE_ALIGNED,EDGE_ALIGNED,EDGE_ALIGNED

		primitivecanvas=CreateCanvas(0,96+48,ClientWidth(panel),ClientWidth(panel),panel)

		SetGraphics CanvasGraphics(canvas)
		
		AddMap "<untitled>"
					
		Repeat
			WaitSystem
		Forever
	End Method	
	
	Method OnEvent(event:TEvent)
		Local engine:TMapletEngine = TMapletEngine(GadgetItemExtra(tabber, SelectedGadgetItem(tabber)))
		Local gadget:TGadget = TGadget(event.source)

		Select event.id
		Case EVENT_MENUACTION
			Select event.data
			Case MENU_FILE_NEW
				AddMap "<untitled>"
			Case MENU_FILE_OPEN
			Case MENU_FILE_SAVE
			Case MENU_FILE_SAVEAS
			Case MENU_FILE_CLOSE
			Case MENU_FILE_EXIT
				End			
			Case MENU_EDIT_UNDO
			Case MENU_EDIT_RESET
				engine.Reset
			Case MENU_EDIT_ZOOMIN
				engine.ChangeZoom 1
			Case MENU_EDIT_ZOOMOUT
				engine.ChangeZoom -1
			Case MENU_EDIT_ROTATEPRIM
			Case MENU_VIEW_TEXTURED
			Case MENU_VIEW_OUTLINES
			Case MENU_VIEW_TRANSPARENT	
			Case MENU_VIEW_WIREFRAME
				If MenuChecked(gadget)
					UncheckMenu gadget
					SetEntityFX engine.model, FX_WIREFRAME
				Else
					CheckMenu gadget
					SetEntityFX engine.model, 0
				EndIf
			Case MENU_TEXTURE_OPEN
			Case MENU_TEXTURE_REPLACE			
			Case MENU_TOOLS_LIGHTMAPPER
				Notify "Lightmapper not implemented! (yet)~n~nVisit https://github.com/kfpimm/mapletce~nand consider contributing!"
			End Select
			RedrawGadget canvas
		Case EVENT_GADGETACTION
			Select event.source
			Case tabber
				RefreshUI
			End Select
		Case EVENT_WINDOWCLOSE
			End
		Case EVENT_WINDOWMOVE
			RedrawGadget canvas
		Case EVENT_WINDOWSIZE
			For Local engine:TMapletEngine = EachIn engines
				engine.Resize(ClientWidth(canvas),ClientHeight(canvas))
			Next
		Case EVENT_KEYDOWN, EVENT_MOUSEDOWN, EVENT_MOUSEMOVE
			RedrawGadget primitivecanvas
		Case EVENT_GADGETPAINT
			SetGraphics CanvasGraphics(primitivecanvas)
			SetClsColor 0,0,255
			Cls
			Flip
		End Select
	End Method
	
	Method OnCanvasEvent(event:TEvent)
		Local engine:TMapletEngine = TMapletEngine(GadgetItemExtra(tabber, SelectedGadgetItem(tabber)))
		engine.OnEvent(event)
		Select event.id
		Case EVENT_KEYDOWN, EVENT_MOUSEDOWN, EVENT_MOUSEMOVE
			RedrawGadget canvas
			ActivateGadget canvas
		Case EVENT_GADGETPAINT
			SetGraphics CanvasGraphics(canvas)
			renderinfo = engine.world.Render()
			DoMax2D
			
			SetStatusText window,"Triangles: "+renderinfo.Triangles+" Nodes: "+engine.model.GetTree().CountNodes()
			
			If GetEntityVisible(engine.large_cursor)
				If engine.begin_marker 
					SetColor 255,0,0
				Else
					SetColor 0,255,0
				EndIf
				Local x#,y#
				CameraProject engine.camera,[engine.marker.x,engine.marker.y,engine.marker.z],x,y
				DrawRect x-2.5,y-2.5,5,5
			EndIf

			Flip
		End Select
	End Method
	
	Method AddMap(name$)
		engines = engines[..engines.length+1]
		engines[engines.length-1] = New TMapletEngine
		AddGadgetItem tabber,name,,,,engines[engines.length-1]
		SelectGadgetItem tabber,CountGadgetItems(tabber)-1

		RefreshUI
	End Method
	
	Method RefreshUI()
		RedrawGadget canvas
		ActivateGadget canvas
	End Method
	
	Function Hook:Object(id,data:Object,context:Object=Null)
		Local event:TEvent = TEvent(data)
		If event.source = TMaplet(context).canvas
			TMaplet(context).OnCanvasEvent(event)
		Else
			TMaplet(context).OnEvent(event)
		EndIf
	Print TEvent(data).ToString()		
	End Function
End Type

' just for lawls
If AppArgs.length > 1
	If AppArgs[1] = "--retro"
		AppTitle = "Notify!"
		Notify "Maplet V1.02 - Release version.~n~nCopyright 2002, Blitz Research Ltd.~n~nPlease visit http://www.blitzbasic.co.nz~nto register your copy of Maplet."
	EndIf
EndIf
		
AppTitle = "Maplet CE v1.02"
New TMaplet
