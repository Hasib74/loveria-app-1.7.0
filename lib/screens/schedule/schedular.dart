import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:loveria/common/services/auth.dart';
import 'package:loveria/screens/schedule/model/schedule_model.dart';

import '../../common/widgets/scheduler_card.dart';
import 'package:http/http.dart' as http;

class SchedulerPage extends StatefulWidget {
  SchedulerPage({Key? key}) : super(key: key);

  @override
  State<SchedulerPage> createState() => _SchedulerPageState();
}

class _SchedulerPageState extends State<SchedulerPage> {
  ScheduleList scheduleList = ScheduleList();

  getSchedulers() async {
    print(userInfo["_id"]);
    var response = await http.get(
        Uri.parse("https://dating.paksang.com/schedule/${userInfo["_id"]}"));

    print(response.body);

    if (response.statusCode == 200) {
      setState(() {
        scheduleList = ScheduleList.fromJson(jsonDecode(response.body));
      });
    } else {
      print("Failed to get data");
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getSchedulers();
  }

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
        itemBuilder: (context, int index) {
          return SchedulerCard(
            title: scheduleList.scheduleList?[index].title,
            date: scheduleList.scheduleList?[index].datetime,
            address: scheduleList.scheduleList?[index].address,
            matchedUserName: scheduleList.scheduleList?[index].matchedUserName,
            matchedUserImg: scheduleList.scheduleList?[index].matchedUserImg,
          );
        },
        separatorBuilder: (context, int index) {
          return SizedBox(
            height: 16,
          );
        },
        itemCount: scheduleList.scheduleList?.length ?? 0);

    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(
            height: 16,
          ),
          SchedulerCard(),
          const SizedBox(
            height: 16,
          ),
          SchedulerCard(),
          const SizedBox(
            height: 16,
          ),
          SchedulerCard(),
          const SizedBox(
            height: 16,
          ),
          SchedulerCard(),
        ],
      ),
    );
  }
}
