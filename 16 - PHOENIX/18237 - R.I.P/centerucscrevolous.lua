local P1IsQuest = false;
local P2IsQuest = false;
if GAMESTATE:IsSideJoined(PLAYER_1) and GAMESTATE:GetCurrentSteps(PLAYER_1):GetDescription() == "D10 UCS CREVOLOUS" then
	P1IsQuest = true;
end;

if GAMESTATE:IsSideJoined(PLAYER_2) and GAMESTATE:GetCurrentSteps(PLAYER_2):GetDescription() == "D10 UCS CREVOLOUS" then
	P2IsQuest = true;
end;

if (GAMESTATE:IsSideJoined(PLAYER_1) and not P1IsQuest) or (GAMESTATE:IsSideJoined(PLAYER_2) and not P2IsQuest) then
	return Def.Actor{};
end;

local sw = SCREEN_WIDTH
local sh = SCREEN_HEIGHT
local t = Def.ActorFrame {}
local ratio = PREFSMAN:GetPreference("DisplayAspectRatio")
local sw = SCREEN_WIDTH
local sh = SCREEN_HEIGHT
local screen = SCREENMAN:GetTopScreen();
 --rotations are x y and z
t[#t+1] = Def.ActorFrame {
	OnCommand=cmd(x,9999;sleep,999)	
};

t[#t+1] = Def.ActorFrame {
	OnCommand=function(self)
		local P1 = SCREENMAN:GetTopScreen():GetChild('PlayerP1');
		local P2 = SCREENMAN:GetTopScreen():GetChild('PlayerP2');
		if P1 then P1:x(math.floor(sw*0.648)); end
		if P2 then P2:x(math.floor(sw*0.648)); end
	end;
};

return t;