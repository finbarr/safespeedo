using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Reflection;
using Mojio.Client;
using Mojio;
using System.Threading;
using Mojio.Events;
using System.ComponentModel;
using System.IO;
using System.Diagnostics;

namespace data
{
    class Program
    {
        static async Task SimulateTrip(BMWClient client, string simulationFile)
        {
            StreamReader reader = new StreamReader(simulationFile);
            Console.WriteLine("Building trip");

            string line = "";
            reader.ReadLine();
            int counter = 0;
            int rainCounter = 0;
            int rainIntensity = 0;
            DateTime lastRequest = DateTime.Now;
            int millisecondsWait = 500;

            while ((line = reader.ReadLine()) != null)
            {
                string[] parts = line.Split(new char[] { ',' });
                double lat = double.Parse(parts[3]);
                double lon = double.Parse(parts[2]);
                DateTime stamp = DateTime.Parse(parts[1]);
                double speed = double.Parse(parts[7]);
                double mphSpeed = Math.Floor(speed * 2.236);

                // fake some rain a little ways in to the simulation
                if (rainCounter > 36)
                    rainIntensity = 62;

                if (rainCounter > 46)
                    rainIntensity = 0;

                if (counter == 0)
                {
                    var createResult = await client.CreateAsync<TripStatusEvent>(new TripStatusEvent()
                    {
                        Location = new Location() { Lat = lat, Lng = lon },
                        Speed = mphSpeed,
                        VehicleId = new Guid("{bc91e2ae-8c06-4fe0-8f2e-d4cda90d0559}"),
                        RPM = rainIntensity,
                        Time = stamp,
                    });
                    Console.WriteLine("LatLon:{0},{1} MPH:{2} WeatherIntensity:{3}", lat, lon, mphSpeed.ToString("0.00"), rainIntensity);
                }
                counter++;

                // skip 10 latlng coords -- we're a little too fast for the BMW simulator
                if (counter == 10)
                {
                    counter = 0;
                    rainCounter++;
                    var millisFromLastRequest = (int)DateTime.Now.Subtract(lastRequest).TotalMilliseconds;
                    if (millisFromLastRequest < millisecondsWait)
                        Thread.Sleep(millisecondsWait - millisFromLastRequest);
                }
            }
        }

        static async Task Test()
        {
            Guid appID = new Guid("{5ab5c0af-f502-49bf-bb74-132cc10245de}");
            Guid secretKey = new Guid("{f2167bc6-dc6a-4983-a69d-d555b36ec8c8}");

            var client = new BMWClient(BMWClient.Live);
            await client.BeginAsync(appID, secretKey);
            await client.SetUserAsync("joelpobar@gmail.com", "Term500blah@1");
            client.PageSize = 15;

            await SimulateTrip(client, "c:\\bmw\\csv\\simulator.csv");
        }

        static void Main(string[] args)
        {
            Test().Wait();
        }
    }
}
