import 'package:flutter/material.dart';
import 'package:zilliken/Components/ZTextField.dart';
import 'package:zilliken/Helpers/SizeConfig.dart';
import 'package:zilliken/Helpers/Styling.dart';
import 'package:zilliken/Helpers/Utils.dart';
import 'package:zilliken/Models/Fields.dart';
import 'package:zilliken/Models/UserProfile.dart';
import 'package:zilliken/Pages/SingleUserPage.dart';
import 'package:zilliken/Services/Authentication.dart';
import 'package:zilliken/Services/Database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:collection/collection.dart';

import '../Components/ZText.dart';
import '../i18n.dart';
import 'SearchPage.dart';

class UserPage extends StatefulWidget {
  final Authentication auth;
  final Database db;
  final String userId;
  final DateFormat formatter = DateFormat('dd/MM/yy hh:mm ');
  final String userRole;

  UserPage({
    required this.auth,
    required this.db,
    required this.userId,
    required this.userRole,
  });

  @override
  _UserPageState createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  late QuerySnapshot<Map<String, dynamic>> itemref;
  int documentLimit = 25;
  bool hasMore = true;
  DocumentSnapshot<Map<String, dynamic>>? lastDocument;
  List<DocumentSnapshot<Map<String, dynamic>>> items = [];

  TextEditingController searchController = TextEditingController();
  String? searchText = '';
  ScrollController _scrollController = ScrollController();
  late Query<Map<String, dynamic>> searchRef1;
  late Query<Map<String, dynamic>> searchRef2;
  List<DocumentSnapshot<Map<String, dynamic>>> searchList = [];
  String? noResult = '';
  bool isSearchLoading = false;
  bool displayCancelButton = false;
  bool isSearching = false;
  bool isLoading = false;
  List<String> searchTags = [];

  @override
  void initState() {
    super.initState();
    itemQuery();
    _scrollController.addListener(() {
      double maxScroll = _scrollController.position.maxScrollExtent;
      double currentScroll = _scrollController.position.pixels;
      double delta = MediaQuery.of(context).size.height * 0.20;
      if (maxScroll - currentScroll <= delta) {
        if (isLoading == false) {
          itemQuery();
        }
      }
    });
  }

  void itemQuery() async {
    if (!hasMore) {
      return;
    }

    if (isLoading == true) {
      return;
    }

    setState(() {
      isLoading = true;
    });

    if (lastDocument == null) {
      itemref = await widget.db.databaseReference
          .collection(Fields.users)
          .orderBy(Fields.lastSeenAt, descending: true)
          .limit(documentLimit)
          .get();
    } else {
      itemref = await widget.db.databaseReference
          .collection(Fields.users)
          .orderBy(Fields.lastSeenAt, descending: true)
          .startAfterDocument(lastDocument!)
          .limit(documentLimit)
          .get();
    }

    if (itemref.docs.length < documentLimit) {
      hasMore = false;
    }

    if (itemref.docs.length > 0)
      lastDocument = itemref.docs[itemref.docs.length - 1];
    setState(() {
      for (int i = 0; i < itemref.docs.length; i++) {
        items.add(itemref.docs[i]);
      }
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(SizeConfig.diagonal * 1),
            child: ZTextField(
              hint: (I18n.of(context).search),
              maxLines: 1,
              controller: searchController,
              keyboardType: TextInputType.text,
              textInputAction: TextInputAction.search,
              outsidePrefix: Icon(
                Icons.search,
                size: SizeConfig.diagonal * 2.5,
              ),
              outsideSuffix: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  displayCancelButton
                      ? IconButton(
                          icon: Icon(
                            Icons.cancel_outlined,
                            color: Color(Styling.primaryColor),
                            size: SizeConfig.diagonal * 2.5,
                          ),
                          onPressed: () {
                            setState(() {
                              searchController.clear();
                              isSearching = false;
                              displayCancelButton = false;
                            });
                          })
                      : Text(''),
                ],
              ),
              onFieldSubmitted: (String? value) {
                if (value != null && value.isNotEmpty && value != '') {
                  setState(() {
                    isSearching = true;
                  });
                  searchText = value;
                  isSearchLoading = false;
                  searchQuery();
                } else {
                  setState(() {
                    isSearching = false;
                  });
                }
              },
              onChanged: (String? value) {
                if (value == null || value.isEmpty || value == '') {
                  setState(() {
                    isSearching = false;
                    displayCancelButton = false;
                  });
                } else {
                  setState(() {
                    displayCancelButton = true;
                  });
                }
              },
            ),
          ),
          isSearching ? searchBody() : body(),
        ],
      ),
    );
  }

  Widget searchBody() {
    return SearchPage(
      auth: widget.auth,
      db: widget.db,
      userId: widget.userId,
      userRole: widget.userRole,
      isLoading: isSearchLoading,
      noResult: noResult!,
      searchList: searchList,
    );
  }

  Widget body() {
    return Expanded(
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            userListStream(),
          ],
        ),
      ),
    );
  }

  Widget userListStream() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        items.length == 0
            ? Center(
                child: ZText(content: ""),
              )
            : Column(
                children: items
                    .map((DocumentSnapshot<Map<String, dynamic>> document) {
                  UserProfile userProfile = UserProfile.buildObject(document);
                  return userList(userProfile);
                }).toList(),
              ),
        isLoading
            ? Container(
                width: MediaQuery.of(context).size.width,
                padding: EdgeInsets.all(SizeConfig.diagonal * 1),
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              )
            : Container()
      ],
    );
  }

  Widget userList(UserProfile userProfile) {
    return Card(
      color: Colors.white.withOpacity(0.7),
      margin: EdgeInsets.symmetric(
          horizontal: SizeConfig.diagonal * 0.9,
          vertical: SizeConfig.diagonal * 0.4),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(SizeConfig.diagonal * 1.5)),
      elevation: 8.0,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: SizeConfig.diagonal * 1),
        child: ListTile(
          leading: Padding(
            padding: EdgeInsets.only(top: SizeConfig.diagonal * 1),
            child: Icon(
              Icons.person,
              size: 25,
              color: Color(Styling.accentColor),
            ),
          ),
          title: Padding(
            padding: EdgeInsets.only(
              bottom: SizeConfig.diagonal * 1,
            ),
            child: ZText(
              content: '${I18n.of(context).name} ' " : " ' ${userProfile.name}',
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.only(
                  bottom: SizeConfig.diagonal * 1,
                ),
                child: ZText(
                  content:
                      I18n.of(context).phone + " : " + userProfile.phoneNumber,
                ),
              ),
              ZText(
                content: '${I18n.of(context).last} '
                    " : "
                    '${widget.formatter.format(userProfile.lastSeenAt!.toDate())}',
              ),
            ],
          ),
          trailing: Padding(
            padding: EdgeInsets.only(
              top: SizeConfig.diagonal * 1,
            ),
            child: Icon(
              Icons.keyboard_arrow_right,
              size: 30,
              color: Color(Styling.accentColor),
            ),
          ),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SingleUserPage(
                  db: widget.db,
                  auth: widget.auth,
                  userId: widget.userId,
                  userRole: widget.userRole,
                  userData: userProfile,
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void searchQuery() {
    if (isSearchLoading == true) {
      // log("here 2");
      return;
    }
    searchList.clear();
    if (mounted) {
      setState(() {
        isSearchLoading = true;
        noResult = '';
      });
    }

    searchRef1 = FirebaseFirestore.instance
        .collection(Fields.users)
        .where(Fields.tags, arrayContains: searchReady(searchText!))
        .limit(50);

    searchRef1.get().then((QuerySnapshot<Map<String, dynamic>>? snapshot) {
      if (snapshot == null || snapshot.docs.length < 1) {
        // log("here 8");
        searchQuery2();
      } else {
        //log("here 9");
        if (mounted) {
          setState(() {
            searchList.removeWhere((Object item) {
              if (item is DocumentSnapshot<Map<String, dynamic>>) {
                DocumentSnapshot<Map<String, dynamic>>? exist = snapshot.docs
                    .firstWhereOrNull(
                        (DocumentSnapshot<Map<String, dynamic>> element) =>
                            element.id == item.id);
                if (exist == null) {
                  return true;
                } else {
                  return false;
                }
              } else {
                return true;
              }
            });

            snapshot.docs.forEach((item) {
              Object? exist = searchList.firstWhereOrNull((Object element) {
                if (element is DocumentSnapshot<Map<String, dynamic>>) {
                  bool isEqual = element.id == item.id;
                  return isEqual;
                } else {
                  return false;
                }
              });

              if (exist == null) {
                searchList.add(item);
              }
            });
            isSearchLoading = false;
          });
        }
      }
    });
  }

  void searchQuery2() {
    searchTags = [];
    searchTags = createTags(searchText!);
    if (searchTags.length > 10) {
      searchTags = searchTags.sublist(0, 10);
    }

    searchRef2 = FirebaseFirestore.instance
        .collection(Fields.users)
        .where(Fields.tags, arrayContainsAny: searchTags)
        .limit(50);

    searchRef2.get().then((QuerySnapshot<Map<String, dynamic>>? snapshot) {
      if (snapshot == null || snapshot.docs.length < 1) {
        // log("here 13");
        if (mounted) {
          setState(() {
            isSearchLoading = false;
            noResult = I18n.of(context).noResult;
          });
        }
      } else {
        // log("here 14");
        if (mounted) {
          setState(() {
            searchList.removeWhere((Object item) {
              if (item is DocumentSnapshot<Map<String, dynamic>>) {
                DocumentSnapshot<Map<String, dynamic>>? exist = snapshot.docs
                    .firstWhereOrNull(
                        (DocumentSnapshot<Map<String, dynamic>> element) =>
                            element.id == item.id);
                if (exist == null) {
                  return true;
                } else {
                  return false;
                }
              } else {
                return true;
              }
            });

            snapshot.docs.forEach((item) {
              Object? exist = searchList.firstWhereOrNull((Object element) {
                if (element is DocumentSnapshot<Map<String, dynamic>>) {
                  bool isEqual = element.id == item.id;
                  return isEqual;
                } else {
                  return false;
                }
              });

              if (exist == null) {
                searchList.add(item);
              }
            });

            isSearchLoading = false;
          });
        }
      }
    });
  }
}
