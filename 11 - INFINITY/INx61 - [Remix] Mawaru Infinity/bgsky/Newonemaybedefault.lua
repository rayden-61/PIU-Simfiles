return Def.ActorFrame{
	
	Def.ActorFrame{
		OnCommand=cmd(x,-SCREEN_WIDTH/2000;y,-SCREEN_HEIGHT/2000;zoom,1.1),
		LoadActor("sky.png")..{ OnCommand=cmd(x,SCREEN_CENTER_X;y,SCREEN_CENTER_Y;zoom,300)},
		
		LoadActor("16xback.png")..{ OnCommand=cmd(zoom,1.7;x,SCREEN_CENTER_X;y,SCREEN_CENTER_Y;
		customtexturerect,4,4,0,0;texcoordvelocity,0,-0.05)},
		
		LoadActor("16xclouds")..{ OnCommand=cmd(x,SCREEN_CENTER_X;y,SCREEN_CENTER_Y;zoom,5;
		customtexturerect,0,0,2,2;texcoordvelocity,0.01,0;)},
		
		Def.Quad{
			OnCommand=cmd(Center;FullScreen;diffuse,0,0,0,.6);
		}
	}
	
}