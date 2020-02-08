feature-new-edit-modal
    bs-modal
        #{'yield'}(to="title")
            .h4.modal-title Элемент списка параметра
        #{'yield'}(to="body")
            form(onchange='{ change }', onkeyup='{ change }')
                .row
                    .col-md-4(if='{ parent.opts.typeparam=="list" || parent.opts.typeparam=="colorlist" }')
                        .form-group
                            .well.well-sm
                                image-select(name='image', section='shopfeature', alt='0', size='256', value='{ item.image }')

                    div(class="{ (parent.opts.typeparam=='colorlist' || parent.opts.typeparam=='list' ) ? 'col-md-8' : 'col-md-12'}")
                        .form-group(class='{ has-error: error.value }')
                            label.control-label Наименование
                            input.form-control(name='value', type='text', value='{ item.value }')
                            .help-block { error.value }
                        .form-group
                            label.control-label Код (URL)
                            input.form-control(name='code', type='text', value='{ item.code }')
                        .form-group(if='{ parent.opts.typeparam=="colorlist" }', class='{ has-error: error.color }')
                            label.control-label Цвет
                            input.form-control(name='color', type='color', value='{ item.color }')
                            .help-block { error.color }
        #{'yield'}(to='footer')
            button(onclick='{ modalHide }', type='button', class='btn btn-default btn-embossed') Закрыть
            button(onclick='{ parent.opts.submit }', type='button', class='btn btn-primary btn-embossed') Сохранить
        
    script(type='text/babel').
        var self = this

        self.on('mount', () => {
            let modal = self.tags['bs-modal']
            //modal.cannotBeClosed = true

            modal.item = opts.item || {}
            modal.mixin('validation')
            modal.mixin('change')

            modal.rules = {
                value: 'empty'
            }

            modal.afterChange = e => {
                modal.error = modal.validation.validate(modal.item, modal.rules, e.target.name)
            }
        })
