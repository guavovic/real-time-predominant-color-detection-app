/// Uma cor de referência com o nome que o aplicativo fala.
class NamedColor {
  const NamedColor(this.name, this.red, this.green, this.blue);

  final String name;
  final int red;
  final int green;
  final int blue;
}

/// Nomes curtos e familiares, em português, no estilo dos termos básicos do
/// ISCC-NBS: cada cor básica com "claro" e "escuro" onde faz diferença.
///
/// Um mesmo nome pode ter mais de uma cor de referência (o verde vivo, o verde
/// normal e o verde apagado, por exemplo), para a cor mais próxima ser
/// escolhida entre todas e o nome continuar o mesmo.
const List<NamedColor> portuguesePalette = <NamedColor>[
  NamedColor('preto', 15, 15, 15),
  NamedColor('cinza escuro', 75, 75, 75),
  NamedColor('cinza', 128, 128, 128),
  NamedColor('cinza claro', 190, 190, 190),
  NamedColor('branco', 248, 248, 248),
  NamedColor('vermelho', 214, 32, 38),
  NamedColor('vermelho escuro', 140, 20, 26),
  NamedColor('vinho', 100, 20, 45),
  NamedColor('rosa', 240, 110, 160),
  NamedColor('rosa claro', 250, 190, 208),
  NamedColor('rosa choque', 225, 30, 150),
  NamedColor('salmão', 250, 140, 115),
  NamedColor('laranja', 245, 125, 20),
  NamedColor('marrom', 125, 75, 35),
  NamedColor('marrom escuro', 68, 40, 22),
  NamedColor('marrom claro', 176, 128, 80),
  NamedColor('bege', 222, 200, 160),
  NamedColor('amarelo', 247, 215, 20),
  NamedColor('amarelo claro', 252, 236, 150),
  NamedColor('amarelo escuro', 190, 150, 20),
  NamedColor('verde-limão', 170, 215, 35),
  NamedColor('verde claro', 140, 210, 120),
  NamedColor('verde', 30, 170, 60),
  NamedColor('verde', 20, 225, 70),
  NamedColor('verde', 90, 135, 65),
  NamedColor('verde escuro', 20, 85, 40),
  NamedColor('verde-oliva', 105, 105, 35),
  NamedColor('turquesa', 40, 190, 185),
  NamedColor('azul claro', 135, 190, 240),
  NamedColor('azul', 25, 75, 225),
  NamedColor('azul escuro', 20, 40, 115),
  NamedColor('lilás', 190, 150, 225),
  NamedColor('roxo', 120, 55, 170),
  NamedColor('roxo escuro', 65, 25, 100),
];
