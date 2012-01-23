
Strict

Import MaxB3D.Functions
Import MaxB3D.Primitives
Import MaxB3DEx.Grid
Import MaxB3DEx.GLGrid
Import MaxB3DEx.D3D9Grid

Const MAPLETMODE_MOVE		= 1
Const MAPLETMODE_ROTATE	= 2

Type TMapletEngine
	Field light:TLight, camera:TCamera
	Field grids:TPivot, reference:TGrid, large_cursor:TGrid, small_cursor:TGrid
	Field model:TBSPModel
	Field zoom
	
	Field mode
	
	Field cursorx#, cursory#
	Field markerx#, markerz#
	
	Method New()
		light = CreateLight()
		''SetEntityRotation light,270,180,0
		
		camera  = CreateCamera()
		SetEntityColor camera,0,0,255
		
		reference = CreateGrid(16,16)
		SetEntityPosition reference,-128,0,-128
		SetEntityRotation reference,90,0,0
		SetEntityScale reference,16,16,0
		SetEntityFX reference,FX_FULLBRIGHT
		SetEntityColor reference,0,191,255
		
		large_cursor = CreateGrid(48,48)
		SetEntityRotation large_cursor,90,0,0
		SetEntityFX large_cursor,FX_FULLBRIGHT
		SetEntityColor large_cursor,0,128,255
		
		small_cursor = CreateGrid(,,large_cursor)
		SetEntityFX small_cursor,FX_FULLBRIGHT
		SetEntityColor small_cursor,0,89,255
		
		Local cube:TMesh = CreateCube()
		SetEntityPosition cube,0,1,0
		FlipMesh cube
		
		Reset
	End Method
	
	Method ChangeZoom(inc)
		zoom = Min(3,Max(0, zoom + inc))
		Local size# = 48*(2^zoom), scale# = 1*(.5^zoom)
		DebugLog "size = "+size+", scale = "+scale
		SetGridSize small_cursor,size,size
		SetEntityScale small_cursor,scale,scale,scale
	End Method
	
	Method Resize(width, height)
		SetCameraViewport camera,0,0,width,height
	End Method
	
	Method Reset()
		SetEntityPosition camera,0,5.5,-9.5
		SetEntityRotation camera,30,0,0
		
		ChangeZoom 0
	End Method

	Method SetMode(m)
		mode = m
	End Method
	
	Method MoveCursor(x#,y#)
		cursorx = x
		cursory = y
		
		Select mode
		Case MAPLETMODE_MOVE
			
		Default
			Local z#
			If MouseIntersect(x,y,z)
				markerx = Round(x, zoom)
				markerz = Round(z, zoom)
				SetEntityPosition large_cursor,markerx - 24,0.0,markerz - 24
			EndIf
		End Select
	End Method
	
	Method Click()
		Local x#,y#,z#
	End Method
	
	Method Round#(v#,frac = 1)
		Local diff#=v-Int(v)
		If Abs(diff) >= .5 Return Int(v)+Sgn(diff)
		Return Int(v)
	End Method
	
	Method MouseIntersect(x# Var, y# Var, z# Var)
		Local ptA:TVector = Vec3(0,0,0), ptB:TVector = Vec3(0,0,0)
		camera.Unproject cursorx,cursory,0,ptA.x,ptA.y,ptA.z
		camera.Unproject cursorx,cursory,1,ptB.x,ptB.y,ptB.z
		Local v:TVector = reference.IntersectsLine(ptA, ptB)
		If v = Null Return False
		x = v.x
		y = v.y
		z = v.z
		Return True
	End Method
End Type



