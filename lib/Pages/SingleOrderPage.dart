import 'dart:async';
import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:zilliken/Components/ZAppBar.dart';
import 'package:zilliken/Components/ZCircularProgress.dart';
import 'package:zilliken/Components/ZRaisedButton.dart';
import 'package:zilliken/Helpers/SizeConfig.dart';
import 'package:zilliken/Helpers/Styling.dart';
import 'package:zilliken/Helpers/Utils.dart';
import 'package:zilliken/Models/Fields.dart';
import 'package:zilliken/Models/Order.dart';
import 'package:zilliken/Models/OrderItem.dart';
import 'package:zilliken/Services/Authentication.dart';
import 'package:zilliken/Services/Database.dart';
import 'package:zilliken/Services/Messaging.dart';
import 'package:zilliken/i18n.dart';
import 'package:intl/intl.dart';
import 'package:timelines/timelines.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'DashboardPage.dart';
import 'DisabledPage.dart';

class SingleOrderPage extends StatefulWidget {
  final Authentication auth;
  final Database db;
  final String userId;
  final String userRole;
  final String orderId;
  final Order clientOrder;
  final Messaging messaging;
  final DateFormat formatter = DateFormat('HH:mm');

  SingleOrderPage({
    @required this.auth,
    @required this.db,
    @required this.userId,
    @required this.userRole,
    @required this.orderId,
    @required this.clientOrder,
    @required this.messaging,
  });

  @override
  _SingleOrderPageState createState() => _SingleOrderPageState();
}

class _SingleOrderPageState extends State<SingleOrderPage> {
  var oneOrderDetails;
  var orderItems;
  bool isDataBeingDeleted = false;
  int _status = Fields.confirmed;

  int _orderStatus = 1;
  int enabled = 1;

  Order order;
  GeoPoint _currentPoint;

  double CAMERA_ZOOM = 14;
  //double CAMERA_TILT = 80;
  //double CAMERA_BEARING = 0;
  LatLng SOURCE_LOCATION = LatLng(-3.3834389, 29.3616122);

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
  BitmapDescriptor sourceIcon;
  BitmapDescriptor destinationIcon;

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
  CameraPosition initialCameraPosition;

  final _scaffoldKey = GlobalKey<ScaffoldState>();

  bool goingBack = false;

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

    FirebaseFirestore.instance
        .collection(Fields.order)
        .doc(widget.orderId)
        .snapshots()
        .listen((DocumentSnapshot documentSnapshot) {
      setState(() {
        _status = documentSnapshot.data()[Fields.status];

        if (documentSnapshot.data()[Fields.orderLocation] == 1 &&
            _status != 4 &&
            widget.userId != order.deliveringOrderId) {
          _currentPoint = documentSnapshot.data()[Fields.currentPoint];
          currentLocation = Position.fromMap({
            "latitude": _currentPoint.latitude,
            "longitude": _currentPoint.longitude,
          });

          updatePinOnMap(currentLocation);
        }
        /*order = Order();
        order.buildObject(documentSnapshot);*/
      });
    });

    FirebaseFirestore.instance
        .collection(Fields.configuration)
        .doc(Fields.settings)
        .snapshots()
        .listen((DocumentSnapshot documentSnapshot) {
      setState(() {
        enabled = documentSnapshot.data()[Fields.enabled];
      });
    });

    widget.db.getOrder(widget.orderId).then((value) {
      if (value.orderLocation == 1) {
        setState(() {
          order = value;
          _currentPoint = value.currentPoint;
          if (_status != 4) {
            if (widget.userId == order.deliveringOrderId) {
              initLocation();
            } else {
              initLocationFromServer();
            }
          }
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
      setState(() {
        if (_status != 4) {
          currentLocation = position;
          updatePinOnMap(currentLocation);
        }
      });

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
      "latitude": _currentPoint.latitude,
      "longitude": _currentPoint.longitude,
    });

    updatePinOnMap(currentLocation);
    setSourceAndDestinationIcons(); // set the initial location
    destinationLocation = Position.fromMap({
      "latitude": order.geoPoint.latitude,
      "longitude": order.geoPoint.longitude,
    });
  }

  void setInitialLocation() async {
    // set the initial location by pulling the user's
    // current location from the location's getLocation()
    /*currentLocation = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);*/

    Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high)
        .then((value) {
      setState(() {
        currentLocation = value;
        updatePinOnMap(currentLocation);
      });
    });

    // hard-coded destination for this example
    destinationLocation = Position.fromMap({
      "latitude": order.geoPoint.latitude,
      "longitude": order.geoPoint.longitude,
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
        icon: sourceIcon));
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
      onWillPop: () {
        return Navigator.pushAndRemoveUntil(
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
      },
      child: enabled == 0
          ? DisabledPage(
              auth: widget.auth,
              db: widget.db,
              userId: widget.userId,
              userRole: widget.userRole,
            )
          : Scaffold(
              key: _scaffoldKey,
              appBar: buildAppBar(
                  context, widget.auth, true, false, null, null, backFunction),
              body: body(),
            ),
    );
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
              order.orderLocation == 1 &&
              _status != 4 &&
              widget.userRole != Fields.client &&
              order.deliveringOrderId != null &&
              goingBack == false)
            map(),
          if (order != null &&
              order.orderLocation == 1 &&
              _status != 4 &&
              widget.userRole != Fields.client &&
              order.deliveringOrderId == null)
            showDeliverButton(),
          if (order != null &&
              order.orderLocation == 1 &&
              _status != 4 &&
              widget.userRole == Fields.client)
            map(),
          if (widget.userRole == Fields.client) progressionTimeLine(),
          if (widget.userRole == Fields.admin ||
              widget.userRole == Fields.developer ||
              widget.userRole == Fields.chef)
            statusUpdate(),
          orderItemStream(),
          informationStream(),
          Padding(
            padding: EdgeInsets.only(
                left: SizeConfig.diagonal * 0.5,
                right: SizeConfig.diagonal * 0.5),
            child: Card(
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

      _scaffoldKey.currentState.showSnackBar(
        SnackBar(
          content: Text(I18n.of(context).noInternet),
        ),
      );
    } else {
      try {
        await widget.db.assignDelivery(widget.orderId, widget.userId);
        setState(() {
          order.deliveringOrderId = widget.userId;
          initLocation();
        });

        EasyLoading.dismiss();
      } on Exception catch (e) {
        //print('Error: $e');
        EasyLoading.dismiss();

        _scaffoldKey.currentState.showSnackBar(
          SnackBar(
            content: Text(e.toString()),
          ),
        );
      }
    }
  }

  Widget showDeliverButton() {
    return Container(
      child: ZRaisedButton(
        leftPadding: SizeConfig.diagonal * 1,
        rightPadding: SizeConfig.diagonal * 1,
        onpressed: assignOrder,
        topPadding: 0.0,
        bottomPadding: 0.0,
        textIcon: Text(
          I18n.of(context).deliverOrder,
          style: TextStyle(color: Color(Styling.primaryBackgroundColor)),
        ),
      ),
    );
  }

  Widget map() {
    Position p;
    if (widget.userId == order.deliveringOrderId)
      p = currentLocation;
    else {
      p = Position.fromMap({
        "latitude": _currentPoint.latitude,
        "longitude": _currentPoint.longitude,
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
              initialCameraPosition: initialCameraPosition,
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
        icon: sourceIcon)); // destination pin
    _markers.add(Marker(
        markerId: MarkerId('destPin'),
        position: destPosition,
        icon:
            destinationIcon)); // set the route lines on the map from source to destination
    // for more info follow this tutorial
    setPolylines(p);
  }

  void setPolylines(Position p) async {
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      getMapsKey(),
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

  Widget progressionTimeLine() {
    oneOrderDetails.snapshots(includeMetadataChanges: true);
    return Container(
      decoration: BoxDecoration(color: Color(Styling.primaryBackgroundColor)),
      child: StreamBuilder<DocumentSnapshot>(
          stream: oneOrderDetails.snapshots(),
          builder:
              (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
            if (snapshot.data == null)
              return Center(
                child: Text(""),
              );

            Order order = Order();
            order.buildObjectAsync(snapshot);

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
              child: Text(
                I18n.of(context).orderStatus,
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(
                      Styling.textColor,
                    ),
                    fontSize: SizeConfig.diagonal * 1.5),
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
                          Text(
                            I18n.of(context).pending,
                            style: TextStyle(
                              fontSize: SizeConfig.diagonal * 1.5,
                              color: order.status == 1
                                  ? Color(Styling.accentColor)
                                  : Color(Styling.primaryColor),
                            ),
                          ),
                          SizedBox(height: SizeConfig.diagonal * 1),
                          Text(
                            order.orderDate == null
                                ? ""
                                : '${widget.formatter.format(order.orderDate.toDate())}',
                            style: TextStyle(
                              fontSize: SizeConfig.diagonal * 1.5,
                              color: order.status == 1
                                  ? Color(Styling.accentColor)
                                  : Color(Styling.primaryColor),
                            ),
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
                          Text(
                            I18n.of(context).confirmed,
                            style: TextStyle(
                              fontSize: SizeConfig.diagonal * 1.5,
                              color: order.status == 2
                                  ? Color(Styling.accentColor)
                                  : order.status < 2
                                      ? Color(Styling.textColor)
                                          .withOpacity(0.2)
                                      : Color(Styling.primaryColor),
                            ),
                          ),
                          SizedBox(
                            height: SizeConfig.diagonal * 1,
                          ),
                          Text(
                            order.confirmedDate == null
                                ? ""
                                : '${widget.formatter.format(order.confirmedDate.toDate())}',
                            style: TextStyle(
                              fontSize: SizeConfig.diagonal * 1.5,
                              color: order.status == 2
                                  ? Color(Styling.accentColor)
                                  : order.status < 2
                                      ? Color(Styling.textColor)
                                          .withOpacity(0.2)
                                      : Color(Styling.primaryColor),
                            ),
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
                          Text(
                            I18n.of(context).preparing,
                            style: TextStyle(
                              fontSize: SizeConfig.diagonal * 1.5,
                              color: order.status == 3
                                  ? Color(Styling.accentColor)
                                  : order.status < 3
                                      ? Color(Styling.textColor)
                                          .withOpacity(0.2)
                                      : Color(Styling.primaryColor),
                            ),
                          ),
                          SizedBox(height: SizeConfig.diagonal * 1),
                          Text(
                            order.preparationDate == null
                                ? ""
                                : '${widget.formatter.format(order.preparationDate.toDate())}',
                            style: TextStyle(
                              fontSize: SizeConfig.diagonal * 1.5,
                              color: order.status == 3
                                  ? Color(Styling.accentColor)
                                  : order.status < 3
                                      ? Color(Styling.textColor)
                                          .withOpacity(0.2)
                                      : Color(Styling.primaryColor),
                            ),
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
                          Text(
                            I18n.of(context).served,
                            style: TextStyle(
                              fontSize: SizeConfig.diagonal * 1.5,
                              color: order.status == 4
                                  ? Color(Styling.accentColor)
                                  : order.status < 4
                                      ? Color(Styling.textColor)
                                          .withOpacity(0.2)
                                      : Color(Styling.primaryColor),
                            ),
                          ),
                          SizedBox(height: SizeConfig.diagonal * 1),
                          Text(
                            order.servedDate == null
                                ? ""
                                : '${widget.formatter.format(order.servedDate.toDate())}',
                            style: TextStyle(
                              fontSize: SizeConfig.diagonal * 1.5,
                              color: order.status == 4
                                  ? Color(Styling.accentColor)
                                  : order.status < 4
                                      ? Color(Styling.textColor)
                                          .withOpacity(0.2)
                                      : Color(Styling.primaryColor),
                            ),
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
        elevation: 16,
        child: new Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              margin: EdgeInsets.all(SizeConfig.diagonal * 1),
              child: Text(
                I18n.of(context).updateStatus,
                style: new TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: SizeConfig.diagonal * 1.5,
                ),
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
                    value: 1,
                    groupValue: _orderStatus,
                    onChanged: handleStatusChange,
                  ),
                  new Text(
                    I18n.of(context).pendingOrder,
                    style: new TextStyle(fontSize: SizeConfig.diagonal * 1.5),
                  ),
                  new Radio(
                    value: 2,
                    groupValue: _orderStatus,
                    onChanged: handleStatusChange,
                  ),
                  new Text(
                    I18n.of(context).confirmedOrder,
                    style: new TextStyle(
                      fontSize: SizeConfig.diagonal * 1.5,
                    ),
                  ),
                  new Radio(
                    value: 3,
                    groupValue: _orderStatus,
                    onChanged: handleStatusChange,
                  ),
                  new Text(
                    I18n.of(context).orderPreparation,
                    style: new TextStyle(
                      fontSize: SizeConfig.diagonal * 1.5,
                    ),
                  ),
                  new Radio(
                    value: 4,
                    groupValue: _orderStatus,
                    onChanged: handleStatusChange,
                  ),
                  new Text(
                    I18n.of(context).orderServed,
                    style: new TextStyle(
                      fontSize: SizeConfig.diagonal * 1.5,
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

  void handleStatusChange(int value) {
    setState(() {
      goingBack = value < _orderStatus ? true : false;
      _orderStatus = value;
    });

    if (goingBack) {
      backFunction();
    }

    widget.db.updateStatus(widget.orderId, _orderStatus, value);
  }

  Widget orderItemStream() {
    return StreamBuilder<QuerySnapshot>(
      stream: orderItems.snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.data == null)
          return Center(
            child: Text(""),
          );

        return Padding(
          padding: EdgeInsets.only(
              left: SizeConfig.diagonal * 0.5,
              right: SizeConfig.diagonal * 0.5),
          child: Card(
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
                    child: Text(
                      I18n.of(context).order,
                      style: TextStyle(
                          fontSize: SizeConfig.diagonal * 1.5,
                          color: Color(Styling.textColor),
                          fontWeight: FontWeight.bold),
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
                ListTile(
                  onTap: () {},
                  title: Text(
                    I18n.of(context).items,
                    style: TextStyle(
                      color: Color(Styling.textColor),
                      fontWeight: FontWeight.bold,
                      fontSize: SizeConfig.diagonal * 1.5,
                    ),
                  ),
                  trailing: Text(
                    I18n.of(context).number,
                    style: TextStyle(
                      color: Color(Styling.textColor),
                      fontWeight: FontWeight.bold,
                      fontSize: SizeConfig.diagonal * 1.5,
                    ),
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: snapshot.data.docs.map((DocumentSnapshot document) {
                    OrderItem orderItem = OrderItem();
                    orderItem.buildObject(document);
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
                child: Text(
                  '${orderItem.menuItem.name}',
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: SizeConfig.diagonal * 1.5,
                    color: Color(Styling.textColor),
                  ),
                ),
              ),
              SizedBox(width: SizeConfig.diagonal * 1),
              Expanded(
                flex: 1,
                child: Text(
                  '${orderItem.count}',
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.end,
                  style: TextStyle(
                    color: Color(Styling.textColor),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget billStream() {
    return StreamBuilder<QuerySnapshot>(
      stream: orderItems.snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.data == null)
          return Center(
            child: Text(""),
          );

        return Column(
          children: [
            Padding(
              padding: EdgeInsets.only(
                bottom: SizeConfig.diagonal * 1.5,
                top: SizeConfig.diagonal * 1.5,
              ),
              child: Center(
                child: Text(
                  I18n.of(context).billDetails,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
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
              children: snapshot.data.docs.map((DocumentSnapshot document) {
                OrderItem orderItem = OrderItem();
                orderItem.buildObject(document);
                return billElement(orderItem);
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
                flex: 3,
                child: Text(
                  '${orderItem.menuItem.name} x ${orderItem.count}',
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Color(Styling.textColor),
                  ),
                ),
              ),
              SizedBox(width: SizeConfig.diagonal * 1),
              Expanded(
                flex: 1,
                child: Text(
                  '${formatNumber(orderItem.menuItem.price)} Fbu',
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.end,
                  style: TextStyle(
                    color: Color(Styling.textColor),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget billStream2() {
    return StreamBuilder<DocumentSnapshot>(
      stream: oneOrderDetails.snapshots(),
      builder:
          (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
        if (snapshot.data == null)
          return Center(
            child: Text(""),
          );

        Order order = Order();
        order.buildObjectAsync(snapshot);
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
    int grandTotal;
    if (order.grandTotal is double) {
      grandTotal = order.grandTotal.round();
    } else {
      grandTotal = order.grandTotal;
    }

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
                flex: 1,
                child: Text(
                  '${I18n.of(context).taxCharge}',
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Color(Styling.textColor),
                  ),
                ),
              ),
              SizedBox(width: SizeConfig.diagonal * 1),
              Expanded(
                flex: 1,
                child: Text(
                  appliedTaxFromTotal(
                      context, order.total, order.taxPercentage),
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.end,
                  style: TextStyle(
                    color: Color(Styling.textColor),
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
                child: Text(
                  '${I18n.of(context).grandTotal}',
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Color(Styling.textColor),
                  ),
                ),
              ),
              SizedBox(width: SizeConfig.diagonal * 1),
              Expanded(
                flex: 1,
                child: Text(
                  '${formatNumber(grandTotal)} Fbu',
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.end,
                  style: TextStyle(
                    color: Color(Styling.textColor),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget informationStream() {
    return StreamBuilder<DocumentSnapshot>(
      stream: oneOrderDetails.snapshots(),
      builder:
          (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
        if (snapshot.data == null)
          return Center(
            child: Text(""),
          );

        Order order = Order();
        order.buildObjectAsync(snapshot);
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
              child: Text(
                I18n.of(context).orderInformation,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(
                    Styling.textColor,
                  ),
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
                    child: Text(
                      '${I18n.of(context).orderDate}',
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Color(
                          Styling.textColor,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: SizeConfig.diagonal * 1),
                  Expanded(
                    flex: 1,
                    child: Text(
                      '${widget.formatter.format(order.orderDate.toDate())}',
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.end,
                      style: TextStyle(
                        color: Color(
                          Styling.textColor,
                        ),
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
                    child: Text(
                      '${tableAddressStatus(order)}',
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Color(
                          Styling.textColor,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: SizeConfig.diagonal * 1),
                  Expanded(
                    flex: 1,
                    child: Text(
                      order.tableAdress,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.end,
                      style: TextStyle(
                        color: Color(
                          Styling.textColor,
                        ),
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
                      child: Text(
                        I18n.of(context).instr,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Color(
                            Styling.textColor,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: SizeConfig.diagonal * 1),
                    Expanded(
                      flex: 1,
                      child: Text(
                        order.instructions,
                        overflow: TextOverflow.visible,
                        textAlign: TextAlign.end,
                        style: TextStyle(
                          height: 1,
                          color: Color(
                            Styling.textColor,
                          ),
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
    return ZRaisedButton(
      leftPadding: SizeConfig.diagonal * 1,
      rightPadding: SizeConfig.diagonal * 1,
      onpressed: () async {
        setState(() {
          isDataBeingDeleted = true;
        });
        await widget.db.cancelOrder(widget.orderId);
        backFunction();
      },
      textIcon: Text(
        I18n.of(context).cancelOrder,
        style: TextStyle(color: Color(Styling.primaryBackgroundColor)),
      ),
    );
  }
}
