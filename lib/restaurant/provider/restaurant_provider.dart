import 'package:baedal/common/model/cursor_pagination_model.dart';
import 'package:baedal/common/model/pagination_params.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../model/restaurant_model.dart';
import '../repository/restaurant_repository.dart';

final restaurantDetailProvider =
    Provider.family<RestaurantModel?, String>((ref, id) {
  final state = ref.watch(restaurantProvider);
  if (state is! CursorPagination) {
    return null;
  }

  return state.data.firstWhere((element) => element.id == id);
});

final restaurantProvider =
    StateNotifierProvider<RestaurantStateNotifier, CursorPaginationBase>(
  (ref) {
    final repository = ref.watch(restaurantRepositoryProvider);
    final notifier = RestaurantStateNotifier(repository);

    return notifier;
  },
);

class RestaurantStateNotifier extends StateNotifier<CursorPaginationBase> {
  final RestaurantRepository repository;

  RestaurantStateNotifier(this.repository) : super(CursorPaginationLoading()) {
    paginate();
  }

  /// XXX: 이게 맞나?
  Future<void> paginate({
    int fetchCount = 20,
    bool fetchMore = false,
    bool forceRefetch = false,
  }) async {
    // 1) CursorPagination - 정상적으로 데이터 있는 상태
    // 2) CursorPaginationLoading - 데이터 로딩중 (캐시 X)
    // 3) CursorPaginationError
    // 4) CursorPaginationRefetching - 첨부터 다시
    // 5) CursorPaginationFetchMore - 추가로 갖고오기

    // 바로 반환
    // 1) hasMore == false (기존 상태에서 이미 x)
    // 2) 로딩중 - fetchMore: true
    //
    //          - fetchMore가 아닐때 -> 그냥 실행 (새로고침의 의도가 있을 수 있다 ?)

    try {
      if (state is CursorPagination && !forceRefetch) {
        final pState = state as CursorPagination;

        if (!pState.meta.hasMore) {
          return;
        }
      }

      final isLoading = state is CursorPaginationLoading;
      final isRefetching = state is CursorPaginationRefetching;
      final isFetchingMore = state is CursorPaginationFetchingMore;

      // 2)
      if (fetchMore && (isLoading || isRefetching || isFetchingMore)) {
        return;
      }

      /// PaginationParams 생성
      PaginationParams paginationParams = PaginationParams(
        count: fetchCount,
      );

      /// fetchMore - 데이터를 추가로 더
      if (fetchMore) {
        final pState = state as CursorPagination;
        state = CursorPaginationFetchingMore(
          meta: pState.meta,
          data: pState.data,
        );

        paginationParams = paginationParams.copyWith(
          after: pState.data.last.id,
        );
      } else {
        /// 데이터 처음부터
        /// 기존 데이터가 있으면 보존한채로 fetch
        if (state is CursorPagination && !forceRefetch) {
          final pState = state as CursorPagination;
          state = CursorPaginationRefetching(
            meta: pState.meta,
            data: pState.data,
          );
        } else {
          state = CursorPaginationLoading();
        }
      }

      final resp =
          await repository.paginate(paginationParams: paginationParams);

      if (state is CursorPaginationFetchingMore) {
        final pState = state as CursorPaginationFetchingMore;

        /// 기존 데이터에 새로운 데이터 추가
        state = resp.copyWith(data: [...pState.data, ...resp.data]);
      } else {
        state = resp;
      }
    } catch (e) {
      state = CursorPaginationError("데이터를 가져오지 못했습니다.");
    }
  }

  void getDetail(String id) async {
    /// 데이터가 하나도 없는 상태 (CursorPagination이 아니면)
    /// 데이터 가져오는 시도
    if (state is! CursorPagination) {
      await paginate();
    }

    /// state가 CursorPagination이 아닐 때 -> 그냥 return
    if (state is! CursorPagination) {
      return;
    }

    final pState = state as CursorPagination;
    final resp = await repository.getRestaurantDetail(id);

    state = pState.copyWith(
      data: pState.data
          .map<RestaurantModel>((e) => e.id == id ? resp : e)
          .toList(),
    );
  }
}
