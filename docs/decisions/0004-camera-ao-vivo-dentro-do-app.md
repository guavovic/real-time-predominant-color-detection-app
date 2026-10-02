# 4. Câmera ao vivo dentro do app

Data: 01/10/2026

Status: Aceito

## Contexto

O app tirava uma foto pela câmera do sistema (`image_picker`), esperava o retorno e só então dizia a cor. Para descrever o que há à frente em tempo real, a câmera precisa ficar aberta dentro do app, entregando quadros que possam ser analisados. O público inclui pessoas cegas e com baixa visão, então a imagem aparece na tela e o resultado também sai por voz.

## Decisão

- **Pacote `camera`**, com a câmera traseira e o fluxo de quadros (`startImageStream`) em YUV 4:2:0, o formato nativo do Android, sem conversão extra.
- **Tela cheia**, com o resultado em letra grande sobre fundo preto, e rótulo para o leitor de tela.
- **Tocar na tela** fala a cor da região central do último quadro, que passa pelo `ColorNamer`. A conversão de YUV para RGB é uma função pura (`yuvToRgb`), com testes.
- **Falhas faladas:** sem permissão, sem câmera ou erro ao abrir, o app mostra e fala a mensagem em português. Quem não enxerga não teria como perceber uma tela vazia.
- **Ciclo de vida:** a câmera é liberada ao ir para segundo plano e reaberta ao voltar.
- **A permissão** de câmera foi declarada no Android. Quem pede ao usuário é o próprio pacote.
- Saíram `image_picker`, `palette_generator` e `image`, que deixaram de ser usados.

## Consequências

- O fluxo de quadros já está aberto para a detecção de objetos, a próxima etapa.
- O quadrado central é pequeno de propósito, para refletir o que está no meio da imagem.
- Testado no Android (Galaxy A05s). No iOS o formato dos quadros é outro (BGRA), então a cor do centro não funcionaria ali sem ajuste.
