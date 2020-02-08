| import 'components/ckeditor.tag'

geotargeting-addpage-modal
    bs-modal
        #{'yield'}(to="title")
            .h4.modal-title Добавить/изменить базовую страницу
        #{'yield'}(to="body")
            loader(if='{ loader }')
            form(if='{ !loader }', onchange='{ change }', onkeyup='{ change }')
                .form-group(if='{ !item.id }', class='{ has-error: error.name }')
                    label.control-label  URL страницы
                    input.form-control(name='name', type='text', value='{ item.name }')
                    .help-block { error.name }
        #{'yield'}(to='footer')
            button(onclick='{ modalHide }', type='button', class='btn btn-default btn-embossed') Закрыть
            button(onclick='{ parent.opts.submit.bind(this) }', type='button', class='btn btn-primary btn-embossed') Сохранить

    script(type='text/babel').
        var self = this

        self.on('mount', () => {
            let modal = self.tags['bs-modal']

            modal.item = opts.item || {}
            modal.error = false
            modal.item = {}
            modal.mixin('validation')
            modal.mixin('change')
            //modal.update()

            modal.rules = {
                name: 'empty',
            }

            modal.afterChange = e => {
                let name = e.target.name
                delete modal.error[name]
                modal.error = {...modal.error, ...modal.validation.validate(modal.item, modal.rules, name)}
            }

        })