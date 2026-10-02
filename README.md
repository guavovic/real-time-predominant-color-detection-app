# WhatColor

Aplicativo de celular, feito como trabalho de faculdade, para ajudar pessoas cegas a saberem o que a câmera está apontando. Hoje ele tira uma foto, descobre a cor dominante e diz o nome da cor em voz alta, em português.

A segunda versão está sendo refeita para funcionar em tempo real e dizer também o que tem à frente da câmera.

## Como foi feito

A primeira versão era um arquivo só, com o projeto copiado em quatro pastas dentro do repositório, sem permissão de câmera declarada e com um erro ao fechar a tela. A segunda está sendo reconstruída em etapas, cada uma com a decisão registrada num ADR.

## Tecnologias

- **Aplicativo:** Flutter e Dart, no Android.
- **Voz:** síntese de voz do aparelho, em português do Brasil.
- **Entrega:** GitHub Actions, com análise, testes e compilação a cada mudança.

## Documentação

- [Decisões de arquitetura](docs/decisions): o porquê de cada escolha, com as alternativas consideradas.
