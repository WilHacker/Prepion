// Se ejecuta en cada commit solo sobre los archivos preparados (staged).
export default {
  'backend/**/*.py': (archivos) => {
    const lista = archivos.join(' ');
    return [
      `uv run --project backend ruff format ${lista}`,
      `uv run --project backend ruff check --fix ${lista}`,
    ];
  },
  'app/{lib,test}/**/*.dart': (archivos) => `dart format ${archivos.join(' ')}`,
};
