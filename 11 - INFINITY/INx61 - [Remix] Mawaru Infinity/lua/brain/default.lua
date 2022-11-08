LoadActor('brain/chart.lua');

function Sound(str)
	local songName = GAMESTATE:GetCurrentSong():GetSongDir();
	SOUND:PlayOnce(songName..'lua/sounds/'..str);
end

dm_notes = {{},{},{},{},{}}
dm_holdbody = {{},{},{},{},{}}
dm_holdbottom = {{},{},{},{},{}}
dm_brain = {}
dm_ptr = 1;

dm_flash = {}
dm_fptr = 1;

beat = 0;

dm_bpm = 124

dm_num_notes = 50;

dm_curnote = 1;
dm_speedmod = 3.14;
dm_dur = 6;

dm_curquestion = 1
dm_questiontiming = {39,47,55,63.5,103,111,119,127,207,224}
dm_curq_note = 1

dm_score = 0;

dm_myanswer = -1

dm_curaction = 1
dm_action = {
	{32,function() dm_questions:setstate(0) end},
	{32,'QuestionOn'},
	{38,function() dm_questions:linear(dm_bl); dm_questions:diffusealpha(0) end},
	{40,function() dm_questions:setstate(1); dm_questions:linear(dm_bl); dm_questions:diffusealpha(1) end},
	{46,function() dm_questions:linear(dm_bl); dm_questions:diffusealpha(0) end},
	{48,function() dm_questions:setstate(2); dm_questions:linear(dm_bl); dm_questions:diffusealpha(1) end},
	{54,function() dm_questions:linear(dm_bl); dm_questions:diffusealpha(0) end},
	{56,function() dm_questions:setstate(3); dm_questions:linear(dm_bl); dm_questions:diffusealpha(1) end},
	{64,'QuestionOff'},
	{96,function() dm_questions:setstate(4) end},
	{96,'QuestionOn'},
	{102,function() dm_questions:linear(dm_bl); dm_questions:diffusealpha(0) end},
	{104,function() dm_questions:setstate(5); dm_questions:linear(dm_bl); dm_questions:diffusealpha(1) end},
	{110,function() dm_questions:linear(dm_bl); dm_questions:diffusealpha(0) end},
	{112,function() dm_questions:setstate(6); dm_questions:linear(dm_bl); dm_questions:diffusealpha(1) end},
	{118,function() dm_questions:linear(dm_bl); dm_questions:diffusealpha(0) end},
	{120,function() dm_questions:setstate(7); dm_questions:linear(dm_bl); dm_questions:diffusealpha(1) end},
	{128,'QuestionOff'},
	{192,function() dm_questions:setstate(8) end},
	{192,'QuestionOn'},
	{206,function() dm_questions:linear(dm_bl); dm_questions:diffusealpha(0) end},
	{208,function() dm_questions:setstate(9); dm_questions:linear(dm_bl); dm_questions:diffusealpha(1) end},
	{224,'QuestionOff'},
}

dm_bl = 60/dm_bpm

dm_ypos = SCREEN_HEIGHT*68/480

function dm_spawnf(col)

	col = col+1

	local a = dm_flash[dm_fptr]
	
	local x = ((col-3)*51)+(dm_ppos)
	
	if GAMESTATE:GetCurrentStyle():GetStepsType()=='StepsType_Pump_Double' then
		x = ((col-5)*51)+(dm_ppos)-26
		if col > 5 then x = x+2 end
		if col > 4 then col = col - 5 end
	end
	
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

function dm_spawn(targ,col,hold,dur)
	local beat = (GAMESTATE:GetCurMusicSeconds()-0.007)/(60/dm_bpm)
	targ = targ-0.05
	
	if hold == 'M' then
		return
	end
	
	col = col+1
	
	local x = ((col-3)*51)+(dm_ppos)
	local y = dm_ypos + (dm_dur*64*dm_speedmod)
	
	if GAMESTATE:GetCurrentStyle():GetStepsType()=='StepsType_Pump_Double' then
		x = ((col-5)*51)+(dm_ppos)-26
		if col > 5 then x = x+2 end
		if col > 4 then col = col - 5 end
	end
	
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
		height = dm_speedmod*64*dur
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
		a:linear(dm_dur*dm_bl)
		a:y(dm_ypos);
		if hold == 2 then
			a:sleep(dm_bl*dur);
		end
		if hold == 'B' then
			a:linear(dm_bl*2);
			a:addy(-128*dm_speedmod);
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
			b:linear(dm_bl*dm_dur)
			b:y(dm_ypos);
			b:linear(dm_bl*(dur-(0.5/dm_speedmod)));
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
		c:croptop(math.min((-dm_speedmod*(height-64))/64,0));
		c:linear(dm_bl*(dm_dur))
		c:y(dm_ypos+height-32);
		c:linear(dm_bl*(dur))
		c:y(dm_ypos-32);
		c:croptop(0.5);
		c:queuecommand('Hide');
	end
	
	dm_ptr = dm_ptr+1
	if dm_ptr>dm_num_notes then
		dm_ptr = 1;
	end
end

function dm_update(self, delta)
	beat = (GAMESTATE:GetCurMusicSeconds()-0.007)/(60/dm_bpm)
	
	--Trace(beat)
	
	if GAMESTATE:IsPlayerEnabled(PLAYER_1) then dm_ppos = SCREENMAN:GetTopScreen():GetChild('PlayerP1'):GetX() end
	if GAMESTATE:IsPlayerEnabled(PLAYER_2) then dm_ppos = SCREENMAN:GetTopScreen():GetChild('PlayerP2'):GetX() end
	
	if dm_curquestion<=table.getn(dm_questiontiming) and beat>dm_questiontiming[dm_curquestion]+1 then
		Trace('CheckAnswer: '..dm_myanswer..' (ans = '..dm_quiz_answers[dm_curquestion]..')');
		if dm_myanswer == dm_quiz_answers[dm_curquestion] then
			dm_score = dm_score+1
			MESSAGEMAN:Broadcast('Good');
			Sound('good.ogg');
		else
			MESSAGEMAN:Broadcast('Wrong');
			Sound('wrong.ogg');
		end
		dm_myanswer = -1
		dm_curquestion = dm_curquestion+1
	end
	
	while dm_curaction<=table.getn(dm_action) and beat>dm_action[dm_curaction][1] do
		if dm_action[dm_curaction][3] or GAMESTATE:GetSongBeat() < dm_action[dm_curaction][1]+2 then
			if type(dm_action[dm_curaction][2]) == 'function' then
				dm_action[dm_curaction][2]()
			elseif type(dm_action[dm_curaction][2]) == 'string' then
				MESSAGEMAN:Broadcast(dm_action[dm_curaction][2]);
			end
		end
		dm_curaction = dm_curaction+1;
	end
	
	while dm_curnote<=table.getn(dm_notedata) and beat>dm_notedata[dm_curnote][1]-dm_dur do
		if dm_notedata[dm_curnote][3] ~= 'M' then
			dm_spawn(dm_notedata[dm_curnote][1],dm_notedata[dm_curnote][2],dm_notedata[dm_curnote][3],dm_notedata[dm_curnote].length);
		else
			for i=1,5 do
				dm_spawn(dm_notedata[dm_curnote][1],i-1,'B',dm_quiz_choices[dm_curq_note][i])
			end
			dm_curq_note = dm_curq_note+1;
		end
		dm_curnote = dm_curnote+1;
	end
	
end

local t = Def.ActorFrame{
	OnCommand= function(self)
		self:SetUpdateFunction(dm_update)
	end,
	Def.Quad{
		Name= "I may be sleeping, but I preserve the world.",
		InitCommand= cmd(visible,false),
		OnCommand= cmd(sleep,1000),
	},
	Def.Quad{
		InitCommand=cmd(visible,false),
		StepMessageCommand=function(self,params)
			--SCREENMAN:SystemMessage('Step'..params.Col);
			for i=1,#dm_questiontiming do
				--Trace('q'..i..': '..beat-dm_questiontiming[i]);
				if beat-dm_questiontiming[i] < 0.25 and beat-dm_questiontiming[i] > -0.1 then
					dm_spawnf(params.Col)
					for c=1,#dm_brain do
						if dm_brain[c]:getaux() == params.Col+1 then
							dm_brain[c]:stoptweening();
							dm_brain[c]:queuecommand('Hide');
						end
					end
					dm_myanswer = dm_quiz_choices[i][params.Col+1]
					Trace('Answering: '..dm_myanswer);
				end
			end
		end,
	}
}

for i=1,dm_num_notes do
	t[#t+1] = LoadActor("dl_b")..{
		OnCommand=cmd(visible,false;sleep,0.02;queuecommand,"SetMe"),
		SetMeCommand=function(self) table.insert(dm_holdbottom[1],self); end,
		HideCommand=cmd(visible,false;)
	}
	t[#t+1] = LoadActor("ul_b")..{
		OnCommand=cmd(visible,false;sleep,0.02;queuecommand,"SetMe"),
		SetMeCommand=function(self) table.insert(dm_holdbottom[2],self); end,
		HideCommand=cmd(visible,false;)
	}
	t[#t+1] = LoadActor("c_b")..{
		OnCommand=cmd(visible,false;sleep,0.02;queuecommand,"SetMe"),
		SetMeCommand=function(self) table.insert(dm_holdbottom[3],self); end,
		HideCommand=cmd(visible,false;)
	}
	t[#t+1] = LoadActor("ur_b")..{
		OnCommand=cmd(visible,false;sleep,0.02;queuecommand,"SetMe"),
		SetMeCommand=function(self) table.insert(dm_holdbottom[4],self); end,
		HideCommand=cmd(visible,false;)
	}
	t[#t+1] = LoadActor("dr_b")..{
		OnCommand=cmd(visible,false;sleep,0.02;queuecommand,"SetMe"),
		SetMeCommand=function(self) table.insert(dm_holdbottom[5],self); end,
		HideCommand=cmd(visible,false;)
	}
	t[#t+1] = LoadActor("dl_m")..{
		OnCommand=cmd(visible,false;sleep,0.02;queuecommand,"SetMe"),
		SetMeCommand=function(self) table.insert(dm_holdbody[1],self); end,
		HideCommand=cmd(visible,false;)
	}
	t[#t+1] = LoadActor("ul_m")..{
		OnCommand=cmd(visible,false;sleep,0.02;queuecommand,"SetMe"),
		SetMeCommand=function(self) table.insert(dm_holdbody[2],self); end,
		HideCommand=cmd(visible,false;)
	}
	t[#t+1] = LoadActor("c_m")..{
		OnCommand=cmd(visible,false;sleep,0.02;queuecommand,"SetMe"),
		SetMeCommand=function(self) table.insert(dm_holdbody[3],self); end,
		HideCommand=cmd(visible,false;)
	}
	t[#t+1] = LoadActor("ur_m")..{
		OnCommand=cmd(visible,false;sleep,0.02;queuecommand,"SetMe"),
		SetMeCommand=function(self) table.insert(dm_holdbody[4],self); end,
		HideCommand=cmd(visible,false;)
	}
	t[#t+1] = LoadActor("dr_m")..{
		OnCommand=cmd(visible,false;sleep,0.02;queuecommand,"SetMe"),
		SetMeCommand=function(self) table.insert(dm_holdbody[5],self); end,
		HideCommand=cmd(visible,false;)
	}
	t[#t+1] = LoadActor("dl_t")..{
		OnCommand=cmd(visible,false;sleep,0.02;queuecommand,"SetMe"),
		SetMeCommand=function(self) table.insert(dm_notes[1],self); end,
		HideCommand=cmd(visible,false;)
	}
	t[#t+1] = LoadActor("ul_t")..{
		OnCommand=cmd(visible,false;sleep,0.02;queuecommand,"SetMe"),
		SetMeCommand=function(self) table.insert(dm_notes[2],self); end,
		HideCommand=cmd(visible,false;)
	}
	t[#t+1] = LoadActor("c_t")..{
		OnCommand=cmd(visible,false;sleep,0.02;queuecommand,"SetMe"),
		SetMeCommand=function(self) table.insert(dm_notes[3],self); end,
		HideCommand=cmd(visible,false;)
	}
	t[#t+1] = LoadActor("ul_t")..{
		OnCommand=cmd(visible,false;basezoomx,-1;sleep,0.02;queuecommand,"SetMe"),
		SetMeCommand=function(self) table.insert(dm_notes[4],self); end,
		HideCommand=cmd(visible,false;)
	}
	t[#t+1] = LoadActor("dl_t")..{
		OnCommand=cmd(visible,false;basezoomx,-1;sleep,0.02;queuecommand,"SetMe"),
		SetMeCommand=function(self) table.insert(dm_notes[5],self); end,
		HideCommand=cmd(visible,false;)
	}
	t[#t+1] = LoadActor("brainshower")..{
		OnCommand=cmd(visible,false;animate,false;sleep,0.02;queuecommand,"SetMe"),
		SetMeCommand=function(self) table.insert(dm_brain,self); end,
		HideCommand=cmd(visible,false;)
	}
	t[#t+1] = Def.ActorFrame{
		OnCommand=cmd(sleep,0.02;queuecommand,"SetMe"),
		SetMeCommand=function(self) table.insert(dm_flash,self); end,
		LoadActor("_Tap Explosion Bright") .. {
			Frames = Sprite.LinearFrames( 5, 0.28);
			InitCommand=cmd(visible,false;animate,false;blend,Blend.Add;diffusealpha,0;zoom,0.975);
			GlowCommand=cmd(stoptweening;visible,true;setstate,0;diffusealpha,1;sleep,0.28;diffusealpha,0;queuecommand,'Hide'),
			HideCommand=cmd(visible,false;)
		},
		LoadActor("_Tap Explosion Bright") .. {
			Frames = Sprite.LinearFrames( 5, 0.28);
			InitCommand=cmd(visible,false;animate,false;blend,Blend.Add;diffusealpha,0;zoom,1.2);
			GlowCommand=cmd(stoptweening;visible,true;setstate,0;diffusealpha,0;linear,0.075;diffusealpha,1;sleep,0.28;diffusealpha,0;queuecommand,'Hide'),
			HideCommand=cmd(visible,false;)
		},
		LoadActor("emptyq") .. {
			InitCommand=cmd(visible,false;blend,Blend.Add;diffusealpha,0;);
			GlowCommand=cmd(stoptweening;visible,true;diffusealpha,1;zoom,1;linear,0.2;zoom,1.075;linear,0.1;diffusealpha,0;queuecommand,'Hide');
			HideCommand=cmd(visible,false;)
		},
		LoadActor("emptyq") .. {
			InitCommand=cmd(visible,false;blend,Blend.Add;diffusealpha,0;);
			GlowCommand=cmd(stoptweening;visible,true;diffusealpha,0;zoom,1;diffusealpha,1;linear,0.25;zoom,1.4;linear,0.1;diffusealpha,0;queuecommand,'Hide');
			HideCommand=cmd(visible,false;)
		}
	}

end

t[#t+1] = LoadActor("grade")..{
	OnCommand=cmd(diffusealpha,0;animate,0;y,SCREEN_HEIGHT*0.4),
	GoodMessageCommand=cmd(setstate,1;queuecommand,"Flash");
	WrongMessageCommand=cmd(setstate,0;queuecommand,"Flash");
	FlashCommand=cmd(x,dm_ppos;diffusealpha,1;sleep,0.1;diffusealpha,0;sleep,0.1;diffusealpha,1;sleep,0.1;diffusealpha,0;sleep,0.1;diffusealpha,1;sleep,1;diffusealpha,0;);
}

t[#t+1] = LoadActor("quiz");

return t