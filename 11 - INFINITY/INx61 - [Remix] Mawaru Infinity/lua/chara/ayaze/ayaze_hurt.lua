return Def.ActorFrame{

	LoadActor( "ayaze_hurt 2x1.png" )..{
		OnCommand=cmd(animate,0;setstate,0;cullmode,'CullMode_Back';)
	},
	LoadActor( "ayaze_hurt 2x1.png" )..{
		OnCommand=cmd(addy,3;animate,0;setstate,1;cullmode,'CullMode_Back';rotationy,180;)
	}
	
}