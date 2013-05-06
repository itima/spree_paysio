module Spree    
  module PaysioHelper
    def paysio_form_for(order)
      Paysio.api_key = Spree::PaymentMethod::PaysioCom.preferences[:client_api_key]
      Paysio.publishable_key = Spree::PaymentMethod::PaysioCom.preferences[:client_publishable_key]
      "#{render_javascript(order.total.to_i * 100)}".html_safe
      # form.render
    end

    def static_url(string)
      Paysio.static_url(string)
    end

    def render_javascript(amount)
      opt = { key: "#{Paysio.publishable_key}", amount: amount }
      if @charge.present? 
        if @charge.class == Paysio::Charge
          opt.merge!(charge_id: @charge.id) 
        else
          errors = @charge.params
        end
      end
      html = <<-TEXT
        <script type="text/javascript">
          PaysioCom.build('#{Paysio.api_url}', '#paysio', #{opt.to_json})
        </script>
      TEXT
    end
  end
end