local sw = SCREEN_WIDTH
local sh = SCREEN_HEIGHT
local cw = math.floor(sw/2);
local ch = math.floor(sh/2);

mawaru_ratings = {0,0}
mawaru_message = {'',''}
mawaru_mcol = {0,0}

mawaru_meter1 = 0;
mawaru_meter2 = 0;

mawaru_mine_amts = {{0,0},{0,0}}

-- Gets the Current Rate Mod
function mawaru_GetRateMod()
	
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

RATEMOD = mawaru_GetRateMod()

function add_ratings(pn,ratings)
	mawaru_ratings[pn] = mawaru_ratings[pn]+ratings
end

mawaru_24thmisses = {0,0}
mawaru_countjudgments = {{0,0,0,0,0,0,0,0,0,0,mines = 0,cb = 0},{0,0,0,0,0,0,0,0,0,0,mines = 0,cb = 0}}
function mawaru_resetjcount()
	mawaru_countjudgments = {{0,0,0,0,0,0,0,0,0,0,mines = 0,cb = 0},{0,0,0,0,0,0,0,0,0,0,mines = 0,cb = 0}}
	mawaru_24thmisses = {0,0}
end

local stats;
local combo = 0;
local flag = 0;
local goalmet = false;

function mawaru_dist(x1,y1,x2,y2)
	return math.sqrt(((x2-x1)*(x2-x1))+((y2-y1)*(y2-y1)));
end

if GAMESTATE:IsPlayerEnabled('PlayerNumber_P1') then
	mawaru_meter1 = GAMESTATE:GetCurrentSteps('PlayerNumber_P1'):GetMeter()
end
if GAMESTATE:IsPlayerEnabled('PlayerNumber_P2') then
	mawaru_meter2 = GAMESTATE:GetCurrentSteps('PlayerNumber_P2'):GetMeter()
end

aspect = sw/sh

mod_firstSeenBeat = GAMESTATE:GetSongBeat();

mawaru_thisgame = 1;

P1 = nil
P2 = nil

mawaru_displayBPM = 130;
mawaru_displayBPMmax = 130;

local function mawaru_mod(str,pn)
	if pn then
		pn= 'PlayerNumber_P' .. pn
		local ps= GAMESTATE:GetPlayerState(pn)
		local pmods= ps:GetPlayerOptionsString('ModsLevel_Song')
		ps:SetPlayerOptions('ModsLevel_Song', pmods .. ', ' .. str)
	else
		for i=1,2 do
			pn= 'PlayerNumber_P' .. i
			local ps= GAMESTATE:GetPlayerState(pn)
			local pmods= ps:GetPlayerOptionsString('ModsLevel_Song')
			ps:SetPlayerOptions('ModsLevel_Song', pmods .. ', ' .. str)
		end
	end
end

function Sound(str)
	local songName = GAMESTATE:GetCurrentSong():GetSongDir();
	SOUND:PlayOnce(songName..'lua/sounds/'..str);
end

local t = Def.ActorFrame{OnCommand=cmd(fov,20)}

dm_curnote = {1,1}
dm_speedmod = {3,3}
--[[if GAMESTATE:IsPlayerEnabled(PLAYER_1) then
	dm_speedmod[1] = GAMESTATE:GetPlayerState(PLAYER_1):GetCurrentPlayerOptions():GetXMod()
end
if GAMESTATE:IsPlayerEnabled(PLAYER_2) then
	dm_speedmod[2] = GAMESTATE:GetPlayerState(PLAYER_2):GetCurrentPlayerOptions():GetXMod()
end]]

LoadActor('brain/chart.lua');

dm_p1pos = -1000
dm_p2pos = -1000

dm_dur = 6;

dm_tqp1 = 1
dm_tqp2 = 1

dm_curquestion = 1
dm_questiontiming = {99,107}
dm_curq_note = {1,1}

dm_score = {0,0};

dm_myanswer = {-1,-1}

dm_notes = {{},{},{},{},{}}
dm_holdbody = {{},{},{},{},{}}
dm_holdbottom = {{},{},{},{},{}}
dm_brain = {}
dm_ptr = 1;

dm_flash = {}
dm_fptr = 1;

beat = 0;

dm_num_notes = 50;
dm_bpm = 128;
dm_bl = 60/128

dm_ypos = SCREEN_HEIGHT*68/480

dm_notedata1 = {{999,0,1}}
dm_notedata2 = {{999,0,1}}

function dm_spawnf(col,pn)

	col = col+1

	local a = dm_flash[dm_fptr]
	
	local x = ((col-3)*51)+(_G['dm_p'..pn..'pos'])
	
	if a then
		a:visible(true)
		a:x(x)
		a:y(dm_ypos)
		a:playcommand('Glow');
	end

	dm_fptr = dm_fptr+1
	if dm_fptr > table.getn(dm_flash) then
		dm_fptr = 1
	end
end

function dm_spawn(targ,col,hold,dur,pn)
	local beat = ((GAMESTATE:GetCurMusicSeconds()+5.274)/(60/128))*RATEMOD
	targ = targ-0.05
	
	if hold == 'M' then
		return
	end
	
	col = col+1
	
	local x = ((col-3)*51)+(_G['dm_p'..pn..'pos'])
	local y = dm_ypos + (dm_dur*64*dm_speedmod[pn])
	
	local a = nil
	local b = nil
	local c = nil
	local height = 0;
	
	if hold == 'B' then
		a = dm_brain[dm_ptr]
	else
		a = dm_notes[col][dm_ptr]
	end
	
	if hold == 2 then
		b = dm_holdbody[col][dm_ptr]
		c = dm_holdbottom[col][dm_ptr]
		height = dm_speedmod[pn]*64*dur
	end
	
	if a then
		a:finishtweening();
		if hold == 'B' then
			if dur>-1 then
				a:setstate(dur);
				a:visible(true);
				a:aux(col);
			else
				a:visible(false);
			end
		else
			a:visible(true);
		end
		a:x(x);
		a:y(y);
		a:linear(dm_dur*dm_bl/RATEMOD)
		a:y(dm_ypos);
		if hold == 2 then
			a:sleep(dm_bl*dur/RATEMOD);
		end
		if hold == 'B' then
			a:linear(dm_bl*2/RATEMOD);
			a:addy(-128*dm_speedmod[pn]);
		end
		a:queuecommand('Hide');
	end
	
	if b then
		if height > 64 then
			b:finishtweening();
			b:valign(0);
			b:visible(true);
			b:zoomtoheight(height-32)
			b:x(x);
			b:y(y);
			b:linear(dm_bl*dm_dur/RATEMOD)
			b:y(dm_ypos);
			b:linear(dm_bl*(dur-(0.5/dm_speedmod[pn]))/RATEMOD);
			b:zoomtoheight(0);
			b:queuecommand('Hide');
		end
	end
	
	if c then
		c:finishtweening();
		c:visible(true);
		c:valign(0);
		c:x(x);
		c:y(y+height-32);
		c:croptop(math.min((-dm_speedmod[pn]*(height-64))/64,0));
		c:linear(dm_bl*(dm_dur)/RATEMOD)
		c:y(dm_ypos+height-32);
		c:linear(dm_bl*(dur)/RATEMOD)
		c:y(dm_ypos-32);
		c:croptop(0.5);
		c:queuecommand('Hide');
	end
	
	dm_ptr = dm_ptr+1
	if dm_ptr>dm_num_notes then
		dm_ptr = 1;
	end
end

for i=1,dm_num_notes do
	t[#t+1] = LoadActor("brain/dl_b")..{
		OnCommand=cmd(visible,false;),
		SetMeMessageCommand=function(self) table.insert(dm_holdbottom[1],self); end,
		HideCommand=cmd(visible,false;)
	}
	t[#t+1] = LoadActor("brain/ul_b")..{
		OnCommand=cmd(visible,false;),
		SetMeMessageCommand=function(self) table.insert(dm_holdbottom[2],self); end,
		HideCommand=cmd(visible,false;)
	}
	t[#t+1] = LoadActor("brain/c_b")..{
		OnCommand=cmd(visible,false;),
		SetMeMessageCommand=function(self) table.insert(dm_holdbottom[3],self); end,
		HideCommand=cmd(visible,false;)
	}
	t[#t+1] = LoadActor("brain/ur_b")..{
		OnCommand=cmd(visible,false;),
		SetMeMessageCommand=function(self) table.insert(dm_holdbottom[4],self); end,
		HideCommand=cmd(visible,false;)
	}
	t[#t+1] = LoadActor("brain/dr_b")..{
		OnCommand=cmd(visible,false;),
		SetMeMessageCommand=function(self) table.insert(dm_holdbottom[5],self); end,
		HideCommand=cmd(visible,false;)
	}
	t[#t+1] = LoadActor("brain/dl_m")..{
		OnCommand=cmd(visible,false;),
		SetMeMessageCommand=function(self) table.insert(dm_holdbody[1],self); end,
		HideCommand=cmd(visible,false;)
	}
	t[#t+1] = LoadActor("brain/ul_m")..{
		OnCommand=cmd(visible,false;),
		SetMeMessageCommand=function(self) table.insert(dm_holdbody[2],self); end,
		HideCommand=cmd(visible,false;)
	}
	t[#t+1] = LoadActor("brain/c_m")..{
		OnCommand=cmd(visible,false;),
		SetMeMessageCommand=function(self) table.insert(dm_holdbody[3],self); end,
		HideCommand=cmd(visible,false;)
	}
	t[#t+1] = LoadActor("brain/ur_m")..{
		OnCommand=cmd(visible,false;),
		SetMeMessageCommand=function(self) table.insert(dm_holdbody[4],self); end,
		HideCommand=cmd(visible,false;)
	}
	t[#t+1] = LoadActor("brain/dr_m")..{
		OnCommand=cmd(visible,false;),
		SetMeMessageCommand=function(self) table.insert(dm_holdbody[5],self); end,
		HideCommand=cmd(visible,false;)
	}
	t[#t+1] = LoadActor("brain/dl_t")..{
		OnCommand=cmd(visible,false;),
		SetMeMessageCommand=function(self) table.insert(dm_notes[1],self); end,
		HideCommand=cmd(visible,false;)
	}
	t[#t+1] = LoadActor("brain/ul_t")..{
		OnCommand=cmd(visible,false;),
		SetMeMessageCommand=function(self) table.insert(dm_notes[2],self); end,
		HideCommand=cmd(visible,false;)
	}
	t[#t+1] = LoadActor("brain/c_t")..{
		OnCommand=cmd(visible,false;),
		SetMeMessageCommand=function(self) table.insert(dm_notes[3],self); end,
		HideCommand=cmd(visible,false;)
	}
	t[#t+1] = LoadActor("brain/ul_t")..{
		OnCommand=cmd(visible,false;basezoomx,-1;),
		SetMeMessageCommand=function(self) table.insert(dm_notes[4],self); end,
		HideCommand=cmd(visible,false;)
	}
	t[#t+1] = LoadActor("brain/dl_t")..{
		OnCommand=cmd(visible,false;basezoomx,-1;),
		SetMeMessageCommand=function(self) table.insert(dm_notes[5],self); end,
		HideCommand=cmd(visible,false;)
	}
	t[#t+1] = LoadActor("brain/brainshower")..{
		OnCommand=cmd(visible,false;animate,false;),
		SetMeMessageCommand=function(self) table.insert(dm_brain,self); end,
		HideCommand=cmd(visible,false;)
	}
	t[#t+1] = Def.ActorFrame{
		OnCommand=cmd(),
		SetMeMessageCommand=function(self) table.insert(dm_flash,self); end,
		LoadActor("brain/_Tap Explosion Bright") .. {
			Frames = Sprite.LinearFrames( 5, 0.28);
			InitCommand=cmd(visible,false;animate,false;blend,"BlendMode_Add";diffusealpha,0;zoom,0.975);
			GlowCommand=cmd(stoptweening;visible,true;setstate,0;diffusealpha,1;sleep,0.28;diffusealpha,0;queuecommand,'Hide'),
			HideCommand=cmd(visible,false;)
		},
		LoadActor("brain/_Tap Explosion Bright") .. {
			Frames = Sprite.LinearFrames( 5, 0.28);
			InitCommand=cmd(visible,false;animate,false;blend,"BlendMode_Add";diffusealpha,0;zoom,1.2);
			GlowCommand=cmd(stoptweening;visible,true;setstate,0;diffusealpha,0;linear,0.075;diffusealpha,1;sleep,0.28;diffusealpha,0;queuecommand,'Hide'),
			HideCommand=cmd(visible,false;)
		},
		LoadActor("brain/emptyq") .. {
			InitCommand=cmd(visible,false;blend,"BlendMode_Add";diffusealpha,0;);
			GlowCommand=cmd(stoptweening;visible,true;diffusealpha,1;zoom,1;linear,0.2;zoom,1.075;linear,0.1;diffusealpha,0;queuecommand,'Hide');
			HideCommand=cmd(visible,false;)
		},
		LoadActor("brain/emptyq") .. {
			InitCommand=cmd(visible,false;blend,"BlendMode_Add";diffusealpha,0;);
			GlowCommand=cmd(stoptweening;visible,true;diffusealpha,0;zoom,1;diffusealpha,1;linear,0.25;zoom,1.4;linear,0.1;diffusealpha,0;queuecommand,'Hide');
			HideCommand=cmd(visible,false;)
		}
	}

end

t[#t+1] = LoadActor("brain/quiz");

t[#t+1] = LoadActor("grade")..{
	OnCommand=cmd(diffusealpha,0;animate,0;y,SCREEN_HEIGHT*0.4),
	GoodP1MessageCommand=cmd(setstate,1;queuecommand,"Flash");
	WrongP1MessageCommand=cmd(setstate,0;queuecommand,"Flash");
	FlashCommand=cmd(x,dm_p1pos;diffusealpha,1;sleep,0.1;diffusealpha,0;sleep,0.1;diffusealpha,1;sleep,0.1;diffusealpha,0;sleep,0.1;diffusealpha,1;sleep,1;diffusealpha,0;);
}

t[#t+1] = LoadActor("grade")..{
	OnCommand=cmd(diffusealpha,0;animate,0;y,SCREEN_HEIGHT*0.4),
	GoodP2MessageCommand=cmd(setstate,1;queuecommand,"Flash");
	WrongP2MessageCommand=cmd(setstate,0;queuecommand,"Flash");
	FlashCommand=cmd(x,dm_p2pos;diffusealpha,1;sleep,0.1;diffusealpha,0;sleep,0.1;diffusealpha,1;sleep,0.1;diffusealpha,0;sleep,0.1;diffusealpha,1;sleep,1;diffusealpha,0;);
}

t[#t+1] = Def.Quad{
	InitCommand=cmd(visible,false),
	StepMessageCommand=function(self,params)
	
		local mbeat = (GAMESTATE:GetCurMusicSeconds()+5.274)/(60/128);
		if mbeat > 92 and mbeat < 109 then
			for i=1,#dm_questiontiming do
				--Trace('q'..i..': '..beat-dm_questiontiming[i]);
				local pn = 1;
				if params.PlayerNumber == 'PlayerNumber_P1' then pn = 1 else pn = 2 end
				if mbeat-dm_questiontiming[i] < 0.25 and mbeat-dm_questiontiming[i] > -0.1 then
					dm_spawnf(params.Column,pn)
					for c=1,#dm_brain do
						if dm_brain[c]:getaux() == params.Column+1 and (pn == 1 and dm_brain[c]:GetX() < sw/2 or pn == 2 and dm_brain[c]:GetX() > sw/2) then
							dm_brain[c]:stoptweening();
							dm_brain[c]:queuecommand('Hide');
						end
					end
					dm_myanswer[pn] = _G['dm_quiz_choices'..pn][i][params.Column+1]
					Trace('Answering: '..dm_myanswer[pn]);
				end
			end
		end
	end,
}


t[#t+1] = LoadActor("gonzales")..{
	OnCommand=cmd(Center;zoom,1.5;y,SCREEN_BOTTOM+(360*1.5);vertalign,bottom;visible,false);
	GonzalesMessageCommand=cmd(visible,true;linear,0.2;y,SCREEN_BOTTOM+120);
	GonzalesAwayMessageCommand=cmd(visible,false);
}

mawaru_bs_questions_nm = {
	{'(2+2)/2',2},
	{'1+2+3',6},
	{'2+2+2-1',5},
	{'3x3-6',3},
	{'8/2',4},
	{'10-9',1},
	{'3^2',9},
	{'3+3+3-1',8},
	{'5-5',0},
	{'1+2+4',7}
}

mawaru_bs_questions_hd = {
	{'(-2+(2+6/3)^2)-2',2},
	{'((4^2)/4)+2',6},
	{'(9/3)+1/2+3/2',5},
	{'(1+1+1x6)/8+2',3},
	{'9-8+7-6+5-4+3-2',4},
	{'(7+7)/2/7',1},
	{'(6x(3^2))/(3x2)',9},
	{'((2+3+5)/2)+3',8},
	{'(1+1+1+1+1+1+1+1)x0',0},
	{'1+2+3-4+5+6-7+1',7}
}

mawaru_bs_picker = 1;
mawaru_bs_question = 'set me';
mawaru_bs_realanswer = -1;
mawaru_bs_myanswer = {math.random(0,9),math.random(0,9)}

mawaru_bs_chars = {'taro','sami'};

mawaru_bs_correct = {false,false}

t[#t+1] = Def.ActorFrame{
	OnCommand=cmd(visible,false);
	OtadaOnMessageCommand=function(self)
		mawaru_bs_picker = math.random(1,10)
		local q = mawaru_bs_questions_nm[mawaru_bs_picker]
		if math.max(mawaru_meter1,mawaru_meter2) > 17 then
			q = mawaru_bs_questions_hd[mawaru_bs_picker]
		end
		
		mawaru_bs_question = q[1]
		mawaru_bs_realanswer = q[2]
		
		otada_qtext:settext(mawaru_bs_question);
		otada_qtext:zoom(1.3);
		
		self:playcommand("SetOtada");
		self:visible(true);
	end,
	CheckOtadaMessageCommand=function(self)
		anywrong = false
		for pn=1,2 do
			if GAMESTATE:IsPlayerEnabled('PlayerNumber_P'..pn) then
				if mawaru_bs_myanswer[pn] == mawaru_bs_realanswer then
					local a = _G[ 'otada_'..mawaru_bs_chars[pn] ]
					a:setstate(1);
					a:zoom(1.05);
					a:linear(0.2);
					a:zoom(1);
					mawaru_bs_correct[pn] = true;
				else
					local a = _G[ 'otada_'..mawaru_bs_chars[pn] ]
					a:setstate(2);
					a:zoom(1.05);
					a:linear(0.2);
					a:zoom(1);
					anywrong = true;
				end
			end
		end
		if anywrong then
			MESSAGEMAN:Broadcast('OtadaSlash');
			MESSAGEMAN:Broadcast('WhiteFlash');
			Sound('slash.ogg');
		else
			MESSAGEMAN:Broadcast('OtadaOK');
		end
	end,
	OtadaAwayMessageCommand=cmd(visible,false);
	LoadActor('otadabg')..{
		OnCommand=cmd(Center;scale_or_crop_background;);
	},
	
	LoadActor('shadow')..{ OnCommand=cmd(x,sw/2-100;y,sh-60;addy,12;);
		SetOtadaCommand=function(self) if not GAMESTATE:IsPlayerEnabled(PLAYER_2) then self:visible(false) end end },
	LoadActor('shadow')..{ OnCommand=cmd(x,sw/2-240;y,sh-60;addy,12;);
		SetOtadaCommand=function(self) if not GAMESTATE:IsPlayerEnabled(PLAYER_1) then self:visible(false) end end },
	LoadActor('shadow')..{ OnCommand=cmd(x,sw/2+70;y,sh-60;addy,10;addx,40); OtadaSlashMessageCommand=cmd(addx,-8;); },
	LoadActor('shadow')..{ OnCommand=cmd(x,sw/2+240;y,sh-80;addy,50;addx,-30) },
	LoadActor('shadow')..{ OnCommand=cmd(x,sw/2+210;y,sh-40;addy,-35;addx,20;zoom,1.5) },
	
	LoadActor('sami')..{
		OnCommand=cmd(x,sw/2-100;y,sh-60;valign,0.9;animate,false;setstate,0;pulse;effectmagnitude,1,1.01,1;effectperiod,0.7);
		SetOtadaCommand=function(self) if not GAMESTATE:IsPlayerEnabled(PLAYER_2) then self:visible(false) end end,
		InitCommand=function(self) otada_sami = self end,
	},
	LoadActor('taro')..{
		OnCommand=cmd(x,sw/2-240;y,sh-60;valign,0.9;animate,false;setstate,0;pulse;effectmagnitude,1,1.01,1;effectperiod,1);
		SetOtadaCommand=function(self) if not GAMESTATE:IsPlayerEnabled(PLAYER_1) then self:visible(false) end end,
		InitCommand=function(self) otada_taro = self end,
	},
	LoadActor('slash')..{
		OnCommand=cmd(x,sw/2-40;y,sh-170;diffusealpha,0;);
		OtadaSlashMessageCommand=cmd(diffusealpha,1;linear,1;diffusealpha,0);
	},
	LoadActor('otada1')..{
		OnCommand=cmd(x,(sw/2)+70;y,sh-60;valign,0.9;animate,false;setstate,0;pulse;effectmagnitude,1,1.01,1;effectoffset,0.2;effectperiod,1.2);
		OtadaSlashMessageCommand=cmd(setstate,1;stopeffect;);
		OtadaOKMessageCommand=cmd(setstate,2;zoom,1.05;linear,0.2;zoom,1;stopeffect;);
	},
	LoadActor('otada3')..{
		OnCommand=cmd(x,sw/2+240;y,sh-80;valign,0.9;pulse;effectmagnitude,1,1.02,1;effectoffset,0.7;effectperiod,2);
	},
	LoadActor('otada2')..{
		OnCommand=cmd(x,sw/2+210;y,sh-40;valign,0.9;pulse;effectmagnitude,1,1.01,1;effectoffset,0.3;effectperiod,1.4);
	},
	
	LoadActor('solve')..{
		OnCommand=cmd(x,sw/2-40;y,sh/2-160;);
	},
	LoadActor('answers')..{
		OnCommand=cmd(x,sw/2-100+45;y,sh-290;animate,false;setstate,1;);
		SetOtadaCommand=function(self) if not GAMESTATE:IsPlayerEnabled(PLAYER_2) then self:visible(false) end end
	},
	LoadActor('answers')..{
		OnCommand=cmd(x,sw/2-240+45;y,sh-310;animate,false;setstate,0;);
		SetOtadaCommand=function(self) if not GAMESTATE:IsPlayerEnabled(PLAYER_1) then self:visible(false) end end
	},
	
	LoadFont('Common/_segoe ui 24px')..{
		Text='';
		InitCommand=function(self) otada_qtext = self end,
		OnCommand=cmd(x,sw/2-40;y,sh/2-160;diffuse,0,0,0,1);
	},
	
	LoadActor('brainshower')..{
		OnCommand=cmd(x,sw/2-100+46;y,sh-290;animate,false;setstate,0;zoom,0.7);
		SetOtadaCommand=function(self) self:setstate(mawaru_bs_myanswer[2])
			if not GAMESTATE:IsPlayerEnabled(PLAYER_2) then self:visible(false) end end;
		StepMessageCommand=function(self,params)
			pn = 2
			if params.PlayerNumber == 'PlayerNumber_P'..pn and GAMESTATE:GetSongBeat() > 282 and GAMESTATE:GetSongBeat() < 308 then
				if params.Column == 0 then
					if mawaru_bs_myanswer[pn] == 0 then
						mawaru_bs_myanswer[pn] = 9
					else
						mawaru_bs_myanswer[pn] = mawaru_bs_myanswer[pn]-1
					end
				elseif params.Column == 4 then
					if mawaru_bs_myanswer[pn] == 9 then
						mawaru_bs_myanswer[pn] = 0
					else
						mawaru_bs_myanswer[pn] = mawaru_bs_myanswer[pn]+1
					end
				end
				self:finishtweening();
				self:setstate(mawaru_bs_myanswer[pn])
				self:zoom(0.8);
				self:linear(0.2);
				self:zoom(0.7);
			end
		end
	},
	
	LoadActor('brainshower')..{
		OnCommand=cmd(x,sw/2-240+46;y,sh-310;animate,false;setstate,0;zoom,0.7);
		SetOtadaCommand=function(self) self:setstate(mawaru_bs_myanswer[1])
			if not GAMESTATE:IsPlayerEnabled(PLAYER_1) then self:visible(false) end end;
		StepMessageCommand=function(self,params)
			pn = 1
			if params.PlayerNumber == 'PlayerNumber_P'..pn and GAMESTATE:GetSongBeat() > 282 and GAMESTATE:GetSongBeat() < 308 then
				if params.Column == 0 then
					if mawaru_bs_myanswer[pn] == 0 then
						mawaru_bs_myanswer[pn] = 9
					else
						mawaru_bs_myanswer[pn] = mawaru_bs_myanswer[pn]-1
					end
				elseif params.Column == 4 then
					if mawaru_bs_myanswer[pn] == 9 then
						mawaru_bs_myanswer[pn] = 0
					else
						mawaru_bs_myanswer[pn] = mawaru_bs_myanswer[pn]+1
					end
				end
				self:finishtweening();
				self:setstate(mawaru_bs_myanswer[pn])
				self:zoom(0.8);
				self:linear(0.2);
				self:zoom(0.7);
			end
		end
	},
}



mawaru_horse_x = {0,0}
mawaru_horse_pos = {7,7}
mawaru_horse_prevpos = {7,7}

mawaru_horse_spdmult = {0.62,0.62}

mawaru_horse_enemypos = {{30,40,50,65,80,95},{30,40,50,65,80,95}}
mawaru_horse_enemyspd = {-0.2,-0.1,-0.05,0.0,0.02,0.04}
mawaru_horse_characters = {{},{}}
mawaru_horse_shadows = {{},{}}

mawaru_horse_basezoom = {{1,1,1,1,1,1},{1,1,1,1,1,1}}

function mawaru_hspd_correct(i,pn)
	if mawaru_horse_enemyspd[i] > 0 then
		return mawaru_horse_enemyspd[i]*mawaru_horse_spdmult[pn]
	else
		return mawaru_horse_enemyspd[i]
	end
end

function mawaru_horse_update()
	local b = GAMESTATE:GetSongBeat()
	if b > 418 and b < 446 then
		for pn=1,2 do
			if GAMESTATE:IsPlayerEnabled('PlayerNumber_P'..pn) then
				
				mawaru_horse_pos[pn] = 7
				
				for i=1,6 do
					local a = mawaru_horse_characters[pn][i]
					mawaru_horse_enemypos[pn][i] = mawaru_horse_enemypos[pn][i]+mawaru_hspd_correct(i,pn)
					a:addx((((mawaru_horse_enemypos[pn][i]-mawaru_horse_x[pn]-(sw*0.2/20))*20)-a:GetX())/5)
					
					mawaru_horse_shadows[pn][i]:x(a:GetX());
					
					if i == 4 or i == 6 then
						mawaru_horse_shadows[pn][i]:basezoomx(mawaru_horse_basezoom[pn][i])
						mawaru_horse_shadows[pn][i]:basezoomy(mawaru_horse_basezoom[pn][i])
						mawaru_horse_characters[pn][i]:basezoomx(mawaru_horse_basezoom[pn][i])
						mawaru_horse_characters[pn][i]:basezoomy(mawaru_horse_basezoom[pn][i])
					end
					
					if mawaru_horse_basezoom[pn][i] > 1 then
						mawaru_horse_basezoom[pn][i] = mawaru_horse_basezoom[pn][i]-0.02;
					end
					
					if a:GetX() < sw*-0.1 then
						if i == 4 and a:getaux() == 0 then
							a:aux(1);
							a:setstate(1);
							mawaru_horse_basezoom[pn][i] = 1.2
						end
						if i == 6 and a:getaux() == 0 then
							a:aux(1);
							a:setstate(1);
							mawaru_horse_basezoom[pn][i] = 1.2
						end
						mawaru_horse_pos[pn] = 7-i
					end
				end
				
				if mawaru_horse_prevpos[pn] ~= mawaru_horse_pos[pn] then
					Trace('Player '..pn..' pos changed to '..mawaru_horse_pos[pn]);
					MESSAGEMAN:Broadcast('HorsePosChangedP'..pn,{pos = mawaru_horse_pos[pn]});
					if _G['horse_sounded'..pn][mawaru_horse_pos[pn] ] == 0 then
						_G['horse_sounded'..pn][mawaru_horse_pos[pn] ] = 1
						if mawaru_horse_pos[pn] == 1 then
							MESSAGEMAN:Broadcast('HorseWin');
						end
						MESSAGEMAN:Broadcast('HorseOvertake');
					end
				end
				
				mawaru_horse_prevpos[pn] = mawaru_horse_pos[pn]
				
			end
		end
	end
end

horse_sounded1 = {0,0,0,0,0,0,0}
horse_sounded2 = {0,0,0,0,0,0,0}

t[#t+1] = LoadActor("sounds/EX_Confirm.mp3")..{
	HorseOvertakeMessageCommand=cmd(play);
}
t[#t+1] = LoadActor("sounds/EvalAnnouncer/RANK_A.mp3")..{
	HorseWinMessageCommand=cmd(play);
}

t[#t+1] = Def.ActorFrame{
	Def.ActorFrame{
		OnCommand=cmd(visible,false),
		HorseOnMessageCommand=function(self)
		
			if GAMESTATE:IsPlayerEnabled(PLAYER_1) and not GAMESTATE:IsPlayerEnabled(PLAYER_2) then
				self:x(sw*0.25);
				MESSAGEMAN:Broadcast('HCoverP2');
			end
			if GAMESTATE:IsPlayerEnabled(PLAYER_2) and not GAMESTATE:IsPlayerEnabled(PLAYER_1) then
				self:x(sw*-0.25);
				MESSAGEMAN:Broadcast('HCoverP1');
			end
			
			--{30,40,50,65,80,95},
			if mawaru_meter1 > 17 then
				mawaru_horse_spdmult[1] = 1
				mawaru_horse_enemypos[1] = {60,70,90,110,120,130}
			elseif mawaru_meter1 < 17 then
				mawaru_horse_spdmult[1] = 0.62*(0.7*(mawaru_meter1/17)+0.3)
			end
			if mawaru_meter2 > 17 then
				mawaru_horse_spdmult[2] = 1
				mawaru_horse_enemypos[2] = {60,70,90,110,120,110}
			elseif mawaru_meter2 < 17 then
				mawaru_horse_spdmult[2] = 0.62*(0.7*(mawaru_meter2/17)+0.3)
			end
			
			for pn=1,2 do
				if GAMESTATE:IsPlayerEnabled('PlayerNumber_P'..pn) then
					
					for i=1,6 do
						local a = mawaru_horse_characters[pn][i]
						a:x(((mawaru_horse_enemypos[pn][i]-mawaru_horse_x[pn])*20)-(sw*0.2))
						mawaru_horse_shadows[pn][i]:x(a:GetX());
					end
					
				end
			end
			
			self:visible(true);
			self:playcommand('SetUpHorse');
		end,
		HorseAwayMessageCommand=cmd(visible,false);
		
		Def.Quad{
			OnCommand=cmd(visible,false);
			StepMessageCommand=function(self,params)
				if GAMESTATE:GetSongBeat() > 418 and GAMESTATE:GetSongBeat() < 446 then
					for pn=1,2 do
						if params.PlayerNumber == 'PlayerNumber_P'..pn then
							mawaru_horse_x[pn] = mawaru_horse_x[pn]+1;
							MESSAGEMAN:Broadcast('HAccelP'..pn);
						end
					end
				end
			end,
		},
		
		LoadActor('race_sky')..{
			OnCommand=cmd(Center;halign,1)
		},	
		LoadActor('clouds')..{
			OnCommand=cmd(Center;halign,1;customtexturerect,0,0,2,2;zoom,2;texcoordvelocity,-0.1,0),
			SetUpHorseCommand=cmd(texcoordvelocity,-0.1,0);
		},
		Def.ActorFrame{
			OnCommand=cmd(x,sw*0.25;y,sh*0.45;zoom,0.8),
			LoadActor('brain/dl_t')..{
				OnCommand=cmd(x,-40;y,-110;queuecommand,"Loops");
				LoopsCommand=cmd(zoom,0.9;sleep,0.2;zoom,1.1;sleep,0.2;queuecommand,'Loops');
			},
			LoadActor('brain/dl_t')..{
				OnCommand=cmd(x,40;y,-110;basezoomx,-1;queuecommand,"Loops");
				LoopsCommand=cmd(zoom,1.1;sleep,0.2;zoom,0.9;sleep,0.2;queuecommand,'Loops');
			},
			LoadFont("Shruti Metal")..{
				OnCommand=cmd(y,-156;strokecolor,0,0,0,1;zoom,1.2;diffuseblink;effectcolor1,1,.5,.5,1;effectcolor2,1,1,.5,1;effectperiod,0.2);
				Text="Mash!";
			}
		},	
		LoadActor('grass')..{
			OnCommand=cmd(CenterX;halign,1;y,sh+4;valign,1;customtexturerect,0,0,1,1;texcoordvelocity,0.6,0),
			HAccelP1MessageCommand=cmd(stoptweening;texcoordvelocity,1.2,0;sleep,0.05;queuecommand,'NoAccel'),
			NoAccelCommand=cmd(texcoordvelocity,0.6,0;),
		},
		
		Def.ActorFrame{
			OnCommand=cmd(x,sw*0.25);
			LoadActor('shadow')..{
				InitCommand=cmd(x,-250;y,sh-120;);
				OnCommand=function(self) table.insert(mawaru_horse_shadows[1],self) end
			},
			LoadActor('shadow')..{
				InitCommand=cmd(x,-150-16;y,sh-120;);
				OnCommand=function(self) table.insert(mawaru_horse_shadows[1],self) end
			},
			LoadActor('shadow')..{
				InitCommand=cmd(x,-50+8;y,sh-120;zoom,0.8);
				OnCommand=function(self) table.insert(mawaru_horse_shadows[1],self) end
			},
			LoadActor('shadow')..{
				InitCommand=cmd(x,50;y,sh-120;);
				OnCommand=function(self) table.insert(mawaru_horse_shadows[1],self) end
			},
			LoadActor('shadow')..{
				InitCommand=cmd(x,150;y,sh-120;zoomx,1.4;);
				OnCommand=function(self) table.insert(mawaru_horse_shadows[1],self) end
			},
			LoadActor('shadow')..{
				InitCommand=cmd(x,250;y,sh-120;);
				OnCommand=function(self) table.insert(mawaru_horse_shadows[1],self) end
			},
			LoadActor('racers/yeo')..{
				InitCommand=cmd(x,-250;y,sh-220-20;zoom,0.8;bob;effectmagnitude,0,5,0;effectperiod,1.8;effectoffset,0.1);
				OnCommand=function(self) table.insert(mawaru_horse_characters[1],self) end
			},
			LoadActor('racers/rolling')..{
				InitCommand=cmd(x,-150;y,sh-180;);
				OnCommand=function(self) table.insert(mawaru_horse_characters[1],self) end
			},
			LoadActor('racers/sheep')..{
				InitCommand=cmd(x,-50;y,sh-240-40;bob;effectmagnitude,0,5,0;effectperiod,0.3;effectoffset,0.1);
				OnCommand=function(self) table.insert(mawaru_horse_characters[1],self) end
			},
			LoadActor('racers/monk')..{
				InitCommand=cmd(x,50;y,sh-200-30;animate,false;bob;effectmagnitude,0,5,0;effectperiod,1.7;effectoffset,0.1);
				OnCommand=function(self) table.insert(mawaru_horse_characters[1],self) end
			},
			LoadActor('racers/africa')..{
				InitCommand=cmd(x,150;y,sh-230-30;zoom,0.8;bob;effectmagnitude,0,-5,0;effectperiod,1.6;effectoffset,0.1;animate,false;setstate,math.random(0,1));
				OnCommand=function(self) table.insert(mawaru_horse_characters[1],self) end
			},
			LoadActor('racers/ufo')..{
				InitCommand=cmd(x,250;y,sh-230-40;bob;effectmagnitude,0,5,0;animate,false;setstate,0;effectperiod,1;effectoffset,0.1);
				OnCommand=function(self) table.insert(mawaru_horse_characters[1],self) end
			},
		},
		
		
		LoadActor('race_sky')..{
			OnCommand=cmd(Center;halign,0)
		},
		LoadActor('clouds')..{
			OnCommand=cmd(Center;halign,0;customtexturerect,0,0,2,2;zoom,2;texcoordvelocity,-0.0,0),
			SetUpHorseCommand=cmd(texcoordvelocity,-0.1,0);
		},
		Def.ActorFrame{
			OnCommand=cmd(x,sw*0.75;y,sh*0.45;zoom,0.8),
			LoadActor('brain/dl_t')..{
				OnCommand=cmd(x,-40;y,-110;queuecommand,"Loops");
				LoopsCommand=cmd(zoom,0.9;sleep,0.2;zoom,1.1;sleep,0.2;queuecommand,'Loops');
			},
			LoadActor('brain/dl_t')..{
				OnCommand=cmd(x,40;y,-110;basezoomx,-1;queuecommand,"Loops");
				LoopsCommand=cmd(zoom,1.1;sleep,0.2;zoom,0.9;sleep,0.2;queuecommand,'Loops');
			},
			LoadFont("Shruti Metal")..{
				OnCommand=cmd(y,-156;strokecolor,0,0,0,1;zoom,1.2;diffuseblink;effectcolor1,1,.5,.5,1;effectcolor2,1,1,.5,1;effectperiod,0.2);
				Text="Mash!";
			}
		},
		LoadActor('grass')..{
			OnCommand=cmd(CenterX;halign,0;y,sh+4;valign,1;customtexturerect,0,0,1,1;texcoordvelocity,0.0,0),
			HAccelP2MessageCommand=cmd(stoptweening;texcoordvelocity,1.2,0;sleep,0.05;queuecommand,'NoAccel'),
			NoAccelCommand=cmd(texcoordvelocity,0.6,0;),
			SetUpHorseCommand=cmd(texcoordvelocity,0.6,0);
		},
		
		Def.Quad{
			OnCommand=cmd(x,sw*0.75;y,sh*0.6;zoomto,sw*0.5,sh*0.8;MaskSource);
		},
		
		Def.ActorFrame{
			OnCommand=cmd(x,sw*0.75;ztestmode,'ZTestMode_WriteOnFail');
			LoadActor('shadow')..{
				InitCommand=cmd(x,-250;y,sh-120;);
				OnCommand=function(self) table.insert(mawaru_horse_shadows[2],self) end
			},
			LoadActor('shadow')..{
				InitCommand=cmd(x,-150-16;y,sh-120;);
				OnCommand=function(self) table.insert(mawaru_horse_shadows[2],self) end
			},
			LoadActor('shadow')..{
				InitCommand=cmd(x,-50+8;y,sh-120;zoom,0.8);
				OnCommand=function(self) table.insert(mawaru_horse_shadows[2],self) end
			},
			LoadActor('shadow')..{
				InitCommand=cmd(x,50;y,sh-120;);
				OnCommand=function(self) table.insert(mawaru_horse_shadows[2],self) end
			},
			LoadActor('shadow')..{
				InitCommand=cmd(x,150;y,sh-120;zoomx,1.4;);
				OnCommand=function(self) table.insert(mawaru_horse_shadows[2],self) end
			},
			LoadActor('shadow')..{
				InitCommand=cmd(x,250;y,sh-120;);
				OnCommand=function(self) table.insert(mawaru_horse_shadows[2],self) end
			},
			LoadActor('racers/yeo')..{
				InitCommand=cmd(x,-250;y,sh-220-20;zoom,0.8;bob;effectmagnitude,0,5,0;effectperiod,1.8;effectoffset,0.1);
				OnCommand=function(self) table.insert(mawaru_horse_characters[2],self) end
			},
			LoadActor('racers/rolling')..{
				InitCommand=cmd(x,-150;y,sh-180;);
				OnCommand=function(self) table.insert(mawaru_horse_characters[2],self) end
			},
			LoadActor('racers/sheep')..{
				InitCommand=cmd(x,-50;y,sh-240-40;bob;effectmagnitude,0,5,0;effectperiod,0.3;effectoffset,0.1);
				OnCommand=function(self) table.insert(mawaru_horse_characters[2],self) end
			},
			LoadActor('racers/monk')..{
				InitCommand=cmd(x,50;y,sh-200-30;animate,false;bob;effectmagnitude,0,5,0;effectperiod,1.7;effectoffset,0.1);
				OnCommand=function(self) table.insert(mawaru_horse_characters[2],self) end
			},
			LoadActor('racers/africa')..{
				InitCommand=cmd(x,150;y,sh-230-30;zoom,0.8;bob;effectmagnitude,0,-5,0;effectperiod,1.6;effectoffset,0.1;animate,false;setstate,math.random(0,1));
				OnCommand=function(self) table.insert(mawaru_horse_characters[2],self) end
			},
			LoadActor('racers/ufo')..{
				InitCommand=cmd(x,250;y,sh-230-40;bob;effectmagnitude,0,5,0;animate,false;setstate,0;effectperiod,1;effectoffset,0.1);
				OnCommand=function(self) table.insert(mawaru_horse_characters[2],self) end
			},
		},
		
		LoadActor('horseP1')..{
			OnCommand=cmd(valign,1;y,sh+20;x,(sw*0.15)+10;zoom,0.5;wag;effectmagnitude,0,0,-5);
		},
		LoadActor('horseP2')..{
			OnCommand=cmd(valign,1;y,sh+20;x,(sw*0.65)+10;zoom,0.5;wag;effectmagnitude,0,0,5);
		},
		
		LoadActor('horse_pos')..{
			OnCommand=cmd(halign,1;valign,1;x,sw*0.5-3;y,sh-3;animate,false;setstate,0;visible,false;);
			HorsePosChangedP1MessageCommand=function(self,params)
				if params.pos < 4 then
					local pos = params.pos;
					self:finishtweening()
					self:setstate(pos-1)
					self:zoom(((3-pos)*0.1)+0.7)
					self:linear(0.1);
					self:zoom(((3-pos)*0.1)+0.6)
					self:visible(true);
				else
					self:finishtweening()
					self:visible(false);
				end
			end
		},
		LoadActor('horse_loser_pos')..{
			OnCommand=cmd(halign,1;valign,1;x,sw*0.5-3;y,sh-3;animate,false;setstate,3;visible,true;zoom,0.8);
			HorsePosChangedP1MessageCommand=function(self,params)
				if params.pos > 3 then
					local pos = params.pos;
					self:finishtweening()
					self:setstate(pos-4)
					self:zoom(((7-pos)*0.1)+0.9)
					self:linear(0.1);
					self:zoom(((7-pos)*0.1)+0.8)
					self:visible(true);
				else
					self:finishtweening()
					self:visible(false);
				end
			end
		},
		
		LoadActor('horse_pos')..{
			OnCommand=cmd(halign,1;valign,1;x,sw-3;y,sh-3;animate,false;setstate,0;visible,false;);
			HorsePosChangedP2MessageCommand=function(self,params)
				if params.pos < 4 then
					local pos = params.pos;
					self:finishtweening()
					self:setstate(pos-1)
					self:zoom(((3-pos)*0.1)+0.7)
					self:linear(0.1);
					self:zoom(((3-pos)*0.1)+0.6)
					self:visible(true);
				else
					self:finishtweening()
					self:visible(false);
				end
			end
		},
		LoadActor('horse_loser_pos')..{
			OnCommand=cmd(halign,1;valign,1;x,sw-3;y,sh-3;animate,false;setstate,3;visible,true;zoom,0.8);
			HorsePosChangedP2MessageCommand=function(self,params)
				if params.pos > 3 then
					local pos = params.pos;
					self:finishtweening()
					self:setstate(pos-4)
					self:zoom(((7-pos)*0.1)+0.9)
					self:linear(0.1);
					self:zoom(((7-pos)*0.1)+0.8)
					self:visible(true);
				else
					self:finishtweening()
					self:visible(false);
				end
			end
		},
		
		Def.Quad{
			OnCommand=cmd(Center;zoomto,6,sh;diffuse,0,0,0,1);
		},
		
		Def.Quad{
			OnCommand=cmd(halign,1;CenterY;zoomto,sw,sh;diffuse,0,0,0,1);
			HCoverP1MessageCommand=cmd(CenterX);
		},
		Def.Quad{
			OnCommand=cmd(x,sw;halign,0;CenterY;zoomto,sw,sh;diffuse,0,0,0,1);
			HCoverP2MessageCommand=cmd(CenterX);
		}
		
	}
}


botw_canact = {false,false}
botw_held = {false,false}
botw_dead = {false,false}

botw_alivetime = {0,0}

botw_attackdir = {0,0}
botw_attacktime = {0,0}

function mawaru_botw_update()
	local b = GAMESTATE:GetSongBeat()
	if b > 374 and b < 406 then
	
		--Trace(botw_olist[1]:GetX());
	
		for pn = 1,2 do
			if GAMESTATE:IsPlayerEnabled('PlayerNumber_P'..pn) and botw_canact[pn] then
				
				if botw_attacktime[pn] > 0 then
					botw_attacktime[pn] = botw_attacktime[pn]-0.02;
				end
				if not botw_held[pn] then
					botw_attacktime[pn] = 0
				end
				
				if botw_held[pn] and not botw_dead[pn] then
					_G['botw_p'..pn..'idles']:visible(true);
					_G['botw_p'..pn..'flail']:visible(false);
				end
				if not botw_held[pn] and not botw_dead[pn] then
					_G['botw_p'..pn..'idles']:visible(false)
					_G['botw_p'..pn..'flail']:visible(true);
				end
				
				if botw_dead[pn] then
					_G['botw_p'..pn..'idles']:visible(false)
					_G['botw_p'..pn..'flail']:visible(false);
				else
					botw_alivetime[pn] = b;
				end
				
				for i=1,#botw_olist do
					local a = botw_olist[i]
					if a:getaux() > 0 then
						if mawaru_dist(a:GetX(),a:GetY(),_G['dm_p'..pn..'pos'],(sh/2)-40) < 120 then
							
							--[[
							if i==1 and pn == 1 then
								Trace('P1 attack dir '..botw_attackdir[pn]..' time '..botw_attacktime[pn]);
								Trace('Enemy aux '..a:getaux()..' dist '..mawaru_dist(a:GetX(),a:GetY(),_G['dm_p'..pn..'pos'],(sh/2)-40));
							end
							]]
							
							if a:getaux() == botw_attackdir[pn]+1 and botw_attacktime[pn] > 0 then
								a:stoptweening();
								local ff = -1000
								if a:getaux() == 1 or a:getaux() == 5 then ff = 1000 end
								a:aux(0);
								a:linear(0.8);
								a:addy(ff)
								--Trace(mawaru_dist(a:GetX(),a:GetY(),_G['dm_p'..pn..'pos'],(sh/2)-40))
								Sound('deflect.ogg');
								a:queuecommand('Hide');
							end
							
							if a:getaux() > 0 and mawaru_dist(a:GetX(),a:GetY(),_G['dm_p'..pn..'pos'],(sh/2)-40) < 30 and b < 405 and not botw_dead[pn] then
								
								Sound('whack.ogg');
								_G['botw_p'..pn..'hurt']:visible(true);
								_G['botw_p'..pn..'hurt']:decelerate(0.3);
								_G['botw_p'..pn..'hurt']:zoom(1.2);
								_G['botw_p'..pn..'hurt']:addy(-100);
								_G['botw_p'..pn..'hurt']:accelerate(0.2);
								_G['botw_p'..pn..'hurt']:addy(100);
								_G['botw_p'..pn..'hurt']:linear(1);
								_G['botw_p'..pn..'hurt']:addy(1300);
								
								botw_dead[pn] = true;
						
								a:aux(0);
							end
						end
					end
				end
				
				--[[
				if not botw_dead[pn] and b < 405 then
				
					_G['botw_p'..pn..'hurt']:visible(true);
					_G['botw_p'..pn..'hurt']:decelerate(0.3);
					_G['botw_p'..pn..'hurt']:zoom(1.2);
					_G['botw_p'..pn..'hurt']:addy(-100);
					_G['botw_p'..pn..'hurt']:accelerate(0.3);
					_G['botw_p'..pn..'hurt']:addy(100);
					_G['botw_p'..pn..'hurt']:linear(1);
					_G['botw_p'..pn..'hurt']:addy(1300);
					
					botw_dead[pn] = true;
				end
				]]
				
			end
		end
	end
end

Botw_Orbs = Def.ActorFrame{}
botw_olist = {}

botw_curnote = {1,1}

botw_orb_chart_s9 = {

	{381,4,8},
	
	{384,3,8},
	{388,4,8},
	
	{392,0,6},
	{396,4,6},
	
	{400,3,6},
	{404,1,6},
}

botw_orb_chart_s13 = {

	{381,4,6},
	
	{384,3,6},
	{386,4,6},
	{388,3,6},
	
	{392,1,6},
	{394,3,6},
	{396,1,6},
	
	{400,4,6},
	{402,0,6},
	{404,4,6},
}

botw_orb_chart_s17 = {
	{381,4,6},
	
	{384,3,6},
	{386,1,6},
	{388,3,6},
	{389,3,6},
	
	{392,4,4},
	{394,0,4},
	{396,4,4},
	{397,4,4},
	
	{400,3,4},
	{402,1,4},
	{404,4,3},
	{405,4,3},
}

botw_orb_chart_s22 = {
	{381,4,6},
	
	{384,3,4},
	{385,1,4},
	{386,3,4},
	{387,1,4},
	{388,4,4},
	{389,0,4},
	
	{392,4,4},
	{393,0,4},
	{394,4,4},
	{395,0,4},
	{396,4,4},
	{397,3,4},
	
	{400,1,4},
	{401,3,4},
	{402,4,4},
	{403,0,4},
	{404,3,3},
	{405,0,3},
}

botw_bptr = 1;
function botw_spawn(beat,col,dur,pn)

	local a = botw_olist[botw_bptr]
	
	col = col+1;
	
	local xadd1 = {-sw/4,-sw/4,0,sw/2,sw/2}
	local xadd2 = {-30,-30,0,30,30}
	
	if pn == 2 then
		xadd1 = {-sw/2,-sw/2,0,sw/4,sw/4}
		
		if col == 1 then col = 5
		elseif col == 5 then col = 1
		elseif col == 2 then col = 4
		elseif col == 4 then col = 2 end
	end
	
	local yadd1 = {sh/1.5,-sh/2,0,-sh/2,sh/1.5}
	local yadd2 = {20,-20,0,-20,20}
	
	local rot = {-45,45,0,135,-135}
	
	local dmult = 2;
	
	if a then
		a:finishtweening();
		
		a:visible(true);
		a:zoom(0.6);
		a:diffusealpha(1)
		a:aux(col);
		a:rotationz(rot[col])
		a:x(_G['dm_p'..pn..'pos']+xadd1[col])
		a:y((sh*0.5-40)+yadd1[col])
		a:linear((dur*60/191)/RATEMOD)
		a:x(_G['dm_p'..pn..'pos']+(xadd2[col]*dmult))
		a:y((sh*0.5-40)+(yadd2[col]*dmult))
		a:linear((dur*0.25*60/191)/RATEMOD)
		a:x(_G['dm_p'..pn..'pos'])
		a:y((sh*0.5-40))
		a:decelerate(0.3);
		a:diffusealpha(0);
		a:zoom(1.2);
		a:sleep(0);
		a:aux(0);
		a:queuecommand('Hide');
	end
	
	botw_bptr = botw_bptr+2
	if botw_bptr > table.getn(botw_olist) then
		botw_bptr = 1
	end
	
end

for orb=1,60 do
	Botw_Orbs[#Botw_Orbs+1] = LoadActor('canon_orb')..{
		OnCommand=cmd(visible,false;),
		SetMeMessageCommand=function(self) table.insert(botw_olist,self) end,
		HideCommand=cmd(visible,false);
	}
end

t[#t+1] = Def.ActorFrame{
	OnCommand=cmd(visible,false),
	Botw_Orbs,
	BotwOnMessageCommand=function(self)
		self:visible(true);
		GAMESTATE:ApplyGameCommand("mod,dark");
		self:playcommand('SetUpBotw');
	end,
	Def.Quad{
		StepMessageCommand=function(self,params)
			for pn=1,2 do
				if params.PlayerNumber == 'PlayerNumber_P'..pn and params.Column == 2 then
					botw_held[pn] = true;
				end
			end
		end,
		LiftMessageCommand=function(self,params)
			for pn=1,2 do
				if params.PlayerNumber == 'PlayerNumber_P'..pn and params.Column == 2 then
					botw_held[pn] = false;
				end
			end
		end
	},
	Def.Quad{
		StepMessageCommand=function(self,params)
			local b = GAMESTATE:GetSongBeat()
			if b > 374 and b < 406 then
				for pn=1,2 do
					if params.PlayerNumber == 'PlayerNumber_P'..pn then
						if params.Column == 2 then
							if botw_canact[pn] then
								_G['botw_p'..pn..'idle']:finishtweening();
								_G['botw_p'..pn..'idle']:visible(true);
								_G['botw_p'..pn..'attacks']:finishtweening();
								_G['botw_p'..pn..'attacks']:visible(false);
							end
						elseif botw_attacktime[pn] <= 0.02 and botw_canact[pn] and botw_held[pn] and not botw_dead[pn] then
							botw_attackdir[pn] = params.Column
							botw_attacktime[pn] = 0.06;
							_G['botw_p'..pn..'idle']:visible(false);
							if params.Column == 0 then
								_G['botw_p'..pn..'attacks']:visible(true);
								_G['botw_p'..pn..'attacks']:finishtweening();
								_G['botw_p'..pn..'attacks']:setstate(1);
								_G['botw_p'..pn..'attacks']:basezoomx(-1);
								_G['botw_p'..pn..'attacks']:zoom(1.1);
								_G['botw_p'..pn..'attacks']:linear(0.2);
								_G['botw_p'..pn..'attacks']:zoom(1);
								_G['botw_p'..pn..'trail']:finishtweening();
								_G['botw_p'..pn..'trail']:setstate(1);
								_G['botw_p'..pn..'trail']:basezoomx(-1);
								_G['botw_p'..pn..'trail']:diffusealpha(1);
								_G['botw_p'..pn..'trail']:zoom(1.1);
								_G['botw_p'..pn..'trail']:linear(0.2);
								_G['botw_p'..pn..'trail']:zoom(1);
								_G['botw_p'..pn..'trail']:diffusealpha(0);
							elseif params.Column == 1 then
								_G['botw_p'..pn..'attacks']:visible(true);
								_G['botw_p'..pn..'attacks']:finishtweening();
								_G['botw_p'..pn..'attacks']:setstate(2);
								_G['botw_p'..pn..'attacks']:basezoomx(-1);
								_G['botw_p'..pn..'attacks']:zoom(1.1);
								_G['botw_p'..pn..'attacks']:linear(0.2);
								_G['botw_p'..pn..'attacks']:zoom(1);
								_G['botw_p'..pn..'trail']:finishtweening();
								_G['botw_p'..pn..'trail']:setstate(0);
								_G['botw_p'..pn..'trail']:basezoomx(-1);
								_G['botw_p'..pn..'trail']:diffusealpha(1);
								_G['botw_p'..pn..'trail']:zoom(1.1);
								_G['botw_p'..pn..'trail']:linear(0.2);
								_G['botw_p'..pn..'trail']:zoom(1);
								_G['botw_p'..pn..'trail']:diffusealpha(0);
							elseif params.Column == 3 then
								_G['botw_p'..pn..'attacks']:visible(true);
								_G['botw_p'..pn..'attacks']:finishtweening();
								_G['botw_p'..pn..'attacks']:setstate(2);
								_G['botw_p'..pn..'attacks']:basezoomx(1);
								_G['botw_p'..pn..'attacks']:zoom(1.1);
								_G['botw_p'..pn..'attacks']:linear(0.2);
								_G['botw_p'..pn..'attacks']:zoom(1);
								_G['botw_p'..pn..'trail']:finishtweening();
								_G['botw_p'..pn..'trail']:setstate(0);
								_G['botw_p'..pn..'trail']:basezoomx(1);
								_G['botw_p'..pn..'trail']:diffusealpha(1);
								_G['botw_p'..pn..'trail']:zoom(1.1);
								_G['botw_p'..pn..'trail']:linear(0.2);
								_G['botw_p'..pn..'trail']:zoom(1);
								_G['botw_p'..pn..'trail']:diffusealpha(0);
							elseif params.Column == 4 then
								_G['botw_p'..pn..'attacks']:visible(true);
								_G['botw_p'..pn..'attacks']:finishtweening();
								_G['botw_p'..pn..'attacks']:setstate(1);
								_G['botw_p'..pn..'attacks']:basezoomx(1);
								_G['botw_p'..pn..'attacks']:zoom(1.1);
								_G['botw_p'..pn..'attacks']:linear(0.2);
								_G['botw_p'..pn..'attacks']:zoom(1);
								_G['botw_p'..pn..'trail']:finishtweening();
								_G['botw_p'..pn..'trail']:setstate(1);
								_G['botw_p'..pn..'trail']:basezoomx(1);
								_G['botw_p'..pn..'trail']:diffusealpha(1);
								_G['botw_p'..pn..'trail']:zoom(1.1);
								_G['botw_p'..pn..'trail']:linear(0.2);
								_G['botw_p'..pn..'trail']:zoom(1);
								_G['botw_p'..pn..'trail']:diffusealpha(0);
							end
						end
					end
				end
			end
		end;
	},
	BotwAwayMessageCommand=function(self)
		self:visible(false);
		GAMESTATE:ApplyGameCommand("mod,no dark");
	end;
	Def.ActorFrame{
		OnCommand=cmd(zoom,0.7);
		InitCommand=function(self)
			botw_p1 = self;
		end,
		SetUpBotwCommand=cmd(x,dm_p1pos;y,ch-400;sleep,180/190/RATEMOD;accelerate,180/190/RATEMOD;y,ch+25;);
		--fall
		Def.Sprite{
			Texture="botw 4x2.png";
			Frame0000=3,
			Delay0000=0.06,
			Frame0001=4,
			Delay0001=0.06,
			OnCommand=cmd(valign,0.9);
			BotwLandMessageCommand=cmd(visible,false)
		},
		--sword trails
		LoadActor("botw_slash")..{
			InitCommand=function(self) botw_p1trail = self; end,
			OnCommand=cmd(valign,0.9;diffusealpha,0;blend,"BlendMode_Add";animate,false);
		},
		--Are you holding the button
		Def.ActorFrame{
			InitCommand=function(self)
				botw_p1idles = self;
			end,
			--idle
			Def.Sprite{
				Texture="botw 4x2.png";
				Frame0000=0,
				Delay0000=999,
				InitCommand=function(self) botw_p1idle = self; end,
				OnCommand=cmd(valign,0.9;visible,false;);
				BotwLandMessageCommand=cmd(visible,true;zoomx,1.2;zoomy,0.7;linear,0.2/RATEMOD;zoom,1;queuecommand,'CanAct'),
				CanActCommand=function(self) botw_canact[1] = true end,
			},
			--attacks
			LoadActor("botw 4x2.png")..{
				InitCommand=function(self) botw_p1attacks = self; end,
				OnCommand=cmd(valign,0.9;visible,false;animate,false);
			},
		},
		--flail
		Def.Sprite{
			InitCommand=function(self)
				botw_p1flail = self;
			end,
			Texture="botw 4x2.png";
			Frame0000=5,
			Delay0000=0.06,
			Frame0001=6,
			Delay0001=0.06,
			OnCommand=cmd(valign,0.9;x,-6;rotationz,-5;visible,false;wag;effectperiod,0.4;effectmagnitude,0,0,4);
		},
		--hurt
		Def.Sprite{
			InitCommand=function(self)
				botw_p1hurt = self;
			end,
			Texture="botw 4x2.png";
			Frame0000=7,
			Delay0000=999,
			OnCommand=cmd(valign,0.9;visible,false;);
		},
	},
	Def.ActorFrame{
		OnCommand=cmd(zoom,0.7);
		InitCommand=function(self)
			botw_p2 = self;
		end,
		SetUpBotwCommand=cmd(x,dm_p2pos;y,ch-400;sleep,180/190/RATEMOD;accelerate,180/190/RATEMOD;y,ch+25;);
		--fall
		Def.Sprite{
			Texture="botw 4x2.png";
			Frame0000=3,
			Delay0000=0.06,
			Frame0001=4,
			Delay0001=0.06,
			OnCommand=cmd(valign,0.9);
			BotwLandMessageCommand=cmd(visible,false)
		},
		--sword trails
		LoadActor("botw_slash")..{
			InitCommand=function(self) botw_p2trail = self; end,
			OnCommand=cmd(valign,0.9;diffusealpha,0;blend,"BlendMode_Add";animate,false);
		},
		--Are you holding the button
		Def.ActorFrame{
			InitCommand=function(self)
				botw_p2idles = self;
			end,
			--idle
			Def.Sprite{
				Texture="botw 4x2.png";
				Frame0000=0,
				Delay0000=999,
				InitCommand=function(self) botw_p2idle = self; end,
				OnCommand=cmd(valign,0.9;visible,false;);
				BotwLandMessageCommand=cmd(visible,true;zoomx,1.2;zoomy,0.7;linear,0.2/RATEMOD;zoom,1;queuecommand,'CanAct'),
				CanActCommand=function(self) botw_canact[2] = true end,
			},
			--attacks
			LoadActor("botw 4x2.png")..{
				InitCommand=function(self) botw_p2attacks = self; end,
				OnCommand=cmd(valign,0.9;visible,false;animate,false);
			},
		},
		--flail
		Def.Sprite{
			InitCommand=function(self)
				botw_p2flail = self;
			end,
			Texture="botw 4x2.png";
			Frame0000=5,
			Delay0000=0.06,
			Frame0001=6,
			Delay0001=0.06,
			OnCommand=cmd(valign,0.9;x,-6;rotationz,-5;visible,false;wag;effectperiod,0.4;effectmagnitude,0,0,4);
		},
		--hurt
		Def.Sprite{
			InitCommand=function(self)
				botw_p2hurt = self;
			end,
			Texture="botw 4x2.png";
			Frame0000=7,
			Delay0000=999,
			OnCommand=cmd(valign,0.9;visible,false;);
		},
	},
}


tower_pos = {0,0}
tower_cursor_x = {0,0}

tower_cursor_spd = {1,1};

tower_height = {-55,-55}
tower_width = {68,68}

tower_piece_info = {{54,54,26},{80,16,44},{42,42,20}}

tower_curpiece = {1,1}

tower_stacked = {0,0}

function mawaru_tower_update()
	local s = GAMESTATE:GetCurMusicSeconds()
	local b = GAMESTATE:GetSongBeat()
	if b > 458 and b < 494 then
		for pn=1,2 do
			if GAMESTATE:IsPlayerEnabled('PlayerNumber_P'..pn) then
				tower_cursor_x[pn] = (854*0.1)*math.sin(s*tower_cursor_spd[pn]*3)
				if tower_curpiece[pn] > 0 then
					local a = _G['tower_p'..pn..'brick'..tower_curpiece[pn] ]
					if a:GetZoom() < 1 then
						a:zoom(a:GetZoom()+0.05);
					end
					a:x(tower_cursor_x[pn]);
				end
			end
		end
	end
end

t[#t+1] = Def.ActorFrame{
	OnCommand=function(self)
		self:zoomx((16/9)/PREFSMAN:GetPreference('DisplayAspectRatio'));
		self:x(sw/2);
	end;
	Def.Quad{
		OnCommand=cmd(visible,false);
		StepMessageCommand=function(self,params)
			for pn=1,2 do
				if params.Column == 2 and params.PlayerNumber == 'PlayerNumber_P'..pn then
					if tower_curpiece[pn] > 0 and GAMESTATE:GetSongBeat() > 464 and GAMESTATE:GetSongBeat() < 490 then
						local a = _G['tower_p'..pn..'brick'..tower_curpiece[pn] ]
						if math.abs(a:GetX()-tower_pos[pn]) < (tower_piece_info[ tower_curpiece[pn] ][1]/4)+(tower_width[pn]/4) then
							a:sleep(0.2/RATEMOD);
							a:accelerate(0.6/RATEMOD);
							a:y(tower_height[pn]);
							a:queuemessage('StackSound');
							a:queuecommand('NextBrick');
							
							tower_width[pn] = tower_piece_info[ tower_curpiece[pn] ][2]
							tower_height[pn] = tower_height[pn]-tower_piece_info[ tower_curpiece[pn] ][3]
							tower_stacked[pn] = tower_stacked[pn]+1;
							tower_pos[pn] = a:GetX();
							
							tower_cursor_spd[pn] = tower_cursor_spd[pn]*1.2
							
						else
							a:sleep(0.2/RATEMOD);
							a:accelerate(0.6/RATEMOD);
							a:y(0);
							a:queuemessage('NoStackSound');
							a:sleep(0.3/RATEMOD);
							a:queuecommand('NextBrick');
							a:queuecommand('Despawn');
						end
						
						tower_curpiece[pn] = -1;
					end
				end
			end
		end
	},
	Def.ActorFrame{
		OnCommand=cmd(visible,false;x,-sw/2),
		TowerOnMessageCommand=function(self)
		
			if mawaru_meter1 > 17 then
				tower_cursor_spd[1] = 1.3
			elseif mawaru_meter1 < 17 then
				tower_cursor_spd[1] = 1*(0.5*(mawaru_meter1/17)+0.5)
			end
			if mawaru_meter2 > 17 then
				tower_cursor_spd[2] = 0.83
			elseif mawaru_meter2 < 17 then
				tower_cursor_spd[2] = 1*(0.5*(mawaru_meter2/17)+0.5)
			end
		
			self:visible(true);
			self:playcommand('SetUpTower');
		end,
		TowerAwayMessageCommand=cmd(visible,false);
		LoadActor('space')..{
			OnCommand=cmd(Center;customtexturerect,0,0,2,2;zoom,4;texcoordvelocity,-.03,-.01);
		},
		LoadActor('towerbg')..{
			OnCommand=cmd(valign,1;y,sh;CenterX);
		},
		Def.ActorFrame{
			SetUpTowerCommand=function(self) if not GAMESTATE:IsPlayerEnabled('PlayerNumber_P1') then self:visible(false) end end,
			OnCommand=cmd(x,sw*0.25;y,sh-130);
			LoadActor('tower_base')..{
				OnCommand=cmd(valign,110/128);
			},
			LoadActor('tower_bricks')..{
				InitCommand=function(self) tower_p1brick1 = self end;
				OnCommand=cmd(valign,57/64;y,-180;zoom,1;animate,0;setstate,0;);
				NextBrickCommand=function(self) tower_curpiece[1] = 2 end;
				DespawnCommand=cmd(diffusealpha,1;sleep,0.1;diffusealpha,0;sleep,0.1;
				diffusealpha,1;sleep,0.1;diffusealpha,0;sleep,0.1;
				diffusealpha,1;sleep,0.1;diffusealpha,0;);
			},
			LoadActor('tower_bricks')..{
				InitCommand=function(self) tower_p1brick2 = self end;
				OnCommand=cmd(valign,57/64;y,-220;zoom,0;animate,0;setstate,1;);
				NextBrickCommand=function(self) tower_curpiece[1] = 3 end;
				DespawnCommand=cmd(diffusealpha,1;sleep,0.1;diffusealpha,0;sleep,0.1;
				diffusealpha,1;sleep,0.1;diffusealpha,0;sleep,0.1;
				diffusealpha,1;sleep,0.1;diffusealpha,0;);
			},
			LoadActor('tower_bricks')..{
				InitCommand=function(self) tower_p1brick3 = self end;
				OnCommand=cmd(valign,57/64;y,-260;zoom,0;animate,0;setstate,2;);
				NextBrickCommand=cmd();
				DespawnCommand=cmd(diffusealpha,1;sleep,0.1;diffusealpha,0;sleep,0.1;
				diffusealpha,1;sleep,0.1;diffusealpha,0;sleep,0.1;
				diffusealpha,1;sleep,0.1;diffusealpha,0;);
			},
		},
		Def.ActorFrame{
			SetUpTowerCommand=function(self) if not GAMESTATE:IsPlayerEnabled('PlayerNumber_P2') then self:visible(false) end end,
			OnCommand=cmd(x,sw*0.75;y,sh-130);
			LoadActor('tower_base')..{
				OnCommand=cmd(valign,110/128);
			},
			LoadActor('tower_bricks')..{
				InitCommand=function(self) tower_p2brick1 = self end;
				OnCommand=cmd(valign,57/64;y,-180;zoom,1;animate,0;setstate,0;);
				NextBrickCommand=function(self) tower_curpiece[2] = 2 end;
				DespawnCommand=cmd(diffusealpha,1;sleep,0.1;diffusealpha,0;sleep,0.1;
				diffusealpha,1;sleep,0.1;diffusealpha,0;sleep,0.1;
				diffusealpha,1;sleep,0.1;diffusealpha,0;);
			},
			LoadActor('tower_bricks')..{
				InitCommand=function(self) tower_p2brick2 = self end;
				OnCommand=cmd(valign,57/64;y,-220;zoom,0;animate,0;setstate,1;);
				NextBrickCommand=function(self) tower_curpiece[2] = 3 end;
				DespawnCommand=cmd(diffusealpha,1;sleep,0.1;diffusealpha,0;sleep,0.1;
				diffusealpha,1;sleep,0.1;diffusealpha,0;sleep,0.1;
				diffusealpha,1;sleep,0.1;diffusealpha,0;);
			},
			LoadActor('tower_bricks')..{
				InitCommand=function(self) tower_p2brick3 = self end;
				OnCommand=cmd(valign,57/64;y,-260;zoom,0;animate,0;setstate,2;);
				NextBrickCommand=cmd();
				DespawnCommand=cmd(diffusealpha,1;sleep,0.1;diffusealpha,0;sleep,0.1;
				diffusealpha,1;sleep,0.1;diffusealpha,0;sleep,0.1;
				diffusealpha,1;sleep,0.1;diffusealpha,0;);
			},
		},
	}
}

t[#t+1] = LoadActor("sounds/EX_Confirm.mp3")..{
	StackSoundMessageCommand=cmd(play);
}

t[#t+1] = Def.Quad{
	NoStackSoundMessageCommand=function(self)
		Sound('gung.ogg');
	end
}


t[#t+1] = LoadActor("chara")

--------------------------------------------------------------------------------


t[#t+1] = LoadActor("0")..{
	OnCommand=cmd(visible,false;sleep,999;);
	StepMessageCommand=function (self, params)
		--SCREENMAN:SystemMessage("Step "..params.Column);
	end;
	LiftMessageCommand=function (self, params)
		--SCREENMAN:SystemMessage("Lift "..params.Column);
	end;
}

t[#t+1] = LoadActor("mainbg")..{
	OnCommand=cmd(diffusealpha,0;Center;scale_or_crop_background;diffusealpha,0;);
	StartMawaruMessageCommand=cmd(glow,1,1,1,0.6;diffusealpha,1;linear,0.3;glow,1,1,1,0);
	ClearCrap1MessageCommand=cmd(visible,false);
}

t[#t+1] = LoadActor("numbers")..{
	OnCommand=cmd(animate,0;setstate,2;diffusealpha,0;Center);
	Count1MessageCommand=cmd(zoom,2;linear,0.1;zoom,1.4;diffusealpha,1;sleep,60/176;linear,0.2;diffusealpha,0);
	ClearCrap1MessageCommand=cmd(visible,false);
}
t[#t+1] = LoadActor("numbers")..{
	OnCommand=cmd(animate,0;setstate,1;diffusealpha,0;basezoomx,1.1;basezoomy,1.1;Center);
	Count2MessageCommand=cmd(zoom,2;linear,0.1;zoom,1.4;diffusealpha,1;sleep,60/176;linear,0.2;diffusealpha,0);
	ClearCrap1MessageCommand=cmd(visible,false);
}
t[#t+1] = LoadActor("numbers")..{
	OnCommand=cmd(animate,0;setstate,0;diffusealpha,0;basezoomx,1.2;basezoomy,1.2;Center);
	Count3MessageCommand=cmd(zoom,2;linear,0.1;zoom,1.4;diffusealpha,1;sleep,60/176;linear,0.2;diffusealpha,0);
	ClearCrap1MessageCommand=cmd(visible,false);
}

t[#t+1] = Def.Quad{
	TitleOnMessageCommand=cmd(Center;FullScreen;diffuse,0,0,0,0;linear,0.4;diffusealpha,0.6);
	ClearCrap1MessageCommand=cmd(visible,false);
}

t[#t+1] = LoadActor("logo_inf")..{
	OnCommand=cmd(Center;zoom,aspect/1.77778;x,SCREEN_WIDTH+640;);
	StartMawaruMessageCommand=cmd(sleep,0.2/RATEMOD;linear,0.3/RATEMOD;x,SCREEN_CENTER_X+30;decelerate,4.8*60/176/RATEMOD;Center;
	linear,0.2/RATEMOD;glow,1,1,1,0.6;linear,1/RATEMOD;glow,1,1,1,0;
	sleep,5*60/176/RATEMOD;accelerate,0.5/RATEMOD;y,SCREEN_HEIGHT+320;sleep,0;diffusealpha,0;);
	ClearCrap1MessageCommand=cmd(visible,false);
}
t[#t+1] = LoadActor("logo_maw")..{
	OnCommand=cmd(Center;zoom,aspect/1.77778;x,-640;);
	StartMawaruMessageCommand=cmd(sleep,0.2/RATEMOD;linear,0.3/RATEMOD;x,SCREEN_CENTER_X-30;decelerate,4.8*60/176/RATEMOD;Center;
	linear,0.2/RATEMOD;glow,1,1,1,0.6;linear,1/RATEMOD;glow,1,1,1,0;
	sleep,5*60/176/RATEMOD;accelerate,0.5/RATEMOD;y,-320;sleep,0;diffusealpha,0;);
	ClearCrap1MessageCommand=cmd(visible,false);
}

t[#t+1] = LoadActor("instructions")..{
	OnCommand=cmd(Center;diffusealpha,0;wag;effectclock,"bgm";effectperiod,4;effectmagnitude,0,0,2);
	InstructionsMessageCommand=cmd(zoom,1.5;linear,0.3/RATEMOD;zoom,1;diffusealpha,1;);
	RulesOffMessageCommand=cmd(linear,0.4/RATEMOD;diffusealpha,0);
}

t[#t+1] = Def.Quad{
	InitCommand=function(self)
		mawaru_black = self;
	end,
	OnCommand=cmd(Center;FullScreen;diffuse,0,0,0,0;)
}

t[#t+1] = LoadActor("screenmask")..{
	OnCommand=cmd(Center;diffuse,0,0,0,0;MaskSource),
	SpeedUpMessageCommand=cmd(diffusealpha,1);
	SpeedUpAwayMessageCommand=cmd(sleep,0.4;diffusealpha,0);
}

t[#t+1] = LoadActor("aura")..{
	InitCommand=function(self)
		mawaru_aura = self;
	end,
	OnCommand=cmd(Center;diffuse,0,1,.8,1;diffusealpha,0),
	FlashYellowMessageCommand=cmd(linear,0.4;diffuse,1,1,0,1;),
	FlashOrangeMessageCommand=cmd(linear,0.4;diffuse,1,.5,0,1;),
	FlashRedMessageCommand=cmd(linear,0.4;diffuse,1,0,0,1;),
}

t[#t+1] = LoadActor("thumb")..{
	OnCommand=cmd(x,SCREEN_CENTER_X-80;y,SCREEN_HEIGHT*0.4+20;diffusealpha,0;);
	InitCommand=function(self)
		mawaru_thumb = self
	end;
}

t[#t+1] = LoadActor("jonathan")..{
	OnCommand=cmd(x,SCREEN_CENTER_X+50;y,SCREEN_HEIGHT*0.4;diffusealpha,0;);
	InitCommand=function(self)
		mawaru_jon = self
	end;
}

t[#t+1] = LoadActor("ayaze_head")..{
	OnCommand=cmd(x,SCREEN_CENTER_X+5;zoom,1.1;y,SCREEN_HEIGHT*0.45;diffusealpha,0;wag;effectmagnitude,0,0,3;);
	InitCommand=function(self)
		mawaru_aya = self
	end;
}

for i=1,13 do
	t[#t+1] = LoadActor("text/t"..i..".png")..{
		OnCommand=cmd(Center;y,SCREEN_HEIGHT*0.4;diffusealpha,0;vibrate;effectmagnitude,2,2,2);
		InitCommand=function(self)
			_G['mawaru_text'..i] = self
		end;
	}
end

t[#t+1] = Def.ActorFrame{
	OnCommand=cmd(x,sw/2;y,sh/2),
	InitCommand=function(self)
		mawaru_cab_all = self;
	end,
	Def.ActorFrame{
		OnCommand=cmd(x,-sw/2;y,-sh/2),
		LoadActor("cutout")..{
			InitCommand=function(self)
				mawaru_cutout = self;
			end,
			OnCommand=cmd(Center;diffusealpha,0),
			FlashYellowMessageCommand=cmd(glow,0,0,0,1;linear,0.3;glow,1,1,0,.5;linear,1;glow,.2,.2,0,.5;);
			FlashOrangeMessageCommand=cmd(glow,0,0,0,1;linear,0.3;glow,1,.5,0,.5;linear,1;glow,.3,.15,0,.5;);
			FlashRedMessageCommand=cmd(glow,0,0,0,1;linear,0.3;glow,1,0,0,.5;linear,1;glow,.4,0,0,.5;);
		},
		LoadActor("speedup")..{
			OnCommand=cmd(y,SCREEN_HEIGHT*0.4-33;x,SCREEN_CENTER_X;customtexturerect,0,0,4,1;zoomx,4;texcoordvelocity,0.3,0;diffusealpha,0;MaskDest);
			SpeedUpMessageCommand=cmd(linear,0.4;diffusealpha,1);
			SpeedUpAwayMessageCommand=cmd(linear,0.4;diffusealpha,0);
		},
		LoadActor("speedup")..{
			OnCommand=cmd(y,SCREEN_HEIGHT*0.4+33;x,SCREEN_CENTER_X;customtexturerect,0,0,4,1;zoomx,4;texcoordvelocity,-0.3,0;diffusealpha,0;MaskDest);
			SpeedUpMessageCommand=cmd(linear,0.4;diffusealpha,1);
			SpeedUpAwayMessageCommand=cmd(linear,0.4;diffusealpha,0);
		},
		Def.Sprite{
			InitCommand=function(self)
				mawaru_cab = self;
			end,
			Texture="cab 2x2.png",
			Frame0000=0,
			Delay0000=0.1,
			Frame0001=1,
			Delay0001=0.1,
			Frame0002=2,
			Delay0002=0.1,
			OnCommand=cmd(Center;diffusealpha,0),
		},
		Def.ActorFrame{
			OnCommand=cmd(Center;),
			InitCommand=function(self)
				mawaru_bpmdisp = self;
			end,
			LoadActor("bpmdisplay")..{
				InitCommand=function(self)
					mawaru_bpmdispbg = self;
				end,
				OnCommand=cmd(y,SCREEN_HEIGHT*0.24;diffuse,0,1,.8,0;),
				FlashYellowMessageCommand=cmd(linear,0.4;diffuse,1,1,0,1;),
				FlashOrangeMessageCommand=cmd(linear,0.4;diffuse,1,.5,0,1;),
				FlashRedMessageCommand=cmd(linear,0.4;diffuse,1,0,0,1;),
			},
			LoadFont("zeroesone normal")..{
				InitCommand=function(self)
					mawaru_bpmdisptext = self;
				end,
				Text="130 BPM",
				OnCommand=cmd(zoomx,1.24;zoomy,1.24;y,SCREEN_HEIGHT*0.24;diffuse,0,0,0,0;);
			},
		},
		Def.Sprite{
			InitCommand=function(self)
				mawaru_inf = self;
			end,
			Texture="inf 1x3.png",
			Frame0000=0,
			Delay0000=0.1,
			Frame0001=1,
			Delay0001=0.1,
			Frame0002=2,
			Delay0002=0.1,
			OnCommand=cmd(Center;valign,0;y,0;diffusealpha,0;),
		},
		Def.Sprite{
			InitCommand=function(self)
				mawaru_bar = self;
			end,
			Texture="bar 1x3.png",
			Frame0000=0,
			Delay0000=0.1,
			Frame0001=1,
			Delay0001=0.1,
			Frame0002=2,
			Delay0002=0.1,
			OnCommand=cmd(Center;valign,1;y,SCREEN_BOTTOM;diffusealpha,0;),
		},
		LoadFont('Common/_segoe ui 24px')..{
			Text="",
			OnCommand=cmd(CenterY;x,8;halign,0;zoom,0.9;zoomx,0.85;diffusealpha,0;wrapwidthpixels,sw/3;strokecolor,0,0,0,1);
			DisplayCommand=cmd(linear,0.4;diffusealpha,1);
			SpeedUpMessageCommand=cmd(linear,0.4;diffusealpha,0);
			OpenDoorsMessageCommand=cmd(linear,0.4;diffusealpha,0);
			InitCommand=function(self)
				mawaru_bonustext1 = self;
			end,
		},
		LoadFont('Common/_segoe ui 24px')..{
			Text="",
			OnCommand=cmd(CenterY;x,sw-8;halign,1;zoom,0.9;zoomx,0.85;diffusealpha,0;wrapwidthpixels,sw/3;strokecolor,0,0,0,1);
			DisplayCommand=cmd(linear,0.4;diffusealpha,1);
			SpeedUpMessageCommand=cmd(linear,0.4;diffusealpha,0);
			OpenDoorsMessageCommand=cmd(linear,0.4;diffusealpha,0);
			InitCommand=function(self)
				mawaru_bonustext2 = self;
			end,
		},
	}
}

t[#t+1] = LoadActor('yes')..{
	OnCommand=cmd(zoomto,SCREEN_WIDTH,SCREEN_HEIGHT;x,SCREEN_CENTER_X;y,SCREEN_CENTER_Y;diffusealpha,0);
	YesMessageCommand=cmd(diffusealpha,1;accelerate,120/140;diffusealpha,0);
}

-----------------------------------------------------------------------------------

t[#t+1] = LoadFont("zeroesone normal")..{
	Text="Ratings\n0",
	OnCommand=cmd(diffusealpha,0;zoomx,1;zoomy,1;halign,0;valign,1;x,12;y,sh-12;strokecolor,0,0,0,1;);
	Condition=GAMESTATE:IsPlayerEnabled('PlayerNumber_P1');
	HideRatingsMessageCommand=cmd(linear,0.4;diffusealpha,0);
	UpdateRatingsP1MessageCommand=function(self)
		self:settext('Ratings\n'..mawaru_ratings[1])
		self:diffusealpha(1);
		self:glow(1,1,1,1);
		self:linear(0.2);
		self:glow(1,1,1,0);
	end
}
t[#t+1] = LoadFont("zeroesone normal")..{
	Text="Ratings\n0",
	OnCommand=cmd(diffusealpha,0;zoomx,1;zoomy,1;halign,1;valign,1;x,sw-12;y,sh-12;strokecolor,0,0,0,1;);
	Condition=GAMESTATE:IsPlayerEnabled('PlayerNumber_P2');
	HideRatingsMessageCommand=cmd(linear,0.4;diffusealpha,0);
	UpdateRatingsP2MessageCommand=function(self)
		self:settext('Ratings\n'..mawaru_ratings[2])
		self:diffusealpha(1);
		self:glow(1,1,1,1);
		self:linear(0.2);
		self:glow(1,1,1,0);
	end
}



t[#t+1] = Def.Quad{
	OnCommand=cmd(visible,false);
	JudgmentMessageCommand=function(self,params)
		local b = GAMESTATE:GetSongBeat()
		for pn = 1,2 do
			if params.Player == 'PlayerNumber_P'..pn then
				--Trace('Judgment '..params.TapNoteScore);
				if params.TapNoteScore == 'TapNoteScore_W1' then
					mawaru_countjudgments[pn][1] = mawaru_countjudgments[pn][1]+1
				end
				if params.TapNoteScore == 'TapNoteScore_CheckpointHit' then
					mawaru_countjudgments[pn][1] = mawaru_countjudgments[pn][1]+1
				end
				if params.TapNoteScore == 'TapNoteScore_W2' then
					mawaru_countjudgments[pn][2] = mawaru_countjudgments[pn][2]+1
				end
				if params.TapNoteScore == 'TapNoteScore_W3' then
					mawaru_countjudgments[pn][3] = mawaru_countjudgments[pn][3]+1
				end
				if params.TapNoteScore == 'TapNoteScore_W4' then
					mawaru_countjudgments[pn][4] = mawaru_countjudgments[pn][4]+1
				end
				if params.TapNoteScore == 'TapNoteScore_W5' then
					mawaru_countjudgments[pn][5] = mawaru_countjudgments[pn][5]+1
					mawaru_countjudgments[pn].cb = mawaru_countjudgments[pn].cb+1
					if b > 168.5 and beat <= 170.5 then
						mawaru_24thmisses[pn] = mawaru_24thmisses[pn]+1;
					end
				end
				if params.TapNoteScore == 'TapNoteScore_Miss' then
					mawaru_countjudgments[pn][6] = mawaru_countjudgments[pn][6]+1
					mawaru_countjudgments[pn].cb = mawaru_countjudgments[pn].cb+1
					if b > 168.5 and beat <= 170.5 then
						mawaru_24thmisses[pn] = mawaru_24thmisses[pn]+1;
					end
				end
				if params.TapNoteScore == 'TapNoteScore_CheckpointMiss' then
					mawaru_countjudgments[pn][6] = mawaru_countjudgments[pn][6]+1
					mawaru_countjudgments[pn].cb = mawaru_countjudgments[pn].cb+1
					if b > 168.5 and beat <= 170.5 then
						mawaru_24thmisses[pn] = mawaru_24thmisses[pn]+1;
					end
				end
			end
		end
	end
}

t[#t+1] = Def.Sprite{
	OnCommand=cmd(visible,false);
	JudgePlayersMessageCommand=function(self)
		
		local correct = {0,0}
		local allfailed = true;
		
		mawaru_prevratings = {0,0}
		
		--judge individual games
		for pn=1,2 do
			if GAMESTATE:IsPlayerEnabled('PlayerNumber_P'..pn) then
			
				mawaru_prevratings[pn] = mawaru_ratings[pn]
			
				local stats = STATSMAN:GetCurStageStats():GetPlayerStageStats('PlayerNumber_P'..pn);
				local mines = 0;
				if stats then
					mines = stats:GetTapNoteScores("TapNoteScore_HitMine");
				end
			
				Trace('Misses: '..tostring(mawaru_countjudgments[pn].cb));
				Trace('Greats: '..tostring(mawaru_countjudgments[pn][3]));
				Trace('Goods: '..tostring(mawaru_countjudgments[pn][4]));
				
				if mawaru_thisgame == 1 then
					mawaru_message[pn] = '+100 Nice!';
					add_ratings(pn,100);
					if mawaru_countjudgments[pn].cb == 0 then
						mawaru_message[pn] = mawaru_message[pn]..'\n+300 (No Misses!)'
						add_ratings(pn,300);
					end
					mawaru_mcol[pn] = 1
					correct[pn] = 1
					
					if mawaru_countjudgments[pn][3] == 1 then
						mawaru_message[pn] = mawaru_message[pn]..'\n+50 (Green Flag)'
						add_ratings(pn,50);
						Trace('green flag');
					end
					if mawaru_countjudgments[pn][4] == 1 then
						mawaru_message[pn] = mawaru_message[pn]..'\n+50 (Yellow Flag)'
						add_ratings(pn,50);
						Trace('yellow flag');
					end
					
				end
				if mawaru_thisgame == 2 then
					Trace('Mines: '..mines);
					mawaru_message[pn] = ''
					mawaru_mcol[pn] = 0
					if mines == mawaru_mine_amts[pn][1] then
						mawaru_message[pn] = '+1000 (Hit all mines)'
						add_ratings(pn,1000);
						mawaru_mcol[pn] = mawaru_mcol[pn]+1;
						correct[pn] = 1
					elseif mines > mawaru_mine_amts[pn][2] then
						mawaru_message[pn] = '+400 (Hit some mines)'
						add_ratings(pn,400);
						mawaru_mcol[pn] = mawaru_mcol[pn]+1;
						correct[pn] = 1
					else
						mawaru_message[pn] = '+0 (Stop being bad.)'
						add_ratings(pn,0);
						mawaru_mcol[pn] = mawaru_mcol[pn]-1;
						correct[pn] = 0
					end
					if mawaru_countjudgments[pn].cb == 0 then
						mawaru_message[pn] = mawaru_message[pn]..'\n+200 (No Misses!)'
						add_ratings(pn,200);
						mawaru_mcol[pn] = mawaru_mcol[pn]+1;
					end
				end
				if mawaru_thisgame == 3 then
					mawaru_message[pn] = ''
					mawaru_mcol[pn] = 0
					if dm_score[pn] == 2 then
						mawaru_message[pn] = '+800 (All correct!)'
						add_ratings(pn,800);
						mawaru_mcol[pn] = mawaru_mcol[pn]+1;
						correct[pn] = 1
					elseif dm_score[pn] == 1 then
						mawaru_message[pn] = '+400 (Half correct)'
						add_ratings(pn,400);
						mawaru_mcol[pn] = mawaru_mcol[pn]+1;
						correct[pn] = 0
					else
						mawaru_message[pn] = '-200 (All Wrong)'
						add_ratings(pn,-200);
						mawaru_mcol[pn] = mawaru_mcol[pn]-1;
						correct[pn] = 0
					end
					if mawaru_countjudgments[pn].cb == 0 then
						mawaru_message[pn] = mawaru_message[pn]..'\n+100 (No Misses!)'
						add_ratings(pn,100);
						mawaru_mcol[pn] = mawaru_mcol[pn]+1;
					end
				end
				
				if mawaru_thisgame == 4 then
					mawaru_message[pn] = ''
					mawaru_mcol[pn] = 0
					if mawaru_countjudgments[pn].cb == 0 then
						mawaru_message[pn] = mawaru_message[pn]..'+800 (No Misses!)'
						add_ratings(pn,800);
						mawaru_mcol[pn] = mawaru_mcol[pn]+1;
						correct[pn] = 1
					elseif mawaru_countjudgments[pn].cb == 1 then
						mawaru_message[pn] = mawaru_message[pn]..'+400 (1 Miss!)'
						add_ratings(pn,400);
						mawaru_mcol[pn] = mawaru_mcol[pn]+1;
						correct[pn] = 1
					elseif mawaru_countjudgments[pn].cb < 5 then
						mawaru_message[pn] = mawaru_message[pn]..'+100 (<5 Misses!)'
						add_ratings(pn,100);
						mawaru_mcol[pn] = mawaru_mcol[pn]+1;
						correct[pn] = 1
					else
						mawaru_message[pn] = mawaru_message[pn]..'-100 (Many Misses!)'
						add_ratings(pn,-100);
						mawaru_mcol[pn] = mawaru_mcol[pn]-1;
						correct[pn] = 0
					end
					if mawaru_countjudgments[pn][3] == 1 or mawaru_countjudgments[pn][4] == 1 then
						mawaru_message[pn] = mawaru_message[pn]..'\n+50 (Summoning Roberto)'
						add_ratings(pn,50);
						mawaru_mcol[pn] = mawaru_mcol[pn]+1;
					end
				end
				
				if mawaru_thisgame == 5 then
					mawaru_message[pn] = ''
					mawaru_mcol[pn] = 0
					if mawaru_24thmisses[pn] == 0 then
						mawaru_message[pn] = mawaru_message[pn].."+800 (Hit all 24ths!)"
						add_ratings(pn,800);
						mawaru_mcol[pn] = mawaru_mcol[pn]+1;
						correct[pn] = 1
					elseif mawaru_24thmisses[pn] == 1 then
						mawaru_message[pn] = mawaru_message[pn]..'+400 (1 24th Miss)'
						add_ratings(pn,400);
						mawaru_mcol[pn] = mawaru_mcol[pn]+1;
						correct[pn] = 1
					else
						mawaru_message[pn] = mawaru_message[pn]..'-100 (Objective failed!)'
						add_ratings(pn,-100);
						mawaru_mcol[pn] = mawaru_mcol[pn]-1;
						correct[pn] = 0
					end
					if mawaru_countjudgments[pn].cb == 0 then
						mawaru_message[pn] = mawaru_message[pn]..'\n+500 (Full Combo!)'
						add_ratings(pn,500);
						mawaru_mcol[pn] = mawaru_mcol[pn]+1
					end
					if mawaru_countjudgments[pn][3] == 1 or mawaru_countjudgments[pn][4] == 1 then
						mawaru_message[pn] = mawaru_message[pn]..'\n+50 (Summoning Roberto)'
						add_ratings(pn,50);
						mawaru_mcol[pn] = mawaru_mcol[pn]+1;
					end
				end
				
				if mawaru_thisgame == 6 then
					mawaru_message[pn] = ''
					mawaru_mcol[pn] = 0
					if mawaru_countjudgments[pn].cb == 0 then
						mawaru_message[pn] = mawaru_message[pn]..'+600 (No Misses!)'
						add_ratings(pn,600);
						mawaru_mcol[pn] = mawaru_mcol[pn]+1;
						correct[pn] = 1
					elseif mawaru_countjudgments[pn].cb == 1 then
						mawaru_message[pn] = mawaru_message[pn]..'+300 (1 Miss!)'
						add_ratings(pn,300);
						mawaru_mcol[pn] = mawaru_mcol[pn]+1;
						correct[pn] = 1
					elseif mawaru_countjudgments[pn].cb < 3 then
						mawaru_message[pn] = mawaru_message[pn]..'+200 (<3 Misses!)'
						add_ratings(pn,200);
						mawaru_mcol[pn] = mawaru_mcol[pn]+1;
						correct[pn] = 1
					else
						mawaru_message[pn] = mawaru_message[pn]..'-100 (Many Misses!)'
						add_ratings(pn,-100);
						mawaru_mcol[pn] = mawaru_mcol[pn]-1;
						correct[pn] = 0
					end
					if mawaru_countjudgments[pn][3] == 1 or mawaru_countjudgments[pn][4] == 1 then
						mawaru_message[pn] = mawaru_message[pn]..'\n+50 (Summoning Roberto)'
						add_ratings(pn,50);
						mawaru_mcol[pn] = mawaru_mcol[pn]+1;
					end
				end
				
				if mawaru_thisgame == 7 then
					mawaru_message[pn] = ''
					mawaru_mcol[pn] = 0
					if mawaru_countjudgments[pn].cb == 0 then
						mawaru_message[pn] = mawaru_message[pn]..'+800 (No Misses!)'
						add_ratings(pn,800);
						mawaru_mcol[pn] = mawaru_mcol[pn]+1;
						correct[pn] = 1
					elseif mawaru_countjudgments[pn].cb < 3 then
						mawaru_message[pn] = mawaru_message[pn]..'+400 (<3 Misses)'
						add_ratings(pn,400);
						mawaru_mcol[pn] = mawaru_mcol[pn]+1;
						correct[pn] = 1
					elseif mawaru_countjudgments[pn].cb < 6 then
						mawaru_message[pn] = mawaru_message[pn]..'+200 (<6 Misses!)'
						add_ratings(pn,200);
						mawaru_mcol[pn] = mawaru_mcol[pn]+1;
						correct[pn] = 1
					else
						mawaru_message[pn] = mawaru_message[pn]..'-100 (Many Misses!)'
						add_ratings(pn,-100);
						mawaru_mcol[pn] = mawaru_mcol[pn]-1;
						correct[pn] = 0
					end
				end
				
				if mawaru_thisgame == 8 then
					mawaru_message[pn] = ''
					mawaru_mcol[pn] = 0
					if mawaru_bs_correct[pn] then
						mawaru_message[pn] = mawaru_message[pn]..'+1000 (Correct!!)'
						add_ratings(pn,1000);
						mawaru_mcol[pn] = mawaru_mcol[pn]+1;
						correct[pn] = 1
					else
						mawaru_message[pn] = mawaru_message[pn]..'-200 (WRONG)'
						add_ratings(pn,-200);
						mawaru_mcol[pn] = mawaru_mcol[pn]-1;
						correct[pn] = 0
					end
				end 
				
				if mawaru_thisgame == 9 then
					mawaru_message[pn] = ''
					mawaru_mcol[pn] = 0
					if mawaru_countjudgments[pn].cb == 0 then
						mawaru_message[pn] = mawaru_message[pn]..'+1500 (No Misses!)'
						add_ratings(pn,1500);
						mawaru_mcol[pn] = mawaru_mcol[pn]+1;
						correct[pn] = 1
					elseif mawaru_countjudgments[pn].cb == 1 then
						mawaru_message[pn] = mawaru_message[pn]..'+1000 (1 Miss!)'
						add_ratings(pn,1000);
						mawaru_mcol[pn] = mawaru_mcol[pn]+1;
						correct[pn] = 1
					elseif mawaru_countjudgments[pn].cb < 5 then
						mawaru_message[pn] = mawaru_message[pn]..'+500 (<5 Misses!)'
						add_ratings(pn,500);
						mawaru_mcol[pn] = mawaru_mcol[pn]+1;
						correct[pn] = 1
					else
						mawaru_message[pn] = mawaru_message[pn]..'-100 (Many Misses!)'
						add_ratings(pn,-100);
						mawaru_mcol[pn] = mawaru_mcol[pn]-1;
						correct[pn] = 0
					end
					if mawaru_countjudgments[pn][3] == 1 or mawaru_countjudgments[pn][4] == 1 then
						mawaru_message[pn] = mawaru_message[pn]..'\n+500 (Summoning Roberto)'
						add_ratings(pn,500);
						mawaru_mcol[pn] = mawaru_mcol[pn]+1;
					end
				end
				
				if mawaru_thisgame == 10 then
					mawaru_message[pn] = ''
					mawaru_mcol[pn] = 0
					if not botw_dead[pn] then
						mawaru_message[pn] = mawaru_message[pn]..'+1000 (Didn\'t die!)'
						add_ratings(pn,1000);
						mawaru_mcol[pn] = mawaru_mcol[pn]+1;
						correct[pn] = 1
					elseif botw_alivetime[pn] > 390 then
						mawaru_message[pn] = mawaru_message[pn]..'+500 (Halfway there)'
						add_ratings(pn,500);
						correct[pn] = 0
					else
						mawaru_message[pn] = mawaru_message[pn]..'-100 (Oops...)'
						add_ratings(pn,-100);
						mawaru_mcol[pn] = mawaru_mcol[pn]-1;
						correct[pn] = 0
					end
				end
				
				if mawaru_thisgame == 11 then
					mawaru_message[pn] = ''
					mawaru_mcol[pn] = 0
					if mawaru_horse_pos[pn] == 1 then
						mawaru_message[pn] = mawaru_message[pn]..'+1000 (First place!!)'
						add_ratings(pn,1000);
						mawaru_mcol[pn] = mawaru_mcol[pn]+1;
						correct[pn] = 1
					elseif mawaru_horse_pos[pn] == 2 then
						mawaru_message[pn] = mawaru_message[pn]..'+100 (Second place)'
						add_ratings(pn,100);
						correct[pn] = 1
					elseif mawaru_horse_pos[pn] == 3 then
						mawaru_message[pn] = mawaru_message[pn]..'+10 (Third place)'
						add_ratings(pn,10);
						correct[pn] = 1
					elseif mawaru_horse_pos[pn] > 3 then
						mawaru_message[pn] = mawaru_message[pn]..'-50 (Bad place)'
						add_ratings(pn,-50);
						mawaru_mcol[pn] = mawaru_mcol[pn]-1;
						correct[pn] = 0
					end
				end
				
				if mawaru_thisgame == 12 then
					mawaru_message[pn] = ''
					mawaru_mcol[pn] = 0
					if tower_stacked[pn] == 3 then
						mawaru_message[pn] = mawaru_message[pn]..'+1200 (Stack 3!!)'
						add_ratings(pn,1000);
						mawaru_mcol[pn] = mawaru_mcol[pn]+1;
						correct[pn] = 1
					elseif tower_stacked[pn] == 2 then
						mawaru_message[pn] = mawaru_message[pn]..'+1000 (Stack 2!)'
						add_ratings(pn,500);
						mawaru_mcol[pn] = mawaru_mcol[pn]+1;
						correct[pn] = 1
					elseif tower_stacked[pn] == 1 then
						mawaru_message[pn] = mawaru_message[pn]..'+100 (Stack 1)'
						add_ratings(pn,100);
						correct[pn] = 0
					else
						mawaru_message[pn] = mawaru_message[pn]..'-100 (Oops...)'
						add_ratings(pn,-100);
						mawaru_mcol[pn] = mawaru_mcol[pn]-1;
						correct[pn] = 0
					end
				end
				
				if mawaru_thisgame == 13 then
					mawaru_message[pn] = '+2000 (Boss defeated!)';
					add_ratings(pn,2000);
					if mawaru_countjudgments[pn].cb == 0 then
						mawaru_message[pn] = mawaru_message[pn]..'\n+1500 (No Misses!)'
						add_ratings(pn,1500);
					elseif mawaru_countjudgments[pn].cb < 10 then
						mawaru_message[pn] = mawaru_message[pn]..'\n+1000 (<10 Misses!)'
						add_ratings(pn,1000);
					elseif mawaru_countjudgments[pn].cb < 20 then
						mawaru_message[pn] = mawaru_message[pn]..'\n+500 (<20 Misses!)'
						add_ratings(pn,500);
					elseif mawaru_countjudgments[pn].cb < 30 then
						mawaru_message[pn] = mawaru_message[pn]..'\n+300 (<30 Misses!)'
						add_ratings(pn,300);
					end
					mawaru_mcol[pn] = 1
					correct[pn] = 1
					
					if mawaru_countjudgments[pn][3] == 1 or mawaru_countjudgments[pn][4] == 1 then
						mawaru_message[pn] = mawaru_message[pn]..'\n+1000 (Summoned Roberto)'
						add_ratings(pn,1000);
					end
					
					if mawaru_ratings[pn] > 0 then
						mawaru_message[pn] = mawaru_message[pn]..'\n\nRatings bonus:\n'..mawaru_ratings[pn]..' = +'..(mawaru_ratings[pn]/200)..'%'
						mawaru_message[pn] = mawaru_message[pn]..'\n(+'..(mawaru_ratings[pn]*100)..' score)'
					else
						mawaru_message[pn] = mawaru_message[pn]..'\n\nRatings anti-bonus:\n'..mawaru_ratings[pn]..' = '..(mawaru_ratings[pn]/200)..'%'
						mawaru_message[pn] = mawaru_message[pn]..'\n('..(mawaru_ratings[pn]*100)..' score)'
						mawaru_mcol[pn] = 0
					end
					
					local PSS = STATSMAN:GetCurStageStats():GetPlayerStageStats('PlayerNumber_P'..pn);
					PSS:SetScore(PSS:GetScore()+(mawaru_ratings[pn]*100));
					
					local poss = PSS:GetPossibleDancePoints()
					local act = PSS:GetActualDancePoints()
					local bonus = ((mawaru_ratings[pn]/200)*(poss/100))
					--PSS:SetActualDancePoints(act+bonus);
					
				end
				
				if mawaru_prevratings[pn] ~= mawaru_ratings[pn] then
					MESSAGEMAN:Broadcast('UpdateRatingsP'..pn,{Ratings = mawaru_ratings[pn]});
				end
				
				mawaru_prevratings[pn] = mawaru_ratings[pn]
				
				local st = _G['mawaru_bonustext'..pn]
				if mawaru_mcol[pn] > 0 then
					st:diffuse(0,1,0,0);
				elseif mawaru_mcol[pn] < 0 then
					st:diffuse(1,0,0,0);
				else
					st:diffuse(1,1,1,0);
				end
				
				st:settext(mawaru_message[pn]);
				st:queuecommand('Display');
				
			end
		end
		
		mawaru_maxratings = math.max(mawaru_ratings[1],mawaru_ratings[2])
		
		if correct[1] == 1 or correct[2] == 1 then
			allfailed = false
		end
		
		if GAMESTATE:GetSongBeat() < 650 then
			if allfailed then
				Sound('wrong.ogg')
			else
				Sound('good.ogg')
			end
		end
		
		mawaru_jon:x((sw*0.5)+50);
		mawaru_jon:y(sh*0.4);
		mawaru_jon:zoom(1);
		mawaru_jon:diffusealpha(1);
		mawaru_jon:animate(false);
		
		if allfailed then
			mawaru_jon:setstate(2);
		else
			mawaru_jon:setstate(1);
		end
		
		mawaru_jon:wag();
		mawaru_jon:effectperiod(2);
		mawaru_jon:effectmagnitude(0,0,5);
		mawaru_jon:effectclock('bgm');
		
		mawaru_thumb:x((sw*0.5)-70);
		mawaru_thumb:y((sh*0.4)+20);
		mawaru_thumb:diffusealpha(1);
		mawaru_thumb:zoom(1);
		mawaru_thumb:animate(false);
		if allfailed then
			mawaru_thumb:setstate(1);
		else
			mawaru_thumb:setstate(0);
		end
		mawaru_thumb:bounce();
		mawaru_thumb:effecttiming(0.2,0,0.2,0.6,0);
		mawaru_thumb:effectmagnitude(0,-20,0);
		mawaru_thumb:effectclock('bgm');
		--effecttiming( float ramp_to_half, float hold_at_half, float ramp_to_full, float hold_at_zero, float hold_at_full )
		
		mawaru_resetjcount();
		mawaru_thisgame = mawaru_thisgame+1;
	end
}

function mawaru_closedoor(bpm)
	local tt = (120/bpm)/RATEMOD
	
	mawaru_black:diffusealpha(0);
	mawaru_black:linear(tt);
	mawaru_black:diffusealpha(1);
	if GAMESTATE:GetSongBeat() > 50 then
		mawaru_black:queuemessage('JudgePlayers');
	end
	
	mawaru_bpmdisp:zoom(1.5);
	mawaru_bpmdisp:linear(tt);
	mawaru_bpmdisp:zoom(1);
	
	mawaru_bpmdispbg:diffusealpha(0);
	mawaru_bpmdispbg:linear(tt);
	mawaru_bpmdispbg:diffusealpha(1);
	
	mawaru_bpmdisptext:diffusealpha(0);
	mawaru_bpmdisptext:linear(tt);
	mawaru_bpmdisptext:diffusealpha(1);
	
	mawaru_aura:zoom(1.5);
	mawaru_aura:diffusealpha(0);
	mawaru_aura:linear(tt);
	mawaru_aura:zoom(1);
	mawaru_aura:diffusealpha(1);
	
	mawaru_cutout:zoom(1.5);
	mawaru_cutout:diffusealpha(0);
	mawaru_cutout:linear(tt);
	mawaru_cutout:zoom(1);
	mawaru_cutout:diffusealpha(2);
	
	mawaru_cab:zoom(1.5);
	mawaru_cab:diffusealpha(0);
	mawaru_cab:linear(tt);
	mawaru_cab:zoom(1);
	mawaru_cab:diffusealpha(1);
	
	mawaru_bar:y(sh*1.25);
	mawaru_bar:zoom(1.5);
	mawaru_bar:diffusealpha(0);
	mawaru_bar:linear(tt);
	mawaru_bar:zoom(1);
	mawaru_bar:diffusealpha(1);
	mawaru_bar:y(sh);
	
	mawaru_inf:y(sh*-0.25);
	mawaru_inf:zoom(1.5);
	mawaru_inf:diffusealpha(0);
	mawaru_inf:linear(tt);
	mawaru_inf:zoom(1);
	mawaru_inf:diffusealpha(1);
	mawaru_inf:y(0);
end

mawaru_textn = 1;

function mawaru_opendoor(bpm,rot)
	local tt = (120/bpm)/RATEMOD
	
	local mp = 1
	
	if rot then
		mawaru_cab_all:rotationz(0);
		mawaru_cab_all:linear(tt)
		mawaru_cab_all:rotationz(30);
		mawaru_cab_all:sleep(0);
		mawaru_cab_all:rotationz(0);
		mp = 1.5
	end
	
	mawaru_bpmdisp:zoom(1);
	mawaru_bpmdisp:linear(tt);
	mawaru_bpmdisp:zoom(2);
	
	mawaru_bpmdispbg:diffusealpha(1);
	mawaru_bpmdispbg:linear(tt);
	mawaru_bpmdispbg:diffusealpha(0);
	
	mawaru_bpmdisptext:diffusealpha(1);
	mawaru_bpmdisptext:linear(tt);
	mawaru_bpmdisptext:diffusealpha(0);
	
	mawaru_black:diffusealpha(1);
	mawaru_black:linear(tt);
	mawaru_black:diffusealpha(0);
	
	mawaru_aura:zoom(1);
	mawaru_aura:diffusealpha(1);
	mawaru_aura:linear(tt);
	mawaru_aura:zoom(2*mp);
	mawaru_aura:diffusealpha(0);
	
	mawaru_cutout:zoom(1);
	mawaru_cutout:diffusealpha(2);
	mawaru_cutout:linear(tt);
	mawaru_cutout:zoom(2.00*mp);
	mawaru_cutout:diffusealpha(0);
	mawaru_cutout:glow(1,1,1,0);
	
	mawaru_cab:zoom(1);
	mawaru_cab:diffusealpha(1);
	mawaru_cab:linear(tt);
	mawaru_cab:zoom(2.00*mp);
	mawaru_cab:diffusealpha(0);
	
	mawaru_bar:y(sh);
	mawaru_bar:zoom(1);
	mawaru_bar:diffusealpha(1);
	mawaru_bar:linear(tt);
	mawaru_bar:zoom(2.00);
	mawaru_bar:diffusealpha(0);
	mawaru_bar:y(sh*1.50);
	
	mawaru_inf:y(0);
	mawaru_inf:zoom(1);
	mawaru_inf:diffusealpha(1);
	mawaru_inf:linear(tt);
	mawaru_inf:zoom(2.00);
	mawaru_inf:diffusealpha(0);
	mawaru_inf:y(sh*-0.50);
	
	_G['mawaru_text'..mawaru_textn]:diffusealpha(1);
	_G['mawaru_text'..mawaru_textn]:zoom(0.6);
	_G['mawaru_text'..mawaru_textn]:linear(tt);
	_G['mawaru_text'..mawaru_textn]:zoom(1);
	_G['mawaru_text'..mawaru_textn]:zoomx(SCREEN_WIDTH/640);
	_G['mawaru_text'..mawaru_textn]:Center();
	_G['mawaru_text'..mawaru_textn]:linear(tt);
	_G['mawaru_text'..mawaru_textn]:diffusealpha(0);
	
	if not rot then
		mawaru_jon:linear(tt);
		mawaru_jon:zoom(2);
		mawaru_jon:diffusealpha(0);
		mawaru_jon:addy(sh*-0.1);
		mawaru_jon:addx(sw*0.07);
		
		mawaru_thumb:linear(tt);
		mawaru_thumb:zoom(2);
		mawaru_thumb:diffusealpha(0);
		mawaru_thumb:addy(sh*-0.1);
		mawaru_thumb:addx(sh*-0.12);
	else
		mawaru_aya:linear(tt);
		mawaru_aya:zoom(2);
		mawaru_aya:diffusealpha(0);
	end
	
	MESSAGEMAN:Broadcast('OpenDoors');
	
end

function mawaru_dotext(bpm,text)
	local tt = (120/bpm)/RATEMOD
	_G['mawaru_text'..text]:diffusealpha(0);
	_G['mawaru_text'..text]:zoom(0.8);
	_G['mawaru_text'..text]:linear(tt);
	_G['mawaru_text'..text]:zoom(0.6);
	_G['mawaru_text'..text]:diffusealpha(1);
	
	mawaru_jon:setstate(0);
	mawaru_thumb:setstate(0);
	
	MESSAGEMAN:Broadcast('SpeedUpAway');
	
	mawaru_textn = text;
end

--alternates a mod back and forth before resetting to 0
--beat,num,div,amt,spdmult,mod,pn
function mod_wiggle(beat,num,div,amt,spdmult,mod,pn,first)
	local fluct = 1
	for i=0,(num-1) do
		b = beat+(i/div)
		local m = 1
		if i==0 and not first then m = 0.5 end
		table.insert(mods,{b,'*'..math.abs(spdmult*m*amt/10)..' '..(amt*fluct)..' '..mod..'',pn});
		fluct = fluct*-1;
	end
	table.insert(mods,{beat+(num/div),'*'..math.abs(spdmult*amt/20)..' no '..mod..'',pn});
end

function simple_m0d2(beat,strength,mult,mod,pn)
	if not strength then strength = 400 end
	if not mult then mult = 1 end
	if not mod then mod = 'drunk' end
	
	table.insert(mods,{beat,'*'..math.abs(strength/10)..' '..strength..' '..mod,pn});
	table.insert(mods,{beat+.3,'*'..((1/mult)*math.abs(strength)/100)..' no '..mod,pn});
end

--lua course :D	/ timed mod management	
curmod = 1;
--{beat,mod,player}
mods = {
	{364,'10 reverse,*10000 -20000 move0,*10000 -20000 move1,*10000 20000 move3,*10000 20000 move4'},
	{408,'no reverse,*10000 no move0,*10000 no move1,*10000 no move3,*10000 no move4'},
	
	{513-.1,'*5 100 hallway'},
	{515-.1,'*5 66 hallway'},
	{516-.1,'*5 33 hallway'},
	
	{521.0-.05,'*10 100 drunk, *0.18 25 reverse'},
	{521.5-.05,'*20 -100 drunk, *0.18 25 reverse'},
	{522.0-.05,'*20 100 drunk, *0.18 25 reverse'},
	{522.5-.05,'*20 -100 drunk, *0.18 25 reverse'},
	{523.0-.05,'*20 100 drunk, *0.18 25 reverse'},
	{523.5-.05,'*20 -100 drunk, *0.18 25 reverse'},
	{524.0-.05,'*20 100 drunk, *0.18 25 reverse'},
	{524.5-.05,'*20 -100 drunk, *0.18 25 reverse'},
	{525.0-.05,'*10 no drunk, *5 50 reverse'},
	{526.0-.05,'*10 no reverse'},
	
	{529.0-.05,'*10 100 drunk, *0.18 25 reverse'},
	{529.5-.05,'*20 -100 drunk, *0.18 25 reverse'},
	{530.0-.05,'*20 100 drunk, *0.18 25 reverse'},
	{530.5-.05,'*20 -100 drunk, *0.18 25 reverse'},
	{531.0-.05,'*20 100 drunk, *0.18 25 reverse'},
	{531.5-.05,'*20 -100 drunk, *0.18 25 reverse'},
	{532.0-.05,'*20 100 drunk, *0.18 25 reverse'},
	{532.5-.05,'*20 -100 drunk, *0.18 25 reverse'},
	{533.0-.05,'*10 no drunk, *5 50 reverse'},
	{534.0-.05,'*10 no reverse, *10 100 mini, *5 50 centered'},
	
	{536.5,'*1000 200 beat'},
	{537-.05,'*2 75 mini, *1 37 centered'},
	{538-.05,'*2 50 mini, *1 25 centered'},
	{539-.05,'*2 25 mini, *1 12 centered'},
	{540-.05,'*2 0 mini, *1 0 centered'},
	{540.5,'*1000 no beat'},
	
	{541-.1,'*10 hallway'},
	{543-.1,'*5 50 hallway'},
	
	{545-.1,'*5 no hallway, *10 move0, *10 -100 move1, *10 move3, *10 -100 move4'},
	{546.5-.1,'*10 no move0, *10 no move1, *10 no move3, *10 no move4'},
	{547-.1,'*10 move0, *10 -100 move1, *10 move3, *10 -100 move4'},
	{548.5-.1,'*10 no move0, *10 no move1, *10 no move3, *10 no move4'},
	
	{549.5,'*4 mini'},
	{550.0,'*4 no mini'},
	{550.5,'*4 mini'},
	{551.0,'*4 no mini'},
	
	{557.5,'*4 mini'},
	{558.0,'*4 no mini'},
	{558.5,'*4 mini'},
	{559.0,'*4 no mini'},
	
	{567,'*10000 2512 dizzy'},
	{573,'*10 reverse'},
	{581,'*10 no reverse, *10000 no dizzy'},
	
	{591.0,'*2 50 alternate'},
	{591.5,'*2 no alternate'},
	{592.0,'*2 50 alternate'},
	{592.5,'*2 no alternate'},
	
	{595.0,'*2 -50 alternate, *2 50 reverse'},
	{595.5,'*2 no alternate, *2 no reverse'},
	{596.0,'*2 -50 alternate, *2 50 reverse'},
	{596.5,'*2 no alternate, *2 no reverse'},
	
	{597,'*3 130 wave'},
	{605,'no wave'},
	
	{628.5,'*3 130 wave'},
	{630,'*3 50 wave'},
	
	{645,'*10 no wave'},
	
	{647,'*10000 5 reverse'},
	{647.25,'*10000 10 reverse'},
	{647.5,'*10000 15 reverse'},
	{647.75,'*10000 20 reverse'},
	{648,'*10000 25 reverse'},
	{648.25,'*10000 30 reverse'},
	{648.5,'*10000 35 reverse'},
	{648.75,'*10000 40 reverse'},
	{649,'*10000 no reverse'},
	
	{656,'50 bumpy'},
	
	{672,'*4 3000 drunk, *0.5 stealth'},
	
	{999,'3x'},
	
}

for i=0,7 do
	simple_m0d2(604.9+i,80,0.3,'brake');
end
for i=0,3 do
	simple_m0d2(636.9+i,80,0.3,'brake');
end

simple_m0d2(517-.1,200,2,'distant');
simple_m0d2(549-.1,20,1.5,'reverse');

--action table
curaction = 1
actions = {
	
	{0,'Count1'},
	{1,'Count2'},
	{2,'Count3'},
	{3,'StartMawaru'},
	{4,'TitleOn'},
	{20,'UpdateRatingsP1'},
	{20,'UpdateRatingsP2'},
	{20,'Instructions'},
	{24,'SetMe'},
	{32,'RulesOff'},
	{32,function() mawaru_closedoor(88*2) end},
	{33,function() mawaru_dotext(130*2,1) end},
	{36,'ClearCrap1'},
	{42,function() mawaru_opendoor(130*4) end},
	
	--[[{43,function()
		for pn=1,2 do
			if _G['P'..pn] then
				--Notefield cannot use rotationz.
				local nf = SCREENMAN:GetTopScreen():GetChild('PlayerP'..pn):GetChild("NoteField")
				local prevY = nf:GetY();
				nf:y(-prevY)
				_G['P'..pn]:y(SCREEN_CENTER_Y)
				_G['P'..pn]:accelerate(120/162/RATEMOD);
				_G['P'..pn]:rotationz(-180);
				_G['P'..pn]:decelerate(120/162/RATEMOD);
				_G['P'..pn]:rotationz(-360);
				_G['P'..pn]:sleep(0);
				_G['P'..pn]:rotationz(0);
			end
		end
	end},]]
	--[[{43,function()
		for pn=1,2 do
			if _G['P'..pn] then
				_G['P'..pn]:y(SCREEN_CENTER_Y);
			end
		end
	end},]]
	
	{59,function() mawaru_closedoor(130*2) end},
	{64,function() mawaru_dotext(130*2,2) end},
	{66,function() mawaru_opendoor(130*4) end},
	
	{83,function() mawaru_closedoor(130*2) end},
	{88,function() mawaru_dotext(130*2,3) end},
	{90,function() mawaru_opendoor(130*4) end},
	
	{90,function()
		dm_questions1:setstate(dm_tqp1-1)
		dm_questions2:setstate(dm_tqp2-1)
	end},
	{90,'QuestionOn'},
	{107,'QuestionOff'},
	
	{107,function() mawaru_closedoor(130*2) end},
	{116,'SpeedUp'},
	{122,'FlashYellow'},
	{122,function() mawaru_displayBPMmax = 150; end},
	{124,function() mawaru_dotext(150*2,4) end},
	{130,function() mawaru_opendoor(150*4) end},
	
	{147,function() mawaru_closedoor(150*2) end},
	{147,function() mawaru_dotext(150*2,5) end},
	{154,function() mawaru_opendoor(150*4) end},
	
	{170.5,'Gonzales'},
	
	{172,function() mawaru_closedoor(150*4) end},
	{172,function() mawaru_dotext(150*2,6) end},
	{176,'GonzalesAway'},
	{176,function() mawaru_opendoor(150*2) end},
	
	{188,function()
		for pn=1,2 do
			if _G['P'..pn] then
				_G['P'..pn]:accelerate(120/162/RATEMOD);
				_G['P'..pn]:rotationz(-180);
				_G['P'..pn]:decelerate(120/162/RATEMOD);
				_G['P'..pn]:rotationz(-360);
				_G['P'..pn]:sleep(0);
				_G['P'..pn]:rotationz(0);
			end
		end
	end},
	
	{204,function()
		for pn=1,2 do
			if _G['P'..pn] then
				_G['P'..pn]:accelerate(120/162/RATEMOD);
				_G['P'..pn]:rotationz(-180);
				_G['P'..pn]:decelerate(120/162/RATEMOD);
				_G['P'..pn]:rotationz(-360);
				_G['P'..pn]:sleep(0);
				_G['P'..pn]:rotationz(0);
			end
		end
	end},
	
	{212,function() mawaru_closedoor(150*2) end},
	{220,'SpeedUp'},
	{226,'FlashOrange'},
	{226,function() mawaru_displayBPMmax = 175; end},
	{228,function() mawaru_dotext(130*2,7) end},
	{237,function() mawaru_opendoor(176*2) mawaru_thisgame = 7 end},
	
	{270,function() mawaru_closedoor(180*1) end},
	{276,function() mawaru_dotext(170*2,8) end},
	{276,'OtadaOn'},
	{280,function() mawaru_opendoor(180*2) end},
	
	{308,'CheckOtada'},
	
	{312,function() mawaru_closedoor(180*2) end},
	{316,function() mawaru_dotext(180*2,9) end},
	{316,'OtadaAway'},
	{320,function() mawaru_opendoor(180*2) end},
	
	{347,function() mawaru_closedoor(180*2) end},
	{352,'SpeedUp'},
	{358,'FlashRed'},
	{358,function() mawaru_displayBPMmax = 190; end},
	{360,function() mawaru_dotext(190*2,10) end},
	{364,function()
		for pn=1,2 do
			if _G['P'..pn] then
				_G['P'..pn]:y(sh/2+190);
			end
		end
	end},
	{368,'BotwOn'},
	{369,function() mawaru_opendoor(190*2) end},
	
	{374,'BotwLand'},
	{375,function() botw_canact = {true,true} end},
	
	{405,function() mawaru_closedoor(190*2) end},
	{405,function() mawaru_dotext(190*2,11) end},
	{408,function()
		for pn=1,2 do
			if _G['P'..pn] then
				_G['P'..pn]:y(sh/2);
			end
		end
	end},
	{410,'BotwAway'},
	{412,'HorseOn'},
	{414,function() mawaru_opendoor(190*2) end},
	{414,'HideRatings'},
	
	{448,function() mawaru_closedoor(190*2) end},
	{452,function() mawaru_dotext(190*2,12) end},
	{452,'HorseAway'},
	{454,'TowerOn'},
	{458,function() mawaru_opendoor(190*2) end},
	
	{492,function() mawaru_closedoor(190*2) end},
	{500,'TowerAway'},
	{500,function() mawaru_displayBPMmax = 250; end},
	{502,function() mawaru_dotext(190*2,13) end},
	
	{502,function()	
		char_ayaze:x(sw/2)
		char_ayaze:y(sh/2)
		char_ayaze:playcommand('Spawn');
	end},
	
	{502,function()
		mawaru_aya:addy(-200)
		mawaru_aya:diffusealpha(1)
		mawaru_aya:linear(1.5/RATEMOD)
		mawaru_aya:addy(200)
		mawaru_thumb:linear(1.5/RATEMOD)
		mawaru_thumb:addy(200);
		mawaru_thumb:sleep(0);
		mawaru_thumb:diffusealpha(0);
		mawaru_jon:linear(1.5/RATEMOD)
		mawaru_jon:addy(200);
		mawaru_jon:sleep(0);
		mawaru_jon:diffusealpha(0);
	end},
	{508,function() mawaru_opendoor(210/1.5,true)
	
		for pn=1,2 do
			if _G['P'..pn] then
				_G['P'..pn]:rotationz(0);
				_G['P'..pn]:zoom(1);
			end
		end
	
	end},
	
	{552-.1,function()
		for pn=1,2 do
			if _G['P'..pn] then
				_G['P'..pn]:linear(0.1);
				_G['P'..pn]:zoom(0.6);
				_G['P'..pn]:rotationz(0);
				_G['P'..pn]:sleep(60/210/RATEMOD - .1);
				_G['P'..pn]:linear(0.1);
				_G['P'..pn]:zoom(0.8);
				_G['P'..pn]:rotationz(-15);
				_G['P'..pn]:sleep(120/210/RATEMOD - .1);
				_G['P'..pn]:linear(0.1);
				_G['P'..pn]:zoom(1.0);
				_G['P'..pn]:rotationz(20);
				_G['P'..pn]:sleep(120/210/RATEMOD - .1);
				_G['P'..pn]:linear(0.1);
				_G['P'..pn]:zoom(1.2);
				_G['P'..pn]:rotationz(-25);
			end
		end
	end},
	
	{560-.1,function()
		for pn=1,2 do
			if _G['P'..pn] then
				_G['P'..pn]:linear(0.1);
				_G['P'..pn]:zoom(0.6);
				_G['P'..pn]:rotationz(0);
				_G['P'..pn]:sleep(60/210/RATEMOD - .1);
				_G['P'..pn]:linear(0.1);
				_G['P'..pn]:zoom(0.8);
				_G['P'..pn]:rotationz(15);
				_G['P'..pn]:sleep(120/210/RATEMOD - .1);
				_G['P'..pn]:linear(0.1);
				_G['P'..pn]:zoom(1.0);
				_G['P'..pn]:rotationz(-20);
				_G['P'..pn]:sleep(120/210/RATEMOD - .1);
				_G['P'..pn]:linear(0.1);
				_G['P'..pn]:zoom(1.2);
				_G['P'..pn]:rotationz(25);
			end
		end	
	end},
	
	{567,function()
		for pn=1,2 do
			if _G['P'..pn] then
				_G['P'..pn]:linear(120/210/RATEMOD);
				_G['P'..pn]:zoom(1);
				_G['P'..pn]:rotationz(0);
			end
		end	
	end},
	
	{584,function()
		for pn=1,2 do
			if _G['P'..pn] then
				_G['P'..pn]:linear(60/210/RATEMOD -.1);
				_G['P'..pn]:rotationz(20);
				_G['P'..pn]:spring(0.2);
				_G['P'..pn]:rotationz(0);
			end
		end	
	end},
	{586,function()
		for pn=1,2 do
			if _G['P'..pn] then
				_G['P'..pn]:linear(60/210/RATEMOD -.1);
				_G['P'..pn]:rotationz(-20);
				_G['P'..pn]:spring(0.2);
				_G['P'..pn]:rotationz(0);
			end
		end	
	end},
	{588,function()
		for pn=1,2 do
			if _G['P'..pn] then
				_G['P'..pn]:linear(60/210/RATEMOD -.1);
				_G['P'..pn]:rotationx(-40);
				_G['P'..pn]:spring(0.2);
				_G['P'..pn]:rotationx(0);
			end
		end	
	end},
	
	{613,function()	
		char_ayaze:playcommand('Attack');
	end},
	
	{652,'Yes'},
	
	{652,function()
		char_ayaze:playcommand('Hurt');
	end},
	{652.1,function()
		char_ayaze:decelerate(8*60/155)
		char_ayaze:rotationy(360*8)
		char_ayaze:sleep(240/155);
		char_ayaze:linear(240/155);
		char_ayaze:zoomy(0);
	end},
	
	{656,function()
		for pn=1,2 do
			if _G['P'..pn] then
				_G['P'..pn]:vibrate()
				if _G['mawaru_meter'..pn] > 17 then
					_G['P'..pn]:effectmagnitude(0,8,0);
				else
					_G['P'..pn]:effectmagnitude(0,4*(0.7*(mawaru_meter1/17)+0.3),0);
				end
			end
		end	
	end},
	{672,function()
		for pn=1,2 do
			if _G['P'..pn] then
				_G['P'..pn]:stopeffect();
			end
		end	
	end},
	
	{680,function()
		mawaru_closedoor(300);
	end},
	
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

mawaru_checked = false

t[#t+1] = Def.BitmapText{
	Font="Common Normal";
	InitCommand=cmd(Center);
	
	OnCommand=function (self)
		
		self:visible(true)
		self:queuecommand('Update');
		
	end;
	UpdateCommand=function (self)
		--self:settext((curaction or "nil!").."/"..table.getn(actions).."\n"..GAMESTATE:GetSongBeat());
		
		local beat = GAMESTATE:GetSongBeat()
		local mbeat = ((GAMESTATE:GetCurMusicSeconds()+5.274)/(60/128))
		local mbeat2 = ((GAMESTATE:GetCurMusicSeconds()-42.318)/(60/191))
		
		if not mawaru_checked then
		
			local arng = {{1,1},{3,3},{4,4},{2,2},{5,5},{8,8}}
			local qrng = {
				{{1,-1,3,-1,4},
				{1,2,3,4,5},},
				{{2,5,8,-1,-1},
				{2,5,8,7,9},},
			}
			
			for j=1,#qrng do
				for i=1,#qrng[j] do
					qrng[j][i] = mimi_shuffle(qrng[j][i])
					--randomize choice order
				end
			end
		
			if GAMESTATE:IsPlayerEnabled(PLAYER_1) then
			
				Trace('Mawaru meter 1: '..mawaru_meter1);
			
				P1 = SCREENMAN:GetTopScreen():GetChild('PlayerP1');
				dm_p1pos = SCREENMAN:GetTopScreen():GetChild('PlayerP1'):GetX()
				dm_notedata1 = _G['dm_notedata_s'..mawaru_meter1]
				
				if mawaru_meter1 > 17 then
					dm_tqp1 = math.random(4,6)
					dm_quiz_choices1 = qrng[2]
				else
					dm_tqp1 = math.random(1,3)
					dm_quiz_choices1 = qrng[1]
				end
				
				dm_quiz_answers1 = arng[dm_tqp1]
				
				if mawaru_meter1 >= 17 then
					mawaru_mine_amts[1] = {7,4}
				else
					mawaru_mine_amts[1] = {4,2}
				end
				
				botw_chartp1 = _G['botw_orb_chart_s'..mawaru_meter1]

			end
			if GAMESTATE:IsPlayerEnabled(PLAYER_2) then
			
				Trace('Mawaru meter 2: '..mawaru_meter2);
			
				P2 = SCREENMAN:GetTopScreen():GetChild('PlayerP2');
				dm_p2pos = SCREENMAN:GetTopScreen():GetChild('PlayerP2'):GetX()
				dm_notedata2 = _G['dm_notedata_s'..mawaru_meter2]
				
				if mawaru_meter2 > 17 then
					dm_tqp2 = math.random(4,6)
					dm_quiz_choices2 = qrng[2]
				else
					dm_tqp2 = math.random(1,3)
					dm_quiz_choices2 = qrng[1]
				end
				
				dm_quiz_answers2 = arng[dm_tqp2]
				
				if mawaru_meter1 >= 17 then
					mawaru_mine_amts[2] = {7,4}
				else
					mawaru_mine_amts[2] = {4,2}
				end
				
				botw_chartp2 = _G['botw_orb_chart_s'..mawaru_meter2]

			end
			
			mawaru_checked = true;
		end
		
		if beat > mod_firstSeenBeat+0.1 then
			if mawaru_displayBPM < mawaru_displayBPMmax then
				if mawaru_displayBPM < 190 then
					mawaru_displayBPM = mawaru_displayBPM+0.4;
				else
					mawaru_displayBPM = mawaru_displayBPM+0.8;
				end
				if mawaru_displayBPM < 250 then
					mawaru_bpmdisptext:settext(math.floor(mawaru_displayBPM)..' BPM');
				else
					mawaru_bpmdisptext:settext('??? BPM');
				end
			end
			
			mawaru_horse_update()
			mawaru_botw_update()
			mawaru_tower_update()
		
		end
								--6v
		--custom mod reader (c) 2014 #taronuke #yolo #swag #swag #amazon.co.jp #teamproofofconcept #swag
		while curmod<= #mods and beat>=mods[curmod][1] do
			if table.getn(mods[curmod]) == 3 then
				local pn= 'PlayerNumber_P' .. mods[curmod][3]
				local ps= GAMESTATE:GetPlayerState(pn)
				local pmods= ps:GetPlayerOptionsString('ModsLevel_Song')
				ps:SetPlayerOptions('ModsLevel_Song', pmods .. ', ' .. mods[curmod][2])
			else
				for i=1,2 do
					local pn= 'PlayerNumber_P' .. i
					local ps= GAMESTATE:GetPlayerState(pn)
					local pmods= ps:GetPlayerOptionsString('ModsLevel_Song')
					ps:SetPlayerOptions('ModsLevel_Song', pmods .. ', ' .. mods[curmod][2])
				end
			end
			curmod = curmod+1;
		end
		
		--Trace(tostring(_G['dm_quiz_answers1']));
		
		if beat > mod_firstSeenBeat+0.1 then
			if dm_curquestion<=table.getn(dm_questiontiming) and beat>dm_questiontiming[dm_curquestion]+0.5 then
				local anyright = false;
				if beat<dm_questiontiming[dm_curquestion]+5 then
					for pn=1,2 do
						if GAMESTATE:IsPlayerEnabled('PlayerNumber_P'..pn) then
							Trace('CheckAnswer: '..dm_myanswer[pn]..' (ans = '.._G['dm_quiz_answers'..pn][dm_curquestion]..')');
							if dm_myanswer[pn] == _G['dm_quiz_answers'..pn][dm_curquestion] then
								dm_score[pn] = dm_score[pn]+1
								anyright = true;
								MESSAGEMAN:Broadcast('GoodP'..pn);
							else
								MESSAGEMAN:Broadcast('WrongP'..pn);
							end
							dm_myanswer[pn] = -1
						end
					end
					if beat<104 then
						if anyright then
							Sound('good.ogg');
						else
							Sound('wrong.ogg');
						end
					end
				end
				dm_curquestion = dm_curquestion+1
			end
		end
		
		if beat > mod_firstSeenBeat+0.1 then
			for pn=1,2 do
				if GAMESTATE:IsPlayerEnabled('PlayerNumber_P'..pn) then
					while dm_curnote[pn]<=table.getn(_G['dm_notedata'..pn]) and mbeat>_G['dm_notedata'..pn][ dm_curnote[pn] ][1]-dm_dur do
						if mbeat<_G['dm_notedata'..pn][ dm_curnote[pn] ][1]-dm_dur+5 then
							local n = _G['dm_notedata'..pn];
							if n[ dm_curnote[pn] ][3] ~= 'M' then
								dm_spawn(n[ dm_curnote[pn] ][1],n[ dm_curnote[pn] ][2],n[ dm_curnote[pn] ][3],n[ dm_curnote[pn] ].length,pn);
							else
								for i=1,5 do
									dm_spawn(n[ dm_curnote[pn] ][1],i-1,'B',_G['dm_quiz_choices'..pn][dm_curq_note[pn]][i],pn)
								end
								dm_curq_note[pn] = dm_curq_note[pn]+1;
							end
						end
						dm_curnote[pn] = dm_curnote[pn]+1;
					end
				end
			end
		end
		
		if beat > mod_firstSeenBeat+0.1 then
			for pn=1,2 do
				if GAMESTATE:IsPlayerEnabled('PlayerNumber_P'..pn) then
					while botw_curnote[pn]<=table.getn(_G['botw_chartp'..pn]) and
					mbeat2>_G['botw_chartp'..pn][ botw_curnote[pn] ][1]-_G['botw_chartp'..pn][ botw_curnote[pn] ][3] do
						if mbeat2<_G['botw_chartp'..pn][ botw_curnote[pn] ][1]-_G['botw_chartp'..pn][ botw_curnote[pn] ][3]+5 then
							local n = _G['botw_chartp'..pn];
							botw_spawn(n[ botw_curnote[pn] ][1],n[ botw_curnote[pn] ][2],n[ botw_curnote[pn] ][3],pn);
						end
						botw_curnote[pn] = botw_curnote[pn]+1;
					end
				end
			end
		end
	
		---------------------------------------
		-- ACTION RPGS AINT GOT SHIT ON THIS --
		---------------------------------------
		if beat > mod_firstSeenBeat+0.1 then -- performance coding!! --
			while curaction<=table.getn(actions) and GAMESTATE:GetSongBeat()>=actions[curaction][1] do
				if actions[curaction][3] or GAMESTATE:GetSongBeat() < actions[curaction][1]+2 then
					if type(actions[curaction][2]) == 'function' then
						actions[curaction][2]()
					elseif type(actions[curaction][2]) == 'string' then
						MESSAGEMAN:Broadcast(actions[curaction][2]);
					end
				end
				curaction = curaction+1;
			end
		end
		
		self:sleep(0.02);
		self:queuecommand('Update');
	end;
};

t[#t+1] = Def.Quad{
	OnCommand=cmd(Center;FullScreen;diffuse,1,1,1,0);
	WhiteFlashMessageCommand=cmd(diffusealpha,0.4;linear,0.4;diffusealpha,0);
}
	
return t;
