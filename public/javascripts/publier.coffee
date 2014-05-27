#Vérification et envoi du formulaire
($ document).ready ()->
    ($ 'form').submit (event) ->
        event.preventDefault()
    ($ '#enregistrer').click () ->
        if not verifierErreur true
            envoyerFormulaire "POST", "/admin/ajouter", false

#Fonction pour créer un slug à partir du titre. Pour le moment, je considère
#qu'un slug devrait avoir 50 caractères max
($ document).ready () ->
    ($ '#generer').click (event) ->
        event.preventDefault()
        genererIdentifiant()

# trouvée à
#http://stackoverflow.com/questions/895171/prevent-users-from-submitting-form-by-hitting-enter
($ document).ready () ->
    ($ '#titre, #_id, #auteur').keydown (event) ->
        if event.keyCode is 13
            event.preventDefault()
            return false

#On popover pour donner de l'information à propos du bouton de génération d'identifiant
($ document).ready () ->
    ($ '#generer').popover
        placement: 'right'
        trigger: 'hover'
        title: 'Générer un identifiant'
        content: 'Génère un identifiant à partir du titre. Faites attention, l\'identifiant actuel sera écrasé.'

($ document).ready () ->
    ($ '#_id').popover
        placement: 'bottom'
        trigger: 'focus'
        title: 'Identifiant'
        content: 'L\'identifiant d\'un article ne doit contenir que des caractères acceptés dans un URL (pas d\'espaces ou de caractères avec des accents surtout).'


#Génère un identifiant à partir du titre
genererIdentifiant = () ->
    titre = ($ '#titre').val().trim()
    if not (titre is '')
        titre = titre.toLowerCase()
        titre = titre.replace(/é|è|ê|ë/g, 'e').replace(/à|â|ä/g, 'a').replace(/î|ï/g, 'i').replace(/ô|ö/g, 'o').replace(/ç/g, 'c').replace(/\s+/g, '-').replace(/[!@\/\\$%?&*():;.,'"{}]|[\u0080-\uFFFF]/g, '')
        titre = titre.substring 0, 50
        if (titre.charAt 49) is "-"
            titre = titre.substring 0, 49
        ($ '#_id').val titre


