collections-groups-card
    bs-modal
        #{'yield'}(to="title")
            .h4.modal-title Добавить/изменить категорию коллекций
        #{'yield'}(to="body")
            loader(if='{ loader }')
            form(if='{ !loader }', onchange='{ change }', onkeyup='{ change }')
                .form-group(class='{ has-error: error.name }')
                    label.control-label Наименование
                    input.form-control(name='name', type='text', value='{ item.name }')
                    .help-block { error.name }
                .form-group
                    label.control-label Цена
                    input.form-control(name='price', type='number', min='0', step='0.01', value='{ parseFloat(item.price) }')
                .form-group(class='{ has-error: error.description }')
                    label.control-label Описание
                    textarea.form-control(rows='3', name='description',
                    style='min-width: 100%; max-width: 100%;', value='{ item.description }')
                    .help-block { error.description }
                .form-group
                    .checkbox
                        label
                            input(type='checkbox', name='isActive', checked='{ item.isActive }')
                            | Отображать в магазине
        #{'yield'}(to='footer')
            button(onclick='{ modalHide }', type='button', class='btn btn-default btn-embossed') Закрыть
            button(onclick='{ parent.opts.submit }', type='button', class='btn btn-primary btn-embossed') Сохранить

        script(type='text/babel').
            var self = this

            self.on('mount', () => {
                let modal = self.tags['bs-modal']

                modal.mixin('validation')
                modal.mixin('change')

                modal.item = {}
                modal.item.isActive = true

                modal.rules = {
                    name: 'empty'
                }

                modal.afterChange = e => {
                    modal.error = modal.validation.validate(modal.item, modal.rules, e.target.name)
                }

                if (opts.id) {
                    modal.loader = true

                    API.request({
                        object: 'CollectionGroup',
                        method: 'Info',
                        data: {id: opts.id},
                        success(response) {
                            modal.item = response
                        },
                        complete() {
                            modal.loader = false
                            modal.update()
                        }
                    })
                }
            })