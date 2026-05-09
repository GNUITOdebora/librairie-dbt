-- models/marts/mart_ca_par_genre.sql

with commandes as (
    select * from {{ ref('stg_commandes') }}
    where est_livree = 1                      -- uniquement les commandes livrées
),

lignes as (
    select * from {{ ref('stg_commandes_lignes') }}
),

livres as (
    select * from {{ ref('stg_livres') }}
),

-- Joindre les trois tables
faits as (
    select
        l.genre,
        li.quantite,
        li.montant_ligne
    from lignes li
    join commandes c on li.commande_id = c.commande_id
    join livres l    on li.livre_id    = l.livre_id
)

select
    genre,
    count(*)                        as nb_lignes_vente,
    sum(quantite)                   as unites_vendues,
    round(sum(montant_ligne), 2)    as ca_total,
    round(avg(montant_ligne), 2)    as panier_moyen_ligne
from faits
group by genre
order by ca_total desc