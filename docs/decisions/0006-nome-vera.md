# 6. O app se chama Vera

Data: 02/10/2026

Status: Aceito

## Contexto

O projeto nasceu como um trabalho de faculdade que tirava uma foto e dizia o nome da cor, e por isso se chamava `camera_cor_destaque` no código e WhatColor na tela. O app de agora é outro: mantém a câmera aberta e descreve em voz alta o que há à frente, com a posição e a cor de cada coisa. A cor virou um detalhe, e o nome antigo deixou de descrever o que ele faz.

Como a voz que fala é feminina, o nome pode ser o de uma pessoa, no mesmo caminho dos assistentes de voz. Ele também precisa ser curto, fácil de falar e de buscar, e funcionar bem num leitor de tela.

## Decisão

O app se chama **Vera**.

- Soa como o verbo "ver" e vem do latim *verus*, "verdadeira".
- Tem quatro letras, sem acento, e é simples de pronunciar e de digitar.
- Foram descartados nomes que já são apps conhecidos (como Luzia, um assistente de IA) e nomes parecidos com apps de acessibilidade existentes.
- No código, o pacote Dart passa a ser `vera`, e o identificador do aplicativo, `com.guavovic.vera`, no Android e no iOS.

## Consequências

- O repositório passa a se chamar `vera`, e o GitHub redireciona o endereço antigo.
- Os identificadores antigos (`com.example...`) nunca foram publicados, então trocar agora não quebra nenhuma instalação além das de teste.
- Antes de publicar na loja, é preciso confirmar que o nome está livre lá.
