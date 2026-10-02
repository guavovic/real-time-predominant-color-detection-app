# 5. Detecção de objetos no aparelho, com modelo de licença permissiva

Data: 02/10/2026

Status: Aceito

## Contexto

O app precisa dizer o que há à frente: o objeto, onde está e de que cor. Para quem não enxerga a voz basta, e para quem enxerga pouco as caixas e os nomes na imagem também ajudam. A detecção tem de funcionar **sem internet** e **sem enviar a imagem para fora do aparelho**. Pretende-se publicar o app numa loja, de graça, mantendo a licença MIT do repositório.

## Opções consideradas

- **Pacote `ultralytics_yolo` (YOLO):** o mais rápido de integrar, mas é **AGPL-3.0**. Usar o pacote ou os modelos da Ultralytics obrigaria o app inteiro a ser AGPL, ou a comprar uma licença comercial. Descartado.
- **Google ML Kit:** simples e offline, mas as categorias são grossas (móvel, comida, planta), sem "cadeira" nem "garrafa", e sem uma caixa por objeto tão boa para a posição.
- **`tflite_flutter` com um modelo COCO de licença Apache 2.0:** classes específicas (80), caixa por objeto, tudo no aparelho e a licença MIT do repositório preservada. Dá mais trabalho: o pré-processamento e a tradução dos nomes são nossos.

## Decisão

- **`tflite_flutter` com o EfficientDet-Lite0 (COCO, Apache 2.0)**, versão do TensorFlow Hub com a etapa de escolha das caixas já dentro do modelo. Pesa 4,5 MB e vai dentro do app.
- Uma primeira tentativa com a versão do MediaPipe do mesmo modelo foi descartada: ela devolve as 19.206 caixas candidatas sem a etapa que escolhe as melhores.
- **Pré-processamento próprio:** o quadro da câmera (YUV, deitado, porque o sensor do Android é girado em 90 graus) é girado para ficar em pé, reduzido a 320 x 320 e convertido para RGB.
- **Nomes em português** das 80 classes (`labels_pt.dart`), na ordem do modelo.
- **Posição** pelo centro da caixa: terço da esquerda, do meio ou da direita.
- **Cor de cada objeto:** média da metade central da caixa, nos pixels já reduzidos, passando pelo `ColorNamer`. A fala diz "cor azul" para não precisar concordar o gênero com o objeto.
- **Caixas grossas e amarelas, com o nome em letra grande sobre fundo preto**, desenhadas por cima da imagem. Tocar na tela fala os três maiores objetos.
- O app fica só em **retrato**, para a caixa coincidir com a imagem sem cálculos de giro da tela.
- A detecção roda na thread principal, descartando os quadros que chegam enquanto o anterior ainda é analisado.
- Para o build do plugin com o Java 11 e o Kotlin 17, `kotlin.jvm.target.validation.mode=warning` em `android/gradle.properties`.

## Consequências

- Medido no Galaxy A05s (build de debug): cerca de **108 ms por quadro**, uns 9 quadros por segundo, suficiente para descrever o ambiente. No release deve ser menor. Se pesar na interface, o próximo passo é mover a análise para outra thread.
- Funcionou na prática: caixas no lugar, nomes certos e a voz dizendo o que está na tela. O modelo erra objetos que não são do COCO (um carregador de pilhas, uma guitarra e brinquedos de montar foram confundidos com outras coisas). Isso é um limite das 80 classes, não um defeito do código.
- Fica de fora desta etapa: quando e como falar sozinho, vibração, zoom e alto contraste (etapa de voz e acessibilidade) e a leitura de texto.
- A origem e a licença do modelo estão em `assets/models/ORIGEM.md`.
- Testado só no Android. No iOS o formato dos quadros é outro.
