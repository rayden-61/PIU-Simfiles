# HOW TO USE:
# Copy this script to the root of each song group folder in order to identify issues more easily
# if any happens at runtime. At first the script will not do any actual changes to the simfile,
# this can be changed by uncommenting the two last lines in this script. Have fun!

import simfile
import os 
import re

# Default value
songlength = 0

# Some charts will not be able to parse properly with Simfile due to custom notetypes.
# If encountered, attempt to fix or remove the offending chart and manually edit it later

dir_path = os.path.dirname(os.path.realpath(__file__))

for subdir, dirs, files in os.walk(dir_path):
    for file in files:
        if file.endswith(".MP3") or file.endswith(".mp3") or file.endswith(".OGG") or file.endswith(".ogg"):
            # Grab song length for last second hint
            songpath = os.path.join(subdir, file)
            # TODO: Figure out song path error
            songlength = os.popen('ffprobe.exe -i "' + songpath + '" -show_entries format=duration -v quiet -of csv="p=0"').read()[:-1]
            #print(songpath + " = " + songlength)
            
            cur_dir_path = subdir
            
            for subdir, dirs, files in os.walk(cur_dir_path):
                for file in files:
                    if file.endswith(".ssc"):
                        print(f"Accessing {os.path.join(subdir, file)}")
                        ssc = simfile.open(os.path.join(subdir, file))
                        charts = ssc.charts
                        
                        # Correct banner name
                        if not re.search("_B", ssc.banner.upper()):
                            ssc.banner = ssc.banner[:-4] + "_B.png"
                            print("Added dedicated banner: " + ssc.banner)
                        
                        # Process last second hint properly
                        ssc.lastsecondhint = str(songlength)
                        print("Last second hint: " + str(ssc.lastsecondhint))
                        
                        # Remove all UCS and Quest charts if you're a purist.
                        #charts = list(filter(lambda chart: "UCS" not in chart.description.upper() and "QUEST" not in chart.description.upper(), ssc.charts))
                        
                        # Process individual chart lists by steps type
                        singles = list(filter(lambda chart: chart.stepstype == 'pump-single', charts))
                        halfdoubles = list(filter(lambda chart: chart.stepstype == 'pump-halfdouble', charts))
                        doubles = list(filter(lambda chart: chart.stepstype == 'pump-double', charts))
                        routines = list(filter(lambda chart: chart.stepstype == 'pump-routine', charts))
                        couples = list(filter(lambda chart: chart.stepstype == 'pump-couple', charts))
                        
                        # Reset everything to Edit (prevent difficulty duplicates down the line)
                        for chart in charts:
                            chart.difficulty = "Edit"
                            
                        # Mark the highest rated chart up to 5 as Easy for
                        # demonstration screens
                        easycharts = list(filter(lambda chart: int(chart.meter) <= 5, singles))
                        easycharts.reverse()
                        
                        # If a chart was found, mark it respectively
                        if len(easycharts) > 0:
                            easycharts[0].difficulty = "Easy"
                        
                        # Mark the highest single digit level chart as Medium and 
                        # the lowest double digit level chart as Hard for lights
                        mediumcharts = list(filter(lambda chart: int(chart.meter) < 10, singles))
                        mediumcharts.reverse()
                        hardcharts = list(filter(lambda chart: int(chart.meter) >= 10, singles))
                        
                        # If the two charts were found, mark them respectively
                        if len(mediumcharts) > 0 and len(hardcharts) > 0:
                            mediumcharts[0].difficulty = "Medium"
                            hardcharts[0].difficulty = "Hard"
                        
                        for chart in charts:
                            # Make all descriptions uppercase
                            chart.description = chart.description.upper()
                            
                            # Remove redundant level names in chart descriptions (if still present)
                            redundant = "S"
                            if chart.stepstype == "pump-halfdouble":
                                # Pro HDB charts are tagged as D in descriptions for some reason
                                redundant = "D"
                            elif chart.stepstype == "pump-double":
                                redundant = "D"
                            elif chart.stepstype == "pump-routine":
                                redundant = "R"
                            elif chart.stepstype == "pump-couple":
                                redundant = "C"
                            redundant += str(chart.meter)

                            # Add generic credit if blank
                            if chart.credit == "":
                                chart.credit = "ANDAMIRO"
                                
                            print("Chart: " + redundant + " / Diff: " + chart.difficulty + " / Chart description: " + chart.description)
                            
                        ssc.charts = charts
                        print("\n")
                        
                        with open(os.path.join(subdir, file), 'w', encoding='utf-8') as outfile:
                            ssc.serialize(outfile)