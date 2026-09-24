# Base de Données - Golden House

Ce dossier contient l'infrastructure et la modélisation de la base de données PostgreSQL pour le projet **Golden House** (M-Commerce Mobilier).

---

## 🚀 Démarrage Rapide (One-Click)

Pour lancer la base de données et l'interface graphique d'administration avec toutes les données de test préchargées :

```bash
cd backend
docker compose up -d
```

### 🖥️ Visualisation & Administration Web (Adminer)

Ouvrez votre navigateur sur : **[http://localhost:8080](http://localhost:8080)**

Renseignez les identifiants de connexion :
- **Système** : `PostgreSQL`
- **Serveur** : `postgres` *(ou `localhost` si exécuté hors du réseau Docker)*
- **Utilisateur** : `golden_user`
- **Mot de passe** : `golden_secret`
- **Base de données** : `golden_house_db`

> 💡 **Schéma relationnel visuel dans Adminer** : Une fois connecté, cliquez sur **« Schéma »** dans le menu de gauche d'Adminer pour voir le diagramme interactif des tables et de leurs relations.

---

## 📊 Diagramme Relationnel (ERD / MCD)

*Ce diagramme est interprété et rendu visuellement de manière native par GitHub.*

```mermaid
erDiagram
    USERS ||--o{ ADDRESSES : "possède"
    USERS ||--o| CARTS : "détient"
    USERS ||--o{ ORDERS : "passe"
    USERS ||--o{ REVIEWS : "rédige"
    USERS ||--o{ NOTIFICATIONS : "reçoit"

    CARTS ||--o{ CART_ITEMS : "contient"
    PRODUCTS ||--o{ CART_ITEMS : "référencé dans"

    ORDERS ||--o{ ORDER_ITEMS : "comprend"
    PRODUCTS ||--o{ ORDER_ITEMS : "acheté dans"
    ADDRESSES ||--o{ ORDERS : "adresse de livraison"
    ADDRESSES ||--o{ ORDERS : "adresse de facturation"

    ORDERS ||--o| INVOICES : "facturée par"
    INVOICES ||--o{ INVOICE_ITEMS : "détaille"
    ORDER_ITEMS ||--o{ INVOICE_ITEMS : "figé dans"

    ORDERS ||--o{ PRODUCT_RETURNS : "fait l'objet de"
    USERS ||--o{ PRODUCT_RETURNS : "demande"
    PRODUCT_RETURNS ||--o{ RETURN_ITEMS : "concerne"
    ORDER_ITEMS ||--o{ RETURN_ITEMS : "retourné via"
    PRODUCTS ||--o{ RETURN_ITEMS : "restocké via"

    PRODUCTS ||--o{ REVIEWS : "évalué par"
    FOURNISSEURS ||--o{ PRODUCTS : "fournit"

    FOURNISSEURS ||--o{ SUPPLY_ORDERS : "reçoit commande appro"
    SUPPLY_ORDERS ||--o{ SUPPLY_ORDER_ITEMS : "contient"
    PRODUCTS ||--o{ SUPPLY_ORDER_ITEMS : "réapprovisionne"

    USERS {
        uuid id PK
        varchar email UK
        varchar password_hash
        varchar username UK
        varchar first_name
        varchar last_name
        varchar phone
        role_enum role "CLIENT, COMMERCANT, ADMIN"
        currency_enum currency "EUR, USD"
        varchar stripe_customer_id UK "Stripe cus_xxx"
        boolean is_active
        timestamp created_at
    }

    ADDRESSES {
        uuid id PK
        uuid user_id FK
        address_type_enum type "LIVRAISON, FACTURATION, MIXTE"
        varchar street
        varchar postal_code
        varchar city
        varchar country
        boolean is_default
    }

    PRODUCTS {
        uuid id PK
        varchar nom
        text description
        numeric prix
        product_category_enum categorie "CANAPE_DROIT, CANAPE_ANGLE, etc."
        material_type_enum type_matiere "VELOURS, CUIR, TISSU_BOUCLETTE, LIN, etc."
        varchar couleur
        int largeur_cm
        int hauteur_cm
        int profondeur_cm
        int stock
        int seuil_alerte
        text[] images "URLs Unsplash / CDN"
        uuid fournisseur_id FK
        boolean est_actif
    }

    CARTS {
        uuid id PK
        uuid user_id FK
        varchar code_promo
        timestamp updated_at
    }

    CART_ITEMS {
        uuid id PK
        uuid cart_id FK
        uuid product_id FK
        int quantite
    }

    ORDERS {
        uuid id PK
        varchar order_number UK
        uuid user_id FK
        order_status_enum statut "EN_ATTENTE_PAIEMENT, PAYEE, RETOUR_EN_COURS, REMBOURSEE, etc."
        payment_status_enum statut_paiement "PENDING, SUCCEEDED, FAILED, REFUNDED, etc."
        varchar stripe_payment_intent_id UK "Stripe pi_xxx"
        varchar stripe_session_id "Stripe cs_xxx"
        uuid shipping_address_id FK
        uuid billing_address_id FK
        numeric montant_total
        currency_enum devise
        timestamp created_at
    }

    ORDER_ITEMS {
        uuid id PK
        uuid order_id FK
        uuid product_id FK
        varchar nom_produit
        int quantite
        numeric prix_unitaire "Snapshot du prix d'achat"
        numeric total_ligne
    }

    INVOICES {
        uuid id PK
        uuid order_id FK "UNIQUE 1-1"
        varchar numero_facture UK "FACT-2026-0001"
        invoice_status_enum statut "BROUILLON, EMISE, PAYEE, AVOIR_EMIS"
        numeric montant_ht
        numeric montant_tva
        numeric montant_ttc
        text snapshot_adresse_facturation "Snapshot immuable"
        varchar pdf_url "PDF S3/MinIO"
        timestamp date_emission
    }

    INVOICE_ITEMS {
        uuid id PK
        uuid invoice_id FK
        uuid order_item_id FK "Ligne d'origine"
        varchar nom_produit "Snapshot immuable"
        int quantite
        numeric prix_unitaire_ht
        numeric taux_tva "TVA par ligne"
        numeric total_ht
        numeric total_ttc
    }

    PRODUCT_RETURNS {
        uuid id PK
        uuid order_id FK
        uuid user_id FK
        return_status_enum statut "DEMANDEE, APPROUVEE, RECEPTIONNEE, REMBOURSEE, etc."
        return_reason_enum motif "DEFECTUEUX, CASSE_LIVRAISON, CHANGEMENT_AVIS, etc."
        text description
        numeric montant_rembourse
        varchar stripe_refund_id UK "Stripe re_xxx"
        boolean restock_effectue
    }

    RETURN_ITEMS {
        uuid id PK
        uuid return_id FK
        uuid order_item_id FK
        uuid product_id FK
        int quantite "Retour partiel possible"
        boolean remis_en_stock "Restock ligne à ligne"
    }

    REVIEWS {
        uuid id PK
        uuid user_id FK
        uuid product_id FK
        varchar titre
        text description
        int note "1 à 5"
        text reponse_commercant "Modération commerçant"
        timestamp repondu_at
    }

    FOURNISSEURS {
        uuid id PK
        varchar nom
        varchar email
        varchar telephone
        text adresse
    }

    SUPPLY_ORDERS {
        uuid id PK
        uuid fournisseur_id FK
        supply_order_status_enum statut
        numeric montant_total
        timestamp date_emission
        timestamp date_reception
    }

    SUPPLY_ORDER_ITEMS {
        uuid id PK
        uuid supply_order_id FK
        uuid product_id FK
        int quantite
        numeric prix_unitaire
    }

    NOTIFICATIONS {
        uuid id PK
        uuid user_id FK
        varchar titre
        text message
        notification_type_enum type
        boolean est_lu
        timestamp created_at
    }
```

---

## 📁 Contenu des Scripts

- **`01-schema.sql`** : Script DDL complet avec création des extensions UUID, des types ENUM, des tables, contraintes d'intégrité référentielle (`ON DELETE CASCADE / RESTRICT`) et index de recherche.
- **`02-seed.sql`** : Jeu d'essai réaliste pour le MVP :
  - Fournisseurs de mobilier.
  - 5 modèles de canapés avec prix, dimensions, matières et photos HD.
  - Utilisateurs de test : un commerçant administrateur et un client avec identifiant Stripe.
  - Adresses de facturation et de livraison.
  - Commande test avec statut paiement Stripe `SUCCEEDED` et lignes de commande.
  - Factures légales `FACT-2026-0001/0002` (snapshot HT/TVA/TTC, PDF S3) et lignes de facture.
  - Commande livrée avec demande de retour `CASSE_LIVRAISON` et notification `RETOUR_STATUT`.
  - Avis client et réponse publique du commerçant.
