-- models/marts/mart_top_clients.sql

with clients as (
    select * from {{ ref('stg_clients') }}
),

commandes as (
    select * from {{ ref('stg_commandes') }}
    where est_livree = 1
),

lignes as (
    select * from {{ ref('stg_commandes_lignes') }}
),

-- CA par commande
ca_commandes as (
    select
        c.commande_id,
        c.client_id,
        sum(l.montant_ligne) as montant_commande
    from commandes c
    join lignes l on c.commande_id = l.commande_id
    group by c.commande_id, c.client_id
),

-- Agréger par client
ca_clients as (
    select
        client_id,
        count(commande_id)          as nb_commandes,
        sum(montant_commande)       as ca_total,
        round(avg(montant_commande), 2) as panier_moyen,
        min(montant_commande)       as commande_min,
        max(montant_commande)       as commande_max
    from ca_commandes
    group by client_id
)

select
    cl.nom,
    cl.ville,
    cl.anciennete_jours,
    cc.nb_commandes,
    round(cc.ca_total, 2)   as ca_total,
    cc.panier_moyen,
    case
        when cc.ca_total > 100 then 'Or'
        when cc.ca_total > 50  then 'Argent'
        else                        'Bronze'
    end                     as segment
from ca_clients cc
join clients cl on cc.client_id = cl.client_id
order by ca_total desc