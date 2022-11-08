local Black = color("#000000");

local cenx = SCREEN_CENTER_X
local ceny = SCREEN_CENTER_Y
local sw = SCREEN_WIDTH
local sh = SCREEN_HEIGHT

local t = Def.ActorFrame {
	Def.Quad {
		OnCommand=cmd(x,cenx;y,sh*0.1;zoomtowidth,sw;diffuse,Black;queuecommand,'Expand');
		ExpandCommand=cmd(sleep,2*(15/170);decelerate,0.3;zoomtoheight,sh*0.2;sleep,40/170;decelerate,0.3;zoomtoheight,0;queuecommand,'Stop');
		StopCommand=cmd(sleep,0;diffusealpha,0;stoptweening;);
	};
	Def.Quad {
		OnCommand=cmd(x,cenx;y,sh*0.3;zoomtowidth,sw;diffuse,Black;queuecommand,'Expand');
		ExpandCommand=cmd(sleep,1.5*(15/170);decelerate,0.3;zoomtoheight,sh*0.2;sleep,40/170;decelerate,0.3;zoomtoheight,0;queuecommand,'Stop');
		StopCommand=cmd(sleep,0;diffusealpha,0;stoptweening;);
	};
	Def.Quad {
		OnCommand=cmd(x,cenx;y,sh*0.5;zoomtowidth,sw;diffuse,Black;queuecommand,'Expand');
		ExpandCommand=cmd(sleep,1*(15/170);decelerate,0.3;zoomtoheight,sh*0.2;sleep,40/170;decelerate,0.3;zoomtoheight,0;queuecommand,'Stop');
		StopCommand=cmd(sleep,0;diffusealpha,0;stoptweening;);
	};
	Def.Quad {
		OnCommand=cmd(x,cenx;y,sh*0.7;zoomtowidth,sw;diffuse,Black;queuecommand,'Expand');
		ExpandCommand=cmd(sleep,0.5*(15/170);decelerate,0.3;zoomtoheight,sh*0.2;sleep,40/170;decelerate,0.3;zoomtoheight,0;queuecommand,'Stop');
		StopCommand=cmd(sleep,0;diffusealpha,0;stoptweening;);
	};
	Def.Quad {
		OnCommand=cmd(x,cenx;y,sh*0.9;zoomtowidth,sw;diffuse,Black;queuecommand,'Expand');
		ExpandCommand=cmd(sleep,0*(15/170);decelerate,0.3;zoomtoheight,sh*0.2;sleep,40/170;decelerate,0.3;zoomtoheight,0;queuecommand,'Stop');
		StopCommand=cmd(sleep,0;diffusealpha,0;stoptweening;);
	};
};

return t;
