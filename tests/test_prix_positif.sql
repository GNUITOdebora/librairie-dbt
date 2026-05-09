-- tests/test_prix_positif.sql
-- Vérifie qu'aucun livre n'a un prix nul ou négatif

select livre_id, titre, prix
from {{ ref('stg_livres') }}