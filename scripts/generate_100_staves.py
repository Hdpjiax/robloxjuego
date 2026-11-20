# scripts/generate_100_staves.py
# Genera el catálogo completo de 100 bastones únicos en src/shared/StavesData.luau
import os

staves = []

# --- 1. COMÚN (25 Bastones: Tier 1-2, Mult x1.0 - x2.8, Daño 12-35) ---
comunes = [
    ("VaraDeAprendiz", "Vara de Aprendiz", 1, 1.0, 12, "Madera de pino con núcleo de chispa básica.", "WoodPlanks", "(62, 40, 28)", 4.6, "Ball", "Neon", "(0, 235, 255)", 0, 0, 0),
    ("BastonDeRobleArcano", "Bastón de Roble Arcano", 1, 1.2, 15, "Madera de roble centenario impregnada de savia mágica.", "Wood", "(75, 50, 32)", 4.5, "Ball", "Glass", "(20, 255, 110)", 8, 0, 15),
    ("VaraDeSauceUmbrio", "Vara de Sauce Umbrío", 1, 1.3, 17, "Rama flexible de sauce que absorbe la bruma matutina.", "Wood", "(55, 45, 38)", 4.4, "Cylinder", "SmoothPlastic", "(140, 200, 255)", 12, 0, 25),
    ("BastonDeAbedulBlanco", "Bastón de Abedul Blanco", 1, 1.4, 19, "Madera clara y suave que canaliza brisas ligeras.", "SmoothPlastic", "(220, 215, 200)", 4.6, "Ball", "Neon", "(255, 255, 255)", 15, 0, 35),
    ("VaraDeAvellanoSilvestre", "Vara de Avellano Silvestre", 1, 1.5, 21, "Corta y resistente, ideal para principiantes de la alquimia.", "Wood", "(85, 58, 36)", 4.3, "Ball", "Neon", "(255, 210, 80)", 18, 0, 50),
    ("BastonDeFresnoRunico", "Bastón de Fresno Rúnico", 1, 1.6, 23, "Fresno silvestre grabado con marcas de aprendiz.", "WoodPlanks", "(70, 52, 40)", 4.7, "Ball", "Glass", "(0, 220, 200)", 22, 0, 65),
    ("VaraDeCannaDeRio", "Vara de Caña de Río", 1, 1.7, 25, "Caña marina ligera pulida por el agua del arroyo.", "Wood", "(110, 120, 70)", 4.5, "Ball", "Neon", "(80, 230, 255)", 25, 0, 80),
    ("BastonDeEspinoSalvaje", "Bastón de Espino Salvaje", 1, 1.8, 27, "Cargado de diminutas púas que aumentan el filo del proyectil.", "Wood", "(65, 40, 30)", 4.6, "Cylinder", "Neon", "(255, 100, 80)", 30, 0, 100),
    ("VaraDeTejoAntiguo", "Vara de Tejo Antiguo", 1, 1.9, 29, "Madera oscura que retiene los ecos de encantamientos pasados.", "Wood", "(45, 32, 26)", 4.8, "Ball", "Glass", "(180, 140, 255)", 35, 0, 120),
    ("BastonDeCastañoDorado", "Bastón de Castaño Dorado", 2, 2.0, 31, "Castaño pulido con anillos dorados de cobre.", "WoodPlanks", "(90, 60, 35)", 4.6, "Ball", "Neon", "(255, 200, 50)", 40, 0, 140),
    ("VaraDeOlmoEncantado", "Vara de Olmo Encantado", 2, 2.1, 32, "Resiste fuertes ráfagas de maná sin fracturarse.", "Wood", "(72, 54, 38)", 4.5, "Ball", "SmoothPlastic", "(100, 240, 180)", 45, 0, 160),
    ("BastonDeNogalNegro", "Bastón de Nogal Negro", 2, 2.2, 33, "Madera densa que enfoca los impactos mágicos.", "Wood", "(38, 28, 24)", 4.7, "Ball", "Neon", "(200, 100, 255)", 50, 0, 180),
    ("VaraDePinoPlateado", "Vara de Pino Plateado", 2, 2.3, 34, "Corteza pálida que refleja la luz estelar tenue.", "WoodPlanks", "(160, 165, 175)", 4.6, "Ball", "Glass", "(200, 235, 255)", 55, 0, 200),
    ("BastonDeCipresMistico", "Bastón de Ciprés Místico", 2, 2.4, 35, "Canaliza hechizos defensivos y proyectiles veloces.", "Wood", "(60, 55, 40)", 4.5, "Ball", "Neon", "(60, 255, 210)", 60, 0, 220),
    ("VaraDeAlisoPuro", "Vara de Aliso Puro", 2, 2.45, 35, "Vara equilibrada que reacciona con chispas de colores.", "Wood", "(80, 50, 38)", 4.4, "Ball", "Neon", "(255, 170, 70)", 65, 0, 240),
    ("BastonDeMaderaPetrificada", "Bastón de Madera Petrificada", 2, 2.5, 36, "Ramas fósiles endurecidas por milenios de presión.", "Basalt", "(50, 48, 52)", 4.6, "Ball", "Neon", "(140, 150, 165)", 70, 0, 260),
    ("VaraDeSaucoComun", "Vara de Saúco Común", 2, 2.55, 36, "Hermana menor de las legendarias varas de saúco.", "WoodPlanks", "(68, 48, 36)", 4.5, "Ball", "Glass", "(255, 230, 120)", 75, 0, 280),
    ("BastonDeHiedraTrenzada", "Bastón de Hiedra Trenzada", 2, 2.6, 37, "Tres ramas delgadas enrolladas en espiral viva.", "Wood", "(58, 64, 42)", 4.6, "Ball", "Neon", "(90, 255, 120)", 80, 0, 300),
    ("VaraDeCerezoSilvestre", "Vara de Cerezo Silvestre", 2, 2.65, 37, "Madera rojiza aromática con pétalos de maná flotantes.", "Wood", "(92, 42, 38)", 4.5, "Ball", "Neon", "(255, 130, 170)", 85, 0, 320),
    ("BastonDeAceboInvernal", "Bastón de Acebo Invernal", 2, 2.7, 38, "Frescura gélida concentrada en la empuñadura.", "SmoothPlastic", "(210, 215, 220)", 4.7, "Ball", "Glass", "(110, 210, 255)", 90, 0, 340),
    ("VaraDeLentiscoRocoso", "Vara de Lentisco Rocoso", 2, 2.72, 38, "Recolectada en los acantilados del Valle Mágico.", "Wood", "(76, 58, 44)", 4.4, "Ball", "Neon", "(240, 190, 90)", 95, 0, 360),
    ("BastonDeSecuoyaNoble", "Bastón de Secuoya Noble", 2, 2.75, 39, "Porte imponente con madera de grano rojizo.", "WoodPlanks", "(105, 45, 32)", 4.9, "Ball", "Glass", "(255, 110, 70)", 100, 0, 380),
    ("VaraDePalmaCostera", "Vara de Palma Costera", 2, 2.78, 39, "Fibra marina trenzada que dispara chorros de energía.", "Wood", "(98, 76, 48)", 4.5, "Ball", "Neon", "(0, 220, 240)", 105, 0, 400),
    ("BastonDeBambuVerde", "Bastón de Bambú Verde", 2, 2.8, 40, "Ultra ligero y veloz para lanzar ráfagas rítmicas.", "SmoothPlastic", "(75, 130, 55)", 4.5, "Ball", "Neon", "(120, 255, 90)", 110, 0, 420),
    ("VaraDeSerbalSagrado", "Vara de Serbal Sagrado", 2, 2.85, 40, "Ahuyenta los malos augurios con una gema perlada.", "Wood", "(70, 50, 40)", 4.6, "Ball", "Neon", "(255, 245, 210)", 115, 0, 450),
]

# --- 2. POCO COMÚN (25 Bastones: Tier 3-4, Mult x3.0 - x8.5, Daño 42-95) ---
poco_comunes = [
    ("BastonDeCobreRunico", "Bastón de Cobre Rúnico", 3, 3.2, 45, "Engarces de cobre puro que amplifican la corriente mágica.", "Metal", "(180, 110, 65)", 4.6, "Ball", "Neon", "(255, 140, 50)", 130, 5, 500),
    ("VaraDeBronceTemplado", "Vara de Bronce Templado", 3, 3.5, 48, "Forjada en yunque y templada en agua arcana.", "Metal", "(160, 125, 75)", 4.5, "Cylinder", "Glass", "(255, 180, 70)", 140, 8, 550),
    ("CetroDePedernalIgneo", "Cetro de Pedernal Ígneo", 3, 3.8, 52, "Al chocar con el aire desprende chispas de fuego vivas.", "Basalt", "(40, 36, 42)", 4.7, "Ball", "Neon", "(255, 80, 20)", 150, 10, 600),
    ("BastonDeEscarchaMenor", "Bastón de Escarcha Menor", 3, 4.0, 55, "Cristaliza el suelo al apoyar la contera.", "Marble", "(200, 225, 245)", 4.6, "Ball", "Glass", "(100, 210, 255)", 160, 12, 650),
    ("VaraDeHierroForjado", "Vara de Hierro Forjado", 3, 4.3, 58, "Sólida y pesada, dispara proyectiles de choque contundente.", "Metal", "(85, 88, 95)", 4.8, "Cylinder", "Neon", "(220, 220, 240)", 170, 15, 700),
    ("BastonDeCuarzoAhumado", "Bastón de Cuarzo Ahumado", 3, 4.6, 62, "Gema translúcida que disimula la trayectoria del hechizo.", "WoodPlanks", "(65, 45, 32)", 4.6, "Ball", "Glass", "(140, 120, 110)", 180, 18, 750),
    ("VaraDeChispasVoltaicas", "Vara de Chispas Voltaicas", 3, 4.9, 65, "Pequeñas descargas eléctricas bailan entre sus anillos.", "Metal", "(110, 115, 130)", 4.5, "Ball", "Neon", "(80, 210, 255)", 190, 20, 800),
    ("CetroDeAmatistaSilvestre", "Cetro de Amatista Silvestre", 3, 5.2, 68, "Punta de amatista natural sin pulir con brillo violeta.", "Marble", "(45, 35, 55)", 4.7, "Ball", "Neon", "(190, 110, 255)", 200, 22, 850),
    ("BastonDeMusgoLuminoso", "Bastón de Musgo Luminoso", 3, 5.5, 71, "Cubierto de líquenes mágicos que brillan en la penumbra.", "Wood", "(48, 62, 40)", 4.6, "Ball", "Neon", "(70, 255, 140)", 210, 25, 900),
    ("VaraDeObsidianaBruta", "Vara de Obsidiana Bruta", 3, 5.8, 74, "Filos de vidrio volcánico negro con reflejos oscuros.", "Basalt", "(25, 24, 28)", 4.7, "Ball", "Neon", "(180, 80, 240)", 220, 28, 950),
    ("CetroDeAmbarCalido", "Cetro de Ámbar Cálido", 4, 6.0, 77, "Encierra una lágrima de resina fósil milenaria.", "WoodPlanks", "(85, 55, 30)", 4.6, "Ball", "Glass", "(255, 160, 30)", 230, 30, 1000),
    ("BastonDePiedraLunar", "Bastón de Piedra Lunar", 4, 6.3, 80, "Refleja el resplandor de la medianoche sobre la niebla.", "Marble", "(215, 220, 235)", 4.8, "Ball", "Neon", "(180, 220, 255)", 240, 32, 1100),
    ("VaraDeSulfuroArdiente", "Vara de Sulfuro Ardiente", 4, 6.6, 82, "Huele a azufre y ceniza volcánica cuando dispara.", "Basalt", "(50, 42, 35)", 4.6, "Ball", "Neon", "(255, 190, 40)", 250, 35, 1200),
    ("BastonDeCoralAbisal", "Bastón de Coral Abisal", 4, 6.9, 84, "Extraído de los arrecifes sumergidos del Mar Olvidado.", "Marble", "(160, 60, 70)", 4.5, "Ball", "Neon", "(255, 100, 130)", 260, 38, 1300),
    ("VaraDeMalaquitaVerde", "Vara de Malaquita Verde", 4, 7.2, 86, "Anillos concéntricos verdes que condensan energía vital.", "Marble", "(32, 68, 48)", 4.7, "Ball", "Glass", "(40, 240, 130)", 270, 40, 1400),
    ("CetroDeLapisLazuli", "Cetro de Lapislázuli", 4, 7.4, 88, "Azul ultramar moteado de chispas doradas de pirita.", "Marble", "(30, 48, 110)", 4.6, "Ball", "Neon", "(60, 130, 255)", 280, 42, 1500),
    ("BastonDeAceroTemplado", "Bastón de Acero Templado", 4, 7.6, 90, "Forjado para resistir golpes cuerpo a cuerpo y hechizos.", "Metal", "(120, 125, 135)", 4.8, "Cylinder", "Glass", "(200, 225, 255)", 290, 45, 1600),
    ("VaraDeGranitoGris", "Vara de Granito Gris", 4, 7.8, 91, "Pesada y firme, genera ondas de choque terrestres.", "Cobblestone", "(75, 78, 85)", 4.7, "Ball", "Neon", "(180, 185, 200)", 300, 48, 1700),
    ("BastonDeTopacioDorado", "Bastón de Topacio Dorado", 4, 8.0, 92, "Filtra la luz del sol transformándola en rayos penetrantes.", "Metal", "(140, 110, 60)", 4.6, "Ball", "Neon", "(255, 215, 60)", 310, 50, 1800),
    ("VaraDeSerpentina", "Vara de Serpentina", 4, 8.1, 93, "Escamas grabadas que aumentan la velocidad de ataque.", "Marble", "(45, 75, 52)", 4.5, "Ball", "Neon", "(60, 255, 160)", 320, 52, 1900),
    ("CetroDeOjoDeTigre", "Cetro de Ojo de Tigre", 4, 8.2, 93, "Ondulaciones pardas y doradas con visión de puntería.", "WoodPlanks", "(95, 65, 35)", 4.6, "Ball", "Glass", "(230, 160, 50)", 330, 55, 2000),
    ("BastonDeZafiroPálido", "Bastón de Zafiro Pálido", 4, 8.3, 94, "Canaliza lluvia de hielo ligero con gran alcance.", "Marble", "(70, 95, 140)", 4.7, "Ball", "Neon", "(110, 180, 255)", 340, 58, 2100),
    ("VaraDeMaderaDeEspíritus", "Vara de Madera de Espíritus", 4, 8.4, 94, "Las almas del bosque guían el proyectil al objetivo.", "Wood", "(62, 50, 60)", 4.6, "Ball", "Neon", "(160, 120, 255)", 350, 60, 2200),
    ("BastonDeMarmolGris", "Bastón de Mármol Gris", 4, 8.45, 95, "Tallado en una sola pieza en las canteras del este.", "Marble", "(130, 135, 145)", 4.8, "Ball", "Glass", "(220, 230, 245)", 360, 62, 2300),
    ("CetroDePiritaRadiante", "Cetro de Pirita Radiante", 4, 8.5, 95, "Reflejos de oro brillante con estallidos ensordecedores.", "Metal", "(160, 145, 80)", 4.6, "Ball", "Neon", "(255, 230, 90)", 370, 65, 2400),
]

# --- 3. RARO (20 Bastones: Tier 5-6, Mult x10.0 - x35.0, Daño 110-320) ---
raros = [
    ("CetroDeJadeAncestral", "Cetro de Jade Ancestral", 5, 10.0, 110, "Jade tallado por monjes milenarios con flujo vital continuo.", "Marble", "(30, 75, 55)", 4.8, "Ball", "Neon", "(0, 245, 180)", 400, 75, 3000),
    ("BastonDeFuegoVolcanico", "Bastón de Fuego Volcánico", 5, 12.0, 125, "Lava fundida en su interior lista para estallar en llamas.", "Basalt", "(35, 22, 25)", 4.7, "Ball", "Neon", "(255, 70, 20)", 430, 85, 3400),
    ("VaraDeTormentaElectrica", "Vara de Tormenta Eléctrica", 5, 14.0, 140, "Atrae rayos celestes y los dispara en forma de arco continuo.", "Metal", "(90, 100, 140)", 4.8, "Ball", "Neon", "(50, 200, 255)", 460, 95, 3800),
    ("CetroDeMareasProfundas", "Cetro de Mareas Profundas", 5, 16.0, 155, "La presión del fondo marino concentrada en una perla azul.", "Marble", "(20, 50, 100)", 4.7, "Ball", "Neon", "(0, 180, 255)", 490, 105, 4200),
    ("BastonDeCristalSideral", "Bastón de Cristal Sideral", 5, 18.0, 170, "Fragmento de meteorito caído que desafía la gravedad.", "Marble", "(70, 60, 95)", 4.8, "Ball", "Glass", "(180, 140, 255)", 520, 115, 4600),
    ("VaraDeEspinasToxicas", "Vara de Espinas Tóxicas", 5, 20.0, 185, "Veneno de víbora arcana que desgasta a los monstruos.", "Wood", "(42, 58, 35)", 4.6, "Ball", "Neon", "(90, 255, 60)", 550, 125, 5000),
    ("BastonDeGlaciarEterno", "Bastón de Glaciar Eterno", 5, 22.0, 200, "Cero absoluto que congela el aire al disparar.", "Marble", "(180, 220, 255)", 4.8, "Ball", "Glass", "(120, 230, 255)", 580, 135, 5500),
    ("CetroDeEsmeraldaPura", "Cetro de Esmeralda Pura", 5, 24.0, 215, "Gema colosal facetada con doce reflejos de sanación y ataque.", "Marble", "(25, 80, 50)", 4.7, "Ball", "Neon", "(0, 255, 150)", 610, 145, 6000),
    ("VaraDeVientoCiclónico", "Vara de Viento Ciclónico", 6, 26.0, 230, "Huracanes miniatura que empujan y desgarran a los rivales.", "SmoothPlastic", "(190, 230, 240)", 4.6, "Ball", "Neon", "(140, 255, 240)", 640, 155, 6500),
    ("BastonDeMagmaLiquido", "Bastón de Magma Líquido", 6, 28.0, 245, "Núcleo ardiente visible a través de canales de cristal negro.", "Basalt", "(40, 20, 20)", 4.8, "Ball", "Neon", "(255, 95, 30)", 670, 165, 7000),
    ("CetroDeSangreAncestral", "Cetro de Sangre Ancestral", 6, 29.0, 260, "Rubí sangriento que drena vitalidad mágica de la tierra.", "Marble", "(70, 20, 30)", 4.7, "Ball", "Neon", "(255, 40, 70)", 700, 175, 7500),
    ("VaraDeAmatistaImperial", "Vara de Amatista Imperial", 6, 30.0, 270, "Joya de la corona de la antigua dinastía de hechiceros.", "Marble", "(55, 30, 75)", 4.8, "Ball", "Neon", "(210, 90, 255)", 730, 185, 8000),
    ("BastonDeDiamanteNegro", "Bastón de Diamante Negro", 6, 31.0, 280, "La sustancia más dura del reino, prácticamente indestructible.", "Metal", "(30, 30, 35)", 4.7, "Ball", "Glass", "(150, 150, 180)", 760, 195, 8500),
    ("CetroDeArenaDelDesierto", "Cetro de Arena del Desierto", 6, 32.0, 290, "Tormenta de arena abrasadora que ciega a las bestias.", "WoodPlanks", "(110, 85, 45)", 4.6, "Ball", "Neon", "(255, 200, 80)", 790, 205, 9000),
    ("VaraDeHuesoDeDragon", "Vara de Hueso de Dragón", 6, 33.0, 300, "Costilla de un dragón del bosque tallada con runas de fuego.", "Marble", "(215, 205, 190)", 4.9, "Ball", "Neon", "(255, 120, 40)", 820, 215, 9500),
    ("BastonDeLotoSagrado", "Bastón de Loto Sagrado", 6, 33.5, 305, "Pétalos de cristal flotantes que giran en armonía.", "Marble", "(75, 40, 65)", 4.7, "Ball", "Neon", "(255, 140, 200)", 850, 225, 10000),
    ("CetroDeAuroraBoreal", "Cetro de Aurora Boreal", 6, 34.0, 310, "Colores cambiantes verde, azul y violeta en un halo continuo.", "Marble", "(40, 60, 85)", 4.8, "Ball", "Neon", "(80, 255, 210)", 880, 235, 10500),
    ("VaraDeGravedadCero", "Vara de Gravedad Cero", 6, 34.5, 315, "Levita ligeramente en la mano sin peso alguno.", "Metal", "(80, 85, 105)", 4.6, "Ball", "Neon", "(160, 110, 255)", 910, 245, 11000),
    ("BastonDeRelampagoNegro", "Bastón de Relámpago Negro", 6, 35.0, 320, "Truenos sombríos que atraviesan las defensas enemigas.", "Basalt", "(22, 22, 28)", 4.8, "Ball", "Neon", "(130, 70, 255)", 940, 255, 11500),
    ("CetroDeLuzSolar", "Cetro de Luz Solar", 6, 35.0, 320, "Atrapa el mediodía en una esfera de cristal pulido.", "Metal", "(160, 130, 40)", 4.8, "Ball", "Neon", "(255, 225, 50)", 970, 265, 12000),
]

# --- 4. ÉPICO (15 Bastones: Tier 7-8, Mult x50.0 - x250.0, Daño 400-1,200) ---
epicos = [
    ("BastonDelArchimago", "Bastón del Archimago", 7, 50.0, 450, "Portado únicamente por los líderes del Consejo de la Torre.", "Marble", "(45, 40, 65)", 5.0, "Ball", "Neon", "(180, 90, 255)", 1200, 350, 15000),
    ("CetroDeTormentaSolar", "Cetro de Tormenta Solar", 7, 65.0, 520, "Erupciones solares en miniatura que abrasan el campo de batalla.", "Metal", "(180, 120, 25)", 5.0, "Ball", "Neon", "(255, 140, 20)", 1400, 400, 18000),
    ("BastonDeHieloEterno", "Bastón de Hielo Eterno", 7, 80.0, 600, "Forjado en el corazón del pico más alto del continente helado.", "Marble", "(160, 210, 255)", 5.1, "Ball", "Glass", "(80, 220, 255)", 1600, 450, 22000),
    ("VaraDeObsidianaAbisal", "Vara de Obsidiana Abisal", 7, 100.0, 700, "Vórtice oscuro que traga la luz a su alrededor.", "Basalt", "(18, 16, 22)", 5.0, "Ball", "Neon", "(150, 50, 255)", 1800, 500, 26000),
    ("CetroDelSenorDeLasMareas", "Cetro del Señor de las Mareas", 7, 120.0, 800, "Convoca maremotos y géiseres con un solo movimiento.", "Marble", "(20, 60, 120)", 5.2, "Ball", "Neon", "(0, 210, 255)", 2000, 550, 30000),
    ("BastonDelFenixDorado", "Bastón del Fénix Dorado", 8, 140.0, 880, "Plumas doradas del ave inmortal ardiendo eternamente.", "Metal", "(190, 145, 30)", 5.0, "Ball", "Neon", "(255, 185, 30)", 2300, 600, 35000),
    ("VaraDeMeteoroCaeleste", "Vara de Meteoro Celeste", 8, 160.0, 950, "Material cósmico recolectado del cráter de la estrella caída.", "Marble", "(60, 55, 90)", 5.1, "Ball", "Neon", "(110, 160, 255)", 2600, 650, 40000),
    ("CetroDeLotoCelestial", "Cetro de Loto Celestial", 8, 180.0, 1020, "Pureza mágica absoluta que multiplica cada gota de maná.", "Marble", "(230, 215, 240)", 5.0, "Ball", "Neon", "(255, 160, 220)", 2900, 700, 45000),
    ("BastonDeTruenoPrimordial", "Bastón de Trueno Primordial", 8, 200.0, 1080, "La primera chispa eléctrica que resonó al inicio del mundo.", "Metal", "(80, 90, 130)", 5.2, "Ball", "Neon", "(40, 230, 255)", 3200, 750, 50000),
    ("VaraDelVacioEtereo", "Vara del Vacío Etéreo", 8, 215.0, 1120, "Desgarra la tela de la realidad generando ondas de choque.", "Marble", "(35, 25, 50)", 5.0, "Ball", "Neon", "(190, 70, 255)", 3500, 800, 55000),
    ("CetroDeSanacionSuprema", "Cetro de Sanación Suprema", 8, 225.0, 1150, "Canalización de vitalidad infinita y daño de luz radiante.", "Marble", "(220, 240, 210)", 5.1, "Ball", "Neon", "(70, 255, 160)", 3800, 850, 60000),
    ("BastonDelColosoDePiedra", "Bastón del Coloso de Piedra", 8, 235.0, 1170, "Fuerza telúrica capaz de quebrar montañas con sus rayos.", "Cobblestone", "(55, 58, 68)", 5.2, "Ball", "Neon", "(255, 150, 60)", 4100, 900, 65000),
    ("VaraDeSupernova", "Vara de Supernova", 8, 240.0, 1180, "Contiene el estertor agonizante de un sol gigante rojo.", "Metal", "(160, 50, 30)", 5.1, "Ball", "Neon", "(255, 60, 30)", 4400, 950, 70000),
    ("CetroDeGalaxiasLejanas", "Cetro de Galaxias Lejanas", 8, 245.0, 1190, "Espirales estelares giran alrededor de su núcleo de antimateria.", "Marble", "(40, 35, 70)", 5.2, "Ball", "Neon", "(140, 90, 255)", 4700, 1000, 75000),
    ("BastonDelJuicioFinal", "Bastón del Juicio Final", 8, 250.0, 1200, "El arma definitiva forjada por los cuatro señores elementales.", "Metal", "(50, 45, 60)", 5.3, "Ball", "Neon", "(255, 215, 0)", 5000, 1100, 80000),
]

# --- 5. LEGENDARIO (10 Bastones: Tier 9-10, Mult x400.0 - x3,000.0, Daño 1,800-8,500) ---
legendarios = [
    ("BastonDelFenixEterno", "Báculo del Fénix Eterno", 9, 450.0, 2000, "Plumas de fuego imperecedero forjadas en el núcleo del sol.", "Metal", "(190, 80, 20)", 5.4, "Ball", "Neon", "(255, 110, 20)", 8000, 2000, 150000),
    ("CetroCosmicoDelVacio", "Cetro Cósmico del Vacío", 9, 700.0, 2800, "Un agujero negro en miniatura estabilizado por runas titánicas.", "Marble", "(20, 15, 35)", 5.5, "Ball", "Neon", "(160, 40, 255)", 10000, 2500, 200000),
    ("BastonDelDragonCelestial", "Bastón del Dragón Celestial", 9, 1000.0, 3600, "Garra dorada que sostiene el orbe del Gran Dragón Estelar.", "Metal", "(200, 160, 35)", 5.5, "Ball", "Neon", "(255, 230, 80)", 12500, 3000, 250000),
    ("VaraDelCaosTemporal", "Vara del Caos Temporal", 9, 1300.0, 4400, "Desacelera el flujo del tiempo y desintegra enemigos a distancia.", "Marble", "(50, 45, 75)", 5.4, "Ball", "Neon", "(0, 240, 255)", 15000, 3500, 300000),
    ("CetroDelSenorDelAbismo", "Cetro del Señor del Abismo", 9, 1600.0, 5200, "Oscuridad viviente que devora cualquier magia enemiga.", "Basalt", "(15, 12, 18)", 5.6, "Ball", "Neon", "(180, 20, 255)", 18000, 4000, 350000),
    ("BastonDeLasSieteEstrellas", "Bastón de las Siete Estrellas", 10, 1900.0, 6000, "Siete gemas astrales que disparan en constelación perfecta.", "Marble", "(220, 230, 250)", 5.5, "Ball", "Neon", "(100, 210, 255)", 21000, 4500, 400000),
    ("VaraDelTitanTelurico", "Vara del Titán Telúrico", 10, 2200.0, 6800, "Sustraída de la tumba del titán que moldeó los continentes.", "Cobblestone", "(60, 52, 45)", 5.6, "Ball", "Neon", "(255, 160, 40)", 24000, 5000, 450000),
    ("CetroDeNebulosaEstelar", "Cetro de Nebulosa Estelar", 10, 2500.0, 7500, "Nubes de polvo interestelar que dan a luz a cometas de energía.", "Marble", "(65, 30, 70)", 5.5, "Ball", "Neon", "(255, 80, 210)", 27000, 5500, 500000),
    ("BastonDeLuzPrimigenia", "Bastón de Luz Primigenia", 10, 2800.0, 8000, "El primer destello que rompió la nada antes del tiempo.", "SmoothPlastic", "(255, 250, 240)", 5.6, "Ball", "Neon", "(255, 255, 220)", 30000, 6000, 550000),
    ("VaraDelEmperadorAstral", "Vara del Emperador Astral", 10, 3000.0, 8500, "Arma ceremonial con la que se gobernaron mil dimensiones.", "Metal", "(215, 175, 45)", 5.7, "Ball", "Neon", "(255, 215, 0)", 35000, 7000, 600000),
]

# --- 6. MÍTICO (5 Bastones: Tier 11-12, Mult x5,000.0 - x35,000.0, Daño 15,000-85,000) ---
miticos = [
    ("VaraPrimordialDelGenesis", "Vara Primordial del Génesis", 11, 6000.0, 18000, "El báculo con el que se trazaron las leyes de la física y la magia.", "Marble", "(240, 235, 255)", 5.8, "Ball", "Neon", "(0, 255, 240)", 60000, 15000, 1500000),
    ("CetroDeLaOmnisciencia", "Cetro de la Omnisciencia", 11, 10000.0, 30000, "Conoce la debilidad de cada ser vivo antes de disparar.", "Marble", "(70, 45, 95)", 5.8, "Ball", "Neon", "(210, 120, 255)", 80000, 20000, 2000000),
    ("BastonDelColapsoEstelar", "Báculo del Colapso Estelar", 12, 16000.0, 45000, "El peso de diez supernovas condensado en un proyectil destructor.", "Metal", "(30, 25, 40)", 5.9, "Ball", "Neon", "(255, 40, 100)", 110000, 28000, 3000000),
    ("VaraDelHacedorDeMundos", "Vara del Hacedor de Mundos", 12, 24000.0, 65000, "Capaz de crear y destruir reinos enteros con cada pulsación de poder.", "Metal", "(225, 185, 55)", 6.0, "Ball", "Neon", "(255, 235, 90)", 150000, 38000, 4500000),
    ("BastonDeLaTrascendencia", "Bastón de la Trascendencia", 12, 35000.0, 85000, "La culminación del arte arcano: poder infinito que trasciende la existencia.", "Neon", "(255, 255, 255)", 6.0, "Ball", "Neon", "(255, 215, 0)", 200000, 50000, 6000000),
]

all_staves = []
for item in comunes: all_staves.append((item, "Comun", "Color3.fromRGB(120, 200, 255)"))
for item in poco_comunes: all_staves.append((item, "PocoComun", "Color3.fromRGB(80, 230, 120)"))
for item in raros: all_staves.append((item, "Raro", "Color3.fromRGB(0, 220, 255)"))
for item in epicos: all_staves.append((item, "Epico", "Color3.fromRGB(190, 90, 255)"))
for item in legendarios: all_staves.append((item, "Legendario", "Color3.fromRGB(255, 180, 30)"))
for item in miticos: all_staves.append((item, "Mitico", "Color3.fromRGB(255, 50, 90)"))

print(f"Total Staves: {len(all_staves)}")

output_path = r"c:\Users\Antonio Garcia\Downloads\robloxjuego\src\shared\StavesData.luau"
with open(output_path, "w", encoding="utf-8") as f:
    f.write("""--!strict
-- StavesData.luau
-- Wizard Craft & Combat Simulator
-- Catálogo Maestro de los 100 Bastones Arcanos divididos en 6 Rarezas:
-- Común (25), Poco Común (25), Raro (20), Épico (15), Legendario (10), Mítico (5).
-- Incluye sistema de Forja Alquímica Aleatoria por Inversión de Materiales.

export type StaffConfig = {
	Id: string,
	Name: string,
	Tier: number,
	Rarity: "Comun" | "PocoComun" | "Raro" | "Epico" | "Legendario" | "Mitico",
	RarityColor: Color3,
	Damage: number,
	PowerMultiplier: number,
	ProjectileType: "Beam" | "Orb" | "Lightning",
	ProjectileColor: Color3,
	GlowColor: Color3,
	WoodCost: number,
	CrystalCost: number,
	CoinCost: number,
	Description: string,
	ModelDesign: {
		ShaftMaterial: Enum.Material,
		ShaftColor: Color3,
		ShaftLength: number,
		GemShape: Enum.PartType,
		GemMaterial: Enum.Material,
		GemColor: Color3,
		HeadWings: boolean,
		ProngCount: number,
		OrbitRings: number,
	},
}

local StavesData = {}

local STAVES: { [string]: StaffConfig } = {
""")

    for (item, rarity, rarity_color) in all_staves:
        s_id, s_name, tier, mult, dmg, desc, s_mat, s_col, s_len, g_shape, g_mat, g_col, w_cost, c_cost, coin_cost = item
        proj_type = "Orb" if tier <= 3 else ("Beam" if tier <= 8 else "Lightning")
        wings = "true" if tier >= 3 else "false"
        prongs = 3 if tier <= 3 else (4 if tier <= 8 else 6)
        rings = 0 if tier <= 2 else (1 if tier <= 7 else 2)

        f.write(f"""\t["{s_id}"] = {{\n""")
        f.write(f"""\t\tId = "{s_id}",\n""")
        f.write(f"""\t\tName = "{s_name}",\n""")
        f.write(f"""\t\tTier = {tier},\n""")
        f.write(f"""\t\tRarity = "{rarity}",\n""")
        f.write(f"""\t\tRarityColor = {rarity_color},\n""")
        f.write(f"""\t\tDamage = {dmg},\n""")
        f.write(f"""\t\tPowerMultiplier = {mult:.2f},\n""")
        f.write(f"""\t\tProjectileType = "{proj_type}",\n""")
        f.write(f"""\t\tProjectileColor = Color3.fromRGB{g_col},\n""")
        f.write(f"""\t\tGlowColor = Color3.fromRGB{g_col},\n""")
        f.write(f"""\t\tWoodCost = {w_cost},\n""")
        f.write(f"""\t\tCrystalCost = {c_cost},\n""")
        f.write(f"""\t\tCoinCost = {coin_cost},\n""")
        f.write(f"""\t\tDescription = "{desc}",\n""")
        f.write(f"""\t\tModelDesign = {{\n""")
        f.write(f"""\t\t\tShaftMaterial = Enum.Material.{s_mat},\n""")
        f.write(f"""\t\t\tShaftColor = Color3.fromRGB{s_col},\n""")
        f.write(f"""\t\t\tShaftLength = {s_len},\n""")
        f.write(f"""\t\t\tGemShape = Enum.PartType.{g_shape},\n""")
        f.write(f"""\t\t\tGemMaterial = Enum.Material.{g_mat},\n""")
        f.write(f"""\t\t\tGemColor = Color3.fromRGB{g_col},\n""")
        f.write(f"""\t\t\tHeadWings = {wings},\n""")
        f.write(f"""\t\t\tProngCount = {prongs},\n""")
        f.write(f"""\t\t\tOrbitRings = {rings},\n""")
        f.write(f"""\t\t}},\n""")
        f.write(f"""\t}},\n\n""")

    f.write("""}

-- Obtener configuración de un bastón por Id
function StavesData.getStaff(staffId: string?): StaffConfig
	if not staffId then
		return STAVES["VaraDeAprendiz"]
	end
	return STAVES[staffId] or STAVES["VaraDeAprendiz"]
end

-- Lista completa ordenada de los 100 bastones
function StavesData.getAllStaves(): { StaffConfig }
	local list = {}
	for _, staff in pairs(STAVES) do
		table.insert(list, staff)
	end
	table.sort(list, function(a, b)
		if a.Tier == b.Tier then
			return a.PowerMultiplier < b.PowerMultiplier
		end
		return a.Tier < b.Tier
	end)
	return list
end

-- Obtener bastones por rareza específica
function StavesData.getStavesByRarity(rarity: string): { StaffConfig }
	local list = {}
	for _, staff in pairs(STAVES) do
		if staff.Rarity == rarity then
			table.insert(list, staff)
		end
	end
	return list
end

-- ==============================================================================
-- SISTEMA DE FORJA ALQUÍMICA ALEATORIA SEGÚN MATERIALES INVERTIDOS
-- ==============================================================================
-- woodInvested: Cantidad de Madera Arcana vertida al foso (mínimo 5)
-- crystalInvested: Cantidad de Cristales Celestes vertidos (opcional, aumenta suerte)
function StavesData.rollRandomStaff(woodInvested: number, crystalInvested: number?): StaffConfig
	local crystal = crystalInvested or 0

	-- Cálculo de Suerte según la inversión
	-- Base: 60% Comun, 25% PocoComun, 10% Raro, 4.0% Epico, 0.9% Legendario, 0.1% Mitico
	local bonus = math.clamp((woodInvested / 50) + (crystal * 2), 0, 80)

	local roll = math.random() * 100

	local chosenRarity = "Comun"

	local mythicThreshold = 0.1 + (bonus * 0.05)       -- Hasta ~4%
	local legendThreshold = mythicThreshold + 0.9 + (bonus * 0.15) -- Hasta ~13%
	local epicThreshold = legendThreshold + 4.0 + (bonus * 0.35)   -- Hasta ~32%
	local rareThreshold = epicThreshold + 10.0 + (bonus * 0.35)    -- Hasta ~55%
	local pocoComunThreshold = rareThreshold + 25.0

	if roll <= mythicThreshold then
		chosenRarity = "Mitico"
	elseif roll <= legendThreshold then
		chosenRarity = "Legendario"
	elseif roll <= epicThreshold then
		chosenRarity = "Epico"
	elseif roll <= rareThreshold then
		chosenRarity = "Raro"
	elseif roll <= pocoComunThreshold then
		chosenRarity = "PocoComun"
	else
		chosenRarity = "Comun"
	end

	local pool = StavesData.getStavesByRarity(chosenRarity)
	if #pool == 0 then
		pool = StavesData.getStavesByRarity("Comun")
	end

	return pool[math.random(1, #pool)]
end

return StavesData
""")

print("Successfully generated StavesData.luau with 100 staves!")
