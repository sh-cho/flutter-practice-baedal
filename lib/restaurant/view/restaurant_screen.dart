import 'package:baedal/common/model/cursor_pagination_model.dart';
import 'package:baedal/restaurant/component/restaurant_card.dart';
import 'package:baedal/restaurant/provider/restaurant_provider.dart';
import 'package:baedal/restaurant/view/restaurant_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class RestaurantScreen extends ConsumerStatefulWidget {
  const RestaurantScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<RestaurantScreen> createState() => _RestaurantScreenState();
}

class _RestaurantScreenState extends ConsumerState<RestaurantScreen> {
  final ScrollController controller = ScrollController();

  @override
  void initState() {
    super.initState();

    controller.addListener(scrollListener);
  }

  void scrollListener() {
    /// 현재 위치가 맨 끝 약간전에 왔다면, 새로운 데이터 추가요청
    // debugPrint('${controller.offset} ${controller.position.maxScrollExtent}');

    if (controller.offset > controller.position.maxScrollExtent - 300) {
      ref.read(restaurantProvider.notifier).paginate(fetchMore: true);
    }
  }

  @override
  void dispose() {
    controller.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final data = ref.watch(restaurantProvider);

    /// 완전 처음 로딩
    if (data is CursorPaginationLoading) {
      return Center(
        child: CircularProgressIndicator(),
      );
    }

    /// 에러
    if (data is CursorPaginationError) {
      return Center(
        child: Text(data.message),
      );
    }

    /// CursorPagination
    /// CursorPaginationFetchingMore
    /// CursorPaginationRefetching
    final cp = data as CursorPagination; // temp

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView.separated(
        controller: controller,
        itemCount: cp.data.length + 1,
        itemBuilder: (_, index) {
          if (index == cp.data.length) {
            return Center(
              child: data is CursorPaginationFetchingMore
                  ? CircularProgressIndicator()
                  : Text('더이상 없어요'),
            );
          }

          final parsedItem = cp.data[index];

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
      ),
    );
  }
}
