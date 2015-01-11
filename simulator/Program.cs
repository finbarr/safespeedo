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

namespace data
{
    class LatLon
    {
        public double Latitude { get; set; }
    }

    class Program
    {
        static void PrintObj(object o)
        {
            Console.ForegroundColor = ConsoleColor.Green;
            Console.WriteLine(o.GetType().Name);
            Console.ForegroundColor = ConsoleColor.Gray;
            foreach (PropertyDescriptor descriptor in TypeDescriptor.GetProperties(o))
            {
                string name = descriptor.Name;
                object value = descriptor.GetValue(o);
                if (value == null) value = "null";
                Console.WriteLine("    {0}={1}", name, value);
            }
        }

        static string PrintHtml(object o)
        {
            StringBuilder builder = new StringBuilder();
            builder.AppendLine("<b>" + o.GetType().Name + "</b></br>");
            foreach (PropertyDescriptor descriptor in TypeDescriptor.GetProperties(o))
            {
                string name = descriptor.Name;
                object value = descriptor.GetValue(o);
                if (value == null) value = "null";
                builder.AppendLine(string.Format("&nbsp;&nbsp;&nbsp;&nbsp;{0}={1}</br>", name, value));
            }

            return builder.ToString();
        }

        static async Task GetTripEvents(BMWClient client, Guid tripId, Guid vehicleId)
        {
            MojioResponse<Results<Event>> eventResponse = await client.GetByAsync<Event, Trip>(tripId);
            Results<Event> events = eventResponse.Data;

            if (events != null)
            {
                foreach (Event e in events.Data)
                {
                    PrintObj(e);
                }
            }
        }

        

        static async Task BuildTrip(BMWClient client, string csvfile)
        {
            StreamReader reader = new StreamReader(csvfile);

            // our trip 114c8181-9449-47a4-9b94-2301c53f7711
            Guid appID = new Guid("{5ab5c0af-f502-49bf-bb74-132cc10245de}");
            Guid secretKey = new Guid("{f2167bc6-dc6a-4983-a69d-d555b36ec8c8}");
            Guid ownerId = new Guid("{3399e126-c363-49e0-b5bc-9f10ebeff759}");

            Console.WriteLine("Building trip");

            // Fetch first page of 15 trips
            MojioResponse<Results<Trip>> response = await client.GetAsync<Trip>();
            Results<Trip> results = response.Data;

            foreach (var t in results.Data)
            {
                Console.WriteLine("Id:" + t.Id.ToString() + " " + t.StartAddress.Address1 + " " + t.StartAddress.Address2 + " VehicleId:" + t.VehicleId.ToString() + " MojioId: " + t.MojioId.ToString());
            }

            var myTrip = results.Data.First(c => c.Id.ToString() == "114c8181-9449-47a4-9b94-2301c53f7711");
            //var createResult = await client.CreateAsync<IgnitionEvent>(new IgnitionEvent()
            //{
            //    Location = new Location() { Lat = 51.63958102, Lng = -0.916797108 },
            //    Odometer = 500,
            //    VehicleId = new Guid("{bc91e2ae-8c06-4fe0-8f2e-d4cda90d0559}"),
            //    TripId = myTrip.Id,
            //    OwnerId = ownerId,
            //    Time = DateTime.Now,
            //});

            string line = "";
            reader.ReadLine();
            int counter = 0;
            int rainCounter = 0;
            int rainIntensity = 0;

            while ((line = reader.ReadLine()) != null)
            {
                string[] parts = line.Split(new char[] { ',' });
                double lat = double.Parse(parts[3]);
                double lon = double.Parse(parts[2]);
                DateTime stamp = DateTime.Parse(parts[1]);
                double speed = double.Parse(parts[7]);
                double mphSpeed = Math.Floor(speed * 2.236);


                // fake some rain
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
                    Console.WriteLine("{0},{1} {2} {3}", lat, lon, mphSpeed, rainIntensity);
                }
                counter++;

                if (counter == 10)
                {
                    counter = 0;
                    rainCounter++;
                    Thread.Sleep(440);
                }
                else
                {
                    Console.Write("/");
                }
            }
        }

        static async Task Test()
        {
            StreamWriter writer = new StreamWriter("out.html");

            // our trip 114c8181-9449-47a4-9b94-2301c53f7711

            Guid appID = new Guid("{5ab5c0af-f502-49bf-bb74-132cc10245de}");
            Guid secretKey = new Guid("{f2167bc6-dc6a-4983-a69d-d555b36ec8c8}");
            Guid ownerId = new Guid("{3399e126-c363-49e0-b5bc-9f10ebeff759}");

            Guid tripId = new Guid("{114c8181-9449-47a4-9b94-2301c53f7711}");
            Guid vehicleId = new Guid("{bc91e2ae-8c06-4fe0-8f2e-d4cda90d0559}");

            var client = new BMWClient(BMWClient.Live);
            await client.BeginAsync(appID, secretKey);
            await client.SetUserAsync("joelpobar@gmail.com", "Term500blah@1");
            client.PageSize = 15;

            await BuildTrip(client, "c:\\bmw\\csv\\simulator.csv");
            await GetTripEvents(client, tripId, vehicleId);

            // Fetch first page of 15 trips
            MojioResponse<Results<Trip>> response = await client.GetAsync<Trip>();
            Results<Trip> results = response.Data;

            //// Iterate over each trip
            //var trips = results.Data.GroupBy(c => c.StartAddress.Address1);

            //foreach (var group in trips)
            //{
            //    Trip trip = group.First();
            //    Console.WriteLine(trip.MojioId);
            //    Console.WriteLine(trip.StartAddress.Address1);
            //    var vehicleId = trip.VehicleId;
            //    client.PageSize = 5000;

            //    MojioResponse<Results<Event>> eventResponse = await client.GetByAsync<Event, Vehicle>(vehicleId);
            //    Results<Event> events = eventResponse.Data;

            //    if (events != null)
            //    {
            //        foreach (Event e in events.Data)
            //        {
            //            PrintObj(e);
            //            var r = PrintHtml(e);
            //            writer.WriteLine(r);
            //            writer.Flush();
            //        }
            //    }
            //}

                //while (true)
                //{
                //    MojioResponse<Vehicle> vehicleResponse = await client.GetAsync<Vehicle>(vehicleId);
                //    Vehicle vehicle = vehicleResponse.Data;
                //    Console.WriteLine("RPM: {0} LastSpeed: {1}, LastAccelerometer: {2}, LastPedal: {3}, LastAltitude: {4}", vehicle.LastRpm, vehicle.LastSpeed, vehicle.LastAccelerometer, vehicle.LastAcceleratorPedal, vehicle.LastAltitude);
                //    Thread.Sleep(500);
                //}
        }

        static void Main(string[] args)
        {
            Test().Wait();
        }
    }
}
