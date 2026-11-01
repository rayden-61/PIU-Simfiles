local nightmare = false;

if GAMESTATE:IsSideJoined(PLAYER_1) then
	local steps = GAMESTATE:GetCurrentSteps(PLAYER_1);
	if steps:GetStepsType() == 'StepsType_Pump_Double' and steps:GetDifficulty() == 'Difficulty_Edit' and steps:GetDescription() == 'D20' then
		nightmare = true;
	end;
elseif GAMESTATE:IsSideJoined(PLAYER_2) then
	local steps = GAMESTATE:GetCurrentSteps(PLAYER_2);
	if steps:GetStepsType() == 'StepsType_Pump_Double' and steps:GetDifficulty() == 'Difficulty_Edit' and steps:GetDescription() == 'D20' then
		nightmare = true;
	end;
end;

if nightmare then
	
	return Def.Quad {    
    InitCommand=cmd(x,SCREEN_CENTER_X;y,SCREEN_CENTER_Y;scaletoclipped,SCREEN_WIDTH*2,SCREEN_HEIGHT*2;);
    OnCommand=cmd(finishtweening;diffusealpha,1;accelerate,0.6;diffusealpha,0);
};

else
	return Def.Actor{};

end;