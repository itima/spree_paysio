@PaysioCom = 
  build: (end_point, id, opt, values = {}, errors = []) ->
    Paysio.setEndpoint(end_point)
    Paysio.setPublishableKey(opt.key)

    $form = $(id)
    @get_template(opt, end_point).done((data) ->
      if (data.error)
        $form.text(data.error.message + '. Check console.')
        console.log(data)
        return
      else if (data.location)
        window.location.replace(data.location)
        return
      $form.html(data.template.replace /<input class="paysio-button.+?>/, '')

      if (data.systems_fields)
        Paysio.form.setSystemFields(data.systems_fields)
        Paysio.form.init($form)
        if (values)
          Paysio.form.setValues($form, values)
        if (errors && errors.length) 
          Paysio.form.setErrors($form, errors)
      )

  get_template: (opt, endpoint) ->
    $.ajax({
      data: opt,
      dataType: 'jsonp',
      url: endpoint + '/form'
      });     
