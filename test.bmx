
Strict

Import MaxB3D.Drivers
Import MaxB3DEx.Helper
Import "engine.bmx"

GLGraphics3D 800,600

Local engine:TMapletEngine = New TMapletEngine

While Not KeyDown(KEY_ESCAPE) And Not AppTerminate()	
	engine.ChangeZoom KeyHit(KEY_A)-KeyHit(KEY_Z)
	
	RenderWorld
	Flip
Wend

