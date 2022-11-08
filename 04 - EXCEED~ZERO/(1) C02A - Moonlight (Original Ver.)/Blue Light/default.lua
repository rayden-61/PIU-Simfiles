local quest_p1 = false;
local quest_p2 = false;

if GAMESTATE:IsSideJoined(PLAYER_1) then
	local steps = GAMESTATE:GetCurrentSteps(PLAYER_1);
	if steps:GetStepsType() == 'StepsType_Pump_Single' and steps:GetDifficulty() == 'Difficulty_Challenge' then
		quest_p1 = true;
	end;
end;
if GAMESTATE:IsSideJoined(PLAYER_2) then
	local steps = GAMESTATE:GetCurrentSteps(PLAYER_2);
	if steps:GetStepsType() == 'StepsType_Pump_Single' and steps:GetDifficulty() == 'Difficulty_Challenge' then
		quest_p2 = true;
	end;
end;

if getenv("MoonlightQuestLoaded") then
	return Def.Actor{};
end;

if quest_p1 and quest_p2 then
	setenv("MoonlightQuestLoaded",true);
end;

local t = Def.ActorFrame {}

if quest_p1 then
	t[#t+1] = Def.Quad {
    OnCommand=cmd(x,SCREEN_WIDTH/4;y,SCREEN_CENTER_Y;scaletoclipped,SCREEN_WIDTH/2,SCREEN_HEIGHT);
    GainFocusCommand=cmd(finishtweening;diffuse,color("#4444FF");diffusealpha,0.9;accelerate,0.25;diffusealpha,0);
};
end;
	
if quest_p2 then
	t[#t+1] = Def.Quad {
    OnCommand=cmd(x,SCREEN_WIDTH*(3/4);y,SCREEN_CENTER_Y;scaletoclipped,SCREEN_WIDTH/2,SCREEN_HEIGHT);
    GainFocusCommand=cmd(finishtweening;diffuse,color("#4444FF");diffusealpha,0.9;accelerate,0.25;diffusealpha,0);
};
end;

if #t > 0 then
	return t;
else
	return Def.Actor{};
end;


