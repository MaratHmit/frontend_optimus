import-persons-modal
    bs-modal
        #{'yield'}(to="title")
            .h4.modal-title Импорт
        #{'yield'}(to="body")
            loader(text='Импорт', indeterminate='true', if='{ loader }')
            form(onchange='{ change }', onkeyup='{ change }')
                .form-group(class='{ has-error: error.filename }')
                    .input-group
                        .input-group-btn
                            .btn-file.btn.btn-default(onchange='{ changeFile }')
                                input(name='file', type='file', accept='.xlsx, .csv')
                                i.fa.fa-fw.fa-folder-open.text-primary
                        input.form-control(
                            name='filename',
                            value='{ item.filename }',
                            placeholder='Выберите файл или введите ссылку',
                            disabled='{ file.files.length }'
                        )
                        .input-group-btn
                            .btn-file.btn.btn-default(onclick='{ clear }', title='Сброс')
                                i.fa.fa-fw.fa-close.text-danger
                .row
                    .col-md-6.col-xs-12

                        .form-group
                            label.control-label Пропустить строк
                            input.form-control(name='skip', type='number', min='0', step='1', value='{ item.skip }')

                        .form-group
                            label.control-label Ограничитель поля
                            input.form-control(id='limFId', name='limiterField', value='{ item.limiterField }')

                    .col-md-6.col-xs-12

                        .form-group
                            label.control-label Разделитель столбцов
                            select.form-control(id='delimId', name='delimiter', value='{ item.delimiter }')
                                option(
                                    each='{ i in delimiters }', value='{ i.name }',
                                    selected='{ i.name == parent.item.delimiter }', no-reorder
                                ) { i.title }

                    .help-block { error.filename }
                //.form-group
                    label.control-label Тип импорта
                    br
                    label.radio-inline
                        input(type='radio', name='type', value='0', checked='{ item.type == 0 }')
                        | Обновление
                    label.radio-inline
                        input(type='radio', name='type', value='1', checked='{ item.type == 1 }')
                        | Вставка
                //.form-group(if='{ item.type == 1 }')
                    .checkbox-inline
                        label
                            input(name='reset', type='checkbox', checked='{ item.reset }')
                            | Очистить базу данных перед импортом
        #{'yield'}(to='footer')
            button(onclick='{ modalHide }', type='button', class='btn btn-default btn-embossed', disabled='{ cannotBeClosed }') Закрыть
            button(id='startImp', onclick='{ parent.submit }', type='button', class='btn btn-primary btn-embossed', disabled='{ cannotBeClosed }') Импорт


    script(type='text/babel').
        var self = this
        self.loader = true

        self.on('mount', () => {
            let modal = self.tags['bs-modal']

            /** ... разделителителя столбцов **/
            modal.delimiters = [
                {name: 'auto',  title: 'Автоопределение'},
                {name: ';',     title: 'Точка с запятой'},
                {name: ',',     title: 'Запятая'},
                {name: '\t',    title: 'Табуляция'}
            ]

            /** ... ключевое поле */
            modal.keyFields = [
                {name: 'article',   title: 'Артикул'},
                {name: 'id',        title: 'Идентификатор'},
                {name: 'code',      title: 'Код (URL)'},
                {name: 'name',      title: 'Наименование'}
            ]

            /** значния по умолчанию */
            modal.error = false
            modal.mixin('validation')
            modal.mixin('change')
            var limiterFieldValue = '"'
            var skipValue = 1

            modal.item = {
                filename      : '',
                type          : '0',
                reset         : false,
                limiterField  : limiterFieldValue,
                skip          : skipValue,
                delimiter     : modal.delimiters[0]['name']
            }

            modal.rules = {
                filename: {
                    required: true,
                    rules:[{
                        type: 'url',
                        prompt: 'Выберите файл или введите правильную ссылку',
                    }]
                }
            }
            self.blockImportButtonReload(modal.item.filename)

            modal.loader = false
            modal.changeFile = e => {
                modal.item.filename = e.target.files[0].name
                modal.update()

                /** блокировка полей для не CSV */
                if (modal.item.filename.indexOf(".csv")+1!=0) {
                    document.getElementById("delimId").disabled = false
                    document.getElementById("limFId").disabled = false
                } else {
                    document.getElementById("delimId").disabled = true
                    document.getElementById("limFId").disabled = true
                }

                self.blockImportButtonReload(modal.item.filename)
            }

            modal.clear = () => {
                modal.item.filename      = ''
                modal.item.file          = ''
                modal.file.value         = ''
                self.blockImportButtonReload(modal.item.filename)
            }

            /** после изменения */
            modal.afterChange = e => {
                if (modal.file.files && !modal.file.files.length) {
                    let name = e.target.name
                    delete modal.error[name]
                    modal.error = {...modal.error, ...modal.validation.validate(modal.item, modal.rules, name)}
                }

                if (modal.file.files && modal.file.files.length)
                    modal.error = false

                if (modal.item && modal.item.type == 0)
                    modal.item.reset = false

                delete modal.item.file
            }

        })

        self.blockImportButtonReload = (filename) => {
            /**
             * блокировка/разб.. кнопки импорта
             * @param {string} filename  имя выбранного файла
             * @param {bool}   startImp  id кнопки импорта
             */
            if (filename == '' || filename == undefined)
                document.getElementById("startImp").disabled = true
            else
                document.getElementById("startImp").disabled = false
        } // блокировка/разб.. импорта

        self.submit = () => {
            let modal = self.tags['bs-modal']
            let target = modal.file
            modal.loader = true

            /**
             * ЗАГРУЗИТЬ
             * данные уходят в Product.php post
             * по файлу - $items, по настройкам - $_POST
             */

            /** прикрепляем к отправке параметры */
            var formData = new FormData()
            for (var i = 0; i < target.files.length; i++) {
               formData.append('file' + i, target.files[i], target.files[i].name)
            }
            formData.append('delimiter', modal.item.delimiter)
            formData.append('limiterField', modal.item.limiterField)
            formData.append('skip', parseInt(modal.item.skip))
            API.upload({
                object: 'Contact',
                data: formData,
                success(response) {
                    self.update();
                    observable.trigger('persons-reload')
                    modal.modalHide()
                },
            })
            $("#importFile").val(undefined)
        }
