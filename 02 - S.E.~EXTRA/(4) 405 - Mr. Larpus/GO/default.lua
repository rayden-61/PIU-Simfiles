local ax = SCREEN_WIDTH/640;
local ay = SCREEN_HEIGHT/480;

local t = Def.ActorFrame{}

local isTaroNuke = false

if GAMESTATE:IsHumanPlayer(PLAYER_1) then
	if GAMESTATE:GetCurrentSteps(PLAYER_1):GetAuthorCredit() == "TaroNuke" then
		isTaroNuke = true;
	end
end

if GAMESTATE:IsHumanPlayer(PLAYER_2) then
	if GAMESTATE:GetCurrentSteps(PLAYER_2):GetAuthorCredit() == "TaroNuke" then
		isTaroNuke = true;
	end
end

local BounceEndBezier =
{
	0,0,
	1/3, 0.7,
	0.58, 1.42,
	1, 1
}
function Actor:bounceend(t)
	self:tween( t, "TweenType_Bezier", BounceEndBezier )
end
	
if isTaroNuke == true then
t[#t+1] = LoadActor("arrow.png")..{
	OnCommand=cmd(zoom,0;x,480*ax;y,240*ay;bounceend,.04;zoom,1;sleep,2;diffusealpha,0;sleep,0.1;diffusealpha,1;sleep,0.1;diffusealpha,0;sleep,0.1;diffusealpha,1;sleep,0.1;diffusealpha,0;sleep,0.1;diffusealpha,1;sleep,0.1;diffusealpha,0;queuecommand,"Stop");
	StopCommand=cmd(stoptweening;);
}
end		

return t;