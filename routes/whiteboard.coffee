colors = ["#FFFFFF", "#C0C0C0", "#808080", "#000000", "#FF0000", "#800000", "#FFFF00", "#808000", "#00FF00", "#008000", "#00FFFF", "#008080", "#0000FF", "#000080", "#FF00FF", "#800080"]

exports.index = (req, res) ->
  res.render('whiteboard/index', {title: "Board: #{req.params.id}", colors: colors, colorCount: colors.length, id: req.params.id})