local nightmare = false;

if GAMESTATE:IsSideJoined(PLAYER_1) then
	local steps = GAMESTATE:GetCurrentSteps(PLAYER_1);
	if steps:GetStepsType() == 'StepsType_Pump_Double' and steps:GetDifficulty() == 'Difficulty_Hard' then
		nightmare = true;
	end;
elseif GAMESTATE:IsSideJoined(PLAYER_2) then
	local steps = GAMESTATE:GetCurrentSteps(PLAYER_2);
	if steps:GetStepsType() == 'StepsType_Pump_Double' and steps:GetDifficulty() == 'Difficulty_Hard' then
		nightmare = true;
	end;
end;

if nightmare then
	return LoadActor("PE353_2-wide.png")..{
		OnCommand=cmd(Center);
	}
end;


return LoadActor("PE353-wide.png")..{
	OnCommand=cmd(Center);
}

	