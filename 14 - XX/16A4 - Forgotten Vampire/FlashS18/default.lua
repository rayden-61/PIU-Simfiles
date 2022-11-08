local single = false;
local player = 0;

if GAMESTATE:IsSideJoined(PLAYER_1) == true and GAMESTATE:IsSideJoined(PLAYER_2) == true then
	local steps1 = GAMESTATE:GetCurrentSteps(PLAYER_1):GetDescription();
	local steps2 = GAMESTATE:GetCurrentSteps(PLAYER_2):GetDescription();
	if steps1 == 'S18' and steps2 == 'S18' then
		single = true;
		player = 3;
	end;
	if steps1 == 'S18' and steps2 ~= 'S18' then
		single = true;
		player = 1;
	end;
	if steps1 ~= 'S18' and steps2 == 'S18' then
		single = true;
		player = 2;
	end;
else
	if GAMESTATE:IsSideJoined(PLAYER_1) then
		local steps = GAMESTATE:GetCurrentSteps(PLAYER_1);
		if steps:GetStepsType() == 'StepsType_Pump_Single' and steps:GetDifficulty() == 'Difficulty_Edit' and steps:GetDescription() == 'S18' then
			single = true;
			player = 1;
		end;
	end;

	if GAMESTATE:IsSideJoined(PLAYER_2) then
		local steps = GAMESTATE:GetCurrentSteps(PLAYER_2);
		if steps:GetStepsType() == 'StepsType_Pump_Single' and steps:GetDifficulty() == 'Difficulty_Edit' and steps:GetDescription() == 'S18' then
			single = true;
			player = 2;
		end;
	end;
end;

if single then
	if player == 1 then
		return Def.Quad {
	    	InitCommand=cmd(x,214;y,SCREEN_CENTER_Y;scaletoclipped,SCREEN_WIDTH*0.5,SCREEN_HEIGHT*2;);
	    	OnCommand=cmd(finishtweening;diffusealpha,1;accelerate,0.6;diffusealpha,0);
	    };
	end;
	if player == 2 then
		return Def.Quad {
	    	InitCommand=cmd(x,640;y,SCREEN_CENTER_Y;scaletoclipped,SCREEN_WIDTH*0.5,SCREEN_HEIGHT*2;);
	    	OnCommand=cmd(finishtweening;diffusealpha,1;accelerate,0.6;diffusealpha,0);
	    };
	end;
	if player == 3 then
		return Def.Quad {
		    InitCommand=cmd(x,SCREEN_CENTER_X;y,SCREEN_CENTER_Y;scaletoclipped,SCREEN_WIDTH*2,SCREEN_HEIGHT*2;);
		    OnCommand=cmd(finishtweening;diffusealpha,1;accelerate,0.6;diffusealpha,0);
		};
	end;
else
	return Def.Actor{};

end;








