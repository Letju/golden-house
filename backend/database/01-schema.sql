-- =============================================================================
-- GOLDEN HOUSE - DDL SCHEMA POSTGRESQL (MVP)
-- Projet IWA (Ingénierie du Web Avancée 2) - Polytech Montpellier
-- =============================================================================

-- Extension UUID
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- -----------------------------------------------------------------------------
-- ENUMS
-- -----------------------------------------------------------------------------

CREATE TYPE role_enum AS ENUM ('CLIENT', 'COMMERCANT', 'ADMIN');
CREATE TYPE currency_enum AS ENUM ('EUR', 'USD');
CREATE TYPE product_category_enum AS ENUM (
    'CANAPE_DROIT',
    'CANAPE_ANGLE',
    'CANAPE_CONVERTIBLE',
    'FAUTEUIL_LOVESEAT',
    'MODULABLE',
    'VINTAGE'
);
CREATE TYPE material_type_enum AS ENUM (
    'CUIR',
    'VELOURS',
    'TISSU_BOUCLETTE',
    'LIN',
    'MICROFIBRE',
    'BOIS_MASSIF'
);
CREATE TYPE order_status_enum AS ENUM (
    'EN_ATTENTE_PAIEMENT',
    'PAYEE',
    'EN_PREPARATION',
    'EXPEDIEE',
    'LIVREE',
    'RETOUR_EN_COURS',
    'REMBOURSEE',
    'ANNULEE'
);
CREATE TYPE payment_status_enum AS ENUM (
    'PENDING',
    'REQUIRES_ACTION',
    'SUCCEEDED',
    'FAILED',
    'CANCELED',
    'REFUNDED'
);
CREATE TYPE address_type_enum AS ENUM ('LIVRAISON', 'FACTURATION', 'MIXTE');
CREATE TYPE supply_order_status_enum AS ENUM (
    'BROUILLON',
    'EMISE',
    'CONFIRMEE',
    'EXPEDIEE',
    'RECEPTIONNEE',
    'ANNULEE'
);
CREATE TYPE notification_type_enum AS ENUM (
    'COMMANDE_STATUT',
    'RETOUR_STATUT',
    'STOCK_BAS',
    'PROMOTION',
    'SYSTEME'
);
CREATE TYPE invoice_status_enum AS ENUM (
    'BROUILLON',
    'EMISE',
    'PAYEE',
    'AVOIR_EMIS',
    'ANNULEE'
);
CREATE TYPE return_status_enum AS ENUM (
    'DEMANDEE',
    'APPROUVEE',
    'REFUSEE',
    'RECEPTIONNEE',
    'REMBOURSEE',
    'AVOIR_EMIS',
    'CLOTUREE'
);
CREATE TYPE return_reason_enum AS ENUM (
    'DEFECTUEUX',
    'NON_CONFORME',
    'CASSE_LIVRAISON',
    'ERREUR_COULEUR',
    'TAILLE_INADAPTEE',
    'CHANGEMENT_AVIS',
    'AUTRE'
);

-- -----------------------------------------------------------------------------
-- UTILISATEURS & ADRESSES
-- -----------------------------------------------------------------------------

CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    email VARCHAR(255) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    username VARCHAR(100) NOT NULL UNIQUE,
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    phone VARCHAR(30),
    role role_enum NOT NULL DEFAULT 'CLIENT',
    currency currency_enum NOT NULL DEFAULT 'EUR',
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE addresses (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    type address_type_enum NOT NULL DEFAULT 'LIVRAISON',
    street VARCHAR(255) NOT NULL,
    complement VARCHAR(255),
    postal_code VARCHAR(20) NOT NULL,
    city VARCHAR(100) NOT NULL,
    country VARCHAR(100) NOT NULL DEFAULT 'France',
    is_default BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- -----------------------------------------------------------------------------
-- FOURNISSEURS (REAPPROVISIONNEMENT & GESTION DU STOCK)
-- -----------------------------------------------------------------------------

CREATE TABLE fournisseurs (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    nom VARCHAR(255) NOT NULL,
    email VARCHAR(255) NOT NULL,
    telephone VARCHAR(30),
    adresse TEXT,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- -----------------------------------------------------------------------------
-- CATALOGUE PRODUITS (MVP CANAPÉS & DÉCORATION)
-- -----------------------------------------------------------------------------

CREATE TABLE products (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    nom VARCHAR(255) NOT NULL,
    description TEXT NOT NULL,
    prix NUMERIC(10, 2) NOT NULL CHECK (prix >= 0),
    categorie product_category_enum NOT NULL,
    type_matiere material_type_enum NOT NULL,
    couleur VARCHAR(50) NOT NULL,
    largeur_cm INT NOT NULL CHECK (largeur_cm > 0),
    hauteur_cm INT NOT NULL CHECK (hauteur_cm > 0),
    profondeur_cm INT NOT NULL CHECK (profondeur_cm > 0),
    stock INT NOT NULL DEFAULT 0 CHECK (stock >= 0),
    seuil_alerte INT NOT NULL DEFAULT 5 CHECK (seuil_alerte >= 0),
    images TEXT[] DEFAULT '{}',
    fournisseur_id UUID REFERENCES fournisseurs(id) ON DELETE SET NULL,
    est_actif BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_products_categorie ON products(categorie);
CREATE INDEX idx_products_prix ON products(prix);
CREATE INDEX idx_products_couleur ON products(couleur);

-- -----------------------------------------------------------------------------
-- PANIER D'ACHAT
-- -----------------------------------------------------------------------------

CREATE TABLE carts (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL UNIQUE REFERENCES users(id) ON DELETE CASCADE,
    code_promo VARCHAR(50),
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE cart_items (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    cart_id UUID NOT NULL REFERENCES carts(id) ON DELETE CASCADE,
    product_id UUID NOT NULL REFERENCES products(id) ON DELETE CASCADE,
    quantite INT NOT NULL DEFAULT 1 CHECK (quantite > 0),
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uq_cart_product UNIQUE (cart_id, product_id)
);

-- -----------------------------------------------------------------------------
-- COMMANDES & PAIEMENT STRIPE
-- -----------------------------------------------------------------------------

CREATE TABLE orders (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    order_number VARCHAR(50) NOT NULL UNIQUE,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
    statut order_status_enum NOT NULL DEFAULT 'EN_ATTENTE_PAIEMENT',
    statut_paiement payment_status_enum NOT NULL DEFAULT 'PENDING',
    stripe_payment_intent_id VARCHAR(255) UNIQUE, -- ID PaymentIntent Stripe (pi_xxx)
    stripe_session_id VARCHAR(255),                -- Session Checkout Stripe (cs_xxx)
    shipping_address_id UUID NOT NULL REFERENCES addresses(id) ON DELETE RESTRICT,
    billing_address_id UUID NOT NULL REFERENCES addresses(id) ON DELETE RESTRICT,
    montant_total NUMERIC(10, 2) NOT NULL CHECK (montant_total >= 0),
    devise currency_enum NOT NULL DEFAULT 'EUR',
    code_promo_applique VARCHAR(50),
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_orders_user_id ON orders(user_id);
CREATE INDEX idx_orders_statut ON orders(statut);

CREATE TABLE order_items (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    order_id UUID NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
    product_id UUID NOT NULL REFERENCES products(id) ON DELETE RESTRICT,
    nom_produit VARCHAR(255) NOT NULL,
    quantite INT NOT NULL CHECK (quantite > 0),
    prix_unitaire NUMERIC(10, 2) NOT NULL CHECK (prix_unitaire >= 0),
    total_ligne NUMERIC(10, 2) NOT NULL CHECK (total_ligne >= 0),
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- -----------------------------------------------------------------------------
-- FACTURATION LEGALE (DOCUMENT IMMUABLE 1-1 AVEC LA COMMANDE)
-- Une facture fige les montants HT/TVA/TTC et l'adresse au moment du paiement.
-- On ne modifie jamais une facture EMISE : un retour approuve donne un avoir.
-- -----------------------------------------------------------------------------

CREATE TABLE invoices (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    order_id UUID NOT NULL UNIQUE REFERENCES orders(id) ON DELETE RESTRICT,
    numero_facture VARCHAR(50) NOT NULL UNIQUE, -- ex FACT-2026-0001 (sequence legale continue)
    statut invoice_status_enum NOT NULL DEFAULT 'BROUILLON',
    montant_ht NUMERIC(10, 2) NOT NULL CHECK (montant_ht >= 0),
    montant_tva NUMERIC(10, 2) NOT NULL CHECK (montant_tva >= 0),
    montant_ttc NUMERIC(10, 2) NOT NULL CHECK (montant_ttc >= 0),
    devise currency_enum NOT NULL DEFAULT 'EUR',
    snapshot_adresse_facturation TEXT NOT NULL, -- snapshot immuable (l'adresse peut evoluer)
    pdf_url VARCHAR(500), -- objet S3/MinIO du PDF legal
    stripe_payment_intent_id VARCHAR(255), -- PaymentIntent d'origine (pi_xxx)
    date_emission TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    date_echeance TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_invoices_order_id ON invoices(order_id);
CREATE INDEX idx_invoices_statut ON invoices(statut);

-- Note MVP : pas de table invoice_items. La facture est en 1-1 avec la
-- commande, ses lignes se deduisent de order_items par jointure order_id.
-- (A reintroduire si avoirs partiels complexes : TVA par ligne figee.)

-- -----------------------------------------------------------------------------
-- RETOURS PRODUITS MONO-LIGNE (DEMANDE CLIENT, REMBOURSEMENT STRIPE, RESTOCK)
-- Format MVP : un retour = une ligne de commande (produit + quantite).
-- Un retour multi-produits = plusieurs demandes. Workflow :
-- DEMANDEE -> APPROUVEE/REFUSEE -> RECEPTIONNEE -> REMBOURSEE/AVOIR_EMIS -> CLOTUREE
-- -----------------------------------------------------------------------------

CREATE TABLE product_returns (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    order_id UUID NOT NULL REFERENCES orders(id) ON DELETE RESTRICT,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
    order_item_id UUID NOT NULL REFERENCES order_items(id) ON DELETE RESTRICT,
    product_id UUID NOT NULL REFERENCES products(id) ON DELETE RESTRICT,
    quantite INT NOT NULL DEFAULT 1 CHECK (quantite > 0),
    statut return_status_enum NOT NULL DEFAULT 'DEMANDEE',
    motif return_reason_enum NOT NULL,
    description TEXT,
    montant_rembourse NUMERIC(10, 2) CHECK (montant_rembourse >= 0),
    devise currency_enum NOT NULL DEFAULT 'EUR',
    stripe_refund_id VARCHAR(255) UNIQUE, -- remboursement Stripe (re_xxx)
    remis_en_stock BOOLEAN NOT NULL DEFAULT FALSE, -- restock (exclu si defectueux)
    decide_par VARCHAR(255), -- gestionnaire ayant statue sur la demande
    decide_le TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_returns_order_id ON product_returns(order_id);
CREATE INDEX idx_returns_user_id ON product_returns(user_id);
CREATE INDEX idx_returns_statut ON product_returns(statut);

-- -----------------------------------------------------------------------------
-- AVIS CLIENTS & MODERATION
-- -----------------------------------------------------------------------------

CREATE TABLE reviews (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    product_id UUID NOT NULL REFERENCES products(id) ON DELETE CASCADE,
    titre VARCHAR(150) NOT NULL,
    description TEXT NOT NULL,
    note INT NOT NULL CHECK (note BETWEEN 1 AND 5),
    reponse_commercant TEXT,
    repondu_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uq_review_user_product UNIQUE (user_id, product_id)
);

-- -----------------------------------------------------------------------------
-- NOTIFICATIONS
-- -----------------------------------------------------------------------------

CREATE TABLE notifications (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    titre VARCHAR(255) NOT NULL,
    message TEXT NOT NULL,
    type notification_type_enum NOT NULL DEFAULT 'SYSTEME',
    est_lu BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_notifications_user_lu ON notifications(user_id, est_lu);

-- -----------------------------------------------------------------------------
-- REAPPROVISIONNEMENTS FOURNISSEURS (COMMANDES FOURNISSEUR)
-- -----------------------------------------------------------------------------

CREATE TABLE supply_orders (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    fournisseur_id UUID NOT NULL REFERENCES fournisseurs(id) ON DELETE RESTRICT,
    statut supply_order_status_enum NOT NULL DEFAULT 'BROUILLON',
    montant_total NUMERIC(10, 2) CHECK (montant_total >= 0),
    date_emission TIMESTAMP WITH TIME ZONE,
    date_reception TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE supply_order_items (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    supply_order_id UUID NOT NULL REFERENCES supply_orders(id) ON DELETE CASCADE,
    product_id UUID NOT NULL REFERENCES products(id) ON DELETE RESTRICT,
    quantite INT NOT NULL CHECK (quantite > 0),
    prix_unitaire NUMERIC(10, 2) CHECK (prix_unitaire >= 0),
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP
);
