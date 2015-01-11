import pandas as pd, numpy as np, matplotlib.pyplot as plt
from sklearn.cluster import DBSCAN
from geopy.distance import great_circle

df = pd.read_csv('result.csv')
co = df.as_matrix(columns=['Longitude', 'Latitude'])
coordinates = co[:10000]
coordinates = [[lon, lat] for lon, lat in co if not np.isnan(lon) and not np.isnan(lat)]

print "Got coordinates" 

def getCentroid(points):
  n = points.shape[0]
  sum_lon = np.sum(points[:, 1])
  sum_lat = np.sum(points[:, 0])
  return (sum_lon/n, sum_lat/n)

def getNearestPoint(set_of_points, point_of_reference):
  closest_point = None
  closest_dist = None
  for point in set_of_points:
    point = (point[1], point[0])
    dist = great_circle(point_of_reference, point).meters
    if (closest_dist is None) or (dist < closest_dist):
      closest_point = point
      closest_dist = dist
  return closest_point

print "About to cluster"

db = DBSCAN(eps=1, min_samples=5).fit(coordinates)
labels = db.labels_
num_clusters = len(set(labels)) - (1 if -1 in labels else 0)
clusters = pd.Series([coordinates[labels == i] for i in xrange(num_clusters)])
print('Number of clusters: %d' % num_clusters)

lon = []
lat = []
for i, cluster in clusters.iteritems():
  if len(cluster) < 3:
    representative_point = (cluster[0][1], cluster[0][0])
  else:
    representative_point = getNearestPoint(cluster, getCentroid(cluster))
  lon.append(representative_point[0])
  lat.append(representative_point[1])
  print representative_point