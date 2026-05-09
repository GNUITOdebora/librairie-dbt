-- tests/test_ca_genre_positif.sql
-- Vérifie qu'aucun genre n'a un CA négatif ou nul dans les marts

select genre, ca_total
from {{ ref('mart_ca_par_genre') }}