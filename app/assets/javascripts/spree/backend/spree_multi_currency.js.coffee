$(@).ready( ->
  $('[data-hook=calculate_prices] #calculate_prices').click ->
    $.ajax
      type: 'POST'
      url: Spree.pathFor('admin/general_settings/calculate_prices')
      success: ->
        show_flash 'success', "Succesfully calculated and updated prices "
      error: (msg) ->
        if msg.responseJSON["error"]
          show_flash 'error', msg.responseJSON["error"]
        else
          show_flash 'error', "There was a problem while calculating prices"
)
