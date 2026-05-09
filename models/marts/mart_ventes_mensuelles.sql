-- models/marts/mart_ventes_mensuelles.sql

with commandes as (
    select * from {{ ref('stg_commandes') }}
    where est_livree = 1
),

lignes as (
    select * from {{ ref('stg_commandes_lignes') }}
),

mensuel as (
    select
        c.annee,
        c.mois_num,
        c.mois_label,
        count(distinct c.commande_id)   as nb_commandes,
        count(distinct c.client_id)     as nb_clients_actifs,
        sum(l.quantite)                 as unites_vendues,
        round(sum(l.montant_ligne), 2)  as ca_mensuel
    from commandes c
    join lignes l on c.commande_id = l.commande_id
    group by c.annee, c.mois_num, c.mois_label
)

select
    annee,
    mois_num,
    mois_label,
    nb_commandes,
    nb_clients_actifs,
    unites_vendues,
    ca_mensuel,
    -- CA cumulé calculé en SQL pur (compatible MySQL)
    round(
        sum(ca_mensuel) over (
            partition by annee
            order by mois_num
        ), 2
    ) as ca_cumule_annee
from mensuel
order by annee, mois_num