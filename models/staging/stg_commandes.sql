-- models/staging/stg_commandes.sql

with source as (
    select * from {{ source('librairies', 'commandes') }}
),

nettoyage as (
    select
        id              as commande_id,
        client_id,
        date_commande,
        statut,
        year(date_commande)  as annee,
        month(date_commande) as mois_num,
        -- Libellé du mois pour les graphiques
        case month(date_commande)
            when 1  then 'Janvier'   when 2  then 'Fevrier'
            when 3  then 'Mars'      when 4  then 'Avril'
            when 5  then 'Mai'       when 6  then 'Juin'
            when 7  then 'Juillet'   when 8  then 'Aout'
            when 9  then 'Septembre' when 10 then 'Octobre'
            when 11 then 'Novembre'  when 12 then 'Decembre'
        end              as mois_label,
        case when statut = 'livree'   then 1 else 0 end as est_livree,
        case when statut = 'annulee'  then 1 else 0 end as est_annulee
    from source
)

select * from nettoyage