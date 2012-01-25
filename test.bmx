
Strict

Framework MaxB3D.Drivers
Import MaxB3DEx.Helper
Import "src/engine.bmx"

SetGraphicsDriver D3D9MaxB3DDriver(), GRAPHICS_BACKBUFFER|GRAPHICS_DEPTHBUFFER
Graphics 800,600

Local engine:TMapletEngine = New TMapletEngine

Local plane:TPlane = New TPlane.FromPoint(Vec3(0,1,0),Vec3(0,2,0))

Local fly = False
While Not KeyDown(KEY_ESCAPE) And Not AppTerminate()	
	If KeyHit(KEY_F) fly=Not fly
	If fly FlyCam engine.camera

	engine.ChangeZoom KeyHit(KEY_A)-KeyHit(KEY_Z)
	engine.ChangeZoom KeyHit(KEY_S)-KeyHit(KEY_X)
	
	If KeyHit(KEY_R) engine.Reset
	
	Select True
	Case KeyDown(KEY_LCONTROL)
		engine.SetMode MAPLETMODE_ROTATE
	Case KeyDown(KEY_LSHIFT) And MouseDown(2)
		engine.SetMode MAPLETMODE_MOVEY
	Case MouseDown(1)
		engine.Mark()
	Case MouseDown(2)
		engine.SetMode MAPLETMODE_MOVEXZ
	Case KeyDown(KEY_LSHIFT)
		engine.SetMode MAPLETMODE_PLANE
	Case KeyDown(KEY_F1)
		engine.SetView MAPLETVIEW_FACES
	Case KeyDown(KEY_F2)
		engine.SetView MAPLETVIEW_WIREFRAME
	Default
		engine.SetMode 0
	End Select
	
	engine.MoveCursor(MouseX(), MouseY())
	
'	TurnEntity engine.model,1,1,0
	
	Local info:TRenderInfo = RenderWorld()
	DoMax2D
	
	If GetEntityVisible(engine.large_cursor)
		If engine.begin_marker 
			SetColor 255,0,0
		Else
			SetColor 0,255,0
		EndIf
		Local x#,y#
		CameraProject engine.camera,[engine.marker.x,engine.marker.y,engine.marker.z],x,y
		DrawRect x-2.5,y-2.5,5,5
		SetColor 255,255,255
		DrawText "Marker Y: "+engine.marker.y,0,52
	EndIf
	
	DrawText "FPS:       "+info.FPS,0,0
	DrawText "Triangles: "+info.Triangles,0,13
	
	DrawText "Grid Size: "+["1","0.5","0.25","0.125"][engine.zoom],0,39
	Flip
Wend

