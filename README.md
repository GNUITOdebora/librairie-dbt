# 📚 librairie_dbt

Projet **dbt Core** d'analyse des données d'une librairie en ligne.  
Transforme les tables MySQL brutes en modèles analytiques testés et documentés.

---

## Stack technique

| Outil | Version | Rôle |
|---|---|---|
| MySQL | 8.0 | Base de données source |
| dbt Core | 1.7.9 | Transformation & orchestration SQL |
| dbt-mysql | 1.7.0 | Adaptateur MySQL pour dbt |
| Python | 3.10 | Environnement d'exécution |
| conda | — | Gestion de l'environnement |

---

## Architecture du projet

```
Sources MySQL          Staging (vues)               Marts (tables)
──────────────         ─────────────────            ──────────────────────────
clients           →    stg_clients             →
livres            →    stg_livres              →    mart_ca_par_genre
commandes         →    stg_commandes           →    mart_top_clients
commandes_lignes  →    stg_commandes_lignes    →    mart_ventes_mensuelles
avis              →    stg_avis                →
```

**Couche staging** — une vue par table source : nettoyage, renommage, colonnes calculées.  
**Couche marts** — tables agrégées prêtes pour dashboards et analyses.

---

## Prérequis

- Python ≥ 3.10 avec conda ou venv
- MySQL 8 en local avec la base `librairies`
- git

---

## Installation

### 1. Cloner le projet

```bash
git clone https://github.com/VOTRE_USERNAME/librairie_dbt.git
cd librairie_dbt
```

### 2. Créer l'environnement Python

```bash
conda create -n dbt_env python=3.10
conda activate dbt_env
pip install dbt-core==1.7.0 dbt-mysql==1.7.0
```

### 3. Configurer la connexion MySQL

Créez `~/.dbt/profiles.yml` — ce fichier ne doit **jamais** être commité :

```yaml
librairie_dbt:
  target: dev
  outputs:
    dev:
      type: mysql
      server: "{{ env_var('DBT_MYSQL_HOST', 'localhost') }}"
      port: 3306
      schema: "{{ env_var('DBT_MYSQL_SCHEMA', 'librairies') }}"
      username: "{{ env_var('DBT_MYSQL_USER') }}"
      password: "{{ env_var('DBT_MYSQL_PASSWORD') }}"
      threads: 1
```

### 4. Déclarer les variables d'environnement

Créez un fichier `.env` à la racine du projet (ignoré par git) :

```bash
export DBT_MYSQL_HOST=localhost
export DBT_MYSQL_SCHEMA=librairies
export DBT_MYSQL_USER=votre_user
export DBT_MYSQL_PASSWORD=votre_mot_de_passe
```

Puis chargez-les :

```bash
source .env
```

### 5. Vérifier la connexion

```bash
dbt debug
# → All checks passed!
```

---

## Utilisation

```bash
# Exécuter tous les modèles
dbt run

# Lancer tous les tests
dbt test

# Run + Test en une seule commande (recommandé)
dbt build

# Cibler un modèle ou une couche précise
dbt run  --select mart_top_clients
dbt run  --select staging.*
dbt run  --select +mart_ca_par_genre    # modèle + toutes ses dépendances
dbt test --select stg_clients

# Générer et consulter la documentation
dbt docs generate
dbt docs serve
# → Ouvrir http://localhost:8080
```

---

## Modèles

### Staging

| Modèle | Source | Transformations clés |
|---|---|---|
| `stg_clients` | `clients` | Email en minuscules, calcul ancienneté en jours |
| `stg_livres` | `livres` | Valeur stock (prix × stock), alerte niveau stock |
| `stg_commandes` | `commandes` | Extraction année/mois, flags `est_livree` / `est_annulee` |
| `stg_commandes_lignes` | `commandes_lignes` | Calcul `montant_ligne` (quantité × prix unitaire) |
| `stg_avis` | `avis` | Classification sentiment (positif / neutre / négatif) |

### Marts

| Modèle | Description | Métriques principales |
|---|---|---|
| `mart_ca_par_genre` | CA agrégé par genre littéraire | `ca_total`, `unites_vendues`, `panier_moyen_ligne` |
| `mart_top_clients` | Classement clients par dépenses totales | `ca_total`, `nb_commandes`, segment `Bronze/Argent/Or` |
| `mart_ventes_mensuelles` | Évolution mensuelle des ventes | `ca_mensuel`, `ca_cumule_annee`, `nb_clients_actifs` |

---

## Tests

52 tests automatiques, 0 erreur.

```
Done. PASS=52 WARN=0 ERROR=0 SKIP=0 TOTAL=52
```

### Tests génériques (schema.yml)

| Type | Vérifie | Appliqué sur |
|---|---|---|
| `not_null` | Aucune valeur NULL | Toutes les colonnes clés |
| `unique` | Pas de doublons | Clés primaires, emails |
| `accepted_values` | Valeurs dans une liste autorisée | `statut`, `alerte_stock`, `sentiment`, `segment` |
| `relationships` | Intégrité référentielle | Toutes les clés étrangères |

### Tests singuliers (tests/)

| Fichier | Règle métier vérifiée |
|---|---|
| `test_prix_positif.sql` | Aucun livre avec prix ≤ 0 |
| `test_montant_coherent.sql` | `montant_ligne` = `quantite × prix_unitaire` |
| `test_ca_genre_positif.sql` | CA par genre toujours positif |

---

## Sécurité

| Élément sensible | Protection |
|---|---|
| `profiles.yml` | Stocké dans `~/.dbt/` — hors du repo git |
| Mots de passe | Variables d'environnement via `env_var()` |
| Fichier `.env` | Listé dans `.gitignore` — jamais commité |
| `target/` | Ignoré par git — contient les fichiers compilés |

---

## Structure du projet

```
librairie_dbt/
├── .gitignore
├── README.md
├── dbt_project.yml
├── models/
│   ├── staging/
│   │   ├── sources.yml               # 5 sources MySQL déclarées
│   │   ├── schema.yml                # tests + descriptions staging
│   │   ├── stg_clients.sql
│   │   ├── stg_livres.sql
│   │   ├── stg_commandes.sql
│   │   ├── stg_commandes_lignes.sql
│   │   └── stg_avis.sql
│   └── marts/
│       ├── schema.yml                # tests + descriptions marts
│       ├── mart_ca_par_genre.sql
│       ├── mart_top_clients.sql
│       └── mart_ventes_mensuelles.sql
└── tests/
    ├── test_prix_positif.sql
    ├── test_montant_coherent.sql
    └── test_ca_genre_positif.sql
```

---

## Parcours d'apprentissage

Ce projet s'inscrit dans un parcours Data Engineering complet :

```
SQL (MySQL)  →  Python  →  Pandas  →  Matplotlib  →  dbt  →  ...
```

Prochaines étapes envisagées : orchestration avec **Airflow**, containerisation avec **Docker**.

---

## Auteur

**Debora** · projet pédagogique Data Engineering  
Linux · Python 3.10 · miniconda · dbt Core 1.7
