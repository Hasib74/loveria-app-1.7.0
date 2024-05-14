import 'package:flutter/material.dart';

class BannerScreen extends StatelessWidget {
  BannerScreen({super.key});

  List<String> bannerAssetList = [
    'assets/images/b1.jpg',
    'assets/images/b2.jpg',
    'assets/images/b3.jpg',
  ];

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
        padding: const EdgeInsets.all(16),
        shrinkWrap: true,
        itemBuilder: (BuildContext context, int index) {
          return Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                image: DecorationImage(
                    fit: BoxFit.cover,
                    image: AssetImage(
                      bannerAssetList[index],
                    ))),
            height: 200,
            width: MediaQuery.of(context).size.width * 0.8,
          );
        },
        separatorBuilder: (BuildContext context, int index) {
          return SizedBox(
            height: 16,
          );
        },
        itemCount: bannerAssetList.length);
  }
}
