################################################################################
# Vérification.coffee
################################################################################


#Vérifie les champs du formulaire, et si on rencontre un erreur, on l'affiche à
#l'utilisateur
verifierErreur = (verifID) ->
    erreur = false
    donnees = $ '#_id, #titre, #auteur, #texte'
    donnees.each () ->
        if ($ this).val().trim() is ""
            ajouterMessageErreur ($ this).attr('id'), "Ce champ ne peut être vide."
            erreur = true
        else if verifierScript ($ this).val()
            ajouterMessageErreur ($ this).attr('id'), "Détection d'une balise script."
            erreur = true
        else if (($ this).attr('id') is "_id") and verifID and verifierErreurID ($ this)
            ajouterMessageErreur ($ this).attr('id'), "Identifiant invalide."
            erreur = true
        else
            ($ this).removeClass 'error'
            ($ this).next().remove()
            temp = ($ this).attr 'id'
            
    return erreur

#Vérifie si on détecte une balise script entrante et fermante dans un champ
#source: 
#http://stackoverflow.com/questions/6659351/removing-all-script-tags-from-html-with-js-regular-expression
#Ce n'est pas une vérification très poussée, mais c'est mieux que rien.
verifierScript = (texte) ->
    return (/<script\b[^<]*(?:(?!<\/script>)<[^<]*)*<\/script>/).test texte

#Vérifie si l'identifiant est bien formé (doit ressembler à un slug)
verifierErreurID = (id) ->
    return ((/(?=.*(\s|[\/\\;,'"{}]|[\u0080-\uFFFF]))/).test id.val().toLowerCase().trim())

#Ajoute le message d'erreur à l'endroit approprié
#Je traite avec le id directe et pas l'objet, drôle de bug
#avec Chrome, pour le champ ID dans publier, on peut obtenir deux
#messages d'erreur
ajouterMessageErreur = (div, messageErr) ->
    ($ "##{div}Err").empty()
    ($ "##{div}").addClass 'error'
    message = $ '<div>',
        class: "error-msg"
        text: messageErr
    ($ "##{div}Err").append message


#Envoi les données du formulaire au serveur pour sauvegarde
envoyerFormulaire = (type, url, modif) ->
#On récupère les données. serialize ne semble pas fonctionner pour une raison
    
    resultat = {}
    donnees = $ '#_id, #titre, #auteur, #texte'
    donnees.each () ->
        cle = ($ this).attr 'id'
        resultat[cle] = ($ this).val().trim()
    if modif
        resultat["date"] = ($ '#date').val()
    else
        resultat["date"] = new Date

    #On envoi le résultat
    $.ajax
        type: type
        url:  url
        data: resultat
        dataType: 'json'
        timeout:10000
        success: (data) ->
            afficherSucces data, modif, resultat['titre']
        error: (request, status, error) ->
            alert = $ '<div>',
                class:'alert alert-danger alert-dismissable'
                text: "Erreur de traitement:" + error
            alert.append $ '<button>',
                class:'close'
                'data-dismiss':'alert'
                text:'x'
            ($ "#alert-placeholder").empty().append alert


afficherSucces = (data, modif, titre) ->
    alert = $ '<div>',
        class:'alert alert-dismissable'
        text: data.message
    if data.erreur
        alert.addClass "alert-danger"
    else
        alert.addClass "alert-success"
    alert.append $ '<button>',
        class:'close'
        'data-dismiss':'alert'
        text:'x'
    ($ "#alert-placeholder").empty().append alert
    if modif
        ($ '#jumbo').html titre
        document.title = "Modification de \"#{titre}\""


#Fontion de qui fait la demande de suppression
supprimer = () ->
    #On prend le _id
    message = { }
    message.id = ($ '#_id').val()
    #Maintenant on AJAX
    xhr = $.ajax
        type:"DELETE"
        url: "/admin/effacer"
        data: message
        dataType: 'json'
        timeout: 5000
        success: (data) ->
            changerModal data
        error: (request, status, error) ->
            ($ '.modal-body p').html "Erreur lors de la suppression: " + error
        complete: () ->

#Succès de suppression: on affiche un lien pour retourner à la page d'accueil
changerModal = (data) ->
    ($ '.modal-body p').html data.message
    ($ '#annuler').remove()
    ($ '.close').remove()

    #Ça fonctionne...
    ($ '#supprimer').unbind 'click'
    ($ '#supprimer').html "Retourner à la page d'accueil"
    ($ '#supprimer').click () ->
        window.location = '/'

