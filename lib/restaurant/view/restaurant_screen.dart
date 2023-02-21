import 'package:baedal/common/dio/vince_dio.dart';
import 'package:baedal/restaurant/component/restaurant_card.dart';
import 'package:baedal/restaurant/model/restaurant_model.dart';
import 'package:baedal/restaurant/repository/restaurant_repository.dart';
import 'package:baedal/restaurant/view/restaurant_detail_screen.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../../common/constant/data.dart';

class RestaurantScreen extends StatelessWidget {
  const RestaurantScreen({Key? key}) : super(key: key);

  Future<List<RestaurantModel>> paginationRestaurant() async {
    final dio = Dio();
    dio.interceptors.add(
      CustomInterceptor(storage),
    );

    final resp =
        await RestaurantRepository(dio, baseUrl: 'http://$ip/restaurant')
            .paginate();

    return resp.data;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: FutureBuilder<List<RestaurantModel>>(
            future: paginationRestaurant(),
            builder: (context, AsyncSnapshot<List<RestaurantModel>> snapshot) {
              if (!snapshot.hasData) {
                return Center(
                  child: CircularProgressIndicator(),
                );
              }

              debugPrint(snapshot.data.toString());

              return ListView.separated(
                itemBuilder: (_, index) {
                  final parsedItem = snapshot.data![index];

                  return GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => RestaurantDetailScreen(
                            id: parsedItem.id,
                          ),
                        ),
                      );
                    },
                    child: RestaurantCard.fromModel(parsedItem),
                  );
                },
                separatorBuilder: (_, index) {
                  return SizedBox(height: 16);
                },
                itemCount: snapshot.data!.length,
              );
            },
          ),
        ),
      ),
    );
  }
}
