import 'package:cloud_firestore/cloud_firestore.dart';

class Fields {
  static final String users = "users";
  static final String configuration = "configuration";
  static final String order = "order";
  static final String items = "items";

  static final String id = "id";
  static final String role = "role";
  static final String receiveNotifications = "receiveNotifications";

  static final String client = 'client';
  static final String chef = 'chef';
  static final String server = 'server';
  static final String admin = 'admin';
  static final String developer = 'developer';

  static final String chefCuisine = 'chefCuisine';
  static final String chefBoissons = 'chefBoissons';

  static final String taxes = 'taxes';
  static final String percentage = 'percentage';

  static final String orderLocation = 'orderLocation';
  static final String instructions = 'instructions';
  static final String grandTotal = 'grandTotal';
  static final String status = 'status';
  static final String orderDate = 'orderDate';
  static final String confirmedDate = 'confirmedDate';
  static final String preparationDate = 'preparationDate';
  static final String servedDate = 'servedDate';
  static final String userId = 'userId';
  static final String userRole = 'userRole';
  static final String taxPercentage = 'taxPercentage';
  static final String total = 'total';

  static final String count = 'count';
  static final String name = 'name';
  static final String category = 'category';
  static final String price = 'price';
  static final String rank = 'rank';
  static final String global = 'global';

  static final String menu = 'menu';
  static final String createdAt = 'createdAt';
  static final String availability = 'availability';

  static final int pending = 1;
  static final int confirmed = 2;
  static final int preparation = 3;
  static final int served = 4;

  static final String tableAdress = 'tableAdress';
  static final String phoneNumber = 'phoneNumber';
  static final String tout = 'Tout';
  static final String boissonsChaudes = 'Boissons chaudes';

  static final String settings = 'settings';
  static final String enabled = 'enabled';
  static final String imageName = 'imageName';
  static final String calls = 'calls';

  /*static final String isDrink = 'isDrink';
  static final String coldCount = 'coldCount';
  static final String lukeWCount = 'lukeWCount';*/
  static final String hasCalled = 'hasCalled';

  static final String token = 'token';
  static final String lastSeenAt = 'lastSeenAt';

  static final String orderId = 'orderId';
  static final String addressName = 'addressName';
  static final String geoPoint = 'geoPoint';
  static final String addresses = 'addresses';
  static final String address = 'address';
  static final String currentPoint = 'currentPoint';
  static final String typedAddress = 'typedAddress';
  static final String deliveringOrderId = 'deliveringOrderId';
  static final String isDrink = 'isDrink';

  static final String date = 'date';
  static final String statistic = 'statistic';

  static final String quantity = 'quantity';
  static final String unit = 'unit';
  static final String usedSince = 'usedSince';
  static final String usedTotal = 'usedTotal';
  static final String stock = 'stock';
  static final String date = 'date';

  static final String itemId = 'itemId';
  static final String itemName = 'itemName';
  static final String substQuantity = 'substQuantity';
  static final String linked = 'linked';
  static final String condiments = 'condiments';
}
