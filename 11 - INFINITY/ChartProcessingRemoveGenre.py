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
            # If on Linux, comment the first line and uncomment the second one. Or just remove the .exe extension from ffprobe
            #songlength = os.popen('ffprobe.exe -i "' + songpath + '" -show_entries format=duration -v quiet -of csv="p=0"').read()[:-1]
            songlength = os.popen('ffprobe -i "' + songpath + '" -show_entries format=duration -v quiet -of csv="p=0"').read()[:-1]
            
            #print(songpath + " = " + songlength)
            
            cur_dir_path = subdir
            
            for subdir, dirs, files in os.walk(cur_dir_path):
                for file in files:
                    if file.endswith(".ssc"):
                        print(f"Accessing {os.path.join(subdir, file)}")
                        ssc = simfile.open(os.path.join(subdir, file))
                        charts = ssc.charts
                        
                        # Process last second hint properly
                        ssc.lastsecondhint = str(songlength)
                        ssc.genre = "WORLD MUSIC"
                        print("Last second hint: " + str(ssc.lastsecondhint))
                            
                        ssc.charts = charts
                        for chart in charts:
                            chart['LASTSECONDHINT'] = str(songlength)
                        print("\n")
                        
                        # Uncomment the two bottom lines to apply all changes to the ssc file!
                        with open(os.path.join(subdir, file), 'w', encoding='utf-8') as outfile:
                            ssc.serialize(outfile)

