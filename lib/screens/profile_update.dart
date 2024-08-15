import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:loveria/common/language/language_extension.dart';
import '../common/services/auth.dart';
import '../common/services/data_transport.dart' as data_transport;
import '../common/services/utils.dart';
import '../common/widgets/form_fields.dart';
import '../common/widgets/common.dart';
import 'dart:async';
import 'package:easy_autocomplete/easy_autocomplete.dart';

class ProfileUpdatePage extends StatefulWidget {
  const ProfileUpdatePage({Key? key}) : super(key: key);

  @override
  State<ProfileUpdatePage> createState() => _ProfileUpdatePageState();
}

class _ProfileUpdatePageState extends State<ProfileUpdatePage>
    with AutomaticKeepAliveClientMixin<ProfileUpdatePage> {
  @override
  void initState() {
    _fetchMyData = data_transport.get(
      'profile/prepare-profile-update',
      context: context,
    );
    super.initState();
  }

  @override
  bool get wantKeepAlive => true;
  List locationResultData = [];
  Future? _fetchMyData;
  Timer? _debounce;
  final Map<String, dynamic> formInputData = {};
  Map<String, dynamic> basicUserInformationFormInputs = {};
  List<Map> formFields = [];

  void _updateProfileData(BuildContext context, item, value) {
    if (value != formInputData[item['name']]) {
      if (_debounce?.isActive ?? false) {
        _debounce?.cancel();
      }
      _debounce = Timer(
        const Duration(milliseconds: 1000),
        () {
          setState(() {
            formInputData[item['name']] = value;
          });
          data_transport.post(
            'update-profile-settings',
            inputData: formInputData,
            context: context,
          );
        },
      );
    }
  }

  void _updateBasicInfo(BuildContext context, itemName, value) {
    if (value != basicUserInformationFormInputs[itemName]) {
      if (_debounce?.isActive ?? false) {
        _debounce?.cancel();
      }
      _debounce = Timer(
        const Duration(milliseconds: 1000),
        () {
          setState(() {
            basicUserInformationFormInputs[itemName] = value;
          });
          data_transport.post(
            'update-basic-settings',
            inputData: basicUserInformationFormInputs,
            context: context,
            onSuccess: (responseData) {
              refreshUserInfo();
            },
          );
        },
      );
    }
  }

  List<String> processedLocations = [];

  Future<List<String>> _fetchLocationSuggestions(String searchValue) async {
    processedLocations = [];
    await data_transport.post(
      'search-static-cities',
      inputData: {'search_query': searchValue},
      onSuccess: (responseData) {
        locationResultData = getItemValue(responseData, 'data.search_result');
        if (locationResultData.isNotEmpty) {
          locationResultData.forEach(((element) {
            processedLocations.add(element['cities_full_name']);
          }));
        }
      },
    );
    return processedLocations.toList();
  }

  @override
  void dispose() {
    basicUserInformationFormInputs = {};
    formFields = [];
    if (_debounce?.isActive ?? false) {
      _debounce?.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      appBar: mainAppBarWidget(
          title: 'My Profile Update'.toTranslated(),
          context: context,
          actionWidgets: []),
      body: FutureBuilder(
          future: _fetchMyData,
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            List<Widget> children = [];
            // fixed tabs
            List<Widget> tabItems = [
              Padding(
                padding: EdgeInsets.only(left: 20, right: 20),
                child: Tab(text: 'Basic Information'.toTranslated()),
              ),
            ];
            // fixed tab views
            List<Widget> tabViews = [];
            if (snapshot.hasData &&
                (snapshot.connectionState == ConnectionState.done)) {
              Map data = jsonDecode(snapshot.data.toString());
              if (basicUserInformationFormInputs.isEmpty) {
                basicUserInformationFormInputs =
                    data['data']?['basicInformation'] ?? {};
              }

              final Map<String, dynamic> userBasicConfigurations =
                  data['data']?['user_settings'] ?? {};
              final Map<String, dynamic> otherSettings =
                  data['data']?['other_settings'] ?? {};

              List phoneCountries = [
                {'name': 'Select Country Code'.toTranslated(), 'phone_code': ''}
              ];
              phoneCountries.addAll(getItemValue(
                  data, 'data.other_settings.country_phone_codes',
                  fallbackValue: []));

              print(
                  ("userBasicConfigurations['preferred_language'] : ${userBasicConfigurations['preferred_language']}"));

              tabViews.add(SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    InputField(
                      initialValue:
                          basicUserInformationFormInputs['first_name'],
                      labelText: 'First Name'.toTranslated(),
                      onChanged: (String? value) {
                        _updateBasicInfo(context, 'first_name', value);
                      },
                    ),
                    InputField(
                      initialValue: basicUserInformationFormInputs['last_name'],
                      labelText: 'Last Name'.toTranslated(),
                      onChanged: (String? value) {
                        _updateBasicInfo(context, 'last_name', value);
                      },
                    ),
                    //    locationUpdateWidget(context),
                    SelectField(
                      value:
                          basicUserInformationFormInputs['gender'].toString(),
                      listItems: userBasicConfigurations['gender'],
                      labelText: 'Gender'.toTranslated(),
                      onChanged: (String? value) {
                        _updateBasicInfo(context, 'gender', value);
                      },
                    ),
                    /*SelectField(
                      value:
                          basicUserInformationFormInputs['preferred_language']
                              .toString(),
                      listItems: userBasicConfigurations['preferred_language'],
                      labelText: 'Language'.toTranslated(),
                      onChanged: (String? value) {
                        _updateBasicInfo(context, 'preferred_language', value);
                      },
                    ),*/
                    SelectField(
                      value: basicUserInformationFormInputs['country_code']
                          .toString(),
                      optionKeyName: 'phone_code',
                      optionLabelName: 'name',
                      showOptionKeyInBracket: true,
                      listItems: phoneCountries,
                      labelText: 'Mobile Country Code'.toTranslated(),
                      onChanged: (String? value) {
                        _updateBasicInfo(context, 'country_code', value);
                      },
                    ),
                    InputField(
                      inputType: TextInputType.phone,
                      initialValue: basicUserInformationFormInputs[
                          'mobile_number_without_country_code'],
                      labelText: 'Mobile Number'.toTranslated(),
                      onChanged: (String? value) {
                        _updateBasicInfo(context, 'mobile_number', value);
                      },
                    ),
                    InputField(
                      inputType: TextInputType.multiline,
                      initialValue: basicUserInformationFormInputs['about_me'],
                      labelText: 'About me'.toTranslated(),
                      onChanged: (String? value) {
                        _updateBasicInfo(context, 'about_me', value);
                      },
                    ),
                    DateTimeInputPicker(
                      initialValue:
                          basicUserInformationFormInputs['birthday'].toString(),
                      minimumDate: otherSettings['min_age_year'].toString(),
                      maximumDate: otherSettings['max_age_year'].toString(),
                      labelText: 'Birthday'.toTranslated(),
                      onChanged: (String? value) {
                        _updateBasicInfo(context, 'birthday', value);
                      },
                    ),
                    /*  SelectField(
                      value: basicUserInformationFormInputs['education']
                          .toString(),
                      listItems: userBasicConfigurations['educations'],
                      labelText: 'Education',
                      onChanged: (String? value) {
                        _updateBasicInfo(context, 'education', value);
                      },
                    ),*/
                    /* SelectField(
                      value:
                          basicUserInformationFormInputs['relationship_status']
                              .toString(),
                      listItems: userBasicConfigurations['relationship_status'],
                      labelText: 'Relationship Status',
                      onChanged: (String? value) {
                        _updateBasicInfo(context, 'relationship_status', value);
                      },
                    ),*/
                    /* SelectField(
                      value: basicUserInformationFormInputs['work_status']
                          .toString(),
                      listItems: userBasicConfigurations['work_status'],
                      labelText: 'Work Status',
                      onChanged: (String? value) {
                        _updateBasicInfo(context, 'work_status', value);
                      },
                    ),*/
                  ],
                ),
              ));

              if (data['data']?['specifications'] != null) {
                data['data']['specifications']
                    .forEach((specificationItemIndex, specificationItem) {
                  tabItems.add(Padding(
                    padding: const EdgeInsets.only(left: 20, right: 20),
                    child: Tab(
                        text: specificationItem['title']
                            .toString()
                            .toTranslated()),
                  ));
                  List itemOptions = specificationItem['items'];

                  List<Widget> listOfItems = [];
                  for (var item in itemOptions) {
                    if ((!formInputData.containsKey(item['name']))) {
                      formInputData[item['name']] = item['selected_options'];
                    }

                    if (item['input_type'] == 'select') {
                      listOfItems.add(SelectField(
                        value: formInputData[item['name']],
                        listItems: item['options'],
                        labelText: item['label'].toString().toTranslated(),
                        onChanged: (String? value) {
                          _updateProfileData(context, item, value);
                        },
                      ));
                    } else if (item['input_type'] == 'textbox') {
                      listOfItems.add(InputField(
                        initialValue: item['selected_options'],
                        labelText: item['label'].toString().toTranslated(),
                        onChanged: (String? value) {
                          _updateProfileData(context, item, value);
                        },
                      ));
                    }
                  }
                  tabViews.add(SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: listOfItems,
                    ),
                  ));
                });
              }
            } else if (snapshot.hasError) {
              children = <Widget>[
                const Icon(
                  Icons.error_outline,
                  color: Colors.red,
                  size: 60,
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Text('Error: ${snapshot.error}'),
                ),
              ];
            } else {
              children = <Widget>[
                const AppItemProgressIndicator(),
              ];
            }

            if (children.isEmpty) {
              return DefaultTabController(
                length: tabItems.length,
                child: Scaffold(
                  appBar: AppBar(
                    elevation: 0,
                    toolbarHeight: 0,
                    bottom: TabBar(
                        labelStyle: const TextStyle(fontSize: 18),
                        isScrollable: true,
                        indicatorSize: TabBarIndicatorSize.label,
                        indicator: UnderlineTabIndicator(
                          borderSide: BorderSide(
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        tabs: tabItems),
                    // title: const Text('Profile'),
                  ),
                  body: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: TabBarView(children: tabViews),
                  ),
                ),
              );
            } else {
              return Center(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: children,
                ),
              );
            }
          }),
    );
  }

  EasyAutocomplete locationUpdateWidget(BuildContext context) {
    return EasyAutocomplete(
        decoration: const InputDecoration(
            labelText: 'Location',
            labelStyle: TextStyle(
              height: 1,
              fontSize: 18.0,
            )),
        debounceDuration: const Duration(milliseconds: 300),
        progressIndicatorBuilder: const AppItemProgressIndicator(),
        asyncSuggestions: (searchValue) async {
          return _fetchLocationSuggestions(searchValue);
        },
        onChanged: (value) {
          if (value.isNotEmpty && locationResultData.isNotEmpty) {
            Map searchedLocationItem = locationResultData.singleWhere(
              (element) {
                return element['cities_full_name'] == value;
              },
            );
            if (searchedLocationItem.isNotEmpty) {
              data_transport.post('store-city',
                  inputData: {'selected_city_id': searchedLocationItem['id']},
                  context: context);
            }
          }
          return value;
        });
  }
}

class BasicInfoWidget extends StatelessWidget {
  const BasicInfoWidget({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      // mainAxisAlignment: MainAxisAlignment.spaceAround,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Center(
          child: Text(
              'Your basic information form will come here.'.toTranslated()),
        )
      ],
    );
  }
}
