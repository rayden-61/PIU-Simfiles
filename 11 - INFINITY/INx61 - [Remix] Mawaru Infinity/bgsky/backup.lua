return Def.ActorFrame{
	
	Def.ActorFrame{
		OnCommand=cmd(x,-SCREEN_WIDTH/2;y,-SCREEN_HEIGHT/2),
		LoadActor("sky.png")..{ OnCommand=cmd(x,SCREEN_CENTER_X;y,SCREEN_CENTER_Y;zoom,3)},
		LoadActor("back.png")..{ OnCommand=cmd(zoom,4;blend,Blend.Add;x,SCREEN_CENTER_X;y,SCREEN_CENTER_Y;
		customtexturerect,4,4,0,0;texcoordvelocity,0,-0.08)},
		
		LoadActor("clouds")..{ OnCommand=cmd(x,SCREEN_CENTER_X;y,SCREEN_CENTER_Y;zoom,5;
		customtexturerect,0,0,2,2;texcoordvelocity,0.04,0;)},
		
		Def.Quad{
			OnCommand=cmd(Center;FullScreen;diffuse,0,0,0,.6);
		}
	}
	
}