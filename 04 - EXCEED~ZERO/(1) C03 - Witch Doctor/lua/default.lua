if GAMESTATE:GetCurrentSteps(GAMESTATE:GetMasterPlayerNumber()):GetChartName() ~= '3PlayerLev21' or GAMESTATE:GetCurrentSteps(GAMESTATE:GetMasterPlayerNumber()):GetAuthorCredit() ~= 'KahruNYA' then
	return Def.ActorFrame{}
end

local song_path= GAMESTATE:GetCurrentSong():GetSongDir()

-- Gets the Current Rate Mod
function wd_GetRateMod()
	
	--if true then return 0.5 end;
	
	--GAMESTATE:GetSongOptionsObject("ModsLevel_Song"):MusicRate()
	local so = GAMESTATE:GetSongOptions('ModsLevel_Song');
	Trace(so);
	local s = '';
	if not so then return 1.0 else s = so end
	if not s then return 1.0 end;
	
	local fbegin = string.find(s,'.',1,true);
	local fend = string.find(s,'xMusic');
	if fbegin and fend then
		return tonumber(string.sub(s,fbegin-1,fend-1));
	else
		return 1.0;
	end
	
	--TODO check if this works
	--return 1.0
	
end

RATEMOD = wd_GetRateMod()

local function wd_init()
	fgcurcommand = 0;
	checked = false;
	--self:queuecommand('Update');
	
	--lua course :D	/ timed mod management	
	curmod = 1;
	--{time(seconds),mod,player}
	mods = {

	}
	
	curaction = 1;
	--{beat,message,persists}
	actions = {
		{60-4,'MiddleOn'},
		{100-4,'MiddleOff'},
		{204-4,'MiddleOn'},
	}
	
	function time_compare(a,b)
		return a[1] < b[1]
	end
	
	if table.getn(mods) > 1 then
		table.sort(mods, time_compare)
	end
	
	if table.getn(actions) > 1 then
		table.sort(actions, time_compare)
	end
	
end

mod_firstSeenBeat = GAMESTATE:GetSongBeat()

local function wd_update(self, delta)
	if GAMESTATE:GetSongBeat()>0 and not checked then
		
		P1 = SCREENMAN:GetTopScreen():GetChild('PlayerP1');
		P2 = SCREENMAN:GetTopScreen():GetChild('PlayerP2');
		
		for pn=1,2 do
			local a = _G['P'..pn]
			if a then
				a:zoom(1);
				a:y(0);
				a:rotationz(0);
				a:zoomz(1)
			end
		end
		
		screen = SCREENMAN:GetTopScreen();
		checked = true;
		
	end
	
	local beat = GAMESTATE:GetSongBeat()
	
---------------------------------------------------------------------------------------
----------------------DON'T TOUCH IT KIDDO---------------------------------------------
---------------------------------------------------------------------------------------
	
	--custom mod reader (c) 2014 #taronuke #yolo #swag #swag #amazon.co.jp #teamproofofconcept #swag
	while curmod<= #mods and GAMESTATE:GetSongBeat()>=mods[curmod][1] do
		for i=1,2 do
			local pn= 'PlayerNumber_P' .. i
			local ps= GAMESTATE:GetPlayerState(pn)
			local pmods= ps:GetPlayerOptionsString('ModsLevel_Song')
			ps:SetPlayerOptions('ModsLevel_Song', pmods .. ', ' .. mods[curmod][2])
		end
		curmod = curmod+1;
	end
	
	while curaction<=table.getn(actions) and GAMESTATE:GetSongBeat()>=actions[curaction][1] do
		if actions[curaction][3] or GAMESTATE:GetSongBeat() < actions[curaction][1]+2 then
			if type(actions[curaction][2]) == 'function' then
				actions[curaction][2]()
			elseif type(actions[curaction][2]) == 'string' then
				Trace('Message: '..actions[curaction][2]);
				MESSAGEMAN:Broadcast(actions[curaction][2]);
			end
		end
		curaction = curaction+1;
	end

---------------------------------------------------------------------------------------
----------------------END DON'T TOUCH IT KIDDO-----------------------------------------
---------------------------------------------------------------------------------------
end

local t = Def.ActorFrame{
	OnCommand= function(self)
		 songName = GAMESTATE:GetCurrentSong():GetSongDir();
		 wd_init()
		 --self:SetUpdateFunction(wd_update)
	 end,
	Def.Quad{
		OnCommand=cmd(visible,false;sleep,1000);
	},
	Def.BitmapText{
		Font="Common Normal";
		OnCommand=cmd(Center;queuecommand,"Update");
		UpdateCommand=function(self)
			--self:settext((curaction or "nil!").."/"..table.getn(actions).."\n"..GAMESTATE:GetSongBeat());
			wd_update();
			self:sleep(0.02);
			self:queuecommand("Update");
		end;
	};
	LoadActor('arrow')..{
		OnCommand=cmd(Center;y,SCREEN_CENTER_Y+80;zoom,0.6;diffusealpha,0;animate,0;bob;effectperiod,0.4;effectmagnitude,0,8,0;);
		MiddleOnMessageCommand=cmd(setstate,0;linear,0.3;diffusealpha,1;sleep,7*60/190;linear,0.3;diffusealpha,0);
		MiddleOffMessageCommand=cmd(setstate,1;linear,0.3;diffusealpha,1;sleep,7*60/190;linear,0.3;diffusealpha,0);
	},
	Def.Quad{
		OnCommand=cmd(x,SCREEN_CENTER_X;y,SCREEN_CENTER_Y;zoomto,SCREEN_WIDTH,SCREEN_HEIGHT;diffuse,0,0,0,0),
		WhiteFlashLongMessageCommand=cmd(diffuse,1,1,1,1.04;linear,2/RATEMOD;diffusealpha,0),
		WhiteFlashMessageCommand=cmd(diffuse,1,1,1,1;linear,1/RATEMOD;diffusealpha,0),
		WhiteFlashQMessageCommand=cmd(diffuse,1,1,1,0.4;linear,0.6/RATEMOD;diffusealpha,0),
		WhiteFlashMMessageCommand=cmd(finishtweening;diffuse,1,1,1,0.8;linear,0.8/RATEMOD;diffusealpha,0),
	},
}

return t
