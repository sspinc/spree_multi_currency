$(@).ready( ->
  $('[data-hook=calculate_currencies] #calculate_currencies').click ->
    $.ajax
      type: 'POST'
      url: Spree.pathFor('admin/general_settings/calculate_currencies')
      success: ->
        show_flash 'success', "Currencies calculated and updated"
      error: (msg) ->
        if msg.responseJSON["error"]
          show_flash 'error', msg.responseJSON["error"]
        else
          show_flash 'error', "There was a problem while calculating currencies"
)
