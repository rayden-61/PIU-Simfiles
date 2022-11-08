local function vv_init()
	checked = false;
	--self:queuecommand('Update');
	
	curaction = 1;
	--{beat,message,persists}
	actions = {
		{5,"Test"},
		{66,'Brief'},
		{232,'FUCK'},
	}
	
	function time_compare(a,b)
		return a[1] < b[1]
	end
	
	if table.getn(actions) > 1 then
		table.sort(actions, time_compare)
	end
	
end

mod_firstSeenBeat = GAMESTATE:GetSongBeat()

local function vv_update(self, delta)
	--[[if GAMESTATE:GetSongBeat()>0 and not checked then
		
		P1 = SCREENMAN:GetTopScreen():GetChild('PlayerP1');
		P2 = SCREENMAN:GetTopScreen():GetChild('PlayerP2');
		
		for pn=1,2 do
			local a = _G['P'..pn]
			if a then
				a:zoom(1);
				a:y(SCREEN_CENTER_Y);
				a:rotationz(0);
				a:zoomz(1)
			end
		end
		
		screen = SCREENMAN:GetTopScreen();
		checked = true;
		
	end]]
	
	local beat = GAMESTATE:GetSongBeat()
	
	while curaction<=table.getn(actions) and GAMESTATE:GetSongBeat()>=actions[curaction][1] do
		if actions[curaction][3] or GAMESTATE:GetSongBeat() < actions[curaction][1]+2 then
			MESSAGEMAN:Broadcast(actions[curaction][2]);
		end
		curaction = curaction+1;
	end
---------------------------------------------------------------------------------------
----------------------END DON'T TOUCH IT KIDDO-----------------------------------------
---------------------------------------------------------------------------------------
end

local sw = SCREEN_WIDTH;
local sh = SCREEN_HEIGHT;

local t = Def.ActorFrame{}

local onephil = false;

if GAMESTATE:IsPlayerEnabled(PLAYER_1) and GAMESTATE:GetCurrentSteps(PLAYER_1):GetAuthorCredit() == 'ZELLLOOO' then onephil = true end
if GAMESTATE:IsPlayerEnabled(PLAYER_2) and GAMESTATE:GetCurrentSteps(PLAYER_2):GetAuthorCredit() == 'ZELLLOOO' then onephil = true end


--Debugging
--[[t[#t+1] = Def.ActorFrame{
	OnCommand=cmd(sleep,1000);
	Def.BitmapText{
		Font="Common Normal";
		OnCommand=cmd(Center;queuecommand,"Update";);
		UpdateCommand=function(self)
			self:settext((curaction or "nil!").."/"..table.getn(actions).."\n"..GAMESTATE:GetSongBeat());
			self:sleep(0.02);
			vv_update();
			self:queuecommand("Update");
		end;
	};
}]]

if onephil == false then
	t[#t+1] = Def.ActorFrame{
		OnCommand= function(self)
			 songName = GAMESTATE:GetCurrentSong():GetSongDir();
			 vv_init()
			 --self:SetUpdateFunction(vv_update)
		 end,
		Def.Quad{
			OnCommand=cmd(visible,false;sleep,1000);
		},
		Def.BitmapText{
			Font="Common Normal";
			OnCommand=cmd(Center;queuecommand,"Update";);
			UpdateCommand=function(self)
				--self:settext((curaction or "nil!").."/"..table.getn(actions).."\n"..GAMESTATE:GetSongBeat());
				self:sleep(0.02);
				vv_update();
				self:queuecommand("Update");
			end;
		};
		LoadActor('maria')..{
			OnCommand=cmd(Center;zoomto,SCREEN_WIDTH,SCREEN_HEIGHT;diffusealpha,0;);
			BriefMessageCommand=cmd(blend,'BlendMode_Add';linear,0.3;diffusealpha,1;linear,1;diffusealpha,0);
			SlowMessageCommand=cmd(blend,'BlendMode_Add';linear,32*60/192;diffusealpha,1.3;linear,1;diffusealpha,0);
		},
		Def.ActorFrame{
			FUCKMessageCommand=cmd(Center;pulse;addx,10;effectperiod,0.036;effectmagnitude,1,1.25,0;playcommand,'Oh');
			LoadActor('black')..{
				OnCommand=cmd(zoomto,SCREEN_WIDTH,SCREEN_HEIGHT;diffusealpha,0;);
				OhCommand=cmd(linear,.4;diffusealpha,1;sleep,0.6;linear,0.5;diffusealpha,0;);
			},

			LoadActor('maria')..{
				OnCommand=cmd(zoomto,SCREEN_WIDTH,SCREEN_HEIGHT;diffusealpha,0;);
				OhCommand=cmd(blend,'BlendMode_Add';diffusealpha,0.6;diffuseblink;effectperiod,0.04;effectcolor1,1,1,1,0;effectcolor2,1,1,1,0.8;
				sleep,0.4;zoomto,sw*1.5,sh*1.5;diffusealpha,1.3;sleep,0.6;zoomto,sw*1.1,sh*1.1;rotationz,0;diffusealpha,0.4;sleep,0.5;diffusealpha,0;);
			},
		},
	}
end

return t
