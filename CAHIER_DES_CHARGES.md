# Cahier des Charges & Cadrage Fonctionnel - Golden House

**Projet** : Golden House - Application M-Commerce de mobilier et décoration d'intérieur  
**Matière** : Ingénierie du Web Avancée 2 (IWA) - Semestre 9 (Polytech Montpellier)  
**Équipe** : Justin Chapon, Nabil Bennacer  
**Date de cadrage** : Séance du 7 septembre 2026  

---

## 1. Présentation du projet

Golden House est une solution m-commerce spécialisée dans la vente directe de mobilier et d'articles pour la maison (lits, canapés, rideaux, coussins).

La plateforme se compose :
1. D'une **application mobile acheteur** (multiplateforme).
2. D'un **backoffice web commerçant** (dashboard et gestion).
3. D'un **backend micro-services** (Spring Boot / API REST).
4. D'une **interface MCP** (Model Context Protocol) pour l'intégration d'outils et d'agents IA.

---

## 2. Périmètre du MVP (Minimum Viable Product)

Pour la première itération exploitable du projet :
- **Catalogue ciblé** : Vente de canapés.
- **Recherche & Navigation** : Barre de recherche textuelle et système de filtres par critères (prix, couleur, dimensions, matière).
- **Parcours d'achat complet** : De la consultation publique jusqu'au paiement fictif et confirmation de commande.
- **Backoffice minimal** : Gestion du stock de canapés et tableau de bord avec les premiers KPI de vente.

---

## 3. Backlog Fonctionnel

### 3.1. Espace Acheteur (Application Mobile)

- **Consultation publique** : Accès au catalogue complet sans obligation de connexion préalable.
- **Recherche & Filtres** : Recherche textuelle rapide, filtres par catégorie, prix, dimensions, disponibilité.
- **Gestion du panier** : Ajout d'articles, modification des quantités, calcul automatique du total.
- **Authentification & Profil** :
  - Création de compte et connexion sécurisée (JWT).
  - Gestion des informations personnelles et carnets d'adresses (facturation et livraison).
- **Paiement sécurisé** : Simulation de paiement par carte bancaire avec validation transactionnelle.
- **Suivi de commande & Historique** :
  - Consultation de l'historique des achats.
  - Suivi en temps réel de l'état de la commande (validée, en préparation, expédiée, livrée).
- **Consultation des stocks** : Indication claire de la disponibilité en stock sur chaque fiche article.
- **Centre de notifications** : Notifications in-app sur l'avancement des commandes et alertes de stock.
- **Avis et commentaires** : Dépôt d'une note et d'un commentaire après réception du produit.
- **Chatbot IA** : Assistant conversationnel intégré pour guider l'utilisateur dans son choix et répondre aux questions fréquentes.
- **Conversion monétaire** : Bascule d'affichage des devises (€ / $).

### 3.2. Espace Commerçant (Backoffice Web)

- **Authentification administrateur** : Connexion sécurisée dédiée aux gestionnaires.
- **Gestion du catalogue (CRUD)** :
  - Ajout, modification, archivage et suppression d'articles.
  - Gestion des caractéristiques techniques, photos et prix.
- **Gestion des stocks** :
  - Suivi des quantités restantes en temps réel.
  - Incrémentation / décrémentation manuelle ou liée aux événements de vente.
- **Gestion des réapprovisionnements fournisseurs** :
  - Déclenchement de demandes d'achat auprès des fournisseurs partenaires.
  - Suivi des statuts de commande fournisseur (émise, confirmée, expédiée, réceptionnée).
  - Mise à jour automatique des stocks dès validation de la réception des marchandises.
- **Gestion des clients** : Consultation de la liste des utilisateurs inscrits et possibilité de désactivation / suppression de compte.
- **Tableau de bord KPI** :
  - Chiffre d'affaires global et périodique.
  - Identification du « Produit star » (meilleure vente).
  - Volume de commandes traitées / en cours.
  - Taux de rupture de stock.
- **Modération des avis** : Consultation et réponse publique aux avis et commentaires des clients.

### 3.3. Interface MCP (Model Context Protocol)

Intégration d'un serveur MCP connecté au backend afin d'exposer de manière standardisée :
- La consultation du catalogue et de l'état des stocks pour des agents conversationnels (Chatbot IA client).
- Le requêtage automatisé des KPIs et des métriques de vente pour les gestionnaires.
- Des actions contrôlées (vérification d'état de commande, statut de réapprovisionnement).

---

## 4. Workflows Opérationnels

### 4.1. Workflow Acheteur

```text
[Arrivée sur l'application] 
       │
       ▼
[Consultation du catalogue public / Recherche / Filtres]
       │
       ▼
[Sélection d'un produit]
       │
       ▼
[Intention d'achat] ──> Compte existant ?
       │                      ├── Non : [Création de compte] ────┐
       │                      └── Oui : [Authentification] ──────┤
       ▼                                                         │
[Ajout au panier] <──────────────────────────────────────────────┘
       │
       ▼
[Validation du panier & Choix adresses facturation / livraison]
       │
       ▼
[Paiement sécurisé par carte bancaire]
       │
       ▼
[Confirmation de commande & Envoi en historique]
       │
       ▼
[Suivi du statut de préparation et de livraison]
       │
       ▼
[Réception & Dépôt d'un avis client]
```

### 4.2. Workflow Commerçant

```text
[Connexion au backoffice web]
       │
       ├───> [Consultation du Dashboard KPI (CA, Produit star, Commandes)]
       │
       ├───> [Notification d'une nouvelle commande client]
       │        │
       │        ▼
       │     [Mise à jour automatique des stocks]
       │
       ├───> [Alerte stock bas]
       │        │
       │        ▼
       │     [Demande de réapprovisionnement auprès du fournisseur]
       │        │
       │        ▼
       │     [Suivi du statut de la commande fournisseur]
       │        │
       │        ▼
       │     [Réception des produits & Incrémentation automatique du stock]
       │
       └───> [Consultation et réponse aux avis clients]
```

---

## 5. Choix Technologiques & Justifications

| Composant | Technologie | Justification |
| :--- | :--- | :--- |
| **Mobile Acheteur** | **React Native** | Développement multiplateforme (iOS & Android) sans dépendance matérielle macOS ni double base de code native. |
| **Backoffice Web** | **React** | Écosystème riche pour la construction de tableaux de bord interactifs (KPIs) et réactivité de l'interface. |
| **Backend** | **Spring Boot** | Imposé par le sujet. Architecture micro-services robuste (Spring Cloud, JPA, Security, REST API). |
| **Base de données** | **PostgreSQL** | SGBDR éprouvé garantissant l'intégrité transactionnelle (ACID) pour les commandes, stocks et facturations. |
| **Protocole IA** | **MCP (Model Context Protocol)** | Standardisation des outils et des contextes pour connecter le backend à des modèles et agents LLM. |
| **Maquettage** | **Figma** | Prototypage collaboratif des écrans mobile et du tableau de bord backoffice. |
| **Gestion de version** | **GitHub** | Suivi du code source, gestion des branches et revues de code en binôme. |
