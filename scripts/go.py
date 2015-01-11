import csv
import sys

accidents = open("Accidents0512.csv", 'r')
output = open("result.csv", 'w')

try:
    reader = csv.reader(accidents)
    writer = csv.writer(output)

    for row in reader: 
       " lat, lng, accidentid, accident_sev, num of veh, num of casualties "
       print row[3] + "," + row[4] + "," + row[0] + "," + row[6] + "," + row[7] + "," + row[8]
       writer.writerow((row[3], row[4], row[0], row[6], row[7], row[8]))
finally:
    accidents.close()
    output.close();
