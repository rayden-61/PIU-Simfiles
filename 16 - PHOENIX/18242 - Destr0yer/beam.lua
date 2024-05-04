local P1IsQuest = false;
local P2IsQuest = false;
if GAMESTATE:IsSideJoined(PLAYER_1) and GAMESTATE:GetCurrentSteps(PLAYER_1):GetDescription() == 'D24' then
	P1IsQuest = true;
end;

if GAMESTATE:IsSideJoined(PLAYER_2) and GAMESTATE:GetCurrentSteps(PLAYER_2):GetDescription() == 'D24' then
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
t[#t+1] = Def.ActorFrame {
	OnCommand=cmd(x,9999;sleep,999)	
};

t[#t+1] = Def.ActorFrame {
	OnCommand=function(self)
		local screen = SCREENMAN:GetTopScreen();
		local P1 = SCREENMAN:GetTopScreen():GetChild('PlayerP1');
		local P2 = SCREENMAN:GetTopScreen():GetChild('PlayerP2');
			if (ratio > 1.5) then
				if P1 then P1:x(math.floor(sw*.84));P1:y(math.floor(sh*.50));P1:rotationz(90); end
				if P2 then P2:x(math.floor(sw*.84));P2:y(math.floor(sh*.50));P2:rotationz(90); end
				
			else
			
		if P1 then P1:x(math.floor(sw*.84));P1:y(math.floor(sh*.50));P2:rotationz(90); end
		if P2 then P2:x(math.floor(sw*.84));P2:y(math.floor(sh*.50));P2:rotationz(90); end
				
		end;

	end;
};

return t;