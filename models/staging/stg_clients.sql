with source as (
    select * from {{ source('librairies', 'clients') }}
),

nettoyage as (
    select
        id as client_id,
        trim(nom) as nom,
        lower(trim(email)) as email,

        concat(
            upper(left(trim(ville), 1)),
            lower(substring(trim(ville), 2))
        ) as ville,

        date_inscription,
        datediff(curdate(), date_inscription) as anciennete_jours

    from source
    where email is not null
)

select * from nettoyage