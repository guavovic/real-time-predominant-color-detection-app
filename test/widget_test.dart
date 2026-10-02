import 'package:vera/camera/camera_screen.dart';
import 'package:vera/main.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final spoken = <String>[];

  setUp(() {
    spoken.clear();
    TestWidgetsFlutterBinding.ensureInitialized();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(const MethodChannel('flutter_tts'), (
          call,
        ) async {
          if (call.method == 'speak') {
            spoken.add(call.arguments as String);
          }
          return 1;
        });
  });

  testWidgets('abre direto na câmera', (tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.byType(CameraScreen), findsOneWidget);
  });

  testWidgets('sem câmera disponível, mostra e fala o aviso', (tester) async {
    await tester.pumpWidget(const MyApp());
    // O indicador de carregamento anima sem parar, então não dá pra "assentar".
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 200)),
    );
    await tester.pump();

    const aviso = 'Não foi possível abrir a câmera.';
    expect(find.text(aviso), findsOneWidget);
    expect(spoken, contains(aviso));
  });
}
