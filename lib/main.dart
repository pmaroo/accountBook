import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app/app.dart';
import 'app/app_controller.dart';

export 'app/app.dart';

/// 앱 진입점
/// 
/// Flutter 앱의 메인 함수로, 앱 초기화 및 실행을 담당합니다.
void main() async {
  // Flutter 바인딩 초기화 (비동기 작업 전 필수)
  WidgetsFlutterBinding.ensureInitialized();

  // 시스템 UI 설정
  await _configureSystemUI();

  // 앱 컨트롤러 미리 생성 (스플래시 화면에서 로딩 표시용)
  final controllerFuture = AppController.create();

  // 앱 실행
  runApp(MoneyBookApp(controllerFuture: controllerFuture));
}

/// 시스템 UI 설정
/// 
/// 상태바 스타일, 화면 방향 등 시스템 레벨 UI를 구성합니다.
Future<void> _configureSystemUI() async {
  // 상태바 스타일 설정 (라이트 모드 기준)
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  // 화면 방향 고정 (세로 모드만 허용)
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
}

/// 앱 재시작 유틸리티
/// 
/// 설정 변경 등으로 앱을 재시작해야 할 때 사용합니다.
class AppRestarter {
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  
  /// 앱 전체를 재시작합니다.
  static void restart() {
    navigatorKey.currentState?.pushAndRemoveUntil(
      MaterialPageRoute<void>(
        builder: (_) => FutureBuilder<AppController>(
          future: AppController.create(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }
            return MoneyBookApp(controllerFuture: Future.value(snapshot.data));
          },
        ),
      ),
      (_) => false,
    );
  }
}
