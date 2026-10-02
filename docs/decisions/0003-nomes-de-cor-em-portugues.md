# 3. Nomes de cor em português

Data: 01/10/2026

Status: Aceito

## Contexto

O app fala o nome da cor em voz alta, para quem não enxerga. O nome vinha do pacote `colornames`, que devolve nomes de uma lista em inglês e em outras línguas. Uma foto de um objeto roxo escuro foi chamada de **"Melanzane"**, que é "berinjela" em italiano, lida por uma voz em português. Para quem só ouve, isso não quer dizer nada. Além de não ser português, a lista é longa e tem nomes que ninguém usa.

## Opções consideradas

Como se costuma nomear cores em código:

- **Paleta curta e vizinho mais próximo em CIELAB.** Uma lista pequena de nomes, cada um com uma cor de referência. A cor medida recebe o nome da referência mais parecida, com a diferença perceptual CIEDE2000. É a forma mais comum, e a que o ISCC-NBS, o sistema de nomes mais próximo de um padrão, segue em essência: 13 termos básicos com modificadores como "claro" e "escuro".
- **Regras de matiz em HSL**, com faixas de matiz e adjetivos. Simples, mas erra onde a cor não é só matiz: marrom é laranja escuro, rosa é vermelho claro, bege é amarelo apagado. Cada exceção vira um remendo.
- **Dicionário grande traduzido** (xkcd, com cerca de 950 nomes, ou ntc.js, com 1,5 mil). Nomes ricos, mas muito para traduzir, a voz tropeça em nomes raros e a pessoa teria de memorizar centenas de termos.

## Decisão

Paleta curta de 32 referências e vizinho mais próximo em CIELAB com CIEDE2000, em Dart puro (sem depender do Flutter), em `lib/color`.

- Nomes familiares e curtos: preto, branco, cinza (claro e escuro), vermelho, vinho, rosa, salmão, laranja, marrom, bege, amarelo, verde, verde-limão, verde-oliva, turquesa, azul, lilás, roxo, com "claro" e "escuro" onde faz diferença.
- **Um nome pode ter mais de uma referência.** O primeiro teste com as cores puras mostrou que o azul e o verde vivos caíam em "roxo" e "verde-limão", porque a referência de cada um era mais escura. O verde ganhou três referências (vivo, normal e apagado, como o de folha) e o azul ficou mais saturado. A cor mais próxima entre todas decide, e o nome continua um só.
- A paleta foi calibrada com cerca de 80 cores de teste (cores do CSS, tons de pele e de céu, a berinjela do exemplo), olhando o nome que cada uma recebia.
- O `colornames` saiu do projeto. O app usa o `ColorNamer` para falar o nome, e `hexOf` fica pronto para mostrar o código na tela.

## Consequências

- O que o app fala agora é português e previsível: as cores puras e as básicas têm o nome que uma pessoa daria.
- Cores muito claras e pouco saturadas viram "branco" (um bege de papel de parede ou uma lavanda). Para quem só ouve, é aceitável. Se incomodar, a paleta ganha "off-white" e "creme", sem mudar o código.
- Azul acinzentado, como um céu nublado, vira "cinza claro". Um nome como "cinza azulado" seria uma referência a mais.
- A cor ainda vem do `palette_generator`, que será trocado na etapa da cor ao vivo. A paleta, o `ColorNamer` e os testes continuam valendo.
- A calibragem é do autor, em um aparelho e sob a luz dele. A luz do ambiente muda a cor que a câmera enxerga, e isso não é corrigido aqui.
