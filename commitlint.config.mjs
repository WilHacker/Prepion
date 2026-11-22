// Conventional Commits con descripción en español y en minúscula (estándar heredado de ArcuSIS).
export default {
  extends: ['@commitlint/config-conventional'],
  rules: {
    'header-max-length': [2, 'always', 100],
    'subject-case': [2, 'always', ['lower-case']],
    'scope-enum': [2, 'always', ['app', 'backend', 'ml', 'docker', 'ci', 'docs', 'deps']],
  },
};
