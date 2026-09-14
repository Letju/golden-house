# Batch Spark - KPIs Backoffice (MVP)

## 1. Objectif

Calculer en différé les indicateurs du backoffice commerçant à partir des
données transactionnelles PostgreSQL. Le backoffice lit les tables
pré-calculées, aucun calcul à la volée.

## 2. Périmètre MVP

Catalogue restreint aux canapés. Exécution en batch (quotidienne ou
pluri-quotidienne selon la démo). Pas de temps réel.

Hors périmètre : panier, paiement Stripe, suivi de commande en direct.
Ces flux restent sur les micro-services Spring Boot.

## 3. Entrées

Lecture via JDBC depuis PostgreSQL :
- `orders` (statut, montant_total, devise, created_at)
- `order_items` (order_id, product_id, quantite, prix_unitaire, total_ligne)
- `products` (id, nom, prix, stock, seuil_alerte, est_actif)
- `reviews` (product_id, note) pour le calcul optionnel de note moyenne

Seules les commandes au statut `LIVREE` (ou `EXPEDIEE` selon la règle
retenue en équipe) et au paiement `SUCCEEDED` alimentent le chiffre
d'affaires.

## 4. Sorties

Tables pré-calculées lues par le backoffice React :

- `kpi_daily` (date, ca_total, nb_commandes, panier_moyen)
- `kpi_product` (product_id, nom_produit, quantite_vendue, ca_produit,
  note_moyenne, stock_restant, en_rupture)
- `kpi_global` (une ligne : ca_global, nb_commandes_total,
  produit_star_id, taux_rupture)

Définition produit star : `product_id` avec le `ca_produit` maximal sur
la période. Taux de rupture : produits avec `stock = 0` divisé par le
nombre de produits actifs.

## 5. Architecture

- Module batch séparé : Spark Java (même JVM que Spring Boot).
- Exécution en mode local pour le MVP, image Docker sous utilisateur
  non-root.
- Déclenchement par planification (cron ou scheduler), pas par les
  APIs synchrones.
- Écriture idempotente : recalcul complet par période puis upsert sur
  clé (date) ou (product_id, date).

## 6. Étapes suivantes

1. Créer le DDL des tables `kpi_*` dans `backend/database/`.
2. Implémenter le job Spark de lecture et d'agrégation.
3. Exposer les tables via une API Spring de lecture pour le backoffice.
