-- tests/test_montant_coherent.sql
-- Vérifie que montant_ligne = quantite * prix_unitaire (cohérence interne)

select
    ligne_id,
    quantite,
    prix_unitaire,
    montant_ligne,
    round(quantite * prix_unitaire, 2) as montant_attendu
from {{ ref('stg_commandes_lignes') }}