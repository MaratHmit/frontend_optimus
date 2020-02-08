| import parallel from 'async/parallel'

collections-items-card
    bs-modal
        #{'yield'}(to="title")
            .h4.modal-title Элемент коллекции
        #{'yield'}(to="body")
            loader(if='{ loader }')
            form(if='{ !loader }', onchange='{ change }', onkeyup='{ change }')
                .row
                    .col-md-5
                        .form-group
                            .well.well-sm
                                image-select(name='image', section='collections', alt='0', size='256', value='{ item.image }')
                    .col-md-7
                        .form-group(class='{ has-error: error.name }')
                            label.control-label Наименование
                            input.form-control(name='name', type='text', value='{ item.name }')
                            .help-block { error.name }
                        .form-group
                            label.control-label Коллекция
                            select.form-control(name='idCollection', value='{ item.idCollection }')
                                option(value='') Не выбрана
                                option(each='{ collection in collections }', selected='{ item.idCollection == collection.id }',  value='{ collection.id }') { collection.name }
                        .form-group
                            label.control-label Описание
                            textarea.form-control(name='description', value='{ item.description }')
                        .form-group
                            .checkbox
                                label
                                    input(type='checkbox', name='isActive', checked='{ item.isActive }')
                                    | Отображать в магазине

        #{'yield'}(to='footer')
            button(onclick='{ modalHide }', type='button', class='btn btn-default btn-embossed') Закрыть
            button(onclick='{ parent.opts.submit.bind(this) }', type='button', class='btn btn-primary btn-embossed') Сохранить

        script(type='text/babel').
            let self = this

            self.on('mount', () => {

                let modal = self.tags['bs-modal']

                 modal.mixin('validation')
                 modal.mixin('change')

                 modal.item = {}
                 modal.item.isActive = true

                 modal.rules = {
                     name: 'empty'
                }

                modal.collections = []
                modal.item.idCollection = opts.option || 0

                modal.afterChange = e => {
                    modal.error = modal.validation.validate(modal.item, modal.rules, e.target.name)
                }

                modal.getCollections = () => {
                    API.request({
                    object: 'Collection',
                        method: 'Fetch',
                        success(response) {
                        modal.collections = response.items
                        modal.update()
                       }
                    })
                }

                if (opts.id) {
                    modal.loader = true

                    API.request({
                        object: 'CollectionItem',
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

                modal.getCollections()
            })