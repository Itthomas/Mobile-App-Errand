import 'dart:async';
import 'dart:convert';
//import 'dart:html';
//import 'dart:js';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart';
import 'package:url_launcher/url_launcher.dart';
//import 'get_request.dart';
//import 'package:http/http.dart';

String startingPoint = 'none';
String destination1 = 'none';
String destination2 = 'none';
String destination3 = 'none';
String destination4 = 'none';
String end = 'none';
String googleMapsUrl = 'none';

void main(context) {
  runApp(MaterialApp(
    home: FirstRoute()
  ));
}

class FirstRoute extends StatelessWidget {
  @override
  Widget build(BuildContext context){
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text('Errand'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Container(
          margin: EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildstartingPointForm(),
                _buildDestination1Form(),
                _buildDestination2Form(),
                _buildDestination3Form(),
                _buildDestination4Form(),
                _buildEndForm(),
                SizedBox(height: 40),
                ElevatedButton(
                    onPressed: () {
                      if(!_formKey.currentState!.validate()){
                        return;
                      }
                      _formKey.currentState!.save();
                      Navigator.push(context, MaterialPageRoute(builder: (context)=>SecondRoute()));
                      return;
                    },
                    child: Text('Calculate Fastest Route')
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class SecondRoute extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Directions"),
      ),
      body: FutureBuilder(
        builder: (ctx, snapshot) {
          // Checking if future is resolved or not
          if (snapshot.connectionState == ConnectionState.done) {
            // If we got an error
            if (snapshot.hasError) {
              return Center(
                child: Text(
                  '${snapshot.error} occured',
                  style: TextStyle(fontSize: 18),
                ),
              );

              // if we got our data
            } else if (snapshot.hasData) {
              // Extracting data from snapshot object
              final data = snapshot.data as String;
              googleMapsUrl = data;
              return Center(
                child: ElevatedButton(
                  child: Text('Google Maps'),
                  onPressed: _launchURL,
                ),
              );
            }
          }

          // Displaying LoadingSpinner to indicate waiting state
          return Center(
            child: CircularProgressIndicator(),
          );
        },

        // Future that needs to be resolved
        // inorder to display something on the Canvas
        future: getFastestRoute(startingPoint, destination1, destination2, destination3, destination4, end),
      )
    );
  }
}

_launchURL() async {
  String url = googleMapsUrl;
  print(url);
  if (await canLaunch(url)) {
    await launch(url);
  } else {
    throw 'Could not launch $url';
  }
}

Widget _buildstartingPointForm() {
  return TextFormField(
    decoration: InputDecoration(
      labelText: 'Start Location',
    ),
    validator: (var value){
      if(value == null || value.isEmpty){
        return 'Required';
      }
    },
    onSaved: (var value){
      startingPoint = value.toString();
    },
  );
}

Widget _buildDestination1Form() {
  return TextFormField(
    decoration: InputDecoration(
      labelText: 'Destination 1',
    ),
    validator: (var value){
      if(value == null || value.isEmpty){
        return 'Required';
      }
    },
    onSaved: (var value){
      destination1 = value.toString();
    },
  );
}

Widget _buildDestination2Form() {
  return TextFormField(
    decoration: InputDecoration(
      labelText: 'Destination 2',
    ),
    validator: (var value){
      if(value == null || value.isEmpty){
        return 'Required';
      }
    },
    onSaved: (var value){
      destination2 = value.toString();
    },
  );
}

Widget _buildDestination3Form() {
  return TextFormField(
    decoration: InputDecoration(
      labelText: 'Destination 3',
    ),
    validator: (var value){
      if(value == null || value.isEmpty){
        return 'Required';
      }
    },
    onSaved: (var value){
      destination3 = value.toString();
    },
  );
}

Widget _buildDestination4Form() {
  return TextFormField(
    decoration: InputDecoration(
      labelText: 'Destination 4',
    ),
    validator: (var value){
      if(value == null || value.isEmpty){
        return 'Required';
      }
    },
    onSaved: (var value){
      destination4 = value.toString();
    },
  );
}

Widget _buildEndForm() {
  return TextFormField(
    decoration: InputDecoration(
      labelText: 'End Location',
    ),
    validator: (var value){
      if(value == null || value.isEmpty){
        return 'Required';
      }
    },
    onSaved: (var value){
      end = value.toString();
    },
  );
}

Future<String> getFastestRoute(start, des1, des2, des3, des4, endP) async {
  String startingPointID = await createPlaceId(start);
  String destination1ID = await createPlaceId(des1);
  String destination2ID = await createPlaceId(des2);
  String destination3ID = await createPlaceId(des3);
  String destination4ID = await createPlaceId(des4);
  String endID = await createPlaceId(endP);

  print(createDistanceMatrixUrl(startingPointID, [destination1ID, destination2ID, destination3ID, destination4ID]));

  Map<String, dynamic> startResponse = jsonDecode((await get(Uri.parse(
    createDistanceMatrixUrl(startingPointID, [destination1ID, destination2ID, destination3ID, destination4ID])
  ))).body);
  Map<String, dynamic> des1Response = jsonDecode((await get(Uri.parse(
      createDistanceMatrixUrl(destination1ID, [destination2ID, destination3ID, destination4ID, endID])
  ))).body);
  Map<String, dynamic> des2Response = jsonDecode((await get(Uri.parse(
      createDistanceMatrixUrl(destination2ID, [destination1ID, destination3ID, destination4ID, endID])
  ))).body);
  Map<String, dynamic> des3Response = jsonDecode((await get(Uri.parse(
      createDistanceMatrixUrl(destination3ID, [destination1ID, destination2ID, destination4ID, endID])
  ))).body);
  Map<String, dynamic> des4Response = jsonDecode((await get(Uri.parse(
      createDistanceMatrixUrl(destination4ID, [destination1ID, destination2ID, destination3ID, endID])
  ))).body);

  var distanceMatrix = [
    [
      startResponse['rows'][0]['elements'][0]['duration']['value'],
      startResponse['rows'][0]['elements'][1]['duration']['value'],
      startResponse['rows'][0]['elements'][2]['duration']['value'],
      startResponse['rows'][0]['elements'][3]['duration']['value'],
    ],
    [
      -1,
      des1Response['rows'][0]['elements'][0]['duration']['value'],
      des1Response['rows'][0]['elements'][1]['duration']['value'],
      des1Response['rows'][0]['elements'][2]['duration']['value'],
      des1Response['rows'][0]['elements'][3]['duration']['value'],
    ],
    [
      des2Response['rows'][0]['elements'][0]['duration']['value'],
      -1,
      des2Response['rows'][0]['elements'][1]['duration']['value'],
      des2Response['rows'][0]['elements'][2]['duration']['value'],
      des2Response['rows'][0]['elements'][3]['duration']['value'],
    ],
    [
      des3Response['rows'][0]['elements'][0]['duration']['value'],
      des3Response['rows'][0]['elements'][1]['duration']['value'],
      -1,
      des3Response['rows'][0]['elements'][2]['duration']['value'],
      des3Response['rows'][0]['elements'][3]['duration']['value'],
    ],
    [
      des4Response['rows'][0]['elements'][0]['duration']['value'],
      des4Response['rows'][0]['elements'][1]['duration']['value'],
      des4Response['rows'][0]['elements'][2]['duration']['value'],
      -1,
      des4Response['rows'][0]['elements'][3]['duration']['value'],
    ],
  ];

  var bestRoute = await getBestRoute(distanceMatrix);

  String finalUrl =
      'https://www.google.com/maps/dir/?api=1&origin=placeholder&origin_place_id=' +
      startingPointID +
      '&destination=placeholder&destination_place_id=' +
      endID +
      '&travelmode=driving&waypoints=placeholder%7Cplaceholder%7Cplaceholder%7Cplaceholder&waypoint_place_ids=' +
      getPlaceIdFromIndex(bestRoute[0], destination1ID, destination2ID, destination3ID, destination4ID) +
      '%7C' + getPlaceIdFromIndex(bestRoute[1], destination1ID, destination2ID, destination3ID, destination4ID) +
      '%7C' + getPlaceIdFromIndex(bestRoute[2], destination1ID, destination2ID, destination3ID, destination4ID) +
      '%7C' + getPlaceIdFromIndex(bestRoute[3], destination1ID, destination2ID, destination3ID, destination4ID);
  print(finalUrl);
  return finalUrl;
}

getBestRoute(distanceMatrix){
  num bestDuration = 999999999999999;
  var bestRoute = [-1, -1, -1, -1];
  var currentRoute = [-1, -1, -1, -1];
  for(int a = 0; a < 4; a++){
    currentRoute[0] = a;
    for(int b = 0; b < 4; b++){
      currentRoute[1] = b;
      for(int c = 0; c < 4; c++){
        currentRoute[2] = c;
        for(int d = 0; d < 4; d++){
          currentRoute[3] = d;
          if(currentRoute.length == currentRoute.toSet().length) {
            num currentDuration = distanceMatrix[0][currentRoute[0]];
            currentDuration +=
            distanceMatrix[currentRoute[0] + 1][currentRoute[1]];
            currentDuration +=
            distanceMatrix[currentRoute[1] + 1][currentRoute[2]];
            currentDuration +=
            distanceMatrix[currentRoute[2] + 1][currentRoute[3]];
            currentDuration += distanceMatrix[currentRoute[3] + 1][4];
            if (currentDuration < bestDuration) {
              bestDuration = currentDuration;
              bestRoute[0] = currentRoute[0];
              bestRoute[1] = currentRoute[1];
              bestRoute[2] = currentRoute[2];
              bestRoute[3] = currentRoute[3];
            }
          }
        }
      }
    }
  }
  print('Final best: $bestRoute');
  return bestRoute;
}

String getPlaceIdFromIndex(index, des1, des2, des3, des4){
  String id = 'nothing';
  switch(index){
    case 0: {
      id = des1;
    }
    break;
    case 1: {
      id = des2;
    }
    break;
    case 2: {
      id = des3;
    }
    break;
    case 3: {
      id = des4;
    }
    break;
  }
  return id;
}

String createDistanceMatrixUrl(start, destinations){
  String url = 'https://maps.googleapis.com/maps/api/distancematrix/json?units=imperial&origins=place_id:' + start + '&destinations=';
  for(int i=0; i < destinations.length; i++){
    url = url + 'place_id:' + destinations[i];
    if(i != destinations.length){
      url = url + '|';
    }
  }
  url = url + '&key=AIzaSyD0UEYCISPeEE-zEIh_WuOF9u4Wdmro_GI';
  return url;
}

Future<String> createPlaceId(address) async {
  String formattedAddress = '';
  for(int i = 0; i < address.length; i++){
    if(address[i] == ' ') {
      formattedAddress = formattedAddress + '+';
    }
    else{
      formattedAddress = formattedAddress + address[i];
    }
  }
  String url = 'https://maps.googleapis.com/maps/api/geocode/json?address=' + formattedAddress + '&key=AIzaSyD0UEYCISPeEE-zEIh_WuOF9u4Wdmro_GI';
  final uri = Uri.parse(url);
  Map<String, dynamic> data = jsonDecode((await get(uri)).body);
  String placeId = data['results'][0]['place_id'];
  return placeId;
}

class DistanceMatrix {
  var startResponse;
  var des1Response;
  var des2Response;
  var des3Response;
  var des4Response;

}

final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
