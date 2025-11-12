# DevSecOps Pipeline Demo

Application de démonstration d'un pipeline CI/CD avec sécurité intégrée.

## Technologies

- Node.js + Express
- Jenkins
- Docker
- Gitleaks, Semgrep, Trivy, OWASP ZAP

## Démarrage Local
```bash
npm install
npm start
```

## Endpoints

- GET / - Page d'accueil
- GET /health - Health check
- GET /api/users - Liste des utilisateurs

## Pipeline de Sécurité

1. Scan des secrets (Gitleaks)
2. Analyse statique (Semgrep)
3. Scan des dépendances (Trivy)
4. Build Docker
5. Scan de l'image (Trivy)
6. Déploiement staging
7. Tests dynamiques (OWASP ZAP)
8. Health check

## Auteur

DevSecOps Lab - 2025
