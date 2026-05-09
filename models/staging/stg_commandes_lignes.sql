-- models/staging/stg_commandes_lignes.sql

with source as (
    select * from {{ source('librairies', 'commandes_lignes') }}
),

nettoyage as (
    select
        id              as ligne_id,
        commande_id,
        livre_id,
        quantite,
        prix_unitaire,
        quantite * prix_unitaire  as montant_ligne   -- colonne calculée centrale
    from source
    where quantite > 0
      and prix_unitaire > 0
)

select * from nettoyage