# 1. Flutter atual e Android primeiro

Data: 01/10/2026

Status: Aceito

## Contexto

O projeto vinha de um trabalho de faculdade de 2022 e 2023. O repositório tinha o app copiado em quatro pastas, com `build/`, `local.properties` e `.iml` versionados, e pesava 77 MB. As pastas `android` e `ios` eram de um Flutter antigo (Android Gradle Plugin 7.3, Kotlin 1.7) e não compilam no Flutter de hoje. O Android não declarava permissão de câmera, e o iOS não trazia a descrição de uso da câmera, que o sistema exige. O `pubspec` listava pacotes que o código nunca usou (`speech_to_text`, `google_speech`, `flutter_colorpicker` e `camera`).

## Decisão

- **Flutter 3.47 (Dart 3.13).** As pastas `android` e `ios` foram regeneradas com o Flutter atual, em vez de remendadas.
- **Android primeiro.** É a plataforma que o autor tem para testar (um celular Android). O `ios` foi regenerado e ganhou a descrição de uso da câmera, mas não é compilado nem testado, porque não há um Mac. O README diz que o app foi testado só no Android.
- **Só as dependências usadas:** `flutter_tts`, `image_picker`, `image`, `palette_generator` e `colornames`, nas versões mais novas. As que faltarem entram junto de quem as usa, nas próximas etapas.
- **Análise rígida** (`strict-casts`, `strict-inference`, `strict-raw-types`, mais algumas regras do `flutter_lints`), com `flutter analyze` sem nenhum aviso.
- **Histórico reescrito** com `git filter-repo`: ficou só o projeto da raiz, sem as cópias, o `build/`, o `local.properties` e os `.iml`. De 77 MB para 214 KB, com um backup espelhado feito antes. Os commits antigos ainda abrem no GitHub pelo hash até a coleta de lixo deles.
- O `main.dart` foi limpo mantendo o comportamento (tocar, foto, cor dominante, fala): sem os campos que não eram usados, e com o erro ao fechar a tela corrigido (o `dispose` chamava `dispose` e `cancel` em campos que nunca eram criados).

## Consequências

- O app compila e passa na análise e nos testes com o Flutter atual.
- Quem clonar baixa poucos KB, em vez de 77 MB.
- No iOS, nada foi verificado. Antes de prometer iOS é preciso compilar em um Mac ou no CI da Apple.
- O `flutter_tts` (a voz) usa um plugin Gradle do Kotlin que o Flutter já avisa que deixará de aceitar em versões futuras. Hoje compila só com o aviso. Se o pacote não migrar a tempo, a voz precisa de outro pacote ou de uma chamada direta ao Android.
