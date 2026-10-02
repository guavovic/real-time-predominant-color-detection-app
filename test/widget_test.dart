import 'package:camera_cor_destaque/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('mostra o título e a instrução da tela inicial', (tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('WhatColor'), findsOneWidget);
    expect(find.text('Clique na tela para tirar uma foto'), findsOneWidget);
  });

  testWidgets('não mostra cor antes da primeira foto', (tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.textContaining('Cor detectada'), findsNothing);
    expect(find.byType(Scaffold), findsOneWidget);
  });
}
