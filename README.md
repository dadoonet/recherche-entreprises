# recherche-entreprises

Ce projet permet de générer un index Elastic Search qui regroupe toutes les informations utiles pour rechercher une entreprise par établissement, raison sociale, code postal, ville, siret/siren, effectif, convention collective...

Les données sont issues de [plusieurs jeux de données data.gouv.fr](./assembly/scripts/get-data.sh) et de [kali-data](https://github.com/SocialGouv/kali-data).

Le dossier [`api`](./api) présente un exemple d'implémentation d'API NodeJS qui exploite cet index Elastic Search avec différentes requêtes.

Un frontend de démo est disponible ici : https://p8dyl.csb.app/

Et vous pouvez utiliser librement l'API disponible sur https://api-recherche-entreprises.fabrique.social.gouv.fr cf [doc API](./api/README.md)

Exemple : [/api/v1/search?q=plume&a=paris](https://api-recherche-entreprises.fabrique.social.gouv.fr/api/v1/search?q=plume&a=paris)


## Étapes :

[![](https://mermaid.ink/img/eyJjb2RlIjoiZ3JhcGggTFJcblxuU3RvY2tVbml0ZUxlZ2FsZS5jc3YtLT5TUUxpdGVcbmdlb19zaXJldC5jc3YtLT5TUUxpdGVcbnNpcmV0MmlkY2MuY3N2LS0-U1FMaXRlXG5TUUxpdGUtLT5hc3NlbWJseS5jc3ZcbmFzc2VtYmx5LmNzdi0tPmluZGV4LS0-RWxhc3RpY1NlYXJjaC0tPkFQSVtBUEkgSFRUUDFdXG5FbGFzdGljU2VhcmNoLS0-QVBJMltBUEkgSFRUUDJdXG5FbGFzdGljU2VhcmNoLS0-Q2xpZW50W0NsaWVudCBFU10iLCJtZXJtYWlkIjp7fSwidXBkYXRlRWRpdG9yIjpmYWxzZSwiYXV0b1N5bmMiOnRydWUsInVwZGF0ZURpYWdyYW0iOmZhbHNlfQ)](https://mermaid-js.github.io/mermaid-live-editor/edit#eyJjb2RlIjoiZ3JhcGggTFJcblxuU3RvY2tVbml0ZUxlZ2FsZS5jc3YtLT5TUUxpdGVcbmdlb19zaXJldC5jc3YtLT5TUUxpdGVcbnNpcmV0MmlkY2MuY3N2LS0-U1FMaXRlXG5TUUxpdGUtLT5hc3NlbWJseS5jc3ZcbmFzc2VtYmx5LmNzdi0tPmluZGV4LS0-RWxhc3RpY1NlYXJjaC0tPkFQSVtBUEkgSFRUUDFdXG5FbGFzdGljU2VhcmNoLS0-QVBJMltBUEkgSFRUUDJdXG5FbGFzdGljU2VhcmNoLS0-Q2xpZW50W0NsaWVudCBFU10iLCJtZXJtYWlkIjoie30iLCJ1cGRhdGVFZGl0b3IiOmZhbHNlLCJhdXRvU3luYyI6dHJ1ZSwidXBkYXRlRGlhZ3JhbSI6ZmFsc2V9)

## Données :

| Dataset                                                                                                                                                                        | usage                                                    |
| ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ | -------------------------------------------------------- |
| [geo-sirene](https://www.data.gouv.fr/fr/datasets/base-sirene-des-entreprises-et-de-leurs-etablissements-siren-siret/#resource-community-c6006b4d-0b4b-4504-a762-1efe69c7ed18) | Version géocodée du stock des établiseement              |
| [insee-sirene](https://www.data.gouv.fr/fr/datasets/base-sirene-des-entreprises-et-de-leurs-etablissements-siren-siret/)                                                       | Base Sirene des entreprises et de leurs établissements   |
| [siret2idcc](https://www.data.gouv.fr/fr/datasets/liste-des-conventions-collectives-par-entreprise-siret/#_)                                                                   | Lien vers la convention collective                       |
| [kali-data](https://github.com/SocialGouv/kali-data)                                                                                                                           | Informations sur les conventions collectives             |
| [codes-naf](https://github.com/SocialGouv/codes-naf)                                                                                                                           | Liste des codes NAF (Nomenclature d’activités française) |

## Assemblage

Le script `sqlite.sh` permet de permet de télécharger les CSV, les importer dans SQLite puis les re-exporter en CSV pour une indexation dans ElasticSearch.

Au final, le fichier `./output/assembly.csv` fait environ 5Go avec plus de 30 millions de lignes. Cette opération dure environ 30 minutes.

## Indexation Elastic Search

Le dossier `index/` contient les scripts qui injectent le fichier `assembly.csv` dans un index `recherche-entreprises` ElasticSearch.

La mise à jour exploite la fonctionnalité [alias](https://www.elastic.co/guide/en/elasticsearch/reference/6.8/indices-aliases.html) d'ElasticSearch pour éviter les downtimes.

Le script `scripts/create-es-keys.sh` permet de créer des token pour lire/écrire sur ces index.

Pour lancer une indexation :

```sh
yarn install

ELASTICSEARCH_URL=https://elastic_url:9200 ELASTICSEARCH_API_KEY=key_with_writing_rights ASSEMBLY_FILE=./output/assembly.csv yarn start
```

The default `ELASTICSEARCH_INDEX_NAME` is `recherche-entreprises`
