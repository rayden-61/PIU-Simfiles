local ratio = PREFSMAN:GetPreference("DisplayAspectRatio")




if (ratio > 1.5) then
	return LoadActor("IN33-wide.png")..{
		OnCommand=cmd(Center);
	}
else
	return LoadActor("IN33.png")..{
	OnCommand=cmd(Center);
}
end;


	