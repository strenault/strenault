# Mode d'emploi — publier vos outils sur le portfolio

## Pourquoi publier en extraits plutôt qu'en code complet

Vos scripts complets contiennent des informations liées au CHU de Nantes
(listes de numéros de série du parc, adresses internes, détails de
configuration réseau). Les extraits fournis (`extraits/`) illustrent la
valeur technique sans rien exposer : vous pouvez les publier tels quels.

Si vous voulez publier les scripts complets un jour, faites d'abord le
contrôle de la check-list ci-dessous.

## Contenu du kit (v2)

- `FICHES_PORTFOLIO.md` : les 4 fiches (dont 3 prêtes) + le bloc HTML à
  coller dans votre `index.html` GitHub Pages.
- `extraits/stress_cpu_dutycycle.ps1` : stress CPU par duty-cycle et
  scoring P90 (extrait StressTest_PC, assaini).
- `extraits/detection_machine_confiance.ps1` : détection du type de
  machine avec score de confiance (extrait Diag_PC, séries retirées).
- `extraits/latence_reseau_et_maj.ps1` : test de sortie Internet avec
  proxy, et détection du pilotage WSUS/Intune (extrait Get-Diagnostic).

## Étapes

1. **Captures d'écran** (avant publication, anonymisez) :
   - rapport HTML de StressTest_PC (section Résumé + tableau des scores) ;
   - console pendant un test ;
   - rapport HTML A4 de Diag_PC ;
   - extrait du CSV historique (colonnes seulement, données fictives).
   Dans chaque capture : remplacer les numéros de série et noms de
   machines par des valeurs fictives, ou les masquer.

2. **Déposer les fichiers sur GitHub** : dans le dépôt de votre portfolio,
   créez un dossier `extraits/` avec les `.ps1` et un dossier `captures/`
   avec les images. Le dépôt de code peut aussi hériter un dépôt séparé
   type `strenault/outils-diag` si vous voulez donner le lien « Code ».

3. **Intégrer le HTML** : copier le bloc de `FICHES_PORTFOLIO.md` dans
   `index.html`, au-dessus de la partie Réseaux, et ajuster les classes
   CSS pour qu'elles matchent celles de vos projets existants.

4. **Mettre à jour le lien du CV** : le CV actuel pointe vers
   `strenault.github.io/portfolio/` — une fois la section en ligne, le
   lien fonctionnera sans changement.

## Check-list d'anonymisation (si vous publiez du code complet)

À retirer ou remplacer avant toute publication :

- [ ] Toutes les listes de numéros de série (HashSet `...Set` DiagIdentification.psm1) : les retirer entièrement.
- [ ] URLs internes : `mail.chu-nantes.fr`, `CHUStore`, ruchers spécifiques au CHU → remplacer par des exemples génériques.
- [ ] Noms de machines internes : la regex `(CHU\d{5,6})` peut rester en exemple générique.
- [ ] Détails de filtrage réseau propres à l'établissement (commentaires « bloqué par le pare-feu du CHU »).
- [ ] Vérifier avec votre hiérarchie si les outils appartiennent au cadre
      de la mission : si oui, publiez les extraits et une description
      fonctionnelle, pas le code.

## Le dépôt git recommandé

```
portfolio/
├── index.html            (page GitHub Pages existante + nouvelle section)
├── extraits/
│   ├── stress_cpu_dutycycle.ps1
│   ├── detection_machine_confiance.ps1
│   └── latence_reseau_et_maj.ps1
└── captures/
    ├── stresstest_rapport.png
    ├── getdiagnostic_rapport.png
    └── diagpc_rapport.png
```

## Nouveautés de cette version

- `index.html` : votre page complète, mise à jour, avec la nouvelle section
  « Outils développés — Maintenance de parc (PowerShell) » en tête. Remplacez
  votre index.html actuel par celui-ci (les autres fichiers du site ne changent pas).
- Fiche « Rch Pilote » complétée dans FICHES_PORTFOLIO.md.
- `extraits/rch_pilote_selectif.ps1` : extrait assaini (nom du serveur de
  pilotes remplacé par un exemple générique).
- Les cartes StressTest_PC / Get-Diagnostic / Diag_PC pointent vers
  `captures/*.png` : ajoutez ces captures dans un dossier `captures/`
  (mêmes noms de fichiers) une fois anonymisées.
