
Strict

Framework MaxB3D.Drivers
Import MaxB3DEx.Helper
Import "src/engine.bmx"

''SetGraphicsDriver D3D9MaxB3DDriver(), GRAPHICS_BACKBUFFER|GRAPHICS_DEPTHBUFFER
Graphics 800,600

Local engine:TMapletEngine = New TMapletEngine

Function Hook:Object(id,data:Object,context:Object=Null)
	TMapletEngine(context).OnEvent(TEvent(data))
End Function
AddHook EmitEventHook, Hook, engine

While Not KeyDown(KEY_ESCAPE) And Not AppTerminate()	
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

