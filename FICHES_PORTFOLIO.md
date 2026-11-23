# Fiches portfolio — Outils PowerShell de diagnostic de parc

> Fiches prêtes à intégrer dans votre GitHub Pages (https://strenault.github.io/portfolio/).
> Chaque fiche suit le style de vos projets existants : titre, description courte, technologies, date.
> À placer dans une nouvelle section « Outils développés — Maintenance de parc (PowerShell) », au-dessus de la partie Réseaux/TCP-IP.

---

## 1. StressTest_PC

**Description :** Outil de stress matériel pour postes de travail (mini-PC, tout-en-un, fixes, portables). Détection automatique du type de machine, tests parallélisés CPU / RAM / disque / GPU avec étalonnage, scores sur 100, détection des goulots d'étranglement (analyse P90), usure de la batterie sur portables. Génère un rapport HTML / CSV / JSON nominatif par poste et une aide à la décision de compatibilité Windows 11. Exécutable depuis une clé USB, sans droits administrateur.

**Technologies :** PowerShell 5.1, CIM/WMI, jobs parallèles, runspaces, compteurs de performance, rapports HTML autogénérés.

**Points forts à mettre en avant :**
- Charge CPU contrôlée par duty-cycle (cible 50 %) pour révéler les goulots ailleurs sans saturer le poste
- Score basé sur la proximité de la cible et le P90 (les pics isolés ne compte᷉nt pas)
- Étalonnage GPU avant le test réel : le score est relatif à la capacité mesurée de la machine
- Mode automatisé (`-SkipIdentification`) pour les campagnes en série

**Date : 2026** — **Version : 4.4**

**Captures d'écran recommandées :** rapport HTML (section Résumé + tableau des résultats avec les scores), console pendant un test (bandeau + monitoring CPU/RAM), rapport CSV ouvert dans Excel.

---

## 2. Get-Diagnostic

**Description :** Outil de diagnostic et de dépannage de postes Windows pour le support N1/N2. Contrôle disques (espace + santé SMART), services critiques (DNS, DHCP, spooler…), réseau (DNS, passerelle, sortie Internet avec détection du proxy), temps de démarrage, mises à jour en environnement géré (WSUS / Intune / GPO), BitLocker, état des pilotes, journaux d'erreurs. Mode `-Repair` : réparation assistée avec point de restauration et corrections confirmées une par une. Rapport HTML hiérarchisé (critique / attention / OK).

**Technologies :** PowerShell 5.1, CIM, journaux d'événements, registre (détection de pilotage central des mises à jour), rapports HTML colorés par criticité.

**Points forts à mettre en avant :**
- Distingue un poste piloté par WSUS/MDM d'un poste autonome : pas de fausse alerte « pas à jour » en entreprise
- Test de sortie Internet en deux temps (TCP 443 direct, puis via le proxy) car l'ICMP est souvent filtré
- Détection des redémarrages en attente (clés CBS / WU / PendingFileRenameOperations), piège fréquent du dépannage
- Mode réparation : aucune action sans confirmation explicite, point de restauration d'abord

**Date : 2026** — **Version : 2.3**

**Captures d'écran recommandées :** rapport HTML complet, console pendant le diagnostic (lignes colorées par niveau), le mode -Repair avec les confirmations.

---

## 3. Diag_PC — plateforme modulaire de diagnostic de parc

**Description :** Plateforme complète de diagnostic organisée en 3 modules PowerShell pilotés par un orchestrateur : identification du poste et de son type (avec score de confiance et confirmation guidée si nécessaire), tests périphériques selon le type de machine (écran plein écran avec couleurs/damier/dégradé, clavier avec vérification des touches saisies, webcam, tactile, haut-parleurs, batterie), contrôle des applications métiers et de la sécurité (antivirus/EDR), puis génération du rapport : HTML A4 imprimable, historique CSV consolidé sans doublons, classement et copie des photos du matériel.

**Technologies :** PowerShell 5.1 (modules .psm1), WinForms (fenêtres de test et de confirmation), CIM, historisation CSV, architecture orchestrateur / modules à contexte partagé.

**Points forts à mettre en avant :**
- Architecture modulaire à « source unique de vérité » : l'identification est faite une fois et partagée
- Détection multi-critères du type de machine (série, châssis, modèle, BIOS) avec score de confiance et fallback utilisateur guidé
- Journal d'apprentissage : chaque confirmation manuelle est loggée pour améliorer la détection
- Historique CSV consolidé : suivi du parc dans le temps (configuration, baterie, état)

**Date : 2026** — **Version : 2.0**

**Captures d'écran recommandées :** architecture en schéma (orchestrateur → 3 modules → rapport), fenêtre WinForms de confirmation du type de machine, rapport HTML A4, extrait du CSV historique.

---

## 4. Rch Pilote

**Description :** Outil de mise à jour **sélective** des pilotes depuis un partage réseau. Mappe temporairement le partage des pilotes, propose un dossier via une boîte de dialogue (par modèle de machine), compare les pilotes déjà publiés sur le poste (`pnputil /enum-drivers`) avec les fichiers .inf du dossier, et n'installe QUE les pilotes manquants via `pnputil /add-driver`. Récapitulatif installés / ignorés et proposition de redémarrage si nécessaire.

**Technologies :** PowerShell 5.1, pnputil, WinForms (boîte de sélection de dossier, confirmations), mappage réseau non persistant (`net use` / UNC).

**Points forts à mettre en avant :**
- Sélectif plutôt que massif : aucun risque d'écraser une version plus récente déjà en place, et un gain de temps important sur un parc
- Sélection guidée par modèle de machine, mappage temporaire proprement démonté et conversion Z: → UNC pour pnputil
- Confirmation avant installation puis proposition de redémarrer : rien ne se fait sans accord

**Date : 2026** — **Version : 3.0**

**Captures d'écran recommandées :** console pendant l'installation (lignes vertes « installé » / jaunes « ignoré » + résumé).

------

## Remarque

Le fichier `index.html` fourni dans ce kit contient déjà la section outils intégrée à votre page : remplacez simplement votre index.html actuel.

Ajoutez cette section dans votre `index.html`, au-dessus de la partie « Projets réalisés Administrateur Réseau & Sécurité » (adaptez les classes CSS à celles de votre page) :

```html
<h3>Outils développés — Maintenance de parc (PowerShell)</h3>

<div class="project">
  <h4>StressTest_PC — stress matériel et compatibilité Windows 11</h4>
  <p>
    Outil de stress CPU/RAM/disque/GPU avec détection automatique du type de machine,
    scores et goulots d'étranglement, rapport HTML/CSV/JSON nominatif et aide à la
    décision de compatibilité Windows 11. Fonctionne depuis une clé USB, sans
    droits administrateur.
  </p>
  <p><em>PowerShell, CIM/WMI, jobs parallèles, runspaces — v4.4 — 2026</em></p>
  <p><a href="captures/stresstest_rapport.png">Rapport HTML (capture)</a> ·
     <a href="extraits/detection_machine.html">Extrait de code : détection du type de machine</a></p>
</div>

<div class="project">
  <h4>Get-Diagnostic — diagnostic et dépannage N1/N2 de postes Windows</h4>
  <p>
    Diagnostic complet : disques (SMART), services critiques, réseau et proxy, démarrage,
    mises à jour en environnement géré (WSUS/Intune/GPO), BitLocker, journaux. Mode
    réparation assistée avec point de restauration et rapport HTML hiérarchisé
    (critique / attention / OK).
  </p>
  <p><em>PowerShell 5.1, CIM, journaux d'événements, registre — v2.3 — 2026</em></p>
  <p><a href="captures/getdiagnostic_rapport.png">Rapport HTML (capture)</a> ·
     <a href="extraits/latence_reseau.html">Extrait de code : test de latence réseau avec fallback TCP</a></p>
</div>

<div class="project">
  <h4>Diag_PC — plateforme modulaire de diagnostic de parc</h4>
  <p>
    Orchestrateur pilotant 3 modules PowerShell : identification des postes (fabricant,
    modèle, série, type avec score de confiance), tests guidés selon le type de machine
    (écran, clavier, webcam, tactile, batterie), contrôle des applications et de la
    sécurité, puis rapport HTML A4 nominatif et historique CSV consolidé du parc.
  </p>
  <p><em>PowerShell, modules .psm1, WinForms, historisation CSV — v2.0 — 2026</em></p>
  <p><a href="captures/diagpc_rapport.png">Rapport A4 (capture)</a> ·
     <a href="extraits/scoring_confiance.html">Extrait de code : détection multi-critères avec score de confiance</a></p>
</div>
```
