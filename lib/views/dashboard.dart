import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:unpack/models/statistics.dart';
import 'package:unpack/views/create_shipment.dart';
import 'package:unpack/views/shipment_details.dart';
import 'package:unpack/web_services/shipment_service.dart';

import '../web_services/statistics_service.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

String type = "";
Statistics statistics = Statistics(
    totalShipments: 0, statusCounts: {"test": 0}, averageDeliveryTime: 0);

class _DashboardState extends State<Dashboard> {
  getType() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      type = prefs.getString('type') ?? '';
    });
  }

  void _showPopup(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Total Fees'),
          content: Text(message + "\$"),
          actions: <Widget>[
            TextButton(
              child: Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    getType();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      endDrawer: Drawer(
        child: ListView(children: [
          ListTile(
            leading: Icon(Icons.logout),
            title: Text('Logout'),
            onTap: () async {
              Navigator.pop(context); // Close the drawer
              SharedPreferences prefs = await SharedPreferences.getInstance();
              await prefs.clear();
              Navigator.of(context).popUntil(
                  (route) => route.isFirst); // Navigate to the first screen
            },
          ),
        ]),
      ),
      appBar: AppBar(
        automaticallyImplyLeading: false, // Disable the back button
        actions: [
          Builder(
            builder: (context) => IconButton(
              icon: Icon(Icons.menu), // Hamburger menu icon
              onPressed: () =>
                  Scaffold.of(context).openEndDrawer(), // Opens the endDrawer
            ),
          ),
        ],
        flexibleSpace: Container(
          margin: EdgeInsets.only(),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(
                  margin: EdgeInsets.only(left: 15),
                  child: SvgPicture.asset(
                    'assets/logo.svg',
                    width: 24,
                    height: 24,
                    color: Colors.white, // Color the icon in white
                  ),
                ),
                SizedBox(
                    width: 10), // Adds spacing between the logo and the text
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: ' UN',
                          style: TextStyle(
                              color: Theme.of(context).secondaryHeaderColor,
                              fontSize: 25,
                              fontWeight: FontWeight.bold),
                        ),
                        TextSpan(
                          text: 'PACK',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 25,
                              fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: Consumer<ShipmentService>(builder: (context, service, child) {
        return FutureBuilder(
            future: service.getShipments(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError || service.shipments.isEmpty) {
                return Center(child: Text("No shipments available."));
              }

              Container(
                  margin: EdgeInsets.only(left: 20, top: 20),
                  width: MediaQuery.of(context).size.width,
                  child: Text("All Shipments",
                      textAlign: TextAlign.left,
                      style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontSize: 30,
                          fontWeight: FontWeight.bold)));
              return SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                        margin: EdgeInsets.only(left: 10),
                        width: MediaQuery.of(context).size.width,
                        child: Text("All Shipments",
                            textAlign: TextAlign.left,
                            style: TextStyle(
                                color: Theme.of(context).primaryColor,
                                fontSize: 30,
                                fontWeight: FontWeight.bold))),
                    Visibility(
                      visible: type.toLowerCase() == "customer",
                      child: Container(
                        margin: EdgeInsets.only(right: 10, bottom: 10),
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: ElevatedButton(
                            onPressed: () async {
                              final result = await Navigator.of(context).push(
                                  MaterialPageRoute(
                                      builder: (context) => CreateShipment()));
                              if (result != null) {
                                _showPopup(context, result);
                              }
                            },
                            child: Text("Create"),
                          ),
                        ),
                      ),
                    ),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal, // Scroll horizontally
                      child: DataTable(
                        headingRowColor:
                            MaterialStateProperty.resolveWith<Color>(
                                (Set<MaterialState> states) {
                          // Change the background color of the heading row
                          return Theme.of(context).primaryColor.withOpacity(
                              0.8); // Semi-transparent primary color
                        }),
                        headingTextStyle: TextStyle(
                          // Heading text style
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                        dataRowColor: MaterialStateProperty.resolveWith<Color>(
                            (Set<MaterialState> states) {
                          // Change the background color for rows
                          return Colors
                              .white; // Or any other appropriate color for data rows
                        }),
                        dataTextStyle: TextStyle(
                          // Data text style
                          color: Colors.black87,
                          fontSize: 14,
                        ),
                        columns: <DataColumn>[
                          DataColumn(
                            label: Text('Origin'),
                          ),
                          DataColumn(
                            label: Text('Destination'),
                          ),
                          DataColumn(
                            label: Text('Order Date'),
                          ),
                          DataColumn(
                            label: Text('Expected Delivery Date'),
                          ),
                          DataColumn(
                            label: Text('Status'),
                          ),
                        ],
                        rows: service.shipments.map((shipment) {
                          return DataRow(
                            cells: <DataCell>[
                              DataCell(
                                GestureDetector(
                                  onTap: () {
                                    Navigator.of(context).push(
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                ShipmentDetails(
                                                    shipment: shipment)));
                                  },
                                  child: Text(shipment.origin),
                                ),
                              ),
                              DataCell(
                                GestureDetector(
                                  onTap: () {
                                    Navigator.of(context).push(
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                ShipmentDetails(
                                                    shipment: shipment)));
                                  },
                                  child: Text(shipment.destination),
                                ),
                              ),
                              DataCell(
                                GestureDetector(
                                  onTap: () {
                                    Navigator.of(context).push(
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                ShipmentDetails(
                                                    shipment: shipment)));
                                  },
                                  child: Text(shipment.shipmentDate
                                      .toString()
                                      .split(" ")[0]),
                                ),
                              ),
                              DataCell(
                                GestureDetector(
                                  onTap: () {
                                    Navigator.of(context).push(
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                ShipmentDetails(
                                                    shipment: shipment)));
                                  },
                                  child: Text(
                                    shipment.expectedDeliveryDate != null
                                        ? shipment.expectedDeliveryDate
                                            .toString()
                                            .split(" ")[0]
                                        : "Not Set",
                                  ),
                                ),
                              ),
                              DataCell(
                                GestureDetector(
                                  onTap: () {
                                    Navigator.of(context).push(
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                ShipmentDetails(
                                                    shipment: shipment)));
                                  },
                                  child: Text(shipment.status),
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                    SizedBox(
                      height: 30,
                    ),
                    Visibility(
                      visible: type.toLowerCase() == "customer",
                      child: Consumer<StatisticsService>(
                          builder: (context, service, child) {
                        return FutureBuilder(
                            future: service.getStatistics(),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return Center(
                                    child: CircularProgressIndicator());
                              } else if (snapshot.hasError ||
                                  service.statistics == null) {
                                return Padding(
                                  padding: EdgeInsets.all(16),
                                  child: Text("No statistics available"),
                                );
                              }
                              return Column(
                                children: [
                                  Material(
                                    elevation: 10.0,
                                    borderRadius: BorderRadius.circular(12.0),
                                    shadowColor: Colors.black.withOpacity(1),
                                    child: Container(
                                      width: MediaQuery.of(context).size.width -
                                          40,
                                      height: 100,
                                      decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(12.0),
                                      ),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceAround,
                                        children: [
                                          Text(
                                            "Total Shipments",
                                            style: TextStyle(
                                                color: Theme.of(context)
                                                    .primaryColor,
                                                fontSize: 25,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          Text(
                                            service.statistics.totalShipments
                                                .toString(),
                                            style: TextStyle(
                                              color: Theme.of(context)
                                                  .primaryColor,
                                              fontSize: 20,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 30,
                                  ),
                                  Material(
                                    elevation: 10.0,
                                    borderRadius: BorderRadius.circular(12.0),
                                    shadowColor: Colors.black.withOpacity(1),
                                    child: Container(
                                      width: MediaQuery.of(context).size.width -
                                          40,
                                      decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(12.0),
                                      ),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceAround,
                                        children: List<Widget>.generate(
                                            service.statistics.statusCounts
                                                .length, (index) {
                                          return Container(
                                            constraints: BoxConstraints(
                                              minHeight:
                                                  100.0, // Minimum height
                                            ),
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceAround,
                                              children: [
                                                Text(
                                                  service.statistics
                                                      .statusCounts.entries
                                                      .toList()[index]
                                                      .key
                                                      .toString(),
                                                  style: TextStyle(
                                                      color: Theme.of(context)
                                                          .primaryColor,
                                                      fontSize: 25,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                                Text(
                                                  service.statistics
                                                      .statusCounts.entries
                                                      .toList()[index]
                                                      .value
                                                      .toString(),
                                                  style: TextStyle(
                                                    color: Theme.of(context)
                                                        .primaryColor,
                                                    fontSize: 20,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          );
                                        }),
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 30,
                                  ),
                                  Material(
                                    elevation: 10.0,
                                    borderRadius: BorderRadius.circular(12.0),
                                    shadowColor: Colors.black.withOpacity(1),
                                    child: Container(
                                      width: MediaQuery.of(context).size.width -
                                          40,
                                      height: 100,
                                      decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(12.0),
                                      ),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceAround,
                                        children: [
                                          Text(
                                            "Average Delivery Time",
                                            style: TextStyle(
                                                color: Theme.of(context)
                                                    .primaryColor,
                                                fontSize: 25,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          Text(
                                            service
                                                .statistics.averageDeliveryTime
                                                .toString(),
                                            style: TextStyle(
                                              color: Theme.of(context)
                                                  .primaryColor,
                                              fontSize: 20,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 30,
                                  ),
                                ],
                              );
                            });
                      }),
                    )
                  ],
                ),
              );
            });
      }),
    );
  }
}
