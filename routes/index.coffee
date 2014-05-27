#Routes pour le blog
moment = require 'moment'
_ = require 'underscore'
_.str = require 'underscore.string'
_.mixin _.str.exports()
_.str.include 'Underscore.string', 'string'


#Exportation des routes
module.exports = (app, coll) ->

    app.get '/', (req, res) ->
        recupererListe coll, (err, result) ->
            if err
                res.render 'erreur',
                    title: 'Erreur lors du traitement de la demande'
            else
                res.render 'accueil',
                    title: 'Page d\'accueil'
                    articles: result


    app.get '/admin/publier', (req, res) ->
        res.render 'publier',
            title: 'Publier un article'


    app.post '/admin/ajouter', (req, res) ->
        ajouterArticle req.body, coll, (err, result) ->
            if err and err is 11000
                res.json
                    erreur: true
                    message: 'Erreur: identifiant existant déjà, veuillez le modifier.'
            else if err
                res.json 500
            else
                res.json 201,
                    message: result

    #J'utilise le statut 200 pour la modification avec succès
    #car 204 ne permet pas de récupérer le message.
    app.put '/admin/modifier', (req, res) ->
        modifierArticle req.body, coll, (err, result) ->
            if err
                res.json 500,
                    message: 'Erreur lors de la modification'
            else
                res.json 200,
                    message: result


    app.delete '/admin/effacer', (req, res) ->
        effacerArticle req.body, coll, (err, result) ->
            if err
                res.json 500
            else
                res.json 200,
                    message: result

    app.get '/:idUnique', (req, res) ->
        trouverArticle req.params.idUnique, coll, true, (err, result) ->
            if err is 404
                res.render '404'
            else if err is 500
                res.render 'erreur',
                    title: 'Erreur lors de la requête au serveur'
            else
                res.render 'article',
                    title:  result.titre
                    article: result

    app.get '/admin/:idUnique', (req, res) ->
        trouverArticle req.params.idUnique, coll,false, (err, result) ->
            if err is 404
                res.render '404'
            else if err is 500
                res.render 'erreur',
                    title: 'Erreur lors de la requête au serveur'
            else
                res.render 'afficherModifier',
                    title:  result.titre
                    article: result

###############################################################################
# fonctions sur mongodb
###############################################################################

#Identifie un article selon son _id, utilisé pour l'article et sa modification
trouverArticle = (id, coll, doHTML, callback) ->
    cursor = coll.find {"_id": "#{id}"},
        titre:true
        auteur:true
        date:true
        texte:true
            
    cursor.toArray (err, result) ->
        if err
            callback
        else
            if result.length is 0
                callback 404
            else if result.length > 1
                callback 500
            else
                info = result[0]
                if doHTML
                    info.texte = toHTML info.texte
                else
                    info.texte = toText info.texte
                info.date = prettyDate info.date
                callback null, info

#Retourne une liste de tous les éléments de la collection blog,
#on ajoute les balises de html nécessaires
recupererListe = (coll, callback) ->
    cursor = coll.find {},
        date:true
        titre:true
        auteur:true
        texte:true
            
    cursor.toArray (err, result) ->
        if err
            throw err
        else
            result2 = _.sortBy result, (datePub) ->
                return new Date datePub.date
            articles = {}
            articles.titres = []
            articles.recent = []
            for article, index in result2.reverse()
                if index < 3
                    article.texte = toHTML article.texte
                    article.date = prettyDate article.date
                    articles.recent.push article
                articles.titres.push
                    "_id":article._id
                    "titre":article.titre
            callback null, articles


#TraiterAjout: on vérifie d'abord l'unicité du id
ajouterArticle = (donnees, coll, callback) ->

#On modifie les données nécessaires
    donnees.date = new Date donnees.date
    donnees.texte = toParagraph donnees.texte
    coll.insert donnees, {w:1},(err, docs) ->
        if err and err.code is 11000
            callback 11000
        else
            callback null, "Article publié."

#Modifie les données d'un article dans mongoDB, mais
#ne change pas le _id et la date de publication
modifierArticle = (donnees, coll, callback) ->
    #On ouvre mongoDB
    donnees.texte = toParagraph donnees.texte
    coll.update {"_id":"#{donnees._id}"}, {$set: {"titre":"#{donnees.titre}", "texte":donnees.texte, "auteur":"#{donnees.auteur}"}}, {upsert:false, w:1}, (err, docs) ->
        if err
            callback err
        else
            callback null, "Article modifié."

effacerArticle = (donnees, coll, callback) ->
    coll.remove {"_id": donnees.id}, {w:1}, (err, count) ->
        if err
            callback err
        else if not count is 1
            callback 500
        else
            callback null, "Article effacé."

###############################################################################
# Texte à HTML
###############################################################################

#Ajoute des balises <p> pour le texte où nécessaire.
#on a déjà enlevé les lignes vides, donc pas besoin de vérifier
#
#Pour le moment, on gère seulement les balises <ul>, <li>, les balises <a>
#sont dans une ligne, donc c'est correct.
toHTML = (texte) ->
    result = ""
    for line in texte
        line = _.trim line
        paragraph = "<p>"
        for word in _.words line.replace(/</g, " <").replace(/>/g,"> ")
            if (word is "<ul>") or (word is "</ul>")
                if not (paragraph is "<p>")
                    result = _.join "", result,paragraph, "</p>\n"
                result = _.join "", result, word,"\n"
                paragraph = "<p>"
            else if word is "<li>"
                if not (paragraph is "<p>")
                    result = _.join "", result, paragraph,"</p>\n"
                result = _.join "", result, word
                paragraph = ""
            else if word is "</li>"
                result = _.join "", result, paragraph, word, "\n"
                paragraph = "<p>"
            else
               paragraph = _. join " ", paragraph, word
        if not (paragraph is "<p>")
            result = _.join "", result, paragraph, "</p>\n"
    return result

#On transforme la liste de paragraphe en une chaine
#j'ajoute un \n au début car il semble disparaitre dans jade
toText = (texte) ->
    result = "\n"
    for line in texte
        result = _.join "", result,line, "\n\n"
    return result.substring 0, result.length - 1

#formater la date
prettyDate = (dateString) ->
    date = moment dateString
    return date.format "YYYY-MM-DD"

#Séparer le texte en liste de paragraphe, la gestion des
#balises HTML sera faite lors de la préparation à l'affichage.
#Pour le moment, je me contente d'enlever les lignes blanches.
#On considère aussi qu'il y a un nouveau paragraphe si on rencontre
#deux retour chariot de suite.
toParagraph = (texte) ->
    return _.words texte, "\n\n"

