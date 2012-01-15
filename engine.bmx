
Strict

Import MaxB3D.Functions
Import MaxB3DEx.Grid
Import MaxB3DEx.GLGrid
Import MaxB3DEx.D3D9Grid

Type TMapletEngine
	Field light:TLight, camera:TCamera
	Field grids:TPivot, reference:TGrid, large_cursor:TGrid, small_cursor:TGrid
	Field model:TBSPModel
	Field zoom
	
	Method New()
		light = CreateLight()
		
		camera  = CreateCamera()
		SetEntityPosition camera,0,5.5,-9.5
		SetEntityRotation camera,30,0,0
		SetEntityColor camera,0,0,255
		
		grids = CreatePivot()
		SetEntityRotation grids,90,0,0
		
		reference = CreateGrid(16,16,grids)
		SetEntityPosition reference,-128,-128,0
		SetEntityScale reference,16,16,0
		SetEntityFX reference,FX_FULLBRIGHT
		SetEntityColor reference,0,191,255
		SetEntityOrder reference,-100
		
		large_cursor = CreateGrid(48,48,grids)
		SetEntityFX large_cursor,FX_FULLBRIGHT
		SetEntityColor large_cursor,0,128,255
		
		small_cursor = CreateGrid(,,grids)
		SetEntityFX small_cursor,FX_FULLBRIGHT
		SetEntityColor small_cursor,0,89,255
		
		ChangeZoom 2
	End Method
	
	Method ChangeZoom(inc)
		zoom:+inc
		Local size# = 48*(2^zoom-1), scale# = 1*(.5^(zoom-1))
		SetGridSize small_cursor,size,size
		SetEntityScale small_cursor,scale,scale,scale
	End Method
	
	Method Resize(width, height)
		SetCameraViewport camera,0,0,width,height
	End Method
End Type



