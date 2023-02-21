import 'package:baedal/restaurant/model/restaurant_model.dart';
import 'package:dio/dio.dart' hide Headers;
import 'package:retrofit/retrofit.dart';

import '../../common/model/cursor_pagination_model.dart';
import '../model/restaurant_detail_model.dart';

part 'restaurant_repository.g.dart';

@RestApi()
abstract class RestaurantRepository {
  /// http://$ip/restaurant
  factory RestaurantRepository(Dio dio, {String baseUrl}) =
      _RestaurantRepository;

  @GET('/')
  @Headers({
    'accessToken': 'true',
  })
  Future<CursorPagination<RestaurantModel>> paginate();

  @GET('/{id}')
  @Headers({
    'accessToken': 'true',
  })
  Future<RestaurantDetailModel> getRestaurantDetail(
    @Path() String id,
  );
}
