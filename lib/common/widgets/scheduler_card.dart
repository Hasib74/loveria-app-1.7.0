import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class SchedulerCard extends StatelessWidget {
  String? title;

  String? date;

  String? address;

  String? matchedUserName;

  String? matchedUserImg;

  SchedulerCard(
      {super.key,
      this.title,
      this.date,
      this.address,
      this.matchedUserName,
      this.matchedUserImg});

  Color cardColor = Colors.white;

  @override
  Widget build(BuildContext context) {
    cardColor = const Color(0xffFF6A69);


    print("matchedUserImg :: $matchedUserImg");

    return Container(
      width: MediaQuery.of(context).size.width * 0.9,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(45),
        color: cardColor,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: Row(
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(45),
                color: Colors.white,
              ),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Icon(
                    Icons.calendar_month,
                    color: cardColor,
                    size: 50,
                  ),
                ),
              ),
            ),
            const SizedBox(
              width: 16,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title ?? "Scheduler Card",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    matchedUserName ?? "Name",
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                  Text(
                    dateFormat(date ?? "") ?? "Date",
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                  Text(address ?? "Address",
                      style:
                          TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  SizedBox(
                    height: 8,
                  ),
                ],
              ),
            ),
          
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(45),
                color: Colors.white,
                image: DecorationImage(
                  image: NetworkImage(matchedUserImg ??
                      "https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460_1280.png"),
                  fit: BoxFit.cover,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  String dateFormat(String dateTimeString) {
    DateTime dateTime = DateTime.parse(dateTimeString);

    String formattedDateTime =
        DateFormat('dd/MM/yyyy hh:mm a').format(dateTime);
    print(formattedDateTime);

    return formattedDateTime;
  }
}
