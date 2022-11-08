local youknowwhyirequire = false;

if GAMESTATE:IsSideJoined(PLAYER_1) then
	local steps = GAMESTATE:GetCurrentSteps(PLAYER_1);
	if steps:GetStepsType() == 'StepsType_Pump_Single' and steps:GetDifficulty() == 'Difficulty_Challenge' then
		youknowwhyirequire = true;
	end;
elseif GAMESTATE:IsSideJoined(PLAYER_2) then
	local steps = GAMESTATE:GetCurrentSteps(PLAYER_2);
	if steps:GetStepsType() == 'StepsType_Pump_Single' and steps:GetDifficulty() == 'Difficulty_Challenge' then
		youknowwhyirequire = true;
	end;
end;

if youknowwhyirequire then

return Def.Quad {    
    InitCommand=cmd(x,SCREEN_CENTER_X;y,SCREEN_CENTER_Y;scaletoclipped,SCREEN_WIDTH*2,SCREEN_HEIGHT*2;);
    OnCommand=cmd(finishtweening;diffusealpha,1;accelerate,0.3;diffusealpha,0);
};

else
	return Def.Actor{};

end;