local cenx = SCREEN_CENTER_X
local ceny = SCREEN_CENTER_Y
local sw = SCREEN_WIDTH
local sh = SCREEN_HEIGHT

local P1X, P2X

local fgcurcommand = 0;
local timings = {
	10,
	11.987,
	13.399,
	14.811,
	51.546,
	52.928,
	54.340,
	55.752,
	57.164,
	58.575,
	59.987
};

local P1IsQuest = false;
local P2IsQuest = false;

if GAMESTATE:IsSideJoined(PLAYER_1) and GAMESTATE:GetCurrentSteps(PLAYER_1):GetAuthorCredit() == "TaroNuke" then
	P1IsQuest = true;
end;

if GAMESTATE:IsSideJoined(PLAYER_2) and GAMESTATE:GetCurrentSteps(PLAYER_2):GetAuthorCredit() == "TaroNuke" then
	P2IsQuest = true;
end;

if (GAMESTATE:IsSideJoined(PLAYER_1) and not P1IsQuest) or (GAMESTATE:IsSideJoined(PLAYER_2) and not P2IsQuest) then
	return Def.Actor{};
end;

local t = Def.ActorFrame {}

t[#t+1] = Def.ActorFrame {
	OnCommand=cmd(x,9999;sleep,999)
};

t[#t+1] = Def.ActorFrame {
	OnCommand=function(self)
		fgcurcommand = 0;
		self:queuecommand('Update');
	end;
	UpdateCommand=function(self)
		local screen = SCREENMAN:GetTopScreen();
		local P1 = SCREENMAN:GetTopScreen():GetChild('PlayerP1');
		local P2 = SCREENMAN:GetTopScreen():GetChild('PlayerP2');
		
		if fgcurcommand == 0 then
			if P1 then P1X = P1:GetX(); end;
			if P2 then P2X = P2:GetX(); end;
		end;
		if fgcurcommand == 1 then
			screen:rotationz(0);
			screen:x(0);
			screen:y(0);
		end;
		if fgcurcommand == 2 then
			if not ( P1 and P2 ) then
				if P1 then P1:x(math.floor(sw*.35)); end
				if P2 then P2:x(math.floor(sw*.65)); end
			end
		end;
		if fgcurcommand == 3 then
			if not ( P1 and P2 ) then
				if P1 then P1:x(math.floor(sw*.45)); end
				if P2 then P2:x(math.floor(sw*.55)); end
			end;
		end;
		if fgcurcommand == 4 then
		--[[
			if P1 then P1:x(math.floor(sw*.25)); end
			if P2 then P2:x(math.floor(sw*.75)); end
		]]--
			if P1 then P1:x(P1X); end
			if P2 then P2:x(P2X); end
		end;
		if fgcurcommand == 5 then
			if not ( P1 and P2 ) then
				if P1 then P1:x(math.floor(sw/2)); end
				if P2 then P2:x(math.floor(sw/2)); end			
				screen:rotationz(90);
				screen:x(sw);
				screen:y(-(sw-sh)/2);
			end;
		end;
		if fgcurcommand == 6 then
			screen:rotationz(180);
			screen:x(sw);
			screen:y(sh);
		end;
		if fgcurcommand == 7 then
			if not ( P1 and P2 ) then
				if P1 then P1:x(math.floor(sw/2)); end
				if P2 then P2:x(math.floor(sw/2)); end			
				screen:rotationz(270);
				screen:x(0);
				screen:y(sh+((sw-sh)/2));
			end;
		end;
		if fgcurcommand == 8 then
		--[[
			if P1 then P1:x(math.floor(sw*.25)); end
			if P2 then P2:x(math.floor(sw*.75)); end
		]]--
			if P1 then P1:x(P1X); end
			if P2 then P2:x(P2X); end
			screen:rotationz(0);
			screen:x(0);
			screen:y(0);
		end;
		if fgcurcommand == 9 then
			if not ( P1 and P2 ) then
				if P1 then P1:x(math.floor(sw/2)); end
				if P2 then P2:x(math.floor(sw/2)); end
				screen:rotationz(90);
				screen:x(sw);
				screen:y(-(sw-sh)/2);
			end;
		end;
		if fgcurcommand == 10 then
			if not ( P1 and P2 ) then
				if P1 then P1:x(math.floor(sw/2)); end
				if P2 then P2:x(math.floor(sw/2)); end
				screen:rotationz(270);
				screen:x(0);
				screen:y(sh+((sw-sh)/2));
			end;
		end;
		if fgcurcommand == 11 then
		--[[
			if P1 then P1:x(math.floor(sw*.25)); end
			if P2 then P2:x(math.floor(sw*.75)); end
		]]--
			if P1 then P1:x(P1X); end
			if P2 then P2:x(P2X); end
			screen:rotationz(0);
			screen:x(0);
			screen:y(0);
			self:stoptweening();
			return;
		end;
		
		fgcurcommand = fgcurcommand+1;
		if fgcurcommand == 1 then
			self:sleep(timings[fgcurcommand]);
			self:queuecommand('Update');
		else
			self:sleep(timings[fgcurcommand]-timings[fgcurcommand-1]);
			self:queuecommand('Update');
		end;

	end;
};

t[#t+1] = LoadActor("blinds_ud")..{
	OnCommand=cmd(hibernate,5.899);
}
t[#t+1] = LoadActor("blinds_du")..{
	OnCommand=cmd(hibernate,7.311);
}
t[#t+1] = LoadActor("blinds_ud")..{
	OnCommand=cmd(hibernate,8.722);
}
t[#t+1] = LoadActor("blinds_du")..{
	OnCommand=cmd(hibernate,5.647+5.899);
}
t[#t+1] = LoadActor("blinds_ud")..{
	OnCommand=cmd(hibernate,5.647+7.311);
}
t[#t+1] = LoadActor("blinds_stay1")..{
	OnCommand=cmd(hibernate,5.647+8.722);
}
t[#t+1] = LoadActor("blinds_gimmick")..{
	OnCommand=cmd(hibernate,39.781);
}
t[#t+1] = LoadActor("blinds_du")..{
	OnCommand=cmd(hibernate,51.075);
}
t[#t+1] = LoadActor("blinds_du")..{
	OnCommand=cmd(hibernate,52.487);
}
t[#t+1] = LoadActor("blinds_du")..{
	OnCommand=cmd(hibernate,53.899);
}
t[#t+1] = LoadActor("blinds_du")..{
	OnCommand=cmd(hibernate,51.075);
}
t[#t+1] = LoadActor("blinds_du")..{
	OnCommand=cmd(hibernate,55.311);
}
t[#t+1] = LoadActor("blinds_du")..{
	OnCommand=cmd(hibernate,56.722);
}
t[#t+1] = LoadActor("blinds_du")..{
	OnCommand=cmd(hibernate,58.134);
}
t[#t+1] = LoadActor("blinds_stay2")..{
	OnCommand=cmd(hibernate,59.546);
}

return t;