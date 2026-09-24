# Golden House - Solution M-Commerce

Projet réalisé dans le cadre du module **Ingénierie du Web Avancée 2 (IWA)**.  
Formation : Polytech Montpellier - IG5 / DaMS (Semestre 9).

## Équipe

- Justin Chapon ([@Letju](https://github.com/Letju))
- Nabil Bennacer ([@nabil-bennacer](https://github.com/nabil-bennacer))
- Tom Cantillon ([@Tom-Cantillon](https://github.com/Tom-Cantillon))
- Salma elannaby ([@salmaanbig](https://github.com/salmaanbig))
- Manuela Zapata Quirós ([@ManuelaZQ](https://github.com/ManuelaZQ))

## Description

Golden House est une solution m-commerce de vente directe spécialisée dans le mobilier et la décoration d'intérieur (canapés, lits, rideaux, coussins).

Le système s'articule autour de trois briques principales :
- Une application mobile acheteur multiplateforme (iOS / Android).
- Une application web backoffice commerçant avec suivi des indicateurs clés (KPIs) et gestion des stocks/fournisseurs.
- Un backend distribué en micro-services Spring Boot exposant des APIs REST et une interface MCP.

## Stack Technique Retenue

- **Frontend Mobile** : React Native
- **Frontend Backoffice** : React
- **Backend** : Spring Boot (Architecture Micro-services, Spring Data JPA, Spring Security)
- **Authentification** : Keycloak (IdP OIDC / SSO prévu pour l'authentification des micro-services)
- **Base de données** : PostgreSQL
- **IA & Agents** : Model Context Protocol (MCP)
- **Paiement** : Stripe (PaymentIntent & Checkout)
- **Outils** : Figma (conception UI), GitHub (versioning & CI/CD), Docker, Adminer

## Stratégie de Branches (Git Workflow)

- **`main`** : Branche stable de production / livrable jalons. Tout commit sur `main` doit être validé et fonctionnel.
- **`dev`** : Branche principale de développement. Toute nouvelle fonctionnalité ou correctif est développé sur une branche dédiée (ex: `feature/nom-tache`) puis mergé dans `dev`.

## Démarrage Rapide de la Base de Données

Pour lancer la base de données PostgreSQL 16 et l'interface visuelle Adminer avec les données de test préchargées :

```bash
cd backend
docker compose up -d
```
- **Interface Web Adminer** : [http://localhost:8080](http://localhost:8080)
- **Visualisation du Schéma (ERD)** : Voir [`backend/database/README.md`](backend/database/README.md) pour le diagramme visuel complet des tables et relations.

## Gestion des erreurs

- **APIs** : format unique RFC 7807 (`Problem Details`) avec `code` métier et `correlationId` ; `400` validation, `404` introuvable, `409` conflit (stock, double soumission), `422` règle métier, `502`/`504` dépendance (Stripe, Keycloak). Clé `Idempotency-Key` sur commande, paiement et remboursement.
- **Workers async** (événements, webhooks, notifications, réassort) : retry à backoff exponentiel puis file de lettres mortes (DLQ), consommateurs idempotents, alerte au-delà du seuil.
- **Batchs Spark** (KPIs, reco ALS) : jobs idempotents partitionnés par date avec checkpointing, lignes en erreur mises en quarantaine, écriture atomique par partition, `X-Correlation-ID` propagé partout (logs JSON).

## Dépôt GitLab & CI/CD

- **Cible** : migration du projet vers **GitLab** (remote à ajouter ; workflow `main` / `dev` / `feature` et revues via Merge Requests inchangés).
- **CI (blocante avant merge)** : `.gitlab-ci.yml` à écrire — sur chaque MR, vérification anti-erreurs : DDL + seed appliqués sur postgres éphémère, `prisma validate`, compilation LaTeX du rapport, MCD régénéré identique au commité. Merge impossible si la CI échoue.
- **CD (automatique)** : sur merge vers `main`, construction de l'image Docker (PostgreSQL + schéma/seed, puis images des micro-services) et déploiement automatique.

## Documents de référence

- `CONSIGNES.md` : Sujet et exigences transmises par Christophe Nauroy.
- `CAHIER_DES_CHARGES.md` : Cadrage fonctionnel complet, périmètre MVP, workflows acheteur et commerçant.
- `docs/` : Documents annexes et notes brutes de cadrage (`Note 7 sept. 2026.pdf`, `Note 8 sept. 2026.pdf`).

## Structure du Répertoire

```text
.
├── CAHIER_DES_CHARGES.md
├── CONSIGNES.md
├── README.md
├── .gitignore
├── backend/
│   ├── database/
│   │   ├── 01-schema.sql     # Script SQL DDL complet (PostgreSQL / Spring Boot)
│   │   ├── 02-seed.sql       # Jeu d'essai réaliste MVP (canapés, stock, Stripe)
│   │   └── README.md         # Documentation et diagramme relationnel (ERD) visuel
│   ├── prisma/
│   │   └── schema.prisma     # Schéma Prisma déclaratif (visualisation & tooling)
│   ├── docker-compose.yml    # Conteneurs PostgreSQL 16 + Adminer Web GUI
│   ├── package.json          # Tooling Prisma & scripts
│   └── .env.example
└── docs/
    ├── Note 7 sept. 2026.pdf # Notes de cadrage initiales
    └── Note 8 sept. 2026.pdf # Schéma manuscrit de Nabil Bennacer
```
