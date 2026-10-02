# Vera

Aplicativo de celular, feito para pessoas cegas e com baixa visão, que diz em voz alta o que a câmera está apontando. Você aponta, e a Vera mostra na tela e fala o que há à frente: o objeto, onde ele está e de que cor é.

Começou como um trabalho de faculdade que só dizia o nome da cor de uma foto. Hoje ele funciona ao vivo e continua em desenvolvimento.

## Como foi feito

A primeira versão era um arquivo só, com o projeto copiado em quatro pastas dentro do repositório. A Vera foi reconstruída em etapas, cada uma com a decisão registrada num ADR:

- **Câmera ao vivo**, dentro do app, que entrega os quadros para análise sem tirar foto.
- **Objetos reconhecidos no próprio aparelho**, sem internet e sem enviar imagem para fora, com os nomes em português e a posição de cada um.
- **Nomes de cor em português**, escolhidos pela referência mais próxima no espaço de cor CIELAB, que se aproxima de como a gente percebe as cores.
- **Voz e tela juntas**, com letra grande e caixas de alto contraste para quem enxerga um pouco.
- **Testes e CI** a cada mudança, com análise do código, testes e compilação do aplicativo.

## Tecnologias

- **Aplicativo:** Flutter e Dart, no Android.
- **Reconhecimento de objetos:** TensorFlow Lite, com o modelo EfficientDet-Lite0.
- **Voz:** síntese de voz do aparelho, em português do Brasil.
- **Entrega:** GitHub Actions.

## Documentação

- [Decisões de arquitetura](docs/decisions): o porquê de cada escolha, com as alternativas consideradas.
