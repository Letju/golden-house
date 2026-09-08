# Consignes du Projet IWA (Ingénierie du Web Avancée 2)

Enseignant : Christophe Nauroy  
Formation : Polytech Montpellier - IG5 / DaMS (Semestre 9)

## 1. Sujet du projet

Développement d'une solution m-commerce de vente directe, avec une application mobile disponible à terme sur App Store et Google Play.

Thématique du commerce libre, dans le domaine du légal.

### Contraintes d'architecture et de technologies

L'équipe ne disposant pas de compétences natives iOS dédiées ni de machines de développement macOS, le choix d'une technologie multiplateforme est imposé et doit être formellement justifié.

La solution globale doit comprendre :
1. Une application mobile destinée aux acheteurs (technologie multiplateforme justifiée).
2. Un frontend web backoffice pour les commerçants (technologie au choix et justifiée).
3. Un backend conçu selon une architecture micro-services majoritairement développé avec le framework Spring.
4. Une interface MCP (Model Context Protocol) intégrée à la solution.

---

## 2. Démarche et attendus initiaux

1. **Cahier des charges fonctionnel** :
   - Définir les fonctionnalités nécessaires pour l'acheteur et pour le commerçant.
   - Prévoir un tableau de bord KPI sur le backoffice commerçant.
   - Spécifier l'intégration et l'interface MCP.
   - Délimiter un périmètre restreint pour le MVP (Minimum Viable Product).
   - Représentations UML recommandées (cas d'utilisation, séquence, classes).

2. **Maquettage des interfaces** :
   - Maquettage des parcours de l'application mobile acheteur.
   - Maquettage du backoffice commerçant web (Figma recommandé).

3. **Organisation des données** :
   - Choix et justification du stockage (SGBDR relationnel, NoSQL éventuel, stockage d'images et médias).
   - Modélisation conceptuelle et logique (MCD, MLD).

4. **Organisation et rétroplanning** :
   - Découpage des tâches et planification du projet (suite à la présentation de l'architecture micro-services).
