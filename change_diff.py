import simfile
import os 
dir_path = os.path.dirname(os.path.realpath(__file__))

# Some charts will not be able to parse properly with Simfile for really weird reasons.
# If encountered, attempt to fix or remove the offending chart and manually edit it later.

for subdir, dirs, files in os.walk(dir_path):
    for file in files:
        if file.endswith(".ssc"):
            ssc = simfile.open(os.path.join(subdir, file))
            print(f"Acessing {os.path.join(subdir, file)}")
            
            singles = list(filter(lambda chart: chart.stepstype == 'pump-single', ssc.charts))
            mediumcharts = list(filter(lambda chart: int(chart.meter) < 10, singles))
            mediumcharts.reverse()
            hardcharts = list(filter(lambda chart: int(chart.meter) > 10, singles))
            
            if len(mediumcharts) == 0 or len(hardcharts) == 0:   
                if len(singles) >= 2:
                    singles[0].difficulty = "Medium"
                    print(f"Chart {singles[0].stepstype} {singles[0].meter} is now Medium")
                    singles[1].difficulty = "Hard"
                    print(f"Chart {singles[1].stepstype} {singles[1].meter} is now Hard")
                else:
                    print(f"Not enough charts available!")
            else:
                mediumcharts[0].difficulty = "Medium"
                print(f"Chart {mediumcharts[0].stepstype} {mediumcharts[0].meter} is now Medium")
                hardcharts[0].difficulty = "Hard"
                print(f"Chart {hardcharts[0].stepstype} {hardcharts[0].meter} is now Hard")
                
            with open(os.path.join(subdir, file), 'w', encoding='utf-8') as outfile:
                ssc.serialize(outfile)