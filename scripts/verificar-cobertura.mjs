// Falla si la cobertura de líneas de un lcov.info es menor al mínimo.
// Uso: node scripts/verificar-cobertura.mjs <ruta/lcov.info> <minimo%>
import { readFileSync } from 'node:fs';

const [ruta, minimoTexto = '80'] = process.argv.slice(2);
const minimo = Number(minimoTexto);
// main.dart solo llama a runApp; se prueba de forma indirecta con PrepionApp.
// Los *_tablas.dart de drift solo los lee el generador: sus líneas nunca se ejecutan.
const excluidos = [/[\/]main\.dart$/, /\.g\.dart$/, /\.freezed\.dart$/, /_tablas\.dart$/];

let archivoActual = '';
let lineasTotales = 0;
let lineasCubiertas = 0;

for (const linea of readFileSync(ruta, 'utf8').split(/\r?\n/)) {
  if (linea.startsWith('SF:')) archivoActual = linea.slice(3);
  const esExcluido = excluidos.some((patron) => patron.test(archivoActual));
  if (esExcluido) continue;
  if (linea.startsWith('LF:')) lineasTotales += Number(linea.slice(3));
  if (linea.startsWith('LH:')) lineasCubiertas += Number(linea.slice(3));
}

const porcentaje = lineasTotales === 0 ? 100 : (lineasCubiertas / lineasTotales) * 100;
const mensaje = `Cobertura de la app: ${porcentaje.toFixed(2)} % (mínimo ${minimo} %)`;

if (porcentaje < minimo) {
  console.error(`✖ ${mensaje}`);
  process.exit(1);
}
console.log(`✔ ${mensaje}`);
