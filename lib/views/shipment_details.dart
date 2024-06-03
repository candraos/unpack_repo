import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:unpack/web_services/shipment_service.dart';

import '../models/shipment.dart';

class ShipmentDetails extends StatefulWidget {
  ShipmentDetails({super.key, required this.shipment});

  Shipment shipment;
  @override
  State<ShipmentDetails> createState() => _ShipmentDetailsState();
}

class _ShipmentDetailsState extends State<ShipmentDetails> {
  String type = "";
  TextEditingController deliveryDateController = TextEditingController();
  List<String> statuses = ["Packaging", "Onway", "Failed"];
  String? selectedStatus;

  getType() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    setState(() {
      type = prefs.getString('type') ?? '';
      // selectedStatus = widget.shipment.status;
      if (type.toLowerCase() == "employee") {
        deliveryDateController.text =
            widget.shipment.expectedDeliveryDate.toString().split(" ")[0] ?? "";
      }
    });
  }

  Future<void> _showDatePicker() async {
    DateTime? picked = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime.now(),
        lastDate: DateTime(2030));
    if (picked != null) {
      deliveryDateController.text = picked.toString().split(" ")[0];
    }
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
      body: SingleChildScrollView(
        child: Container(
          margin: EdgeInsets.only(left: 20),
          child: Column(
            children: [
              Container(
                  margin: EdgeInsets.only(left: 20, bottom: 30, top: 30),
                  width: MediaQuery.of(context).size.width,
                  child: Text("Order Details",
                      textAlign: TextAlign.left,
                      style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontSize: 30,
                          fontWeight: FontWeight.bold))),
              Container(
                margin: EdgeInsets.only(bottom: 15),
                child: Row(
                  children: [
                    Text(
                      "Order Id: ",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                    ),
                    Flexible(
                        child: Text(widget.shipment.id!,
                            softWrap: true,
                            overflow: TextOverflow.visible,
                            style: TextStyle(fontSize: 20))),
                  ],
                ),
              ),
              Container(
                margin: EdgeInsets.only(bottom: 15),
                child: Row(
                  children: [
                    Text(
                      "Destination: ",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                    ),
                    Flexible(
                        child: Text(widget.shipment.destination,
                            softWrap: true,
                            overflow: TextOverflow.visible,
                            style: TextStyle(fontSize: 20))),
                  ],
                ),
              ),
              Container(
                margin: EdgeInsets.only(bottom: 15),
                child: Row(
                  children: [
                    Text(
                      "Shipment Date: ",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                    ),
                    Flexible(
                        child: Text(
                            widget.shipment.shipmentDate
                                .toString()
                                .split(" ")[0],
                            softWrap: true,
                            overflow: TextOverflow.visible,
                            style: TextStyle(fontSize: 20))),
                  ],
                ),
              ),
              Visibility(
                visible: type.toLowerCase() == "employee",
                child: Container(
                  margin: EdgeInsets.only(bottom: 15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                          margin: EdgeInsets.only(bottom: 5),
                          child: Text(
                            "Expected Delivery Date",
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 20),
                          )),
                      TextFormField(
                        controller: deliveryDateController,
                        readOnly: true,
                        decoration: InputDecoration(
                            hintText: "enter expected delivery date",
                            filled: true,
                            prefixIcon: Icon(Icons.calendar_today)),
                        onTap: () {
                          _showDatePicker();
                        },
                      ),
                    ],
                  ),
                ),
              ),
              Visibility(
                visible: type.toLowerCase() == "employee",
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                        margin: EdgeInsets.only(bottom: 5),
                        child: Text(
                          "Status",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 20),
                        )),
                    DropdownButton(
                      hint: Text("select"),
                      isExpanded: true,
                      value: selectedStatus,
                      onChanged: (String? newValue) {
                        setState(() {
                          selectedStatus = newValue;
                        });
                      },
                      items: statuses
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              Visibility(
                visible: type.toLowerCase() != "employee",
                child: Container(
                  margin: EdgeInsets.only(bottom: 15),
                  child: Row(
                    children: [
                      Text(
                        "Expected Delivery Date: ",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 20),
                      ),
                      Flexible(
                          child: Text(
                              widget.shipment.expectedDeliveryDate
                                  .toString()
                                  .split(" ")[0],
                              softWrap: true,
                              overflow: TextOverflow.visible,
                              style: TextStyle(fontSize: 20))),
                    ],
                  ),
                ),
              ),
              Visibility(
                visible: type.toLowerCase() != "employee",
                child: Container(
                  margin: EdgeInsets.only(bottom: 15),
                  child: Row(
                    children: [
                      Text(
                        "Status: ",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 20),
                      ),
                      Text(widget.shipment.status,
                          style: TextStyle(fontSize: 20)),
                    ],
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.only(bottom: 15),
                child: Row(
                  children: [
                    Text(
                      "Origin: ",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                    ),
                    Flexible(
                        child: Text(widget.shipment.origin,
                            softWrap: true,
                            overflow: TextOverflow.visible,
                            style: TextStyle(fontSize: 20))),
                  ],
                ),
              ),
              Container(
                margin: EdgeInsets.only(bottom: 15),
                child: Row(
                  children: [
                    Text(
                      "Receiver Id: ",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                    ),
                    Flexible(
                        child: Text(widget.shipment.receiverId,
                            softWrap: true,
                            overflow: TextOverflow.visible,
                            style: TextStyle(fontSize: 20))),
                  ],
                ),
              ),
              Container(
                margin: EdgeInsets.only(bottom: 15),
                child: Row(
                  children: [
                    Text(
                      "Warehouse Id: ",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                    ),
                    Flexible(
                        child: Text(widget.shipment.warehouseId,
                            softWrap: true,
                            overflow: TextOverflow.visible,
                            style: TextStyle(fontSize: 20))),
                  ],
                ),
              ),
              Container(
                color: Colors.grey.shade300,
                padding: EdgeInsets.only(top: 20, left: 20),
                child: Column(
                  children:
                      List.generate(widget.shipment.items.length, (index) {
                    return Container(
                      margin: EdgeInsets.only(bottom: 20),
                      child: Column(
                        children: [
                          Container(
                            margin: EdgeInsets.only(bottom: 15),
                            child: Row(
                              children: [
                                Text(
                                  "Item Name: ",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20),
                                ),
                                Flexible(
                                    child: Text(
                                  widget.shipment.items[index].name,
                                  softWrap: true,
                                  overflow: TextOverflow.visible,
                                  style: TextStyle(fontSize: 20),
                                )),
                              ],
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.only(bottom: 15),
                            child: Row(
                              children: [
                                Text(
                                  "Item Quantity: ",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20),
                                ),
                                Flexible(
                                    child: Text(
                                        widget.shipment.items[index].quantity
                                            .toString(),
                                        softWrap: true,
                                        overflow: TextOverflow.visible,
                                        style: TextStyle(fontSize: 20))),
                              ],
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.only(bottom: 15),
                            child: Row(
                              children: [
                                Text(
                                  "Item Type: ",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20),
                                ),
                                Text(widget.shipment.items[index].type,
                                    style: TextStyle(fontSize: 20)),
                              ],
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.only(bottom: 15),
                            child: Row(
                              children: [
                                Text(
                                  "Is Sensitive: ",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20),
                                ),
                                Text(
                                    widget.shipment.items[index].isSensitive
                                        ? "yes"
                                        : "no",
                                    style: TextStyle(fontSize: 20)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ),
              ),
              SizedBox(height: 20),
              Visibility(
                visible: type.toLowerCase() == "customer",
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 20),
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width,
                    child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor:
                                Theme.of(context).secondaryHeaderColor),
                        onPressed: () async {
                          ShipmentService service =
                              Provider.of<ShipmentService>(context,
                                  listen: false);
                          try {
                            await service.deleteShipment(widget.shipment.id!);
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text("Shipment Deleted Successfully!"),
                            ));
                            Navigator.of(context).pop();
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text(e.toString()),
                            ));
                          }
                        },
                        child: Text("Delete Shipment")),
                  ),
                ),
              ),
              Visibility(
                visible: type.toLowerCase() == "receiver",
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 20),
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width,
                    child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).primaryColor),
                        onPressed: () async {
                          ShipmentService service =
                              Provider.of<ShipmentService>(context,
                                  listen: false);
                          try {
                            await service.updateStatus(
                                widget.shipment.id!, "Received");
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text("Shipment Updated Successfully!"),
                            ));
                            Navigator.of(context).pop();
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text(e.toString()),
                            ));
                          }
                        },
                        child: Text("Set Received")),
                  ),
                ),
              ),
              Visibility(
                visible: type.toLowerCase() == "employee",
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 20),
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width,
                    child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).primaryColor),
                        onPressed: () async {
                          ShipmentService service =
                              Provider.of<ShipmentService>(context,
                                  listen: false);
                          try {
                            await service.updateStatus(
                                widget.shipment.id!, selectedStatus!);
                            await service.updateExpectedDeliveryDate(
                                widget.shipment.id!,
                                DateTime.parse(
                                    deliveryDateController.text.trim()));
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text("Shipment Updated Successfully!"),
                            ));
                            Navigator.of(context).pop();
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text(e.toString()),
                            ));
                          }
                        },
                        child: Text("Save Changes")),
                  ),
                ),
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
