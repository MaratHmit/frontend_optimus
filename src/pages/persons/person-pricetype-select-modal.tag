person-pricetype-select-modal
    bs-modal
        #{'yield'}(to="title")
            .h4.modal-title Тип цены
        #{'yield'}(to="body")
            form(onchange='{ change }', onkeyup='{ change }')
                .form-group.col-sm-12(class='{ has-error: error.parentName }')
                    label.control-label Выберите тип цены
                    .input-group(style="width: 100%")
                        select.form-control(name='priceType')
                            option(each='{ priceTypeTitle }', value='{ id }', selected='{ id == item.priceType }', no-reorder) { name }

        #{'yield'}(to='footer')
            button(onclick='{ modalHide }', type='button', class='btn btn-default btn-embossed') Закрыть
            button(onclick='{ parent.opts.submit }', type='button', class='btn btn-primary btn-embossed') Выбрать

    script(type='text/babel').
        var self = this

        self.on('mount', () => {
            let modal = self.tags['bs-modal']
            modal.item = {}
            modal.item.priceType = 0
            modal.priceTypeTitle = [
                {id: 0, name: 'Розничная'},
                {id: 1, name: 'Корпоративная'},
                {id: 2, name: 'Оптовая'}
            ]

            modal.mixin('change')
        })