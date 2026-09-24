-- =============================================================================
-- GOLDEN HOUSE - SEED DATA (MVP TEST DATA)
-- Données initiales pour le prototype MVP Canapés & Mobilier
-- =============================================================================

-- -----------------------------------------------------------------------------
-- 1. FOURNISSEURS
-- -----------------------------------------------------------------------------
INSERT INTO fournisseurs (id, nom, email, telephone, adresse) VALUES
('11111111-1111-1111-1111-111111111111', 'Atelier Scandinave Nord', 'contact@atelierscandi.fr', '+33 4 67 00 11 22', '12 Rue des Ebénistes, 59000 Lille'),
('22222222-2222-2222-2222-222222222222', 'Manufacture Cuir & Bois', 'appro@cuirbois-design.com', '+33 4 99 33 44 55', '45 Avenue de l Artisanat, 34000 Montpellier')
ON CONFLICT (id) DO NOTHING;

-- -----------------------------------------------------------------------------
-- 2. UTILISATEURS (Commerçant & Client)
-- Mots de passe hashés (BCrypt pour Spring Security - ex: 'Password123!')
-- -----------------------------------------------------------------------------
INSERT INTO users (id, email, password_hash, username, first_name, last_name, phone, role, currency, stripe_customer_id, is_active) VALUES
('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'admin@goldenhouse.fr', '$2a$12$e8Y6Bqj7e5zT7rE5D6h4Xu7.K7U6dGf0B9gZ4t6X7t4J8t0B9gZ4t', 'admin_golden', 'Sophie', 'Marchand', '+33 6 12 34 56 78', 'COMMERCANT', 'EUR', NULL, TRUE),
('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', 'client@test.fr', '$2a$12$e8Y6Bqj7e5zT7rE5D6h4Xu7.K7U6dGf0B9gZ4t6X7t4J8t0B9gZ4t', 'justin_c', 'Justin', 'Chapon', '+33 6 98 76 54 32', 'CLIENT', 'EUR', 'cus_test_123456789', TRUE)
ON CONFLICT (id) DO NOTHING;

-- -----------------------------------------------------------------------------
-- 3. ADRESSES
-- -----------------------------------------------------------------------------
INSERT INTO addresses (id, user_id, type, street, complement, postal_code, city, country, is_default) VALUES
('a0000001-0000-0000-0000-000000000001', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', 'LIVRAISON', 'Place Eugène Bataillon', 'Polytech Montpellier - IG5', '34095', 'Montpellier', 'France', TRUE),
('a0000002-0000-0000-0000-000000000002', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', 'FACTURATION', '10 Boulevard du Jeu de Paume', 'Appartement 4B', '34000', 'Montpellier', 'France', FALSE)
ON CONFLICT (id) DO NOTHING;

-- -----------------------------------------------------------------------------
-- 4. PRODUITS (CATALOGUE MVP : CANAPÉS)
-- -----------------------------------------------------------------------------
INSERT INTO products (id, nom, description, prix, categorie, type_matiere, couleur, largeur_cm, hauteur_cm, profondeur_cm, stock, seuil_alerte, images, fournisseur_id, est_actif) VALUES
(
    'c0000001-0000-0000-0000-000000000001',
    'Canapé d''Angle Velours Céleste',
    'Canapé d''angle panoramique haut de gamme au revêtement velours royal déperlant. Assise profonde et mousse haute résilience 35kg/m3.',
    1299.00,
    'CANAPE_ANGLE',
    'VELOURS',
    'Bleu Nuit',
    280,
    85,
    165,
    8,
    3,
    ARRAY['https://images.unsplash.com/photo-1555041469-a586c61ea9bc?auto=format&fit=crop&w=1000&q=80', 'https://images.unsplash.com/photo-1493663284031-b7e3aefcae8e?auto=format&fit=crop&w=1000&q=80'],
    '11111111-1111-1111-1111-111111111111',
    TRUE
),
(
    'c0000002-0000-0000-0000-000000000002',
    'Fauteuil Loveseat Bouclette Cocoon',
    'Banquette loveseat 2 places au design organique enveloppant en tissu texturé bouclette blanche. Idéal pour salons contemporains.',
    649.00,
    'FAUTEUIL_LOVESEAT',
    'TISSU_BOUCLETTE',
    'Blanc Crème',
    140,
    78,
    90,
    14,
    4,
    ARRAY['https://images.unsplash.com/photo-1586023492125-27b2c045efd7?auto=format&fit=crop&w=1000&q=80'],
    '11111111-1111-1111-1111-111111111111',
    TRUE
),
(
    'c0000003-0000-0000-0000-000000000003',
    'Canapé Convertible Express Oslo',
    'Canapé convertible 3 places scandinave avec couchage quotidien 140x190cm mémoire de forme et ouverture express sans retirer les coussins.',
    899.00,
    'CANAPE_CONVERTIBLE',
    'LIN',
    'Gris Anthracite',
    205,
    90,
    98,
    5,
    2,
    ARRAY['https://images.unsplash.com/photo-1540574163026-643ea20ade25?auto=format&fit=crop&w=1000&q=80'],
    '22222222-2222-2222-2222-222222222222',
    TRUE
),
(
    'c0000004-0000-0000-0000-000000000004',
    'Canapé Droit Cuir Vintage Chesterfield',
    'Le grand classique Chesterfield en cuir pleine fleur vieilli fait main, capitonnage traditionnel et pieds en bois massif ciré.',
    1790.00,
    'VINTAGE',
    'CUIR',
    'Cognac',
    220,
    76,
    95,
    3,
    2,
    ARRAY['https://images.unsplash.com/photo-1550581190-9c1c48d21d6c?auto=format&fit=crop&w=1000&q=80'],
    '22222222-2222-2222-2222-222222222222',
    TRUE
),
(
    'c0000005-0000-0000-0000-000000000005',
    'Canapé Modulable 4 Modules Cloud',
    'Système de canapé entièrement modulable à assembler selon vos envies. Confort duvet d oie et tissu résistant aux taches.',
    2150.00,
    'MODULABLE',
    'MICROFIBRE',
    'Taupe',
    310,
    72,
    110,
    2,
    2,
    ARRAY['https://images.unsplash.com/photo-1493663284031-b7e3aefcae8e?auto=format&fit=crop&w=1000&q=80'],
    '11111111-1111-1111-1111-111111111111',
    TRUE
)
ON CONFLICT (id) DO NOTHING;

-- -----------------------------------------------------------------------------
-- 5. AVIS CLIENTS & RÉPONSES
-- -----------------------------------------------------------------------------
INSERT INTO reviews (id, user_id, product_id, titre, description, note, reponse_commercant, repondu_at) VALUES
(
    'e0000001-0000-0000-0000-000000000001',
    'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb',
    'c0000001-0000-0000-0000-000000000001',
    'Superbe confort et tissu très doux',
    'Reçu en avance, livraison très professionnelle dans le salon. Le bleu nuit est magnifique sous une lumière naturelle.',
    5,
    'Merci beaucoup pour votre retour Justin ! Nous sommes ravis que la couleur s intègre parfaitement à votre intérieur.',
    CURRENT_TIMESTAMP
)
ON CONFLICT (id) DO NOTHING;

-- -----------------------------------------------------------------------------
-- 6. COMMANDE TEST (AVEC PAIEMENT STRIPE RÉUSSI)
-- -----------------------------------------------------------------------------
INSERT INTO orders (id, order_number, user_id, statut, statut_paiement, stripe_payment_intent_id, stripe_session_id, shipping_address_id, billing_address_id, montant_total, devise, code_promo_applique) VALUES
(
    'd0000001-0000-0000-0000-000000000001',
    'CMD-2026-0001',
    'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb',
    'EN_PREPARATION',
    'SUCCEEDED',
    'pi_test_3N9xJkLkd82LsmQ81JkaopLq',
    'cs_test_a1b2c3d4e5f6',
    'a0000001-0000-0000-0000-000000000001',
    'a0000002-0000-0000-0000-000000000002',
    1299.00,
    'EUR',
    NULL
)
ON CONFLICT (id) DO NOTHING;

INSERT INTO order_items (id, order_id, product_id, nom_produit, quantite, prix_unitaire, total_ligne) VALUES
(
    'f0000001-0000-0000-0000-000000000001',
    'd0000001-0000-0000-0000-000000000001',
    'c0000001-0000-0000-0000-000000000001',
    'Canapé d''Angle Velours Céleste',
    1,
    1299.00,
    1299.00
)
ON CONFLICT (id) DO NOTHING;

-- -----------------------------------------------------------------------------
-- 7. NOTIFICATION CLIENT
-- -----------------------------------------------------------------------------
INSERT INTO notifications (id, user_id, titre, message, type, est_lu) VALUES
(
    'f1000001-0000-0000-0000-000000000001',
    'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb',
    'Commande confirmée !',
    'Votre commande CMD-2026-0001 est en cours de préparation dans nos ateliers.',
    'COMMANDE_STATUT',
    FALSE
)
ON CONFLICT (id) DO NOTHING;

-- -----------------------------------------------------------------------------
-- 8. FACTURES LEGALES (SNAPSHOT IMMUABLE HT/TVA/TTC, TVA 20 %)
-- CMD-2026-0001 : 1299.00 TTC = 1082.50 HT + 216.50 TVA
-- -----------------------------------------------------------------------------
INSERT INTO invoices (id, order_id, numero_facture, statut, montant_ht, montant_tva, montant_ttc, devise, snapshot_adresse_facturation, pdf_url, stripe_payment_intent_id, date_emission, date_echeance) VALUES
(
    '10000001-0000-0000-0000-000000000001',
    'd0000001-0000-0000-0000-000000000001',
    'FACT-2026-0001',
    'PAYEE',
    1082.50,
    216.50,
    1299.00,
    'EUR',
    'Justin Chapon, 10 Boulevard du Jeu de Paume, Appartement 4B, 34000 Montpellier, France',
    's3://golden-house/invoices/FACT-2026-0001.pdf',
    'pi_test_3N9xJkLkd82LsmQ81JkaopLq',
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP + INTERVAL '30 days'
)
ON CONFLICT (id) DO NOTHING;

-- Note MVP : pas de invoice_items, les lignes se deduisent de order_items.

-- -----------------------------------------------------------------------------
-- 9. COMMANDE LIVREE + RETOUR PRODUIT (CASSE LIVRAISON, EN ATTENTE D'INSTRUCTION)
-- CMD-2026-0002 : 899.00 TTC = 749.17 HT + 149.83 TVA
-- -----------------------------------------------------------------------------
INSERT INTO orders (id, order_number, user_id, statut, statut_paiement, stripe_payment_intent_id, stripe_session_id, shipping_address_id, billing_address_id, montant_total, devise, code_promo_applique) VALUES
(
    'd0000002-0000-0000-0000-000000000002',
    'CMD-2026-0002',
    'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb',
    'RETOUR_EN_COURS',
    'SUCCEEDED',
    'pi_test_7Q2mRtVbn45PswE12MnbvcXz',
    'cs_test_g7h8i9j0k1l2',
    'a0000001-0000-0000-0000-000000000001',
    'a0000002-0000-0000-0000-000000000002',
    899.00,
    'EUR',
    NULL
)
ON CONFLICT (id) DO NOTHING;

INSERT INTO order_items (id, order_id, product_id, nom_produit, quantite, prix_unitaire, total_ligne) VALUES
(
    'f0000002-0000-0000-0000-000000000002',
    'd0000002-0000-0000-0000-000000000002',
    'c0000003-0000-0000-0000-000000000003',
    'Canapé Convertible Express Oslo',
    1,
    899.00,
    899.00
)
ON CONFLICT (id) DO NOTHING;

INSERT INTO invoices (id, order_id, numero_facture, statut, montant_ht, montant_tva, montant_ttc, devise, snapshot_adresse_facturation, pdf_url, stripe_payment_intent_id, date_emission, date_echeance) VALUES
(
    '10000002-0000-0000-0000-000000000002',
    'd0000002-0000-0000-0000-000000000002',
    'FACT-2026-0002',
    'PAYEE',
    749.17,
    149.83,
    899.00,
    'EUR',
    'Justin Chapon, 10 Boulevard du Jeu de Paume, Appartement 4B, 34000 Montpellier, France',
    's3://golden-house/invoices/FACT-2026-0002.pdf',
    'pi_test_7Q2mRtVbn45PswE12MnbvcXz',
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP + INTERVAL '30 days'
)
ON CONFLICT (id) DO NOTHING;

INSERT INTO product_returns (id, order_id, user_id, order_item_id, product_id, quantite, statut, motif, description, devise, remis_en_stock) VALUES
(
    'b0000001-0000-0000-0000-000000000001',
    'd0000002-0000-0000-0000-000000000002',
    'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb',
    'f0000002-0000-0000-0000-000000000002',
    'c0000003-0000-0000-0000-000000000003',
    1,
    'DEMANDEE',
    'CASSE_LIVRAISON',
    'Pied arrière droit fissuré constaté à la livraison, photos transmises au service client.',
    'EUR',
    FALSE
)
ON CONFLICT (id) DO NOTHING;

INSERT INTO notifications (id, user_id, titre, message, type, est_lu) VALUES
(
    'f1000002-0000-0000-0000-000000000002',
    'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb',
    'Demande de retour enregistrée',
    'Votre demande de retour pour la commande CMD-2026-0002 est en cours d examen par notre équipe.',
    'RETOUR_STATUT',
    FALSE
)
ON CONFLICT (id) DO NOTHING;
