Deface::Override.new(:virtual_path => 'spree/admin/general_settings/edit',
  :name => 'add_calculate_prices_to_general_settings',
  :original => '22246b980c12f6c77bebd0a1a1f13cb071c5f06c',
  :insert_after => "erb[loud]:contains('select_tag :currency')",
  :text => "
    <div data-hook=calculate_prices>
      <%= button Spree.t(:calculate_prices), 'ok', 'button', id: 'calculate_prices' %>
    </div>
  ")
