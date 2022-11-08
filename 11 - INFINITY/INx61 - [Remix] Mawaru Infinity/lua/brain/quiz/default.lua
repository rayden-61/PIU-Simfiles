dm_quiz_choices = {
{3,5,1,-1,-1}, -- 4 + ? = 7
{3,5,1,-1,-1}, -- 4 + ? = 7
}

dm_quiz_answers = {3,3}


-----------------------------------------------
--------------DON'T TOUCH IT KIDDO-------------
-----------------------------------------------

function mimi_shuffle(t)
	local n = table.getn(t)
 
	while n >= 2 do
		-- n is now the last pertinent index
		local k = math.random(n) -- 1 <= k <= n
		-- Quick swap
		t[n], t[k] = t[k], t[n]
		n = n - 1
	end
 
	return t
end

for i=1,#dm_quiz_choices do
	dm_quiz_choices[i] = mimi_shuffle(dm_quiz_choices[i])
	--randomize choice order
end

local t = Def.ActorFrame{}

t[#t+1] = Def.ActorFrame{
	OnCommand=cmd(y,-100;zoomx,0.75);
	QuestionOnMessageCommand=function(self)
		self:playcommand('Do');
		self:x(dm_p1pos)
		self:linear(60/dm_bpm)
		self:y(SCREEN_CENTER_Y);
	end,
	QuestionOffMessageCommand=cmd(linear,60/dm_bpm;y,-100),
	LoadActor("back")..{
		
	},
	LoadActor("questions")..{
		OnCommand=function(self)
			self:animate(false)
			dm_questions1 = self;
		end
	},
}

t[#t+1] = Def.ActorFrame{
	OnCommand=cmd(y,-100;zoomx,0.75);
	QuestionOnMessageCommand=function(self)
		self:playcommand('Do');
		self:x(dm_p2pos)
		self:linear(60/dm_bpm)
		self:y(SCREEN_CENTER_Y);
	end,
	QuestionOffMessageCommand=cmd(linear,60/dm_bpm;y,-100),
	LoadActor("back")..{
		
	},
	LoadActor("questions")..{
		OnCommand=function(self)
			self:animate(false)
			dm_questions2 = self;
		end
	},
}


return t