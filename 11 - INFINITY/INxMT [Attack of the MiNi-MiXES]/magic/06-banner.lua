local ratio = PREFSMAN:GetPreference("DisplayAspectRatio")




if (ratio > 1.5) then
	return LoadActor("06-K.O.A. Alice In Wonderworld-bg.png")..{
	OnCommand=cmd(Center;FullScreen;sleep,3.00);
	}
else
	return LoadActor("06-K.O.A. Alice In Wonderworld-bg.png")..{
	OnCommand=cmd(Center;FullScreen;sleep,3.00);
}
end;
