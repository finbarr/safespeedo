import json, requests
import csv
import sys
from bs4 import BeautifulSoup

url = "http://route.st.nlp.nokia.com/routing/6.2/getlinkinfo.json"

def parse_kml(kmlfile):
  print "Parsing KML file " + kmlfile
  soup = BeautifulSoup(open(kmlfile, 'r'))
  res = soup.coordinates.text.strip().split(' ')
  latlngs = [[x[0], x[1]] for x in (x.split(',') for x in res)]
  return latlngs
  
def haversine(lon1, lat1, lon2, lat2):
  # convert decimal degrees to radians 
  lon1, lat1, lon2, lat2 = map(radians, [lon1, lat1, lon2, lat2])
  # haversine formula 
  dlon = lon2 - lon1 
  dlat = lat2 - lat1 
  a = sin(dlat/2)**2 + cos(lat1) * cos(lat2) * sin(dlon/2)**2
  c = 2 * asin(sqrt(a)) 
  km = 6367 * c
  return km

if (len(sys.argv) < 2): 
  print "getspeeds kmlfile.kml outputfile.csv"
  exit(1)

latlngs = parse_kml(sys.argv[1])
writer = csv.writer(open(sys.argv[2], 'w'))

for pair in latlngs: 
  #expects lat (pair[1]) then lng (pair[0]) 
  latlng = str(pair[1]) + ',' + str(pair[0])
  print latlng
  params=dict(
    waypoint=latlng,
    app_id='DemoAppId01082013GAL',
    app_code='AJKnXv84fjrb0KIHawS0Tg',
  )

  resp = requests.get(url=url, params=params)
  print resp.content
  data = json.loads(resp.content)
  speedLimit = data.get('Response').get('Link')[0].get('SpeedLimit')
  print str(latlng) + "," + str(speedLimit)
  writer.writerow((pair[1], pair[0], speedLimit))
  
  