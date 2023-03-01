import 'package:baedal/common/dio/vince_dio.dart';
import 'package:baedal/common/layout/default_layout.dart';
import 'package:baedal/product/component/product_card.dart';
import 'package:baedal/restaurant/component/restaurant_card.dart';
import 'package:baedal/restaurant/model/restaurant_detail_model.dart';
import 'package:baedal/restaurant/repository/restaurant_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../common/constant/data.dart';

class RestaurantDetailScreen extends ConsumerWidget {
  final String id;

  const RestaurantDetailScreen({
    Key? key,
    required this.id,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultLayout(
      title: '불타는 떡볶이',
      child: FutureBuilder<RestaurantDetailModel>(
        future: ref.watch(restaurantRepositoryProvider).getRestaurantDetail(id),
        builder: (context, AsyncSnapshot<RestaurantDetailModel> snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text(snapshot.error.toString()),
            );
          }

          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          final item = snapshot.data!;
          return CustomScrollView(
            slivers: [
              renderTop(item),
              renderLabel(),
              renderProducts(item.products),
            ],
          );
        },
      ),
    );
  }

  Widget renderTop(RestaurantDetailModel model) {
    return SliverToBoxAdapter(
      child: RestaurantCard.fromModel(
        model,
        isDetail: true,
      ),
    );
  }

  Widget renderLabel() {
    return SliverPadding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      sliver: SliverToBoxAdapter(
        child: Text(
          '메뉴',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }

  SliverPadding renderProducts(List<RestaurantProductModel> products) {
    return SliverPadding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final model = products[index];
            return Padding(
              padding: const EdgeInsets.only(top: 16),
              child: ProductCard.fromModel(model),
            );
          },
          childCount: products.length,
        ),
      ),
    );
  }
}
