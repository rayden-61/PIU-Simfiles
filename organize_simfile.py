import os 
dir_path = os.path.dirname(os.path.realpath(__file__))

# define a function to extract the meter and steps type information from a NOTEDATA section
def get_meter(notedata):
    for line in notedata:
        if line.startswith("#METER:"):
            meter_str = line.split(":")[1].strip().rstrip(";")
            try:
                meter = int(meter_str)
                return meter
            except ValueError:
                print(f"Invalid meter value: {meter_str}")
                return None
    return None
    
def get_stepstype(notedata):
    for line in notedata:
        if line.startswith("#STEPSTYPE:"):
            stepstype_str = line.split(":")[1].strip().rstrip(";")
            return stepstype_str
    return None
    
stepstype_order = { "pump-single": 0, 
    "pump-halfdouble": 1, 
    "pump-double": 2, 
    "pump-couple": 3, 
    "pump-routine": 4,
    "lights-cabinet": 5}
    
for subdir, dirs, files in os.walk(dir_path):
    for file in files:
        if file.endswith(".ssc"):
            # here we go again.
            # read in the simfile
            with open(os.path.join(subdir, file), "r") as f:
                lines = f.readlines()

            # extract the NOTEDATA sections and their meter information
            notedata_sections = []
            current_section = None
            ispastnotes = False
            for line in lines:
                if line.startswith("#NOTEDATA:"):
                    current_section = [line]
                elif current_section is not None:
                    current_section.append(line)
                    if line.startswith("#NOTES:"):
                        ispastnotes = True
                    elif line.startswith(";") and ispastnotes:
                        current_section.append("\n")
                        meter = get_meter(current_section)
                        stepstype = get_stepstype(current_section)
                        notedata_sections.append((meter, stepstype, current_section))
                        current_section = None
                        ispastnotes = False

            # first sort the NOTEDATA sections by meter
            notedata_sections = sorted(notedata_sections, key=lambda x: x[0])

            # then sort the NOTEDATA sections by stepstype
            notedata_sections = sorted(notedata_sections, key=lambda x: stepstype_order[x[1]])

            ispastbg = False
            # re-write the simfile with the NOTEDATA sections in the new order
            with open(os.path.join(subdir, file), "w") as f:
                for line in lines:
                    if line.startswith("#BGCHANGES:"):
                        ispastbg = True
                        f.write(line)
                    elif line.startswith(";") and ispastbg:
                        f.write(line)
                        f.write("\n")
                        for num in range(len(notedata_sections)):
                            meter, stepstype, notedata = notedata_sections.pop(0)
                            f.writelines(notedata)
                        break
                    else:
                        f.write(line)
            
            print(f"File processed: {os.path.join(subdir, file)}")