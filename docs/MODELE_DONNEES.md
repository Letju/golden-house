# Modélisation de la Base de Données - Golden House

Document de référence pour l'architecture des données du projet **Golden House** (M-Commerce Mobilier & Décoration).  
Module : **Ingénierie du Web Avancée 2 (IWA)** - Semestre 9 (Polytech Montpellier).

---

## 1. Origine & Évolution du Schéma

Ce schéma est issu de la synthèse des besoins fonctionnels du cahier des charges et des notes de cadrage manuscrites transmises par **Nabil Bennacer** (séance du 8 septembre 2026, archivée dans [`docs/Note 8 sept. 2026.pdf`](./Note%208%20sept.%202026.pdf)).

### 1.1. Analyse des notes initiales de Nabil

Dans sa proposition initiale, Nabil avait posé les bases de 7 entités clés :
- `User` (UserId, Email, Password, Username, isAdmin, Devise, Adresse)
- `Produit` (idProduit, Prix, catégorie [Enum LoveSeat, LivingRoom, Vintage], TypeMat, Couleur, Dimension, Stock, Description)
- `Panier` (idPanier, `<Product, Qty>`, CodePromo)
- `Commande` (idCommande, Adresse de livrai, Statut, Addr Factu, idPanier, idProduit, UserId, date, Montant)
- `Avis` (id, titre, Description, Note, idUser, idProduit, date)
- `Notification` (idNotif, titre, Description, Date, Statut, idUser)
- `Fournisseur` (idFournisseur, Nom, mail, numTel)

---

### 1.2. Corrections et optimisations majeures pour le MVP

Pour aboutir à un modèle de données relationnel normalisé (3NF), robuste, performant et adapté aux exigences du MVP :

1. **Entité Produit** :
   - **Ajout du nom du produit (`nom`)** : Oublié dans le brouillon initial.
   - **Ajout du champ `images` (tableau d'URLs)** : Indispensable pour l'affichage visuel sur l'application mobile React Native et le catalogue backoffice.
   - **Dimensions normalisées** : Séparation en `largeur_cm`, `hauteur_cm`, `profondeur_cm` (au lieu d'une chaîne brute) pour faciliter les filtres de recherche.
   - **Liaison Fournisseur** : Ajout d'une clé étrangère `fournisseur_id` pour rattacher chaque produit à son fabricant/grossiste.
   - **Seuil d'alerte (`seuil_alerte`)** : Pour déclencher automatiquement les alertes de stock bas vers les commerçants.

2. **Panier & Lignes de Panier (`Cart` & `CartItem`)** :
   - Normalisation de la notation `<Product, Qty>` via une table de liaison dédiée `cart_items` avec contrainte d'unicité `(cart_id, product_id)`.
   - Clé étrangère directe `user_id` sur `Cart` pour lier le panier au compte de l'acheteur.

3. **Commande & Lignes de Commande (`Order` & `OrderItem`)** :
   - **Correction de la modélisation Produit/Commande** : Dans le brouillon, `idProduit` était directement dans `Commande`, ce qui empêcherait de commander plusieurs articles différents par panier ! Création de la table `order_items`.
   - **Snapshot du prix au moment de l'achat** : Stockage de `prix_unitaire` et `total_ligne` dans `order_items` pour figer la facture même si le prix catalogue change ultérieurement.
   - **Découplage Panier / Commande** : La commande enregistre ses propres lignes pour conserver l'historique d'achat même si le panier est réinitialisé après le paiement.

4. **Adresses (`Address`)** :
   - Séparation en entité dédiée reliée à `User` avec distinction du type (`LIVRAISON`, `FACTURATION`, `MIXTE`) pour respecter la spécification du carnet d'adresses (Cahier des charges §3.1).

5. **Paiement avec Stripe** :
   - Stockage de `stripe_customer_id` (`cus_...`) dans `users`.
   - Stockage de `stripe_payment_intent_id` (`pi_...`) et `stripe_session_id` dans `orders`.
   - Enum `payment_status_enum` aligné sur le cycle de vie Stripe (`PENDING`, `REQUIRES_ACTION`, `SUCCEEDED`, `FAILED`, `CANCELED`, `REFUNDED`).

6. **Modération des Avis (`Review`)** :
   - Ajout des champs `reponse_commercant` et `repondu_at` pour implémenter la réponse publique commerçant demandée dans le backoffice.

7. **Réapprovisionnements Fournisseurs (`SupplyOrder` & `SupplyOrderItem`)** :
   - Formalisation des commandes fournisseurs pour concrétiser le workflow de réapprovisionnement décrit au §3.2 du cahier des charges.

---

## 2. Diagramme Entité-Association (Mermaid)

```mermaid
erDiagram
    USER ||--o{ ADDRESS : "possede"
    USER ||--o| CART : "detient"
    USER ||--o{ ORDER : "passe"
    USER ||--o{ REVIEW : "redige"
    USER ||--o{ NOTIFICATION : "recoit"

    CART ||--o{ CART_ITEM : "contient"
    PRODUCT ||--o{ CART_ITEM : "est reference dans"

    ORDER ||--o{ ORDER_ITEM : "comprend"
    PRODUCT ||--o{ ORDER_ITEM : "est achete via"
    ADDRESS ||--o{ ORDER : "adresse livraison"
    ADDRESS ||--o{ ORDER : "adresse facturation"

    PRODUCT ||--o{ REVIEW : "fait l objet de"
    FOURNISSEUR ||--o{ PRODUCT : "fournit"

    FOURNISSEUR ||--o{ SUPPLY_ORDER : "recoit commande"
    SUPPLY_ORDER ||--o{ SUPPLY_ORDER_ITEM : "contient"
    PRODUCT ||--o{ SUPPLY_ORDER_ITEM : "reapprovisionne"

    USER {
        uuid id PK
        string email UK
        string password_hash
        string username UK
        string first_name
        string last_name
        string phone
        enum role
        enum currency
        string stripe_customer_id UK
        boolean is_active
        timestamp created_at
    }

    ADDRESS {
        uuid id PK
        uuid user_id FK
        enum type
        string street
        string postal_code
        string city
        string country
        boolean is_default
    }

    PRODUCT {
        uuid id PK
        string nom
        text description
        numeric prix
        enum categorie
        enum type_matiere
        string couleur
        int largeur_cm
        int hauteur_cm
        int profondeur_cm
        int stock
        int seuil_alerte
        string[] images
        uuid fournisseur_id FK
        boolean est_actif
    }

    CART {
        uuid id PK
        uuid user_id FK
        string code_promo
        timestamp updated_at
    }

    CART_ITEM {
        uuid id PK
        uuid cart_id FK
        uuid product_id FK
        int quantite
    }

    ORDER {
        uuid id PK
        string order_number UK
        uuid user_id FK
        enum statut
        enum statut_paiement
        string stripe_payment_intent_id UK
        string stripe_session_id
        uuid shipping_address_id FK
        uuid billing_address_id FK
        numeric montant_total
        enum devise
        string code_promo_applique
        timestamp created_at
    }

    ORDER_ITEM {
        uuid id PK
        uuid order_id FK
        uuid product_id FK
        string nom_produit
        int quantite
        numeric prix_unitaire
        numeric total_ligne
    }

    REVIEW {
        uuid id PK
        uuid user_id FK
        uuid product_id FK
        string titre
        text description
        int note
        text reponse_commercant
        timestamp repondu_at
    }

    FOURNISSEUR {
        uuid id PK
        string nom
        string email
        string telephone
        text adresse
    }

    SUPPLY_ORDER {
        uuid id PK
        uuid fournisseur_id FK
        enum statut
        numeric montant_total
        timestamp date_emission
        timestamp date_reception
    }

    SUPPLY_ORDER_ITEM {
        uuid id PK
        uuid supply_order_id FK
        uuid product_id FK
        int quantite
        numeric prix_unitaire
    }

    NOTIFICATION {
        uuid id PK
        uuid user_id FK
        string titre
        text message
        enum type
        boolean est_lu
        timestamp created_at
    }
```

---

## 3. Choix d'outils : Prisma vs Spring Boot / SQL DDL

### La question posée :
> *« Tu penses le mieux c'est de créer le dossier backend et mettre cela dans prisma ? »*

### Recommandation d'architecture :

1. **Exigence académique IWA** : Le sujet officiel de Christophe Nauroy impose un backend micro-services majoritairement développé en **Spring Boot** (Java) adossé à **PostgreSQL**.
   - En Java / Spring Boot, le standard est **Spring Data JPA** (entités Java `@Entity`) ou des migrations SQL avec **Flyway** / **Liquibase**.
   - Prisma est un ORM exclusivement **TypeScript / Node.js**. Il ne remplace donc pas JPA dans les micro-services Java Spring Boot.

2. **La valeur ajoutée de Prisma pour l'équipe** :
   - **Clarté du DSL** : Le format `schema.prisma` est le format le plus lisible, expressif et clair pour modéliser visuellement et sans ambiguïté les entités et leurs relations.
   - **Prisma Studio** : Permet de lancer une interface web instantanée (`npx prisma studio`) pour inspecter, créer et modifier visuellement des données en base pendant les sessions de dev et démos.
   - **Intégration rapide** si un micro-service satellite (comme le serveur MCP ou un proxy BFF) est écrit en TypeScript.

3. **Organisation retenue dans le projet** :
   - **`backend/prisma/schema.prisma`** : Le schéma déclaratif complet, idéal pour visualiser et prototyper avec Prisma Studio.
   - **`backend/database/schema.sql`** : Le script SQL DDL PostgreSQL natif complet (types ENUM, tables, contraintes FK, index) directement utilisable par les micro-services Spring Boot et Docker.
   - **`backend/docker-compose.yml`** : Pour démarrer PostgreSQL 16 localement en une seule commande (`docker compose up -d`).
