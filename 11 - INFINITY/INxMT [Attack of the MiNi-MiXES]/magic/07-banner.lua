local ratio = PREFSMAN:GetPreference("DisplayAspectRatio")




if (ratio > 1.5) then
	return LoadActor("07-PROCEDIMIENTOS PARA LLEGAR A UN COMUN ACUERDO-bg.png")..{
	OnCommand=cmd(Center;FullScreen;sleep,3.00);
	}
else
	return LoadActor("07-PROCEDIMIENTOS PARA LLEGAR A UN COMUN ACUERDO-bg.png")..{
	OnCommand=cmd(Center;FullScreen;sleep,3.00);
}
end;
