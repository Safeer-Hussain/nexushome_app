import 'dart:async';
import 'dart:math';

import 'package:dio/dio.dart';

class MockDioInterceptor extends Interceptor {
  int minLatencyMs;
  int maxLatencyMs;
  bool forceHttp503Error;

  MockDioInterceptor({
    this.minLatencyMs = 400,
    this.maxLatencyMs = 850,
    this.forceHttp503Error = false,
  });

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final randomLatency =
        minLatencyMs + Random().nextInt(max(1, maxLatencyMs - minLatencyMs));
    await Future.delayed(Duration(milliseconds: randomLatency));

    if (forceHttp503Error) {
      return handler.reject(
        DioException(
          requestOptions: options,
          response: Response(
            requestOptions: options,
            statusCode: 503,
            statusMessage:
                'Service Unavailable - Simulated Cloud Grid Sync Outage',
            data: {'error': 'Simulated Cloud Grid Sync Outage', 'code': 503},
          ),
          type: DioExceptionType.badResponse,
        ),
      );
    }

    // Handle mock API endpoints
    if (options.path.contains('/api/v1/grid/telemetry')) {
      final mockResponse = Response(
        requestOptions: options,
        statusCode: 200,
        data: {
          'status': 'HEALTHY',
          'gridStatus': 'SYNCHRONIZED',
          'frequencyHz': 50.02,
          'tariffWindow': 'OFF_PEAK',
          'carbonIntensityGPerKwh': 184,
        },
      );
      return handler.resolve(mockResponse);
    }

    if (options.path.contains('/api/v1/matter/diagnostics')) {
      final mockResponse = Response(
        requestOptions: options,
        statusCode: 200,
        data: {
          'meshHealth': 'OPTIMAL',
          'activePartitions': 1,
          'borderRouterAddress': 'fdde:ad11:11de:0:1',
          'threadVersion': 'Thread 1.3.0',
        },
      );
      return handler.resolve(mockResponse);
    }

    return handler.next(options);
  }
}
