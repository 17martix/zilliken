import 'dart:async';
import 'dart:developer';

import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:zilliken/Components/ZAppBar.dart';
import 'package:zilliken/Components/ZCircularProgress.dart';
import 'package:zilliken/Components/ZElevatedButton.dart';
import 'package:zilliken/Helpers/SizeConfig.dart';
import 'package:zilliken/Helpers/Styling.dart';
import 'package:zilliken/Helpers/Utils.dart';
import 'package:zilliken/Models/Call.dart';
import 'package:zilliken/Models/Fields.dart';
import 'package:zilliken/Models/Order.dart';
import 'package:zilliken/Models/OrderItem.dart';
import 'package:zilliken/Models/UserProfile.dart';
import 'package:zilliken/Services/Authentication.dart';
import 'package:zilliken/Services/Database.dart';
import 'package:zilliken/Services/Messaging.dart';
import 'package:zilliken/i18n.dart';
import 'package:intl/intl.dart';
import 'package:timelines/timelines.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../Components/ZText.dart';
import 'DashboardPage.dart';
import 'DisabledPage.dart';
import 'PrintPage.dart';

class SingleOrderPage extends StatefulWidget {
  final Authentication auth;
  final Database db;
  final String userId;
  final String userRole;
  final String orderId;
  final Order clientOrder;
  final Messaging messaging;
  final DateFormat formatter = DateFormat('dd/MM/yy HH:mm');

  SingleOrderPage({
    required this.auth,
    required this.db,
    required this.userId,
    required this.userRole,
    required this.orderId,
    required this.clientOrder,
    required this.messaging,
  });

  @override
  _SingleOrderPageState createState() => _SingleOrderPageState();
}

class _SingleOrderPageState extends State<SingleOrderPage> {
  var oneOrderDetails;
  var orderItems;
  bool isDataBeingDeleted = false;
  int _status = Fields.pending;

  int _orderStatus = 1;
  int enabled = 1;

  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  Order? order;
  GeoPoint? _currentPoint;

  double CAMERA_ZOOM = 14;
  //double CAMERA_TILT = 80;
  //double CAMERA_BEARING = 0;
  LatLng SOURCE_LOCATION = LatLng(-3.3834389, 29.3616122);
  //MenuItem menu = MenuItem();
  UserProfile? userProfile;

  /*double CAMERA_ZOOM = 16;
  double CAMERA_TILT = 80;
  double CAMERA_BEARING = 30;
  LatLng SOURCE_LOCATION = LatLng(-3.3834389, 29.3616122);*/

  /*double CAMERA_ZOOM = 16;
  double CAMERA_TILT = 0.0;
  double CAMERA_BEARING = 0.0;*/
  //LatLng SOURCE_LOCATION = LatLng(-3.3834389, 29.3616122);

  Completer<GoogleMapController> _controller = Completer();
  Set<Marker> _markers = Set<Marker>();

// for my drawn routes on the map
  Set<Polyline> _polylines = Set<Polyline>();
  List<LatLng> polylineCoordinates = [];
  PolylinePoints polylinePoints = PolylinePoints();

// for my custom marker pins
  BitmapDescriptor? sourceIcon;
  BitmapDescriptor? destinationIcon;

// the user's initial location and current location
// as it moves
  Position currentLocation = Position.fromMap({
    "latitude": -3.3834389,
    "longitude": 29.3616122,
  }); // a reference to the destination location
  Position destinationLocation = Position.fromMap({
    "latitude": -3.3834389,
    "longitude": 29.3616122,
  }); // wrapper around the location API
  Geolocator location = new Geolocator();
  CameraPosition? initialCameraPosition;

  bool goingBack = false;
  List<OrderItem> items = [];
  var now = new DateTime.now();

  @override
  void initState() {
    super.initState();
    _orderStatus = widget.clientOrder.status;
    oneOrderDetails =
        FirebaseFirestore.instance.collection(Fields.order).doc(widget.orderId);

    orderItems = FirebaseFirestore.instance
        .collection(Fields.order)
        .doc(widget.orderId)
        .collection(Fields.items);

    widget.db.getUserProfile(widget.userId).then((value) {
      setState(() {
        userProfile = value;
      });
    });

    FirebaseFirestore.instance
        .collection(Fields.order)
        .doc(widget.orderId)
        .snapshots()
        .listen((DocumentSnapshot<Map<String, dynamic>> documentSnapshot) {
      if (mounted) {
        setState(() {
          goingBack =
              documentSnapshot.data()![Fields.status] < _status ? true : false;

          _status = documentSnapshot.data()![Fields.status];

          if (documentSnapshot.data()![Fields.orderLocation] == 1 &&
              _status != 4 &&
              widget.userId != order!.deliveringOrderId) {
            if (goingBack) {
              backFunction();
            }
            _currentPoint = documentSnapshot.data()![Fields.currentPoint];
            currentLocation = Position.fromMap({
              "latitude": _currentPoint!.latitude,
              "longitude": _currentPoint!.longitude,
            });

            updatePinOnMap(currentLocation);
          }
          /*order = Order();
        order.buildObject(documentSnapshot);*/
        });
      }
    });

    FirebaseFirestore.instance
        .collection(Fields.configuration)
        .doc(Fields.settings)
        .snapshots()
        .listen((DocumentSnapshot<Map<String, dynamic>> documentSnapshot) {
      if (mounted) {
        setState(() {
          enabled = documentSnapshot.data()![Fields.enabled];
        });
      }
    });

    widget.db.getOrder(widget.orderId).then((value) {
      if (mounted) {
        setState(() {
          order = value;
        });
      }
      if (value!.orderLocation == 1) {
        if (mounted) {
          setState(() {
            _currentPoint = value.currentPoint;
            if (_status != 4) {
              if (widget.userId == order!.deliveringOrderId) {
                initLocation();
              } else {
                initLocationFromServer();
              }
            }
          });
        }
      }
    });

    widget.db.getOrderItems(widget.orderId).then((value) {
      if (mounted) {
        setState(() {
          items = value;
        });
      }
    });
  }

  void initLocation() {
    // subscribe to changes in the user's location
    // by "listening" to the location's onLocationChanged event

    Geolocator.getPositionStream(
            desiredAccuracy: LocationAccuracy.high,
            distanceFilter: 1,
            intervalDuration: Duration(minutes: 1))
        .listen((Position position) {
      if (mounted) {
        setState(() {
          if (_status != 4) {
            currentLocation = position;
            updatePinOnMap(currentLocation);
          }
        });
      }

      GeoPoint currentPoint =
          GeoPoint(currentLocation.latitude, currentLocation.longitude);
      widget.db.updateLocation(widget.orderId, currentPoint);
    });

    setSourceAndDestinationIcons();
    setInitialLocation();
    //updatePinOnMap(currentLocation);

    /*location.changeSettings(
        accuracy: LocationAccuracy.high, interval: 60000, distanceFilter: 1);*/

    /*location.onLocationChanged.listen((LocationData cLoc) {
      // cLoc contains the lat and long of the
      // current user's position in real time,
      // so we're holding on to it
      currentLocation = cLoc;
      updatePinOnMap();
      GeoPoint currentPoint =
          GeoPoint(currentLocation.latitude, currentLocation.longitude);
      //widget.db.updateLocation(widget.orderId, currentPoint);
    }); // set custom marker pins
    setSourceAndDestinationIcons(); // set the initial location
    setInitialLocation();*/
  }

  void initLocationFromServer() {
    currentLocation = Position.fromMap({
      "latitude": _currentPoint!.latitude,
      "longitude": _currentPoint!.longitude,
    });

    updatePinOnMap(currentLocation);
    setSourceAndDestinationIcons(); // set the initial location
    destinationLocation = Position.fromMap({
      "latitude": order!.geoPoint!.latitude,
      "longitude": order!.geoPoint!.longitude,
    });
  }

  void setInitialLocation() async {
    // set the initial location by pulling the user's
    // current location from the location's getLocation()
    /*currentLocation = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);*/

    Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high)
        .then((value) {
      if (mounted) {
        setState(() {
          currentLocation = value;
          updatePinOnMap(currentLocation);
        });
      }
    });

    // hard-coded destination for this example
    destinationLocation = Position.fromMap({
      "latitude": order!.geoPoint!.latitude,
      "longitude": order!.geoPoint!.longitude,
    });
  }

  void setSourceAndDestinationIcons() async {
    sourceIcon = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(devicePixelRatio: 2.5), 'assets/driving_pin.png');

    destinationIcon = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(devicePixelRatio: 2.5),
        'assets/destination_map_marker.png');
  }

  void updatePinOnMap(Position position) async {
    // create a new CameraPosition instance
    // every time the location changes, so the camera
    // follows the pin as it moves with an animation
    CameraPosition cPosition = CameraPosition(
      zoom: CAMERA_ZOOM,
      // tilt: CAMERA_TILT,
      //bearing: CAMERA_BEARING,
      target: LatLng(position.latitude, position.longitude),
    );

    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(cPosition));
    // do this inside the setState() so Flutter gets notified
    // that a widget update is due
    //setState(() {
    // updated position
    var pinPosition = LatLng(position.latitude, position.longitude);

    // the trick is to remove the marker (by id)
    // and add it again at the updated location
    _markers.removeWhere((m) => m.markerId.value == '‘sourcePin’');
    _markers.add(Marker(
        markerId: MarkerId('sourcePin'),
        position: pinPosition, // updated position
        icon: sourceIcon!));
    //});

    setPolylines(position);
  }

  void backFunction() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => DashboardPage(
          db: widget.db,
          auth: widget.auth,
          userId: widget.userId,
          userRole: widget.userRole,
          messaging: widget.messaging,
          index: 1,
        ),
      ),
      (Route<dynamic> route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);

    return WillPopScope(
      onWillPop: () async {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => DashboardPage(
              db: widget.db,
              auth: widget.auth,
              userId: widget.userId,
              userRole: widget.userRole,
              messaging: widget.messaging,
              index: 1,
            ),
          ),
          (Route<dynamic> route) => false,
        );
        return false;
      },
      child: enabled == 0
          ? DisabledPage(
              auth: widget.auth,
              db: widget.db,
              userId: widget.userId,
              userRole: widget.userRole,
            )
          : Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                    image: AssetImage('assets/Zilliken.jpg'),
                    fit: BoxFit.cover),
              ),
              child: Scaffold(
                backgroundColor: Colors.transparent,
                key: _scaffoldKey,
                appBar: buildAppBar(
                  context,
                  widget.auth,
                  true,
                  null,
                  backFunction,
                  (widget.userRole != Fields.client &&
                          order != null &&
                          userProfile != null)
                      ? printing
                      : null,
                  null,
                ),
                floatingActionButton: (widget.userRole != Fields.client ||
                        widget.clientOrder.orderLocation == 1)
                    ? null
                    : FloatingActionButton.extended(
                        onPressed: () async {
                          EasyLoading.show(status: I18n.of(context).loading);
                          bool isOnline = await hasConnection();
                          if (!isOnline) {
                            EasyLoading.dismiss();

                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content:
                                  ZText(content: I18n.of(context).noInternet),
                            ));
                          } else {
                            try {
                              Call call = Call(
                                hasCalled: true,
                                order: widget.clientOrder,
                              );
                              await widget.db.addCall(call);
                              EasyLoading.dismiss();

                              ScaffoldMessenger.of(context)
                                  .showSnackBar(SnackBar(
                                content: ZText(
                                    content: I18n.of(context).messageSent),
                              ));
                            } on Exception catch (e) {
                              EasyLoading.dismiss();

                              ScaffoldMessenger.of(context)
                                  .showSnackBar(SnackBar(
                                content: ZText(content: e.toString()),
                              ));
                            }
                          }
                        },
                        label: ZText(
                            content: I18n.of(context).callThewaiter,
                            color: Color(Styling.primaryBackgroundColor),
                            fontSize: SizeConfig.diagonal * 1.5),
                        icon: Icon(
                          FontAwesomeIcons.handPointUp,
                          size: SizeConfig.diagonal * 2.5,
                          color: Color(Styling.primaryBackgroundColor),
                        ),
                        backgroundColor: Color(Styling.accentColor),
                      ),
                body: body(),
              ),
            ),
    );
  }

  void printing() {
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PrintPage(
            auth: widget.auth,
            orderType: widget.clientOrder.orderLocation == 0
                ? I18n.of(context).restaurantOrder
                : I18n.of(context).livrdomicile,
            tableAddressLabel: widget.clientOrder.orderLocation == 0
                ? "${I18n.of(context).tableNumber}"
                : "${I18n.of(context).addr}", //restaurant order or delivery
            tableAddress: "${widget.clientOrder.tableAdress}",
            phoneNumber: widget.clientOrder.orderLocation == 1
                ? "${widget.clientOrder.phoneNumber}"
                : null,
            agentName: userProfile!.name,
            order: order!,
          ),
        ));
  }

  Widget body() {
    if (isDataBeingDeleted) {
      return Center(
        child: ZCircularProgress(true),
      );
    } else {
      return ListView(
        children: [
          /*if (widget.userRole != Fields.client &&
              order != null &&
              order.orderLocation == 1 &&
              _status > 2)
            showMap(),
          if (widget.userRole == Fields.client &&
              order != null &&
              order.orderLocation == 1)
            showMap(),*/
          if (order != null &&
              order!.orderLocation == 1 &&
              _status != 4 &&
              widget.userRole != Fields.client &&
              order!.deliveringOrderId != null &&
              goingBack == false)
            map(),
          if (order != null &&
              order!.orderLocation == 1 &&
              _status != 4 &&
              widget.userRole != Fields.client &&
              order!.deliveringOrderId == null)
            showDeliverButton(),
          if (order != null &&
              order!.orderLocation == 1 &&
              _status != 4 &&
              widget.userRole == Fields.client &&
              goingBack == false)
            map(),
          if (widget.userRole == Fields.client) progressionTimeLine(),
          if (widget.userRole != Fields.client && order != null) statusUpdate(),
          orderItemStream(),
          informationStream(),
          Padding(
            padding: EdgeInsets.only(
                left: SizeConfig.diagonal * 0.5,
                right: SizeConfig.diagonal * 0.5),
            child: Card(
              color: Colors.white.withOpacity(0.7),
              shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(SizeConfig.diagonal * 1.5)),
              elevation: 15,
              child: Column(
                children: [
                  billStream(),
                  billStream2(),
                  if ((_status <= 2 && widget.userRole == Fields.client) ||
                      widget.userRole == Fields.admin ||
                      widget.userRole == Fields.developer)
                    cancelOrder(),
                ],
              ),
            ),
          )
        ],
      );
    }
  }

  void assignOrder() async {
    EasyLoading.show(status: I18n.of(context).loading);

    bool isOnline = await hasConnection();
    if (!isOnline) {
      EasyLoading.dismiss();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: ZText(content: I18n.of(context).noInternet),
        ),
      );
    } else {
      try {
        await widget.db.assignDelivery(widget.orderId, widget.userId);
        if (mounted) {
          setState(() {
            order!.deliveringOrderId = widget.userId;
            initLocation();
          });
        }

        EasyLoading.dismiss();
      } on Exception catch (e) {
        //print('Error: $e');
        EasyLoading.dismiss();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: ZText(content: e.toString()),
          ),
        );
      }
    }
  }

  Widget showDeliverButton() {
    return Container(
      child: ZElevatedButton(
        leftPadding: SizeConfig.diagonal * 1,
        rightPadding: SizeConfig.diagonal * 1,
        onpressed: assignOrder,
        topPadding: 0.0,
        bottomPadding: 0.0,
        child: ZText(
            content: I18n.of(context).deliverOrder,
            color: Color(Styling.primaryBackgroundColor)),
      ),
    );
  }

  Widget map() {
    Position p;
    if (widget.userId == order!.deliveringOrderId)
      p = currentLocation;
    else {
      p = Position.fromMap({
        "latitude": _currentPoint!.latitude,
        "longitude": _currentPoint!.longitude,
      });
    }

    initialCameraPosition = CameraPosition(
        zoom: CAMERA_ZOOM,
        //tilt: CAMERA_TILT,
        //bearing: CAMERA_BEARING,
        target: SOURCE_LOCATION);

    if (currentLocation != null) {
      initialCameraPosition = CameraPosition(
        target: LatLng(p.latitude, p.longitude),
        zoom: CAMERA_ZOOM,
        //tilt: CAMERA_TILT,
        //bearing: CAMERA_BEARING,
      );
    }

    return Container(
      width: double.infinity,
      height: SizeConfig.diagonal * 50,
      child: Stack(
        children: [
          GestureDetector(
            onVerticalDragStart: (start) {},
            child: GoogleMap(
              myLocationEnabled: false,
              myLocationButtonEnabled: false,
              zoomGesturesEnabled: true,
              zoomControlsEnabled: true,
              compassEnabled: false,
              tiltGesturesEnabled: false,
              markers: _markers,
              polylines: _polylines,
              mapType: MapType.normal,
              initialCameraPosition: initialCameraPosition!,
              gestureRecognizers: Set()
                ..add(Factory<OneSequenceGestureRecognizer>(
                    () => new EagerGestureRecognizer()))
                ..add(
                    Factory<PanGestureRecognizer>(() => PanGestureRecognizer()))
                ..add(Factory<ScaleGestureRecognizer>(
                    () => ScaleGestureRecognizer()))
                ..add(
                    Factory<TapGestureRecognizer>(() => TapGestureRecognizer()))
                ..add(Factory<VerticalDragGestureRecognizer>(
                    () => VerticalDragGestureRecognizer())),
              onMapCreated: (GoogleMapController controller) {
                _controller.complete(
                    controller); // my map has completed being created;
                // i'm ready to show the pins on the map
                showPinsOnMap(p);
              },
              /*onCameraMove: (position) {
                showPinsOnMap(p);
              },*/
            ),
          ),
        ],
      ),
    );
  }

  void showPinsOnMap(Position p) {
    // get a LatLng for the source location
    // from the LocationData currentLocation object
    var pinPosition = LatLng(
        p.latitude, p.longitude); // get a LatLng out of the LocationData object
    var destPosition = LatLng(destinationLocation.latitude,
        destinationLocation.longitude); // add the initial source location pin
    _markers.add(Marker(
        markerId: MarkerId('sourcePin'),
        position: pinPosition,
        icon: sourceIcon!)); // destination pin
    _markers.add(Marker(
        markerId: MarkerId('destPin'),
        position: destPosition,
        icon:
            destinationIcon!)); // set the route lines on the map from source to destination
    // for more info follow this tutorial
    setPolylines(p);
  }

  void setPolylines(Position p) async {
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      getMapsKey()!,
      PointLatLng(p.latitude, p.longitude),
      PointLatLng(destinationLocation.latitude, destinationLocation.longitude),
    );
    if (result != null) {
      if (polylineCoordinates != null && polylineCoordinates.length > 0) {
        polylineCoordinates.clear();
      }
      result.points.forEach((PointLatLng point) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      });

      if (mounted) {
        setState(() {
          if (_polylines != null && _polylines.length > 0) {
            _polylines.clear();
          }

          _polylines.add(Polyline(
              width: 5, // set the width of the polylines
              polylineId: PolylineId('poly'),
              color: Color(Styling.accentColor),
              points: polylineCoordinates));
        });
      }
    }
  }

  Widget progressionTimeLine() {
    oneOrderDetails.snapshots(includeMetadataChanges: true);
    return Container(
      decoration: BoxDecoration(color: Color(Styling.primaryBackgroundColor)),
      child: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          stream: oneOrderDetails.snapshots(),
          builder: (BuildContext context,
              AsyncSnapshot<DocumentSnapshot<Map<String, dynamic>>> snapshot) {
            if (snapshot.data == null)
              return Center(
                child: ZText(content: ""),
              );

            Order order = Order.buildObjectAsync(snapshot);

            return Container(
              width: double.infinity,
              height: SizeConfig.diagonal * 25,
              child: progressStatus(order),
            );
          }),
    );
  }

  Widget progressStatus(Order order) {
    return Padding(
      padding: EdgeInsets.only(
        left: SizeConfig.diagonal * 0.5,
        right: SizeConfig.diagonal * 0.5,
      ),
      child: Card(
        color: Colors.white.withOpacity(0.7),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(SizeConfig.diagonal * 1.5)),
        elevation: 16,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: EdgeInsets.only(
                top: SizeConfig.diagonal * 1.5,
                bottom: SizeConfig.diagonal * 1.5,
              ),
              child: ZText(
                content: I18n.of(context).orderStatus,
                fontWeight: FontWeight.bold,
                color: Color(
                  Styling.textColor,
                ),
                fontSize: SizeConfig.diagonal * 1.5,
                textAlign: TextAlign.center,
              ),
            ),
            Padding(
              padding: EdgeInsets.only(
                  left: SizeConfig.diagonal * 2,
                  right: SizeConfig.diagonal * 2,
                  bottom: SizeConfig.diagonal * 1.5),
              child: Container(
                color: Color(Styling.primaryColor),
                height: 1,
                width: double.infinity,
              ),
            ),
            Expanded(
              child: Timeline(
                scrollDirection: Axis.horizontal,
                children: [
                  TimelineTile(
                    oppositeContents: Padding(
                      padding: EdgeInsets.all(SizeConfig.diagonal * 1),
                      child: Icon(
                        Icons.access_alarm,
                        size: SizeConfig.diagonal * 4,
                        color: order.status == 1
                            ? Color(Styling.accentColor)
                            : Color(Styling.primaryColor),
                      ),
                    ),
                    contents: Container(
                      padding: EdgeInsets.all(SizeConfig.diagonal * 1),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ZText(
                            content: I18n.of(context).pending,
                            fontSize: SizeConfig.diagonal * 1.5,
                            color: order.status == 1
                                ? Color(Styling.accentColor)
                                : Color(Styling.primaryColor),
                          ),
                          SizedBox(height: SizeConfig.diagonal * 1),
                          ZText(
                            content: order.orderDate == null
                                ? ""
                                : '${widget.formatter.format(order.orderDate!.toDate())}',
                            fontSize: SizeConfig.diagonal * 1.5,
                            color: order.status == 1
                                ? Color(Styling.accentColor)
                                : Color(Styling.primaryColor),
                          ),
                        ],
                      ),
                    ),
                    direction: Axis.horizontal,
                    node: TimelineNode(
                      direction: Axis.horizontal,
                      indicator: DotIndicator(
                        color: order.status == 1
                            ? Color(Styling.accentColor)
                            : Color(Styling.primaryColor),
                        size: SizeConfig.diagonal * 3,
                        child: order.status == 1
                            ? Padding(
                                padding:
                                    EdgeInsets.all(SizeConfig.diagonal * 1),
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white),
                                ),
                              )
                            : Icon(
                                Icons.check,
                                color: Color(Styling.accentColor),
                                size: SizeConfig.diagonal * 2,
                              ),
                      ),
                      startConnector: null,
                      endConnector: SizedBox(
                        width: SizeConfig.diagonal * 4,
                        child: SolidLineConnector(
                          color: order.status < 2
                              ? Color(Styling.textColor).withOpacity(0.2)
                              : Color(Styling.primaryColor),
                        ),
                      ),
                    ),
                  ),
                  TimelineTile(
                    oppositeContents: Padding(
                      padding: EdgeInsets.all(SizeConfig.diagonal * 1),
                      child: Icon(
                        Icons.thumb_up,
                        size: SizeConfig.diagonal * 4,
                        color: order.status == 2
                            ? Color(Styling.accentColor)
                            : order.status < 2
                                ? Color(Styling.textColor).withOpacity(0.2)
                                : Color(Styling.primaryColor),
                      ),
                    ),
                    contents: Container(
                      padding: EdgeInsets.all(SizeConfig.diagonal * 1),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ZText(
                            content: I18n.of(context).confirmed,
                            fontSize: SizeConfig.diagonal * 1.5,
                            color: order.status == 2
                                ? Color(Styling.accentColor)
                                : order.status < 2
                                    ? Color(Styling.textColor).withOpacity(0.2)
                                    : Color(Styling.primaryColor),
                          ),
                          SizedBox(
                            height: SizeConfig.diagonal * 1,
                          ),
                          ZText(
                            content: order.confirmedDate == null
                                ? ""
                                : '${widget.formatter.format(order.confirmedDate!.toDate())}',
                            fontSize: SizeConfig.diagonal * 1.5,
                            color: order.status == 2
                                ? Color(Styling.accentColor)
                                : order.status < 2
                                    ? Color(Styling.textColor).withOpacity(0.2)
                                    : Color(Styling.primaryColor),
                          ),
                        ],
                      ),
                    ),
                    direction: Axis.horizontal,
                    node: TimelineNode(
                      direction: Axis.horizontal,
                      indicator: DotIndicator(
                        color: order.status == 2
                            ? Color(Styling.accentColor)
                            : order.status < 2
                                ? Color(Styling.textColor).withOpacity(0.2)
                                : Color(Styling.primaryColor),
                        size: SizeConfig.diagonal * 3,
                        child: order.status == 2
                            ? Padding(
                                padding:
                                    EdgeInsets.all(SizeConfig.diagonal * 1),
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white),
                                ),
                              )
                            : order.status < 2
                                ? null
                                : Icon(
                                    Icons.check,
                                    color: Color(Styling.accentColor),
                                    size: SizeConfig.diagonal * 2,
                                  ),
                      ),
                      startConnector: SizedBox(
                        width: SizeConfig.diagonal * 4,
                        child: SolidLineConnector(
                          color: order.status < 2
                              ? Color(Styling.textColor).withOpacity(0.2)
                              : Color(Styling.primaryColor),
                        ),
                      ),
                      endConnector: SizedBox(
                        width: SizeConfig.diagonal * 4,
                        child: SolidLineConnector(
                          color: order.status < 3
                              ? Color(Styling.textColor).withOpacity(0.2)
                              : Color(Styling.primaryColor),
                        ),
                      ),
                    ),
                  ),
                  TimelineTile(
                    oppositeContents: Padding(
                      padding: EdgeInsets.all(SizeConfig.diagonal * 1),
                      child: Icon(
                        Icons.kitchen,
                        size: SizeConfig.diagonal * 4,
                        color: order.status == 3
                            ? Color(Styling.accentColor)
                            : order.status < 3
                                ? Color(Styling.textColor).withOpacity(0.2)
                                : Color(Styling.primaryColor),
                      ),
                    ),
                    contents: Container(
                      padding: EdgeInsets.all(SizeConfig.diagonal * 1),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ZText(
                            content: I18n.of(context).preparing,
                            fontSize: SizeConfig.diagonal * 1.5,
                            color: order.status == 3
                                ? Color(Styling.accentColor)
                                : order.status < 3
                                    ? Color(Styling.textColor).withOpacity(0.2)
                                    : Color(Styling.primaryColor),
                          ),
                          SizedBox(height: SizeConfig.diagonal * 1),
                          ZText(
                            content: order.preparationDate == null
                                ? ""
                                : '${widget.formatter.format(order.preparationDate!.toDate())}',
                            fontSize: SizeConfig.diagonal * 1.5,
                            color: order.status == 3
                                ? Color(Styling.accentColor)
                                : order.status < 3
                                    ? Color(Styling.textColor).withOpacity(0.2)
                                    : Color(Styling.primaryColor),
                          ),
                        ],
                      ),
                    ),
                    direction: Axis.horizontal,
                    node: TimelineNode(
                      direction: Axis.horizontal,
                      indicator: DotIndicator(
                        color: order.status == 3
                            ? Color(Styling.accentColor)
                            : order.status < 3
                                ? Color(Styling.textColor).withOpacity(0.2)
                                : Color(Styling.primaryColor),
                        size: SizeConfig.diagonal * 3,
                        child: order.status == 3
                            ? Padding(
                                padding:
                                    EdgeInsets.all(SizeConfig.diagonal * 1),
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white),
                                ),
                              )
                            : order.status < 3
                                ? null
                                : Icon(
                                    Icons.check,
                                    color: Color(Styling.accentColor),
                                    size: SizeConfig.diagonal * 2,
                                  ),
                      ),
                      startConnector: SizedBox(
                        width: SizeConfig.diagonal * 4,
                        child: SolidLineConnector(
                          color: order.status < 3
                              ? Color(Styling.textColor).withOpacity(0.2)
                              : Color(Styling.primaryColor),
                        ),
                      ),
                      endConnector: SizedBox(
                        width: SizeConfig.diagonal * 4,
                        child: SolidLineConnector(
                          color: order.status < 4
                              ? Color(Styling.textColor).withOpacity(0.2)
                              : Color(Styling.primaryColor),
                        ),
                      ),
                    ),
                  ),
                  TimelineTile(
                    oppositeContents: Padding(
                      padding: EdgeInsets.all(SizeConfig.diagonal * 1),
                      child: Icon(
                        Icons.restaurant_menu,
                        size: SizeConfig.diagonal * 4,
                        color: order.status == 4
                            ? Color(Styling.accentColor)
                            : order.status < 4
                                ? Color(Styling.textColor).withOpacity(0.2)
                                : Color(Styling.primaryColor),
                      ),
                    ),
                    contents: Container(
                      padding: EdgeInsets.all(SizeConfig.diagonal * 1),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ZText(
                            content: I18n.of(context).served,
                            fontSize: SizeConfig.diagonal * 1.5,
                            color: order.status == 4
                                ? Color(Styling.accentColor)
                                : order.status < 4
                                    ? Color(Styling.textColor).withOpacity(0.2)
                                    : Color(Styling.primaryColor),
                          ),
                          SizedBox(height: SizeConfig.diagonal * 1),
                          ZText(
                            content: order.servedDate == null
                                ? ""
                                : '${widget.formatter.format(order.servedDate!.toDate())}',
                            fontSize: SizeConfig.diagonal * 1.5,
                            color: order.status == 4
                                ? Color(Styling.accentColor)
                                : order.status < 4
                                    ? Color(Styling.textColor).withOpacity(0.2)
                                    : Color(Styling.primaryColor),
                          ),
                        ],
                      ),
                    ),
                    direction: Axis.horizontal,
                    node: TimelineNode(
                      direction: Axis.horizontal,
                      indicator: DotIndicator(
                        color: order.status == 4
                            ? Color(Styling.accentColor)
                            : order.status < 4
                                ? Color(Styling.textColor).withOpacity(0.2)
                                : Color(Styling.primaryColor),
                        size: SizeConfig.diagonal * 3,
                        child: order.status < 4
                            ? null
                            : Icon(
                                Icons.check,
                                color: Color(Styling.primaryBackgroundColor),
                                size: SizeConfig.diagonal * 2,
                              ),
                      ),
                      startConnector: SizedBox(
                        width: SizeConfig.diagonal * 4,
                        child: SolidLineConnector(
                          color: order.status < 4
                              ? Color(Styling.textColor).withOpacity(0.2)
                              : Color(Styling.primaryColor),
                        ),
                      ),
                      endConnector: null,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget statusUpdate() {
    return Padding(
      padding: EdgeInsets.only(
          left: SizeConfig.diagonal * 0.5, right: SizeConfig.diagonal * 0.5),
      child: Card(
        color: Colors.white.withOpacity(0.7),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(SizeConfig.diagonal * 1.5)),
        elevation: 16,
        child: new Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              margin: EdgeInsets.all(SizeConfig.diagonal * 1),
              child: ZText(
                content: I18n.of(context).updateStatus,
                fontWeight: FontWeight.bold,
                fontSize: SizeConfig.diagonal * 1.5,
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: SizeConfig.diagonal * 1,
                  vertical: SizeConfig.diagonal * 0.5),
              child: Divider(height: 2.0, color: Colors.black),
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: new Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  new Radio(
                    activeColor: Color(Styling.accentColor),
                    value: 1,
                    groupValue: _orderStatus,
                    onChanged: handleStatusChange,
                  ),
                  ZText(
                      content: I18n.of(context).pendingOrder,
                      fontSize: SizeConfig.diagonal * 1.5),
                  new Radio(
                    value: 2,
                    groupValue: _orderStatus,
                    onChanged: handleStatusChange,
                    activeColor: Color(Styling.accentColor),
                  ),
                  ZText(
                    content: I18n.of(context).confirmedOrder,
                    fontSize: SizeConfig.diagonal * 1.5,
                  ),
                  new Radio(
                    value: 3,
                    activeColor: Color(Styling.accentColor),
                    groupValue: _orderStatus,
                    onChanged: handleStatusChange,
                  ),
                  ZText(
                    content: I18n.of(context).orderPreparation,
                    fontSize: SizeConfig.diagonal * 1.5,
                  ),
                  new Radio(
                    value: 4,
                    activeColor: Color(Styling.accentColor),
                    groupValue: _orderStatus,
                    onChanged: handleStatusChange,
                  ),
                  ZText(
                    content: I18n.of(context).orderServed,
                    fontSize: SizeConfig.diagonal * 1.5,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void handleStatusChange(int? value) {
    if (mounted) {
      setState(() {
        goingBack = value! < _orderStatus ? true : false;
        _orderStatus = value;
      });
    }

    if (goingBack) {
      backFunction();
    }
    widget.db.updateStatus(widget.orderId, _orderStatus, value!, order!,
        widget.clientOrder.grandTotal);
  }

  Widget orderItemStream() {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: orderItems.snapshots(),
      builder: (BuildContext context,
          AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
        if (snapshot.data == null)
          return Center(
            child: ZText(content: ""),
          );

        return Padding(
          padding: EdgeInsets.only(
              left: SizeConfig.diagonal * 0.5,
              right: SizeConfig.diagonal * 0.5),
          child: Card(
            color: Colors.white.withOpacity(0.7),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(SizeConfig.diagonal * 1.5)),
            elevation: 16,
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.only(
                      left: SizeConfig.diagonal * 1.5,
                      right: SizeConfig.diagonal * 1.5,
                      top: SizeConfig.diagonal * 1.5,
                      bottom: SizeConfig.diagonal * 1.5),
                  child: Center(
                    child: ZText(
                        content: I18n.of(context).order,
                        fontSize: SizeConfig.diagonal * 1.5,
                        color: Color(Styling.textColor),
                        fontWeight: FontWeight.bold),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(
                      left: SizeConfig.diagonal * 2,
                      right: SizeConfig.diagonal * 2,
                      bottom: SizeConfig.diagonal * 1.5),
                  child: Container(
                    color: Color(Styling.primaryColor),
                    height: 1,
                    width: double.infinity,
                  ),
                ),
                ListTile(
                  onTap: () {},
                  title: ZText(
                    content: I18n.of(context).items,
                    color: Color(Styling.textColor),
                    fontWeight: FontWeight.bold,
                    fontSize: SizeConfig.diagonal * 1.5,
                  ),
                  trailing: ZText(
                    content: I18n.of(context).number,
                    color: Color(Styling.textColor),
                    fontWeight: FontWeight.bold,
                    fontSize: SizeConfig.diagonal * 1.5,
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: snapshot.data!.docs
                      .map((DocumentSnapshot<Map<String, dynamic>> document) {
                    OrderItem orderItem = OrderItem.buildObject(document);
                    return orderElement(orderItem);
                  }).toList(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget orderElement(OrderItem orderItem) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.only(
            left: SizeConfig.diagonal * 1.5,
            right: SizeConfig.diagonal * 1.5,
            bottom: SizeConfig.diagonal * 1.5,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                flex: 4,
                child: ZText(
                  content: '${orderItem.menuItem.name}',
                  overflow: TextOverflow.ellipsis,
                  fontSize: SizeConfig.diagonal * 1.5,
                  color: Color(Styling.textColor),
                ),
              ),
              SizedBox(width: SizeConfig.diagonal * 1),
              Expanded(
                flex: 1,
                child: ZText(
                  content: '${orderItem.count}',
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.end,
                  color: Color(Styling.textColor),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget billStream() {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: orderItems.snapshots(),
      builder: (BuildContext context,
          AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
        if (snapshot.data == null)
          return Center(
            child: ZText(content: ""),
          );

        return Column(
          children: [
            Padding(
              padding: EdgeInsets.only(
                bottom: SizeConfig.diagonal * 1.5,
                top: SizeConfig.diagonal * 1.5,
              ),
              child: Center(
                child: ZText(
                  content: I18n.of(context).billDetails,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(
                  left: SizeConfig.diagonal * 2,
                  right: SizeConfig.diagonal * 2,
                  bottom: SizeConfig.diagonal * 1.5),
              child: Container(
                color: Color(Styling.primaryColor),
                height: 1,
                width: double.infinity,
              ),
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: snapshot.data!.docs
                  .map((DocumentSnapshot<Map<String, dynamic>> document) {
                OrderItem orderItem = OrderItem.buildObject(document);
                if (widget.userRole == Fields.chefBoissons) {
                  if (orderItem.menuItem.isDrink == 1) {
                    return billElement(orderItem);
                  } else {
                    return Container();
                  }
                } else if (widget.userRole == Fields.chefCuisine) {
                  if (orderItem.menuItem.isDrink == 0) {
                    return billElement(orderItem);
                  } else {
                    return Container();
                  }
                } else {
                  return billElement(orderItem);
                }
              }).toList(),
            ),
          ],
        );
      },
    );
  }

  Widget billElement(OrderItem orderItem) {
    return Column(
      children: [
        Padding(
            padding: EdgeInsets.only(
              left: SizeConfig.diagonal * 1.5,
              right: SizeConfig.diagonal * 1.5,
              bottom: SizeConfig.diagonal * 1.5,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: ZText(
                    content: '${orderItem.menuItem.name} x ${orderItem.count}',
                    overflow: TextOverflow.ellipsis,
                    color: Color(Styling.textColor),
                  ),
                ),
                SizedBox(width: SizeConfig.diagonal * 1),
                ZText(
                  content:
                      '${formatNumber(orderItem.menuItem.price)} * ${orderItem.count} = ${formatNumber(orderItem.menuItem.price * orderItem.count)} FBU',
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.end,
                  color: Color(Styling.textColor),
                ),
              ],
            )),
      ],
    );
  }

  Widget billStream2() {
    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: oneOrderDetails.snapshots(),
      builder: (BuildContext context,
          AsyncSnapshot<DocumentSnapshot<Map<String, dynamic>>> snapshot) {
        if (snapshot.data == null)
          return Center(
            child: ZText(content: ""),
          );

        Order order = Order.buildObjectAsync(snapshot);
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            billElement2(order),
          ],
        );
      },
    );
  }

  Widget billElement2(Order order) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.only(
            left: SizeConfig.diagonal * 1.5,
            right: SizeConfig.diagonal * 1.5,
            bottom: SizeConfig.diagonal * 1.5,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: ZText(
                  content: '${I18n.of(context).taxCharge}',
                  overflow: TextOverflow.ellipsis,
                  color: Color(Styling.textColor),
                ),
              ),
              SizedBox(width: SizeConfig.diagonal * 1),
              ZText(
                content: appliedTaxFromTotal(
                    context, order.total, order.taxPercentage),
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.end,
                color: Color(Styling.textColor),
              ),
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.only(
            left: SizeConfig.diagonal * 1.5,
            right: SizeConfig.diagonal * 1.5,
            bottom: SizeConfig.diagonal * 1.5,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: ZText(
                  content: '${I18n.of(context).grandTotal}',
                  overflow: TextOverflow.ellipsis,
                  color: Color(Styling.textColor),
                ),
              ),
              SizedBox(width: SizeConfig.diagonal * 1),
              ZText(
                content: '${formatNumber(order.grandTotal)} FBU',
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.end,
                color: Color(Styling.textColor),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget informationStream() {
    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: oneOrderDetails.snapshots(),
      builder: (BuildContext context,
          AsyncSnapshot<DocumentSnapshot<Map<String, dynamic>>> snapshot) {
        if (snapshot.data == null)
          return Center(
            child: ZText(content: ""),
          );

        Order order = Order.buildObjectAsync(snapshot);
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            orderInformations(order),
          ],
        );
      },
    );
  }

  Widget orderInformations(Order order) {
    return Padding(
      padding: EdgeInsets.only(
        left: SizeConfig.diagonal * 0.5,
        right: SizeConfig.diagonal * 0.5,
      ),
      child: Card(
        color: Colors.white.withOpacity(0.7),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(SizeConfig.diagonal * 1.5),
        ),
        elevation: 16,
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.only(
                top: SizeConfig.diagonal * 1.5,
                bottom: SizeConfig.diagonal * 1.5,
              ),
              child: ZText(
                content: I18n.of(context).orderInformation,
                fontWeight: FontWeight.bold,
                color: Color(
                  Styling.textColor,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            Padding(
              padding: EdgeInsets.only(
                  left: SizeConfig.diagonal * 2,
                  right: SizeConfig.diagonal * 2,
                  bottom: SizeConfig.diagonal * 1.5),
              child: Container(
                color: Color(Styling.primaryColor),
                height: 1,
                width: double.infinity,
              ),
            ),
            Padding(
              padding: EdgeInsets.only(
                left: SizeConfig.diagonal * 1.5,
                right: SizeConfig.diagonal * 1.5,
                bottom: SizeConfig.diagonal * 1.5,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    flex: 1,
                    child: ZText(
                      content: '${I18n.of(context).orderDate}',
                      overflow: TextOverflow.ellipsis,
                      color: Color(
                        Styling.textColor,
                      ),
                    ),
                  ),
                  SizedBox(width: SizeConfig.diagonal * 1),
                  Expanded(
                    flex: 1,
                    child: ZText(
                      content: order.orderDate == null
                          ? ''
                          : '${widget.formatter.format(order.orderDate!.toDate())}',
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.end,
                      color: Color(
                        Styling.textColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.only(
                left: SizeConfig.diagonal * 1.5,
                right: SizeConfig.diagonal * 1.5,
                bottom: SizeConfig.diagonal * 1.5,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    flex: 1,
                    child: ZText(
                      content: '${tableAddressStatus(order)}',
                      overflow: TextOverflow.ellipsis,
                      color: Color(
                        Styling.textColor,
                      ),
                    ),
                  ),
                  SizedBox(width: SizeConfig.diagonal * 1),
                  Expanded(
                    flex: 1,
                    child: ZText(
                      content: order.tableAdress,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.end,
                      color: Color(
                        Styling.textColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (order.instructions != null && order.instructions != '')
              Padding(
                padding: EdgeInsets.only(
                  left: SizeConfig.diagonal * 1.5,
                  right: SizeConfig.diagonal * 1.5,
                  bottom: SizeConfig.diagonal * 1.5,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      flex: 1,
                      child: ZText(
                        content: I18n.of(context).instr,
                        overflow: TextOverflow.ellipsis,
                        color: Color(
                          Styling.textColor,
                        ),
                      ),
                    ),
                    SizedBox(width: SizeConfig.diagonal * 1),
                    Expanded(
                      flex: 1,
                      child: ZText(
                        content: order.instructions!,
                        overflow: TextOverflow.visible,
                        textAlign: TextAlign.end,
                        color: Color(
                          Styling.textColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  String tableAddressStatus(Order order) {
    String value;
    if (order.orderLocation == 1) {
      value = I18n.of(context).addr;
    } else {
      value = I18n.of(context).tableNumber;
    }
    return value;
  }

  Widget cancelOrder() {
    return ZElevatedButton(
      leftPadding: SizeConfig.diagonal * 1,
      rightPadding: SizeConfig.diagonal * 1,
      onpressed: () async {
        if (mounted) {
          setState(() {
            isDataBeingDeleted = true;
          });
        }
        await widget.db.cancelOrder(widget.orderId);
        backFunction();
      },
      child: ZText(
        content: I18n.of(context).cancelOrder,
        color: Color(Styling.primaryBackgroundColor),
      ),
    );
  }
}
