-- models/staging/stg_avis.sql

with source as (
    select * from {{ source('librairies', 'avis') }}
),

nettoyage as (
    select
        id          as avis_id,
        client_id,
        livre_id,
        note,
        case
            when note >= 4 then 'positif'
            when note  = 3 then 'neutre'
            else                'negatif'
        end         as sentiment,
        commentaire,
        date_avis
    from source
    where note between 1 and 5   -- exclure les notes aberrantes
)

select * from nettoyage