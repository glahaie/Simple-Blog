#Vérification et envoi du formulaire pour modifier un article
($ document).ready ()->
    ($ 'form').submit (event) ->
        event.preventDefault()
    ($ '#enregistrer').click (event) ->
        if not verifierErreur false
            envoyerFormulaire "PUT", "/admin/modifier", true

#Pour le bouton de suppression
($ document).ready () ->
    ($ '#supprimer').click (event) ->
        supprimer()

($ document).ready () ->
    ($ '#titre, #auteur').keydown (event) ->
        if event.keyCode is 13
            event.preventDefault()
            return false


#Fontion de qui fait la demande de suppression
supprimer = () ->
    #On prend le _id
    message = { }
    message.id = ($ '#_id').val()
    #Maintenant on AJAX
    $.ajax
        type:"DELETE"
        url: "/admin/effacer"
        data: message
        dataType: 'json'
        success: (data) ->
            changerModal data
        error: (request, status, error) ->
            ($ '.modal-body p').html "Erreur lors de la suppression"



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

