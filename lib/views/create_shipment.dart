import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:unpack/models/receiver.dart';
import 'package:unpack/web_services/receiver_service.dart';
import 'package:unpack/web_services/shipment_service.dart';
import 'package:unpack/web_services/warehouse_service.dart';

import '../models/item.dart';
import '../models/shipment.dart';
import '../models/warehouse.dart';

class CreateShipment extends StatefulWidget {
  const CreateShipment({super.key});

  @override
  State<CreateShipment> createState() => _CreateShipmentState();
}

class _CreateShipmentState extends State<CreateShipment> {
  getWarehousesAndReceivers() async {
    _warehouses = await WarehouseService().fetchWarehouses();
    _receivers = await ReceiverService().fetchReceivers();
    warehouseNames = _warehouses.map((warehouse) => warehouse.name).toList();
    receiversNames = _receivers.map((receivers) => receivers.name).toList();
    setState(() {});
  }

  List<Warehouse> _warehouses = [];
  Warehouse? _selectedWarehouse;
  List<String> warehouseNames = [];

  List<Receiver> _receivers = [];
  Receiver? _selectedReceiver;
  List<String> receiversNames = [];

  List<String> _itemTypes = [
    'Electronics',
    'Clothing',
    'Furniture',
    'Pharmaceuticals',
    'Food',
    'Other'
  ];
  String? _selectedType;

  bool isSensitive = false;

  TextEditingController _originController = TextEditingController();
  TextEditingController _destinationController = TextEditingController();
  TextEditingController _itemNameController = TextEditingController();
  TextEditingController _itemQuantityController = TextEditingController();

  List<Item> addedItems = [];

  @override
  void initState() {
    super.initState();

    getWarehousesAndReceivers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        child: ListView(children: [
          ListTile(
            leading: Icon(Icons.logout),
            title: Text('Logout'),
            onTap: () async {
              Navigator.pop(context); // Close the drawer
              SharedPreferences prefs = await SharedPreferences.getInstance();
              await prefs.clear();
              Navigator.of(context).popUntil(
                  (route) => route.isFirst); // Call the logout function
            },
          ),
        ]),
      ),
      appBar: AppBar(
        automaticallyImplyLeading: false,
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
                    width:
                        10), // Add some spacing between the logo and the text
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
      body: Container(
        margin: EdgeInsets.symmetric(horizontal: 20),
        child: SingleChildScrollView(
          child: Form(
            child: Column(
              children: [
                Container(
                    margin: EdgeInsets.only(left: 30),
                    width: MediaQuery.of(context).size.width,
                    child: Text("Create Shipment",
                        textAlign: TextAlign.left,
                        style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontSize: 30,
                            fontWeight: FontWeight.bold))),
                Container(
                  margin: EdgeInsets.only(bottom: 15),
                  child: TextFormField(
                    controller: _originController,
                    decoration: InputDecoration(hintText: "origin"),
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(bottom: 15),
                  child: TextFormField(
                    controller: _destinationController,
                    decoration: InputDecoration(hintText: "destination"),
                  ),
                ),
                Container(
                  width: MediaQuery.of(context).size.width,
                  child: DropdownButton<Warehouse>(
                    hint: Text("select warehouse"),
                    isExpanded: true,
                    value: _selectedWarehouse,
                    onChanged: (Warehouse? newValue) {
                      setState(() {
                        _selectedWarehouse = newValue;
                      });
                    },
                    items: _warehouses.map<DropdownMenuItem<Warehouse>>(
                        (Warehouse warehouse) {
                      return DropdownMenuItem<Warehouse>(
                        value: warehouse,
                        child: Text(warehouse.name),
                      );
                    }).toList(),
                  ),
                ),
                Container(
                  width: MediaQuery.of(context).size.width,
                  child: DropdownButton<Receiver>(
                    hint: Text("select receiver"),
                    isExpanded: true,
                    value: _selectedReceiver,
                    onChanged: (Receiver? newValue) {
                      setState(() {
                        _selectedReceiver = newValue;
                      });
                    },
                    items: _receivers
                        .map<DropdownMenuItem<Receiver>>((Receiver receiver) {
                      return DropdownMenuItem<Receiver>(
                        value: receiver,
                        child: Text(receiver.name),
                      );
                    }).toList(),
                  ),
                ),
                Container(
                    margin: EdgeInsets.only(left: 30, top: 30),
                    width: MediaQuery.of(context).size.width,
                    child: Text("Add items",
                        textAlign: TextAlign.left,
                        style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontSize: 20,
                            fontWeight: FontWeight.bold))),
                Container(
                  margin: EdgeInsets.only(bottom: 15),
                  child: TextFormField(
                    controller: _itemNameController,
                    decoration: InputDecoration(hintText: "item name"),
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(bottom: 15),
                  child: TextFormField(
                    controller: _itemQuantityController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(hintText: "quantity"),
                  ),
                ),
                Container(
                  width: MediaQuery.of(context).size.width,
                  child: DropdownButton(
                    hint: Text("select type"),
                    isExpanded: true,
                    value: _selectedType,
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedType = newValue;
                      });
                    },
                    items: _itemTypes
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                ),
                Row(
                  children: [
                    Checkbox(
                      activeColor: Theme.of(context).primaryColor,
                      value: isSensitive,
                      onChanged: (bool? value) {
                        setState(() {
                          isSensitive = value!;
                        });
                      },
                    ),
                    Expanded(
                      // Use Expanded to make the Text widget take up remaining space
                      child: Text(
                        'is sensitive',
                        textAlign: TextAlign.left, // Align text to the left
                      ),
                    ),
                  ],
                ),
                Container(
                  margin: EdgeInsets.only(right: 10, bottom: 10),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton(
                      onPressed: () {
                        addedItems.add(Item(
                            name: _itemNameController.text.trim(),
                            type: _selectedType!,
                            quantity:
                                int.parse(_itemQuantityController.text.trim()),
                            isSensitive: isSensitive));
                        _itemQuantityController.text = "";
                        _itemNameController.text = "";
                        isSensitive = false;
                        _selectedType = null;
                        setState(() {});
                      },
                      child: Text("Add item"),
                    ),
                  ),
                ),
                Column(
                  children: List.generate(addedItems.length, (index) {
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
                                Text(
                                  addedItems[index].name,
                                  style: TextStyle(fontSize: 20),
                                ),
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
                                Text(addedItems[index].quantity.toString(),
                                    style: TextStyle(fontSize: 20)),
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
                                Text(addedItems[index].type,
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
                                    addedItems[index].isSensitive
                                        ? "yes"
                                        : "no",
                                    style: TextStyle(fontSize: 20)),
                              ],
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.only(right: 10, bottom: 10),
                            child: Align(
                              alignment: Alignment.centerRight,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        Theme.of(context).secondaryHeaderColor),
                                onPressed: () {
                                  addedItems.removeAt(index);
                                  setState(() {});
                                },
                                child: Text("Remove item"),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ),
                Container(
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width,
                    child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).primaryColor),
                        onPressed: () async {
                          SharedPreferences prefs =
                              await SharedPreferences.getInstance();
                          String customerId = prefs.getString('id') ?? '';
                          ShipmentService service =
                              Provider.of<ShipmentService>(context,
                                  listen: false);
                          try {
                            String fee = await service.createShipment(Shipment(
                                customerId: customerId,
                                receiverId: _selectedReceiver!.id,
                                origin: _originController.text.trim(),
                                destination: _destinationController.text.trim(),
                                shipmentDate: DateTime.now(),
                                expectedDeliveryDate: null,
                                status: "pending",
                                warehouseId: _selectedWarehouse!.id,
                                items: addedItems));
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                content:
                                    Text("Shipment Created Successfully")));
                            Navigator.of(context).pop(fee);
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text("Error: ${e}")));
                          }
                        },
                        child: Text("Submit Shipment")),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
