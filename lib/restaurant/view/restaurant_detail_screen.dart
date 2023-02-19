import 'package:baedal/common/layout/default_layout.dart';
import 'package:baedal/product/component/product_card.dart';
import 'package:baedal/restaurant/component/restaurant_card.dart';
import 'package:flutter/material.dart';

class RestaurantDetailScreen extends StatelessWidget {
  const RestaurantDetailScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DefaultLayout(
      title: '불타는 떡볶이',
      child: CustomScrollView(
        slivers: [
          renderTop(),
          renderLabel(),
          renderProducts(),
        ],
      ),

      // Column(
      //   children: [
      //     RestaurantCard(
      //       image: Image.asset(
      //         'asset/img/food/ddeok_bok_gi.jpg',
      //       ),
      //       name: '불타는 떡볶이',
      //       tags: ['떡볶이', '맛있음', '치즈'],
      //       ratingsCount: 100,
      //       deliveryTime: 300,
      //       deliveryFee: 3000,
      //       ratings: 4.7,
      //       isDetail: true,
      //       detail: '맛있는 떡볶이',
      //     ),
      //     Padding(
      //       padding: const EdgeInsets.symmetric(horizontal: 16),
      //       child: ProductCard(),
      //     ),
      //   ],
      // ),
    );
  }

  Widget renderTop() {
    return SliverToBoxAdapter(
      child: RestaurantCard(
        image: Image.asset(
          'asset/img/food/ddeok_bok_gi.jpg',
        ),
        name: '불타는 떡볶이',
        tags: ['떡볶이', '맛있음', '치즈'],
        ratingsCount: 100,
        deliveryTime: 300,
        deliveryFee: 3000,
        ratings: 4.7,
        isDetail: true,
        detail: '맛있는 떡볶이',
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

  SliverPadding renderProducts() {
    return SliverPadding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            return Padding(
              padding: const EdgeInsets.only(top: 16),
              child: ProductCard(),
            );
          },
          childCount: 10,
        ),
      ),
    );
  }
}
