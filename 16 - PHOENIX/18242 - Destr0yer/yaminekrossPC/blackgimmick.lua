local Black = color("#000000");
local Green = color("#00FF00");

local cenx = SCREEN_CENTER_X
local ceny = SCREEN_CENTER_Y
local sw = SCREEN_WIDTH
local sh = SCREEN_HEIGHT

local shutters = {
"11111",
"01000",
"00010",
"00100",
"01010",
"10101",
"01010",
"10101",
"00000",
}

local t = Def.ActorFrame {
	Def.Quad {
		OnCommand=cmd(x,cenx;y,sh*0.1;zoomtowidth,sw;diffuse,Black;queuecommand,'Expand');
		ExpandCommand=cmd(sleep,0.0*(10/170);decelerate,40/170;zoomtoheight,sh*0.2;sleep,0;queuecommand,'Next1');
		Next1Command=cmd(decelerate,40/170;zoomtoheight,tonumber(string.sub(shutters[2],1,1))*sh*0.2;sleep,40/170;queuecommand,'Next2');
		Next2Command=cmd(decelerate,40/170;zoomtoheight,tonumber(string.sub(shutters[3],1,1))*sh*0.2;sleep,40/170;queuecommand,'Next3');
		Next3Command=cmd(decelerate,40/170;zoomtoheight,tonumber(string.sub(shutters[4],1,1))*sh*0.2;sleep,40/170;queuecommand,'Next4');
		Next4Command=cmd(decelerate,40/170;zoomtoheight,tonumber(string.sub(shutters[5],1,1))*sh*0.2;sleep,40/170;queuecommand,'Next5');
		Next5Command=cmd(decelerate,40/170;zoomtoheight,tonumber(string.sub(shutters[6],1,1))*sh*0.2;sleep,40/170;queuecommand,'Next6');
		Next6Command=cmd(decelerate,40/170;zoomtoheight,tonumber(string.sub(shutters[7],1,1))*sh*0.2;sleep,40/170;queuecommand,'Next7');
		Next7Command=cmd(decelerate,40/170;zoomtoheight,tonumber(string.sub(shutters[8],1,1))*sh*0.2;sleep,40/170;queuecommand,'Next8');
		Next8Command=cmd(decelerate,40/170;zoomtoheight,tonumber(string.sub(shutters[9],1,1))*sh*0.2;sleep,40/170;queuecommand,'Next9');
		Next9Command=cmd(decelerate,40/170;zoomtoheight,tonumber(string.sub(shutters[10],1,1))*sh*0.2;sleep,40/170;queuecommand,'Stop');
		StopCommand=cmd(sleep,0;diffusealpha,0;stoptweening;);
	};
	Def.Quad {
		OnCommand=cmd(x,cenx;y,sh*0.3;zoomtowidth,sw;diffuse,Black;queuecommand,'Expand');
		ExpandCommand=cmd(sleep,0.5*(10/170);decelerate,40/170;zoomtoheight,sh*0.2;sleep,0;queuecommand,'Next1');
		Next1Command=cmd(decelerate,40/170;zoomtoheight,tonumber(string.sub(shutters[2],2,2))*sh*0.2;sleep,40/170;queuecommand,'Next2');
		Next2Command=cmd(decelerate,40/170;zoomtoheight,tonumber(string.sub(shutters[3],2,2))*sh*0.2;sleep,40/170;queuecommand,'Next3');
		Next3Command=cmd(decelerate,40/170;zoomtoheight,tonumber(string.sub(shutters[4],2,2))*sh*0.2;sleep,40/170;queuecommand,'Next4');
		Next4Command=cmd(decelerate,40/170;zoomtoheight,tonumber(string.sub(shutters[5],2,2))*sh*0.2;sleep,40/170;queuecommand,'Next5');
		Next5Command=cmd(decelerate,40/170;zoomtoheight,tonumber(string.sub(shutters[6],2,2))*sh*0.2;sleep,40/170;queuecommand,'Next6');
		Next6Command=cmd(decelerate,40/170;zoomtoheight,tonumber(string.sub(shutters[7],2,2))*sh*0.2;sleep,40/170;queuecommand,'Next7');
		Next7Command=cmd(decelerate,40/170;zoomtoheight,tonumber(string.sub(shutters[8],2,2))*sh*0.2;sleep,40/170;queuecommand,'Next8');
		Next8Command=cmd(decelerate,40/170;zoomtoheight,tonumber(string.sub(shutters[9],2,2))*sh*0.2;sleep,40/170;queuecommand,'Next9');
		Next9Command=cmd(decelerate,40/170;zoomtoheight,tonumber(string.sub(shutters[10],2,2))*sh*0.2;sleep,40/170;queuecommand,'Stop');
		StopCommand=cmd(sleep,0;diffusealpha,0;stoptweening;);
	};
	Def.Quad {
		OnCommand=cmd(x,cenx;y,sh*0.5;zoomtowidth,sw;diffuse,Black;queuecommand,'Expand');
		ExpandCommand=cmd(sleep,1.0*(10/170);decelerate,40/170;zoomtoheight,sh*0.2;sleep,0;queuecommand,'Next1');
		Next1Command=cmd(decelerate,40/170;zoomtoheight,tonumber(string.sub(shutters[2],3,3))*sh*0.2;sleep,40/170;queuecommand,'Next2');
		Next2Command=cmd(decelerate,40/170;zoomtoheight,tonumber(string.sub(shutters[3],3,3))*sh*0.2;sleep,40/170;queuecommand,'Next3');
		Next3Command=cmd(decelerate,40/170;zoomtoheight,tonumber(string.sub(shutters[4],3,3))*sh*0.2;sleep,40/170;queuecommand,'Next4');
		Next4Command=cmd(decelerate,40/170;zoomtoheight,tonumber(string.sub(shutters[5],3,3))*sh*0.2;sleep,40/170;queuecommand,'Next5');
		Next5Command=cmd(decelerate,40/170;zoomtoheight,tonumber(string.sub(shutters[6],3,3))*sh*0.2;sleep,40/170;queuecommand,'Next6');
		Next6Command=cmd(decelerate,40/170;zoomtoheight,tonumber(string.sub(shutters[7],3,3))*sh*0.2;sleep,40/170;queuecommand,'Next7');
		Next7Command=cmd(decelerate,40/170;zoomtoheight,tonumber(string.sub(shutters[8],3,3))*sh*0.2;sleep,40/170;queuecommand,'Next8');
		Next8Command=cmd(decelerate,40/170;zoomtoheight,tonumber(string.sub(shutters[9],3,3))*sh*0.2;sleep,40/170;queuecommand,'Next9');
		Next9Command=cmd(decelerate,40/170;zoomtoheight,tonumber(string.sub(shutters[10],3,3))*sh*0.2;sleep,40/170;queuecommand,'Stop');
		StopCommand=cmd(sleep,0;diffusealpha,0;stoptweening;);
	};
	Def.Quad {
		OnCommand=cmd(x,cenx;y,sh*0.7;zoomtowidth,sw;diffuse,Black;queuecommand,'Expand');
		ExpandCommand=cmd(sleep,1.5*(10/170);decelerate,40/170;zoomtoheight,sh*0.2;sleep,0;queuecommand,'Next1');
		Next1Command=cmd(decelerate,40/170;zoomtoheight,tonumber(string.sub(shutters[2],4,4))*sh*0.2;sleep,40/170;queuecommand,'Next2');
		Next2Command=cmd(decelerate,40/170;zoomtoheight,tonumber(string.sub(shutters[3],4,4))*sh*0.2;sleep,40/170;queuecommand,'Next3');
		Next3Command=cmd(decelerate,40/170;zoomtoheight,tonumber(string.sub(shutters[4],4,4))*sh*0.2;sleep,40/170;queuecommand,'Next4');
		Next4Command=cmd(decelerate,40/170;zoomtoheight,tonumber(string.sub(shutters[5],4,4))*sh*0.2;sleep,40/170;queuecommand,'Next5');
		Next5Command=cmd(decelerate,40/170;zoomtoheight,tonumber(string.sub(shutters[6],4,4))*sh*0.2;sleep,40/170;queuecommand,'Next6');
		Next6Command=cmd(decelerate,40/170;zoomtoheight,tonumber(string.sub(shutters[7],4,4))*sh*0.2;sleep,40/170;queuecommand,'Next7');
		Next7Command=cmd(decelerate,40/170;zoomtoheight,tonumber(string.sub(shutters[8],4,4))*sh*0.2;sleep,40/170;queuecommand,'Next8');
		Next8Command=cmd(decelerate,40/170;zoomtoheight,tonumber(string.sub(shutters[9],3,3))*sh*0.2;sleep,40/170;queuecommand,'Next9');
		Next9Command=cmd(decelerate,40/170;zoomtoheight,tonumber(string.sub(shutters[10],4,4))*sh*0.2;sleep,40/170;queuecommand,'Stop');
		StopCommand=cmd(sleep,0;diffusealpha,0;stoptweening;);
	};
	Def.Quad {
		OnCommand=cmd(x,cenx;y,sh*0.9;zoomtowidth,sw;diffuse,Black;queuecommand,'Expand');
		ExpandCommand=cmd(sleep,2.0*(10/170);decelerate,40/170;zoomtoheight,sh*0.2;sleep,0;queuecommand,'Next1');
		Next1Command=cmd(decelerate,40/170;zoomtoheight,tonumber(string.sub(shutters[2],5,5))*sh*0.2;sleep,40/170;queuecommand,'Next2');
		Next2Command=cmd(decelerate,40/170;zoomtoheight,tonumber(string.sub(shutters[3],5,5))*sh*0.2;sleep,40/170;queuecommand,'Next3');
		Next3Command=cmd(decelerate,40/170;zoomtoheight,tonumber(string.sub(shutters[4],5,5))*sh*0.2;sleep,40/170;queuecommand,'Next4');
		Next4Command=cmd(decelerate,40/170;zoomtoheight,tonumber(string.sub(shutters[5],5,5))*sh*0.2;sleep,40/170;queuecommand,'Next5');
		Next5Command=cmd(decelerate,40/170;zoomtoheight,tonumber(string.sub(shutters[6],5,5))*sh*0.2;sleep,40/170;queuecommand,'Next6');
		Next6Command=cmd(decelerate,40/170;zoomtoheight,tonumber(string.sub(shutters[7],5,5))*sh*0.2;sleep,40/170;queuecommand,'Next7');
		Next7Command=cmd(decelerate,40/170;zoomtoheight,tonumber(string.sub(shutters[8],5,5))*sh*0.2;sleep,40/170;queuecommand,'Next8');
		Next8Command=cmd(decelerate,40/170;zoomtoheight,tonumber(string.sub(shutters[9],3,3))*sh*0.2;sleep,40/170;queuecommand,'Next9');
		Next9Command=cmd(decelerate,40/170;zoomtoheight,tonumber(string.sub(shutters[10],5,5))*sh*0.2;sleep,40/170;queuecommand,'Stop');
		StopCommand=cmd(sleep,0;diffusealpha,0;stoptweening;);
	};
};

return t;
