--////////////////////////////////////////////////////////////
-- Check for players
local IsQuest = false
local Alone = false
local PlayerAlone;

if GAMESTATE:IsHumanPlayer(PLAYER_1) and GAMESTATE:IsHumanPlayer(PLAYER_2) then
	if GAMESTATE:GetCurrentSteps(PLAYER_1):GetAuthorCredit() == "KAZE, Taro & DOOM" and GAMESTATE:GetCurrentSteps(PLAYER_2):GetAuthorCredit() == "KAZE, Taro & DOOM" then
		IsQuest = true;
	end
end

if GAMESTATE:IsHumanPlayer(PLAYER_1) and not GAMESTATE:IsHumanPlayer(PLAYER_2) then
	if GAMESTATE:GetCurrentSteps(PLAYER_1):GetAuthorCredit() == "KAZE, Taro & DOOM" then
		IsQuest = true;
		Alone = true;
		PlayerAlone = PLAYER_1;
	end
end

if not GAMESTATE:IsHumanPlayer(PLAYER_1) and GAMESTATE:IsHumanPlayer(PLAYER_2) then
	if GAMESTATE:GetCurrentSteps(PLAYER_2):GetAuthorCredit() == "KAZE, Taro & DOOM" then
		IsQuest = true;
		Alone = true;
		PlayerAlone = PLAYER_2;
	end
end

if not IsQuest then
	return Def.Actor{};
end;	

--////////////////////////////////////////////////////////////
-- Load local animations
local BounceEndBezier =
{
	0,0,
	1/3, 0.7,
	0.58, 1.42,
	1, 1
}
local BounceBeginBezier =
{
	0, 0,
	0.42, -0.42,
	2/3, 0.3,
	1, 1
}
function Actor:bounceend(t)
	self:tween( t, "TweenType_Bezier", BounceEndBezier )
end
function Actor:bouncebegin(t)
	self:tween( t, "TweenType_Bezier", BounceBeginBezier )
end

--////////////////////////////////////////////////////////////
-- Animations vars

local sw = SCREEN_WIDTH
local sh = SCREEN_HEIGHT
local cw = math.floor(sw/2);
local ch = math.floor(sh/2);

local comboP1 = 0;
local comboP2 = 0;
local combo = 0;
local flag = 1;
local goalmet = false;
local posCheckTimer = 0;

local ended = false;

--local length = GAMESTATE:GetCurrentSong():GetStepsSeconds()
local length = 92;
local horsesOn = false;
--aspect = sw/sh
aspect = 1

--////////////////////////////////////////////////////////////
-- Actors
local t = Def.ActorFrame{OnCommand=cmd(sleep,999);}

t[#t+1] = LoadActor("logo")..{
	OnCommand=cmd(wag;effectmagnitude,0,0,3;x,cw;y,ch*0.8;zoom,0;sleep,5.347;linear,0.353;rotationz,360*1;zoom,1;sleep,6;bouncebegin,0.3;zoomx,2;zoomy,0;queuecommand,"Stop");
	StopCommand=cmd(diffusealpha,0;stoptweening;);
};

t[#t+1] = Def.Quad {
	OnCommand=cmd(x,cw;y,sh*0.8-2;zoomto,SCREEN_WIDTH+1,80;diffuse,color("#000000");diffusealpha,0;sleep,6.7;linear,0.3;diffusealpha,0.8;sleep,4;linear,0.5;diffusealpha,0;queuecommand,"Stop");
	StopCommand=cmd(stoptweening;);
};
t[#t+1] = LoadFont("BPM")..{
	OnCommand=cmd(maxwidth,640;cropright,1;x,cw;y,sh*0.8-22;settext,"Welcome to the annual Pump It Up Derby!";sleep,4.5;sleep,2.5+0;queuecommand,"In");
	InCommand=cmd(linear,1;cropright,0;sleep,3;linear,0.5;diffusealpha,0;queuecommand,"Stop");
	StopCommand=cmd(stoptweening;);
}
t[#t+1] = LoadFont("BPM")..{
	OnCommand=cmd(maxwidth,640;cropright,1;x,cw;y,sh*0.8;settext,"Get them horses ready, 'cause yer gonna need 'em!";sleep,4.5;sleep,2.5+0.5;queuecommand,"In");
	InCommand=cmd(linear,1;cropright,0;sleep,2.5;linear,0.5;diffusealpha,0;queuecommand,"Stop");
	StopCommand=cmd(stoptweening;);
}
t[#t+1] = LoadFont("BPM")..{
	OnCommand=cmd(maxwidth,640;cropright,1;x,cw;y,sh*0.8+22;settext,"On your marks... Get set... GO!";sleep,4.5;sleep,2.5+1.1;queuecommand,"In");
	InCommand=cmd(linear,2.5;cropright,0;sleep,0.5;linear,0.5;diffusealpha,0;queuecommand,"Stop");
	StopCommand=cmd(stoptweening;);
}

t[#t+1] = Def.Quad {
	OnCommand=cmd(x,cw;y,ch;zoomto,SCREEN_WIDTH+1,80;diffuse,color("#000000");diffusealpha,0;sleep,6.7;);
	FinalStretchMessageCommand=cmd(linear,0.3;diffusealpha,0.8;sleep,2;linear,0.5;diffusealpha,0;queuecommand,"Stop");
	StopCommand=cmd(stoptweening;);
};
t[#t+1] = LoadFont("BPM")..{
	OnCommand=cmd(maxwidth,640;cropright,1;x,cw;y,ch-11;settext,"Great job so far! Keep on going...";sleep,2.5+1.1;);
	FinalStretchMessageCommand=cmd(linear,0.5;cropright,0;sleep,1.5;linear,0.5;diffusealpha,0;queuecommand,"Stop");
	StopCommand=cmd(stoptweening;);
}
t[#t+1] = LoadFont("BPM")..{
	OnCommand=cmd(maxwidth,640;cropright,1;x,cw;y,ch+17;settext,"It's the final stretch!";sleep,2.5+1.1;);
	FinalStretchMessageCommand=cmd(sleep,0.5;linear,0.5;cropright,0;sleep,1.0;linear,0.5;diffusealpha,0;queuecommand,"Stop");
	StopCommand=cmd(stoptweening;);
}

if Alone then
	t[#t+1] = Def.ActorFrame{
		OnCommand=cmd(x,0;y,sh+10;);
		UpdateMessageCommand=cmd(x,((sw*1)-((sw*0.9)/((combo+300)/300))));
		LoadActor("200")..{
			OnMessageCommand=cmd(zoom,0.4;x,(200*5-combo*5);vertalign,bottom;);
			UpdateMessageCommand=cmd(x,(200*5-combo*5));
			GotTo200MessageCommand=cmd(decelerate,3;rotationy,360*4;diffusealpha,0.5);
		};
		LoadActor("400")..{
			OnMessageCommand=cmd(zoom,0.4;x,(400*5-combo*5);vertalign,bottom;);
			UpdateMessageCommand=cmd(x,(400*5-combo*5));
			GotTo400MessageCommand=cmd(decelerate,3;rotationy,360*4;diffusealpha,0.5);
		};
		LoadActor("600")..{
			OnMessageCommand=cmd(zoom,0.4;x,(600*5-combo*5);vertalign,bottom;);
			UpdateMessageCommand=cmd(x,(600*5-combo*5));
			GotTo600MessageCommand=cmd(decelerate,3;rotationy,360*4;diffusealpha,0.5);
		};
		LoadActor("800")..{
			OnMessageCommand=cmd(zoom,0.4;x,(800*5-combo*5);vertalign,bottom;);
			UpdateMessageCommand=cmd(x,(800*5-combo*5));
			GotTo800MessageCommand=cmd(decelerate,3;rotationy,360*4;diffusealpha,0.5);
		};
		LoadActor("thousand")..{
			OnMessageCommand=cmd(zoom,0.4;x,(1000*5-combo*5);vertalign,bottom;);
			UpdateMessageCommand=cmd(x,(1000*5-combo*5));
			GotTo1000MessageCommand=cmd(decelerate,3;rotationy,360*4;diffusealpha,0.5);
		};
		LoadActor("1200")..{
			OnMessageCommand=cmd(zoom,0.4;x,(1200*5-combo*5);vertalign,bottom;);
			UpdateMessageCommand=cmd(x,(1200*5-combo*5));
			GotTo1200MessageCommand=cmd(decelerate,3;rotationy,360*4;diffusealpha,0.5);
		};
		LoadActor("1400")..{
			OnMessageCommand=cmd(zoom,0.4;x,(1400*5-combo*5);vertalign,bottom;);
			UpdateMessageCommand=cmd(x,(1400*5-combo*5));
			GotTo1400MessageCommand=cmd(decelerate,3;rotationy,360*4;diffusealpha,0.5);
		};
		LoadActor("1600")..{
			OnMessageCommand=cmd(zoom,0.4;x,(1600*5-combo*5);vertalign,bottom;);
			UpdateMessageCommand=cmd(x,(1600*5-combo*5));
			GotTo1600MessageCommand=cmd(decelerate,3;rotationy,360*4;diffusealpha,0.5);
		};
	}

	t[#t+1] = LoadActor("horseN")..{
		OnCommand=cmd(wag;effectmagnitude,0,0,3;x,sw*(16/length)*0.9;y,sh+10;zoom,0;vertalign,bottom;);
		UpdateMessageCommand=function (self, params)
			local stats = STATSMAN:GetCurStageStats():GetPlayerStageStats(PlayerAlone);
			
			if stats:GetCurrentCombo() > combo then
				combo = stats:GetCurrentCombo();
			end
			
			if HorsesOn then
				if combo >= 200 and flag == 1 then
					MESSAGEMAN:Broadcast('GotTo200');
					flag = 2;
				end
				if combo >= 400 and flag == 2 then
					MESSAGEMAN:Broadcast('GotTo400');
					flag = 3;
				end
				if combo >= 600 and flag == 3 then
					MESSAGEMAN:Broadcast('GotTo600');
					flag = 4;
				end
				if combo >= 800 and flag == 4 then
					MESSAGEMAN:Broadcast('GotTo800');
					flag = 5;
				end
				if combo >= 1000 and flag == 5 then
					MESSAGEMAN:Broadcast('GotTo1000');
					flag = 6;
				end
				if combo >= 1200 and flag == 6 then
					MESSAGEMAN:Broadcast('GotTo1200');
					flag = 7;
				end
				if combo >= 1400 and flag == 7 then
					MESSAGEMAN:Broadcast('GotTo1400');
					flag = 8;
				end
				if combo >= 1600 and flag == 8 then
					MESSAGEMAN:Broadcast('GotTo1600');
					flag = 9;
				end
				--self:finishtweening();
				--self:x(sw*(GAMESTATE:GetCurMusicSeconds()/length)*0.9);
				self:x(((sw*1)-((sw*0.9)/((combo+300)/300))+0));
			end
		end;
		ShowHorsesMessageCommand=cmd(x,((sw*1)-((sw*0.9)/((combo+300)/300))+0);bounceend,0.5;zoom,0.4;);
	};
	
	t[#t+1] = LoadActor("conf")..{
		GotTo200MessageCommand=cmd(play);
		GotTo400MessageCommand=cmd(play);
		GotTo600MessageCommand=cmd(play);
		GotTo800MessageCommand=cmd(play);
		GotTo1000MessageCommand=cmd(play);
		GotTo1200MessageCommand=cmd(play);
		GotTo1400MessageCommand=cmd(play);
		GotTo1600MessageCommand=cmd(play);
		WinMessageCommand=cmd(play);
	}
end

if not Alone then
	t[#t+1] = Def.ActorFrame{
		CheckPositionMessageCommand=function(self)
			if comboP2 == comboP1 then
				self:decelerate(0.5);
				self:x(0);
				self:zoom(1.0);
				self:diffuse(color("1,1,1,1"));
			elseif comboP2 > comboP1 then
				self:decelerate(0.5);
				self:x(10);
				self:zoom(1.0);
				self:diffuse(color("1,1,1,1"));
			else
				self:decelerate(0.5);
				self:x(-10);
				--self:zoom(0.9);
				self:diffuse(color(".5,.5,.5,1"));
			end
		end;
		LoadActor("horseP2")..{
			OnCommand=cmd(wag;effectmagnitude,0,0,-3;x,sw*(16/length)*0.85;y,sh+10;zoom,0;vertalign,bottom;);
			UpdateMessageCommand=function (self, params)
				local statsP2 = STATSMAN:GetCurStageStats():GetPlayerStageStats(PLAYER_2);
				if statsP2:GetCurrentCombo() > comboP2 then
					comboP2 = statsP2:GetCurrentCombo();
				end
				if HorsesOn then
					--self:finishtweening();
					if comboP2<comboP1 then
						distance = math.abs(comboP1-comboP2);
					else
						distance = 0;
					end
					
					self:x((sw*(GAMESTATE:GetCurMusicSeconds()/length)*0.85)-distance);
				end
			end;
			ShowHorsesMessageCommand=cmd(bounceend,0.5;zoom,0.4;);
		}
	};
		
	t[#t+1] = Def.ActorFrame{
		CheckPositionMessageCommand=function(self)
			if comboP1 == comboP2 then
				self:decelerate(0.5);
				self:x(0);
				self:zoom(1.0);
				self:diffuse(color("1,1,1,1"));
			elseif comboP1 > comboP2 then
				self:decelerate(0.5);
				self:x(10);
				self:zoom(1.0);
				self:diffuse(color("1,1,1,1"));
			else
				self:decelerate(0.5);
				self:x(-10);
				--self:zoom(0.9);
				self:diffuse(color("0.5,0.5,0.5,1"));
			end
		end;
		LoadActor("horseP1")..{
			OnCommand=cmd(wag;effectmagnitude,0,0,3;x,sw*(16/length)*0.85;y,sh+10;zoom,0;vertalign,bottom;);
			UpdateMessageCommand=function (self, params)
				local statsP1 = STATSMAN:GetCurStageStats():GetPlayerStageStats(PLAYER_1);
				if statsP1:GetCurrentCombo() > comboP1 then
					comboP1 = statsP1:GetCurrentCombo();
				end
				if HorsesOn then
					--self:finishtweening();
					if comboP1<comboP2 then
						distance = math.abs(comboP1-comboP2);
					else
						distance = 0;
					end
					
					self:x((sw*(GAMESTATE:GetCurMusicSeconds()/length)*0.85)-distance);
				end
			end;
			ShowHorsesMessageCommand=cmd(bounceend,0.5;zoom,0.4;);
		};
	}
end;

t[#t+1] = Def.ActorFrame {
	OnCommand=function (self)
		fgcurcommand = 0;
		fg2curcommand = 1;
		self:queuecommand('Update');
	end;
	UpdateCommand=function (self)
		posCheckTimer = posCheckTimer+0.0166;
		
		if posCheckTimer > 0.6 and not ended or GAMESTATE:GetCurMusicSeconds() >= 88.994 and not ended then
			posCheckTimer = 0;
			MESSAGEMAN:Broadcast('CheckPosition');
			if GAMESTATE:GetCurMusicSeconds() >= 88.994 and not Alone then
				ended = true;
				if comboP1>comboP2 then
					MESSAGEMAN:Broadcast('EndWin1');
				elseif comboP1<comboP2 then
					MESSAGEMAN:Broadcast('EndWin2');
				else
					MESSAGEMAN:Broadcast('EndDraw');
				end
			end;
			if GAMESTATE:GetCurMusicSeconds() >= 88.994 then
				ended = true;
			end;
		end
		
		if GAMESTATE:GetCurMusicSeconds() >= 5 and fgcurcommand == 0 then
			screen = SCREENMAN:GetTopScreen();
			P1 = SCREENMAN:GetTopScreen():GetChild('PlayerP1');
			P2 = SCREENMAN:GetTopScreen():GetChild('PlayerP2');
			screen:rotationz(0);
			screen:x(0);
			screen:y(0);
			screen:zoom(1);
			fgcurcommand = fgcurcommand+1;
		end;
		if GAMESTATE:GetCurMusicSeconds() >= 15.582 and fg2curcommand == 1 then
			MESSAGEMAN:Broadcast('ShowHorses');
			fg2curcommand = fg2curcommand+1;
		end;
		if GAMESTATE:GetCurMusicSeconds() >= 16.111 and fg2curcommand == 2 then
			HorsesOn = true;
			fg2curcommand = fg2curcommand+1;
		end;
		if GAMESTATE:GetCurMusicSeconds() >= 76.288 and fg2curcommand == 3 then
			MESSAGEMAN:Broadcast('FinalStretch');
			fg2curcommand = fg2curcommand+1;
		end;
		MESSAGEMAN:Broadcast('Update');
		self:queuecommand('Update2');
	end;
	Update2Command=function (self)
		self:sleep(0.0166);
		self:queuecommand('Update');
	end;
};

t[#t+1] = LoadActor("win0")..{
	OnCommand=cmd(wag;effectmagnitude,0,0,3;x,cw;y,ch*0.8;zoom,0;);
	EndDrawMessageCommand=cmd(linear,0.353;rotationz,360*1;zoom,1;sleep,99;);
};
t[#t+1] = LoadActor("win1")..{
	OnCommand=cmd(wag;effectmagnitude,0,0,3;x,cw;y,ch*0.8;zoom,0;);
	EndWin1MessageCommand=cmd(linear,0.353;rotationz,360*1;zoom,1;sleep,99;);
};
t[#t+1] = LoadActor("win2")..{
	OnCommand=cmd(wag;effectmagnitude,0,0,3;x,cw;y,ch*0.8;zoom,0;);
	EndWin2MessageCommand=cmd(linear,0.353;rotationz,360*1;zoom,1;sleep,99;);
};

return t;