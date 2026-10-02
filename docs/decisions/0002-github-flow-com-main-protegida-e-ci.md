# 2. GitHub Flow com main protegida e CI

Data: 01/10/2026

Status: Aceito

## Contexto

Toda mudança era commitada direto na `main`, sem nada conferindo se o app ainda compilava. O projeto tem uma pessoa só mantendo. A v1 é o app como foi entregue na faculdade, e as mudanças a partir desta decisão formam a v2.

## Opções consideradas

- **Git Flow**, com uma branch `develop` de vida longa. Feito para várias versões em suporte ao mesmo tempo e para times maiores.
- **GitHub Flow**: a `main` está sempre pronta, cada mudança vai numa branch curta e entra por pull request.
- **Trunk-based** com commit direto na `main`. Rápido, mas abre mão da PR como registro de cada mudança.

## Decisão

GitHub Flow.

- Toda mudança vai numa branch própria (`feat/...`, `fix/...`, `chore/...`) e entra na `main` por pull request. Só se aceita *squash*, e a branch é apagada depois.
- A `main` é protegida: PR obrigatória, e o check `Build` precisa passar com a branch atualizada. A regra vale também para administradores, sem force push.
- O CI (`.github/workflows/ci.yml`) roda no Linux, em toda PR e em todo push na `main`: `flutter pub get`, `flutter analyze`, `flutter test` e `flutter build apk --debug`. Aviso da análise quebra o build.
- O Dependabot acompanha os pacotes do Dart, o Gradle e as Actions uma vez por mês, com minor e patch agrupados e as major em PRs separadas. As correções de segurança chegam na hora, pelos alertas do GitHub.
- As versões são tags na `main`, e a v2 sai como tag quando a trilha fechar.

## Consequências

- A `main` só recebe código que passa na análise, nos testes e compila.
- Cada mudança tem uma pull request explicando o que faz e como foi testada.
- O CI não cobre o iOS nem roda o app num aparelho: a captura da câmera e a voz são conferidas à mão, no celular.
