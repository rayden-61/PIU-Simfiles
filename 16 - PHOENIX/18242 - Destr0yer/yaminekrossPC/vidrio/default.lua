local t = Def.ActorFrame{   
   InitCommand= cmd(draworder,100;x,SCREEN_CENTER_X;y,SCREEN_CENTER_Y),
   OnCommand=cmd(linear,0;zoom,0;linear,0.1;zoom,1.3;diffusealpha,1;linear,0.5;linear,0.4;diffusealpha,0;);
	LoadActor("vidrio.png")..{
		OnCommand = cmd(zoomto,SCREEN_WIDTH,SCREEN_HEIGHT;);
		
	};
};


return t;