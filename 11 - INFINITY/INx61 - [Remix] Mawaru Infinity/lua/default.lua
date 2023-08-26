local BounceEndBezier =
{
	0,0,
	1/3, 0.7,
	0.58, 1.42,
	1, 1
}

local characters = Def.ActorFrame{
	
	Def.ActorFrame{
		InitCommand=function (self) char_ayaze=self; self:bob();
		self:effectclock('music'); self:effectmagnitude(0,4,0); self:zoom(0); self:zoomx(3) end, HideQCommand=cmd(zoomy,0;zoomx,3;),
		
		HideCommand=cmd(bouncebegin,0.2;zoomy,0;zoomx,3;),
		--Bounceend doesn't exist in StepF2 so reimplement the function by copying from 02 ActorDef. -SF
		SpawnCommand=function(self)
			--Equivalent of bounceend(0.3)
			self:tween( 0.3, "TweenType_Bezier", BounceEndBezier )
			self:zoom(1) 
		end,
		SpawnQCommand=cmd(zoom,1),
		
		Def.ActorFrame{
		
			OnCommand=cmd(zoom,0.9),
			
			Def.Sprite {
				Texture="ayaze/ayaze_idle 4x1.png",
				Frame0000=0,
				Delay0000=0.125,
				Frame0001=1,
				Delay0001=0.125,
				Frame0002=2,
				Delay0002=0.125,
				Frame0003=1,
				Delay0003=0.125,
				Frame0004=0,
				Delay0004=0.125,
				Frame0005=1,
				Delay0005=0.125,
				Frame0006=3,
				Delay0006=0.125,
				Frame0007=1,
				Delay0007=0.125,
				OnCommand=cmd(diffusealpha,1),
				IdleCommand=cmd(diffusealpha,1),
				AttackCommand=cmd(diffusealpha,0),
				HurtCommand=cmd(diffusealpha,0),
				CastCommand=cmd(diffusealpha,0),
				Cast2Command=cmd(diffusealpha,0),
			},
			
			Def.Sprite {
				Texture="ayaze/ayaze_attack 3x2.png",
				Frame0000=0,
				Delay0000=0.066,
				Frame0001=1,
				Delay0001=0.066,
				Frame0002=2,
				Delay0002=0.066,
				Frame0003=3,
				Delay0003=0.066,
				Frame0004=4,
				Delay0004=999,
				OnCommand=cmd(diffusealpha,0),
				IdleCommand=cmd(diffusealpha,0),
				AttackCommand=cmd(setstate,0;diffusealpha,1;zoom,1.1;linear,0.2;zoom,1),
				HurtCommand=cmd(diffusealpha,0),
				CastCommand=cmd(diffusealpha,0),
				Cast2Command=cmd(diffusealpha,0),
			},
			
			Def.Sprite {
				Texture="ayaze/ayaze_cast 3x2.png",
				Frame0000=0,
				Delay0000=0.066,
				Frame0001=1,
				Delay0001=0.066,
				Frame0002=2,
				Delay0002=0.066,
				Frame0003=3,
				Delay0003=0.066,
				Frame0004=4,
				Delay0004=999,
				OnCommand=cmd(diffusealpha,0),
				AttackCommand=cmd(diffusealpha,0),
				HurtCommand=cmd(diffusealpha,0),
				CastCommand=cmd(setstate,0;diffusealpha,1;zoom,1.1;linear,0.2;zoom,1),
				Cast2Command=cmd(setstate,0;diffusealpha,1;zoom,1.1;linear,0.2;zoom,1),
				IdleCommand=cmd(diffusealpha,0),
			},
			
			LoadActor( "ayaze/ayaze_hurt.lua" )..{
				OnCommand=cmd(diffusealpha,0),
				HurtCommand=cmd(vibrate;diffusealpha,1;sleep,0.3;queuecommand,"StopVib"),
				StopVibCommand=cmd(stopeffect),
				CastCommand=cmd(diffusealpha,0),
				Cast2Command=cmd(diffusealpha,0),
				IdleCommand=cmd(diffusealpha,0),
				AttackCommand=cmd(diffusealpha,0),
			},
			
			Def.ActorFrame{
				OnCommand=cmd(zoom,2.5;spin;effectmagnitude,0,0,90),
				LoadActor( "casting" )..{
				OnCommand=cmd(blend,'BlendMode_Add';diffuse,1,0.5,0,0;),
				CastCommand=function (self)
					self:zoom(1.1);
					self:linear(0.8);
					self:diffusealpha(1);
					self:linear(1);
					self:zoom(0.7);
					self:linear(0.8);
					self:diffusealpha(0);
				end, },
			},
			
			Def.ActorFrame{
			CastCommand=function(self) self:playcommand('Inner'); chara_drand = math.random(0,360);
			chara_dspd = (math.random(0,600)/100)-3; self:playcommand('Turn') end,
			TurnCommand=cmd(rotationz,chara_drand;
			linear,0.1;rotationz,chara_drand+(60*chara_dspd);
			linear,0.1;rotationz,chara_drand+(110*chara_dspd);
			linear,0.1;rotationz,chara_drand+(150*chara_dspd);
			linear,0.1;rotationz,chara_drand+(180*chara_dspd);
			linear,0.2;rotationz,chara_drand+(200*chara_dspd);
			linear,1.0;rotationz,chara_drand+(350*chara_dspd);
			linear,0.2;rotationz,chara_drand+(370*chara_dspd);
			linear,0.2;rotationz,chara_drand+(400*chara_dspd);
			linear,0.2;rotationz,chara_drand+(440*chara_dspd);
			linear,0.2;rotationz,chara_drand+(490*chara_dspd);
			linear,0.2;rotationz,chara_drand+(550*chara_dspd);),
			
				LoadActor( "triangle" )..{
				OnCommand=cmd(vertalign,top;blend,'BlendMode_Add';diffusealpha,0;fadetop,0.2;fadebottom,0.2;
				diffuseblink;effectcolor1,1,0.5,0,0.3;effectcolor2,1,0.5,0,1;effectperiod,0.066),
				InnerCommand=cmd(zoom,1;diffusealpha,0;linear,0.5;diffusealpha,1;zoomy,5;zoomx,3;linear,1.5;
				zoomy,8;zoomx,3;linear,0.6;zoomy,20;zoomx,0;sleep,0;diffusealpha,0;),
				},
			},
			Def.ActorFrame{
			CastCommand=function(self) self:playcommand('Inner'); chara_drand = math.random(0,360);
			chara_dspd = (math.random(0,600)/100)-3; self:playcommand('Turn') end,
			TurnCommand=cmd(rotationz,chara_drand;
			linear,0.1;rotationz,chara_drand+(60*chara_dspd);
			linear,0.1;rotationz,chara_drand+(110*chara_dspd);
			linear,0.1;rotationz,chara_drand+(150*chara_dspd);
			linear,0.1;rotationz,chara_drand+(180*chara_dspd);
			linear,0.2;rotationz,chara_drand+(200*chara_dspd);
			linear,1.0;rotationz,chara_drand+(350*chara_dspd);
			linear,0.2;rotationz,chara_drand+(370*chara_dspd);
			linear,0.2;rotationz,chara_drand+(400*chara_dspd);
			linear,0.2;rotationz,chara_drand+(440*chara_dspd);
			linear,0.2;rotationz,chara_drand+(490*chara_dspd);
			linear,0.2;rotationz,chara_drand+(550*chara_dspd);),
			
				LoadActor( "triangle" )..{
				OnCommand=cmd(vertalign,top;blend,'BlendMode_Add';diffusealpha,0;fadetop,0.2;fadebottom,0.2;
				diffuseblink;effectcolor1,1,0.5,0,0.3;effectcolor2,1,0.5,0,1;effectperiod,0.066),
				InnerCommand=cmd(zoom,1;diffusealpha,0;linear,0.5;diffusealpha,1;zoomy,5;zoomx,3;linear,1.5;
				zoomy,8;zoomx,3;linear,0.6;zoomy,20;zoomx,0;sleep,0;diffusealpha,0),
				},
			},
			Def.ActorFrame{
			CastCommand=function(self) self:playcommand('Inner'); chara_drand = math.random(0,360);
			chara_dspd = (math.random(0,600)/100)-3; self:playcommand('Turn') end,
			TurnCommand=cmd(rotationz,chara_drand;
			linear,0.1;rotationz,chara_drand+(60*chara_dspd);
			linear,0.1;rotationz,chara_drand+(110*chara_dspd);
			linear,0.1;rotationz,chara_drand+(150*chara_dspd);
			linear,0.1;rotationz,chara_drand+(180*chara_dspd);
			linear,0.2;rotationz,chara_drand+(200*chara_dspd);
			linear,1.0;rotationz,chara_drand+(350*chara_dspd);
			linear,0.2;rotationz,chara_drand+(370*chara_dspd);
			linear,0.2;rotationz,chara_drand+(400*chara_dspd);
			linear,0.2;rotationz,chara_drand+(440*chara_dspd);
			linear,0.2;rotationz,chara_drand+(490*chara_dspd);
			linear,0.2;rotationz,chara_drand+(550*chara_dspd);),
			
				LoadActor( "triangle" )..{
				OnCommand=cmd(vertalign,top;blend,'BlendMode_Add';diffusealpha,0;fadetop,0.2;fadebottom,0.2;
				diffuseblink;effectcolor1,1,0.5,0,0.3;effectcolor2,1,0.5,0,1;effectperiod,0.066),
				InnerCommand=cmd(zoom,1;diffusealpha,0;linear,0.5;diffusealpha,1;zoomy,5;zoomx,3;linear,1.5;
				zoomy,8;zoomx,3;linear,0.6;zoomy,20;zoomx,0;sleep,0;diffusealpha,0),
				},
			},
			Def.ActorFrame{
			CastCommand=function(self) self:playcommand('Inner'); chara_drand = math.random(0,360);
			chara_dspd = (math.random(0,600)/100)-3; self:playcommand('Turn') end,
			TurnCommand=cmd(rotationz,chara_drand;
			linear,0.1;rotationz,chara_drand+(60*chara_dspd);
			linear,0.1;rotationz,chara_drand+(110*chara_dspd);
			linear,0.1;rotationz,chara_drand+(150*chara_dspd);
			linear,0.1;rotationz,chara_drand+(180*chara_dspd);
			linear,0.2;rotationz,chara_drand+(200*chara_dspd);
			linear,1.0;rotationz,chara_drand+(350*chara_dspd);
			linear,0.2;rotationz,chara_drand+(370*chara_dspd);
			linear,0.2;rotationz,chara_drand+(400*chara_dspd);
			linear,0.2;rotationz,chara_drand+(440*chara_dspd);
			linear,0.2;rotationz,chara_drand+(490*chara_dspd);
			linear,0.2;rotationz,chara_drand+(550*chara_dspd);),
			
				LoadActor( "triangle" )..{
				OnCommand=cmd(vertalign,top;blend,'BlendMode_Add';diffusealpha,0;fadetop,0.2;fadebottom,0.2;
				diffuseblink;effectcolor1,1,0.5,0,0.3;effectcolor2,1,0.5,0,1;effectperiod,0.066),
				InnerCommand=cmd(zoom,1;diffusealpha,0;linear,0.5;diffusealpha,1;zoomy,5;zoomx,3;linear,1.5;
				zoomy,8;zoomx,3;linear,0.6;zoomy,20;zoomx,0;sleep,0;diffusealpha,0),
				},
			},
		
		},
		
	},
	
}

return characters
