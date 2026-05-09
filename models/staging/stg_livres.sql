-- models/staging/stg_livres.sql

with source as (
    select * from {{ source('librairies', 'livres') }}
),

nettoyage as (
    select
        id                              as livre_id,
        trim(titre)                     as titre,
        trim(auteur)                    as auteur,
        coalesce(genre, 'Non classé')   as genre,   -- remplacer les nulls
        prix,
        stock,
        prix * stock                    as valeur_stock,
        case
            when stock = 0   then 'epuise'
            when stock < 10  then 'critique'
            when stock < 25  then 'faible'
            else 'ok'
        end                             as alerte_stock
    from source
    where prix > 0                                  -- exclure les prix aberrants
)

select * from nettoyage