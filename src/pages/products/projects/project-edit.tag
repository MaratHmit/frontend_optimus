| import 'components/ckeditor.tag'
| import parallel from 'async/parallel'
| import 'pages/products/products/products-list-select-modal.tag'
| import 'pages/products/projects/project-group-select-modal.tag'

project-edit
    loader(if='{ loader }')
    virtual(hide='{ loader }')
        .btn-group
            a.btn.btn-default(href='#products/projects') #[i.fa.fa-chevron-left]
            button.btn(if='{ checkPermission("products", "0010") }', onclick='{ submit }',
                class='{ item._edit_ ? "btn-success" : "btn-default" }', type='button')
                i.fa.fa-floppy-o
                |  Сохранить
            button.btn.btn-default(onclick='{ reload }', title='Обновить', type='button')
                i.fa.fa-refresh
        .h4 { item.name || 'Редактирование проекта' }
        ul.nav.nav-tabs.m-b-2
            li.active #[a(data-toggle='tab', href='#project-edit-home') Информация о проекте]
            li #[a(data-toggle='tab', href='#project-edit-photos') Фотографии]
            li #[a(data-toggle='tab', href='#project-edit-seo') SEO Продвижение]
            li #[a(data-toggle='tab', href='#project-edit-products') Товары]

        form(action='', onchange='{ change }', onkeyup='{ change }', method='POST')
            .tab-content
                #project-edit-home.tab-pane.fade.in.active
                    .row
                        .col-md-6
                            .row
                                .col-md-12
                                    .form-group(class='{ has-error: error.name }')
                                        label.control-label Наименование
                                        input.form-control(name='name', type='text', value='{ item.name }')
                                        .help-block { error.name }
                    .row
                        .col-md-6
                            .form-group
                                label Группа проекта
                                .input-group
                                    input.form-control(name='nameGroup', value='{ item.nameGroup }', readonly='{ true }')
                                    .input-group-btn
                                        .btn.btn-default(onclick='{ selectGroup }')
                                            i.fa.fa-list.text-primary
                                        .btn.btn-default(onclick='{ removeGroup }')
                                            i.fa.fa-times.text-danger
                    .row
                        .col-md-12
                            .form-group
                                label.control-label Описание
                                ckeditor(name='text', value='{ item.text }')

                #project-edit-photos.tab-pane.fade
                    form(action='', onchange='{ change }', onkeyup='{ change }', method='POST')
                        product-edit-images(name='images', value='{ item.images }', section='shopProject')
                #project-edit-seo.tab-pane.fade
                    form(action='', onchange='{ change }', onkeyup='{ change }', method='POST')
                        .row
                            .col-md-12
                                .form-group
                                    button.btn.btn-primary.btn-sm(each='{ seoTags }', title='{ note }', type='button'
                                        onclick='{ seoTag.insert }', no-reorder) { name }
                                .form-group
                                    label.control-label  Заголовок
                                    input.form-control(name='title', type='text',
                                        onfocus='{ seoTag.focus }', value='{ item.title }')
                                .form-group
                                    label.control-label  Ключевые слова
                                    input.form-control(name='keywords', type='text',
                                        onfocus='{ seoTag.focus }', value='{ item.keywords }')
                                .form-group
                                    label.control-label  Описание
                                    textarea.form-control(rows='5', name='description', onfocus='{ seoTag.focus }',
                                        style='min-width: 100%; max-width: 100%;', value='{ item.description }')

                #project-edit-products.tab-pane.fade
                    .row
                        .col-md-12
                            catalog-static(name='products', add='{ addProducts }', handlers='{ itemsHandlers }',
                                cols='{ productsCols }', rows='{ item.products }', remove='true')
                                #{'yield'}(to='body')
                                    datatable-cell(name='id') { row.id }
                                    datatable-cell(name='code') { row.code }
                                    datatable-cell(name='article') { row.article }
                                    datatable-cell(name='name') { row.name }
                                    datatable-cell(name='count', style = "width: 100px")
                                        input.form-control(
                                            style="text-align:center",
                                            type='number',
                                            min='0', step='1',
                                            value='{ parseFloat(row.count) }',
                                            onchange='{ handlers.numberChange }'
                                        )
                                    datatable-cell(name='price') { row.price }


    script(type='text/babel').
        var self = this

        self.item = {}
        self.loader = false
        self.error = false
        self.mixin('permissions')
        self.mixin('validation')
        self.mixin('change')

        self.productsCols = [
            {name: 'id', value: '#'},
            {name: 'code', value: 'URL'},
            {name: 'article', value: 'Артикул'},
            {name: 'name', value: 'Наименование'},
            {name: 'count', value: 'Кол-во'},
            {name: 'price', value: 'Цена'},
        ]


        self.rules = {
            name: 'empty'
        }

        self.afterChange = e => {
            self.error = self.validation.validate(self.item, self.rules, e.target.name)
        }

        self.submit = e => {
            var params = self.item
            self.error = self.validation.validate(params, self.rules)

            if (!self.error) {
                API.request({
                    object: 'ShopProject',
                    method: 'Save',
                    data: params,
                    success(response) {
                        popups.create({title: 'Успех!', text: 'Проект сохранен!', style: 'popup-success'})
                        observable.trigger('projects-reload')
                    }
                })
                }
        }

        self.reload = () => {
            observable.trigger('projects-edit', self.item.id)
        }

        self.itemsHandlers =  {
            numberChange(e) {
                console.log("ok")
                this.row[this.opts.name] = e.target.value
                console.log(this.opts.name)
            }
        }

        observable.on('projects-edit', id => {
            self.loader = true
            self.error = false
            var params = {id: id}

            API.request({
                object: 'ShopProject',
                method: 'Info',
                data: params,
                success(response) {
                    self.item = response
                    self.loader = false
                    self.update()
                },
                error(response) {
                    self.item = {}
                    self.loader = false
                    self.update()
                }
            })
        })


        // Выбор группы
        self.selectGroup = e => {
            modals.create('project-group-select-modal', {
                type: 'modal-primary',
                submit() {
                    let items = this.tags['catalog-tree'].tags.treeview.getSelectedNodes()
                    self.item.idGroup = items[0].id
                    self.item.nameGroup = items[0].name

                    self.update()
                    this.modalHide()
                }
            })
        }

        self.addProducts = () => {
            modals.create('products-list-select-modal', {
            type: 'modal-primary',
            size: 'modal-lg',
            submit() {
                self.item.products = self.item.products || []

                let items = this.tags.catalog.tags.datatable.getSelectedRows()

                let ids = self.item.products.map(item => {
                    return item.id
                })

                items.forEach(item => {
                    item.count = 1
                    if (ids.indexOf(item.id) === -1) {
                        self.item.products.push(item)
                    }
                })

                self.update()
                this.modalHide()
                }
            })
        }


        // Удалить группу
        self.removeGroup = e => {
            self.item.idGroup = 0
            self.item.nameGroup = ''
        }

        self.on('update', () => {
            localStorage.setItem('SE_section', 'shopproject')
        })

        self.on('mount', () => {
            riot.route.exec()
        })