import csv
import sys
import random

def random_speed_generator(speed_limit_list): 
  car_speeds = []
  start_speed = speed_limit_list[0]
  current = start_speed
  
  for limit in speed_limit_list: 
    difference = abs(current - limit)
    if (difference/limit > 0.05): 
      # gradually ramp speed
      if (current - limit) < 1.0: 
        current = current * 1.01
      else:
        current = current * 0.99
      print "Limit: " + str(limit) + " Ramp: " + str(current)
      car_speeds.append(current)
    else: 
      # hover around the limit
      random_speed = random.randint(int(limit * .96), int(limit * 1.02))
      current = random_speed
      print "Limit: " + str(limit) + " rand: " + str(random_speed)
      car_speeds.append(random_speed)

  #print car_speeds
  return car_speeds

reader = csv.reader(open("myoutput.csv", 'r'))
speeds = []
for row in reader: 
  if not row[2] == "": 
    speeds.append(float(row[2]))

random_speed_generator(speeds)
  