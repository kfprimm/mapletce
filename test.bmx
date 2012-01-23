
Strict

Import MaxB3D.Drivers
Import MaxB3DEx.Helper
Import "engine.bmx"

GLGraphics3D 800,600

Local engine:TMapletEngine = New TMapletEngine

Local plane:TPlane = New TPlane.FromPoint(Vec3(0,1,0),Vec3(0,0,0))

Local v:TVector = plane.LineIntersection(Vec3(5,5,5), Vec3(5,-5,5))
Print v.x+","+v.y+","+v.z

Local fly = false
While Not KeyDown(KEY_ESCAPE) And Not AppTerminate()	
	If KeyHit(KEY_F) fly=Not fly
	If fly FlyCam engine.camera

	engine.ChangeZoom KeyHit(KEY_A)-KeyHit(KEY_Z)
	
	If MouseHit(1) engine.Click()
	If KeyHit(KEY_R) engine.Reset
	
	Select True
	Case KeyDown(KEY_LCONTROL)
		engine.SetMode MAPLETMODE_ROTATE
	Case MouseDown(2)
		engine.SetMode MAPLETMODE_MOVE
	Default
		engine.SetMode 0
	End Select
	
	engine.MoveCursor(MouseX(), MouseY())
	
	Local info:TRenderInfo = RenderWorld()
	DoMax2D
	
	SetColor 0,255,0
	Local x#,y#
	CameraProject engine.camera,[engine.markerx,0.0,engine.markerz],x,y
	DrawRect x-2.5,y-2.5,5,5
	SetColor 255,255,255
	DrawText "FPS:       "+info.FPS,0,0
	DrawText "Triangles: "+info.Triangles,0,15
	
	DrawText "Grid Size: "+["1","0.5","0.25","0.125"][engine.zoom],0,45
	Flip
Wend

