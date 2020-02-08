modification-edit-modal
    bs-modal
        #{'yield'}(to="title")
            .h4.modal-title { title }
        #{'yield'}(to="body")
            form(onchange='{ change }', onkeyup='{ change }')
                .row
                    .col-md-12
                        .form-group(class='{ has-error: error.name }')
                            label.control-label Наименование
                            input.form-control(name='name', value='{ item.name }')
                            .help-block { error.name }
                .row
                    .col-md-12
                        .form-group(class='{ has-error: error.type }')
                            label.control-label Тип цены
                            select.form-control(name='vtype', value='{ item.vtype }')
                                option(value='0') Добавляет к цене
                                option(value='1') Умножает на цену
                                option(value='2') Замещает цену
                            .help-block { error.vtype }
        #{'yield'}(to='footer')
            button(onclick='{ modalHide }', type='button', class='btn btn-default btn-embossed') Закрыть
            button(onclick='{ parent.opts.submit }', type='button', class='btn btn-primary btn-embossed') Сохранить
        
    script(type='text/babel').
        var self = this

        self.on('mount', () => {
            let modal = self.tags['bs-modal']

            modal.item = opts.item || {}
            modal.mixin('validation')
            modal.mixin('change')
            modal.title = opts.title

            modal.rules = {
                name: 'empty',
                values: {
                    required: true,
                    rules: [{
                        vtype: 'minLength[1]',
                        prompt: 'В списке должно быть не менее одного элемента'
                    }]
                },
            }

            modal.afterChange = e => {
                modal.error = modal.validation.validate(modal.item, modal.rules, e.target.name)
            }
        })
