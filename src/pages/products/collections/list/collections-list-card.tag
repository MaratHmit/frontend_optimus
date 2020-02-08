| import parallel from 'async/parallel'

collections-list-card
    bs-modal
        #{'yield'}(to="title")
            .h4.modal-title Коллекция
        #{'yield'}(to="body")
            loader(if='{ loader }')
            form(if='{ !loader }', onchange='{ change }', onkeyup='{ change }')
                .form-group(class='{ has-error: error.name }')
                    label.control-label Наименование
                    input.form-control(name='name', type='text', value='{ item.name }')
                    .help-block { error.name }
                .form-group
                    label.control-label Категория
                    select.form-control(name='idGroup', value='{ item.idGroup }')
                        option(value='') Не выбрана
                        option(each='{ group in groups }', selected='{ item.idGroup == group.id }',  value='{ group.id }') { group.name }
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
            button(onclick='{ parent.opts.submit.bind(this) }', type='button', class='btn btn-primary btn-embossed') Сохранить

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

                modal.groups = []
                modal.item.idGroup = opts.option || 0

                modal.afterChange = e => {
                    modal.error = modal.validation.validate(modal.item, modal.rules, e.target.name)
                }

                modal.getOptionGroup = () => {
                    API.request({
                        object: 'CollectionGroup',
                        method: 'Fetch',
                        success(response) {
                            modal.groups = response.items
                            modal.update()
                        }
                    })
                }

                if (opts.id) {
                    modal.loader = true

                    API.request({
                        object: 'Collection',
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

                modal.getOptionGroup()
            })