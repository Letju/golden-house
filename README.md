# Golden House - Solution M-Commerce

Projet réalisé dans le cadre du module **Ingénierie du Web Avancée 2 (IWA)**.  
Formation : Polytech Montpellier - IG5 / DaMS (Semestre 9).

## Binôme

- Justin Chapon (`justin.chapon@etu.umontpellier.fr`)
- Nabil Bennacer (`bennacerna@gmail.com`)

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
- **Base de données** : PostgreSQL
- **IA & Agents** : Model Context Protocol (MCP)
- **Outils** : Figma (conception UI), GitHub (versioning & CI/CD)

## Documents de référence

- `CONSIGNES.md` : Sujet et exigences transmises par Christophe Nauroy.
- `CAHIER_DES_CHARGES.md` : Cadrage fonctionnel complet, périmètre MVP, workflows acheteur et commerçant.
- `docs/` : Documents annexes et notes brutes de cadrage de la séance du 7 septembre 2026.

## Structure du Répertoire

```text
.
├── CAHIER_DES_CHARGES.md
├── CONSIGNES.md
├── README.md
├── .gitignore
└── docs/
    └── Note 7 sept. 2026.pdf
```
