local cenx = SCREEN_CENTER_X
local ceny = SCREEN_CENTER_Y
local sw = SCREEN_WIDTH
local sh = SCREEN_HEIGHT
local ratio = PREFSMAN:GetPreference("DisplayAspectRatio")

local P1X, P2X

local fgcurcommand = 0;
local timings = {
	0.700, --rotasion z
	2.700, -- fin rotacionz
	10.610,
	13.277,
	15.277;
	
	49.505,
	50.887,
	52.299,
	53.711,
	55.123,
	56.534,
	57.946,

	
	70.033,
	72.033,
	
	121.033,
	123.033,
	145.700
};

local P1IsQuest = false;
local P2IsQuest = false;
if GAMESTATE:IsSideJoined(PLAYER_1) and GAMESTATE:GetCurrentSteps(PLAYER_1):GetDescription() == "yaminekross d24 UCS" then
	P1IsQuest = true;
end;

if GAMESTATE:IsSideJoined(PLAYER_2) and GAMESTATE:GetCurrentSteps(PLAYER_2):GetDescription() == "yaminekross d24 UCS" then
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
		if P1 then P1:x(math.floor(sw*.5)); end
		if P2 then P2:x(math.floor(sw*.5)); end	
			screen:rotationz(90);
			screen:x(sw);
			screen:y(-(sw-sh)/2);
		end;
		if fgcurcommand == 2 then
		if P1 then P1:x(math.floor(sw*.5)); end
		if P2 then P2:x(math.floor(sw*.5)); end
			screen:rotationz(0);
			screen:x(0);
			screen:y(0);
		end;
		if fgcurcommand == 3 then
		if P1 then P1:x(math.floor(sw*.5)); end
		if P2 then P2:x(math.floor(sw*.5)); end
			screen:rotationz(0);
			screen:x(0);
			screen:y(0);
		end;
		if fgcurcommand == 4 then
		if P1 then P1:x(math.floor(sw*.5)); end
		if P2 then P2:x(math.floor(sw*.5)); end
			screen:rotationz(0);
			screen:x(0);
			screen:y(0);
		end;
		if fgcurcommand == 5 then
		screen:rotationy(0);
		end;
		if fgcurcommand == 6 then
				if P1 then P1:x(math.floor(sw/2)); end
				if P2 then P2:x(math.floor(sw/2)); end			
				screen:rotationz(90);
				screen:x(sw);
				screen:y(-(sw-sh)/2);
		end;
		if fgcurcommand == 7 then
			screen:rotationz(180);
			screen:x(sw);
			screen:y(sh);
		end;
		if fgcurcommand == 8 then
			if not ( P1 and P2 ) then
				if P1 then P1:x(math.floor(sw/2)); end
				if P2 then P2:x(math.floor(sw/2)); end			
				screen:rotationz(270);
				screen:x(0);
				screen:y(sh+((sw-sh)/2));
			end;
		end;
		if fgcurcommand == 9 then
			if P1 then P1:x(P1X); end
			if P2 then P2:x(P2X); end
			screen:rotationz(0);
			screen:x(0);
			screen:y(0);
		end;
		if fgcurcommand == 10 then
			if not ( P1 and P2 ) then
				if P1 then P1:x(math.floor(sw/2)); end
				if P2 then P2:x(math.floor(sw/2)); end
				screen:rotationz(90);
				screen:x(sw);
				screen:y(-(sw-sh)/2);
			end;
		end;
		if fgcurcommand == 11 then
			if not ( P1 and P2 ) then
				if P1 then P1:x(math.floor(sw/2)); end
				if P2 then P2:x(math.floor(sw/2)); end
				screen:rotationz(270);
				screen:x(0);
				screen:y(sh+((sw-sh)/2));
			end;
		end;
		if fgcurcommand == 12 then
			if P1 then P1:x(P1X); end
			if P2 then P2:x(P2X); end
			screen:rotationz(0);
			screen:x(0);
			screen:y(0);
		end;
		if fgcurcommand == 13 then
				if P1 then P1:x(math.floor(sw/2)); end
				if P2 then P2:x(math.floor(sw/2)); end			
				screen:rotationz(270);
				screen:x(0);
				screen:y(sh+((sw-sh)/2));	
		end;
		if fgcurcommand == 14 then
		if P1 then P1:x(math.floor(sw*.5)); end
		if P2 then P2:x(math.floor(sw*.5)); end
			screen:rotationz(0);
			screen:x(0);
			screen:y(0);
		end;
		if fgcurcommand == 15 then
			screen:rotationz(180);
			screen:x(sw);
			screen:y(sh);
		end;
		if fgcurcommand == 16 then
		if P1 then P1:x(math.floor(sw*.5)); end
		if P2 then P2:x(math.floor(sw*.5)); end
			screen:rotationz(0);
			screen:x(0);
			screen:y(0);
		end;
		if fgcurcommand == 17 then
			screen:rotationz(180);
			screen:x(sw);
			screen:y(sh);
			SCREENMAN:GetTopScreen():GetChild('Overlay'):hidden(1);
			SCREENMAN:GetTopScreen():GetChild('Underlay'):hidden(1);
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


t[#t+1] = LoadActor("Flash")..{
	OnCommand=cmd(hibernate,0.700);
}
t[#t+1] = LoadActor("barras")..{
	OnCommand=cmd(hibernate,0.800);
}
t[#t+1] = LoadActor("Flash")..{
	OnCommand=cmd(hibernate,2.700);
}
t[#t+1] = LoadActor("Flash")..{
	OnCommand=cmd(hibernate,70.033);
}
t[#t+1] = LoadActor("Flash")..{
	OnCommand=cmd(hibernate,72.033);
}
t[#t+1] = LoadActor("Flash")..{
	OnCommand=cmd(hibernate,121.033);
}
t[#t+1] = LoadActor("Flash")..{
	OnCommand=cmd(hibernate,123.033);
}
t[#t+1] = LoadActor("vidrio")..{
	OnCommand=cmd(hibernate,26.700);
}
t[#t+1] = LoadActor("blackgimmick")..{
	OnCommand=cmd(hibernate,3.700);
}
t[#t+1] = LoadActor("blackgimmick")..{
	OnCommand=cmd(hibernate,14.367);
}

t[#t+1] = LoadActor("blindbarra")..{
	OnCommand=cmd(hibernate,49.505); --51.075 2.041+0.471
}
t[#t+1] = LoadActor("blindbarra")..{
	OnCommand=cmd(hibernate,50.446);
}
t[#t+1] = LoadActor("blindbarra")..{
	OnCommand=cmd(hibernate,51.858);
}
t[#t+1] = LoadActor("blindbarra")..{
	OnCommand=cmd(hibernate,49.034);
}
t[#t+1] = LoadActor("blindbarra")..{
	OnCommand=cmd(hibernate,53.270);
}
t[#t+1] = LoadActor("blindbarra")..{
	OnCommand=cmd(hibernate,54.681);
}
t[#t+1] = LoadActor("blindbarra")..{
	OnCommand=cmd(hibernate,56.093);
}
t[#t+1] = LoadActor("blindbarra")..{
	OnCommand=cmd(hibernate,57.505);
}
t[#t+1] = LoadActor("whitegimmick")..{
	OnCommand=cmd(hibernate,94.0333);
}

t[#t+1] = LoadActor("whitegimmick")..{
	OnCommand=cmd(hibernate,104.700);
}


return t;